module JAVA-ARRAYS
    imports JAVA-CORE
    imports JAVA-EXPRESSIONS

syntax RefType ::= "arrayOf" Type
                  [prec(1) latex "{#1}\texttt{\char91\char93}"]

syntax RawVal ::= "arrayRef" "("
                    Type ","  // Type of array
                    Int ","   // Location of first element
                    Int       // Length
                  ")"

syntax K ::= RawVal "::" "elem" Type

//@ \subsection{C-style array declarators}

rule [ArrayVarDecIdDesugar]:
    'LocalVarDec(
      (T:Type => arrayOf T),,
      'ListWrap('VarDec('ArrayVarDecId(
          X:Id,,
          'ListWrap(('Dim(.List{K}) => .List{K}) ,,_)
      ),, _ //possible initializer
    )))

rule [ArrayVarDecIdDiscard]:
    'LocalVarDec(T,, 'ListWrap('VarDec(
        ( 'ArrayVarDecId( X,, 'ListWrap(.List{K}) ) => X ),,
        _ //possible initializer
    )))

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

rule [lookupArrayLocation]:
    <k>
      lookup(L) :: T1
      => subtype T2, T1 ~> true? ~> V::T1
      ...
    </k>
    <store>... L |-> V::elem T2 ...</store>
        [transition]

rule [ArrayIndexOutOfBoundsException]:
    'ArrayAccess(arrayRef(_,_,M) :: _,, N::_)
    => 'Throw('NewInstance(
      'None(.List{K}),,
      'class_(String2Id("ArrayIndexOutOfBoundsException")),,
      'ListWrap( Int2String(N) :: rtString ),,
      'None(.List{K})
    ))
when notBool (N >=Int 0 andBool N <Int M)
        [structural anywhere]

//Required to desugar effects of the previous rule, when exception happens
//inside lvalue.
rule [LvalueIndexOutOfBoundsDesugar]:
    lvalue('Throw(K)) => 'Throw(K)

rule [arrayAccessNull]:
    'ArrayAccess(null::_ ,, _)
    => 'Throw('NewInstance(
      'None(.List{K}),,
      'class_(String2Id("NullPointerException")),,
      'ListWrap( null :: rtString ),,
      'None(.List{K})
    ))
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
                K         // InitExp - expression used to initialize each array element
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
                K         // InitExp - expression used to initialize each array element
             ")"

/*Computation designed to check that array creation expression dimensions are non-negative. If they are non-negative, checkNonNegative is dissolved. Otherwise NegativeArraySizeException is thrown.
*/
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

//In order to avoid problems with empty arrays, such as the test for equality,
//even if the created array is empty it will increment nextLoc by one
rule [newArrayAlloc]:
    <k>
      newArrayAlloc(T, 'ListWrap(NI:Int::_), InitExp:K)
      => evalAndStore((LI:Int .. LI +Int _-Int_(NI,1)), InitExp)
         ~> arrayRef( arrayOf T, LI, NI) :: arrayOf T
      ...
    </k>
    <store>... . => LI .. LI +Int _-Int_(NI,1) |-> undefined :: elem T ...</store>
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
    <store>... L |-> (_ => V) :: elem T1:Type ...</store>

rule [evalAndStoreEmpty]:
    evalAndStore(.List{K}, _) => .
        [structural]

//@ Subtype
rule [subtypeArrayOfArrayPrimitive]:
    subtype arrayOf T1, arrayOf T2 =>
    #if T1 ==K T2
      #then true::bool
      #else false::bool
    #fi
when
    notBool isRefType2(T1) andBool notBool isRefType2(T2)

rule [subtypeArrayOfArrayRef]:
    subtype arrayOf RefT1:RefType, arrayOf RefT2:RefType => subtype RefT1, RefT2

define toString(arrayOf T) => 'Plus("["::rtString,, arrayToString(T))

//@ Sequences of locations

syntax List{K} ::= Int ".." Int
define N1:Int..N2:Int => .List{K}              when N1  >Int N2
define N1:Int..N2:Int => N1 ,, (N1 +Int 1)..N2 when N1 <=Int N2

//@ \subsection{Array element assignment}

rule [AssignInArrayExact]:
    <k> 'Assign(loc(L) :: T:Type,, V:RawVal :: T) => V::T ...</k>
    <store>... L |-> (_ => V)::elem T ...</store>

rule [AssignInArrayWithCheck]:
    <k>
      'Assign(loc(L) :: T:Type,, V:RawVal :: T)
      => assignImpl(
          (subtype typeOf(V), StoreType),
          L,
          V::T
      )
      ...
    </k>
    <store>... L |-> _ :: elem StoreType:Type ...</store>
when
    T =/=K StoreType

//Bug. [strict(1,3)] gives a weird error in K2. Have to use context for argument (3).
syntax K ::= "assignImpl" "("
                            K ","     //subtype check on array element assignment
                            Int ","   //destination store location
                            TypedVal  //assigned value
                          ")"
        [strict(1)]

context assignImpl(_:KResult, _, HOLE)

rule [assignImpl]:
    <k> assignImpl( true::bool, L, V::T) => V::T ...</k>
    <store>... L |-> (_ => V) :: elem _ ...</store>
        [transition]

rule [ArrayStoreException]:
    assignImpl( false::bool, _, V::T)
    =>  'Throw('NewInstance(
          'None(.List{K}),,
          'class_(String2Id("ArrayStoreException")),,
          'ListWrap(
            //the ArrayStoreException argument is the assigned object type
            'Invoke(
              'MethodName(
                'Invoke(
                  'MethodName(V::T,, String2Id("getClass")),,
                  'ListWrap(.List{K})
                ),,
                String2Id("getName")),,
              'ListWrap(.List{K})
            )
          ),,
          'None(.List{K})
        ))

//@ \subsection{Array initializer}

rule [ArrayInitPreprocess]:
    'NewArray((T => arrayOf T),, 'ListWrap(('Dim(.List{K}) => .List{K}),, _),, 'ArrayInit(_))

rule [ArrayInitPreprocess2]:
    'NewArray(T,, 'ListWrap(.List{K}),, 'ArrayInit(InitContent:K))
    => arrayInitCountSize(T, 0, InitContent, InitContent)

//counts elements of an array initiaizer, then passes the counted data, as well as the original
//initializer to the next step - array allocation based on counted size.
syntax K ::= "arrayInitCountSize" "("
                                Type ","  //array type
                                Int ","   //counted size
                                K ","     //InitContent - content of original 'ArrayInit term,
                                          //a 'ListWrap
                                K         //InitContent - copy of the second argument
                              ")"

rule [arrayInitCountSize]:
    arrayInitCountSize(_, I:Int => I +Int 1, 'ListWrap((_:K => .List{K}),, _), _)

rule [arrayInitCountSizeEnd]:
    arrayInitCountSize(arrayOf T, I, 'ListWrap(.List{K}), InitContent)
    => arrayInitAlloc(newArrayAlloc(T, 'ListWrap(I::int), undefined :: T), InitContent)

//allocates the array based on previously computed size, the proceeds to array initialization
syntax K ::= "arrayInitAlloc" "("
                                  K "," //newArrayAlloc(), reduces to arrayRef()
                                  K     //InitContent - original 'ArrayInit content
                              ")"
        [strict(1)]

rule [arrayInitAlloc]:
    arrayInitAlloc(arrayRef(T, L, Len:Int)::T, InitContent)
    => arrayInitImpl(T, L, InitContent) ~> arrayRef(T, L, Len)::T

syntax K ::= "arrayInitImpl" "("
                                  Type ","//T - array type
                                          //    used by inner ArrayInit's
                                  Int "," //L - location of first element in store
                                  K       //InitContent - initialization content inside 'ListWrap
                              ")"

rule [arrayInitImpl]:
    ( . => 'ExprStm(assignImpl(true::bool, L, K)) )
    ~> arrayInitImpl(_, (L => L +Int 1), 'ListWrap((K => .List{K}),, _) )
when
    getKLabel(K) =/=KLabel 'ArrayInit

rule [arrayInitImplInnerArrayInit]:
    ( . => 'ExprStm(assignImpl(
              true::bool,
              L,
              'NewArray(T,, 'ListWrap(.List{K}),, 'ArrayInit(InitContent))
           )) )
    ~> arrayInitImpl(
          arrayOf T,
          (L => L +Int 1),
          'ListWrap(('ArrayInit(InitContent) => .List{K}),, _)
       )

rule [arrayInitImplDiscard]:
    arrayInitImpl(_, _, 'ListWrap(.List{K})) => .

rule [VarDecWithArrayInitDesugar]:
    'LocalVarDec(T,, 'ListWrap('VarDec(
      X,,
      ( 'ArrayInit(InitContent) => 'NewArray(T,, 'ListWrap(.List{K}),, 'ArrayInit(InitContent)) )
    )))

end module
