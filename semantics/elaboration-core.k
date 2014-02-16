require "core.k"
require "subtyping.k"
require "process-class-members.k"
require "elaboration-expressions.k"

/*@ \section{Module ELABORATION-CORE}
Elaborate the composition of code blocks of a class - the last step of preprocessing.
During this phase we inspect the contents of method bodies, instance initializers and
static initializers of a class and perform the following transformations:
\begin{itemize}
  \item each variable name x is resolved into either:
  \begin{itemize}
    \item x - a local var
    \item Class.x - a static var defined in the class Class
    \item field(obj, Class, x) - a field of object obj declared in the class Class.
      Term obj could also be 'This.
  \end{itemize}
  \item each method name is resolved into either:
  \begin{itemize}
    \item Class.m - a static method defined in the class Class
    \item method(obj, Class, x) - an instance method of object obj declared in the class Class.
      Term obj could also be 'This. The actual version of the method will be looked up at runtime.
  \end{itemize}
  \item each method signature is resolved into its appropriate overloaded version. To
    denote the version, each actual parameter will be casted to the type of the actual parameter.
  \item each expression Exp will be replaced with a corresponding typed expression Exp :: T,
    T being the compile-time type of the expression.
\end{itemize}

    /smallskip
    During elaboration, elaborated members will be wrapped into elab().

    During elaboration an expression transition through 6 phases:
  1. Elaboration heating:
      elab('CastRef(_,, 'Minus('ExprName(x))))
      => elab('Minus('ExprName(x)) ~> elab('CastRef(_,, HOLE)
    Some AST terms, especially some statements require custom elaboration heating rules. If the heated expression
      should be always computed into a KResult, such as a type, package or certain literal expresssions, then
      it is heated in the "naked" form, e.g. not wrapped into elab().
  2. Elaboration of children. All the children of the expression are elaborated. After this phase elaborated children
    will be wrapped into ElabRes() (If They are expressions). The expression above would reach the state:
      elab('Minus(elabRes(localVar(X)::int))) ~> elab('CastRef(_,, HOLE)
  3. Initiation of the step elabDispose. When all children have been elaborated and are either KResult of elabRes(),
    the wrapper is changed from elab() to elabDispose().
      elabDispose('Minus(elabRes(localVar(X)::int))) ~> elab('CastRef(_,, HOLE)
  4. Unwrapping of children. During elabDispose step elaborated children are unwrapped from their elabRes() wrapper.
      elabDispose('Minus(localVar(X)::int)) ~> elab('CastRef(_,, HOLE)
  5. End of the step elabDispose. When all children of the term wrapped into elabDispose have been unwrapped
    from their elabRes() wrapper, the root wrapper is replaced from elabDispose to elabEnd. This helps
    to simplify the rules that follow.
    elabRes('Minus(localVar(X)::int)) ~> elab('CastRef(_,, HOLE)
  6. Computation of elaboration result. Now that all children have been elaborated and unwrapped, it is possible to
    compute the type of the current expression itself. When the expression is fully elaborated, it is wrapped into
    elabRes(). This is the step that requires custom rules for most AST terms.
      elabRes('Minus(localVar(X)::int)::int) ~> elab('CastRef(_,, HOLE)
  7. Elaboration cooling. Once the top K Item was wrapped into elabRes, it is ready to be cooled back into its original
    context:
      elab('CastRef(_,, elabRes('Minus(localVar(X)::int)::int))
*/
module ELABORATION-CORE
    imports CORE
    imports SUBTYPING
    imports ELABORATION-EXPRESSIONS      //for isExpressionLabel. todo remove dependence

/*@Custom hole used for custom heating/cooling rules in the elaboration phase.*/
syntax K ::= "CHOLE"

/*@ Elaborate the blocks inside all classes.
Argument K = setWrap(Set) - the set of all classes.
*/
syntax K ::= "elaborateBlocks" "(" K ")" [strict]

//@ Elaborates the methods of the current class. The map contains already elaborated methods. Initially the map is empty.
syntax K ::= "elabMethods" "(" Map ")"
syntax K ::= "elabInstanceInit"
           | "elabStaticInit"

//@Elaborates the given statement/expression. The first step of elaboration.
syntax K ::= "elab" "(" K ")"

//@ Wraps the elaboration result. Since elaboration may happen at both ElaborationPhase and ExecutionPhase, it cannot be KResult. Actually it is not KResult for HOLE, but is for CHOLE.
syntax ElabKResult ::= "elabRes" "(" K ")"

//@Sets the enclosing object for a given object.
//@Invoked by invokeConstr and QSuperConstrInv.
//@Defined in CLASSES
syntax K ::= "setEncloser" "(" TypedExp   //Evaluates to source object
                           "," ClassType  //Class layer in the source object for which to set the enclosing object.
                           "," K          //The enclosing object
                           ")"            [strict(1,3)]

/*@ Computes into an expression of the form elabRes('QThis(QualClass)::QualClass),
where QualClass is searched in the enclosing context of the first argument,
being a subclass of the second one.
Or elabRes(noValue) if no suitable result is found
*/
syntax K ::= "getElabResQThisSubclassOf" "(" ClassType //The context class in which qualifier is searched for.
                                         "," ClassType //Qualifier should be subclass of this class
                                         ")"            [strict(2)]

rule [getElabResQThisSubclassOf]:
    <k>
      getElabResQThisSubclassOf(QualClass:ClassType, ReqClass:ClassType)
      => 'If(
            subtype(QualClass, ReqClass),,
            elabRes('QThis(QualClass)::QualClass),,
            getElabResQThisSubclassOf(QualEncloserClass, ReqClass)
          )
      ...
    </k>
    <classType> QualClass </classType>
    <enclosingClass> QualEncloserClass:ClassType </enclosingClass>
when
    ReqClass =/=K noClass

rule [getElabResQThisSubclassOf-top-level]:
    getElabResQThisSubclassOf(_, noClass) => elabRes(noValue)

//@Happens for 'NewInstance expressions for static inner classes.
rule [getElabResQThisSubclassOf-static]:
    getElabResQThisSubclassOf(noClass, _) => elabRes(noValue)

/*@ Chain of responsibility pattern.
Evaluate the first argument. if it is KResult (except noValue) or elabRes(), the result of the ?? expression is
the result of the first argument. Otherwise, if the first argument evaluates to noValue, the result of the
?? expression is the result of the second argument.
*/
syntax K ::= K "??" K [right]

rule [chainOfResponsibilityHeat]:
    (. => Arg1) ~> (Arg1:K => CHOLE) ?? _
when
    notBool isElab(Arg1)

rule [chainOfResponsibilityResult1]:
    ElabRes:K ~> (CHOLE ?? _) => ElabRes
when isElab(ElabRes) andBool (ElabRes =/=K noValue)

rule [chainOfResponsibilityResult2]:
    noValue ~> (CHOLE ?? K:K) => K

/*@ Computes to true if the given argument is a list of elaboration results, false otherwise.
  An elaborated result is either:
    - KResult
    - TypedExp
    - elabRes(...)
*/
syntax K ::= "isElab" "(" KList ")"                 [function]
rule isElab(K:K,, Ks:KList)
     =>      ((getKLabel(K) ==KLabel 'elabRes`(_`)) orBool (isTypedExp(K) ==K true) orBool (isKResult(K) ==K true))
     andBool isElab(Ks)

rule isElab(.KList) => true

//@ Elaborate parameter type, if not elaborated yet. For catch clause.
context  elab('Param(_:K,, HOLE,, _:Id))

/*@Adds params to the <elabEnv>. Used in both ELABORATION-TOP-BLOCKS and ELABORATION-BLOCKS
*/
rule [elabParams]:
    <k> elab('Param(K1:K,, T:Type,, X:Id)) => paramImpl(T, X) ...</k>
    <elabEnv> ListItem(stEnv((. => X |-> T) _)) ...</elabEnv>

syntax KResult ::= paramImpl ( Type , Id )  //processed representation of a 'Param label

//@Removes the last layer from <elabEnv>
syntax K ::= "removeLastElabEnv"
rule [removeLastElabEnv]:
    <k> removeLastElabEnv => . ...</k>
    <elabEnv> ListItem(_) => . ...</elabEnv>
    <localTypes> ListItem(_) => . ...</localTypes>

/*@ \subsection{Elaboration of code blocks} */

//todo custom elab heating rule
/*@ Heating arguments for both expression and statement terms.
The attribute [transition-strictness] is used as transition attribute for testing strictness.
This is a rule that may lead to unexpected nondeterminism if it is wrongly implemented.
In order to expose incorrect nondeterminism we need to model-check a program that exposes the nondeterminism.
*/
rule [elabHeat-default]:
    (. => elab(K)) ~> elab(KL:KLabel(HeadKs:KList,, (K:K => CHOLE),, _:KList))
when
            defaultElabChildren(KL)
    andBool notBool isElab(K)
    andBool notBool isElabNaked(K)
    andBool isElab(HeadKs)    //Forces elaboration left-to-right. Required when KL == 'ListWrap of statements.
        [transition-strictness]

rule [elabCool-default]:
    (ElabK:K => .) ~> elab(_:KLabel(_,, (CHOLE => ElabK),, _))
when
    isElab(ElabK)

/* todo generalized context rule. Don't work yet as we cannot have KResult in the RHS of a syntax declaration.
*/
/* Disadvantage of generic elab heating:
  heated terms oare of 2 cathegories: defaultElabChildren and naked. for naked terms we should not heat
  their children anymore, but should unwrap their elab() wrapper. This is accomplished well enough for the moment.
*/
/*context elab(KL:KLabel(HeadKs:KList,, (HOLE:K => elab(HOLE)),, _:KList))
when
            defaultElabChildren(KL)
    andBool notBool isElabNaked(HOLE)
    andBool isElab(HeadKs)    //Forces elaboration left-to-right. Required when KL == 'ListWrap of statements.
        [result(ElabKResult), transition-strictness]

syntax ElabKResult ::= TypedExp

//hack suggested by Traian, an alternative to subsorting KResult to ElabKResult
rule isElabKResult(K:KResult) => true*/

/*@ Terms that should use custom elaboration rules. For those terms:
    - They will not be automatically heated from their parents into the elab() state.
    - They will not be automatically passed to elabDispose() state. Instead, those terms should have custom rules
      for elaboration start (heating) and elaboration end (cooling).
  Since all the automatic elaboration-related rules are an incredible mess, we have to put all the AST terms into this
    cathegory one by one, and eliminate automatic elaboration heating/cooling rules altogether.
*/
syntax K ::= "customElabChildren" "(" KLabel ")"                [function]
rule customElabChildren(KL:KLabel) =>
           (KL ==KLabel 'Block)
    orBool (KL ==KLabel 'For)
    orBool (KL ==KLabel 'Catch)
    orBool (KL ==KLabel 'LocalVarDecStm)
    orBool (KL ==KLabel 'LocalVarDec)
    orBool (KL ==KLabel 'SuperConstrInv)
    orBool (KL ==KLabel 'QSuperConstrInv)
    orBool (KL ==KLabel 'AltConstrInv)
    orBool (KL ==KLabel 'ClassDecStm)
    orBool (KL ==KLabel 'NewInstance)
    orBool (KL ==KLabel 'QNewInstance)

/*@ Java KLabels that are processed by default heating/cooling rules of elaboration.
All KLabels that can be part of a code block during elaboration phase,
except those members of customElabChildren or isElabNaked groups.

This predicate should be disjoint with customElabChildren (no longer used) and isElabNaked

todo: maybe statements should be processed by default rules as they are now, but expressions should not.
Let's start from expressions.
*/
syntax K ::= "defaultElabChildren" "(" KLabel ")"                [function]
rule defaultElabChildren(KL:KLabel) =>
           (KL ==KLabel 'ListWrap)
    orBool (KL ==KLabel 'Some)
    orBool (KL ==KLabel 'None)
    /*orBool (KL ==KLabel 'Single)
    orBool (KL ==KLabel 'NamedEscape)
    orBool (KL ==KLabel 'OctaEscape1)
    orBool (KL ==KLabel 'OctaEscape2)
    orBool (KL ==KLabel 'OctaEscape3)
    orBool (KL ==KLabel 'UnicodeEscape)
    orBool (KL ==KLabel 'String)
    orBool (KL ==KLabel 'Chars)*/

    orBool (KL ==KLabel 'Assign)
    orBool (KL ==KLabel 'AssignMul)
    orBool (KL ==KLabel 'AssignDiv)
    orBool (KL ==KLabel 'AssignRemain)
    orBool (KL ==KLabel 'AssignPlus)
    orBool (KL ==KLabel 'AssignMinus)
    orBool (KL ==KLabel 'AssignLeftShift)
    orBool (KL ==KLabel 'AssignRightShift)
    orBool (KL ==KLabel 'AssignURightShift)
    orBool (KL ==KLabel 'AssignAnd)
    orBool (KL ==KLabel 'AssignExcOr)
    orBool (KL ==KLabel 'AssignOr)
    orBool (KL ==KLabel 'InstanceOf)
    orBool (KL ==KLabel 'Mul)
    orBool (KL ==KLabel 'Div)
    orBool (KL ==KLabel 'Remain)
    orBool (KL ==KLabel 'Plus)
    orBool (KL ==KLabel 'Minus)
    orBool (KL ==KLabel 'LeftShift)
    orBool (KL ==KLabel 'RightShift)
    orBool (KL ==KLabel 'URightShift)
    orBool (KL ==KLabel 'Lt)
    orBool (KL ==KLabel 'Gt)
    orBool (KL ==KLabel 'LtEq)
    orBool (KL ==KLabel 'GtEq)
    orBool (KL ==KLabel 'Eq)
    orBool (KL ==KLabel 'NotEq)
    orBool (KL ==KLabel 'LazyAnd)
    orBool (KL ==KLabel 'LazyOr)
    orBool (KL ==KLabel 'And)
    orBool (KL ==KLabel 'ExcOr)
    orBool (KL ==KLabel 'Or)
    orBool (KL ==KLabel 'Cond)
    orBool (KL ==KLabel 'PreIncr)
    orBool (KL ==KLabel 'PreDecr)
    orBool (KL ==KLabel 'Complement)
    orBool (KL ==KLabel 'Not)
    orBool (KL ==KLabel 'CastPrim)
    orBool (KL ==KLabel 'CastRef)
    orBool (KL ==KLabel 'PostIncr)
    orBool (KL ==KLabel 'PostDecr)
    orBool (KL ==KLabel 'Invoke)
    orBool (KL ==KLabel 'Method)
    orBool (KL ==KLabel 'SuperMethod)
    orBool (KL ==KLabel 'QSuperMethod)
    orBool (KL ==KLabel 'GenericMethod)
    orBool (KL ==KLabel 'ArrayAccess)
    orBool (KL ==KLabel 'Field)
    orBool (KL ==KLabel 'SuperField)
    orBool (KL ==KLabel 'QSuperField)
    orBool (KL ==KLabel 'NewArray)
//    orBool (KL ==KLabel 'UnboundWld)
    orBool (KL ==KLabel 'Dim)

    /*orBool (KL ==KLabel 'NewInstance)
    orBool (KL ==KLabel 'QNewInstance)
    orBool (KL ==KLabel 'Lit)
    orBool (KL ==KLabel 'Class)
    orBool (KL ==KLabel 'VoidClass)*/
    orBool (KL ==KLabel 'This)
    orBool (KL ==KLabel 'QThis)
    /*orBool (KL ==KLabel 'PackageDec)
    orBool (KL ==KLabel 'TypeImportDec)
    orBool (KL ==KLabel 'TypeImportOnDemandDec) //ok
    orBool (KL ==KLabel 'StaticImportDec)
    orBool (KL ==KLabel 'StaticImportOnDemandDec)
    orBool (KL ==KLabel 'AnnoDec)
    orBool (KL ==KLabel 'AnnoDecHead)
    orBool (KL ==KLabel 'AnnoMethodDec)
    orBool (KL ==KLabel 'Semicolon)
    orBool (KL ==KLabel 'DefaultVal)
    orBool (KL ==KLabel 'AbstractMethodDec)
    orBool (KL ==KLabel 'DeprAbstractMethodDec)
    orBool (KL ==KLabel 'ConstantDec)
    orBool (KL ==KLabel 'InterfaceDec)
    orBool (KL ==KLabel 'InterfaceDecHead)
    orBool (KL ==KLabel 'ExtendsInterfaces)
    orBool (KL ==KLabel 'EnumDec)
    orBool (KL ==KLabel 'EnumDecHead)
    orBool (KL ==KLabel 'EnumBody)
    orBool (KL ==KLabel 'EnumConst)
    orBool (KL ==KLabel 'EnumBodyDecs)
    orBool (KL ==KLabel 'ConstrDec)
    orBool (KL ==KLabel 'ConstrDecHead)
    orBool (KL ==KLabel 'ConstrBody)
    orBool (KL ==KLabel 'AltConstrInv)
    orBool (KL ==KLabel 'SuperConstrInv)
    orBool (KL ==KLabel 'QSuperConstrInv)
    orBool (KL ==KLabel 'StaticInit)
    orBool (KL ==KLabel 'InstanceInit)*/
    orBool (KL ==KLabel 'Empty)
    orBool (KL ==KLabel 'Labeled)
    orBool (KL ==KLabel 'ExprStm)
    orBool (KL ==KLabel 'If)
    orBool (KL ==KLabel 'AssertStm)
    orBool (KL ==KLabel 'Switch)
    orBool (KL ==KLabel 'SwitchBlock)
    orBool (KL ==KLabel 'SwitchGroup)
    orBool (KL ==KLabel 'Case)
    orBool (KL ==KLabel 'Default) //default keyword from switch
    orBool (KL ==KLabel 'While)
    orBool (KL ==KLabel 'DoWhile)
//    orBool (KL ==KLabel 'For)
//    orBool (KL ==KLabel 'ForEach)
    orBool (KL ==KLabel 'Break)
    orBool (KL ==KLabel 'Continue)
    orBool (KL ==KLabel 'Return)
    orBool (KL ==KLabel 'Throw)
    orBool (KL ==KLabel 'Synchronized)
    orBool (KL ==KLabel 'Try)
    /*orBool (KL ==KLabel 'Catch)
    orBool (KL ==KLabel 'LocalVarDecStm)
    orBool (KL ==KLabel 'LocalVarDec)
    orBool (KL ==KLabel 'Block)
    orBool (KL ==KLabel 'ClassDecStm)*/
    /*orBool (KL ==KLabel 'MethodDec)
    orBool (KL ==KLabel 'MethodDecHead)
    orBool (KL ==KLabel 'DeprMethodDecHead)
    orBool (KL ==KLabel 'Void)
    orBool (KL ==KLabel 'Param)
    orBool (KL ==KLabel 'VarArityParam)
    orBool (KL ==KLabel 'ThrowsDec) */
    orBool (KL ==KLabel 'NoMethodBody)
    orBool (KL ==KLabel 'ArrayInit)
    /*orBool (KL ==KLabel 'Anno)
    orBool (KL ==KLabel 'SingleElemAnno)
    orBool (KL ==KLabel 'MarkerAnno)
    orBool (KL ==KLabel 'ElemValPair)
    orBool (KL ==KLabel 'ElemValArrayInit)
    orBool (KL ==KLabel 'FieldDec)*/
    orBool (KL ==KLabel 'VarDec)
    orBool (KL ==KLabel 'ArrayVarDecId)
    /*orBool (KL ==KLabel 'ClassDec)
    orBool (KL ==KLabel 'ClassBody)
    orBool (KL ==KLabel 'ClassDecHead)
    orBool (KL ==KLabel 'SuperDec)
    orBool (KL ==KLabel 'ImplementsDec)
    orBool (KL ==KLabel 'CompilationUnit)
    orBool (KL ==KLabel 'PackageName)*/

    orBool (KL ==KLabel 'AmbName)
//    orBool (KL ==KLabel 'TypeName)
    orBool (KL ==KLabel 'ExprName)

    orBool (KL ==KLabel 'MethodName)
    orBool auxLabelInElab(KL)
    /*orBool (KL ==KLabel 'PackageOrTypeName)
    orBool (KL ==KLabel 'TypeArgs)
    orBool (KL ==KLabel 'TypeArgs)
    orBool (KL ==KLabel 'Wildcard)
    orBool (KL ==KLabel 'WildcardUpperBound)
    orBool (KL ==KLabel 'TypeParam)
    orBool (KL ==KLabel 'TypeBound)
    orBool (KL ==KLabel 'TypeParams)
    orBool (KL ==KLabel 'ClassOrInterfaceType)
    orBool (KL ==KLabel 'ClassType)
    orBool (KL ==KLabel 'InterfaceType
    orBool (KL ==KLabel 'Member)
    orBool (KL ==KLabel 'TypeVar)
    orBool (KL ==KLabel 'ArrayType)
    orBool (KL ==KLabel 'Boolean)
    orBool (KL ==KLabel 'Byte)
    orBool (KL ==KLabel 'Short)
    orBool (KL ==KLabel 'Int)
    orBool (KL ==KLabel 'Long)
    orBool (KL ==KLabel 'Char)
    orBool (KL ==KLabel 'Float)
    orBool (KL ==KLabel 'Double)
    orBool (KL ==KLabel 'Null)
    orBool (KL ==KLabel 'Bool)
    orBool (KL ==KLabel 'True)
    orBool (KL ==KLabel 'False)
    orBool (KL ==KLabel 'Deci)
    orBool (KL ==KLabel 'Hexa)
    orBool (KL ==KLabel 'Octa)
    orBool (KL ==KLabel 'Public)
    orBool (KL ==KLabel 'Private)
    orBool (KL ==KLabel 'Protected)
    orBool (KL ==KLabel 'Abstract)
    orBool (KL ==KLabel 'Final)
    orBool (KL ==KLabel 'Static)
    orBool (KL ==KLabel 'Native)
    orBool (KL ==KLabel 'Transient)
    orBool (KL ==KLabel 'Volatile)
    orBool (KL ==KLabel 'StrictFP)
    orBool (KL ==KLabel 'Id)*/

syntax K ::= auxLabelInElab( KLabel ) [function]
rule auxLabelInElab(KL:KLabel) =>
           KL ==KLabel 'setEncloser`(_`,_`,_`)
    orBool KL ==KLabel 'stmtAndExp`(_`,_`)

/*@  elabHeat-naked-children
  Since a naked term is always computed int oa KResult during elaboration,
  we can use a simple context rule to heat such terms.
*/
context elab(KL:KLabel(_:KList,, HOLE,, _:KList))
when
            defaultElabChildren(KL)
    andBool isElabNaked(HOLE)

/*@ Naked terms are those that should be computed directly into KResult during elaboration.
  Those are literals, types and packages. They are heated "as is", without being wrapped into elab().
  An exception is the class literal that is not executed during elaboration.
*/
syntax K ::= "isElabNaked" "(" K ")"                            [function]
rule isElabNaked(K:K) =>
           //warning: cannot use ==Bool in the first expression - looks like isTypedExp(Qual) will not be computed
           (isRawVal(K) ==K true)
    orBool (getKLabel(K) ==KLabel 'TypeName)
    orBool (getKLabel(K) ==KLabel 'ClassOrInterfaceType)
    orBool (getKLabel(K) ==KLabel 'InterfaceType)
    orBool (getKLabel(K) ==KLabel 'ClassType)
    orBool (getKLabel(K) ==KLabel 'ArrayType)
    orBool (getKLabel(K) ==KLabel 'PackageName)
    orBool (getKLabel(K) ==KLabel 'PackageOrTypeName)
    orBool (getKLabel(K) ==KLabel 'Id)
    orBool (getKLabel(K) ==KLabel 'Lit andBool getInnerKLabel(K) =/=KLabel 'Class)

syntax KLabel ::= "getInnerKLabel" "(" K ")"                    [function]
rule getInnerKLabel(_:KLabel(KL:KLabel(_))) => KL

//todo elaboration-related hack - we should not have special elaboration rules for auxiliary constructs
syntax K ::= elabPassThrough( KLabel ) [function]
rule elabPassThrough(KL:KLabel) =>
           KL ==KLabel 'noValue
    orBool KL ==KLabel 'noClass
    orBool KL ==KLabel 'toString`(_`)

rule [elabPassThrough]:
    elab(KL:KLabel(Ks:KList)) => elabRes(KL(Ks))
when
    elabPassThrough(KL)

/*@ The default algorithm of transforming the term from elab to elabRes, when the children were completely elaborated.
  Deletes elabRes wrappers from children. This algorithm is activated when the following conditions apply:
    - term is not customElabChildren
    - term children are completely elaborated - isElab(children)
    - term is not naked. This case should never be true, but there is some weird case that requires it.
  When the default algorithm is not appropriate, the respective term should be in the cathegory customElabChildren
*/
syntax K ::= "elabDispose" "(" K ")"

/*@ This rule is universal for all forms of terms, both instructions and statements.
*/
rule [elabDisposeStart]:
    elab(KL:KLabel(ElabResL:KList)) => elabDispose(KL(ElabResL))
when
    isElab(ElabResL)

rule [elabDisposeProcess]:
    elabDispose(KL:KLabel(_,, (elabRes(K:K) => K),, _))

rule [elabDisposeEnd]:
    elabDispose(KL:KLabel(Ks:KList)) => elabEnd(KL(Ks))
when
    haveNoElabRes(Ks)

//@ True if given KList have no terms of the form elabRes(...), false otherwise.
syntax K ::= "haveNoElabRes" "(" KList ")"          [function]
rule haveNoElabRes(K:K,, Ks:KList)
     => (getKLabel(K) =/=KLabel 'elabRes`(_`)) andBool haveNoElabRes(Ks)

rule haveNoElabRes(.KList) => true

/*@ The 3rd elaboration-phase wrapper for expressions. Represents the case when children are completely elaborated and
unwrapped from elabRes(), but root node might not be elaborated yet. The implementation is scattered across all modules
that deal with the elaboration phase.
*/
syntax K ::= elabEnd ( K )

//@ \subsection{Hacks related to elaboration during execution phase}

//@ Unwrap elaborated terms in execution phase, so that they could be executed.
rule [elabRes-ExecutionPhase-discard1]:
    <k> (elabRes(K:K) => K) ~> KL:KLabel(_) ...</k>
    <globalPhase> ExecutionPhase </globalPhase>
when
    KL =/=KLabel 'elab`(_`)

rule [elabRes-ExecutionPhase-discard2]:
    <k> elabRes(K:K) => K </k>
    <globalPhase> ExecutionPhase </globalPhase>

//Required for [VarDecWithArrayInitDesugar], [FieldDecWithArrayInitDesugar]
rule elab(elab(K:K)) => elab(K)

endmodule
