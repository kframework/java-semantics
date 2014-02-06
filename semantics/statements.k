require "core.k"
require "subtyping.k"
require "var-lookup.k"

//@ \section{Module STATEMENTS}

module STATEMENTS
    imports CORE
    imports SUBTYPING
    imports VAR-LOOKUP

//@ \subsection{Call of main method}

//For now main class may only be placed in the default package.
rule [StartExecutionPhase]:
    <k>
      //K-AST for new <MainClass>().main(new String[0]);
      . =>  elab('ExprStm(
              'Invoke(
                'MethodName('TypeName(packageId(String2Id("")),,String2Id(MainClassS)),, String2Id("main")),,
                'ListWrap('NewArray(
                    rtString,,
                    'ListWrap('Dim(0 :: int)),,
                    'ListWrap(.KList)))
              )
            ))
    </k>
    <env> . </env>
    <mainClass> ListItem(MainClassS:String) </mainClass>
    <globalPhase> ElaborationPhase => ExecutionPhase  </globalPhase>

//@ \subsection{Program stack}

//ListItem content as a stack layer
syntax K ::=
    "sl" "("
      K ","   //K - rest of computation
      Bag     //MethContext - the content of <methodContext>
    ")"

//bug in K? we cannot use the constructions below, they will give some errors related to k-prelude.
//syntax StackConsumerLabel ::= 'Return | 'Throw | 'Break | 'Continue
//syntax KLabel ::= StackConsumerLabel

syntax K ::= "isStackConsumer" "(" KLabel ")" [function]
rule isStackConsumer (KL:KLabel) =>
           (KL ==KLabel 'Return)
    orBool (KL ==KLabel 'Throw)
    orBool (KL ==KLabel 'Break)
    orBool (KL ==KLabel 'Continue) [anywhere]

//@ \subsection{Blocks} JLS \$14.2

rule [Block]:
    <k> 'Block(S:K) => S ~> env(Env:Map) ...</k>
    <env> Env </env>
        [structural]

rule [ListOfStatements]:
    'ListWrap(S1:K,, Stmts:KList) => S1 ~> 'ListWrap(Stmts)
        [structural]

rule [DiscardEmptyList]:
    <k> 'ListWrap(.KList) => . ...</k>
        [structural]

//@ \texttt{env} Restore the env cell content from env(...) statement argument
syntax K ::= "env" "(" Map ")"

rule [env]:
    <k> env(Env:Map) => . ...</k>
    <env> _ => Env </env>
        [structural]

rule [envDiscard]:
    (env(_) => .) ~> env(_)
        [structural]

//@ \subsection{Local Variable Declaration Statements} JLS \$14.4
//@ Not only local but fields also

/*In Java current version of semantics only int and boolean primitive
types are supported*/

rule [LocalVarDec]:
    <k> 'LocalVarDec(_:K,, T:Type,,'ListWrap('VarDec(X:Id))) => . ...</k>
    <env> Env:Map => Env[L:Int/X] </env>
    <store>... . => L |-> default(T) ...</store>
    <nextLoc> L => L +Int 1 </nextLoc>

//@ \subsection{Empty statement} JLS \$14.6

rule [Empty]:
    'Empty(_) => .

//@ \subsection{Labeled statements} JLS \$14.7

rule [Labeled]:
    'Labeled(X:Id,, S:K) => S ~> labeledImpl(X)

rule [labeledImplDiscard]:
    labeledImpl(_) => .K

//processed version of the labeled statement
syntax K ::= "labeledImpl" "(" Id ")"

//@ \subsection{Expression statements} JLS \$14.8

context 'ExprStm(HOLE)

rule [ExprStm]:
    'ExprStm(_:TypedVal) => .

//@ \subsection{If statement}

context 'If(HOLE,,_,,_)

rule [IfTrue]:
    'If(true::bool,, S:K,, _) => S

rule [IfFalse]:
    'If(false::bool,, _,, S:K) => S

rule [IfThenDesugar]:
    'If(E:K,,S1:K) => 'If(E:K,, S1:K,, .K)

//@ \subsection{Assert statement}

context 'AssertStm(HOLE,,_:KList)

rule [AssertStmTrueDiscard]:
    'AssertStm(true::bool,, _:KList) => .

rule [AssertStmOneArg]:
    'AssertStm(false::bool)
    =>  elab('Throw('NewInstance(
          'None(.KList),,
          (class String2Id("java.lang.AssertionError")),,
          'ListWrap(null),,
          'None(.KList)
        )))

context 'AssertStm(false::bool,, HOLE)

rule [AssertStmTwoArgs]:
    'AssertStm(false::bool,, TV:TypedVal)
    =>  elab('Throw('NewInstance(
          'None(.KList),,
          (class String2Id("java.lang.AssertionError")),,
          'ListWrap( toString(TV) ),,
          'None(.KList)
        )))

//@ \subsection{Switch statement}

syntax K ::= "switchImpl" "("
                TypedVal "," // TV - switch argument
                KList ","  // switch body - list of 'SwitchGroup labels
                K            // DefaultStm - default block, if any
              ")"
            | "switchEnd"

context 'Switch(HOLE,,_)

//The switchEnd in the right-hand side of => is required to properly interact with break.
rule [Switch]:
    'Switch(TV:TypedVal,, 'SwitchBlock('ListWrap(Ks:KList),, TrailingLabels:K))
    => switchImpl(TV, (Ks,, 'SwitchGroup(TrailingLabels,, .K)), .K)
    ~> switchEnd

context switchImpl( _,
          ( 'SwitchGroup('ListWrap('Case(HOLE),,_:KList),,_),, _:KList ), _)

//the type associated to V and V2 is not important for match, only the value.
//JLS3 \$14.11, page 377: Every case constant expression associated with
//a switch statement must be assignable (�5.2) to the type of the switch Expression.

rule [SwitchCaseNotMatch]:
    switchImpl( V:RawVal :: _, ( 'SwitchGroup('ListWrap(
        ( 'Case(V2:RawVal :: _) => .KList ),,
        _:KList ),,_),, _), _)
when
    V =/=K V2

/*@Once case of first switch group matches, the whole switch is replaced
by it's block. The execution rules for switch will discard switch-related
constructs and will execute the statements. */

rule [SwitchCaseMatch]:
    switchImpl( V:RawVal :: _, ('SwitchGroup('ListWrap('Case(V :: _),,_:KList),,S:K),,Ks:KList), _)
    => 'ListWrap(S,,Ks)

rule [SwitchDefaultSave]:
    switchImpl( TV:TypedVal, (
      'SwitchGroup('ListWrap(
          ( 'Default(_) => .KList ),,
          _:KList),, S:K),, Ks:KList
      ),
      ( _:K => 'ListWrap(S,, Ks) )
    )

rule [SwitchGroupDiscard]:
    switchImpl( TV:TypedVal,
      (( 'SwitchGroup('ListWrap( .KList ),,_) => .KList ),,_),
    _)

rule [SwitchDefaultExec]:
    switchImpl( _, .KList, DefaultStm:K) => DefaultStm

rule [SwitchGroupExec]:
    'SwitchGroup(_:K,, S:K) => S

rule [SwitchEndDiscard]:
    switchEnd => .K

//@ \subsection{While statement} and loop infrastructure.

rule [While]:
    'While(E:K,,S:K) => whileImpl(E, S)         [structural]

syntax K ::= "whileImpl" "("
                K ","  // E - test expression. In For loop, it is UpdClause ~> testExp
                K      // S - while body
             ")"

rule [whileImpl]:
    whileImpl(E:K, S:K) => 'If(E,, 'Block(S ~> whileImpl(E, S)),, .K)     [structural]

//@ \subsection{Do statement}
rule
    'DoWhile(S:K,,E:K) => S ~> whileImpl(E, S)  [structural]

//@ \subsection{For statement}

//wrapper of certain clauses of for statement
syntax K ::= "stm" "(" K ")"

rule [stmDiscard]:
    stm('ListWrap(.KList)) => .
        [structural]

rule [stmList]:
    stm('ListWrap(E:K,, Es:KList)) => 'ExprStm(E) ~> stm('ListWrap(Es))
when
    isTypedExp(E) ==K true                [structural]

rule [stmLocalVarDec]:
    stm('ListWrap(K:K,,Ks:KList)) => 'ListWrap(K,,Ks)
when
    notBool (isTypedExp(K) ==K true)      [structural]

rule [ForFirstArgV1Red]:
    'For((
      'ListWrap(InitExps:KList) => stm('ListWrap(InitExps))
    ),,_:KList)
        [structural]

//Works also in elaboration phase
rule [ForFirstArgV2Red]:
    'For((
      'LocalVarDec(Ks:KList) => stm('ListWrap('LocalVarDec(Ks)))
    ),,_:KList)
        [structural]

rule [ForSecondArgRed]:
    'For(_:K,,(
      'None(.KList) => 'Some(true)
    ),,_:KList)
        [structural]

rule [ForThirdArgRed]:
    'For(_:K,,_:K,,(
      'ListWrap(UpdExps:KList) => stm('ListWrap(UpdExps))
    ),,_:K)
        [structural]

//this form of resulting while is required for compatibility with continue statement
rule [For]:
    'For(stm(InitClause:K),, 'Some(TestExp:K),, stm(UpdClause:K),, S:K)
     => 'Block(stm(InitClause)
        ~> 'If(TestExp,, 'Block(S) ~> whileImpl(stm(UpdClause) ~> TestExp, S),, .K))  [structural]

//stack consumer stm - Return, Throw, Break or Continue reaches tryFinallySL layer
//todo test whether KL argument might be not KResult at the moment of this rule
rule [StackConsumerStmInTryFinally]:
    KL:KLabel(Ks:KList) ~> finallyBlock(FinallyS:K)
    => FinallyS ~> KL(Ks)
when
  isStackConsumer(KL)

rule [StackConsumerStmRestoreEnv]:
    KL:KLabel(Ks:KList) ~> env(Env:Map)
    => env(Env:Map) ~> KL(Ks)
when
  isStackConsumer(KL)

//@ \subsection{Break statement}

rule [BreakUnlabeledPropagate]:
    'Break('None(_)) ~> (KL:KLabel(_) => .)
when
            KL =/=KLabel 'env`(_`)
    andBool KL =/=KLabel 'finallyBlock`(_`)
    andBool KL =/=KLabel 'whileImpl`(_`,_`)
    andBool KL =/=KLabel 'switchEnd

rule [BreakUnlabeled]:
    'Break('None(_)) ~> KL:KLabel(_) => .
when
           KL ==KLabel 'whileImpl`(_`,_`)
    orBool KL ==KLabel 'switchEnd

rule [BreakLabeledPropagate]:
    'Break('Some(X:Id)) ~> (KL:KLabel(_) => .)
when
            KL =/=KLabel 'env`(_`)
    andBool KL =/=KLabel 'finallyBlock`(_`)
    andBool KL =/=KLabel 'labeledImpl`(_`)

rule [BreakLabeledNotMatch]:
    'Break('Some(X1:Id)) ~> (labeledImpl(X2:Id) => .)
when
    X1 =/=K X2

rule [BreakLabeledMatch]:
    'Break('Some(X:Id)) ~> labeledImpl(X:Id) => .

//@ \subsection{Continue statement}

rule [ContinuePropagate]:
    'Continue(_) ~> (KL:KLabel(_) => .)
when
            KL =/=KLabel 'env`(_`)
    andBool KL =/=KLabel 'finallyBlock`(_`)
    andBool KL =/=KLabel 'whileImpl`(_`,_`)

rule [ContinueUnlabeled]:
    ('Continue('None(_)) => .) ~> whileImpl(_,_)

rule [ContinueLabeledMeetsWhile]:
    <k>
      (. => getWhileLabel(Rest)) ~> 'Continue('Some(X:Id)) ~> whileImpl(_,_) ~> Rest:K
    </k>

rule [ContinueLabeledNotMatch]:
    (whileLabel(LabelK:K) => .) ~> 'Continue('Some(X:Id)) ~> (whileImpl(_,_) => .)
when
    LabelK =/=K X

rule [ContinueLabeledMatch]:
    whileLabel(X) ~> 'Continue('Some(X:Id)) => .

//Auxiliary constructs used in the semantics of continue.
//Search for the label associated with the last encountered while statement
syntax K ::= "getWhileLabel" "(" K ")"
           | "whileLabel" "(" K ")"

rule getWhileLabel((env(_) => .) ~> _)
rule getWhileLabel(.K) => whileLabel(.K)
rule getWhileLabel(labeledImpl(X:Id) ~> _) => whileLabel(X)

rule getWhileLabel(KL:KLabel(_) ~> _) => whileLabel(.K)
when
            KL =/=KLabel 'env`(_`)
    andBool KL =/=KLabel 'labeledImpl`(_`)

/*@\subsection{Return} At method return, we have to check that the type
of the returned
value is a subtype of the expected return type.  Moreover, if that is
the case, then we also up-cast the returned value to one of the
expected type. */

context 'Return('Some(HOLE))

rule [ReturnNothingDesugar]:
    'Return('None(.KList) => 'Some(nothing :: void))
        [structural]

rule [ReturnPropagate]:
    'Return('Some(TV:TypedVal)) ~> (KL:KLabel(Ks:KList) => .K)
when
            KL =/=KLabel 'env`(_`)
    andBool KL =/=KLabel 'finallyBlock`(_`)

//bug workaround: (V::T1) needs to be taken between parentheses, because K
//wrongly considers ~> to have higher priority than ::
rule [ReturnMethodEnd]:
    <k>
      'Return('Some(V:RawVal :: T2:Type))
      => subtype(T2, T1) ~> true? ~> (V::T1) ~> K    </k>
    <stack> ListItem( sl(K:K, MethContext:Bag) ) => . ...</stack>
    <methodContext>
      <return> T1:Type </return> _:Bag => MethContext
    </methodContext>

/*@ \subsection{Throw statement}
Exceptions are propagated now until a catch that can bind them is
encountered. */

context 'Throw(HOLE)

rule [Throw]:
    (. => checkCatch(subtype(typeOf(TV), T)))
    ~> 'Throw(TV:TypedVal)
    ~> catchBlocks(catchImpl(paramImpl(T:Type, X:Id),_),, _)

syntax K ::= "checkCatch" "(" K ")"
context checkCatch(HOLE)

rule [ThrowCheckedTrue]:
    checkCatch(true::bool) ~> 'Throw(TV:TypedVal)
    ~> catchBlocks(catchImpl(paramImpl(T:Type, X:Id), CatchS:K),, _)
    => 'Block('ListWrap(
          'LocalVarDec(.K,, T,, 'ListWrap('VarDec(X))),,
          elab('ExprStm('Assign(localVar(X)::T,, TV))),,
          CatchS
        ))

rule [ThrowCheckedFalse]:
    (checkCatch(false::bool) => .)
    ~> 'Throw(TV:TypedVal) ~> catchBlocks((catchImpl(_,_) => .KList),, _)

rule [ThrowCatchEmptyDiscard]:
    'Throw(TV:TypedVal) ~> (catchBlocks(.KList) => .)

rule [ThrowPropagate]:
    'Throw(TV:TypedVal) ~> (KL:KLabel(_) => .)
when
            KL =/=KLabel 'env`(_`)
    andBool KL =/=KLabel 'finallyBlock`(_`)
    andBool KL =/=KLabel 'catchBlocks`(_`)

rule [ThrowMethodEnd]:
    <k>
      'Throw(TV:TypedVal) ~> (. => K)
    </k>
    <stack> ListItem( sl(K:K, MethContext:Bag) ) => . ...</stack>
    <methodContext> _ => MethContext </methodContext>

rule [ThrowCausesThreadTermination]:
    <k>
      'Throw(TV:TypedVal)
      =>  elab('ExprStm(
            'Invoke(
              'Method(
                'MethodName(
                  'AmbName( 'AmbName( String2Id("System")),, String2Id("out") ),,
                  String2Id("println")
                )
              ),,
              'ListWrap( 'Plus( "Thread terminated with exception: ",, TV ) )
            )
          ))
    </k>
    <stack> .List </stack>

//@ \subsection{Try statement}

rule [TryCatchFinallyDesugar]:
    'Try(TryS:K,, 'ListWrap(K:K,, Ks:KList),,FinallyS:K)
    => 'Try('Try(TryS,,'ListWrap(K,,Ks)),,'ListWrap(.KList),,FinallyS)
        [structural]

/*@ \subsubsection{Execution of try-catch} JLS \$14.20.1
*/

//resolve the catch clauses of try statement
context 'Try(_:K,,'ListWrap(_,, HOLE,, _))

//resolve 'Param term of the catch clause
context 'Catch(HOLE,, _)

rule 'Catch(KR:KResult,, S:K) => catchImpl(KR,S)

//internal representation of a preprocessed catch clause
syntax KResult ::= "catchImpl" "(" K //paramImpl term
                               "," K //the code block
                               ")"

//The auxiliary constructs that hold catch clauses / finally clause
//after try clause has been moved to the top of computation
syntax K ::= "catchBlocks" "(" KList ")" //arg - list of catchImpl
           | "finallyBlock" "(" K ")"      //arg - finally block

rule [TryCatch]:
    'Try(TryS:K,, 'ListWrap(KRs:KList)) => TryS ~> catchBlocks(KRs)
when isKResult(KRs)

rule [TryBlocksDiscard]:
    catchBlocks(_) => .K

/*@ \subsubsection{Execution of try-finally} JLS \$14.20.2
*/

rule [TryFinally]:
    'Try(TryS:K ,,'ListWrap(.KList),,FinallyS:K) => TryS ~> finallyBlock(FinallyS)

rule [TryFinallyNormalEnd]:
    finallyBlock(FinallyS:K) => FinallyS

endmodule
