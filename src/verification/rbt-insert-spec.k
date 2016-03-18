require "java-verification.k"

module RBT-INSERT-SPEC
  imports JAVA-VERIFICATION
//only color rule got proved
rule
<threads>
<thread>
  <k>
    (class String2Id(".rbt")).String2Id("color"):Id((TP:RawRefVal)::(class String2Id(".rbt")))
  =>
    ctree_color(T)::int
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
ensures ctree_color(T) ==K 1 orBool ctree_color(T) ==K 0

rule
<threads>
<thread>
  <k>
    (class String2Id(".rbt")).String2Id("insert_aux"):Id(V:Int::int, (TP1:RawRefVal)::(class String2Id(".rbt")))
  =>
    objectRef(?P:Int, class String2Id(".rbt"))::(class String2Id(".rbt"))
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
  <objectStore>... (ctree(TP1)(T1:CTree) =>
                                  <object>
                                      <objectId>
                                          ?P
                                      </objectId>
                                      <objectType>
                                          class String2Id(".rbt")
                                      </objectType>
                                      <layer>
                                          <layerClass>
                                              class String2Id(".rbt")
                                          </layerClass>
                                          <layerEnv>
                                              String2Id("value") |-> ?I2:Int :: int
                                              String2Id("color") |-> ?C2:Int :: int
                                              String2Id("left") |-> ?L2:RawRefVal :: class String2Id(".rbt")
                                              String2Id("right") |-> ?R2:RawRefVal :: class String2Id(".rbt")
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
                          ctree(?L2)(?TL2:CTree)
                          ctree(?R2)(?TR2:CTree)
                       ) (.Bag => ?_:Bag)
...</objectStore>
requires rbt(T1) andBool V >=Int -2147483648 andBool V <=Int 2147483647
ensures rbt(?TL2) andBool rbt(?TR2)
  andBool ctree_keys(?TL2) <IntSet { ?I2 } andBool { ?I2 } <IntSet ctree_keys(?TR2)
  andBool ctree_height(?TL2) ==Int ctree_height(?TR2)
  andBool ( ?C2 ==K 1 orBool ?C2 ==K 0 )
  andBool (
            ?C2 ==K 1
          orBool
            (
              ( ctree_color(?TL2) ==K 1 andBool ctree_color(?TR2) ==K 1 )
            orBool
              (
                ctree_color(T1) =/=K 1
              andBool
                ( ctree_color(?TL2) ==K 1 orBool ctree_color(?TR2) ==K 1 )
              )
            )
          )
  andBool ctree_keys(cnode(?I2, ?C2, ?TL2, ?TR2)) ==K {V} U ctree_keys(T1)
  andBool ctree_height(T1) ==Int ctree_height(cnode(?I2, ?C2, ?TL2, ?TR2))

rule
<threads>
<thread>
  <k>
	(class String2Id(".rbt")).String2Id("insert"):Id(V:Int::int, (TP:RawRefVal)::(class String2Id(".rbt")))

        =>
        ?TP1:RawRefVal::(class String2Id(".rbt"))
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

  <objectStore>... ctree(TP)(T:CTree) => ctree(?TP1)(?T1:CTree) ...</objectStore>
requires rbt(T) andBool V >=Int -2147483648 andBool V <=Int 2147483647 andBool ctree_height(T) >=Int -2147483648 andBool ctree_height(T) <=Int 2147483646
ensures rbt(?T1) andBool ctree_keys(?T1) ==K ctree_keys(T) U {V}
  andBool ctree_height(T) <=Int ctree_height(?T1)
  andBool ctree_height(?T1) <=Int ctree_height(T) +Int 1
  andBool ctree_height(?T1) >=Int -2147483648 andBool ctree_height(?T1) <=Int 2147483647
endmodule

