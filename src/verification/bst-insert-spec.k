require "java-verification.k"

module BST-INSERT-SPEC
  imports JAVA-VERIFICATION

rule
<threads>
<thread>
  <k>
	(class String2Id(".bst")).String2Id("insert"):Id(V:Int::int, (TP:RawRefVal)::(class String2Id(".bst")))

        =>
        ?TP1:RawRefVal::(class String2Id(".bst"))
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

  <objectStore>... tree(TP)(T:Tree) => tree(?TP1)(?T1:Tree) ...</objectStore>
requires bst(T) andBool V >=Int -2147483648 andBool V <=Int 2147483647
ensures bst(?T1) andBool tree_keys(?T1) ==K tree_keys(T) U {V}
endmodule

