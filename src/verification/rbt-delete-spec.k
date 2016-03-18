require "java-verification.k"

module RBT-INSERT-SPEC
  imports JAVA-VERIFICATION
//proved
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
//proved
rule
<threads>
<thread>
  <k>
	(class String2Id(".rbt")).String2Id("find_min"):Id((TP:RawRefVal)::(class String2Id(".rbt")))

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

  <objectStore>... ctree(TP)(T:CTree)  ...</objectStore>
requires rbt(T) andBool TP =/=K null
ensures (?M inIntSet ctree_keys(T)) andBool ({ ?M } <=IntSet ctree_keys(T)) andBool ?M >=Int -2147483648 andBool ?M <=Int 2147483647

rule
<threads>
<thread>
  <k>
	(class String2Id(".rbt")).String2Id("left_remove_fixup"):Id(objectRef(?P1:Int, class String2Id(".rbt"))::(class String2Id(".rbt")))
        =>
        objectRef(?P2:Int, class String2Id(".rbt"))::(class String2Id(".rbt"))
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
<objectStore>... (                                  <object>
                                                       <objectId>
                                                           ?P1
                                                       </objectId>
                                                       <objectType>
                                                           class String2Id(".rbt")
                                                       </objectType>
                                                       <layer>
                                                           <layerClass>
                                                               class String2Id(".rbt")
                                                           </layerClass>
                                                           <layerEnv>
                                                               String2Id("value") |-> I1:Int :: int
                                                               String2Id("color") |-> C1:Int :: int
                                                               String2Id("left") |-> L1:RawRefVal :: class String2Id(".rbt")
                                                               String2Id("right") |-> objectRef(R1:Int, class String2Id(".rbt")) :: class String2Id(".rbt")
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
                                                              <object>
                                                                  <objectId>
                                                                      R1
                                                                  </objectId>
                                                                  <objectType>
                                                                      class String2Id(".rbt")
                                                                  </objectType>
                                                                  <layer>
                                                                      <layerClass>
                                                                          class String2Id(".rbt")
                                                                      </layerClass>
                                                                      <layerEnv>
                                                                          String2Id("value") |-> RT1:Int :: int
                                                                          String2Id("color") |-> RC1:Int :: int
                                                                          String2Id("left") |-> RL1:RawRefVal :: class String2Id(".rbt")
                                                                          String2Id("right") |-> RR1:RawRefVal :: class String2Id(".rbt")
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
                                                   ctree(L1)(TL1:CTree)
                                                   ctree(RL1)(TRL1:CTree)
                                                   ctree(RR1)(TRR1:CTree)
 =>
                                  <object>
                                      <objectId>
                                          ?P2
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
//not finished
endmodule

