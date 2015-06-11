require "java-verification.k"
module QUICKSORT-SPEC
  imports JAVA-VERIFICATION

//copy append-spec code here
rule [append-loop-inv]:
  <threads>
    <thread>
  <k>
                    whileImpl ( cast ( bool , cast ( class String2Id(".listNode") , cast (
                      class String2Id(".listNode") , cast ( class String2Id(".listNode") , 'ExprName(String2Id("p")) ) ) . String2Id("next") )
                      != null :: nullType ) , { cast ( class String2Id(".listNode") , ('ExprName(String2Id("p")) =
                      cast ( class String2Id(".listNode") , cast ( class String2Id(".listNode") , cast (
                      class String2Id(".listNode") , 'ExprName(String2Id("p")) ) ) . String2Id("next") ))::AssignExp ) ; } )
  =>
    .K
  ...</k>
  <env>... (.Map => ?_:Map)
      String2Id("x") |-> LX:Int
      String2Id("p") |-> LP:Int
    ...</env>
  <holds> .Map </holds>
    ...
    </thread>
    </threads>

    <classes> CLASSES:Bag </classes>
    <NumOfClassesToUnfold> 0 </NumOfClassesToUnfold>
    <program> .K </program>
     <globalPhase> ExecutionPhase </globalPhase>
      <store>... (.Map => ?_:Map)
      LX |-> X:RawRefVal :: class String2Id(".listNode")
      LP |-> (objectRef(P1:Int, class String2Id(".listNode")) => objectRef(?P2:Int, class String2Id(".listNode"))) :: class String2Id(".listNode")
          ...</store>
    <storeMetadata> ... (.Map => ?_:Map)
      LX |-> LocalLocMetadata
      LP |-> LocalLocMetadata
       ... </storeMetadata>
    <busy> .Set </busy>
    <nextLoc> I:Int => ?_:Int </nextLoc>

      <objectStore>...
    (lseg(X, objectRef(P1, class String2Id(".listNode")))(A:List)
     lseg(objectRef(P1, class String2Id(".listNode")), null)(B:List)
     =>
     lseg(X, objectRef(?P2, class String2Id(".listNode")))(?AB:List)
     <object>
                            <objectId>
                                ?P2
                            </objectId>
                            <objectType>
                                class String2Id(".listNode")
                            </objectType>
                            <layer>
                                <layerClass>
                                    class String2Id(".listNode")
                                </layerClass>
                                <layerEnv>
                   val |-> ?E:Int :: int
                   next |-> null :: class String2Id(".listNode")
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
                           </object>)
  ...</objectStore>
ensures A B ==K ?AB ListItem(?E) andBool ?E >=Int -2147483648 andBool ?E <=Int 2147483647

rule [append-func-spec]:
  <threads>
  <thread>
    <k>
  	(class String2Id(".listNode")).String2Id("append"):Id((X:RawRefVal)::(class String2Id(".listNode")), (Y:RawRefVal)::(class String2Id(".listNode")))
          =>
          ?P:RawRefVal::(class String2Id(".listNode"))
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

    <objectStore>... (lseg(X, null)(A:List) lseg(Y, null)(B:List) => lseg(?P, null)(A B)) ...</objectStore>

rule [quick-loop-inv]:
  <threads>
       <thread>
  <k>
    while(x != NULL) {
      struct listNode* t;

      t = x;
      x = x->next;
      if (t->val < p->val) {
        t->next = y;
        y = t;
      }
      else {
        t->next = z;
        z = t;
      }
    }
  =>
    .K
  ...</k>
  <env>... (.Map => ?_:Map)
              String2Id("x") |-> LX:Int
              String2Id("p") |-> LP:Int
              String2Id("y") |-> LY:Int
              String2Id("z") |-> LZ:Int
      ...</env>
  <holds> .Map </holds>
            ...
            </thread>
            </threads>

            <classes> CLASSES:Bag </classes>
            <NumOfClassesToUnfold> 0 </NumOfClassesToUnfold>
            <program> .K </program>
             <globalPhase> ExecutionPhase </globalPhase>
              <store>... (.Map => ?_:Map)
              LX |-> ( X:RawRefVal => null ) :: class String2Id(".listNode")
              LP |-> objectRef(P:Int, class String2Id(".listNode")) :: class String2Id(".listNode")
            LY |-> (Y1:RawRefVal => ?Y2:RawRefVal) :: class String2Id(".listNode")
            LZ |-> (Z1:RawRefVal => ?Z2:RawRefVal) :: class String2Id(".listNode")
  ...</store>
      <storeMetadata> ... (.Map => ?_:Map)
        LX |-> LocalLocMetadata
        LP |-> LocalLocMetadata
        LY |-> LocalLocMetadata
        LZ |-> LocalLocMetadata
         ... </storeMetadata>
      <busy> .Set </busy>
      <nextLoc> I:Int => ?_:Int </nextLoc>

        <objectStore>...
        <object>
                                    <objectId>
                                        P
                                    </objectId>
                                    <objectType>
                                        class String2Id(".listNode")
                                    </objectType>
                                    <layer>
                                        <layerClass>
                                            class String2Id(".listNode")
                                        </layerClass>
                                        <layerEnv>
                           val |-> V:Int :: int
                           next |-> null :: class String2Id(".listNode")
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

    (lseg(X, null)(A:List)
     lseg(Y1, null)(B1:List)
     lseg(Z1, null)(C1:List)
     =>
     lseg(?Y2, null)(?B2:List)
     lseg(?Z2, null)(?C2:List))
 ...</objectStore>
requires list2set(B1) <=IntSet { V } andBool { V } <=IntSet list2set(C1) andBool V >=Int -2147483648 andBool V <=Int 2147483647
ensures list2set(?B2) <=IntSet { V } andBool { V } <=IntSet list2set(?C2)
  andBool list2set(A) U list2set(B1) U list2set(C1) ==K list2set(?B2) U list2set(?C2)

rule [quicksort-func-spec]:
  <threads>
  <thread>
    <k>
  	(class String2Id(".listNode")).String2Id("quicksort"):Id((X1:RawRefVal)::(class String2Id(".listNode")))
          =>
          ?X2:RawRefVal::(class String2Id(".listNode"))
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
    <objectStore>... (lseg(X1, null)(A1:List) => lseg(?X2, null)(?A2:List)) ...</objectStore>
ensures sorted(?A2) andBool list2set(A1) ==K list2set(?A2)

endmodule

