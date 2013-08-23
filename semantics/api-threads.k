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
          'ListWrap(.KList)
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
            Id2String(MethodName) ==String "start"
    andBool Id2String(ThreadId) ==String "java.lang.Thread"
    andBool fresh(TId:Int)

//@ \section{Thread termination}

rule [ThreadTermination]:
    ( <thread>
        <k>.K</k>
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
