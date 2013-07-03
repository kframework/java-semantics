require "java-core.k"
require "java-subtyping.k"
require "java-primitive-types.k"

module JAVA-EXPRESSIONS
    imports JAVA-CORE
    imports JAVA-SUBTYPING
    imports JAVA-PRIMITIVE-TYPES

//@ \section{Operators}

//Infix operators
context /* ||  */'LazyOr(HOLE,,_)::_
context /* &&  */'LazyAnd(HOLE,,_)::_
context /* |   */ 'Or(HOLE,,_)::_
context           'Or(_:KResult,,HOLE)::_
context /* ^   */ 'ExcOr(HOLE,,_)::_
context           'ExcOr(_:KResult,,HOLE)::_
context /* &   */ 'And(HOLE,,_)::_
context           'And(_:KResult,,HOLE)::_
context /* ==  */ 'Eq(HOLE,,_)::_
context           'Eq(_:KResult,,HOLE)::_
context /* !=  */ 'NotEq(HOLE,,_)::_
context           'NotEq(_:KResult,,HOLE)::_
context /* <   */ 'Lt(HOLE,,_)::_
context           'Lt(_:KResult,,HOLE)::_
context /* >   */ 'Gt(HOLE,,_)::_
context           'Gt(_:KResult,,HOLE)::_
context /* <=  */ 'LtEq(HOLE,,_)::_
context           'LtEq(_:KResult,,HOLE)::_
context /* >=  */ 'GtEq(HOLE,,_)::_
context           'GtEq(_:KResult,,HOLE)::_
context /* <<  */ 'LeftShift(HOLE,,_)::_
context           'LeftShift(_:KResult,,HOLE)::_
context /* >>  */ 'RightShift(HOLE,,_)::_
context           'RightShift(_:KResult,,HOLE)::_
context /* >>> */ 'URightShift(HOLE,,_)::_
context           'URightShift(_:KResult,,HOLE)::_
context /* +   */ 'Plus(HOLE,,_)::_
context           'Plus(_:KResult,,HOLE)::_
context /* -   */ 'Minus(HOLE,,_)::_
context           'Minus(_:KResult,,HOLE)::_
context /* *   */ 'Mul(HOLE,,_)::_
context           'Mul(_:KResult,,HOLE)::_
context /* /   */ 'Div(HOLE,,_)::_
context           'Div(_:KResult,,HOLE)::_
context /* %   */ 'Remain(HOLE,,_)::_
context           'Remain(_:KResult,,HOLE)::_

//Prefix operators
context /* !   */ 'Not(HOLE)::_
context /* ~   */ 'Complement(HOLE)::_
        /* +   */ //"'Plus"   - defined earlier
        /* -   */ //"'Minus"  - defined earlier

rule /* true  || _ */ 'LazyOr(true :: bool,, _) :: bool => true

//We use K:K instead of TE:TypedList becuase 'LazyAnd is used inside the semantics, not only in the source program.
rule /* false || K */ 'LazyOr(false :: bool,, K:K) :: bool => K
rule /* true  && K */ 'LazyAnd(true :: bool,, K:K) :: bool => K

rule /* false && _ */ 'LazyAnd(false :: bool,, _) :: bool => false

rule /* I1 | I2 */ 'Or(I1:Int :: _,, I2:Int :: _) :: ResT:NumericType => normalize( (I1 |Int I2) :: ResT )
rule /* B1 | B2 */ 'Or(B1:Bool :: bool,, B2:Bool :: bool) :: bool => B1 orBool B2
rule /* I1 ^ I2 */ 'ExcOr(I1:Int :: _,, I2:Int :: _) :: ResT:NumericType => normalize( (I1 xorInt I2) :: ResT )
rule /* B1 ^ B2 */ 'ExcOr(B1:Bool :: bool,, B2:Bool :: bool) :: bool => B1 xorBool B2
rule /* I1 & I2 */ 'And(I1:Int :: _,, I2:Int :: _) :: ResT:NumericType => normalize( (I1 &Int I2) :: ResT )
rule /* B1 & B2 */ 'And(B1:Bool :: bool,, B2:Bool :: bool) :: bool => B1 andBool B2

rule /* V1 == V2 */ 'Eq(V1:RawVal :: _,, V2:RawVal :: _) :: bool => (V1 ==K V2) :: bool
rule /* V1 != V2 */ 'NotEq(V1:RawVal :: _,, V2:RawVal :: _) :: bool => V1 =/=K V2
rule /* I1 <  I2 */ 'Lt(I1:Int :: _,, I2:Int :: _) :: bool => I1 <Int I2
rule /* I1 >  I2 */ 'Gt(I1:Int :: _,, I2:Int :: _) :: bool => I1 >Int I2
rule /* I1 <= I2 */ 'LtEq(I1:Int :: _,, I2:Int :: _) :: bool => I1 <=Int I2
rule /* I1 >= I2 */ 'GtEq(I1:Int :: _,, I2:Int :: _) :: bool => I1 >=Int I2

rule /* I1 <<  I2 */ 'LeftShift(I1:Int :: _,, I2:Int :: _) :: ResT:NumericType
    => normalize( (I1 <<Int (I2 &Int (bitCount(ResT) -Int 1))) :: ResT ) //JLS 15.19
rule /* I1 >>  I2 */ 'RightShift(I1:Int :: _,, I2:Int :: _) :: ResT:NumericType
    => normalize( (I1 >>Int (I2 &Int (bitCount(ResT) -Int 1))) :: ResT )
rule /* I1 >>> I2 */ 'URightShift(I1:Int :: _,, I2:Int :: NT:NumericType) :: ResT:NumericType
  => 'If(
    (I1 >=Int 0),,
    'RightShift(I1 :: ResT,, I2 :: NT) :: ResT,,
    'Plus('RightShift(I1::ResT,, I2::NT) :: ResT,, 'LeftShift(2::ResT,, 'Complement(I2::NT) :: int) :: ResT) :: ResT
  )

rule /* I1 + I2     */ 'Plus(I1:Int :: _,, I2:Int :: _) :: ResT:NumericType => normalize( (I1 +Int I2) :: ResT )
rule /* Str1 + Str2 */ 'Plus(Str1:String :: rtString,, Str2:String :: rtString) :: rtString
    => (Str1 +String Str2) :: rtString
rule /* Str + KR    */ 'Plus(Str:String :: rtString,, ( KR:KResult => toString(KR) )) :: rtString
when       (typeOf(KR) =/=K rtString)
    orBool (KR ==K (null::rtString))
rule /* KR + Str    */ 'Plus(( KR:KResult => toString(KR) ),, Str:String :: rtString) :: rtString
when       (typeOf(KR) =/=K rtString)
    orBool (KR ==K (null::rtString))

rule /* I1 - I2    */ 'Minus(I1:Int :: _,, I2:Int :: _) :: ResT:NumericType => normalize( (I1 -Int I2) :: ResT )
rule /* I1 * I2    */ 'Mul(I1:Int :: _,, I2:Int :: _) :: ResT:NumericType => normalize( (I1 *Int I2) :: ResT )
rule /* I1 / I2    */ 'Div(I1:Int :: _,, I2:Int :: _) :: ResT:NumericType => normalize( (I1 /Int I2) :: ResT )
    when I2 =/=Int 0

//todo test that the first argument is fully evaluated, right now it may be not evaluated
rule                  'Div(_::_     ,, 0::_)::_
   => 'Throw('NewInstance(
        'None(.KList),,
        (class String2Id("java.lang.ArithmeticException")),,
        'ListWrap( "/ by zero" ),,
        'None(.KList)
      ))

rule /* I1 % I2    */ 'Remain(I1:Int :: _,, I2:Int :: _) :: ResT:NumericType => normalize( (I1 %Int I2) :: ResT )
    when I2 =/=Int 0

//todo test that the first argument is fully evaluated, right now it may be not evaluated
rule                  'Remain(_::_     ,, 0::_)::_
   => 'Throw('NewInstance(
        'None(.KList),,
        (class String2Id("java.lang.ArithmeticException")),,
        'ListWrap( "/ by zero" ),,
        'None(.KList)
      ))

// ++E
rule /* ++loc(L) => loc(L) = lookup(L) + 1 */
  'PreIncr(loc(L:Int)::NT:NumericType)::NT => 'AssignPlus( loc(L)::NT,, 1::NT )::NT

// --E
rule /* --loc(L) => loc(L) = lookup(L) - 1 */
  'PreDecr(loc(L:Int)::NT:NumericType)::NT => 'AssignMinus( loc(L)::NT,, 1::NT )::NT

rule /* ! B    */ 'Not(B:Bool :: bool) :: bool => (notBool B)
rule /* ~ I    */ 'Complement(I:Int :: _) :: ResT:NumericType => normalize( (~Int I) :: ResT )
rule /* + I    */ 'Plus(I:Int :: _) :: ResT:NumericType => normalize( I :: ResT )
rule /* - I    */ 'Minus(I:Int :: _) :: ResT:NumericType => normalize( (0 -Int I) :: ResT )

// E++
rule /* loc(L)++ => (loc(L) = lookup(L) + 1) - 1 */
  'PostIncr(loc(L:Int) :: NT:NumericType)::NT => 'Minus( 'PreIncr(loc(L)::NT)::NT,, 1::NT)::NT

// E--
rule /* loc(L)-- => (loc(L) = lookup(L) - 1) + 1 */
  'PostDecr(loc(L:Int) :: NT:NumericType)::NT => 'Plus( 'PreDecr(loc(L)::NT)::NT,, 1::NT)::NT

//Conditional expression : ?: . Desugared into an if with cast.
//The biggest difficulty is computing the expression type, according to JLS1 $15.24
rule 'Cond(CondExp:TypedExp,, TrueExp:TypedExp,, FalseExp:TypedExp) :: ResT:Type
    => castImpl(ResT, 'If(CondExp,, TrueExp,, FalseExp)) :: ResT

/*@ \subsubsection{Assignment operators}
Typed KOOL allows to assign subtype instance values to supertype lvalues.
Assignment operators are seqstrict according to JLS. */

context 'Assign(_:KResult,,HOLE)::_

rule [Assign]:
    <k> 'Assign(loc(L:Int) :: _,, V:RawVal :: _) :: ResT:Type => V::ResT ...</k>
    <store>... L |-> (_:RawVal => V)::ResT ...</store>

rule [AssignUninitialized]:
    <k> (. => staticInit(Class)) ~> 'Assign(loc(L:Int) :: _,, _)::_ ...</k>
    <store>... L |-> uninitialized(Class:ClassType, _) :: _ ...</store>


rule [expLValueHeat]:
    (. => lvalue(K)) ~> KL:KLabel((K:K => HOLE),, _)::_
when
    (      KL ==KLabel 'PreIncr
    orBool KL ==KLabel 'PreDecr
    orBool KL ==KLabel 'PostIncr
    orBool KL ==KLabel 'PostDecr
    orBool KL ==KLabel 'Assign
    orBool isCompoundAssignLabel(KL)
    )
    andBool notBool (isKResult(K) ==K true)

rule [expLValueCool]:
    (KR:KResult => .) ~> KL:KLabel((HOLE => KR),, _)::_

rule [CompoundAssign]:
    KL:KLabel(loc(L:Int) :: T1:Type,, Exp2:K::T2:Type) :: T1:Type
    => 'Assign(loc(L)::T1,, castImpl(T1, getOpLabel(KL)(lookup(L)::T1,, Exp2::T2)::normalizeType(T1,T2))::T1)::T1
when isCompoundAssignLabel(KL)

//only for Compound Assign KLabel's
syntax KLabel ::= "getOpLabel" "(" KLabel ")" [function]
rule getOpLabel('AssignPlus)        => 'Plus
rule getOpLabel('AssignMinus)       => 'Minus
rule getOpLabel('AssignMul)         => 'Mul
rule getOpLabel('AssignDiv)         => 'Div
rule getOpLabel('AssignAnd)         => 'And
rule getOpLabel('AssignOr)          => 'Or
rule getOpLabel('AssignExcOr)       => 'ExcOr
rule getOpLabel('AssignRemain)      => 'Remain
rule getOpLabel('AssignLeftShift)   => 'LeftShift
rule getOpLabel('AssignRightShift)  => 'RightShift
rule getOpLabel('AssignURightShift) => 'URightShift

/*@ \subsection{primitive types cast} */

syntax K ::= "castImpl" "(" Type "," K ")"
context castImpl(_,HOLE)::_

rule [CastNumber]: castImpl(NT:NumericType, I:Int::_)::NT => normalize(I::NT)
rule [CastBool]: castImpl(bool, B:Bool::bool)::bool => B

/*@ \subsection{lvalue and loc syntax} */

syntax K ::= "lvalue" "(" K ")"

//both lookup and loc are RawVal expressions. How will we give lookup context syntax?
syntax RawVal ::= "loc" "(" Int ")"

//lookup result is of sort RawType
syntax K ::= "lookup" "(" Int ")"

endmodule
