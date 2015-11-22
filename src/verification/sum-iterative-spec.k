require "java-verification.k"
module SUM-ITERATIVE-SPEC
    imports JAVA-VERIFICATION

rule
<threads>
<thread>
  <k>
 while ( cast ( bool , cast ( int , 'ExprName(String2Id("n")) ) > 0 :: int ) ) {
                  cast ( int , ('ExprName(String2Id("s")) = cast ( int , cast ( int , 'ExprName(String2Id("s")) ) + cast (
                  int , 'ExprName(String2Id("n")) ) ))::AssignExp ) ; cast ( int , ('ExprName(String2Id("n")) = cast ( int , cast ( int ,
                   'ExprName(String2Id("n")) ) - 1 :: int ))::AssignExp ) ; } 
  =>
    .K
  ...</k>
  <env>... (.Map => ?_:Map)
    String2Id("n") |-> P1:Int
    String2Id("s") |-> P2:Int
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
        P1 |-> (N:Int => 0) :: int
        P2 |-> (S:Int => S +Int ((N +Int 1) *Int N /Int 2)) :: int
    ...</store>
  <busy> .Set </busy>
  <nextLoc> I:Int => ?_:Int </nextLoc>
requires N >=Int 0 andBool N <=Int 200 andBool S >=Int 0 andBool S +Int ((N +Int 1) *Int N /Int 2) <=Int 2147483647

rule
  <threads>
  <thread>
  <k>
    (class String2Id(".sum")).String2Id("sum_iterative"):Id(N:Int::int)
  =>
    ((N +Int 1) *Int N /Int 2) :: int
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
requires N >=Int 0 andBool N <=Int 200

endmodule
