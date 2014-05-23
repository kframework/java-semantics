//@ \section{Module API-THREADS}

module API-THREADS
    imports CORE-SORTS
    imports METHOD-INVOKE-REST  //for invokeImpl
    imports VAR-LOOKUP          //for typedLookup

/*@Java API related to threads and locks. Just the core part.*/

//@ \subsection{Method Thread.start()}
rule [thread-start]:
    <thread>
      <k>
        invokeImpl(
          methodRef(sig(MethodName:Id, _), Class:ClassType),
          objectRef(OL:Int,_)::_,
          [TId:Int :: _]
        ) => nothing::void
        ...
      </k>
      ...
    </thread>

    (. =>
      <thread>
        <k>
          //typedLookup(OL).runnable.run()
          'Field(
            cast(
              class String2Id("java.lang.Thread"),
              typedLookup(OL)
            ),,
            String2Id("runnable")
          )
          .String2Id("run") (.TypedVals) ;  //method invoke, ExprStm
        </k>
        <tid> TId </tid>
        ...
      </thread>
    )
when
    Class ==K class String2Id("java.lang.Thread") andBool Id2String(MethodName) ==String "startImpl"

//@ \subsection{Synchronized statement}

// 'Synchronized(objectRef(...)::_,, Block)
syntax KLabel ::= "'Synchronized"

//evaluate the expression
context 'Synchronized(HOLE,, _)

rule [Synchronized-first-time]:
    <k>
      'Synchronized(objectRef(OId:Int,_)::_,, Block:K)
      => 'Try(Block,, [.KList],, releaseLock(OId))
      ...
    </k>
    <holds>... (. => OId |-> 1) ...</holds>
    <busy> Busy:Set (. => SetItem(OId)) </busy>
when
    notBool (OId in Busy)
        [transition-threading, transition-sync]

rule [Synchronized-nested]:
    <k>
      'Synchronized(objectRef(OId:Int,_)::_,, Block:K)
      => 'Try(Block,, [.KList],, releaseLock(OId))
      ...
    </k>
    <holds>... OId |-> (Level:Int => Level +Int 1) ...</holds>
        [transition-threading, transition-sync]

rule [Synchronized-on-null]:
    'Synchronized(null::_,,_) => throw new classNullPointerException(null::classString);

/*@Release one level of lock for the given object.*/
syntax K ::=  releaseLock ( Int )

rule [releaseLock]:
    <k>
      releaseLock(OL:Int) => .
      ...
    </k>
    <holds>... OL |-> (Level:Int => Level -Int 1) ...</holds>
        [transition-threading, transition-sync]

/*
K performance evaluation with the rule below active and commented:
  helloWorld vanilla: 22.5s
  helloWorld rule commented: 22.15s
  22_array_separated 42 tests, vanilla: 336s
  22_array_separated 42 tests, rule commented: 335s

  Conclusion: the rule below have no impact on performance.
*/
rule [monitor-completely-released]:
    <holds>... (OL:Int |-> 0 => .) ...</holds>
    <busy>... (SetItem(OL) => .) ...</busy>

//@ \subsection{Thread.join()}

rule [thread-join]:
    <k>
      invokeImpl(
        methodRef(sig(MethodName:Id, _), Class:ClassType), _,
        [TId:Int :: _]
      ) => nothing::void
      ...
    </k>
    <interrupted> false </interrupted>
    <terminated>... SetItem(TId) ...</terminated>
when
    Class ==K class String2Id("java.lang.Thread") andBool Id2String(MethodName) ==String "joinImpl"
        [transition-threading, transition-sync]

rule [thread-join-interrupted]:
    <k>
      invokeImpl(
        methodRef(sig(MethodName:Id, _), Class:ClassType), _,
        [TId:Int :: _]
      )
      => throw new class String2Id("java.lang.InterruptedException") (null::classString);
      ...
    </k>
    <interrupted> true => false </interrupted>
when
    Class ==K class String2Id("java.lang.Thread") andBool Id2String(MethodName) ==String "joinImpl"
        [transition-threading, transition-sync]

//@ \subsection{Object.wait()}

/*@When waiting, we release the lock on the OL in the cell <busy>, but don't delete this cell from <holds>.*/
rule [object-wait]:
    <k>
      invokeImpl(
        methodRef(sig(MethodName:Id, _), Class:ClassType),
        objectRef(OL:Int,_)::_, [.KList]
      ) => waitImpl(OL)
      ...
    </k>
    <tid> TId:Int </tid>
    <holds>... OL |-> HoldLevel:Int ...</holds>
    <busy>... (SetItem(OL) => .) ...</busy>
    <waitingThreads>... (. => TId |-> OL ) ...</waitingThreads>
when
            Class ==K classObject
    andBool Id2String(MethodName) ==String "wait"
    andBool HoldLevel >=Int 1
        [transition-threading, transition-sync]

rule [object-wait-notify-notifyAll-without-sync]:
    <k>
      invokeImpl(
        methodRef(sig(MethodName:Id, _), Class:ClassType),
        objectRef(OL:Int,_)::_, [.KList]
      )
      => throw new class String2Id("java.lang.IllegalMonitorStateException") (null::classString);
      ...
    </k>
    <holds> Holds:Map </holds>
when
            Class ==K classObject
    andBool (
             Id2String(MethodName) ==String "wait"
      orBool Id2String(MethodName) ==String "notify"
      orBool Id2String(MethodName) ==String "notifyAll"
    )
    andBool notBool OL in keys(Holds)

/*@Second part of a wait. Waiting was already registered to <waitingThreads>.
When the record in <waitingThreads> will be deleted, waiting itself shall end.
*/
syntax K ::=  waitImpl (
                Int //Monitor object location
              )

rule [waitImpl-end]:
    <k>
      waitImpl(OL:Int) => nothing::void
      ...
    </k>
    <tid> TId:Int </tid>
    <busy> Busy:Set (. => SetItem(OL)) </busy>
    <interrupted> false </interrupted>
    <waitingThreads> WT:Map </waitingThreads>
when
            (notBool OL in Busy)
    andBool (notBool TId in keys(WT))
        [transition-threading, transition-sync]

rule [waitImpl-interrupted]:
    <k>
      waitImpl(OL:Int) => throw new class String2Id("java.lang.InterruptedException") (null::classString);
      ...
    </k>
    <tid> TId:Int </tid>
    <busy> Busy:Set (. => SetItem(OL)) </busy>
    <interrupted> true => false </interrupted>
when
      notBool OL in Busy
        [transition-threading, transition-sync]

//@ \subsection{Object.notify(), Object.notifyAll()}

rule [object-notify]:
    <k>
      invokeImpl(
        methodRef(sig(MethodName:Id, _), Class:ClassType),
        objectRef(OL:Int,_)::_, [.KList]
      ) => objectNotifyImpl(OL)
      ...
    </k>
    <holds>... OL |-> HoldLevel:Int ...</holds>
when
            Class ==K classObject
    andBool Id2String(MethodName) ==String "notify"
    andBool HoldLevel >=Int 1

/*@Implementation of Object.notify(), extracted here to avoid rule superfluousness*/
syntax K ::=  objectNotifyImpl (
                Int //store key of the monitor object
              )

rule [objectNotifyImpl-someone-waiting]:
    <k>
      objectNotifyImpl(OL:Int) => nothing::void
      ...
    </k>
    <waitingThreads>... (_ |-> OL => .Map) ...</waitingThreads>
        [transition-threading]

rule [objectNotifyImpl-no-one-waiting]:
    <k>
      objectNotifyImpl(OL:Int) => nothing::void
      ...
    </k>
    <waitingThreads> WT:Map </waitingThreads>
when
    notBool OL in values(WT)
        [transition-threading]

rule [object-notifyAll]:
    <k>
      invokeImpl(
        methodRef(sig(MethodName:Id, _), Class:ClassType),
        objectRef(OL:Int,_)::_, [.KList]
      ) => objectNotifyAllImpl(OL)
      ...
    </k>
    <holds>... OL |-> HoldLevel:Int ...</holds>
when
            Class ==K classObject
    andBool Id2String(MethodName) ==String "notifyAll"
    andBool HoldLevel >=Int 1

/*@Implementation of Object.notifyAll(), extracted here to avoid rule superfluousness*/
syntax K ::=  objectNotifyAllImpl (
                Int //store key of the monitor object
              )

rule [objectNotifyAllImpl-someone-waiting]:
    <k>
      objectNotifyAllImpl(OL:Int)
      ...
    </k>
    <waitingThreads>... (_ |-> OL => .Map) ...</waitingThreads>
        [transition-threading]

rule [objectNotifyAllImpl-no-one-waiting]:
    <k>
      objectNotifyAllImpl(OL:Int) => nothing::void
      ...
    </k>
    <waitingThreads> WT:Map </waitingThreads>
when
    notBool OL in values(WT)
        [transition-threading]

//@ \subsection{Thread.interrupt()}

rule [thread-interrupt]:
    <thread>
      <k>
        invokeImpl(
          methodRef(sig(MethodName:Id, _), Class:ClassType),
          objectRef(OL:Int,_)::_,
          [TId:Int :: _]
        ) => nothing::void
        ...
      </k>
      ...
    </thread>

    <thread>
      <tid> TId </tid>
      <interrupted> _ => true </interrupted>
      ...
    </thread>
when
    Class ==K class String2Id("java.lang.Thread") andBool Id2String(MethodName) ==String "interruptImpl"
        [transition-threading, transition-sync]

rule [thread-interrupt-ended-thread]:
    <k>
      invokeImpl(
        methodRef(sig(MethodName:Id, _), Class:ClassType),
        objectRef(OL:Int,_)::_,
        [TId:Int :: _]
      ) => nothing::void
      ...
    </k>
    <terminated>... SetItem(TId) ...</terminated>
when
    Class ==K class String2Id("java.lang.Thread") andBool Id2String(MethodName) ==String "interruptImpl"
        [transition-threading, transition-sync]

//@ \subsection{Thread termination}

rule [ThreadTermination]:
    ( <thread>
        <k> .K </k>
        <holds> H:Map </holds>
        <tid> TId:Int </tid>
        ...
      </thread>
    => .)
    <busy> Busy:Set => Busy -Set keys(H) </busy>
    <terminated>... . => SetItem(TId) ...</terminated>
    <globalPhase> ExecutionPhase </globalPhase>
    <dissolveEmptyK> true </dissolveEmptyK>

//@ \subsection{Debug aids}

/*@ Dissolve all cells except <out> for the purpose of model checking. We will avoid duplicates caused by the same
    <out> but different order of content in other cells.*/
rule [DissolveAllExceptOut]:
    <T>
      <out> Out:List </out>
      <threads> .Bag </threads>
      <globalPhase> ExecutionPhase </globalPhase>
      <dissolveAllExceptOut> true </dissolveAllExceptOut>
      ...
    </T>
    => <T> <out> Out </out> </T>

endmodule
