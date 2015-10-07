require "java-verification.k"

module BST-DELETE-SPEC
  imports JAVA-VERIFICATION

rule

<threads>
<thread>
  <k>
	(class String2Id(".bst")).String2Id("delete"):Id(V:Int::int, (TP:RawRefVal)::(class String2Id(".bst")))

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
<busy> .Set </busy>
<nextLoc> I:Int => ?_:Int </nextLoc>

  <objectStore>... (tree(TP)(T:Tree) => tree(?TP1)(?T1:Tree)) (.Bag => ?_:Bag) ...</objectStore>
requires bst(T) andBool V >=Int -2147483648 andBool V <=Int 2147483647
ensures bst(?T1) andBool tree_keys(?T1) ==K tree_keys(T) -IntSet {V}

rule
<threads>
<thread>
  <k>
	(class String2Id(".bst")).String2Id("find_min"):Id((TP:RawRefVal)::(class String2Id(".bst")))

        =>
        ?M:Int::int
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

  <objectStore>... tree(TP)(T:Tree)  ...</objectStore>
requires bst(T) andBool TP =/=K null
ensures (?M inIntSet tree_keys(T)) andBool ({ ?M } <=IntSet tree_keys(T)) andBool ?M >=Int -2147483648 andBool ?M <=Int 2147483647
endmodule

