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
  \item each expression Exp will be replaced with a corresponding typed expression cast(T, Exp),
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
    will be typed (if they are expressions) and wrapped into elabRes(). Typed expressions are cast expressions -
    like cast(T, Exp). The whole initial term will be converted into:
      elab('Minus(elabRes(cast(int, localVar(X))))) ~> elab('CastRef(_,, HOLE)
  3. Initiation of the step elabDispose. When all children have been elaborated and are either KResult of elabRes(),
    the wrapper is changed from elab() to elabDispose().
      elabDispose('Minus(elabRes(cast(int, localVar(X))))) ~> elab('CastRef(_,, HOLE)
  4. Unwrapping of children. During elabDispose step elaborated children are unwrapped from their elabRes() wrapper.
      elabDispose('Minus(cast(int, localVar(X)))) ~> elab('CastRef(_,, HOLE)
  5. End of the step elabDispose. When all children of the term wrapped into elabDispose have been unwrapped
    from their elabRes() wrapper, the root wrapper is replaced from elabDispose to elabEnd. This contributes
    to more simple rules for the following steps.
    elabRes('Minus(cast(int, localVar(X)))) ~> elab('CastRef(_,, HOLE)
  6. Computation of elaboration result. Now that all children have been elaborated and unwrapped, it is possible to
    compute the type of the current expression itself. When the expression is fully elaborated, it is wrapped into
    elabRes(). This is the step that requires custom rules for most AST terms.
      elabRes('Minus(cast(int,cast(int, localVar(X))))) ~> elab('CastRef(_,, HOLE)
  7. Elaboration cooling. Once the top K Item was wrapped into elabRes, it is ready to be cooled back into its original
    context:
      elab('CastRef(_,, elabRes('Minus(cast(int,cast(int, localVar(X)))))))
*/
module ELABORATION-CORE
    imports CORE
    imports SUBTYPING
    imports EXPRESSIONS   //for cast()

/*@Custom hole used for custom heating/cooling rules in the elaboration phase.*/
syntax K ::= "CHOLE"

/*@ Elaborate the blocks inside all classes.
Argument K = setWrap(Set) - the set of all classes.
*/
syntax K ::= elaborateBlocks ( K ) [strict]

//@ Elaborates the methods of the current class. The map contains already elaborated methods. Initially the map is empty.
syntax K ::= elabMethods ( Map )
syntax K ::= "elabInstanceInit"
           | "elabStaticInit"

//@Elaborates the given statement/expression. The first step of elaboration.
syntax K ::= elab ( K )

//@ Wraps the elaboration result. Since elaboration may happen at both ElaborationPhase and ExecutionPhase, it cannot be KResult. Actually it is not KResult for HOLE, but is for CHOLE.
syntax ElabKResult ::= elabRes ( K )

/*@ \subsection{Operator ??}*/

/*@ Chain of responsibility pattern.
Evaluate the first argument. if it is KResult (except noValue) or elabRes(), the result of the ?? expression is
the result of the first argument. Otherwise, if the first argument evaluates to noValue, the result of the
?? expression is the result of the second argument.
*/
syntax K ::= K "??" K [right]

rule [chainOfResponsibility-Heat]:
    (. => Arg1) ~> (Arg1:K => CHOLE) ?? _
when
    notBool isElab(Arg1)

rule [chainOfResponsibility-Result1]:
    ElabRes:K ~> (CHOLE ?? _) => ElabRes
when isElab(ElabRes) andBool (ElabRes =/=K noValue)

rule [chainOfResponsibility-Result2]:
    noValue ~> (CHOLE ?? K:K) => K

/*@ Computes to true if the given argument is a list of elaboration results, false otherwise.
  An elaborated result is either:
    - KResult
    - elabRes(...)

  It is notably NOT a cast() expression. This, together with the fact that cast() have no elaboration heatig rules,
  makes the whole elaboration phase non-reentrant.
*/
syntax K ::= isElab ( KList )                 [function]
rule isElab(K:K,, Ks:KList)
     =>      ((getKLabel(K) ==KLabel 'elabRes) orBool (isKResult(K) ==K true))
     andBool isElab(Ks)

rule isElab(.KList) => true

//@ Elaborate parameter type, if not elaborated yet. For catch clause.
context  elab('Param(_:K,, HOLE,, _:Id))

/*@Adds params to the <elabEnv>. Used in both ELABORATION-TOP-BLOCKS and ELABORATION-BLOCKS
*/
rule [elab-Param]:
    <k> elab('Param(K1:K,, T:Type,, X:Id)) => paramImpl(T, X) ...</k>
    <elabEnv> ListItem(mapWrap((. => X |-> T) _)) ...</elabEnv>

syntax KResult ::= paramImpl ( Type, Id )  //processed representation of a 'Param label

//@Removes the last layer from <elabEnv>
syntax K ::= "removeLastElabEnv"
rule [removeLastElabEnv]:
    <k> removeLastElabEnv => . ...</k>
    <elabEnv> ListItem(_) => . ...</elabEnv>
    <localTypes> ListItem(_) => . ...</localTypes>

/*@ \subsection{Elaboration of code blocks} */

/*@ Heating arguments for both expression and statement terms.
The attribute [transition-strictness] is used as transition attribute for testing strictness.
This is a rule that may lead to unexpected nondeterminism if it is wrongly implemented.
In order to expose incorrect nondeterminism we need to model-check a program that exposes the nondeterminism.
*/
rule [elab-heat-default]:
    (. => elab(K)) ~> elab(KL:KLabel(HeadKs:KList,, (K:K => CHOLE),, _:KList))
when
    (defaultElabHeating(KL) orBool customElabHeating(KL, (HeadKs,,K)) ==K true)
    andBool notBool isElab(K)
    andBool notBool isElabNaked(K)
        [transition-strictness]

rule [elab-cool-default]:
    (ElabK:K => .) ~> elab(_:KLabel(_,, (CHOLE => ElabK),, _))
when
    isElab(ElabK)

/*@ Java KLabels that are processed by default heating/cooling rules of elaboration.
All KLabels that can be part of a code block during elaboration phase,
except those members of customElabChildren or isElabNaked groups.

This predicate should be disjoint with customElabChildren (no longer used) and isElabNaked
*/
syntax K ::= defaultElabHeating ( KLabel )                [function]
rule defaultElabHeating(KL:KLabel) =>
           /*(KL ==KLabel 'ListWrap)*/
           (KL ==KLabel 'Some)
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
           KL ==KLabel 'setEncloser
    orBool KL ==KLabel 'stmtAndExp

/*@  elabHeat-naked-children
  Since a naked term is always computed int oa KResult during elaboration,
  we can use a simple context rule to heat such terms.
*/
context elab(KL:KLabel(HeadKs:KList,, HOLE,, _:KList))
when
            (defaultElabHeating(KL) orBool customElabHeating(KL, (HeadKs,,HOLE)) ==K true)
    andBool isElabNaked(HOLE)

/*@ Naked terms are those that should be computed directly into KResult during elaboration.
  Those are literals, types and packages. They are heated "as is", without being wrapped into elab().
  An exception is the class literal that is not executed during elaboration.
*/
syntax K ::= isElabNaked ( K )                            [function]
rule isElabNaked(K:K) =>
           //warning: cannot use ==Bool in the first expression - looks like isRawVal(K) will not be computed
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
    orBool isAuxFuncElabNaked(getKLabel(K))

syntax KLabel ::= getInnerKLabel ( K )                            [function]
rule getInnerKLabel(_:KLabel(KL:KLabel(_))) => KL

syntax K ::= isAuxFuncElabNaked( KLabel )                         [function]
rule isAuxFuncElabNaked(KL:KLabel) => false

/*@ Terms that should use custom elaboration rules. For those terms:
    - They will not be automatically heated from their parents into the elab() state.
    - They will not be automatically passed to elabDispose() state. Instead, those terms should have custom rules
      for elaboration start (heating) and elaboration end (cooling).
  Since all the automatic elaboration-related rules are an incredible mess, we have to put all the AST terms into this
    cathegory one by one, and eliminate automatic elaboration heating/cooling rules altogether.
*/
syntax K ::= customElabChildren ( KLabel )                [function]
rule customElabChildren(KL:KLabel) =>
           (KL ==KLabel 'ListWrap)
    orBool (KL ==KLabel 'Block)
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

/*@ Must be true for AST nodes that require elaboration heating of their children. For the arguments KL, Ks,
the original node is of he form KL(KS,,_) and the heated child is always the last element of Ks.
Thus it is possible to decide whether the child is allowed to be heated based both on the position of the child
in the list of arguments as well as based on the state of previous brothers.

  This predicate is intended to be used for KLabels that require specific child heating rules based on the state
of their children. The KLabels that heat all their children using default rules are enumerated in the predicate
defaultElabHeating.

The predicate definition is scattered across modules related to elaboration.*/
syntax K ::= customElabHeating ( KLabel, KList )          [function]

//todo elaboration-related hack - we should not have special elaboration rules for auxiliary constructs
syntax K ::= elabPassThrough( KLabel )                    [function]
rule elabPassThrough(KL:KLabel) =>
           KL ==KLabel 'noValue
    orBool KL ==KLabel 'noClass
    orBool KL ==KLabel 'toString

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
syntax K ::= elabDispose ( K )

/*@ This rule is universal for all forms of terms, both instructions and statements.
*/
rule [elab-to-elabDispose]:
    elab(KL:KLabel(ElabResL:KList)) => elabDispose(KL(ElabResL))
when
    isElab(ElabResL)

rule [elabDispose-process]:
    elabDispose(KL:KLabel(_,, (elabRes(K:K) => K),, _))

rule [elabDispose-to-elabEnd]:
    elabDispose(KL:KLabel(Ks:KList)) => elabEnd(KL(Ks))
when
    haveNoElabRes(Ks)

//@ True if given KList have no terms of the form elabRes(...), false otherwise.
syntax K ::= haveNoElabRes ( KList )          [function]
rule haveNoElabRes(K:K,, Ks:KList)
     => (getKLabel(K) =/=KLabel 'elabRes) andBool haveNoElabRes(Ks)

rule haveNoElabRes(.KList) => true

/*@ The 3rd elaboration-phase wrapper for expressions. Represents the case when children are completely elaborated and
unwrapped from elabRes(), but root node might not be elaborated yet. The implementation is scattered across all modules
that deal with the elaboration phase.
*/
syntax K ::= elabEnd ( K )

//@ \subsection{Auxiliary functions for execution phase}

/*@ Computes into an expression of the form elabRes(cast(QualClass, 'QThis(QualClass))),
where QualClass is searched in the enclosing context of the first argument,
being a subclass of the second one.
Or elabRes(noValue) if no suitable result is found
*/
syntax K ::=  getQThisSubclassOf (
                ClassType,  //The context class in which qualifier is searched for.
                ClassType   //Qualifier should be subclass of this class
              )

context elab(getQThisSubclassOf(_, HOLE))

rule [elabEnd-getQThisSubclassOf]:
    <k>
      elabEnd(getQThisSubclassOf(QualClass:ClassType, ReqClass:ClassType))
      => 'If(
            subtype(QualClass, ReqClass),,
            elabRes(cast(QualClass,'QThis(QualClass))),,
            elabEnd(getQThisSubclassOf(QualEncloserClass, ReqClass))
          )
      ...
    </k>
    <classType> QualClass </classType>
    <enclosingClass> QualEncloserClass:ClassType </enclosingClass>
when
    ReqClass =/=K noClass

rule [elabEnd-getQThisSubclassOf-top-level]:
    elabEnd(getQThisSubclassOf(K:K, noClass)) => elabRes(noValue)

//@Happens for 'NewInstance expressions for static inner classes.
rule [elabEnd-getQThisSubclassOf-static]:
    elabEnd(getQThisSubclassOf(noClass, K:K)) => elabRes(noValue)

//@ \subsection{Hacks related to elaboration during execution phase}

//@ Unwrap elaborated terms in execution phase, so that they could be executed.
rule [elabRes-ExecutionPhase-discard1]:
    <k> (elabRes(K:K) => K) ~> KL:KLabel(_) ...</k>
    <globalPhase> ExecutionPhase </globalPhase>
when
    KL =/=KLabel 'elab

rule [elabRes-ExecutionPhase-discard2]:
    <k> elabRes(K:K) => K </k>
    <globalPhase> ExecutionPhase </globalPhase>

//Required for [VarDecWithArrayInitDesugar], [FieldDecWithArrayInitDesugar]
rule elab(elab(K:K)) => elab(K)

endmodule
