module JAVA-ARRAYS
    imports JAVA-CORE
    imports JAVA-EXPRESSIONS

syntax Type ::= "arrayOf" Type
                  [prec(1) latex "{#1}\texttt{\char91\char93}"]

syntax Val ::= "arrayRef" "(" Type "," #Int "," #Int ")"

/*@ \subsection{Array access}
Check array bounds, as part of the dynamic typing policy. */

syntax KLabel ::= 'ArrayAccess [seqstrict]
context lvalue('ArrayAccess(HOLE,,_))
context lvalue('ArrayAccess(_:KResult,,HOLE))

rule [arrayLookup]:
    'ArrayAccess(arrayRef(_,L,M:#Int),, N:#Int) => lookup(L +Int N)
when N >=Int 0 andBool N <Int M
        [structural anywhere]

//Array length, as defined in JDK
syntax #Id ::= "length"
rule 'ExprName(arrayRef(_,_:#Int,N),, length) => N

//@ \subsection{Array Type}

context 'ArrayType(HOLE)

rule 'ArrayType(T:Type) => arrayOf T [structural]

//@ \subsection{New array allocation}
/*@ The dynamic semantics of typed array declarations is
similar to that in untyped SIMPLE, but we have to enforce that the
type of an array declaration be of the form \texttt{arrayOf $T$}
and assign the right type ($T$) to the allocated array locations. */

context 'NewArray(HOLE,, _:List{K})

rule [NewArrayEmptyDims]:
    'NewArray((T => arrayOf T),,_,,'ListWrap(('Dim(.List{K})
    => .List{K}) ,,_:List{K}))
        [structural]

rule [NewArray]:
    'NewArray(T,, K:K,, 'ListWrap(.List{K})) => newArrayImpl(T, K, undefined(T))
        [structural]

syntax K ::= "newArrayImpl" "("
                Type ","  // T - element type
                K ","     // 'ListWrap(Dims) - array dimensions
                K         // InitExp
             ")"

rule [newArrayImplMultiDim]:
    newArrayImpl(T, 'ListWrap(Dims:List{K},,Dim1K:K,,Dim2K:K), InitExp)
    =>  newArrayImpl(
          arrayOf T,
          'ListWrap(Dims,,Dim1K),
          newArrayImpl(T, 'ListWrap(Dim2K), InitExp)
        )
        [structural]

context newArrayImpl(_:KResult, 'ListWrap('Dim(HOLE)), _)

rule [newArrayImpl]:
    <k>
      newArrayImpl(T, 'ListWrap('Dim(NI:#Int)), InitExp:K)
      => evalAndStore((LI:#Int .. LI +Int _-Int_(NI,1)),InitExp)
         ~> arrayRef( arrayOf T, LI, NI)
      ...
    </k>
    <store>... . => LI .. LI +Int _-Int_(NI,1) |-> undefined(void) ...</store>
    <nextLoc> LI:#Int => LI +Int NI </nextLoc>

  syntax K ::= "evalAndStore" "(" List{K}  "," K ")"

rule [evalAndStoreDesugar]:
    evalAndStore((I1:#Int,,I2:#Int,,Ks:List{K}),InitExp)
    => evalAndStore(I1,InitExp) ~> evalAndStore((I2,,Ks),InitExp)
        [structural]

context evalAndStore(_:KResult, HOLE)

rule [evalAndStore]:
    <k> evalAndStore(L:#Int,V:Val) =>. ...</k>
    <store>... L |->(_=>V) ...</store>

rule [evalAndStoreEmpty]:
    evalAndStore(.List{K}, _) => .
        [structural]

//@ \subsection{Array auxiliary constructs}

define typeOf(arrayRef(T,_:#Int,_:#Int)) => T

//@ Sequences of locations

syntax List{K} ::= #Int ".." #Int
define N1:#Int..N2:#Int => .List{K}              when N1  >Int N2
define N1:#Int..N2:#Int => N1 ,, (N1 +Int 1)..N2 when N1 <=Int N2

end module
