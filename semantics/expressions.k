require "core.k"
require "subtyping.k"
require "primitive-types.k"
require "elaboration-expressions.k"

//@ \section{Module EXPRESSIONS}

module EXPRESSIONS
    imports CORE
    imports SUBTYPING
    imports PRIMITIVE-TYPES
    imports ELABORATION-EXPRESSIONS //for "isCompoundAssignLabel

//Concerting typed expressions into expressions with casts
//todo Temp: this rule is an intermadiate step untill we'll finish conversion of TypedExp into cast.
rule [typedExp-generic]:
    Exp:K :: T:Type => castImpl(T, Exp)
when
    notBool (isExtendedRawVal(Exp) ==K true)
        [structural]

rule [lvalue-typedExp-generic]:
    lvalue(Exp:K :: T:Type => Exp)
when
    notBool (isExtendedRawVal(Exp) ==K true)
        [structural]

/* Predicate representing RawVal + lookup()
*/
syntax K ::= isExtendedRawVal ( K )               [function]
rule isExtendedRawVal(_:RawVal) => true
rule isExtendedRawVal(lookup(_)) => true

/*@ Used to denote a temporary type of an expression. Such an expression should always be wrapped inside a cast
  expression. The cast will then replace tempType with the proper compile-time type.
*/
syntax Type ::= "tempType"

//Infix operators
context /* ||  */'LazyOr(HOLE,,_)
context /* &&  */'LazyAnd(HOLE,,_)
context /* |   */ 'Or(HOLE,,_)
context           'Or(_:KResult,,HOLE)
context /* ^   */ 'ExcOr(HOLE,,_)
context           'ExcOr(_:KResult,,HOLE)
context /* &   */ 'And(HOLE,,_)
context           'And(_:KResult,,HOLE)
context /* ==  */ 'Eq(HOLE,,_)
context           'Eq(_:KResult,,HOLE)
        /* !=  - no context rules*/

context /* <   */ 'Lt(HOLE,,_)
context           'Lt(_:KResult,,HOLE)
context /* >   */ 'Gt(HOLE,,_)
context           'Gt(_:KResult,,HOLE)
context /* <=  */ 'LtEq(HOLE,,_)
context           'LtEq(_:KResult,,HOLE)
context /* >=  */ 'GtEq(HOLE,,_)
context           'GtEq(_:KResult,,HOLE)
context /* <<  */ 'LeftShift(HOLE,,_)
context           'LeftShift(_:KResult,,HOLE)
context /* >>  */ 'RightShift(HOLE,,_)
context           'RightShift(_:KResult,,HOLE)
context /* >>> */ 'URightShift(HOLE,,_)
context           'URightShift(_:KResult,,HOLE)
context /* +   */ 'Plus(HOLE,,_)
context           'Plus(_:KResult,,HOLE)
context /* -   */ 'Minus(HOLE,,_)
context           'Minus(_:KResult,,HOLE)
context /* *   */ 'Mul(HOLE,,_)
context           'Mul(_:KResult,,HOLE)
context /* /   */ 'Div(HOLE,,_)
context           'Div(_:KResult,,HOLE)
context /* %   */ 'Remain(HOLE,,_)
context           'Remain(_:KResult,,HOLE)

//Prefix operators
context /* !   */ 'Not(HOLE)
context /* ~   */ 'Complement(HOLE)
        /* +   */ //"'Plus"   - defined earlier
        /* -   */ //"'Minus"  - defined earlier

rule /* true  || _ */ 'LazyOr(true :: bool,, _) => true

//We use K:K instead of TE:TypedList because 'LazyAnd is used inside the semantics, not only in the source program.
rule /* false || K */ 'LazyOr(false :: bool,, K:K) => K
rule /* true  && K */ 'LazyAnd(true :: bool,, K:K) => K

rule /* false && _ */ 'LazyAnd(false :: bool,, _) => false

rule /* I1 | I2 */ 'Or(I1:Int :: _,, I2:Int :: _) => (I1 |Int I2) :: tempType  //temporary type, will be casted anyway
rule /* B1 | B2 */ 'Or(B1:Bool :: bool,, B2:Bool :: bool) => (B1 orBool B2) :: bool
rule /* I1 ^ I2 */ 'ExcOr(I1:Int :: _,, I2:Int :: _) => (I1 xorInt I2) :: tempType
rule /* B1 ^ B2 */ 'ExcOr(B1:Bool :: bool,, B2:Bool :: bool) => (B1 xorBool B2) :: bool
rule /* I1 & I2 */ 'And(I1:Int :: _,, I2:Int :: _) => (I1 &Int I2) :: tempType
rule /* B1 & B2 */ 'And(B1:Bool :: bool,, B2:Bool :: bool) => (B1 andBool B2) :: bool

rule /* I1 == I2 */ 'Eq(I1:Int   :: _,, I2:Int   :: _) => (I1 ==Int I2) :: bool
rule /* F1 == F2 */ 'Eq(F1:Float :: _,, F2:Float :: _) => (F1 ==Float F2) :: bool
rule /* B1 == B2 */ 'Eq(B1:Bool  :: _,, B2:Bool  :: _) => (B1 ==Bool B2) :: bool
rule /* Ref1 == Ref2 */ 'Eq(Ref1:RawRefVal :: _,, Ref2:RawRefVal :: _) => (Ref1 ==K Ref2) :: bool

rule /* V1 != V2 */ 'NotEq(TE1:K,, TE2:K) => 'Not('Eq(TE1,,TE2))

rule /* I1 <  I2 */ 'Lt(I1:Int :: _,, I2:Int :: _) => (I1 <Int I2)::bool
rule                'Lt(F1:Float :: _,, F2:Float :: _) => (F1 <Float F2)::bool
rule /* I1 >  I2 */ 'Gt(I1:Int :: _,, I2:Int :: _) => (I1 >Int I2)::bool
rule                'Gt(F1:Float :: _,, F2:Float :: _) => (F1 >Float F2)::bool
rule /* I1 <= I2 */ 'LtEq(I1:Int :: _,, I2:Int :: _) => (I1 <=Int I2)::bool
rule                'LtEq(F1:Float :: _,, F2:Float :: _) => (F1 <=Float F2)::bool
rule /* I1 >= I2 */ 'GtEq(I1:Int :: _,, I2:Int :: _) => (I1 >=Int I2)::bool
rule                'GtEq(F1:Float :: _,, F2:Float :: _) => (F1 >=Float F2)::bool

rule /* I1 <<  I2 */ 'LeftShift(I1:Int :: NT1:Type,, I2:Int :: _)
    => (I1 <<Int (I2 &Int (bitCount(normalizeType(NT1)) -Int 1))) :: tempType //JLS \$15.19
rule /* I1 >>  I2 */ 'RightShift(I1:Int :: NT1:Type,, I2:Int :: _)
    => (I1 >>Int (I2 &Int (bitCount(normalizeType(NT1)) -Int 1))) :: tempType
rule /* I1 >>> I2 */ 'URightShift(I1:Int :: NT1:Type,, I2:Int :: NT2:NumericType)
  => 'If(
    (I1 >=Int 0)::bool,,
    'RightShift(I1 :: NT1,, I2 :: NT2),,
    'Plus('RightShift(I1::NT1,, I2::NT2),, 'LeftShift(2::NT1,, 'Complement(I2::NT2)))
  )

rule /* I1 + I2     */ 'Plus(I1:Int :: _,, I2:Int :: _) => (I1 +Int I2) :: tempType
rule                   'Plus(F1:Float :: _,, F2:Float :: _) => (F1 +Float F2) :: tempType
rule /* Str1 + Str2 */ 'Plus(Str1:String :: rtString,, Str2:String :: rtString)
    => (Str1 +String Str2) :: rtString
rule /* Str + KR    */ 'Plus(Str:String :: rtString,, ( KR:KResult => toString(KR) ))
when       (typeOf(KR) =/=K rtString)
    orBool (KR ==K (null::rtString))
rule /* KR + Str    */ 'Plus(( KR:KResult => toString(KR) ),, Str:String :: rtString)
when       (typeOf(KR) =/=K rtString)
    orBool (KR ==K (null::rtString))

rule /* I1 - I2    */ 'Minus(I1:Int :: _,, I2:Int :: _) => (I1 -Int I2) :: tempType
rule                  'Minus(F1:Float :: _,, F2:Float :: _) => (F1 -Float F2) :: tempType
rule /* I1 * I2    */ 'Mul(I1:Int :: _,, I2:Int :: _) => (I1 *Int I2) :: tempType
rule                  'Mul(F1:Float :: _,, F2:Float :: _) => (F1 *Float F2) :: tempType
rule /* I1 / I2    */ 'Div(I1:Int :: _,, I2:Int :: _) => (I1 /Int I2) :: tempType
    when I2 =/=Int 0
rule                  'Div(F1:Float :: _,, F2:Float :: _) => (F1 /Float F2) :: tempType

//todo test that the first argument is fully evaluated, right now it may be not evaluated
rule                  'Div(_::_         ,, 0::_)
   => elab('Throw('NewInstance(
        'None(.KList),,
        (class String2Id("java.lang.ArithmeticException")),,
        'ListWrap( "/ by zero" ),,
        'None(.KList)
      )))

rule /* I1 % I2    */ 'Remain(I1:Int :: _,, I2:Int :: _) => (I1 %Int I2) :: tempType
    when I2 =/=Int 0
rule                  'Remain(F1:Float :: _,, F2:Float :: _) => (F1 %Float F2) :: tempType

//todo test that the first argument is fully evaluated, right now it may be not evaluated
rule                  'Remain(_::_     ,, 0::_)
   => elab('Throw('NewInstance(
        'None(.KList),,
        (class String2Id("java.lang.ArithmeticException")),,
        'ListWrap( "/ by zero" ),,
        'None(.KList)
      )))

rule [NormalizeLeftOperandToFloat]:
    KL:KLabel((I:Int::_:IntType => Int2Float(I)::float),, _:Float :: _:FloatType)
when
    isFloatBinaryOp(KL)

rule [NormalizeRightOperandToFloat]:
    KL:KLabel(_:Float :: _:FloatType,, (I:Int::_:IntType => Int2Float(I)::float))
when
    isFloatBinaryOp(KL)

syntax K ::= "isFloatBinaryOp" "(" KLabel ")"       [function]
rule isFloatBinaryOp(KL:KLabel)
    =>     KL ==KLabel 'Plus
    orBool KL ==KLabel 'Minus
    orBool KL ==KLabel 'Mul
    orBool KL ==KLabel 'Div
    orBool KL ==KLabel 'Remain
    orBool KL ==KLabel 'Lt
    orBool KL ==KLabel 'LtEq
    orBool KL ==KLabel 'Gt
    orBool KL ==KLabel 'GtEq
    orBool KL ==KLabel 'Eq
    orBool KL ==KLabel 'NotEq

// ++E
rule /* ++loc(L) => loc(L) = lookup(L) + 1 */
  'PreIncr(loc(L:Int)::NT:NumericType) => 'AssignPlus( loc(L)::NT,, rightTypedNumber(1,NT) )

// --E
rule /* --loc(L) => loc(L) = lookup(L) - 1 */
  'PreDecr(loc(L:Int)::NT:NumericType) => 'AssignMinus( loc(L)::NT,, rightTypedNumber(1,NT) )

rule /* ! B    */ 'Not(B:Bool :: bool) => (notBool B) :: bool
rule /* ~ I    */ 'Complement(I:Int :: _) => (~Int I) :: tempType
rule /* + I    */ 'Plus(I:Int :: _) => I :: tempType
rule /* + F    */ 'Plus(F:Float :: _) => F :: tempType
rule /* - I    */ 'Minus(I:Int :: _) => (0 -Int I) :: tempType
rule /* - F    */ 'Minus(F:Float :: _) => (Int2Float(0) -Float F) :: tempType

// E++
rule /* loc(L)++ => (loc(L) = lookup(L) + 1) - 1 */
  'PostIncr(loc(L:Int) :: NT:NumericType) => 'Minus( 'PreIncr(loc(L)::NT),, rightTypedNumber(1,NT))

// E--
rule /* loc(L)-- => (loc(L) = lookup(L) - 1) + 1 */
  'PostDecr(loc(L:Int) :: NT:NumericType) => 'Plus(  'PreDecr(loc(L)::NT),, rightTypedNumber(1,NT))

//Computes a TypedVal where value representation is of correct numeric type:
//Int when NT is IntType, Float when NT is FloatType
syntax K ::= "rightTypedNumber" "(" Int "," NumericType ")"             [function]
rule rightTypedNumber(I:Int, IntT:IntType) => I::IntT
rule rightTypedNumber(I:Int, FloatT:FloatType) => Int2Float(I)::FloatT

//Conditional expression : ?: . Desugared into an if with cast.
//The biggest difficulty is computing the expression type, according to JLS1 \$15.24
//The whole expression should always come wrapped into a cast, from elaboration.
//Thus we don't have to worry about proper type conversion here.
rule 'Cond(CondExp:K,, TrueExp:K,, FalseExp:K) => 'If(CondExp,, TrueExp,, FalseExp)

/*@ \subsubsection{Assignment operators}
Typed KOOL allows to assign subtype instance values to supertype lvalues.
Assignment operators are seqstrict according to JLS. */

context 'Assign(_:KResult,,HOLE)

rule [Assign]:
    <k> 'Assign(loc(L:Int) :: ResT:Type,, V:RawVal :: ResT) => V::ResT ...</k>
    <store>... L |-> (_:RawVal => V)::ResT ...</store>
        [transition-threading]

rule [expLValueHeat]:
    (. => lvalue(K)) ~> KL:KLabel((K:K => HOLE),, _)
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
    (KR:KResult => .) ~> KL:KLabel((HOLE => KR),, _)

//question: Why can't we move this desugaring into elaboration phase?
rule [CompoundAssign]:
    KL:KLabel(loc(L:Int) :: T1:Type,, Exp2:K)
    => 'Assign(loc(L)::T1,, castImpl(T1, getOpLabel(KL)(lookup(L)::T1,, Exp2)))
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
context castImpl(_,HOLE)

rule [CastNumber]: castImpl(NT:NumericType, RV:RawVal::_) => normalize(RV::NT)
rule [CastBool]: castImpl(bool, B:Bool::bool) => B::bool

/*@ \subsubsection{artificial cases of cast, arised during semantics separation} */

rule [Cast-void]: castImpl(void, RV:RawVal::void) => RV::void

//Happens for the qualifier of a static method call
rule [Cast-noValue]: castImpl(_, noValue) => noValue

/*@ \subsection{lvalue and loc syntax} */

syntax K ::= "lvalue" "(" K ")"

syntax RawVal ::= "loc" "(" Int ")"

endmodule
