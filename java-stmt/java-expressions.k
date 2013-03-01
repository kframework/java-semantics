require "java-core.k"

module JAVA-EXPRESSIONS
    imports JAVA-CORE

//@ \section{Operators}

syntax KLabel ::=
                //Infix operators
                  /* ||  */ "'LazyOr"      [strict(1)]
                | /* &&  */ "'LazyAnd"     [strict(1)]
                | /* |   */ "'Or"          [seqstrict]
                | /* ^   */ "'ExcOr"       [seqstrict]
                | /* &   */ "'And"         [seqstrict]
                | /* ==  */ "'Eq"          [seqstrict]
                | /* !=  */ "'NotEq"       [seqstrict]
                | /* <   */ "'Lt"          [seqstrict]
                | /* >   */ "'Gt"          [seqstrict]
                | /* <=  */ "'LtEq"        [seqstrict]
                | /* >=  */ "'GtEq"        [seqstrict]
                | /* <<  */ "'LeftShift"   [seqstrict]
                | /* >>  */ "'RightShift"  [seqstrict]
                | /* >>> */ "'URightShift" [seqstrict]
                | /* +   */ "'Plus"        [seqstrict]
                | /* -   */ "'Minus"       [seqstrict]
                | /* *   */ "'Mul"         [seqstrict]
                | /* /   */ "'Div"         [seqstrict]
                | /* %   */ "'Remain"      [seqstrict]

                //Prefix operators
                | /* ++  */ "'PreIncr"
                | /* --  */ "'PreDecr"
                | /* !   */ "'Not"         [strict]
                | /* ~   */ "'Complement"  [strict]
                  /* +   */               //Already defined
                  /* -   */

                //Postfix operators
                | /* ++  */ "'PostIncr"
                | /* --  */ "'PostDecr"

                //Ternary operators
                | /* ? : */ "'Cond"

rule /* true  || _ */ 'LazyOr(true :: bool,, _) => true :: bool
rule /* false || K */ 'LazyOr(false :: bool,, E:K) => E
rule /* true  && K */ 'LazyAnd(true :: bool,, E:K) => E
rule /* false && _ */ 'LazyAnd(false :: bool,, _) => false :: bool

rule /* I1 | I2 */ 'Or(I1:Int :: int,, I2:Int :: int) => (I1 |Int I2) :: int
rule /* B1 | B2 */ 'Or(B1:Bool :: bool,, B2:Bool :: bool) => (B1 orBool B2) :: bool
rule /* I1 ^ I2 */ 'ExcOr(I1:Int :: int,, I2:Int :: int) => (I1 xorInt I2) :: int
rule /* B1 ^ B2 */ 'ExcOr(B1:Bool :: bool,, B2:Bool :: bool) => (B1 xorBool B2) :: bool
rule /* I1 & I2 */ 'And(I1:Int :: int,, I2:Int :: int) => (I1 &Int I2) :: int
rule /* B1 & B2 */ 'And(B1:Bool :: bool,, B2:Bool :: bool) => (B1 andBool B2) :: bool

rule /* V1 == V2 */ 'Eq(V1:RawVal :: _,, V2:RawVal :: _) => (V1 ==K V2) :: bool
rule /* V1 != V2 */ 'NotEq(V1:RawVal :: _,, V2:RawVal :: _) => (V1 =/=K V2) :: bool
rule /* I1 <  I2 */ 'Lt(I1:Int :: int,, I2:Int :: int) => (I1 <Int I2) :: bool
rule /* I1 >  I2 */ 'Gt(I1:Int :: int,, I2:Int :: int) => (I1 >Int I2) :: bool
rule /* I1 <= I2 */ 'LtEq(I1:Int :: int,, I2:Int :: int) => (I1 <=Int I2) :: bool
rule /* I1 >= I2 */ 'GtEq(I1:Int :: int,, I2:Int :: int) => (I1 >=Int I2) :: bool

rule /* I1 <<  I2 */ 'LeftShift(I1:Int :: int,, I2:Int :: int) => (I1 <<Int (I2 &Int 31)) :: int //JLS 15.19
rule /* I1 >>  I2 */ 'RightShift(I1:Int :: int,, I2:Int :: int) => (I1 >>Int (I2 &Int 31)) :: int
rule /* I1 >>> I2 */ 'URightShift(I1:Int :: int,, I2:Int :: int)
  => 'Cond(
    (I2:Int >=Int 0)::bool,,
    'RightShift(I1:Int::int,, I2::int),,
    'Plus('RightShift(I1::int,, I2::int),, 'LeftShift(2::int,, 'Complement(I2::int)))
  )

rule /* I1 + I2     */ 'Plus(I1:Int :: T:Type,, I2:Int :: T) => normalize((I1 +Int I2) :: T)
rule /* Str1 + Str2 */ 'Plus(Str1:String :: rtString,, Str2:String :: rtString) => (Str1 +String Str2) :: rtString
rule /* Str + KR    */ 'Plus(_ :: rtString,, ( KR:KResult => toString(KR) ))
    when typeOf(KR) =/=K rtString
rule /* KR + Str    */ 'Plus(( KR:KResult => toString(KR) ),, _ :: rtString)
    when typeOf(KR) =/=K rtString

rule /* I1 - I2    */ 'Minus(I1:Int :: int,, I2:Int :: int) => (I1 -Int I2) :: int
rule /* I1 * I2    */ 'Mul(I1:Int :: int,, I2:Int :: int) => (I1 *Int I2) :: int
rule /* I1 / I2    */ 'Div(I1:Int :: int,, I2:Int :: int) => (I1 /Int I2) :: int
    when I2 =/=Int 0 //todo ArithmeticException
rule /* I1 % I2    */ 'Remain(I1:Int :: int,, I2:Int :: int) => (I1 %Int I2) :: int
    when I2 =/=Int 0 //todo ArithmeticException

// ++E
context 'PreIncr(HOLE => lvalue(HOLE))
rule /* ++loc(L) => loc(L) = lookup(L) + 1 */
  'PreIncr(loc(L)::int) => 'Assign(loc(L:Int)::int,, 'Plus(lookup(L)::int,, 1::int))

// --E
context 'PreDecr(HOLE => lvalue(HOLE))
rule /* --loc(L) => loc(L) = lookup(L) - 1 */
  'PreDecr(loc(L)::int) => 'Assign(loc(L:Int)::int,, 'Minus(lookup(L)::int,, 1::int))

rule /* ! B    */ 'Not(B:Bool :: bool) => (notBool B) :: bool
rule /* ~ I    */ 'Complement(I:Int :: int) => (~Int I) :: int
rule /* + I    */ 'Plus(I:Int :: int) => I :: int
rule /* - I    */ 'Minus(I:Int :: T:Type) => (0 -Int I) :: T

// E++
context 'PostIncr(HOLE => lvalue(HOLE))
rule /* loc(L)++ => (loc(L) = lookup(L) + 1) - 1 */
  'PostIncr(loc(L) :: int) => 'Minus( 'Assign(loc(L:Int) :: int,, 'Plus(lookup(L) :: int,, 1 :: int)),, 1 :: int)

// E--
context 'PostDecr(HOLE => lvalue(HOLE))
rule /* loc(L)-- => (loc(L) = lookup(L) - 1) + 1 */
  'PostDecr(loc(L) :: int) => 'Plus( 'Assign(loc(L:Int) :: int,, 'Minus(lookup(L) :: int,, 1 :: int)),, 1 :: int)

//semantically if and ?: are equivalent
rule 'Cond(Ks:List{K}) => 'If(Ks)

/*@ \subsubsection{Assignment operators}
Typed KOOL allows to assign subtype instance values to supertype lvalues.
Assignment operators are seqstrict according to JLS. */

syntax KLabel ::=
                  /* =    */ "'Assign"
                | /* +=   */ "'AssignPlus"
                | /* -=   */ "'AssignMinus"
                | /* *=   */ "'AssignMul"
                | /* /=   */ "'AssignDiv"
                | /* &=   */ "'AssignAnd"
                | /* |=   */ "'AssignOr"
                | /* ^=   */ "'AssignExcOr"
                | /* %=   */ "'AssignRemain"
                | /* <<=  */ "'AssignLeftShift"
                | /* >>=  */ "'AssignRightShift"
                | /* >>>= */ "'AssignURightShift"

context 'Assign((HOLE => lvalue(HOLE)),,_)
context 'Assign(_:KResult,,HOLE)

//todo check assign expression type in JLS
rule [Assign]:
    <k>
      'Assign(loc(L:Int) :: T1:Type,, V:RawVal :: T2:Type)
      => subtype T2, T1 ~> true? ~> unsafeCast(V::T2, T1)
      ...
    </k>
    <store>... L |-> (_ :: T1 => unsafeCast(V::T2, T1)) ...</store>
        [transition]

/* loc(L) += E => loc(L) = lookup(L) + E */
context 'AssignPlus((HOLE => lvalue(HOLE)),,_)
rule 'AssignPlus(loc(L:Int) :: T:Type,, E:K) => 'Assign(loc(L) :: T,, 'Plus(lookup(L) :: T,, E))

/* loc(L) -= E => loc(L) = lookup(L) - E */
context 'AssignMinus((HOLE => lvalue(HOLE)),,_)
rule 'AssignMinus(loc(L:Int)::T:Type,, E:K) => 'Assign(loc(L)::T,, 'Minus(lookup(L)::T,, E))

/* loc(L) *= E => loc(L) = lookup(L) * E */
context 'AssignMul((HOLE => lvalue(HOLE)),,_)
rule 'AssignMul(loc(L:Int)::T:Type,, E:K) => 'Assign(loc(L)::T,, 'Mul(lookup(L)::T,, E))

/* loc(L) /= E => loc(L) = lookup(L) / E */
context 'AssignDiv((HOLE => lvalue(HOLE)),,_)
rule 'AssignDiv(loc(L:Int)::T:Type,, E:K) => 'Assign(loc(L)::T,, 'Div(lookup(L)::T,, E))

/* loc(L) &= E => loc(L) = lookup(L) & E */
context 'AssignAnd((HOLE => lvalue(HOLE)),,_)
rule 'AssignAnd(loc(L:Int)::T:Type,, E:K) => 'Assign(loc(L)::T,, 'And(lookup(L)::T,, E))

/* loc(L) |= E => loc(L) = lookup(L) | E */
context 'AssignOr((HOLE => lvalue(HOLE)),,_)
rule 'AssignOr(loc(L:Int)::T:Type,, E:K) => 'Assign(loc(L)::T,, 'Or(lookup(L)::T,, E))

/* loc(L) ^= E => loc(L) = lookup(L) ^ E */
context 'AssignExcOr((HOLE => lvalue(HOLE)),,_)
rule 'AssignExcOr(loc(L:Int)::T:Type,, E:K) => 'Assign(loc(L)::T,, 'ExcOr(lookup(L)::T,, E))

/* loc(L) %= E => loc(L) = lookup(L) % E */
context 'AssignRemain((HOLE => lvalue(HOLE)),,_)
rule 'AssignRemain(loc(L:Int)::T:Type,, E:K) => 'Assign(loc(L)::T,, 'Remain(lookup(L)::T,, E))

/* loc(L) <<= E => loc(L) = lookup(L) << E */
context 'AssignLeftShift((HOLE => lvalue(HOLE)),,_)
rule 'AssignLeftShift(loc(L:Int)::T:Type,, E:K) => 'Assign(loc(L)::T,, 'LeftShift(lookup(L)::T,, E))

/* loc(L) >>= E => loc(L) = lookup(L) >> E */
context 'AssignRightShift((HOLE => lvalue(HOLE)),,_)
rule 'AssignRightShift(loc(L:Int)::T:Type,, E:K) => 'Assign(loc(L)::T,, 'RightShift(lookup(L)::T,, E))

/* loc(L) >>>= E => loc(L) = lookup(L) >>> E */
context 'AssignURightShift((HOLE => lvalue(HOLE)),,_)
rule 'AssignURightShift(loc(L:Int)::T:Type,, E:K) => 'Assign(loc(L)::T,, 'URightShift(lookup(L)::T,, E))

/*@ \subsection{lvalue and loc} */

syntax K ::= "lvalue" "(" K ")"

//both lookup and loc are RawVal expressions. How will we give lookup context syntax?
syntax RawVal ::= "loc" "(" Int ")"

rule <k> lvalue(lookup(L:Int)::T:Type) => loc(L)::T ...</k>  [structural]

rule [lvalueExprNameLocal]:
    <k> lvalue('ExprName(X:Id)) => typedLoc(L) ...</k>
    <env>... X |-> L:Int ...</env>
        [structural]

syntax K ::= "typedLoc" "(" Int ")"

rule [typedLoc]:
    <k> typedLoc(L:Int) => loc(L)::T ...</k>
    <store>... L |-> _::T:Type ...</store>

rule [lvalueTypedLoc]:
    <k> lvalue( typedLoc(L:Int) => loc(L)::T ) ...</k>
    <store>... L |-> _::T:Type ...</store>

/*@ \subsection{lookup} */

//lookup result is of sort RawType
syntax K ::= "lookup" "(" Int ")"

rule [lookupVarName]:
    <k> X:Id => V:RawVal :: T ...</k>
    <env>... X |-> L:Int ...</env>
    <store>... L |-> V :: T:Type ...</store>
        [transition]

rule [lookupLocation]:
    <k>
      lookup(L:Int) :: T1:Type
      => subtype T2:Type, T1 ~> true? ~> unsafeCast(V::T2, T1)
      ...
    </k>
    <store>... L |-> V:RawVal::T2 ...</store>
        [transition]

endmodule
