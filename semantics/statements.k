require "core-sorts.k"
require "subtyping.k"
require "var-lookup.k"
require "method-invoke.k"

//@ \section{Module STATEMENTS}

module STATEMENTS
    imports CORE-SORTS
    imports SUBTYPING
    imports VAR-LOOKUP
    imports METHOD-INVOKE // for bindTo

//@ \subsection{Call of main method}

//For now main class may only be placed in the default package.
rule [ExecutionPhase-Start]:
    <k>
      //K-AST for new <MainClass>().main(new String[0]);
      . =>  'ExprStm(
              'Invoke(
                'Method('MethodName('TypeName(packageId(String2Id("")),,String2Id(MainClassS)),, String2Id("main"))),,
                [
                  newArrayImpl(stringClass, ['Dim(0 :: int)], null :: stringClass, .KList)
                ]
              )
            )
    </k>
    <env> . </env>
    <mainClass> ListItem(MainClassS:String) </mainClass>
    <globalPhase> ElaborationPhase => ExecutionPhase  </globalPhase>

//@ \subsection{Program stack}

//ListItem content as a stack layer
syntax K ::=  sl (
                K,  //K - rest of computation
                Bag //MethContext - the content of <methodContext>
              )

syntax KLabel ::= "'Empty"
                | "'Labeled"
                | "'ExprStm"
                | "'If"
                | "'AssertStm"
                | "'Switch"
                | "'SwitchBlock"
                | "'SwitchGroup"
                | "'Case"
                | "'Default"
                | "'While"
                | "'DoWhile"
                | "'For"
                | "'Break"
                | "'Continue"
                | "'Return"
                | "'Throw"
                | "'Try"
                | "'Catch"
                | "'Block"


//@ \subsection{Blocks} JLS \$14.2

rule [Block]:
    <k> 'Block(S:K) => S ~> env(Env:Map) ...</k>
    <env> Env </env>
        [structural]

//@ \texttt{env} Restore the env cell content from env(...) statement argument
syntax K ::= env ( Map )
rule <k> env(Env:Map) => . ...</k>
     <env> _ => Env </env>
        [structural]

rule [env-double-Discard]:
    (env(_) => .) ~> env(_)
        [structural]

/*@ \subsection{Local Variable Declaration Statements} JLS \$14.4
    Not only local but fields also*/

//@ 'LocalVarDec(_:K,, T:Type,, ['VarDec(X:Id)])
syntax KLabel ::= "'LocalVarDec"
                | "'VarDec"

rule [LocalVarDec]:
    <k> 'LocalVarDec(_:K,, T:Type,,['VarDec(X:Id)]) => . ...</k>
    <env> Env:Map => Env[L/X] </env>
    <store>... . => L |-> default(T) ...</store>
    <nextLoc> L:Int => L +Int 1 </nextLoc>

//@ \subsection{Empty statement} JLS \$14.6

rule [Empty]:
    'Empty(_) => .

//@ \subsection{Labeled statements} JLS \$14.7

rule [Labeled]:
    'Labeled(X:Id,, S:K) => S ~> labeledImpl(X)

//@ Processed version of the labeled statement
syntax K ::= labeledImpl ( Id )

rule [labeledImpl-Discard]:
    labeledImpl(_) => .K

//@ \subsection{Expression statements} JLS \$14.8

context 'ExprStm(HOLE)

rule 'ExprStm(_:TypedVal) => .K

//@ \subsection{If statement}

context 'If(HOLE,,_,,_)

rule [If-True]:
    'If(true::bool,, S:K,, _) => S
        [symbolic-rule]

rule [If-False]:
    'If(false::bool,, _,, S:K) => S
        [symbolic-rule]

rule [If-Then-Desugar]:
    'If(E:K,,S1:K) => 'If(E:K,, S1:K,, .K)

//@ \subsection{Assert statement}

context 'AssertStm(HOLE,,_:KList)

rule [AssertStm-True-Discard]:
    'AssertStm(true::bool,, _:KList) => .

rule [AssertStm-OneArg]:
    'AssertStm(false::bool)
    =>  'Throw('NewInstance(
          'None(.KList),,
          (class String2Id("java.lang.AssertionError")),,
          [null::stringClass],,
          'None(.KList)
        ))

context 'AssertStm(false::bool,, HOLE)

rule [AssertStm-TwoArgs]:
    'AssertStm(false::bool,, TV:TypedVal)
    =>  'Throw('NewInstance(
          'None(.KList),,
          (class String2Id("java.lang.AssertionError")),,
          [ toString(TV) ],,
          'None(.KList)
        ))

//@ \subsection{Switch statement}

syntax K ::=  switchImpl (
                TypedVal, // TV - switch argument
                KList,    // switch body - list of 'SwitchGroup labels
                K         // DefaultStm - default block, if any
              )

context 'Switch(HOLE,,_)

//@ The switchEnd in the right-hand side of => is required to properly interact with break.
rule [Switch]:
    'Switch(TV:TypedVal,, 'SwitchBlock([Ks:KList],, TrailingLabels:K))
    => switchImpl(TV, (Ks,, 'SwitchGroup(TrailingLabels,, .K)), .K)
    ~> switchEnd

context switchImpl( _,
          ( 'SwitchGroup(['Case(HOLE),,_:KList],,_),, _:KList ), _)

/*@ The type associated to V and V2 is not important for match, only the value.
JLS3 \$14.11, page 377: Every case constant expression associated with
a switch statement must be assignable (�5.2) to the type of the switch Expression.*/

rule [switchImpl-CaseNotMatch]:
    switchImpl( V:RawVal :: _, ( 'SwitchGroup([
        ( 'Case(V2:RawVal :: _) => .KList ),,
        _:KList ],,_),, _), _)
when
    V =/=K V2

/*@Once case of first switch group matches, the whole switch is replaced
by it's block. The execution rules for switch will discard switch-related
constructs and will execute the statements. */
rule [switchImpl-CaseMatch]:
    switchImpl( V:RawVal :: _, ('SwitchGroup(['Case(V :: _),,_:KList],,S:K),,Ks:KList), _)
    => [S,,Ks]

rule [switchImpl-DefaultSave]:
    switchImpl( TV:TypedVal, (
      'SwitchGroup([
          ( 'Default(_) => .KList ),,
          _:KList],, S:K),, Ks:KList
      ),
      ( _:K => [S,, Ks] )
    )

rule [switchImpl-SwitchGroup-Discard]:
    switchImpl( TV:TypedVal,
      (( 'SwitchGroup([ .KList ],,_) => .KList ),,_),
    _)

rule [switchImpl-Default-Exec]:
    switchImpl( _, .KList, DefaultStm:K) => DefaultStm

rule [SwitchGroup-Exec]:
    'SwitchGroup(_:K,, S:K) => S

syntax K ::=  "switchEnd"

rule [switchEnd-Discard]:
    switchEnd => .K

//@ \subsection{While statement} and loop infrastructure.

rule 'While(E:K,,S:K) => whileImpl(E, S)         [structural]

syntax K ::=  whileImpl (
                K,  // E - test expression. In For loop, it is UpdClause ~> testExp
                K   // S - while body
              )

rule [whileImpl]:
    whileImpl(E:K, S:K) => 'If(E,, 'Block(S ~> whileImpl(E, S)),, .K)     [structural]

//@ \subsection{Do statement}
rule 'DoWhile(S:K,,E:K) => S ~> whileImpl(E, S)  [structural]

//@ \subsection{For statement}

//wrapper of certain clauses of for statement
syntax K ::= stm ( KListWrap )

rule [stm-KListWrap-empty]:
    stm([.KList]) => .
        [structural]

rule [stm-KListWrap-exp]:
    stm([E:K,, Es:KList]) => 'ExprStm(E) ~> stm([Es])
when
    getKLabel(E) ==KLabel 'cast                                           [structural]

rule [stm-KListWrap-LocalVarDec]:
    stm([K:K,,Ks:KList]) => [K,,Ks]
when
    notBool ( getKLabel(K) ==KLabel 'cast )                               [structural]

rule [For-FirstArgV1Red]:
    'For((
      [InitExps:KList] => stm([InitExps])
    ),,_:KList)
        [structural]

//Works also in elaboration phase
rule [For-FirstArgV2Red]:
    'For((
      'LocalVarDec(Ks:KList) => stm(['LocalVarDec(Ks)])
    ),,_:KList)
        [structural]

rule [For-SecondArgRed]:
    'For(_:K,,(
      'None(.KList) => 'Some(true)
    ),,_:KList)
        [structural]

rule [For-ThirdArgRed]:
    'For(_:K,,_:K,,(
      [UpdExps:KList] => stm([UpdExps])
    ),,_:K)
        [structural]

//this form of resulting while is required for compatibility with continue statement
rule [For]:
    'For(stm(InitClause:K),, 'Some(TestExp:K),, stm(UpdClause:K),, S:K)
     => 'Block(stm(InitClause)
        ~> 'If(TestExp,, 'Block(S) ~> whileImpl(stm(UpdClause) ~> TestExp, S),, .K))  [structural]

//totest model check - the argument of 'return and 'Throw must be evaluated. Otherwise some side effects during
// evaluation might be evaluated too late
/*@ Stack consumer stm - Return, Throw, Break or Continue reaches tryFinallySL layer*/
rule [StackConsumer-in-TryFinally]:
    StackCons:StackConsumer ~> finallyBlock(FinallyS:K)
    => FinallyS ~> StackCons

rule [StackConsumer-RestoreEnv]:
    StackCons:StackConsumer ~> env(Env:Map)
    => env(Env:Map) ~> StackCons

syntax StackConsumer ::= "dummyStackConsumer"
rule isStackConsumer('Return(_)) => true
rule isStackConsumer('Throw(_)) => true
rule isStackConsumer('Break(_)) => true
rule isStackConsumer('Continue(_)) => true

//@ \subsection{Break statement}

rule [Break-UnlabeledPropagate]:
    'Break('None(_)) ~> (KL:KLabel(_) => .)
when
            KL =/=KLabel 'env
    andBool KL =/=KLabel 'finallyBlock
    andBool KL =/=KLabel 'whileImpl
    andBool KL =/=KLabel 'switchEnd

rule [Break-Unlabeled]:
    'Break('None(_)) ~> KL:KLabel(_) => .
when
           KL ==KLabel 'whileImpl
    orBool KL ==KLabel 'switchEnd

rule [Break-LabeledPropagate]:
    'Break('Some(X:Id)) ~> (KL:KLabel(_) => .)
when
            KL =/=KLabel 'env
    andBool KL =/=KLabel 'finallyBlock
    andBool KL =/=KLabel 'labeledImpl

rule [BreakLabeledNotMatch]:
    'Break('Some(X1:Id)) ~> (labeledImpl(X2:Id) => .)
when
    X1 =/=K X2

rule [Break-LabeledMatch]:
    'Break('Some(X:Id)) ~> labeledImpl(X:Id) => .

//@ \subsection{Continue statement}

rule [Continue-Propagate]:
    'Continue(_) ~> (KL:KLabel(_) => .)
when
            KL =/=KLabel 'env
    andBool KL =/=KLabel 'finallyBlock
    andBool KL =/=KLabel 'whileImpl

rule [Continue-Unlabeled]:
    ('Continue('None(_)) => .) ~> whileImpl(_,_)

rule [Continue-LabeledMeetsWhile]:
    <k>
      (. => getWhileLabel(Rest)) ~> 'Continue('Some(X:Id)) ~> whileImpl(_,_) ~> Rest:K
    </k>

rule [Continue-LabeledNotMatch]:
    (whileLabel(LabelK:K) => .) ~> 'Continue('Some(X:Id)) ~> (whileImpl(_,_) => .)
when
    LabelK =/=K X

rule [Continue-LabeledMatch]:
    whileLabel(X) ~> 'Continue('Some(X:Id)) => .

/*@ Auxiliary constructs used in the semantics of continue.
Search for the label associated with the last encountered while statement*/
syntax K ::= getWhileLabel ( K )
           | whileLabel ( K )

rule getWhileLabel((env(_) => .) ~> _)
rule getWhileLabel(.K) => whileLabel(.K)
rule getWhileLabel(labeledImpl(X:Id) ~> _) => whileLabel(X)

rule getWhileLabel(KL:KLabel(_) ~> _) => whileLabel(.K)
when
            KL =/=KLabel 'env
    andBool KL =/=KLabel 'labeledImpl

/*@\subsection{Return} At method return, we have to check that the type
of the returned
value is a subtype of the expected return type.  Moreover, if that is
the case, then we also up-cast the returned value to one of the
expected type. */

context 'Return('Some(HOLE))

rule [Return-None-Desugar]:
    'Return('None(.KList) => 'Some(nothing :: void))
        [structural]

rule [Return-Propagate]:
    'Return('Some(TV:TypedVal)) ~> (KL:KLabel(Ks:KList) => .K)
when
            KL =/=KLabel 'env
    andBool KL =/=KLabel 'finallyBlock

rule [Return-MethodEnd]:
    <k>
      'Return('Some(V:RawVal :: T2:Type))
      => subtype(T2, T1) ~> true? ~> V::T1 ~> K    </k>
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
    ~> catchBlocks(catchImpl('Param(_:K,, T:Type,, X:Id),_),, _)

syntax K ::= checkCatch ( K )
context checkCatch(HOLE)

rule [Throw-checkCatch-True]:
    checkCatch(true::bool) ~> 'Throw(TV:TypedVal)
    ~> catchBlocks(catchImpl(Param:ExtKResult, CatchS:K),, _)
    => 'Block([
          bindTo(Param, TV),,
          CatchS
        ])

rule [Throw-checkCatch-False]:
    (checkCatch(false::bool) => .)
    ~> 'Throw(TV:TypedVal) ~> catchBlocks((catchImpl(_,_) => .KList),, _)

rule [Throw-catchBlocks-EmptyDiscard]:
    'Throw(TV:TypedVal) ~> (catchBlocks(.KList) => .)

rule [Throw-Propagate]:
    'Throw(TV:TypedVal) ~> (KL:KLabel(_) => .)
when
            KL =/=KLabel 'env
    andBool KL =/=KLabel 'finallyBlock
    andBool KL =/=KLabel 'catchBlocks

rule [Throw-MethodEnd]:
    <k>
      'Throw(TV:TypedVal) ~> (. => K)
    </k>
    <stack> ListItem( sl(K:K, MethContext:Bag) ) => . ...</stack>
    <methodContext> _ => MethContext </methodContext>

rule [Throw-CausesThreadTermination]:
    <k>
      'Throw(TV:TypedVal)
      =>  'ExprStm(
            'Invoke(
              'Method(
                'MethodName(
                  'Field( 'TypeName( String2Id("System")),, String2Id("out") ),,
                  String2Id("println")
                )
              ),,
              [ cast(objectClass, 'Plus( "Thread terminated with exception: ",, TV )) ]
            )
          )
    </k>
    <stack> .List </stack>

//@ \subsection{Try statement}

rule [Try-Catch-Finally-Desugar]:
    'Try(TryS:K,, [K:K,, Ks:KList],,FinallyS:K)
    => 'Try('Try(TryS,,[K,,Ks]),,[.KList],,FinallyS)
        [structural]

/*@ \subsubsection{Execution of try-catch} JLS \$14.20.1
*/

//resolve the catch clauses of try statement
context 'Try(_:K,,[_,, HOLE,, _])

//resolve 'Param term of the catch clause
context 'Catch(HOLE,, _)                                [result(ExtKResult)]

rule 'Catch(KR:ExtKResult,, S:K) => catchImpl(KR,S)

//@ Internal representation of a preprocessed catch clause
syntax KResult ::=  catchImpl (
                      K,  //'Param(...),
                      K   //the code block
                    )

rule [Try-Catch]:
    'Try(TryS:K,, [KRs:KList]) => TryS ~> catchBlocks(KRs)
when isKResult(KRs)

/*@ The auxiliary constructs that hold catch clauses / finally clause
after try clause has been moved to the top of computation*/
syntax K ::= catchBlocks ( KList ) //arg - list of catchImpl

rule [catchBlocks-Discard]:
    catchBlocks(_) => .K

/*@ \subsubsection{Execution of try-finally} JLS \$14.20.2
*/

rule [Try-Finally]:
    'Try(TryS:K,,[.KList],,FinallyS:K) => TryS ~> finallyBlock(FinallyS)

syntax K ::= finallyBlock ( K )      //arg - finally block

rule [finallyBlock-NormalEnd]:
    finallyBlock(FinallyS:K) => FinallyS

endmodule
