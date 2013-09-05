require "core.k"
require "method-invoke.k"

module API-THREADS
    imports CORE
    imports METHOD-INVOKE

//Java API related to threads and locks. Just the core part.

rule [thread-start]:
    <thread>
      <k>
        invokeImpl(
          methodClosure(class ThreadId,_,_,_,_,_, 'NoMethodBody(_))::methodType(sig(MethodName:Id, _),_),
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
          'ExprStm(
            'Invoke(
              'Method(
                'MethodName(
                  'AmbName(
                    lookup(OL) :: class String2Id("java.lang.Thread"),,
                    String2Id("runnable")
                  ),,
                  String2Id("run")
                )
              ),,
              'ListWrap(.KList)
            )
          )
        </k>
        <tid> TId </tid>
        ...
      </thread>
    )
when
            Id2String(MethodName) ==String "startImpl"
    andBool Id2String(ThreadId) ==String "java.lang.Thread"

//@ \section{Synchronized}

//evaluate the expression
context 'Synchronized(HOLE,, _)

rule [Synchronized-first-time]:
    <k>
      'Synchronized(objectClosure(OL:Int,_,_)::_,, Block:K)
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
      'Synchronized(objectClosure(OL:Int,_,_)::_,, Block:K)
      => 'Try(Block,, 'ListWrap(.KList),, releaseLock(OL))
      ...
    </k>
    <holds>... OL |-> (Level:Int => Level +Int 1) ...</holds>
        [transition-threading]

//Release one level of lock for the given object
syntax K ::= "releaseLock" "(" Int ")"

rule [releaseLock]:
    <k>
      releaseLock(OL:Int) => .
      ...
    </k>
    <holds>... OL |-> (Level:Int => Level -Int 1) ...</holds>
        [transition-threading]

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
          Body:K => 'Synchronized('Lit('Class(Class)),, Body),
          _)
      ...
    </k>
    <crntClass> Class:ClassType </crntClass>

//@ \section{Threading related methods}

rule [thread-join]:
    <k>
      invokeImpl(
        methodClosure(Class:ClassType,_,_,_,_,_, 'NoMethodBody(_))::methodType(sig(MethodName:Id, _),_), _,
        'ListWrap(TId:Int :: _)
      ) => nothing::void
      ...
    </k>
    <terminated>... SetItem(TId) ...</terminated>
when
            Class ==K class String2Id("java.lang.Thread")
    andBool Id2String(MethodName) ==String "joinImpl"
        [transition-threading]

//@ \section{Thread termination}

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
    <computationPhase> ExecutionPhase </computationPhase>
    <dissolveEmptyK> true </dissolveEmptyK>

//Debug aid. Dissolves classes cell so that configuration is not overbloated, at the end
//of the execution.
rule [DissolveClasses]:
    (<classes> _:Bag </classes> => .)
    <threads> .Bag </threads>
    <computationPhase> ExecutionPhase </computationPhase>
    <dissolveClasses> true </dissolveClasses>

//Debug aid. Dissolve all cells except <out> for the purpose of model checking.
//We will avoid duplicates caused by the same <out> but different order of content in other
//cells.
rule [DissolveAllExceptOut]:
    <T>
      <out> Out:List </out>
      <threads> .Bag </threads>
      <computationPhase> ExecutionPhase </computationPhase>
      <dissolveAllExceptOut> true </dissolveAllExceptOut>
      ...
    </T>
    => <T> <out> Out </out> </T>

endmodule
