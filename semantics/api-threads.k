require "core.k"
require "method-invoke.k"

//@ \section{Module API-THREADS}

module API-THREADS
    imports CORE
    imports METHOD-INVOKE

/*@Java API related to threads and locks. Just the core part.*/

//@ \subsection{Method Thread.start()}
rule [thread-start]:
    <thread>
      <k>
        invokeImpl(
          methodClosure(ThreadClass:ClassType,_,_,_,_,_, 'NoMethodBody(_))::methodType(sig(MethodName:Id, _),_),
          OL:Int,
          'ListWrap(TId:Int :: _)
        ) => nothing::void
        ...
      </k>
      ...
    </thread>

    (. =>
      <thread>
        <k>
          //typedLookup(OL).runnable.run()
          elab('ExprStm(
            'Invoke(
              'Method(
                'MethodName(
                  'ExprName(
                    elabRes(cast(class String2Id("java.lang.Thread"), typedLookup(OL))),,
                    String2Id("runnable")
                  ),,
                  String2Id("run")
                )
              ),,
              'ListWrap(.KList)
            )
          ))
        </k>
        <tid> TId </tid>
        ...
      </thread>
    )
when
            Id2String(MethodName) ==String "startImpl"
    andBool ThreadClass ==K class String2Id("java.lang.Thread")

//@ \subsection{Synchronized statement}

//evaluate the expression
context 'Synchronized(HOLE,, _)

rule [Synchronized-first-time]:
    <k>
      'Synchronized(objectClosure(OL:Int,_,_),, Block:K)
      => 'Try(Block,, 'ListWrap(.KList),, releaseLock(OL))
      ...
    </k>
    <holds>... (. => OL |-> 1) ...</holds>
    <busy> Busy:Set (. => SetItem(OL)) </busy>
when
    notBool (OL in Busy)
        [transition-threading]

rule [Synchronized-nested]:
    <k>
      'Synchronized(objectClosure(OL:Int,_,_),, Block:K)
      => 'Try(Block,, 'ListWrap(.KList),, releaseLock(OL))
      ...
    </k>
    <holds>... OL |-> (Level:Int => Level +Int 1) ...</holds>
        [transition-threading]

rule [Synchronized-on-null]:
    'Synchronized(null::_,,_)
    =>  elab('Throw('NewInstance(
          'None(.KList),,
          class String2Id("java.lang.NullPointerException"),,
          'ListWrap( null ),,
          'None(.KList)
        )))

/*@Release one level of lock for the given object.*/
syntax K ::= releaseLock ( Int )

rule [releaseLock]:
    <k>
      releaseLock(OL:Int) => .
      ...
    </k>
    <holds>... OL |-> (Level:Int => Level -Int 1) ...</holds>
        [transition-threading]

//todo investigate performance impact if we eliminate this rule
rule [monitor-completely-released]:
    <holds>... (OL:Int |-> 0 => .) ...</holds>
    <busy>... (SetItem(OL) => .) ...</busy>

rule [synchronized-method-inst-desugar]:
    storeMethod(_, instanceCT, _, (true => false)::bool, _,_,
        Body:K => 'Synchronized('This(.KList),, Body),
        _)

rule [synchronized-method-static-desugar]:
    <k>
      storeMethod(_, staticCT, _, (true => false)::bool, _,_,
          Body:K => 'Synchronized(elab('Lit('Class(Class))),, Body),
          _)
      ...
    </k>
    <crntClass> Class:ClassType </crntClass>

//@ \subsection{Thread.join()}

rule [thread-join]:
    <k>
      invokeImpl(
        methodClosure(Class:ClassType,_,_,_,_,_, 'NoMethodBody(_))::methodType(sig(MethodName:Id, _),_), _,
        'ListWrap(TId:Int :: _)
      ) => nothing::void
      ...
    </k>
    <interrupted> false </interrupted>
    <terminated>... SetItem(TId) ...</terminated>
when
            Class ==K class String2Id("java.lang.Thread")
    andBool Id2String(MethodName) ==String "joinImpl"
        [transition-threading]

rule [thread-join-interrupted]:
    <k>
      invokeImpl(
        methodClosure(Class:ClassType,_,_,_,_,_, 'NoMethodBody(_))::methodType(sig(MethodName:Id, _),_), _,
        'ListWrap(TId:Int :: _)
      )
      =>  elab('Throw('NewInstance(
            'None(.KList),,
            class String2Id("java.lang.InterruptedException"),,
            'ListWrap( null ),,
            'None(.KList)
          )))
      ...
    </k>
    <interrupted> true => false </interrupted>
when
            Class ==K class String2Id("java.lang.Thread")
    andBool Id2String(MethodName) ==String "joinImpl"
        [transition-threading]

//@ \subsection{Object.wait()}

/*@When waiting, we release the lock on the OL in the cell <busy>, but don't delete this cell from <holds>.*/
rule [object-wait]:
    <k>
      invokeImpl(
        methodClosure(Class:ClassType,_,_,_,_,_, 'NoMethodBody(_))::methodType(sig(MethodName:Id, _),_),
        OL:Int, 'ListWrap(.KList)
      ) => waitImpl(OL)
      ...
    </k>
    <tid> TId:Int </tid>
    <holds>... OL |-> HoldLevel:Int ...</holds>
    <busy>... (SetItem(OL) => .) ...</busy>
    <waitingThreads>... (. => TId |-> OL ) ...</waitingThreads>
when
            Class ==K class String2Id("java.lang.Object")
    andBool Id2String(MethodName) ==String "wait"
    andBool HoldLevel >=Int 1
        [transition-threading]

rule [object-wait-notify-notifyAll-without-sync]:
    <k>
      invokeImpl(
        methodClosure(Class:ClassType,_,_,_,_,_, 'NoMethodBody(_))::methodType(sig(MethodName:Id, _),_),
        OL:Int, 'ListWrap(.KList)
      )
      =>  elab('Throw('NewInstance(
            'None(.KList),,
            class String2Id("java.lang.IllegalMonitorStateException"),,
            'ListWrap( null ),,
            'None(.KList)
          )))
      ...
    </k>
    <holds> Holds:Map </holds>
when
            Class ==K class String2Id("java.lang.Object")
    andBool (
             Id2String(MethodName) ==String "wait"
      orBool Id2String(MethodName) ==String "notify"
      orBool Id2String(MethodName) ==String "notifyAll"
    )
    andBool notBool OL in keys(Holds)

/*@Second part of a wait. Waiting was already registered to <waitingThreads>.
When the record in <waitingThreads> will be deleted, waiting itself shall end.
*/
syntax K ::= waitImpl ( Int ) //Monitor object location

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
        [transition-threading]

rule [waitImpl-interrupted]:
    <k>
      waitImpl(OL:Int)
      =>  elab('Throw('NewInstance(
            'None(.KList),,
            class String2Id("java.lang.InterruptedException"),,
            'ListWrap( null ),,
            'None(.KList)
          )))
      ...
    </k>
    <tid> TId:Int </tid>
    <busy> Busy:Set (. => SetItem(OL)) </busy>
    <interrupted> true => false </interrupted>
when
      notBool OL in Busy
        [transition-threading]

//@ \subsection{Object.notify(), Object.notifyAll()}

rule [object-notify]:
    <k>
      invokeImpl(
        methodClosure(Class:ClassType,_,_,_,_,_, 'NoMethodBody(_))::methodType(sig(MethodName:Id, _),_),
        OL:Int, 'ListWrap(.KList)
      ) => objectNotifyImpl(OL)
      ...
    </k>
    <holds>... OL |-> HoldLevel:Int ...</holds>
when
            Class ==K class String2Id("java.lang.Object")
    andBool Id2String(MethodName) ==String "notify"
    andBool HoldLevel >=Int 1

/*@Implementation of Object.notify(), extracted here to avoid rule superfluousness*/
syntax K ::= objectNotifyImpl ( Int //store key of the monitor object
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
        methodClosure(Class:ClassType,_,_,_,_,_, 'NoMethodBody(_))::methodType(sig(MethodName:Id, _),_),
        OL:Int, 'ListWrap(.KList)
      ) => objectNotifyAllImpl(OL)
      ...
    </k>
    <holds>... OL |-> HoldLevel:Int ...</holds>
when
            Class ==K class String2Id("java.lang.Object")
    andBool Id2String(MethodName) ==String "notifyAll"
    andBool HoldLevel >=Int 1

/*@Implementation of Object.notifyAll(), extracted here to avoid rule superfluousness*/
syntax K ::= objectNotifyAllImpl ( Int //store key of the monitor object
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
          methodClosure(Class:ClassType,_,_,_,_,_, 'NoMethodBody(_))::methodType(sig(MethodName:Id, _),_),
          OL:Int,
          'ListWrap(TId:Int :: _)
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
            Class ==K class String2Id("java.lang.Thread")
    andBool Id2String(MethodName) ==String "interruptImpl"
        [transition-threading]

rule [thread-interrupt-ended-thread]:
    <k>
      invokeImpl(
        methodClosure(Class:ClassType,_,_,_,_,_, 'NoMethodBody(_))::methodType(sig(MethodName:Id, _),_),
        OL:Int,
        'ListWrap(TId:Int :: _)
      ) => nothing::void
      ...
    </k>
    <terminated>... SetItem(TId) ...</terminated>
when
            Class ==K class String2Id("java.lang.Thread")
    andBool Id2String(MethodName) ==String "interruptImpl"

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
     <globalPhase> ExecutionPhase  </globalPhase>
    <dissolveEmptyK> true </dissolveEmptyK>

//@ \subsection{Debug aids}

/*@Dissolves classes cell so that configuration is not over-bloated, at the end of the execution.*/
rule [DissolveClasses]:
    (<classes> _:Bag </classes> => .)
    (<phTN> _:Bag </phTN> => .)
    (<phCU> _:Bag </phCU> => .)
    <threads> .Bag </threads>
    <globalPhase> ExecutionPhase  </globalPhase>
    <dissolveClasses> true </dissolveClasses>

/*@Dissolve all cells except <out> for the purpose of model checking. We will avoid duplicates caused by the same <out> but different order of content in other cells.*/
rule [DissolveAllExceptOut]:
    <T>
      <out> Out:List </out>
      <threads> .Bag </threads>
       <globalPhase> ExecutionPhase  </globalPhase>
      <dissolveAllExceptOut> true </dissolveAllExceptOut>
      ...
    </T>
    => <T> <out> Out </out> </T>

endmodule
