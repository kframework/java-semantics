require "java-core.k"
require "java-subtyping.k"
require "java-expressions.k"

module JAVA-ARRAYS
    imports JAVA-CORE
    imports JAVA-SUBTYPING
    imports JAVA-EXPRESSIONS

syntax K ::= RawVal "::" "elem" Type

//@ \subsection{Array declarators with c-style dimensions and inits}

//C-style array dec
//Applied in both elaboration and execution phase
rule [ArrayVarDecIdDesugar]:
    'LocalVarDec(
      _:K,,
      (T:Type => arrayOf T),,
      'ListWrap('VarDec('ArrayVarDecId(
          X:Id,,
          'ListWrap(('Dim(.List{K}) => .List{K}) ,,_)
      ),, _:List{K} //possible initializer
    )))                                                 [structural, anywhere]

rule [ArrayVarDecIdDiscard]:
    'LocalVarDec(_:K,, T:Type,, 'ListWrap('VarDec(
        ( 'ArrayVarDecId( X:Id,, 'ListWrap(.List{K}) ) => X ),,
        _:List{K} //possible initializer
    )))                                                 [structural, anywhere]

rule [VarDecWithArrayInitDesugar]:
    'LocalVarDec(_:K,, T:Type,, 'ListWrap('VarDec(
      X:Id,,
      ( 'ArrayInit(InitK:K) => 'NewArray(T,, 'ListWrap(.List{K}),, 'ArrayInit(InitK)) )
    )))                                                 [structural, anywhere]

//same three rules for fields

rule [ArrayFieldDecIdDesugar]:
    'FieldDec(
      _:K,,
      (T:Type => arrayOf T),,
      'ListWrap('VarDec('ArrayVarDecId(
          X:Id,,
          'ListWrap(('Dim(.List{K}) => .List{K}) ,,_)
      ),, _:List{K} //possible initializer
    )))                                                 [structural]

rule [ArrayFieldDecIdDiscard]:
    'FieldDec(_:K,, T:Type,, 'ListWrap('VarDec(
        ( 'ArrayVarDecId( X:Id,, 'ListWrap(.List{K}) ) => X ),,
        _:List{K} //possible initializer
    )))                                                 [structural]

rule [FieldDecWithArrayInitDesugar]:
    'FieldDec(_:K,, T:Type,, 'ListWrap('VarDec(
      X:Id,,
      ( 'ArrayInit(InitK:K) => 'NewArray(T,, 'ListWrap(.List{K}),, 'ArrayInit(InitK)) )
    )))                                                 [structural]

//first two rules - desugaring C-like array decs, for params

rule [ArrayParamIdDesugar]:
    'Param(
      _:K,,
      (T:Type => arrayOf T),,
      'ArrayVarDecId(
          X:Id,,
          'ListWrap(('Dim(.List{K}) => .List{K}) ,,_)
      )
    )                                                   [structural]

rule [ArrayParamIdDiscard]:
    'Param(
      _:K,, T:Type,,
      ( 'ArrayVarDecId( X:Id,, 'ListWrap(.List{K}) ) => X )
    )                                                   [structural]

/*@ \subsection{Array access}
Check array bounds, as part of the dynamic typing policy. */

context 'ArrayAccess(HOLE,,_)::_
context 'ArrayAccess(_:KResult,,HOLE)::_
context lvalue('ArrayAccess(HOLE,,_)::_)
context lvalue('ArrayAccess(_:KResult,,HOLE)::_)

rule [arrayLookup]:
    'ArrayAccess(arrayRef(_, L:Int, M:Int) :: arrayOf T:Type,, N:Int::_) :: T
    => lookup(L +Int N) :: T
when (N >=Int 0) andBool (N <Int M)
        [structural, anywhere]

rule [lookupArrayLocation]:
    <k>
      lookup(L:Int) :: T1:Type
      => subtype(T2, T1) ~> true? ~> (V::T1)
      ...
    </k>
    <store>... L |-> V:RawVal ::elem T2:Type ...</store>

rule [ArrayIndexOutOfBoundsException]:
    'ArrayAccess(arrayRef(_,_,M:Int) :: _,, N:Int::_)::_
    => 'Throw('NewInstance(
      'None(.List{K}),,
      (class String2Id("java.lang.ArrayIndexOutOfBoundsException")),,
      'ListWrap( Int2String(N) ),,
      'None(.List{K})
    ))
when notBool ((N >=Int 0) andBool (N <Int M))
        [structural, anywhere]

//Required to desugar effects of the previous rule, when exception happens
//inside lvalue.
rule [LvalueIndexOutOfBoundsDesugar]:
    lvalue('Throw(K:K)) => 'Throw(K)

rule [arrayAccessNull]:
    'ArrayAccess(null::_ ,, _)::_
    => 'Throw('NewInstance(
      'None(.List{K}),,
      class String2Id("java.lang.NullPointerException"),,
      'ListWrap( null ),,
      'None(.List{K})
    ))
        [structural, anywhere]

//Array length, as defined in JDK
rule
    lookupField(arrayRef(_,_:Int, N:Int)::_, _, X:Id) :: int => N::int
when
    Id2String(X) ==String "length"

//@ \subsection{New array allocation}
/*@ The dynamic semantics of typed array declarations is
similar to that in untyped SIMPLE, but we have to enforce that the
type of an array declaration be of the form \texttt{arrayOf $T$}
and assign the right type ($T$) to the allocated array locations. */

context newArrayImpl(_:Type, 'ListWrap(Dims:List{K},,HOLE,, _), _,_)::_
when isKResult(Dims)

//applies right after the previous rule, because HOLE is of the form 'Dim(K)
rule 'Dim(K:K) => K [structural]

//when all dims were computed, check that dims are positive, and only
//after that begin array allocation
rule newArrayImpl(T:Type, 'ListWrap(Dims:List{K}), InitExp:K, .List{K})::_
    => checkNonNegative(Dims) ~> newArrayAlloc(T, 'ListWrap(Dims), InitExp)
when isKResult(Dims) andBool InitExp =/=K .K

rule [newArrayWithInit]:
    newArrayImpl(T, 'ListWrap(Dim:TypedVal), .K, InitContent:List{K})::_
    => arrayInitAlloc(newArrayImpl(T, 'ListWrap(Dim), undefined :: T, .List{K}) :: arrayOf T, InitContent)

//same as newArrayImpl, but after dims were computed and checked
syntax K ::= "newArrayAlloc" "("
                Type ","  // T - type of each allocated element. So for new int[1][1][][], T will be "arrayOf arrayOf int".
                K ","     // 'ListWrap(Dims:List{KResult}) - array dimensions
                K         // InitExp - expression used to initialize each array element
             ")"

/*Computation designed to check that array creation expression dimensions are non-negative. If they are non-negative, checkNonNegative is dissolved. Otherwise NegativeArraySizeException is thrown.
*/
syntax K ::= "checkNonNegative" "("
                List{K}           // List{KResult} - computed array dimensions
             ")"

rule checkNonNegative((NI:Int::_ => .List{K}),, _)
when NI >=Int 0

rule [NegativeArraySizeException]:
    checkNonNegative((NI:Int::_),, _)
    => 'Throw('NewInstance(
      'None(.List{K}),,
      class String2Id("java.lang.NegativeArraySizeException"),,
      'ListWrap( null ),,
      'None(.List{K})
    ))
when
    NI <Int 0

rule checkNonNegative(.List{K}) => .

rule [newArrayAllocMultiDim]:
    newArrayAlloc(T:Type, 'ListWrap(Dims:List{K},,Dim1K:TypedVal,,Dim2K:TypedVal), InitExp:K)
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
        [anywhere]

syntax K ::= "evalAndStore" "(" List{K}  "," K ")"

rule [evalAndStoreDesugar]:
    evalAndStore((I1:Int,, I2:Int,, Ks:List{K}), InitExp:K)
    => evalAndStore(I1,InitExp) ~> evalAndStore((I2,,Ks),InitExp)
        [structural]

context evalAndStore(_:Int, HOLE)

rule [evalAndStore]:
    <k>
      evalAndStore(L:Int, V:RawVal :: T2:Type) => subtype(T2, T1) ~> true?
      ...
    </k>
    <store>... L |-> (_ => V) :: elem T1:Type ...</store>

rule [evalAndStoreEmpty]:
    evalAndStore(.List{K}, _) => .
        [structural]

//@ Sequences of locations

syntax List{K} ::= Int ".." Int
rule N1:Int..N2:Int => .List{K}              when N1  >Int N2 [anywhere]
rule N1:Int..N2:Int => N1 ,, (N1 +Int 1)..N2 when N1 <=Int N2 [anywhere]

//@ \subsection{Array element assignment}

rule [AssignInArrayExact]:
    <k> 'Assign(loc(L:Int)::_,, V:RawVal::_)::T => V::T ...</k>
    <store>... L |-> (_ => V)::elem T ...</store>

rule [AssignInArrayWithCheck]:
    <k>
      'Assign(loc(L:Int)::_,, V:RawVal::_)::T
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

//Bug. [strict(1,3)] gives a weird error in K2. Have to use context for argument (3).
syntax K ::= "assignImpl" "("
                            K ","     //subtype check on array element assignment
                            Int ","   //destination store location
                            TypedVal  //assigned value
                          ")"

context assignImpl(HOLE,_,_)
context assignImpl(_:KResult, _, HOLE)

rule [assignImpl]:
    <k> assignImpl( true::bool, L:Int, V:RawVal :: T:Type) => V::T ...</k>
    <store>... L |-> (_ => V) :: elem _ ...</store>

rule [ArrayStoreException]:
    assignImpl( false::bool, _, TV:TypedVal)
    =>  'Throw('NewInstance(
          'None(.List{K}),,
          (class String2Id("java.lang.ArrayStoreException")),,
          'ListWrap(
            //the ArrayStoreException argument is the assigned object type
            'Invoke(
              'MethodName(
                'Invoke(
                  'MethodName(TV,, String2Id("getClass")),,
                  'ListWrap(.List{K})
                ),,
                String2Id("getName")),,
              'ListWrap(.List{K})
            )
          ),,
          'None(.List{K})
        ))

//@ \subsection{Array initializer}

//allocates the array based on previously computed size, the proceeds to array initialization
syntax K ::= "arrayInitAlloc" "("
                                  K "," //newArrayAlloc(), reduces to arrayRef()
                                  List{K} //InitContent - list of initialization expressions
                              ")"
        [strict(1)]

rule [arrayInitAlloc]:
    arrayInitAlloc(arrayRef(T:Type, L:Int, Len:Int)::T, InitContent:List{K})
    => arrayInitImpl(T, L, InitContent) ~> arrayRef(T, L, Len)::T

syntax K ::= "arrayInitImpl" "("
                                  Type ","//T - array type
                                          //    used by inner ArrayInit's
                                  Int "," //L - location of first element in store
                                  List{K} //InitContent - list of initialization expressions
                              ")"

rule [arrayInitImpl]:
    ( . => 'ExprStm(assignImpl(true, L, K)) )
    ~> arrayInitImpl(_, (L:Int => L +Int 1), ((K:K => .List{K}),, _) )
when
    getKLabel(K) =/=KLabel 'ArrayInit

rule [arrayInitImplInnerArrayInit]:
    ( . => 'ExprStm(assignImpl(
              true,
              L,
              newArrayImpl(T, 'ListWrap(count(InitContent)), .K, InitContent) :: arrayOf T
           )) )
    ~> arrayInitImpl(
          arrayOf arrayOf T:Type,
          (L:Int => L +Int 1),
          (('ArrayInit('ListWrap(InitContent:List{K})) => .List{K}),, _)
       )

rule [arrayInitImplDiscard]:
    arrayInitImpl(_, _, .List{K}) => .

//@ toString

rule toString(arrayOf T:Type) => arrayToString(arrayOf T)

//string representation of a type within an array type
//see JDK: Class.getName()
syntax K ::= "arrayToString" "(" Type ")"
rule arrayToString(byte)  => "B"
rule arrayToString(short) => "S"
rule arrayToString(int)   => "I"
rule arrayToString(long)  => "J"
rule arrayToString(char)  => "C"
rule arrayToString(bool)  => "Z"

rule arrayToString(class Class:Id)
    => 'Plus("L",, 'Plus(toString(class Class) ,,";")::rtString)::rtString

rule arrayToString(rtString)
    => 'Plus("L",, 'Plus(toString(rtString),, ";")::rtString)::rtString

rule arrayToString(arrayOf T:Type) => 'Plus("[",, arrayToString(T))::rtString

endmodule
