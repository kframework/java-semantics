require "java-verification.k"

module AVL-FIND-SPEC
  imports JAVA-VERIFICATION

rule

<threads>
<thread>
  <k>
	(class String2Id(".avl")).String2Id("find"):Id(V:Int::int, (TP:RawRefVal)::(class String2Id(".avl")))

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
<storeMetadata> ... .Map => ?_:Map ... </storeMetadata>
<busy> .Set </busy>
<nextLoc> I:Int => ?_:Int </nextLoc>

  <objectStore>... htree(TP)(T:Tree) ...</objectStore>
requires avl(T) andBool V >=Int -2147483648 andBool V <=Int 2147483647
ensures (?B) ==K (V inIntSet tree_keys(T))
endmodule

