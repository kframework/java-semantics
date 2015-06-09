require "java-verification.k"
module APPEND-SPEC
    imports JAVA-VERIFICATION

rule [loop-inv]:
  <threads>
    <thread>
  <k>
                    whileImpl ( cast ( bool , cast ( class String2Id(".listNode") , cast (
                      class String2Id(".listNode") , cast ( class String2Id(".listNode") , 'ExprName(String2Id("p")) ) ) . String2Id("next") )
                      != null :: nullType ) , { cast ( class String2Id(".listNode") , 'ExprName(String2Id("p")) =
                      cast ( class String2Id(".listNode") , cast ( class String2Id(".listNode") , cast (
                      class String2Id(".listNode") , 'ExprName(String2Id("p")) ) ) . String2Id("next") ) ) ; } )
  =>
    .K
  ...</k>
  <env>...
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
      <store>... .Map => ?_:Map
      LX |-> X:RawRefVal :: C:ClassType
      LP |-> (objectRef(P1:Int, C) => objectRef(?P2:Int, C)) :: C
          ...</store>
    <storeMetadata> ... .Map => ?_:Map 
      LX |-> LocalLocMetadata
      LP |-> LocalLocMetadata
       ... </storeMetadata>
    <busy> .Set </busy>
    <nextLoc> I:Int => ?_:Int </nextLoc>

      <objectStore>...

    (lseg(X, objectRef(P1, C))(A:List)
     lseg(objectRef(P1, C), null)(B:List)
     =>
     lseg(X, objectRef(?P2, C))(?C:List)
     <object>
                            <objectId>
                                ?P2
                            </objectId>
                            <objectType>
                                C
                            </objectType>
                            <layer>
                                <layerClass>
                                    C
                                </layerClass>
                                <layerEnv>
                   String2Id("val") |-> ?E:Int :: int
                   String2Id("next") |-> null :: C
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
  ...</objectStore>
ensures A B ==K ?C ListItem(?E) andBool ?E >=Int -2147483648 andBool ?E <=Int 2147483647

//rule [func-spec]:
//  <threads>
//  <thread>
//    <k>
//  	(class String2Id(".listNode")).String2Id("append"):Id((X:RawRefVal)::(class String2Id(".listNode")), (Y:RawRefVal)::(class String2Id(".listNode")))
//          =>
//          ?P:RawRefVal::(class String2Id(".listNode"))
//    ...</k>
//  <holds> .Map </holds>
//  ...
//  </thread>
//  </threads>
//
//  <classes> CLASSES:Bag </classes>
//  <NumOfClassesToUnfold> 0 </NumOfClassesToUnfold>
//  <program> .K </program>
//   <globalPhase> ExecutionPhase </globalPhase>
//    <store>... .Map => ?_:Map ...</store>
//  <storeMetadata> ... .Map => ?_:Map ... </storeMetadata>
//  <busy> .Set </busy>
//  <nextLoc> I:Int => ?_:Int </nextLoc>
//
//    <objectStore>... lseg(X, null)(A:List) lseg(Y, null)(B:List) => lseg(?P, null)(A B) ...</objectStore>
endmodule

