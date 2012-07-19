module JAVA-EXPRESSIONS
    imports JAVA-CORE
    imports JAVA-PRIMITIVE-TYPES

//@ \section{Operators}

syntax KLabel ::=
                //Infix operators
                  /* ||  */ 'LazyOr      [strict(1)]
                | /* &&  */ 'LazyAnd     [strict(1)]
                | /* |   */ 'Or          [seqstrict]
                | /* ^   */ 'ExcOr       [seqstrict]
                | /* &   */ 'And         [seqstrict]
                | /* ==  */ 'Eq          [seqstrict]
                | /* !=  */ 'NotEq       [seqstrict]
                | /* <   */ 'Lt          [seqstrict]
                | /* >   */ 'Gt          [seqstrict]
                | /* <=  */ 'LtEq        [seqstrict]
                | /* >=  */ 'GtEq        [seqstrict]
                | /* <<  */ 'LeftShift   [seqstrict]
                | /* >>  */ 'RightShift  [seqstrict]
                | /* >>> */ 'URightShift [seqstrict]
                | /* +   */ 'Plus        [seqstrict]
                | /* -   */ 'Minus       [seqstrict]
                | /* *   */ 'Mul         [seqstrict]
                | /* /   */ 'Div         [seqstrict]
                | /* %   */ 'Remain      [seqstrict]

                //Prefix operators
                | /* ++  */ 'PreIncr
                | /* --  */ 'PreDecr
                | /* !   */ 'Not         [strict]
                | /* ~   */ 'Complement  [strict]
                | /* +   */ 'Plus        // strictness already specified
                | /* -   */ 'Minus       // strictness already specified

                //Postfix operators
                | /* ++  */ 'PostIncr
                | /* --  */ 'PostDecr

                //Ternary operators
                | /* ? : */ 'Cond

rule /* true  || _ */ 'LazyOr(true :: bool,, _) => true :: bool
rule /* false || K */ 'LazyOr(false :: bool,, K:K) => K
rule /* true  && K */ 'LazyAnd(true :: bool,, K) => K
rule /* false && _ */ 'LazyAnd(false :: bool,, _) => false :: bool

rule /* I1 | I2 */ 'Or(I1 :: NT1:NumericType,, I2 :: NT2:NumericType)
    => normalize( (I1 |Int I2), NT1, NT2 )
rule /* B1 | B2 */ 'Or(B1:Bool :: bool,, B2:Bool :: bool) => (B1 orBool B2) :: bool
rule /* I1 ^ I2 */ 'ExcOr(I1 :: NT1,, I2 :: NT2) => normalize( (I1 xorInt I2), NT1, NT2 )
rule /* B1 ^ B2 */ 'ExcOr(B1 :: bool,, B2 :: bool) => (B1 xorBool B2) :: bool
rule /* I1 & I2 */ 'And(I1 :: NT1,, I2 :: NT2) => normalize( (I1 &Int I2), NT1, NT2 )
rule /* B1 & B2 */ 'And(B1 :: bool,, B2 :: bool) => (B1 andBool B2) :: bool

rule /* V1 == V2 */ 'Eq(V1:RawVal :: _,, V2:RawVal :: _) => (V1 ==K V2) :: bool
rule /* V1 != V2 */ 'NotEq(V1 :: _,, V2 :: _) => (V1 =/=K V2) :: bool
rule /* I1 <  I2 */ 'Lt(I1 :: _,, I2 :: _) => (I1 <Int I2) :: bool
rule /* I1 >  I2 */ 'Gt(I1 :: _,, I2 :: _) => (I1 >Int I2) :: bool
rule /* I1 <= I2 */ 'LtEq(I1 :: _,, I2 :: _) => (I1 <=Int I2) :: bool
rule /* I1 >= I2 */ 'GtEq(I1 :: _,, I2 :: _) => (I1 >=Int I2) :: bool

//normalization of first argument of bit shift operator
rule KL:KLabel(I1::NT1,, I2::NT2) => KL(I1 :: normalizeType(NT1),, I2 :: NT2)
    when    KL ==KLabel 'LeftShift
     orBool KL ==KLabel 'RightShift
     orBool KL ==KLabel 'URightShift

rule /* I1 <<  I2 */ 'LeftShift(I1 :: ILT:IntOrLongType,, I2 :: _)
    => normalize( (I1 <<Int (I2 &Int (bitCount(ILT) -Int 1))) :: ILT ) //JLS 15.19
rule /* I1 >>  I2 */ 'RightShift(I1 :: ILT,, I2 :: _)
    => normalize( (I1 >>Int (I2 &Int (bitCount(ILT) -Int 1))) :: ILT )
rule /* I1 >>> I2 */ 'URightShift(I1 :: ILT,, I2 :: NT)
  => 'Cond(
    (I1 >=Int 0)::bool,,
    'RightShift(I1 :: ILT,, I2 :: NT:NumericType),,
    'Plus('RightShift(I1::ILT,, I2::NT),, 'LeftShift(2::ILT,, 'Complement(I2::NT)))
  )

rule /* I1 + I2     */ 'Plus(I1:Int :: NT1,, I2:Int :: NT2) => normalize( (I1 +Int I2), NT1, NT2 )
rule /* Str1 + Str2 */ 'Plus(Str1:String :: rtString,, Str2:String :: rtString)
    => (Str1 +String Str2) :: rtString
rule /* Str + KR    */ 'Plus(Str:String :: rtString,, ( KR:KResult => toString(KR) ))
when       typeOf(KR) =/=K rtString
    orBool KR ==K (null::rtString)
rule /* KR + Str    */ 'Plus(( KR => toString(KR) ),, Str :: rtString)
when       typeOf(KR) =/=K rtString
    orBool KR ==K (null::rtString)

rule /* I1 - I2    */ 'Minus(I1 :: NT1,, I2 :: NT2) => normalize( _-Int_(I1,I2), NT1, NT2 )
rule /* I1 * I2    */ 'Mul(I1 :: NT1,, I2 :: NT2) => normalize( (I1 *Int I2), NT1, NT2 )
rule /* I1 / I2    */ 'Div(I1 :: NT1,, I2 :: NT2) => normalize( (I1 /Int I2), NT1, NT2 )
    when I2 =/=Int 0 //todo ArithmeticException
rule /* I1 % I2    */ 'Remain(I1 :: NT1,, I2 :: NT2) => normalize( (I1 %Int I2), NT1, NT2 )
    when I2 =/=Int 0 //todo ArithmeticException

// ++E
context 'PreIncr(HOLE => lvalue(HOLE))
rule /* ++loc(L) => loc(L) = lookup(L) + 1 */
  'PreIncr(loc(L:Int)::NT) => 'AssignPlus( loc(L)::NT,, 1::NT )

// --E
context 'PreDecr(HOLE => lvalue(HOLE))
rule /* --loc(L) => loc(L) = lookup(L) - 1 */
  'PreDecr(loc(L)::NT) => 'AssignMinus( loc(L)::NT,, 1::NT )

rule /* ! B    */ 'Not(B:Bool :: bool) => (notBool B) :: bool
rule /* ~ I    */ 'Complement(I:Int :: NT) => normalize( (~Int I), NT )
rule /* + I    */ 'Plus(I :: NT) => normalize( I, NT )
rule /* - I    */ 'Minus(I :: NT) => normalize( (0 -Int I), NT )

// E++
context 'PostIncr(HOLE => lvalue(HOLE))
rule /* loc(L)++ => (loc(L) = lookup(L) + 1) - 1 */
  'PostIncr(loc(L) :: NT) => 'Minus( 'PreIncr(loc(L)::NT),, 1::NT)

// E--
context 'PostDecr(HOLE => lvalue(HOLE))
rule /* loc(L)-- => (loc(L) = lookup(L) - 1) + 1 */
  'PostDecr(loc(L) :: NT) => 'Plus( 'PreDecr(loc(L)::NT),, 1::NT)

//semantically if and ?: are equivalent
rule 'Cond(Ks:List{K}) => 'If(Ks)

/*@ \subsubsection{Assignment operators}
Typed KOOL allows to assign subtype instance values to supertype lvalues.
Assignment operators are seqstrict according to JLS. */

syntax CompoundAssignLabel ::=
                | /* =    */ 'Assign  // K bug : if we move 'Assign under KLabel, as it's correct,
                                      // we get errors
                | /* +=   */ 'AssignPlus
                | /* -=   */ 'AssignMinus
                | /* *=   */ 'AssignMul
                | /* /=   */ 'AssignDiv
                | /* &=   */ 'AssignAnd
                | /* |=   */ 'AssignOr
                | /* ^=   */ 'AssignExcOr
                | /* %=   */ 'AssignRemain
                | /* <<=  */ 'AssignLeftShift
                | /* >>=  */ 'AssignRightShift
                | /* >>>= */ 'AssignURightShift

syntax KLabel ::= CompoundAssignLabel

context 'Assign((HOLE => lvalue(HOLE)),,_)
context 'Assign(_:KResult,,HOLE)

rule [Assign]:
    <k> 'Assign(loc(L) :: T:Type,, V:RawVal :: T) =>  V::T ...</k>
    <store>... L |-> (_ => V) :: T ...</store>
        [transition]

//todo check assign expression type in JLS
rule [AssignWithConversion]:
    'Assign(loc(L) :: T1:Type,, V :: T2:Type)
    =>  #if isNumericType2(T1)
          #then isInRange(V::T1)::bool ~> true?
          #else subtype T2, T1 ~> true?
        #fi ~> 'Assign(loc(L)::T1,, V::T1)
when
    T1 =/=K T2

context CALabel:CompoundAssignLabel((HOLE => lvalue(HOLE)),,_)

rule [CompoundAssign]:
    CALabel(loc(L) :: T,, E:K) => 'Assign(loc(L)::T,,
      castImpl(T, getOpLabel(CALabel)(lookup(L)::T,, E)))

declare getOpLabel : CompoundAssignLabel -> KLabel
define getOpLabel('AssignPlus) => 'Plus
define getOpLabel('AssignMinus) => 'Minus
define getOpLabel('AssignMul) => 'Mul
define getOpLabel('AssignDiv) => 'Div
define getOpLabel('AssignAnd) => 'And
define getOpLabel('AssignOr) => 'Or
define getOpLabel('AssignExcOr) => 'ExcOr
define getOpLabel('AssignRemain) => 'Remain
define getOpLabel('AssignLeftShift) => 'LeftShift
define getOpLabel('AssignRightShift) => 'RightShift
define getOpLabel('AssignURightShift) => 'URightShift

/*@ \subsection{primitive types cast} */

syntax KLabel ::= 'CastPrim
rule 'CastPrim(K1:K,, K2:K) => castImpl(K1,K2)

syntax K ::= "castImpl" "(" Type "," K ")" [seqstrict]
rule [CastNumber]: castImpl(NT, I::_) => normalize(I::NT)
rule [CastBool]: castImpl(bool, B::bool) => B::bool

/*@ \subsection{lvalue and loc} */

syntax K ::= "lvalue" "(" K ")"

//both lookup and loc are RawVal expressions. How will we give lookup context syntax?
syntax RawVal ::= "loc" "(" Int ")"

rule <k> lvalue(lookup(L)::T) => loc(L)::T ...</k>  [structural]

rule [lvalueExprNameLocal]:
    <k> lvalue('ExprName(X:Id)) => typedLoc(L) ...</k>
    <env>... X|->L ...</env>
        [structural]

syntax K ::= "typedLoc" "(" Int ")"

rule [typedLoc]:
    <k> typedLoc(L) => loc(L)::T ...</k>
    <store>... L |-> _::T ...</store>

rule [lvalueTypedLoc]:
    <k> lvalue( typedLoc(L) => loc(L)::T ) ...</k>
    <store>... L |-> _::T ...</store>

/*@ \subsection{lookup} */

//lookup result is of sort RawType
syntax K ::= "lookup" "(" Int ")"

rule [lookupVarName]:
    <k> X => V:RawVal :: T ...</k>
    <env>... X|->L ...</env>
    <store>... L|->V :: T ...</store>
        [transition]

rule [lookupLocation]:
    <k>
      lookup(L) :: T1
      => subtype T2, T1 ~> true? ~> V::T1
      ...
    </k>
    <store>... L |-> V::T2 ...</store>
        [transition]

end module
