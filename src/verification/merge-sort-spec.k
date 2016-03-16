require "java-verification.k"
module MERGESORT-SPEC
  imports JAVA-VERIFICATION

rule [mergesort-loop-inv1]:
  <threads>
         <thread>
  <k>
    while ( cast ( bool , cast ( class .listNode , 'ExprName(String2Id("x")) ) != null :: nullType ) ) { .AnnoVarModList class .listNode String2Id("t") ;
                       cast ( class .listNode , ('ExprName(String2Id("t")) = cast ( class .listNode , 'ExprName(String2Id("x")) ))::AssignExp ) ;
                       cast ( class .listNode , ('ExprName(String2Id("x")) = cast ( class .listNode ,
                       cast ( class .listNode , cast ( class .listNode , 'ExprName(String2Id("x")) ) ) .
                       next ))::AssignExp ) ;
                      cast ( class .listNode , ((cast ( class .listNode , cast ( class .listNode , 'ExprName(String2Id("t")) ) ) . next) =
                      cast ( class .listNode , 'ExprName(String2Id("y")) ))::AssignExp ) ;
                      cast ( class .listNode , ('ExprName(String2Id("y")) = cast ( class .listNode , 'ExprName(String2Id("t")) ))::AssignExp ) ;
                      if ( cast ( bool , cast ( class .listNode , 'ExprName(String2Id("x")) ) != null :: nullType ) ) {
                      cast ( class .listNode , ('ExprName(String2Id("t")) = cast ( class .listNode , 'ExprName(String2Id("x")) ))::AssignExp ) ;
                      cast ( class .listNode , ('ExprName(String2Id("x")) = cast ( class .listNode , cast
                       ( class .listNode , cast ( class .listNode , 'ExprName(String2Id("x")) ) ) . next
                       ))::AssignExp ) ;
                      cast ( class .listNode , ((cast ( class .listNode , cast ( class .listNode , 'ExprName(String2Id("t")) ) ) . next) =
                      cast ( class .listNode , 'ExprName(String2Id("z")) ))::AssignExp ) ;
                      cast ( class .listNode , ('ExprName(String2Id("z")) = cast (
                      class .listNode , 'ExprName(String2Id("t")) ))::AssignExp ) ; } }
  =>
    .K
  ...</k>
  <env>...
                String2Id("x") |-> LX:Int
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
              LY |-> objectRef((Y1:Int => ?Y2:Int), class String2Id(".listNode")) :: class String2Id(".listNode")
              LZ |-> objectRef((Z1:Int => ?Z2:Int), class String2Id(".listNode")) :: class String2Id(".listNode")
    ...</store>
        <busy> .Set </busy>
        <nextLoc> I:Int => ?_:Int </nextLoc>

          <objectStore>...
     (lseg(X, null)(A:List)
     lseg(objectRef(Y1, class String2Id(".listNode")), null)(B1:List)
     lseg(objectRef(Z1, class String2Id(".listNode")), null)(C1:List)
     =>
     lseg(objectRef(?Y2, class String2Id(".listNode")), null)(?B2:List)
     lseg(objectRef(?Z2, class String2Id(".listNode")), null)(?C2:List))
...</objectStore>
ensures list2set(A) U list2set(B1) U list2set(C1) ==K list2set(?B2) U list2set(?C2)

rule [mergesort-loop-inv2]:
  <threads>
       <thread>
  <k>
    while ( cast ( bool , cast ( bool , cast (
                      class .listNode , 'ExprName(String2Id("y")) ) != null :: nullType ) && cast ( bool
                       , cast ( class .listNode , 'ExprName(String2Id("z")) ) != null :: nullType ) ) )
                      { if ( cast ( bool , cast ( int , cast ( class .listNode ,
                       cast ( class .listNode , 'ExprName(String2Id("y")) ) ) . val ) < cast ( int ,
                      cast ( class .listNode , cast ( class .listNode , 'ExprName(String2Id("z")) ) ) .
                      val ) ) ) { cast ( class .listNode , ((cast ( class
                      .listNode , cast ( class .listNode , 'ExprName(String2Id("p")) ) ) . next) = cast
                      ( class .listNode , 'ExprName(String2Id("y")) ))::AssignExp ) ; cast ( class .listNode , ('ExprName(String2Id("y")) =
                      cast ( class .listNode , cast ( class .listNode , cast (
                      class .listNode , 'ExprName(String2Id("y")) ) ) . next ))::AssignExp ) ; } else { cast ( class
                       .listNode , ((cast ( class .listNode , cast ( class
                      .listNode , 'ExprName(String2Id("p")) ) ) . next) = cast ( class .listNode , 'ExprName(String2Id("z")) ))::AssignExp )
                       ; cast ( class .listNode , ('ExprName(String2Id("z")) = cast ( class .listNode ,
                      cast ( class .listNode , cast ( class .listNode , 'ExprName(String2Id("z")) ) ) .
                      next ))::AssignExp ) ; } cast ( class .listNode , ('ExprName(String2Id("p")) = cast ( class
                      .listNode , cast ( class .listNode , cast ( class
                      .listNode , 'ExprName(String2Id("p")) ) ) . next ))::AssignExp ) ; }
    ~>
     'BlockStmList(if ( cast ( bool , cast (
                       class .listNode , 'ExprName(String2Id("y")) ) != null :: nullType ) ) cast (
                      class .listNode , ((cast ( class .listNode , cast ( class
                      .listNode , 'ExprName(String2Id("p")) ) ) . next) = cast ( class .listNode , 'ExprName(String2Id("y")) ))::AssignExp )
                       ; else cast ( class .listNode , ((cast ( class .listNode ,
                       cast ( class .listNode , 'ExprName(String2Id("p")) ) ) . next) = cast ( class
                      .listNode , 'ExprName(String2Id("z")) ))::AssignExp ) ;
    ,,'BlockStmList(S:BlockStmt,, Ss:BlockStmList))
  =>
    'BlockStmList(S,, Ss)
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
              LX |-> X:RawRefVal :: class String2Id(".listNode")
              LP |-> (objectRef(P:Int, class String2Id(".listNode")) => ?_:RawRefVal) :: class String2Id(".listNode")
              LY |-> (Y:RawRefVal => ?_:RawRefVal) :: class String2Id(".listNode")
              LZ |-> (Z:RawRefVal => ?_:RawRefVal) :: class String2Id(".listNode")
    ...</store>
        <busy> .Set </busy>
        <nextLoc> I:Int => ?_:Int </nextLoc>

  <objectStore>...
    (<object>
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
                               next |-> _:RawRefVal :: class String2Id(".listNode")
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

     lseg(X, objectRef(P, class String2Id(".listNode")))(A1:List)
     lseg(Y, null)(B:List)
     lseg(Z, null)(C:List)
     =>
     lseg(X, null)(?A2:List))
...</objectStore>
requires sorted(A1 ListItem(V)) andBool sorted(B) andBool sorted(C)
  andBool list2set(A1) U {V} <=IntSet list2set(B) U list2set(C)
  andBool V >=Int -2147483648 andBool V <=Int 2147483647
ensures sorted(?A2)
  andBool list2set(A1) U list2set(B) U list2set(C) U { V } ==K list2set(?A2)

rule [merge-sort-func-spec]:
  <threads>
  <thread>
    <k>
  	(class String2Id(".listNode")).String2Id("merge_sort"):Id((X1:RawRefVal)::(class String2Id(".listNode")))
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
  <busy> .Set </busy>
  <nextLoc> I:Int => ?_:Int </nextLoc>
    <objectStore>... (lseg(X1, null)(A1:List) => lseg(?X2, null)(?A2:List)) ...</objectStore>
ensures sorted(?A2) andBool list2set(A1) ==K list2set(?A2)

endmodule

