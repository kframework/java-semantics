require "java-verification.k"

module MIN-SPEC
  imports JAVA-VERIFICATION

rule

<threads>
<thread>
  <k>
 (class String2Id(".min")).String2Id("min"):Id(X:Int::int, Y:Int::int)
  =>
    minInt(X,Y)::int
  ...</k>
<holds> .Map </holds>
...
</thread>
</threads>

<classes> CLASSES:Bag </classes>
<NumOfClassesToUnfold> 0 </NumOfClassesToUnfold>
<program> .K </program>
<globalPhase> ExecutionPhase </globalPhase>
<store>... .Map => ?_:Map ...</store>
<busy> .Set </busy>
<nextLoc> I:Int => ?_:Int </nextLoc>
requires X >=Int -2147483648 andBool X <=Int 2147483647 andBool Y >=Int -2147483648 andBool Y <=Int 2147483647

endmodule



