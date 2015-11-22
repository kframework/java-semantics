require "java-verification.k"
module BUBBLE-SORT-SPEC
  imports JAVA-VERIFICATION

rule [bubble-sort-loop-inv1]:
   <threads>
        <thread>
  <k>
  while ( cast ( bool , 'ExprName(String2Id("change")) ) ) { .AnnoVarModList class .listNode String2Id("y") ;
  cast ( bool , ('ExprName(String2Id("change")) = false :: bool)::AssignExp ) ; cast ( class .listNode , ('ExprName(String2Id("y")) = cast (
                    class .listNode , 'ExprName(String2Id("x")) ))::AssignExp ) ; while ( cast ( bool , cast (
                    class .listNode , cast ( class .listNode , cast ( class
                    .listNode , 'ExprName(String2Id("y")) ) ) . next ) != null :: nullType ) ) { if (
                    cast ( bool , cast ( int , cast ( class .listNode , cast (
                     class .listNode , 'ExprName(String2Id("y")) ) ) . val ) > cast ( int , cast (
                    class .listNode , cast ( class .listNode , cast ( class
                    .listNode , cast ( class .listNode , 'ExprName(String2Id("y")) ) ) . next ) ) .
                    val ) ) ) { .AnnoVarModList int String2Id("temp") ;
                    cast ( bool , ('ExprName(String2Id("change")) = true :: bool)::AssignExp ) ;
                    cast ( int , ('ExprName(String2Id("temp")) = cast ( int , cast (
                    class .listNode , cast ( class .listNode , 'ExprName(String2Id("y")) ) ) . val ))::AssignExp )
                     ; cast ( int , ((cast ( class .listNode , cast ( class
                    .listNode , 'ExprName(String2Id("y")) ) ) . val) = cast ( int , cast ( class
                    .listNode , cast ( class .listNode , cast ( class
                    .listNode , cast ( class .listNode , 'ExprName(String2Id("y")) ) ) . next ) ) .
                    val ))::AssignExp ) ; cast ( int , ((cast ( class .listNode , cast (
                    class .listNode , cast ( class .listNode , cast ( class
                    .listNode , 'ExprName(String2Id("y")) ) ) . next ) ) . val) = cast ( int , 'ExprName(String2Id("temp")) ))::AssignExp
                    ) ; } cast ( class .listNode , ('ExprName(String2Id("y")) = cast ( class .listNode
                    , cast ( class .listNode , cast ( class .listNode , 'ExprName(String2Id("y")) ) )
                    . next ))::AssignExp ) ; } }
  =>
    .K
  ...</k>
    <env>
      String2Id("x") |-> LX:Int
      String2Id("change") |-> LC:Int
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
            LX |-> X:RawRefVal :: class String2Id(".listNode")
            LC |-> (C:Bool => ?_:Bool) :: bool
            ...</store>
                <busy> .Set </busy>
                <nextLoc> I:Int => ?_:Int </nextLoc>
      <objectStore>...
      (lseg(X, null)(A1:List)
     =>
     lseg(X, null)(?A2:List))
...</objectStore>
requires X =/=K null andBool (sorted(A1) orBool C =/=K false)
ensures sorted(?A2) andBool list2set(A1) ==K list2set(?A2)

rule [bubble-sort-loop-inv2]:
  <threads>
      <thread>
  <k>
    while ( cast ( bool , cast (class .listNode , cast ( class .listNode , cast ( class
                        .listNode , 'ExprName(String2Id("y")) ) ) . next ) != null :: nullType ) ) { if (
                        cast ( bool , cast ( int , cast ( class .listNode , cast (
                         class .listNode , 'ExprName(String2Id("y")) ) ) . val ) > cast ( int , cast (
                        class .listNode , cast ( class .listNode , cast ( class
                        .listNode , cast ( class .listNode , 'ExprName(String2Id("y")) ) ) . next ) ) .
                        val ) ) ) { .AnnoVarModList int String2Id("temp") ; cast ( bool , ('ExprName(String2Id("change"))
                         = true :: bool)::AssignExp ) ; cast ( int , ('ExprName(String2Id("temp")) = cast ( int , cast (
                        class .listNode , cast ( class .listNode , 'ExprName(String2Id("y")) ) ) . val ))::AssignExp )
                         ; cast ( int , ((cast ( class .listNode , cast ( class
                        .listNode , 'ExprName(String2Id("y")) ) ) . val) = cast ( int , cast ( class
                        .listNode , cast ( class .listNode , cast ( class
                        .listNode , cast ( class .listNode , 'ExprName(String2Id("y")) ) ) . next ) ) .
                        val ))::AssignExp ) ; cast ( int , ((cast ( class .listNode , cast (
                        class .listNode , cast ( class .listNode , cast ( class
                        .listNode , 'ExprName(String2Id("y")) ) ) . next ) ) . val) = cast ( int , 'ExprName(String2Id("temp")) ))::AssignExp
                        ) ; } cast ( class .listNode , ('ExprName(String2Id("y")) = cast ( class .listNode
                        , cast ( class .listNode , cast ( class .listNode , 'ExprName(String2Id("y")) ) )
                        . next ))::AssignExp ) ; }
  =>
    .K
  ...</k>

  <env>
    String2Id("x") |-> LX:Int
    String2Id("y") |-> LY:Int
    String2Id("change") |-> LC:Int
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
        LX |-> X:RawRefVal :: class String2Id(".listNode")
        LY |-> (objectRef(Y:Int, class String2Id(".listNode")) => objectRef(?_:Int, class String2Id(".listNode"))) :: class String2Id(".listNode")
        LC |-> (C1:Bool => ?C2:Bool) :: bool
        ...</store>
            <busy> .Set </busy>
            <nextLoc> I:Int => ?_:Int </nextLoc>
  <objectStore>...
  (<object>
                              <objectId>
                                  Y
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
     lseg(X, objectRef(Y, class String2Id(".listNode")))(A1:List)
     lseg(P, null)(B:List)
     =>
     lseg(X, null)(?A2:List))
...</objectStore>
requires (sorted(A1 ListItem(V)) orBool C1 =/=K false ) andBool V >=Int -2147483648 andBool V <=Int 2147483647
ensures (sorted(?A2) orBool ?C2 =/=K false ) andBool list2set(A1) U list2set(B) U { V } ==K list2set(?A2)

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
  <busy> .Set </busy>
  <nextLoc> I:Int => ?_:Int </nextLoc>
    <objectStore>... (lseg(X1, null)(A1:List) => lseg(?X2, null)(?A2:List)) ...</objectStore>
ensures (sorted(?A2) andBool list2set(A1) ==K list2set(?A2))
endmodule

