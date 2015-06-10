require "java-verification.k"
module INSERTION-SORT-SPEC
  imports JAVA-VERIFICATION

rule [insertion-sort-loop-inv1]:
  <threads>
          <thread>
  <k>
    while (x != NULL) {
      struct listNode* n;

      n = x;
      x = x->next;
      n->next = NULL;
      if (y != NULL) {
        if (y->val < n->val) {
          struct listNode* z;

          z = y;
          while (z->next != NULL && z->next->val < n->val) {
            z = z->next;
          }

          n->next = z->next;
          z->next = n;
        }
        else {
          n->next = y;
          y = n;
        }
      }
      else {
        y = n;
      }
    }
  =>
    .K
  ...</k>
  <env> ... (.Map => ?_:Map)
      String2Id("x") |-> LX:Int
      String2Id("y") |-> LY:Int
    ... </env>
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

                      LY |-> (Y1:RawRefVal => ?Y2:RawRefVal) :: class String2Id(".listNode")

            ...</store>
            <storeMetadata> ... (.Map => ?_:Map)
                    LX |-> LocalLocMetadata
                    LY |-> LocalLocMetadata
            ... </storeMetadata>
                  <busy> .Set </busy>
                  <nextLoc> I:Int => ?_:Int </nextLoc>

                    <objectStore>... (.Bag => ?_:Bag)
      (lseg(Y1, null)(A1:List)
     lseg(X, null)(B:List)
     =>
     lseg(?Y2, null)(?A2:List))
 ...</objectStore>
requires sorted(A1)
ensures sorted(?A2) andBool list2set(A1) U list2set(B) ==K list2set(?A2)

rule [insertion-sort-loop-inv2]:
  <threads>
          <thread>
    <k>
    while (z->next != NULL && z->next->val < n->val) {
      z = z->next;
    }
    ~>
    n->next = z->next;
    z->next = n;
    .Statements
  =>
    .K
  ...</k>
  <env>... (.Map => ?_:Map)
                String2Id("x") |-> _
                String2Id("n") |-> LN:Int
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
                LY |-> Y:RawRefVal :: class String2Id(".listNode")
                LZ |-> (objectRef(Z:Int, class String2Id(".listNode")) => ?_:RawRefVal) :: class String2Id(".listNode")
                LZ |-> objectRef(N:Int, class String2Id(".listNode")) :: class String2Id(".listNode")
                  ...</store>
        <storeMetadata> ... (.Map => ?_:Map)
          LN |-> LocalLocMetadata
          LY |-> LocalLocMetadata
          LZ |-> LocalLocMetadata
           ... </storeMetadata>
        <busy> .Set </busy>
        <nextLoc> I:Int => ?_:Int </nextLoc>

   <objectStore>... (.Bag => ?_:Bag)
    (<object>
                                 <objectId>
                                     Z
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
                        next |-> P:RawRefVal :: class String2Id(".listNode")
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
                                    N
                                </objectId>
                                <objectType>
                                    class String2Id(".listNode")
                                </objectType>
                                <layer>
                                    <layerClass>
                                        class String2Id(".listNode")
                                    </layerClass>
                                    <layerEnv>
                       val |-> NV:Int :: int
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

     lseg(Y, objectRef(Z:Int, class String2Id(".listNode")))(A1:List)
     lseg(P, null)(B:List)
     =>
     lseg(Y, null)(?A2:List))
 ...</objectStore>
requires sorted(A1 ListItem(V) B) andBool V <Int NV andBool V >=Int -2147483648 andBool NV <=Int 2147483647
ensures sorted(?A2)
  andBool list2set(A1) U list2set(B) U { V } U { NV } ==K list2set(?A2)

rule [insertion-sort-func-spec]:
  <threads>
  <thread>
    <k>
  	(class String2Id(".listNode")).String2Id("insertion_sort"):Id((X1:RawRefVal)::(class String2Id(".listNode")))
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
    <objectStore>... (lseg(X1, null)(A1:List) => lseg(?X2, null)(?A2:List)) (.Bag => ?_:Bag)...</objectStore>
ensures sorted(?A2) andBool list2set(A1) ==K list2set(?A2)

endmodule

