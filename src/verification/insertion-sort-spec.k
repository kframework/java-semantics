require "java-verification.k"
module INSERTION-SORT-SPEC
  imports JAVA-VERIFICATION

rule [insertion-sort-loop-inv1]:
  <threads>
          <thread>
  <k>
                    while ( cast ( bool , cast ( class .listNode , 'ExprName(String2Id("x")) ) !=
                      null :: nullType ) ) { .AnnoVarModList class .listNode String2Id("n") ;
                       cast ( class .listNode , ('ExprName(String2Id("n")) = cast ( class .listNode , 'ExprName(String2Id("x")) ))::AssignExp
                       ) ; cast ( class .listNode , ('ExprName(String2Id("x")) = cast ( class .listNode ,
                       cast ( class .listNode , cast ( class .listNode , 'ExprName(String2Id("x")) ) ) .
                       next ))::AssignExp ) ; cast ( class .listNode , ((cast ( class
                      .listNode , cast ( class .listNode , 'ExprName(String2Id("n")) ) ) . next) = cast
                      ( class .listNode , null :: nullType ))::AssignExp ) ; if ( cast (
                      bool , cast ( class .listNode , 'ExprName(String2Id("y")) ) != null :: nullType )
                      ) { if ( cast ( bool , cast ( int , cast ( class .listNode
                       , cast ( class .listNode , 'ExprName(String2Id("y")) ) ) . val ) < cast ( int ,
                      cast ( class .listNode , cast ( class .listNode , 'ExprName(String2Id("n")) ) ) .
                      val ) ) ) { .AnnoVarModList class .listNode String2Id("z") ; cast (
                      class .listNode , ('ExprName(String2Id("z")) = cast ( class .listNode , 'ExprName(String2Id("y")) ))::AssignExp ) ;
                      while ( cast ( bool , cast ( bool , cast ( class .listNode
                       , cast ( class .listNode , cast ( class .listNode , 'ExprName(String2Id("z")) ) )
                       . next ) != null :: nullType ) && cast ( bool , cast (
                      int , cast ( class .listNode , cast ( class .listNode ,
                      cast ( class .listNode , cast ( class .listNode , 'ExprName(String2Id("z")) ) ) .
                      next ) ) . val ) < cast ( int , cast ( class .listNode ,
                      cast ( class .listNode , 'ExprName(String2Id("n")) ) ) . val ) ) ) ) { cast (
                      class .listNode , ('ExprName(String2Id("z")) = cast ( class .listNode , cast (
                      class .listNode , cast ( class .listNode , 'ExprName(String2Id("z")) ) ) . next ))::AssignExp
                      ) ; } cast ( class .listNode , ((cast ( class .listNode ,
                      cast ( class .listNode , 'ExprName(String2Id("n")) ) ) . next) = cast ( class
                      .listNode , cast ( class .listNode , cast ( class
                      .listNode , 'ExprName(String2Id("z")) ) ) . next ))::AssignExp ) ; cast ( class .listNode , ((
                      cast ( class .listNode , cast ( class .listNode , 'ExprName(String2Id("z")) ) ) .
                      next) = cast ( class .listNode , 'ExprName(String2Id("n")) ))::AssignExp ) ; } else { cast (
                      class .listNode , ((cast ( class .listNode , cast ( class
                      .listNode , 'ExprName(String2Id("n")) ) ) . next) = cast ( class .listNode , 'ExprName(String2Id("y")) ))::AssignExp )
                       ; cast ( class .listNode , ('ExprName(String2Id("y")) = cast ( class .listNode , 'ExprName(String2Id("n"))
                       ))::AssignExp ) ; } } else { cast ( class .listNode , ('ExprName(String2Id("y")) = cast (
                      class .listNode , 'ExprName(String2Id("n")) ))::AssignExp ) ; } }
  =>
    .K
  ...</k>
  <env>
      String2Id("x") |-> LX:Int
      String2Id("y") |-> LY:Int
  </env>
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
                  <busy> .Set </busy>
                  <nextLoc> I:Int => ?_:Int </nextLoc>

                    <objectStore>...
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
          while ( cast ( bool , cast ( bool , cast ( class .listNode
                           , cast ( class .listNode , cast ( class .listNode , 'ExprName(String2Id("z")) ) )
                           . next ) != null :: nullType ) && cast ( bool , cast (
                          int , cast ( class .listNode , cast ( class .listNode ,
                          cast ( class .listNode , cast ( class .listNode , 'ExprName(String2Id("z")) ) ) .
                          next ) ) . val ) < cast ( int , cast ( class .listNode ,
                          cast ( class .listNode , 'ExprName(String2Id("n")) ) ) . val ) ) ) ) { cast (
                          class .listNode , ('ExprName(String2Id("z")) = cast ( class .listNode , cast (
                          class .listNode , cast ( class .listNode , 'ExprName(String2Id("z")) ) ) . next ))::AssignExp
                          ) ; }
          ~> cast ( class .listNode , ((cast ( class .listNode ,
                          cast ( class .listNode , 'ExprName(String2Id("n")) ) ) . next) = cast ( class
                          .listNode , cast ( class .listNode , cast ( class
                          .listNode , 'ExprName(String2Id("z")) ) ) . next ))::AssignExp ) ; cast ( class .listNode , ((
                          cast ( class .listNode , cast ( class .listNode , 'ExprName(String2Id("z")) ) ) .
                          next) = cast ( class .listNode , 'ExprName(String2Id("n")) ))::AssignExp ) ;
  =>
    .K
  ...</k>
  <env>
                String2Id("x") |-> _
                String2Id("n") |-> LN:Int
                String2Id("y") |-> LY:Int
                String2Id("z") |-> LZ:Int
  </env>
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
                LN |-> objectRef(N:Int, class String2Id(".listNode")) :: class String2Id(".listNode")
               ... </store>
        <busy> .Set </busy>
        <nextLoc> I:Int => ?_:Int </nextLoc>

   <objectStore>...
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
  <busy> .Set </busy>
  <nextLoc> I:Int => ?_:Int </nextLoc>
    <objectStore>... (lseg(X1, null)(A1:List) => lseg(?X2, null)(?A2:List)) ...</objectStore>
ensures sorted(?A2) andBool list2set(A1) ==K list2set(?A2)

endmodule

