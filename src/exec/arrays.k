module ARRAYS
    imports CORE-SORTS
    imports SUBTYPING
    imports EXPRESSIONS
    imports SYNTAX-CONVERSIONS
    imports JAVA-SYNTAX

/*@ The value in store that corresponds to an array element. The consturction "elem" Type is meant to
  distinguish between regular memory locations and array elements. Array elements need to be represented separately
  in order to support array polymorphism.
*/
syntax KItem ::=  RawVal "::" "elem" Type

/* ArrayAccess arguments are heated left-to-right, because if the evaluation of the first argument
  throws an exception, the second one should not be evaluated. JLS $15.3.1
*/
context lvalue('ArrayAccess(HOLE,,_))
context lvalue('ArrayAccess(_:KResult,,HOLE))

rule [ArrayAccess-to-lookup]:
    (arrayRef(_, L:Int, M:Int) :: arrayOf T:Type [N:Int::_])
    => lookup(aeloc(L, N), T)
when (N >=Int 0) andBool (N <Int M)
        [structural, anywhere]

rule [ArrayElem-lookup]:
        <k>
    lookup(aeloc(L, N), T1:Type) => subtype(T2, T1) ~> true? ~> (V::T1)
          ...
        </k>
        <arrayId> L </arrayId>
        <arraystore>... N |-> V:RawVal ::elem T2:Type ...</arraystore>

rule [ArrayAccess-to-ArrayIndexOutOfBoundsException]:
    arrayRef(_,_,M:Int) :: _ [N:Int::_]
    => throw new class String2Id("java.lang.ArrayIndexOutOfBoundsException") ( Int2String(N) );
when notBool ((N >=Int 0) andBool (N <Int M))
        [anywhere]

rule [ArrayAccess-null-to-NullPointerException]:
    (null::_) [_] => throw new classNullPointerException(null::classString);
        [anywhere]

//@ Array length, as defined in JDK
rule [Field-array-length]:
    'Field(arrayRef(_,_:Int, N:Int)::_,, X:Id) => N::int
when
    Id2String(X) ==String "length"

//@ \subsection{New array allocation}
/*@ The dynamic semantics of typed array declarations is
similar to that in untyped SIMPLE, but we have to enforce that the
type of an array declaration be of the form \texttt{arrayOf $T$}
and assign the right type ($T$) to the allocated array locations. */


/* For multi-dimensions arrays, it is expanded from the last DimInt, but currently, the tail element(s)
 matching is unavailable for user defined lists, so we reverse list for easier matching
*/
syntax DimInts ::= reverseDimInts(DimInts, DimInts) [function]
rule reverseDimInts(D:DimInt Ds:DimInts, Es:DimInts) => reverseDimInts(Ds, (D Es))
rule reverseDimInts(.DimInts, Es:DimInts) => Es

syntax DimInt ::= "[" TypedVal "]" [klabel('Dim)]
syntax DimInts ::= List{DimInt,""} [klabel('DimExprList)]
syntax DimExp ::= DimInt
syntax KResult ::= DimInt

/*@ When all dims were computed, check that dims are positive, and only
    after that begin array allocation
*/
rule [NewArray-simple]:
    new T:Type Ds:DimInts .Dims
    => checkNonNegative(Ds) ~> allocAndInitArray(T, reverseDimInts(Ds,.DimInts) , default(T))

rule [NewArray-ArrayInit]:
    new arrayOf T:Type .Dims {InitContent:VarInits}
    => arrayInitAlloc((new T [length(InitContent)::int]:DimInt .Dims), {InitContent})

syntax Int ::= length (VarInits)                                  [function]
rule length(V:VarInit, Vs:VarInits) => length(Vs)+Int 1
rule length(.VarInits) => 0

/*Computation designed to check that array creation expression dimensions are non-negative. If they are non-negative,
checkNonNegative is dissolved. Otherwise NegativeArraySizeException is thrown.
*/
syntax KItem ::=  checkNonNegative (DimInts)

rule checkNonNegative([NI:Int::_ ]:DimInt Remainings:DimInts)=> checkNonNegative(Remainings)
when NI >=Int 0

rule [checkNonNegative-to-NegativeArraySizeException]:
    checkNonNegative([NI:Int::_]:DimInt _:DimInts)
    => throw new class String2Id("java.lang.NegativeArraySizeException") (null::classString);
when
    NI <Int 0

rule checkNonNegative(.DimInts) => .

//@ Same as 'NewArray, but after DimInts were computed and checked
syntax KItem ::=  allocAndInitArray (
                Type, // T - type of each allocated element. So for new int[1][1][][], T will be "arrayOf arrayOf int".
                DimInts,  // DimInts:List{DimInt} - array dimensions
                K     // InitExp - expression used to initialize each array element
              )

//@ Here we are actually using the reversed DimInts
rule [allocAndInitArray-MultiDim-desugar]:
    allocAndInitArray(T:Type, Dim1K:DimInt Dim2K:DimInt DEs:DimInts, InitExp:K)
    =>  allocAndInitArray(
          arrayOf T,
          Dim2K DEs,
          allocAndInitArray(T, Dim1K .DimInts, InitExp)
        )
        [structural]


/*@ The increment of <nextLoc> by one is required to avoid problems with empty arrays.
  Two empty arrays allocated one after another should have different starting locations, even if those starting
  locations are not used. This is required to identify them as two different objects. Their distinction
  could be tested by the operator ==.
*/
rule [allocAndInitArray]:
    <k>
      allocAndInitArray(T:Type, [NI:Int::_] .DimInts, InitExp:K)
      => allocArray(LI, NI, T) ~> initArray(LI, NI, InitExp)
         ~> arrayRef( arrayOf T, LI, NI) :: arrayOf T
      ...
    </k>
    <nextLoc> LI:Int => LI +Int 1 </nextLoc>
        (.Bag =>  <array>
                    <arrayId> LI </arrayId>
                    <arrayType> arrayOf T </arrayType>
                    <arraystore> .Map </arraystore>
                  </array>
        )


/*@ Allocates the given number of elements in the store of the given Type. Used by array instantiation logic.
*/
syntax KItem ::=  allocArray (
                Int,  //arrayId
                Int,  //The number of elements to allocate
                Type  //The type of each element
              )

rule [allocArray]:
    <k> allocArray(L:Int, N:Int => N -Int 1, T:Type) ...</k>
    <arrayId> L </arrayId>
    <arraystore>... .Map => (N -Int 1) |-> (undefined :: elem T) ...</arraystore>
when
    N >Int 0

rule allocArray(_, 0, _) => .K       [structural]

/*@ Assign to each store location in the given range the value represented by the 3-rd argument. This value might be
  freshly computed for each element, and might alter another locations in the store, as is the case for multidim arrays.
  This procedure don't change the element type in the store.
*/
syntax KItem ::=  initArray (
                Int,    // arrayId
                Int,    // The number of elements
                K       /* Expression used to initialize each location. Is evaluated for each location
                           separately, could be an array creation expression if this is just a
                           dimension of the parent multidim array. */
              )

rule [initArray]:
    initArray(OL:Int, N:Int, InitExp:K)
    => store(aeloc(OL, N -Int 1), InitExp) ~> initArray(OL, N -Int 1, InitExp)
when
    N >Int 0
        [structural]

rule initArray(_, 0, _) => .K       [structural]

//@ \subsection{Array element assignment}
rule [store-array-elem]:
    <k> store(aeloc(LI:Int, L:Int), V:RawVal :: T:Type) => . ...</k>
    <arrayId> LI </arrayId>
    <arraystore>... L |-> (_ => V) :: elem T:Type ...</arraystore>

rule [store-array-location-check-type]:
    <k>
      store(aeloc(LI:Int, L:Int), V:RawVal::T:Type)
      =>  ifAux(subtype(typeOf(V), StoreType),
             store(aeloc(LI, L), V::StoreType),
             throw new class String2Id("java.lang.ArrayStoreException") (
                //the ArrayStoreException argument is the assigned object type
                (V::T .((String2Id("getClass")):>MethodName) (.TypedVals)) .((String2Id("getName")):>MethodName) (.TypedVals)
            );
          )
      ...
    </k>
    <arrayId> LI </arrayId>
    <arraystore>... L |-> _ :: elem StoreType:Type ...</arraystore>
when
    T =/=K StoreType

//@ \subsection{Array initializer}

//@ Allocates the array based on previously computed size, then proceeds to array initialization
syntax KItem ::=  arrayInitAlloc (
                K,        //newArrayAlloc(), reduces to arrayRef()
                ArrayInit //{InitContent} - list of initialization expressions
              )
              [strict(1)]

rule [arrayInitAlloc]:
    arrayInitAlloc(arrayRef(T:Type, L:Int, Len:Int)::T, {InitContent:VarInits})
    => arrayInitImpl(T, aeloc(L, 0), {InitContent}) ~> arrayRef(T, L, Len)::T

syntax KItem ::=  arrayInitImpl (
                Type,     //T - array type, used by inner ArrayInit's
                ArrayElemLoc,      //L - location of first element in store
                ArrayInit //InitContent - list of initialization expressions
              )

rule [arrayInitImpl-not-ArrayInit]:
    ( . => store(aeloc(L, Index), E) )
    ~> arrayInitImpl(
                    _,
                    aeloc(L, (Index:Int => Index +Int 1)),
                    ({E:Exp, Remaining:VarInits} => {Remaining})
       )


rule [arrayInitImpl-inner-ArrayInit-desugar]:
    ( . => store(aeloc(L, Index), (new arrayOf T .Dims A)) )
    ~> arrayInitImpl(
          arrayOf arrayOf T:Type,
          aeloc(L, (Index:Int => Index +Int 1)),
          ({A:ArrayInit, Remaining:VarInits} => {Remaining} )
       )

rule [arrayInitImpl-discard]:
    arrayInitImpl(_, _, {.VarInits}) => .

endmodule
