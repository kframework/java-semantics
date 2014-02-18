require "core.k"
require "subtyping.k"
require "expressions.k"

//@ \section{Module ARRAYS}

module ARRAYS
    imports CORE
    imports SUBTYPING
    imports EXPRESSIONS

syntax K ::= RawVal "::" "elem" Type

//@ \subsection{Array declarators with c-style dimensions and initializers}

//C-style array declaration
//Applied in both elaboration and execution phase
rule [ArrayVarDecIdDesugar]:
    'LocalVarDec(
      _:K,,
      (T:Type => arrayOf T),,
      'ListWrap('VarDec('ArrayVarDecId(
          X:Id,,
          'ListWrap(('Dim(.KList) => .KList) ,,_)
      ),, _:KList //possible initializer
    )))                                                 [structural, anywhere]

rule [ArrayVarDecIdDiscard]:
    'LocalVarDec(_:K,, T:Type,, 'ListWrap('VarDec(
        ( 'ArrayVarDecId( X:Id,, 'ListWrap(.KList) ) => X ),,
        _:KList //possible initializer
    )))                                                 [structural, anywhere]

rule [VarDecWithArrayInitDesugar]:
    'LocalVarDec(_:K,, T:Type,, 'ListWrap('VarDec(
      X:Id,,
      ( 'ArrayInit(InitK:K) => elab('NewArray(T,, 'ListWrap(.KList),, 'ArrayInit(InitK))) )
    )))                                                 [structural, anywhere]

//same three rules for fields

rule [ArrayFieldDecIdDesugar]:
    'FieldDec(
      _:K,,
      (T:Type => arrayOf T),,
      'ListWrap('VarDec('ArrayVarDecId(
          X:Id,,
          'ListWrap(('Dim(.KList) => .KList) ,,_)
      ),, _:KList //possible initializer
    )))                                                 [structural]

rule [ArrayFieldDecIdDiscard]:
    'FieldDec(_:K,, T:Type,, 'ListWrap('VarDec(
        ( 'ArrayVarDecId( X:Id,, 'ListWrap(.KList) ) => X ),,
        _:KList //possible initializer
    )))                                                 [structural]

rule [FieldDecWithArrayInitDesugar]:
    'FieldDec(_:K,, T:Type,, 'ListWrap('VarDec(
      X:Id,,
      ( 'ArrayInit(InitK:K) => elab('NewArray(T,, 'ListWrap(.KList),, 'ArrayInit(InitK))) )
    )))                                                 [structural]

//first two rules - desugaring C-like array declarations, for params

/*@ Thi rule and the next one may happen both in elaboration, execution or process members phases.
They are required to be [anywhere]. */
rule [ArrayParamIdDesugar]:
    'Param(
      _:K,,
      (T:Type => arrayOf T),,
      'ArrayVarDecId(
          X:Id,,
          'ListWrap(('Dim(.KList) => .KList) ,,_)
      )
    )                                                   [structural, anywhere]

rule [ArrayParamIdDiscard]:
    'Param(
      _:K,, T:Type,,
      ( 'ArrayVarDecId( X:Id,, 'ListWrap(.KList) ) => X )
    )                                                   [structural, anywhere]

/*@ \subsection{Array access}
Check array bounds, as part of the dynamic typing policy. */

context 'ArrayAccess(HOLE,,_)
context 'ArrayAccess(_:KResult,,HOLE)
context lvalue('ArrayAccess(HOLE,,_))
context lvalue('ArrayAccess(_:KResult,,HOLE))

rule [arrayLookup]:
    'ArrayAccess(arrayRef(_, L:Int, M:Int) :: arrayOf T:Type,, N:Int::_)
    => lookup(L +Int N, T)
when (N >=Int 0) andBool (N <Int M)
        [structural, anywhere]

rule [lookupArrayLocation]:
    <k>
      lookup(L:Int, T1:Type)
      => subtype(T2, T1) ~> true? ~> (V::T1)
      ...
    </k>
    <store>... L |-> V:RawVal ::elem T2:Type ...</store>
        [transition-threading]

rule [ArrayIndexOutOfBoundsException]:
    'ArrayAccess(arrayRef(_,_,M:Int) :: _,, N:Int::_)
    => elab('Throw('NewInstance(
      'None(.KList),,
      (class String2Id("java.lang.ArrayIndexOutOfBoundsException")),,
      'ListWrap( Int2String(N) ),,
      'None(.KList)
    )))
when notBool ((N >=Int 0) andBool (N <Int M))
        [structural, anywhere]

/*@ Required when a JVM-related exception (e.g. produced by the semantics at runtime) is thrown inside a lvalue.
*/
rule [LvalueIndexOutOfBoundsDesugar]:
    lvalue(elab('Throw(K:K))) => elab('Throw(K))

rule [arrayAccessNull]:
    'ArrayAccess(null::_ ,, _)
    => elab('Throw('NewInstance(
      'None(.KList),,
      class String2Id("java.lang.NullPointerException"),,
      'ListWrap( null ),,
      'None(.KList)
    )))
        [structural, anywhere]

//Array length, as defined in JDK
rule
    lookupField(arrayRef(_,_:Int, N:Int)::_, _, X:Id) => N::int
when
    Id2String(X) ==String "length"

//@ \subsection{New array allocation}
/*@ The dynamic semantics of typed array declarations is
similar to that in untyped SIMPLE, but we have to enforce that the
type of an array declaration be of the form \texttt{arrayOf $T$}
and assign the right type ($T$) to the allocated array locations. */

context newArrayImpl(_:Type, 'ListWrap(Dims:KList,,HOLE,, _), _,_)
when isKResult(Dims)

//applies right after the previous rule, because HOLE is of the form 'Dim(K)
rule 'Dim(K:K) => K [structural]

//when all dims were computed, check that dims are positive, and only
//after that begin array allocation
rule newArrayImpl(T:Type, 'ListWrap(Dims:KList), InitExp:K, .KList)
    => checkNonNegative(Dims) ~> newArrayAlloc(T, 'ListWrap(Dims), InitExp)
when isKResult(Dims) andBool InitExp =/=K .K

rule [newArrayWithInit]:
    newArrayImpl(T:Type, 'ListWrap(Dim:TypedVal), .K, InitContent:KList)
    => arrayInitAlloc(newArrayImpl(T, 'ListWrap(Dim), undefined :: T, .KList), InitContent)

//same as newArrayImpl, but after dims were computed and checked
syntax K ::= "newArrayAlloc" "("
                Type ","  // T - type of each allocated element. So for new int[1][1][][], T will be "arrayOf arrayOf int".
                K ","     // 'ListWrap(Dims:List{KResult}) - array dimensions
                K         // InitExp - expression used to initialize each array element
             ")"

/*Computation designed to check that array creation expression dimensions are non-negative. If they are non-negative, checkNonNegative is dissolved. Otherwise NegativeArraySizeException is thrown.
*/
syntax K ::= "checkNonNegative" "("
                KList           // List{KResult} - computed array dimensions
             ")"

rule checkNonNegative((NI:Int::_ => .KList),, _)
when NI >=Int 0

rule [NegativeArraySizeException]:
    checkNonNegative((NI:Int::_),, _)
    => elab('Throw('NewInstance(
      'None(.KList),,
      class String2Id("java.lang.NegativeArraySizeException"),,
      'ListWrap( null ),,
      'None(.KList)
    )))
when
    NI <Int 0

rule checkNonNegative(.KList) => .

rule [newArrayAllocMultiDim]:
    newArrayAlloc(T:Type, 'ListWrap(Dims:KList,,Dim1K:TypedVal,,Dim2K:TypedVal), InitExp:K)
    =>  newArrayAlloc(
          arrayOf T,
          'ListWrap(Dims,,Dim1K),
          newArrayAlloc(T, 'ListWrap(Dim2K), InitExp)
        )
when isKResult(Dims)
        [structural]

//In order to avoid problems with empty arrays, such as the test for equality,
//even if the created array is empty it will increment nextLoc by one
rule [newArrayAlloc]:
    <k>
      newArrayAlloc(T:Type, 'ListWrap(NI:Int::_), InitExp:K)
      => evalAndStore((LI:Int .. LI +Int (NI -Int 1)), InitExp)
         ~> arrayRef( arrayOf T, LI, NI) :: arrayOf T
      ...
    </k>
    <store>... .Map => Map((LI .. LI +Int (NI -Int 1)) |-> (undefined :: elem T)) ...</store>
    <nextLoc> LI:Int => LI +Int max(NI,1) </nextLoc>

syntax K ::= "max" "(" Int "," Int ")" [function]
rule max(I1:Int, I2:Int) => #if I1 >=Int I2
                              #then I1
                              #else I2
                            #fi

syntax K ::= "evalAndStore" "(" KList  "," K ")"

rule [evalAndStoreDesugar]:
    evalAndStore((I1:Int,, I2:Int,, Ks:KList), InitExp:K)
    => evalAndStore(I1,InitExp) ~> evalAndStore((I2,,Ks),InitExp)
        [structural]

context evalAndStore(_:Int, HOLE)

rule [evalAndStore]:
    <k>
      evalAndStore(L:Int, V:RawVal :: T2:Type) => subtype(T2, T1) ~> true?
      ...
    </k>
    <store>... L |-> (_ => V) :: elem T1:Type ...</store>
        [transition-threading]

rule [evalAndStoreEmpty]:
    evalAndStore(.KList, _) => .
        [structural]

//@ Sequences of locations

syntax KList ::= Int ".." Int                                   [function]
rule N1:Int..N2:Int => .KList              when N1  >Int N2
rule N1:Int..N2:Int => N1 ,, (N1 +Int 1)..N2 when N1 <=Int N2

//@ \subsection{Array element assignment}

rule [AssignInArrayExact]:
    <k> 'Assign(loc(L:Int)::T,, V:RawVal::_) => V::T ...</k>
    <store>... L |-> (_ => V)::elem T ...</store>
        [transition-threading]

rule [AssignInArrayWithCheck]:
    <k>
      'Assign(loc(L:Int)::T,, V:RawVal::_)
      => assignImpl(
          subtype(typeOf(V), StoreType),
          L,
          V::T
      )
      ...
    </k>
    <store>... L |-> _ :: elem StoreType:Type ...</store>
when
    T =/=K StoreType


/*@ Assignment with runtime type compatibility check. If first argument evaluates to true, do the assignment.
  Otherwise throw ArrayStoreException.
*/
syntax K ::= "assignImpl" "("
                            K ","     //subtype check on array element assignment
                            Int ","   //destination store location
                            TypedVal  //assigned value
                          ")"
        [strict(1,3)]

rule [assignImpl]:
    <k> assignImpl( true::bool, L:Int, V:RawVal :: T:Type) => V::T ...</k>
    <store>... L |-> (_ => V) :: elem _ ...</store>
        [transition-threading]

rule [ArrayStoreException]:
    assignImpl( false::bool, _, TV:TypedVal)
    =>  elab('Throw('NewInstance(
          'None(.KList),,
          (class String2Id("java.lang.ArrayStoreException")),,
          'ListWrap(
            //the ArrayStoreException argument is the assigned object type
            'Invoke(
              'MethodName(
                'Invoke(
                  'MethodName(TV,, String2Id("getClass")),,
                  'ListWrap(.KList)
                ),,
                String2Id("getName")),,
              'ListWrap(.KList)
            )
          ),,
          'None(.KList)
        )))

//@ \subsection{Array initializer}

//allocates the array based on previously computed size, the proceeds to array initialization
syntax K ::= "arrayInitAlloc" "("
                                  K "," //newArrayAlloc(), reduces to arrayRef()
                                  KList //InitContent - list of initialization expressions
                              ")"
        [strict(1)]

//todo K 10341 it looks like [strict] above don't work
context arrayInitAlloc(HOLE,_)

rule [arrayInitAlloc]:
    arrayInitAlloc(arrayRef(T:Type, L:Int, Len:Int)::T, InitContent:KList)
    => arrayInitImpl(T, L, InitContent) ~> arrayRef(T, L, Len)::T

syntax K ::= "arrayInitImpl" "("
                                  Type ","//T - array type
                                          //    used by inner ArrayInit's
                                  Int "," //L - location of first element in store
                                  KList //InitContent - list of initialization expressions
                              ")"

rule [arrayInitImpl]:
    ( . => 'ExprStm(assignImpl(true, L, K)) )
    ~> arrayInitImpl(_, (L:Int => L +Int 1), ((K:K => .KList),, _) )
when
    getKLabel(K) =/=KLabel 'ArrayInit

rule [arrayInitImplInnerArrayInit]:
    ( . => 'ExprStm(assignImpl(
              true,
              L,
              newArrayImpl(T, 'ListWrap(length(InitContent)::int), .K, InitContent)
           )) )
    ~> arrayInitImpl(
          arrayOf arrayOf T:Type,
          (L:Int => L +Int 1),
          (('ArrayInit('ListWrap(InitContent:KList)) => .KList),, _)
       )

rule [arrayInitImplDiscard]:
    arrayInitImpl(_, _, .KList) => .

//@ toString

rule toString(arrayOf T:Type) => arrayToString(arrayOf T)

//string representation of a type within an array type
//see JDK: Class.getName()
syntax K ::= "arrayToString" "(" Type ")"
rule arrayToString(byte)  => "B"::rtString
rule arrayToString(short) => "S"::rtString
rule arrayToString(int)   => "I"::rtString
rule arrayToString(long)  => "J"::rtString
rule arrayToString(char)  => "C"::rtString
rule arrayToString(bool)  => "Z"::rtString

rule arrayToString(class Class:Id)
    => 'Plus("L"::rtString,, 'Plus(toString(class Class) ,,";"::rtString))

rule arrayToString(rtString)
    => 'Plus("L"::rtString,, 'Plus(toString(rtString),, ";"::rtString))

rule arrayToString(arrayOf T:Type) => 'Plus("["::rtString,, arrayToString(T))

endmodule
