module JAVA-ARRAYS
    imports JAVA-CORE
    imports JAVA-EXPRESSIONS

syntax RefType ::= "arrayOf" Type
                  [prec(1) latex "{#1}\texttt{\char91\char93}"]

syntax RawVal ::= "arrayRef" "(" Type "," Int "," Int ")"

/*@ \subsection{Array access}
Check array bounds, as part of the dynamic typing policy. */

syntax KLabel ::= 'ArrayAccess [seqstrict]

context lvalue('ArrayAccess(HOLE,,_))
context lvalue('ArrayAccess(_:KResult,,HOLE))

rule [arrayLookup]:
    'ArrayAccess(arrayRef(_,L,M:Int) :: arrayOf T:Type,, N:Int::_)
    => lookup(L +Int N) :: T
when N >=Int 0 andBool N <Int M
        [structural anywhere]

//Array length, as defined in JDK
rule
    <k> 'ExprName(arrayRef(_,_:Int,N)::_,, X:Id ) => N::int ...</k>
when
    Id2String(X) ==String "length"

//@ \subsection{Array Type}

context 'ArrayType(HOLE)

rule 'ArrayType(T) => arrayOf T [structural]

//@ \subsection{New array allocation}
/*@ The dynamic semantics of typed array declarations is
similar to that in untyped SIMPLE, but we have to enforce that the
type of an array declaration be of the form \texttt{arrayOf $T$}
and assign the right type ($T$) to the allocated array locations. */

context 'NewArray(HOLE,, _:List{K})

rule [NewArrayEmptyDims]:
    'NewArray( (T => arrayOf T),, _:List{K},,
        'ListWrap( ( 'Dim(.List{K}) => .List{K} ) ,,_:List{K}) )
        [structural]

rule [NewArray]:
    'NewArray(T,, K:K,, 'ListWrap(.List{K})) => newArrayImpl(T, K, undefined :: T)
        [structural]

syntax K ::= "newArrayImpl" "("
                Type ","  // T - element type
                K ","     // 'ListWrap(Dims) - array dimensions
                K         // InitExp
             ")"

context newArrayImpl(_:KResult, 'ListWrap(_:List{KResult},,HOLE,, _), _)

//applies right after the previous rule, because HOLE is of the form 'Dim(K)
rule 'Dim(K) => K [structural]

//when all dims were computed, check that dims are positive, and only
//after that begin array allocation
rule newArrayImpl(T, 'ListWrap(Dims:List{KResult}), InitExp)
    => checkNonNegative(Dims) ~> newArrayAlloc(T, 'ListWrap(Dims), InitExp)

//same as newArrayImpl, but after dims were computed and checked
syntax K ::= "newArrayAlloc" "("
                Type ","  // T - element type
                K ","     // 'ListWrap(Dims) - array dimensions
                K         // InitExp
             ")"

syntax K ::= "checkNonNegative" "("
                List{KResult}      // - computed array dimensions
             ")"

rule checkNonNegative((NI::_ => .List{K}),, _)
when NI >=Int 0

rule [NegativeArraySizeException]:
    checkNonNegative((NI::_),, _)
    => 'Throw('NewInstance(
      'None(.List{K}),,
      'class_(String2Id("NegativeArraySizeException")),,
      'ListWrap( null :: rtString ),,
      'None(.List{K})
    ))
when
    NI <Int 0

rule checkNonNegative(.List{K}) => .

rule [newArrayAllocMultiDim]:
    newArrayAlloc(T, 'ListWrap(Dims,,Dim1K:TypedVal,,Dim2K:TypedVal), InitExp)
    =>  newArrayAlloc(
          arrayOf T,
          'ListWrap(Dims,,Dim1K),
          newArrayAlloc(T, 'ListWrap(Dim2K), InitExp)
        )
        [structural]

//in order to avoid problems with empty arrays
//even if the created array is empty it will increment nextLoc by one
rule [newArrayAlloc]:
    <k>
      newArrayAlloc(T, 'ListWrap(NI:Int::_), InitExp:K)
      => evalAndStore((LI:Int .. LI +Int _-Int_(NI,1)), InitExp)
         ~> arrayRef( arrayOf T, LI, NI) :: arrayOf T
      ...
    </k>
    <store>... . => LI .. LI +Int _-Int_(NI,1) |-> undefined :: T ...</store>
    <nextLoc> LI:Int => LI +Int max(NI,1) </nextLoc>

declare max : Int Int -> Int
define max(I1, I2) => #if I1 >=Int I2
                        #then I1
                        #else I2
                      #fi

syntax K ::= "evalAndStore" "(" List{K}  "," K ")"

rule [evalAndStoreDesugar]:
    evalAndStore((I1:Int,,I2:Int,,Ks:List{K}), InitExp)
    => evalAndStore(I1,InitExp) ~> evalAndStore((I2,,Ks),InitExp)
        [structural]

context evalAndStore(_:Int, HOLE)

rule [evalAndStore]:
    <k>
      evalAndStore(L:Int, V:RawVal :: T2:Type) => subtype T2, T1 ~> true?
      ...
    </k>
    <store>... L |-> (_ => V) :: T1:Type ...</store>

rule [evalAndStoreEmpty]:
    evalAndStore(.List{K}, _) => .
        [structural]

//@ Subtype
rule [subtypeArrayOfArray]:
    subtype arrayOf T1, arrayOf T2 =>
    #if T1 ==K T2
      #then true::bool
      #else false::bool
    #fi

define toString(arrayOf T) => 'Plus("["::rtString,, arrayToString(T))

//@ Sequences of locations

syntax List{K} ::= Int ".." Int
define N1:Int..N2:Int => .List{K}              when N1  >Int N2
define N1:Int..N2:Int => N1 ,, (N1 +Int 1)..N2 when N1 <=Int N2

end module
