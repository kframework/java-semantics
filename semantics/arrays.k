require "core-sorts.k"
require "subtyping.k"
require "expressions.k"

//@ \section{Module ARRAYS}

module ARRAYS
    imports CORE-SORTS
    imports SUBTYPING
    imports EXPRESSIONS

/*@ The value in store that corresponds to an array element. The consturction "elem" Type is meant to
  distinguish between regular memory locations and array elements. Array elements need to be represented separately
  in order to support array polymorphism.
*/
syntax K ::=  RawVal "::" "elem" Type

//@ \subsection{Array declarators with c-style dimensions and initializers}

//C-style array declaration
//Applied in both elaboration and execution phase
rule [elab-LocalVarDec-ArrayVarDecId-desugar]:
    elab('LocalVarDec(
      _:K,,
      (T:Type => arrayOf T),,
      'ListWrap('VarDec('ArrayVarDecId(
          X:Id,,
          'ListWrap(('Dim(.KList) => .KList) ,,_)
      ),, _:KList //possible initializer
    ))))                                                [structural]

rule [elab-LocalVarDec-ArrayVarDecId-discard]:
    elab('LocalVarDec(_:K,, T:Type,, 'ListWrap('VarDec(
        ( 'ArrayVarDecId( X:Id,, 'ListWrap(.KList) ) => X ),,
        _:KList //possible initializer
    ))))                                                [structural]

rule [elab-LocalVarDec-ArrayInit-desugar]:
    elab('LocalVarDec(_:K,, T:Type,, 'ListWrap('VarDec(
      X:Id,,
      ( 'ArrayInit(InitK:K) => 'NewArray(T,, 'ListWrap(.KList),, 'ArrayInit(InitK)) )
    ))))                                                [structural]

//same three rules for fields

rule [FieldDec-ArrayVarDecId-desugar]:
    'FieldDec(
      _:K,,
      (T:Type => arrayOf T),,
      'ListWrap('VarDec('ArrayVarDecId(
          X:Id,,
          'ListWrap(('Dim(.KList) => .KList) ,,_)
      ),, _:KList //possible initializer
    )))                                                 [structural]

rule [FieldDec-ArrayVarDecId-discard]:
    'FieldDec(_:K,, T:Type,, 'ListWrap('VarDec(
        ( 'ArrayVarDecId( X:Id,, 'ListWrap(.KList) ) => X ),,
        _:KList //possible initializer
    )))                                                 [structural]

rule [FieldDec-ArrayInit-desugar]:
    'FieldDec(_:K,, T:Type,, 'ListWrap('VarDec(
      X:Id,,
      ( 'ArrayInit(InitK:K) => 'NewArray(T,, 'ListWrap(.KList),, 'ArrayInit(InitK)) )
    )))                                                 [structural]

//first two rules - desugaring C-like array declarations, for params

/*@ Thi rule and the next one may happen both in elaboration, execution or process members phases.
They are required to be [anywhere]. */
rule [Param-ArrayVarDecId-desugar]:
    'Param(
      _:K,,
      (T:Type => arrayOf T),,
      'ArrayVarDecId(
          X:Id,,
          'ListWrap(('Dim(.KList) => .KList) ,,_)
      )
    )                                                   [structural, anywhere]

rule [Param-ArrayVarDecId-Discard]:
    'Param(
      _:K,, T:Type,,
      ( 'ArrayVarDecId( X:Id,, 'ListWrap(.KList) ) => X )
    )                                                   [structural, anywhere]

/*@ \subsection{Array access}
Check array bounds, as part of the dynamic typing policy. */

/* ArrayAccess arguments are heated left-to-right, because if the evaluation of the first argument
  throws an exception, the second one should not be evaluated. JLS $15.3.1
*/
context 'ArrayAccess(HOLE,,_)
context 'ArrayAccess(_:KResult,,HOLE)
context lvalue('ArrayAccess(HOLE,,_))
context lvalue('ArrayAccess(_:KResult,,HOLE))

rule [ArrayAccess-to-lookup]:
    'ArrayAccess(arrayRef(_, L:Int, M:Int) :: arrayOf T:Type,, N:Int::_)
    => lookup(L +Int N, T)
when (N >=Int 0) andBool (N <Int M)
        [structural, anywhere]

rule [lookup-array-location]:
    <k>
      lookup(L:Int, T1:Type)
      => subtype(T2, T1) ~> true? ~> (V::T1)
      ...
    </k>
    <store>... L |-> V:RawVal ::elem T2:Type ...</store>
        [transition-threading]

rule [ArrayAccess-to-ArrayIndexOutOfBoundsException]:
    'ArrayAccess(arrayRef(_,_,M:Int) :: _,, N:Int::_)
    => 'Throw('NewInstance(
      'None(.KList),,
      (class String2Id("java.lang.ArrayIndexOutOfBoundsException")),,
      'ListWrap( Int2String(N) ),,
      'None(.KList)
    ))
when notBool ((N >=Int 0) andBool (N <Int M))
        [anywhere]

rule [ArrayAccess-null-to-NullPointerException]:
    'ArrayAccess(null::_,, _)
    => 'Throw('NewInstance(
      'None(.KList),,
      class String2Id("java.lang.NullPointerException"),,
      'ListWrap( null::stringClass ),,
      'None(.KList)
    ))
        [anywhere]

//@ Array length, as defined in JDK
rule
    lookupField(arrayRef(_,_:Int, N:Int)::_, _, X:Id) => N::int
when
    Id2String(X) ==String "length"

//@ \subsection{New array allocation}
/*@ The dynamic semantics of typed array declarations is
similar to that in untyped SIMPLE, but we have to enforce that the
type of an array declaration be of the form \texttt{arrayOf $T$}
and assign the right type ($T$) to the allocated array locations. */

//@Elaboration result of expressions new T[]...
syntax K ::=  newArrayImpl (
                Type, // T - type of each allocated element. So for new int[1][1][][], T will be "arrayOf arrayOf int".
                K,    // 'ListWrap(Dims) - array dimensions
                K,    // InitExp - expression used to initialize each array element, or .K if argument 4 is specified.
                KList // InitContent - array initializer, if any, or .K if argument 3 is specified.
                      // From arguments 3 and 4 just one may be specified. This initializer is for the whole array,
                      //  not for each element as the previous one.
              )

/* HOLE is of the form 'Dim(K)
*/
context newArrayImpl(_:Type, 'ListWrap(Dims:KList,, HOLE,, _), _,_)
when isKResult(Dims)

//applies right after the previous rule, because HOLE is of the form 'Dim(K)
rule 'Dim(K:K) => K [structural]

/*When all dims were computed, check that dims are positive, and only
after that begin array allocation
*/
rule [newArrayImpl]:
    newArrayImpl(T:Type, 'ListWrap(Dims:KList), InitExp:K, .KList)
    => checkNonNegative(Dims) ~> allocAndInitArray(T, 'ListWrap(Dims), InitExp)
when isKResult(Dims) andBool InitExp =/=K .K

rule [newArrayImpl-with-init]:
    newArrayImpl(T:Type, 'ListWrap(Dim:TypedVal), .K, InitContent:KList)
    => arrayInitAlloc(newArrayImpl(T, 'ListWrap(Dim), undefined :: T, .KList), InitContent)

/*Computation designed to check that array creation expression dimensions are non-negative. If they are non-negative,
checkNonNegative is dissolved. Otherwise NegativeArraySizeException is thrown.
*/
syntax K ::=  checkNonNegative (
                KList           // List{KResult} - computed array dimensions
              )

rule checkNonNegative((NI:Int::_ => .KList),, _)
when NI >=Int 0

rule [checkNonNegative-to-NegativeArraySizeException]:
    checkNonNegative((NI:Int::_),, _)
    => 'Throw('NewInstance(
      'None(.KList),,
      class String2Id("java.lang.NegativeArraySizeException"),,
      'ListWrap( null::stringClass ),,
      'None(.KList)
    ))
when
    NI <Int 0

rule checkNonNegative(.KList) => .

//@ Same as newArrayImpl, but after dims were computed and checked
syntax K ::=  allocAndInitArray (
                Type, // T - type of each allocated element. So for new int[1][1][][], T will be "arrayOf arrayOf int".
                K,    // 'ListWrap(Dims:List{KResult}) - array dimensions
                K     // InitExp - expression used to initialize each array element
              )

rule [allocAndInitArray-MultiDim-desugar]:
    allocAndInitArray(T:Type, 'ListWrap(Dims:KList,,Dim1K:TypedVal,,Dim2K:TypedVal), InitExp:K)
    =>  allocAndInitArray(
          arrayOf T,
          'ListWrap(Dims,,Dim1K),
          allocAndInitArray(T, 'ListWrap(Dim2K), InitExp)
        )
when isKResult(Dims)
        [structural]

/*@ The increment of <nextLoc> by one is required to avoid problems with empty arrays.
  Two empty arrays allocated one after another should have different starting locations, even if those starting
  locations are not used. This is required to identify them as two different objects. Their distinction
  could be tested by the operator ==.
*/
rule [allocAndInitArray]:
    <k>
      allocAndInitArray(T:Type, 'ListWrap(NI:Int::_), InitExp:K)
      => allocArray(NI, T) ~> initArray(LI +Int 1, NI, InitExp)
         ~> arrayRef( arrayOf T, LI +Int 1, NI) :: arrayOf T
      ...
    </k>
    <nextLoc> LI:Int => LI +Int 1 </nextLoc>

//@ Maximum of two numbers
syntax K ::=  max ( Int, Int )          [function]
rule max(I1:Int, I2:Int) => #if I1 >=Int I2
                              #then I1
                              #else I2
                            #fi

/*@ Allocates the given number of elements in the store of the given Type. Used by array instantiation logic.
*/
syntax K ::=  allocArray (
                Int,  //The number of elements to allocate
                Type  //The type of each element
              )

rule [allocArray]:
    <k> allocArray(N:Int => N -Int 1, T:Type) ...</k>
    <store>... . => LI |-> (undefined :: elem T) ...</store>
    <nextLoc> LI:Int => LI +Int 1 </nextLoc>
when
    N >Int 0

rule allocArray(0, _) => .K       [structural]

/*@ Assign to each store location in the given range the value represented by the 3-rd argument. This value might be
  freshly computed for each element, and might alter another locations in the store, as is the case for multidim arrays.
  This procedure don't change the element type in the store.
*/
syntax K ::=  initArray (
                Int,    // The location of the first element
                Int,    // The number of elements
                K       /* Expression used to initialize each location. Is evaluated for each location
                           separately, could be an array creation expression if this is just a
                           dimension of the parent multidim array. */
              )

rule [initArray]:
    initArray(OL:Int, N:Int, InitExp:K)
    => store(OL, InitExp) ~> initArray(OL +Int 1, N -Int 1, InitExp)
when
    N >Int 0
        [structural]

rule initArray(_, 0, _) => .K       [structural]

//@ \subsection{Array element assignment}

rule [Assign-array-location-exact-type]:
    'Assign(loc(L:Int)::T:Type,, V:RawVal::T) => store(L, V::T) ~> V::T

rule [store-array-elem]:
    <k> store(L:Int, V:RawVal :: T:Type) => . ...</k>
    <store>... L |-> (_ => V) :: elem T:Type ...</store>
        [transition-threading]

rule [store-array-location-check-type]:
    <k>
      store(L:Int, V:RawVal::T:Type)
      =>  'If(
            subtype(typeOf(V), StoreType),,
            store(L, V::StoreType),,
            'Throw('NewInstance(
              'None(.KList),,
              (class String2Id("java.lang.ArrayStoreException")),,
              'ListWrap(
                //the ArrayStoreException argument is the assigned object type
                'Invoke(
                  'MethodName(
                    'Invoke(
                      'MethodName(V::T,, String2Id("getClass")),,
                      'ListWrap(.KList)
                    ),,
                    String2Id("getName")),,
                  'ListWrap(.KList)
                )
              ),,
              'None(.KList)
            ))
          )
      ...
    </k>
    <store>... L |-> _ :: elem StoreType:Type ...</store>
when
    T =/=K StoreType

//@ \subsection{Array initializer}

//allocates the array based on previously computed size, the proceeds to array initialization
syntax K ::=  arrayInitAlloc (
                K,    //newArrayAlloc(), reduces to arrayRef()
                KList //InitContent - list of initialization expressions
              )
              [strict(1)]

//K bug - [strict] and KList arguments don't work together. Tested with K version of 23/02/2014.
context arrayInitAlloc(HOLE,_)

rule [arrayInitAlloc]:
    arrayInitAlloc(arrayRef(T:Type, L:Int, Len:Int)::T, InitContent:KList)
    => arrayInitImpl(T, L, InitContent) ~> arrayRef(T, L, Len)::T

syntax K ::=  arrayInitImpl (
                Type, //T - array type, used by inner ArrayInit's
                Int,  //L - location of first element in store
                KList //InitContent - list of initialization expressions
              )

rule [arrayInitImpl]:
    ( . => store(L, K) )
    ~> arrayInitImpl(_, (L:Int => L +Int 1), ((K:K => .KList),, _) )
when
    getKLabel(K) =/=KLabel 'ArrayInit

rule [arrayInitImpl-inner-ArrayInit-desugar]:
    ( . => store(L, newArrayImpl(T, 'ListWrap(length(InitContent)::int), .K, InitContent)) )
    ~> arrayInitImpl(
          arrayOf arrayOf T:Type,
          (L:Int => L +Int 1),
          (('ArrayInit('ListWrap(InitContent:KList)) => .KList),, _)
       )

rule [arrayInitImpl-discard]:
    arrayInitImpl(_, _, .KList) => .

endmodule
