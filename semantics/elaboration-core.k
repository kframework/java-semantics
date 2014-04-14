require "core-sorts.k"
require "subtyping.k"
require "elaboration-categories.k"
require "process-class-members.k"

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
    imports ELABORATION-CATEGORIES
    imports EXPRESSIONS   //for cast()

/*@Custom hole used for custom heating/cooling rules in the elaboration phase.*/
syntax K ::= "CHOLE"

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
syntax K ::= isElabKList ( KListWrap )                 [function]
rule isElabKList([ElabKR:ElabKResult,, Ks:KList]) => isElabKList([Ks])
rule isElabKList([.KList]) => true

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
    (defaultElabHeating(KL) ==K true orBool customElabHeating(KL, [HeadKs,,K]) ==K true)
    andBool notBool isElabKResult(K) ==K true
        [transition-strictness]

rule [elab-cool-default]:
    (ElabK:ElabKResult => .) ~> elab(_:KLabel(_,, (CHOLE => ElabK),, _))

/*@ Must be true for AST nodes that require elaboration heating of their children. For the arguments KL, Ks,
the original node is of he form KL(KS,,_) and the heated child is always the last element of Ks.
Thus it is possible to decide whether the child is allowed to be heated based both on the position of the child
in the list of arguments as well as based on the state of previous brothers.

  This predicate is intended to be used for KLabels that require specific child heating rules based on the state
of their children. The KLabels that heat all their children using default rules are enumerated in the predicate
defaultElabHeating.

The predicate definition is scattered across modules related to elaboration.*/
syntax K ::= customElabHeating ( KLabel, KListWrap )          [function]

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
    isElabKList([ElabResL]) ==K true

rule [elabDispose-process]:
    elabDispose(KL:KLabel(_,, (elabRes(K:K) => K),, _))

rule [elabDispose-to-elabEnd]:
    elabDispose(KL:KLabel(Ks:KList)) => elabEnd(KL(Ks))
when
    notBool haveElabRes([Ks]) ==K true

//@ True if given KList have no terms of the form elabRes(...), false otherwise.
syntax K ::= haveElabRes ( KListWrap )          [function]
rule haveElabRes([_,, elabRes(_),, _]) => true

//K bug additional rule required since we introduced KListWrap
rule haveElabRes([_,, KList2KLabel _,, elabRes(_),, _ (_),, _]) => true

/*@ The 3rd elaboration-phase wrapper for expressions. Represents the case when children are completely elaborated and
unwrapped from elabRes(), but root node might not be elaborated yet. The implementation is scattered across all modules
that deal with the elaboration phase.
*/
syntax K ::= elabEnd ( K )

//@ \subsection{Auxiliary functions for elaboration phase}

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

rule isElabNaked(findQualifierOfType(_,_)) => true

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

/*@ \subsection{Elaboration of KListWrap - the list of terms} */
//K bug: this section is a workaround t a serious K' bug that prevents [...] to be properly heated and cooled

rule [elab-heat-KListWrap]:
    (. => #if isElabNaked(K) ==K true
            #then K
            #else elab(K)
          #fi
    )
    ~> elab([HeadKs:KList,, (K:K => CHOLE),, _:KList])
when
    isElabKList([HeadKs]) andBool notBool isElabKResult(K) ==K true

rule [elab-cool-KListWrap]:
    (ElabK:ElabKResult => .) ~> elab([_,, (CHOLE => ElabK),, _])

rule [elab-to-elabDispose-KListWrap]:
    elab([K1:K,,ElabResL:KList]) => elabDispose([K1,,ElabResL])
when
    isElabKList([K1,,ElabResL]) ==K true

rule [elabDispose-process-KListWrap]:
    elabDispose([_,, (elabRes(K:K) => K),, _])

rule [elabDispose-to-elabEnd-KListWrap]:
    elabDispose([K1:K,,Ks:KList]) => elabRes([K1,,Ks])
when
    notBool haveElabRes([Ks]) ==K true

rule [elab-to-elabRes-KListWrap-empty]:
    elab([.KList]) => elabRes([.KList])

endmodule
