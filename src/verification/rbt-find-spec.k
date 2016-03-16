require "java-verification.k"

module RBT-FIND-SPEC
  imports JAVA-VERIFICATION

rule

<threads>
<thread>
  <k>
	(class String2Id(".rbt")).String2Id("find"):Id(V:Int::int, (TP:RawRefVal)::(class String2Id(".rbt")))
        =>
        ?B:Bool::bool
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

  <objectStore>... ctree(TP)(T:CTree) ...</objectStore>
requires rbt(T) andBool V >=Int -2147483648 andBool V <=Int 2147483647
ensures (?B) ==K (V inIntSet ctree_keys(T))
endmodule

