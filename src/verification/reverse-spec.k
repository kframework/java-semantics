require "java-verification.k"
module REVERSE-SPEC
    imports JAVA-VERIFICATION

rule [loop-inv]:
  <threads>
      <thread>
  <k>
                    while ( cast ( bool , cast ( class String2Id(".listNode") , 'ExprName(String2Id("x")) ) !=
                      null :: nullType ) ) { .AnnoVarModList class String2Id(".listNode") String2Id("y") ;
                      cast ( class String2Id(".listNode") , ('ExprName(String2Id("y")) =
                      cast ( class String2Id(".listNode") , cast ( class String2Id(".listNode") ,
                      cast ( class String2Id(".listNode") , 'ExprName(String2Id("x")) ) ) . String2Id("next") ))::AssignExp ) ;
                      cast ( class String2Id(".listNode") , ((cast ( class String2Id(".listNode") ,
                      cast ( class String2Id(".listNode") , 'ExprName(String2Id("x")) ) ) . String2Id("next")) =
                      cast ( class String2Id(".listNode") , 'ExprName(String2Id("p")) ))::AssignExp ) ;
                      cast ( class String2Id(".listNode") , ('ExprName(String2Id("p")) =
                      cast ( class String2Id(".listNode") , 'ExprName(String2Id("x")) ))::AssignExp ) ;
                      cast ( class String2Id(".listNode") , ('ExprName(String2Id("x")) =
                      cast ( class String2Id(".listNode") , 'ExprName(String2Id("y")) ))::AssignExp ) ; }
  =>
    .K
  ...</k>
  <env>... (.Map => ?_:Map)
        String2Id("x") |-> P1:Int
        String2Id("p") |-> P2:Int
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
            P1 |-> (LP1:RawRefVal => null):: class String2Id(".listNode")
            P2 |-> (LP2:RawRefVal => ?LP2:RawRefVal) :: class String2Id(".listNode")
                ...</store>
          <busy> .Set </busy>
          <nextLoc> I:Int => ?_:Int </nextLoc>

            <objectStore>... (.Bag => ?_:Bag)
    (list(LP1)(B:List) list(LP2)(C:List) => list(?LP2)(?A:List))
  ...</objectStore>
ensures ?A ==K rev(B) C

rule [func-spec]:
  <threads>
  <thread>
    <k>
  	(class String2Id(".listNode")).String2Id("reverse"):Id((LP:RawRefVal)::(class String2Id(".listNode")))
          =>
          ?LP:RawRefVal::(class String2Id(".listNode"))
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
  <objectStore>... (list(LP)(A:List) => list(?LP)(rev(A))) (.Bag => ?_:Bag)...</objectStore>

endmodule
