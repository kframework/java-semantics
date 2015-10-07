require "java-verification.k"

module AVL-DELETE-SPEC
  imports JAVA-VERIFICATION

rule
<threads>
<thread>
  <k>
    (class String2Id(".avl")).String2Id("max"):Id(X:Int::int, Y:Int::int)
  =>
    maxInt(X, Y)::int
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

rule
<threads>
<thread>
  <k>
    (class String2Id(".avl")).String2Id("height"):Id((TP:RawRefVal)::(class String2Id(".avl")))
  =>
    tree_height(T)::int
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
  <objectStore>... htree(TP)(T:Tree) ...</objectStore>
requires avl(T) andBool tree_height(T) >=Int -2147483648 andBool tree_height(T) <=Int 2147483647


rule
<threads>
<thread>
  <k>
    (class String2Id(".avl")).String2Id("update_height"):Id((objectRef(P:Int, C:ClassType):RawRefVal)::(class String2Id(".avl")))
  =>
    nothing :: void
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
  <nextLoc> I0:Int => ?_:Int </nextLoc>
  <objectStore>... <object>
                                      <objectId>
                                          P
                                      </objectId>
                                      <objectType>
                                          C
                                      </objectType>
                                      <layer>
                                          <layerClass>
                                              C
                                          </layerClass>
                                          <layerEnv>
                                              String2Id("value") |-> I:Int :: int
                                              String2Id("height") |-> (_:Int => tree_height(node(I, TL, TR))) :: int
                                              String2Id("left") |-> PL:RawRefVal :: C
                                              String2Id("right") |-> PR:RawRefVal :: C
                                          </layerEnv>
                                          <layerEnclosingObject>
                                              noValue
                                          </layerEnclosingObject>
                                      </layer>
                                      <layer>
                                          <layerClass>
                                              class String2Id("java.lang.Object")
                                          </layerClass>
                                          <layerEnv>
                                              .Map
                                          </layerEnv>
                                          <layerEnclosingObject>
                                              noValue
                                          </layerEnclosingObject>
                                      </layer>
                                  </object>
                          htree(PL)(TL:Tree)
                          htree(PR)(TR:Tree)
                          ...
                           </objectStore>
requires avl(TL) andBool avl(TR) andBool tree_height(node(I, TL, TR)) >=Int -2147483648 andBool tree_height(node(I, TL, TR)) <=Int 2147483647

rule
<threads>
<thread>
  <k>
	(class String2Id(".avl")).String2Id("find_min"):Id((TP:RawRefVal)::(class String2Id(".avl")))
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
<objectStore>... htree(TP)(T:Tree)  ...</objectStore>

requires avl(T) andBool TP =/=K null
ensures (?M inIntSet tree_keys(T)) andBool ({ ?M } <=IntSet tree_keys(T)) andBool ?M >=Int -2147483648 andBool ?M <=Int 2147483647

rule
<threads>
<thread>
  <k>
	(class String2Id(".avl")).String2Id("delete"):Id(V:Int::int, (TP:RawRefVal)::(class String2Id(".avl")))
        =>
        ?TP1:RawRefVal::(class String2Id(".avl"))
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
<objectStore>... (htree(TP)(T:Tree) => htree(?TP1)(?T1:Tree)) (.Bag => ?_:Bag) ...</objectStore>

requires avl(T) andBool V >=Int -2147483648 andBool V <=Int 2147483647
ensures avl(?T1) andBool tree_keys(?T1) ==K tree_keys(T) -IntSet {V}
  andBool tree_height(T) -Int 1 <=Int tree_height(?T1)
  andBool tree_height(?T1) <=Int tree_height(T)
endmodule

