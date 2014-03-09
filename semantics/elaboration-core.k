require "core-sorts.k"
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
    imports CORE-SORTS
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
rule isElabKResult(KR:KResult) => true

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
    notBool isElabKResult(Arg1) ==K true

rule [chainOfResponsibility-Result1]:
    ElabRes:ElabKResult ~> (CHOLE ?? _) => ElabRes
when ElabRes =/=K noValue

rule [chainOfResponsibility-Result2]:
    noValue ~> (CHOLE ?? K:K) => K

/*@ Computes to true if the given argument is a list of elaboration results, false otherwise.
  An elaborated result is either:
    - KResult
    - elabRes(...)

  It is notably NOT a cast() expression. This, together with the fact that cast() have no elaboration heatig rules,
  makes the whole elaboration phase non-reentrant.
*/
syntax K ::= isElabKList ( KList )                 [function]
rule isElabKList(ElabKR:ElabKResult,, Ks:KList) => isElabKList(Ks)
rule isElabKList(.KList) => true

//@ Elaborate parameter type, if not elaborated yet. For catch clause.
context  elab('Param(_:K,, HOLE,, _:Id))

/*@Adds params to the <elabEnv>. Used in both ELABORATION-TOP-BLOCKS and ELABORATION-BLOCKS
*/
rule [elab-Param]:
    <k> elab('Param(K1:K,, T:Type,, X:Id)) => elabRes('Param(K1:K,, T:Type,, X:Id)) ...</k>
    <elabEnv> ListItem(mapWrap((. => X |-> T) _)) ...</elabEnv>

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

Labels that are "naked" should be heated in their pure form. Other terms should be heated wrapped into elab().
*/
rule [elab-heat-default]:
    (. => #if isElabNaked(K) ==K true
            #then K
            #else elab(K)
          #fi
    )
    ~> elab(KL:KLabel(HeadKs:KList,, (K:K => CHOLE),, _:KList))
when
    (defaultElabHeating(KL) ==K true orBool customElabHeating(KL, (HeadKs,,K)) ==K true)
    andBool notBool isElabKResult(K) ==K true
        [transition-strictness]

rule [elab-cool-default]:
    (ElabK:ElabKResult => .) ~> elab(_:KLabel(_,, (CHOLE => ElabK),, _))

/*@ Java KLabels that are processed by default heating/cooling rules of elaboration.
All KLabels that can be part of a code block during elaboration phase,
except those members of customElabChildren or isElabNaked groups.

This predicate should be disjoint with customElabChildren (no longer used) and isElabNaked
*/
syntax K ::= defaultElabHeating ( KLabel )                [function]

           /*(KL ==KLabel 'ListWrap)*/
rule defaultElabHeating('Some) => true
rule defaultElabHeating('None) => true
    /*orBool (KL ==KLabel 'Single)
rule defaultElabHeating('NamedEscape) => true
rule defaultElabHeating('OctaEscape1) => true
rule defaultElabHeating('OctaEscape2) => true
rule defaultElabHeating('OctaEscape3) => true
rule defaultElabHeating('UnicodeEscape) => true
rule defaultElabHeating('String) => true
rule defaultElabHeating('Chars) => true*/

rule defaultElabHeating('Assign) => true
rule defaultElabHeating('AssignMul) => true
rule defaultElabHeating('AssignDiv) => true
rule defaultElabHeating('AssignRemain) => true
rule defaultElabHeating('AssignPlus) => true
rule defaultElabHeating('AssignMinus) => true
rule defaultElabHeating('AssignLeftShift) => true
rule defaultElabHeating('AssignRightShift) => true
rule defaultElabHeating('AssignURightShift) => true
rule defaultElabHeating('AssignAnd) => true
rule defaultElabHeating('AssignExcOr) => true
rule defaultElabHeating('AssignOr) => true
rule defaultElabHeating('InstanceOf) => true
rule defaultElabHeating('Mul) => true
rule defaultElabHeating('Div) => true
rule defaultElabHeating('Remain) => true
rule defaultElabHeating('Plus) => true
rule defaultElabHeating('Minus) => true
rule defaultElabHeating('LeftShift) => true
rule defaultElabHeating('RightShift) => true
rule defaultElabHeating('URightShift) => true
rule defaultElabHeating('Lt) => true
rule defaultElabHeating('Gt) => true
rule defaultElabHeating('LtEq) => true
rule defaultElabHeating('GtEq) => true
rule defaultElabHeating('Eq) => true
rule defaultElabHeating('NotEq) => true
rule defaultElabHeating('LazyAnd) => true
rule defaultElabHeating('LazyOr) => true
rule defaultElabHeating('And) => true
rule defaultElabHeating('ExcOr) => true
rule defaultElabHeating('Or) => true
rule defaultElabHeating('Cond) => true
rule defaultElabHeating('PreIncr) => true
rule defaultElabHeating('PreDecr) => true
rule defaultElabHeating('Complement) => true
rule defaultElabHeating('Not) => true
rule defaultElabHeating('CastPrim) => true
rule defaultElabHeating('CastRef) => true
rule defaultElabHeating('PostIncr) => true
rule defaultElabHeating('PostDecr) => true
rule defaultElabHeating('Invoke) => true
rule defaultElabHeating('Method) => true
rule defaultElabHeating('SuperMethod) => true
rule defaultElabHeating('QSuperMethod) => true
rule defaultElabHeating('GenericMethod) => true
rule defaultElabHeating('ArrayAccess) => true
rule defaultElabHeating('Field) => true
rule defaultElabHeating('SuperField) => true
rule defaultElabHeating('QSuperField) => true
rule defaultElabHeating('NewArray) => true
//rule defaultElabHeating('UnboundWld) => true
rule defaultElabHeating('Dim) => true

    /*orBool (KL ==KLabel 'NewInstance)
rule defaultElabHeating('QNewInstance) => true
rule defaultElabHeating('Lit) => true
rule defaultElabHeating('Class) => true
rule defaultElabHeating('VoidClass) => true*/
rule defaultElabHeating('This) => true
rule defaultElabHeating('QThis) => true
    /*orBool (KL ==KLabel 'PackageDec)
rule defaultElabHeating('TypeImportDec) => true
rule defaultElabHeating('TypeImportOnDemandDec) => true //ok
rule defaultElabHeating('StaticImportDec) => true
rule defaultElabHeating('StaticImportOnDemandDec) => true
rule defaultElabHeating('AnnoDec) => true
rule defaultElabHeating('AnnoDecHead) => true
rule defaultElabHeating('AnnoMethodDec) => true
rule defaultElabHeating('Semicolon) => true
rule defaultElabHeating('DefaultVal) => true
rule defaultElabHeating('AbstractMethodDec) => true
rule defaultElabHeating('DeprAbstractMethodDec) => true
rule defaultElabHeating('ConstantDec) => true
rule defaultElabHeating('InterfaceDec) => true
rule defaultElabHeating('InterfaceDecHead) => true
rule defaultElabHeating('ExtendsInterfaces) => true
rule defaultElabHeating('EnumDec) => true
rule defaultElabHeating('EnumDecHead) => true
rule defaultElabHeating('EnumBody) => true
rule defaultElabHeating('EnumConst) => true
rule defaultElabHeating('EnumBodyDecs) => true
rule defaultElabHeating('ConstrDec) => true
rule defaultElabHeating('ConstrDecHead) => true
rule defaultElabHeating('ConstrBody) => true*/
rule defaultElabHeating('AltConstrInv) => true
    /*orBool (KL ==KLabel 'SuperConstrInv)*/
rule defaultElabHeating('QSuperConstrInv) => true
    /*orBool (KL ==KLabel 'StaticInit)
rule defaultElabHeating('InstanceInit) => true*/
rule defaultElabHeating('Empty) => true
rule defaultElabHeating('Labeled) => true
rule defaultElabHeating('ExprStm) => true
rule defaultElabHeating('If) => true
rule defaultElabHeating('AssertStm) => true
rule defaultElabHeating('Switch) => true
rule defaultElabHeating('SwitchBlock) => true
rule defaultElabHeating('SwitchGroup) => true
rule defaultElabHeating('Case) => true
rule defaultElabHeating('Default) => true //default keyword from switch
rule defaultElabHeating('While) => true
rule defaultElabHeating('DoWhile) => true
//rule defaultElabHeating('For) => true
//rule defaultElabHeating('ForEach) => true
rule defaultElabHeating('Break) => true
rule defaultElabHeating('Continue) => true
rule defaultElabHeating('Return) => true
rule defaultElabHeating('Throw) => true
rule defaultElabHeating('Synchronized) => true
rule defaultElabHeating('Try) => true
    /*orBool (KL ==KLabel 'Catch)
rule defaultElabHeating('LocalVarDecStm) => true
rule defaultElabHeating('LocalVarDec) => true
rule defaultElabHeating('Block) => true
rule defaultElabHeating('ClassDecStm) => true
    orBool (KL ==KLabel 'MethodDec)
rule defaultElabHeating('MethodDecHead) => true
rule defaultElabHeating('DeprMethodDecHead) => true
rule defaultElabHeating('Void) => true
rule defaultElabHeating('Param) => true
rule defaultElabHeating('VarArityParam) => true
rule defaultElabHeating('ThrowsDec) => true */
rule defaultElabHeating('NoMethodBody) => true
rule defaultElabHeating('ArrayInit) => true
    /*orBool (KL ==KLabel 'Anno)
rule defaultElabHeating('SingleElemAnno) => true
rule defaultElabHeating('MarkerAnno) => true
rule defaultElabHeating('ElemValPair) => true
rule defaultElabHeating('ElemValArrayInit) => true
rule defaultElabHeating('FieldDec) => true*/
rule defaultElabHeating('VarDec) => true
rule defaultElabHeating('ArrayVarDecId) => true
    /*orBool (KL ==KLabel 'ClassDec)
rule defaultElabHeating('ClassBody) => true
rule defaultElabHeating('ClassDecHead) => true
rule defaultElabHeating('SuperDec) => true
rule defaultElabHeating('ImplementsDec) => true
rule defaultElabHeating('CompilationUnit) => true
rule defaultElabHeating('PackageName) => true*/

rule defaultElabHeating('AmbName) => true
//rule defaultElabHeating('TypeName) => true
rule defaultElabHeating('ExprName) => true

rule defaultElabHeating('MethodName) => true
    /*orBool (KL ==KLabel 'PackageOrTypeName)
rule defaultElabHeating('TypeArgs) => true
rule defaultElabHeating('TypeArgs) => true
rule defaultElabHeating('Wildcard) => true
rule defaultElabHeating('WildcardUpperBound) => true
rule defaultElabHeating('TypeParam) => true
rule defaultElabHeating('TypeBound) => true
rule defaultElabHeating('TypeParams) => true
rule defaultElabHeating('ClassOrInterfaceType) => true
rule defaultElabHeating('ClassType) => true
    orBool (KL ==KLabel 'InterfaceType
rule defaultElabHeating('Member) => true
rule defaultElabHeating('TypeVar) => true
rule defaultElabHeating('ArrayType) => true
rule defaultElabHeating('Boolean) => true
rule defaultElabHeating('Byte) => true
rule defaultElabHeating('Short) => true
rule defaultElabHeating('Int) => true
rule defaultElabHeating('Long) => true
rule defaultElabHeating('Char) => true
rule defaultElabHeating('Float) => true
rule defaultElabHeating('Double) => true
rule defaultElabHeating('Null) => true
rule defaultElabHeating('Bool) => true
rule defaultElabHeating('True) => true
rule defaultElabHeating('False) => true
rule defaultElabHeating('Deci) => true
rule defaultElabHeating('Hexa) => true
rule defaultElabHeating('Octa) => true
rule defaultElabHeating('Public) => true
rule defaultElabHeating('Private) => true
rule defaultElabHeating('Protected) => true
rule defaultElabHeating('Abstract) => true
rule defaultElabHeating('Final) => true
rule defaultElabHeating('Static) => true
rule defaultElabHeating('Native) => true
rule defaultElabHeating('Transient) => true
rule defaultElabHeating('Volatile) => true
rule defaultElabHeating('StrictFP) => true
rule defaultElabHeating('Id) => true*/

//Auxiliary functions that should be default-heated
rule defaultElabHeating('setEncloser) => true
rule defaultElabHeating('stmtAndExp) => true

/*@ Naked terms are those that should be computed directly into KResult during elaboration.
  Those are literals, types and packages. They are heated "as is", without being wrapped into elab().
  An exception is the class literal that is not executed during elaboration.
*/
syntax K ::= isElabNaked ( K )                            [function]
rule isElabNaked(RV:RawVal) => true
rule isElabNaked('TypeName(_)) => true
rule isElabNaked('ClassOrInterfaceType(_)) => true
rule isElabNaked('InterfaceType(_)) => true
rule isElabNaked('ClassType(_)) => true
rule isElabNaked('ArrayType(_)) => true
rule isElabNaked('PackageName(_)) => true
rule isElabNaked('PackageOrTypeName(_)) => true
rule isElabNaked('Id(_)) => true
rule isElabNaked('Lit(InnerKL:KLabel(_))) => InnerKL =/=KLabel 'Class

rule isElabNaked(KL:KLabel(_)) => true
when
    isAuxFuncElabNaked(KL) ==K true

/*@ Implementation is scattered.*/
syntax K ::= isAuxFuncElabNaked( KLabel )                         [function]

/*@ Terms that should use custom elaboration rules. For those terms:
    - They will not be automatically heated from their parents into the elab() state.
    - They will not be automatically passed to elabDispose() state. Instead, those terms should have custom rules
      for elaboration start (heating) and elaboration end (cooling).
  Since all the automatic elaboration-related rules are an incredible mess, we have to put all the AST terms into this
    cathegory one by one, and eliminate automatic elaboration heating/cooling rules altogether.
*/
syntax K ::= customElabChildren ( KLabel )                [function]
rule customElabChildren(KL:KLabel) =>
           (KL ==KLabel 'ListWrap)        //Elaboration left-to-right if children contain variable declarations
    orBool (KL ==KLabel 'Block)           //Allocation of new <elabEnv>
    orBool (KL ==KLabel 'For)             //Allocation of new <elabEnv>
    orBool (KL ==KLabel 'Catch)           //Allocation of new <elabEnv>
    orBool (KL ==KLabel 'LocalVarDecStm)  //Desugaring into 'Assign and simple 'LocalVarDec
    orBool (KL ==KLabel 'LocalVarDec)     //Desugaring into 'Assign and simple 'LocalVarDec
    orBool (KL ==KLabel 'SuperConstrInv)  //Elaboration of qualifier, only at elab() step
    orBool (KL ==KLabel 'ClassDecStm)     //Elaboration of inner 'ClassDec
    orBool (KL ==KLabel 'NewInstance)     //Elaboration of qualifier, only at elab() step, anonymous body.
    orBool (KL ==KLabel 'QNewInstance)    //Elaboration of name into class, anonymous body.

/*@ Must be true for AST nodes that require elaboration heating of their children. For the arguments KL, Ks,
the original node is of he form KL(KS,,_) and the heated child is always the last element of Ks.
Thus it is possible to decide whether the child is allowed to be heated based both on the position of the child
in the list of arguments as well as based on the state of previous brothers.

  This predicate is intended to be used for KLabels that require specific child heating rules based on the state
of their children. The KLabels that heat all their children using default rules are enumerated in the predicate
defaultElabHeating.

The predicate definition is scattered across modules related to elaboration.*/
syntax K ::= customElabHeating ( KLabel, KList )          [function]

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
    isElabKList(ElabResL) ==K true

rule [elabDispose-process]:
    elabDispose(KL:KLabel(_,, (elabRes(K:K) => K),, _))

rule [elabDispose-to-elabEnd]:
    elabDispose(KL:KLabel(Ks:KList)) => elabEnd(KL(Ks))
when
    notBool haveElabRes(Ks) ==K true

//@ True if given KList have no terms of the form elabRes(...), false otherwise.
syntax K ::= haveElabRes ( KList )          [function]
rule haveElabRes(_,, elabRes(_),,_) => true

/*@ The 3rd elaboration-phase wrapper for expressions. Represents the case when children are completely elaborated and
unwrapped from elabRes(), but root node might not be elaborated yet. The implementation is scattered across all modules
that deal with the elaboration phase.
*/
syntax K ::= elabEnd ( K )

//@ \subsection{Auxiliary functions for execution phase}

/*@ Computes into an expression of the form elabRes(cast(QualClass, 'QThis(QualClass))),
where QualClass is searched in the enclosing context of the first argument,
being a subclass of the second one.
Or noValue if no suitable result is found
*/
syntax K ::=  findQualifierOfType (
                ClassType,  //The context class in which qualifier is searched for.
                ClassType   //Qualifier should be subclass of this class
              )
              [strict(2)]

rule isAuxFuncElabNaked('findQualifierOfType) => true

rule [elabEnd-findQualifierOfType]:
    <k>
      findQualifierOfType(QualClass:ClassType, ReqClass:ClassType)
      => ifAux(
            subtype(QualClass, ReqClass),
            elabRes(cast(QualClass,'QThis(QualClass))),
            findQualifierOfType(QualEncloserClass, ReqClass)
          )
      ...
    </k>
    <classType> QualClass </classType>
    <enclosingClass> QualEncloserClass:ClassType </enclosingClass>
when
    ReqClass =/=K noClass

rule [elabEnd-findQualifierOfType-top-level]:
    findQualifierOfType(K:K, noClass) => noValue

//@Happens for 'NewInstance expressions for static inner classes.
rule [elabEnd-findQualifierOfType-static]:
    findQualifierOfType(noClass, K:K) => noValue

/*@ \subsection{Elaboration of statements - step elabEnd} */

/*@ Applies to all nodes that are not expressins - statements and non-expression auxiliary functions
*/
rule [elabEnd-default-all-except-expressions]:
    elabEnd(KL:KLabel(Ks:KList)) => elabRes(KL(Ks))
when
    notBool (isExpressionLabel(KL) ==K true orBool customElabEnd(KL) ==K true)

//@ The implementation is scattered across elaboration-related modules
syntax K ::= customElabEnd ( KLabel )                       [function]

/*@ Wrapper of a statement followed by an expression, to be used in a place where an expression is expected,
such as an anonymous class declaration. Is typed with the type of the expression.
At runtime is rewritten into the statement, that should evaluate into .K, followed by the expression,
that should evaluate to value.*/
syntax K ::= stmtAndExp ( K, K )

//elaboration time
rule elabEnd(           stmtAndExp(Stmt:K, cast(T:Type, Exp:K)) )
     => elabRes(cast(T, stmtAndExp(Stmt,   cast(T:Type, Exp:K))))

//runtime
rule stmtAndExp(Stmt:K, Exp:K) => Stmt ~> Exp

//@ \subsection{Hacks related to elaboration during execution phase}

//todo investigate if needed
//Required for [VarDecWithArrayInitDesugar], [FieldDecWithArrayInitDesugar]
rule elab(elab(K:K)) => elab(K)

endmodule
