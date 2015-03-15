module ELABORATION-CORE
    imports CORE-SORTS
    imports SUBTYPING
    imports ELABORATION-CATEGORIES

/*@
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
      elab('CastRef(\_,, 'Minus('ExprName(x))))
      => elab('Minus('ExprName(x)) ~> elab('CastRef(\_,, HOLE)
    Some AST terms, especially some statements require custom elaboration heating rules. If the heated expression
      should be always computed into a KResult, such as a type, package or certain literal expresssions, then
      it is heated in the "naked" form, e.g. not wrapped into elab().
  2. Elaboration of children. All the children of the expression are elaborated. After this phase elaborated children
    will be typed (if they are expressions) and wrapped into elabRes(). Typed expressions are cast expressions -
    like cast(T, Exp). The whole initial term will be converted into:
      elab('Minus(elabRes(cast(int, localVar(X))))) ~> elab('CastRef(\_,, HOLE)
  3. Initiation of the step elabDispose. When all children have been elaborated and are either KResult of elabRes(),
    the wrapper is changed from elab() to elabDispose().
      elabDispose('Minus(elabRes(cast(int, localVar(X))))) ~> elab('CastRef(\_,, HOLE)
  4. Unwrapping of children. During elabDispose step elaborated children are unwrapped from their elabRes() wrapper.
      elabDispose('Minus(cast(int, localVar(X)))) ~> elab('CastRef(\_,, HOLE)
  5. End of the step elabDispose. When all children of the term wrapped into elabDispose have been unwrapped
    from their elabRes() wrapper, the root wrapper is replaced from elabDispose to elabEnd. This contributes
    to more simple rules for the following steps.
    elabRes('Minus(cast(int, localVar(X)))) ~> elab('CastRef(\_,, HOLE)
  6. Computation of elaboration result. Now that all children have been elaborated and unwrapped, it is possible to
    compute the type of the current expression itself. When the expression is fully elaborated, it is wrapped into
    elabRes(). This is the step that requires custom rules for most AST terms.
      elabRes('Minus(cast(int,cast(int, localVar(X))))) ~> elab('CastRef(\_,, HOLE)
  7. Elaboration cooling. Once the top K Item was wrapped into elabRes, it is ready to be cooled back into its original
    context:
      elab('CastRef(\_,, elabRes('Minus(cast(int,cast(int, localVar(X)))))))
*/

/*@Custom hole used for custom heating/cooling rules in the elaboration phase.*/
syntax KItem ::= "CHOLE"

//@Elaborates the given statement/expression. The first step of elaboration.
syntax KItem ::= elab ( K )

/*@ Wraps the elaboration result. Since elaboration may happen at both ElaborationPhase and
ExecutionPhase, it cannot be KResult. Actually it is not KResult for HOLE, but is for CHOLE.*/
syntax ElabKResult ::= elabRes ( K )
rule isElabKResult(KR:KResult) => true

/*@ \subsection{Operator ??}*/

/*@ Chain of responsibility pattern.
Evaluate the first argument. if it is KResult (except noValue) or elabRes(), the result of the ?? expression is
the result of the first argument. Otherwise, if the first argument evaluates to noValue, the result of the
?? expression is the result of the second argument.
*/
syntax KItem ::= K "??" K [right]

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

  It is notably NOT a cast() expression. This, together with the fact that cast() has no elaboration heatig rules,
  makes the whole elaboration phase non-reentrant.
*/
syntax KItem ::= isElabKList ( KListWrap )                 [function]
rule isElabKList([ElabKR:ElabKResult,, Ks:KList]) => isElabKList([Ks])
rule isElabKList([.KList]) => true
rule isElabKList([_]) => false [owise]

//@ Elaborate parameter type, if not elaborated yet. For catch clause.
context  elab('Param(_:K,, HOLE,, _:Id))

/*@Adds params to the <elabEnv>. Used in both ELABORATION-TOP-BLOCKS and ELABORATION-BLOCKS
*/
rule [elab-Param]:
    <k> elab('Param(K1:K,, T:Type,, X:Id)) => elabRes('Param(K1:K,, T:Type,, X:Id)) ...</k>
    <elabEnv> ListItem(mapWrap((.Map => X |-> T) _)) ...</elabEnv>

//@Removes the last layer from <elabEnv>
syntax KItem ::= "removeLastElabEnv"
rule [removeLastElabEnv]:
    <k> removeLastElabEnv => .K ...</k>
    <elabEnv> ListItem(_) => .List ...</elabEnv>
    <localTypes> ListItem(_) => .List ...</localTypes>

/*@ \subsection{Elaboration of code blocks} */

/*@ Heating arguments for both expression and statement terms.
The attribute [transition-strictness] is used as transition attribute for testing strictness.
This is a rule that may lead to unexpected nondeterminism if it is wrongly implemented.
In order to expose incorrect nondeterminism we need to model-check a program that exposes the nondeterminism.

Labels that are "naked" should be heated in their pure form. Other terms should be heated wrapped into elab().
*/
//todo A matching case 2
//rule [elab-heat-default]:
//    (. => #if isElabNaked(K) ==K true
//            #then K
//            #else elab(K)
//          #fi
//    )
//    ~> elab(KL:KLabel(HeadKs:KList,, (K:K => CHOLE),, _:KList))
//when
//    (defaultElabHeating(KL) ==K true orBool customElabHeating(KL, [HeadKs,,K]) ==K true)
//    andBool notBool isElabKResult(K) ==K true
//        [transition-strictness]

rule [elab-heat-default-case1]:
    elab(KL:KLabel(L:KList)) =>  elabFirstNotElabedChild(KL(L), KL(.KList))
when defaultElabHeating(KL) ==K true andBool isElabKList([L]) ==K false andBool KL =/=KLabel 'KListWrap

syntax KItem ::= elabFirstNotElabedChild( K, K )

rule elabFirstNotElabedChild(KL:KLabel((Hd:ElabKResult => .KList),, _:KList), KL(_:KList,, (.KList => Hd)))
rule elabFirstNotElabedChild(KL:KLabel(K:K,, Tl:KList), KL(Hd:KList))
        => (#if isElabNaked(K) ==K true
               #then K
               #else elab(K)
            #fi) ~> elab(KL(Hd,,CHOLE,,Tl))
when notBool isElabKResult(K) ==K true

rule [elab-cool-default]:
   // (ElabK:ElabKResult => .) ~> elab(_:KLabel(HeadKs:KList,, (CHOLE => ElabK),, _:KList))
    (ElabK:ElabKResult ~> elab(K:KLabel(L:KList))) => coolElabedChild(ElabK, elab(K(L)), elab(K(.KList)))
when hasCHOLE([L]) andBool K =/=KLabel 'KListWrap

syntax KItem ::= hasCHOLE(KListWrap) [function]
rule hasCHOLE([.KList]) => false
rule hasCHOLE([CHOLE,,_]) => true
rule hasCHOLE([Hd:K,,Tl:KList]) => hasCHOLE([Tl]) when Hd =/=K CHOLE

syntax KItem ::= coolElabedChild(ElabKResult, K, K)
rule coolElabedChild(_, elab(_:KLabel(.KList)), R) => R
rule coolElabedChild(ElabK:ElabKResult, elab(K:KLabel((CHOLE => .KList),,_:KList)), elab(K(_:KList,, (.KList => ElabK))))
rule coolElabedChild(_, elab(K:KLabel((Hd => .KList),,_:KList)), elab(K(_:KList,, (.KList => Hd))))
when Hd =/=K CHOLE

/*@ Must be true for AST nodes that require elaboration heating of their children. For the arguments KL, Ks,
the original node is of he form KL(KS,,\_) and the heated child is always the last element of Ks.
Thus it is possible to decide whether the child is allowed to be heated based both on the position of the child
in the list of arguments as well as based on the state of previous brothers.

  This predicate is intended to be used for KLabels that require specific child heating rules based on the state
of their children. The KLabels that heat all their children using default rules are enumerated in the predicate
defaultElabHeating.

The predicate definition is scattered across modules related to elaboration.*/
syntax KItem ::= customElabHeating ( KLabel, KListWrap )          [function]
rule customElabHeating(_,_) => false [owise]

/*@ The default algorithm of transforming the term from elab to elabRes, when the children were completely elaborated.
  Deletes elabRes wrappers from children. This algorithm is activated when the following conditions apply:
    - term is not customElabChildren
    - term children are completely elaborated - isElab(children)
    - term is not naked. This case should never be true, but there is some weird case that requires it.
  When the default algorithm is not appropriate, the respective term should be in the cathegory customElabChildren
*/
syntax KItem ::= elabDispose ( K )
               | elabDispose ( K, K)
//due to the lack of associate matching, we need another argument to enable looping and hold the result

/*@ This rule is universal for all forms of terms, both instructions and statements.
but KL doesn't include KListWrap because of k bug, same rules for KListWrap can be found in the last subsection.
*/
rule [elab-to-elabDispose]:
    elab(KL:KLabel(ElabResL:KList)) => elabDispose(KL(ElabResL), KL(.KList))
when
    isElabKList([ElabResL]) ==K true

rule [elabDispose-process-strip]:
    elabDispose(KL:KLabel((elabRes(K) => .KList),, _:KList), KL(_:KList,, (.KList => K)))
when KL =/=KLabel 'KListWrap

rule [elabDispose-process-keep]:
    elabDispose(KL:KLabel((K:K => .KList),, _:KList), KL(_:KList,, (.KList => K)))
when
    getKLabel(K) =/=KLabel 'elabRes andBool KL =/=KLabel 'KListWrap

rule [elabDispose-to-elabEnd]:
    elabDispose(KL:KLabel(.KList), KL(Ks)) => elabEnd(KL(Ks)) when KL =/=KLabel 'KListWrap

/*@ The 3rd elaboration-phase wrapper for expressions. Represents the case when children are completely elaborated and
unwrapped from elabRes(), but root node might not be elaborated yet. The implementation is scattered across all modules
that deal with the elaboration phase.
*/
syntax KItem ::= elabEnd ( K )

//@ \subsection{Auxiliary functions for elaboration phase}

/*@ Computes into an expression of the form elabRes(cast(QualClass, 'QThis(QualClass))),
where QualClass is searched in the enclosing context of the first argument,
being a subclass of the second one.
Or noValue if no suitable result is found
*/
syntax KItem ::=  findQualifierOfType (
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
    notBool (isExp(KL(Ks)) ==K true orBool customElabEnd(KL) ==K true)

//@ The implementation is scattered across elaboration-related modules
syntax KItem ::= customElabEnd ( KLabel )                       [function]
rule customElabEnd(_) => false [owise]

//@ Eliminate stmtAndExp if the first argument is empty, otherwise keep it for execution phase.
rule elabEnd( stmtAndExp(Stmt:K, cast(T:Type, Exp:K)) )
     => #if Stmt =/=K .K
          #then elabRes(cast(T, stmtAndExp(Stmt,   cast(T:Type, Exp:K))))
          #else elabRes(cast(T:Type, Exp:K))
        #fi

/*@ \subsection{Elaboration of KListWrap - the list of terms} */
//K bug: this section is a workaround t a serious K' bug that prevents [...] to be properly heated and cooled
//todo A matching
//rule [elab-heat-KListWrap]:
//    (. => #if isElabNaked(K) ==K true
//            #then K
//            #else elab(K)
//          #fi
//    )
//    ~> elab([HeadKs:KList,, (K:K => CHOLE),, _:KList])
//when
//    isElabKList([HeadKs]) andBool notBool isElabKResult(K) ==K true
//
//rule [elab-cool-KListWrap]:
//    (ElabK:ElabKResult => .) ~> elab([HeadKs:KList,, (CHOLE => ElabK),, _:KList])
//when isElabKList([HeadKs])

rule [elab-to-elabDispose-KListWrap]:
    elab([ElabResL:KList]) => elabDispose([ElabResL], [.KList])
when
    isElabKList([ElabResL]) ==K true

rule [elabDispose-process-strip-KListWrap]:
    elabDispose([(elabRes(K) => .KList),, _:KList], [_:KList,,(.KList => K)])

rule [elabDispose-process-keep-KListWrap]:
    elabDispose([(K:K => .KList),, _:KList], [_:KList,,(.KList => K)]) when getKLabel(K) =/=KLabel 'elabRes

rule [elabDispose-to-elabRes-KListWrap]:
    elabDispose([.KList], K:K) => elabRes(K)

endmodule
