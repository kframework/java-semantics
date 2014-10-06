//@ \section{Module ARRAYS}

module ARRAYS
    imports CORE-SORTS
    imports SUBTYPING
    imports EXPRESSIONS
    imports SYNTAX-CONVERSIONS

/*@ The value in store that corresponds to an array element. The consturction "elem" Type is meant to
  distinguish between regular memory locations and array elements. Array elements need to be represented separately
  in order to support array polymorphism.
*/
syntax KItem ::=  RawVal "::" "elem" Type

/*@ \subsection{Array access}
Check array bounds, as part of the dynamic typing policy. */

// 'ArrayAccess(arrayRef(_)::arrayOf T:Type,, N:Int::_)
syntax KLabel ::= "'ArrayAccess"

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
      => fieldAccessCheckpoint(L) ~> subtype(T2, T1) ~> true? ~> (V::T1)
      ...
    </k>
    <store>... L |-> V:RawVal ::elem T2:Type ...</store>

rule [ArrayAccess-to-ArrayIndexOutOfBoundsException]:
    'ArrayAccess(arrayRef(_,_,M:Int) :: _,, N:Int::_)
    => throw new class String2Id("java.lang.ArrayIndexOutOfBoundsException") ( Int2String(N) );
when notBool ((N >=Int 0) andBool (N <Int M))
        [anywhere]

rule [ArrayAccess-null-to-NullPointerException]:
    'ArrayAccess(null::_,, _) => throw new classNullPointerException(null::classString);
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

/*  Either 'NewArray( T:ElemType,, ['Dim(N1),,'Dim('N2),, ...],, [...,, 'Dim(.KList),, ...] )
    Or     'NewArray( T:ElemType,, [...,, 'Dim(.KList),, ...],, 'ArrayInit(_) )
*/

syntax ArrayCreationExp ::= "new" Type DimExps Dims [klabel('NewArray)]
syntax ArrayCreationExp ::= "new" Type Dims ArrayInit [klabel('NewArray)]
syntax Exp ::= ArrayCreationExp
/* HOLE is of the form 'Dim(K)
  totest left-to-right evaluation of Dims
*/
//context 'NewArray(_:Type,, [Dims:KList,, HOLE,, _],, _)
//when isKResult(Dims)
//rule isKResult([_:KResult])=> true context new _:Type HOLE .Dims

syntax Dim ::= "[" "]" [klabel('Dim)]
syntax DimExp ::= "[" Exp "]" [strict, klabel('Dim)]
syntax Dims ::= List{Dim,""}
syntax DimExps ::= List{DimExp,""} [seqstrict]

syntax KItem ::= toDims( KListWrap , Dims) [function]
rule toDims([Ds:KList,, D:Dim], Es:Dims) => toDims([Ds], (D Es))
rule toDims([.KList], Es:Dims) => Es

syntax KItem ::= toDimExps( KListWrap , DimExps) [function]
rule toDimExps([Ds:KList,, D:DimExp], Es:DimExps) => toDimExps([Ds], (D Es))
rule toDimExps([.KList], Es:DimExps) => Es

//todo: move it to somewhere else?
rule 'NewArray(_,,([D:DimExp,,Ds:KList] => toDimExps([D,,Ds],.DimExps)),,([Dims:KList] => toDims([Dims],.Dims)))
rule 'NewArray(_,,([D:Dim,,Ds:KList] => toDims([D,,Ds],.Dims)),,_)
rule 'NewArray(_,,([.KList] => .Dims),,_)


/*@ When all dims were computed, check that dims are positive, and only
    after that begin array allocation
*/
rule [NewArray-simple]:
    new T:Type Ds:DimExps _:Dims
    => checkNonNegative(Ds) ~> allocAndInitArray(T, Ds, default(T))
        [structural]

rule [NewArray-ArrayInit]:
    new T:Type Ds:Dims ({InitContent:VarInits})<:ArrayInit
    => arrayInitAlloc(new T [length(InitContent)::int] Ds, {InitContent})

syntax KItem ::= length (VarInits)                                  [function]
rule length(V:VarInit, Vs:VarInits) => length(Vs)+Int 1
rule length(.VarInits) => 0

/*Computation designed to check that array creation expression dimensions are non-negative. If they are non-negative,
checkNonNegative is dissolved. Otherwise NegativeArraySizeException is thrown.
*/
syntax KItem ::=  checkNonNegative (DimExps)
context checkNonNegative ([HOLE] _)

rule checkNonNegative([NI:Int::_ ] Remainings:DimExps)=> checkNonNegative(Remainings)
when NI >=Int 0

rule [checkNonNegative-to-NegativeArraySizeException]:
    checkNonNegative([NI:Int::_] _)
    => throw new class String2Id("java.lang.NegativeArraySizeException") (null::classString);
when
    NI <Int 0

rule checkNonNegative(.DimExps) => .

//@ Same as 'NewArray, but after dims were computed and checked
syntax KItem ::=  allocAndInitArray (
                Type, // T - type of each allocated element. So for new int[1][1][][], T will be "arrayOf arrayOf int".
                DimExps,  // DimExps:List{DimExp} - array dimensions
                K     // InitExp - expression used to initialize each array element
              )
context allocAndInitArray(_,[HOLE] _, _)

rule [allocAndInitArray-MultiDim-desugar]:
    allocAndInitArray(T:Type, Dim1K:DimExp Dim2K:DimExp DEs:DimExps, InitExp:K)
    =>  allocAndInitArray(
          arrayOf T,
          Dim1K,
          allocAndInitArray(T, Dim2K DEs, InitExp)
        )
        [structural]

/*@ The increment of <nextLoc> by one is required to avoid problems with empty arrays.
  Two empty arrays allocated one after another should have different starting locations, even if those starting
  locations are not used. This is required to identify them as two different objects. Their distinction
  could be tested by the operator ==.
*/
rule [allocAndInitArray]:
    <k>
      allocAndInitArray(T:Type, [NI:Int::_], InitExp:K)
      => allocArray(NI, T) ~> initArray(LI +Int 1, NI, InitExp)
         ~> arrayRef( arrayOf T, LI +Int 1, NI) :: arrayOf T
      ...
    </k>
    <nextLoc> LI:Int => LI +Int 1 </nextLoc>

//@ Maximum of two numbers
syntax KItem ::=  max ( Int, Int )          [function]
rule max(I1:Int, I2:Int) => #if I1 >=Int I2
                              #then I1
                              #else I2
                            #fi

/*@ Allocates the given number of elements in the store of the given Type. Used by array instantiation logic.
*/
syntax KItem ::=  allocArray (
                Int,  //The number of elements to allocate
                Type  //The type of each element
              )

rule [allocArray]:
    <k> allocArray(N:Int => N -Int 1, T:Type) ...</k>
    <store>... . => LI |-> (undefined :: elem T) ...</store>
    <storeMetadata>... . => LI |-> FieldLocMetadata ...</storeMetadata>
    <nextLoc> LI:Int => LI +Int 1 </nextLoc>
when
    N >Int 0

rule allocArray(0, _) => .K       [structural]

/*@ Assign to each store location in the given range the value represented by the 3-rd argument. This value might be
  freshly computed for each element, and might alter another locations in the store, as is the case for multidim arrays.
  This procedure don't change the element type in the store.
*/
syntax KItem ::=  initArray (
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

rule [storeImpl-array-elem]:
    <k> storeImpl(L:Int, V:RawVal :: T:Type) => . ...</k>
    <store>... L |-> (_ => V) :: elem T:Type ...</store>

rule [storeImpl-array-location-check-type]:
    <k>
      storeImpl(L:Int, V:RawVal::T:Type)
      =>  if(subtype(typeOf(V), StoreType))
            {storeImpl(L, V::StoreType)}
            else
            {throw new class String2Id("java.lang.ArrayStoreException") (
                //the ArrayStoreException argument is the assigned object type
                (V::T .String2Id("getClass") (.TypedVals)) .String2Id("getName") (.TypedVals)
            );
          }
      ...
    </k>
    <store>... L |-> _ :: elem StoreType:Type ...</store>
when
    T =/=K StoreType

//@ \subsection{Array initializer}

//@ Allocates the array based on previously computed size, then proceeds to array initialization
syntax KItem ::=  arrayInitAlloc (
                K,        //newArrayAlloc(), reduces to arrayRef()
                ArrayInit //InitContent - list of initialization expressions
              )
              [strict(1)]

rule [arrayInitAlloc]:
    arrayInitAlloc(arrayRef(T:Type, L:Int, Len:Int)::T, {InitContent:VarInits})
    => arrayInitImpl(T, L, {InitContent}) ~> arrayRef(T, L, Len)::T

syntax KItem ::=  arrayInitImpl (
                Type,     //T - array type, used by inner ArrayInit's
                Int,      //L - location of first element in store
                ArrayInit //InitContent - list of initialization expressions
              )

rule [arrayInitImpl]:
    ( . => store(L, E) )
    ~> arrayInitImpl(_, (L:Int => L +Int 1), ({E:Exp,Remaining:VarInits} => {Remaining}) )


rule [arrayInitImpl-inner-ArrayInit-desugar]:
    ( . => store(L, new arrayOf T .Dims A) )
    ~> arrayInitImpl(
          arrayOf arrayOf T:Type,
          (L:Int => L +Int 1),
            ( {A:ArrayInit, Remaining:VarInits} => {Remaining} )
       )

rule [arrayInitImpl-discard]:
    arrayInitImpl(_, _, {.VarInits}) => .

syntax VarInit ::= Exp|ArrayInit
syntax ArrayInit ::= "{" VarInits "}" [strict,klabel('ArrayInit)]
syntax VarInits ::= List{VarInit, ","}

syntax KItem ::= toVarInits( KListWrap , VarInits) [function]
rule toVarInits([Args:KList,, Arg:VarInit], Es:VarInits) => toVarInits([Args], (Arg,Es))
rule toVarInits([.KList], Es:VarInits) => Es
//todo: move it to somewhere else?
rule 'ArrayInit([InitContent:KList]) => 'ArrayInit(toVarInits([InitContent], .VarInits)) [anywhere]

endmodule
