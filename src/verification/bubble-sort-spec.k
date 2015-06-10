require "java-verification.k"
module BUBBLE-SORT-SPEC
  imports JAVA-VERIFICATION

rule [bubble-sort-loop-inv1]:
   <threads>
        <thread>
  <k>
    while (change) {
      struct listNode* y;

      change = 0;
      y = x;
      while (y->next != NULL) {
        if (y->val > y->next->val) {
          int temp;

          change = 1;
          temp = y->val;
          y->val = y->next->val;
          y->next->val = temp;
        }
        y = y->next;
      }
    }
  =>
    .K
  ...</k>
    <env> ... (.Map => ?_:Map)
      String2Id("x") |-> LX:Int
      String2Id("change") |-> LC:Int
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
            LX |-> X:RawRefVal :: class String2Id(".listNode")
            LC |-> (C:Int => ?_:Int) :: int
            ...</store>
                <storeMetadata> ... (.Map => ?_:Map)
                  LX |-> LocalLocMetadata
                  LC |-> LocalLocMetadata
                   ... </storeMetadata>
                <busy> .Set </busy>
                <nextLoc> I:Int => ?_:Int </nextLoc>
      <objectStore>... (.Bag => ?_:Bag)
      (lseg(X, null)(A1:List)
     =>
     lseg(X, null)(?A2:List))
 ...</objectStore>
requires X =/=K null andBool (sorted(A1) orBool C =/=K 0)
ensures sorted(?A2) andBool list2set(A1) ==K list2set(?A2)

rule [bubble-sort-loop-inv2]:
  <threads>
      <thread>
  <k>
    while (y->next != NULL) {
      if (y->val > y->next->val) {
        int temp;

        change = 1;
        temp = y->val;
        y->val = y->next->val;
        y->next->val = temp;
      }
      y = y->next;
    }
  =>
    .K
  ...</k>

  <env> ... (.Map => ?_:Map)
    String2Id("x") |-> LX:Int
    String2Id("y") |-> LY:Int
    String2Id("change") |-> LC:Int
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
        LX |-> X:RawRefVal :: class String2Id(".listNode")
        LY |-> (objectRef(Y1:Int, class String2Id(".listNode")) => objectRef(?P2:Int, class String2Id(".listNode"))) :: class String2Id(".listNode")
        LC |-> (C1:Int => ?C2:Int) :: int
        ...</store>
            <storeMetadata> ... (.Map => ?_:Map)
              LX |-> LocalLocMetadata
              LY |-> LocalLocMetadata
              LC |-> LocalLocMetadata
               ... </storeMetadata>
            <busy> .Set </busy>
            <nextLoc> I:Int => ?_:Int </nextLoc>
  <objectStore>... (.Bag => ?_:Bag)
  (<object>
                              <objectId>
                                  Y1
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
     lseg(X, objectRef(Y1, class String2Id(".listNode")))(A1:List)
     lseg(P, null)(B:List)
     =>
     lseg(X, null)(?A2:List))
 ...</objectStore>
requires (sorted(A1 ListItem(V)) orBool C1 =/=K 0 ) andBool V >=Int -2147483648 andBool V <=Int 2147483647
ensures (sorted(?A2) orBool ?C2 =/=K 0 ) andBool list2set(A1) U list2set(B) U { V } ==K list2set(?A2)

rule [bubble-sort-func-spec]:
  <threads>
  <thread>
    <k>
  	(class String2Id(".listNode")).String2Id("bubble_sort"):Id((X1:RawRefVal)::(class String2Id(".listNode")))
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

