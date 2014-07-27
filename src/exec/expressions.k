//@ \section{Module EXPRESSIONS}

module EXPRESSIONS
    imports CORE-SORTS
    imports CORE-CLASSES
    imports SUBTYPING
    imports PRIMITIVE-TYPES // for normalizeType
    imports TO-STRING
    imports VAR-LOOKUP  // for lookup

/*syntax KLabel ::= "'Mul"
                | "'Div"
                | "'Remain"
                | "'Plus"
                | "'Minus"
                | "'LeftShift"
                | "'RightShift"
                | "'URightShift"
                | "'Lt"
                | "'Gt"
                | "'LtEq"
                | "'GtEq"
                | "'Eq"
                | "'NotEq"
                | "'LazyAnd"
                //K bug #260 makes strictness on KLabels impossible. Replace contexts with strictness when fixed.
                | "'LazyOr"     //[strict(1)]
                | "'And"
                | "'ExcOr"
                | "'Or"
                | "'Cond"
                | "'PreIncr"
                | "'PreDecr"
                | "'Complement"
                | "'Not"
                | "'PostIncr"
                | "'PostDecr"
*/

/*@ Used to denote a temporary type of an expression. Such an expression should always be wrapped inside a cast
  expression. The cast will then replace tempType with the proper compile-time type.
*/
syntax Type ::= "tempType"

//rule /* true  || _ */ 'LazyOr(true :: bool,, _) => true
//
////We use K:K instead of TE:TypedList because 'LazyAnd is used inside the semantics, not only in the source program.
//rule /* false || K */ 'LazyOr(false :: bool,, K:K) => K
//rule /* true  && K */ 'LazyAnd(true :: bool,, K:K) => K
//
//rule /* false && _ */ 'LazyAnd(false :: bool,, _) => false
//
//rule /* I1 | I2 */ 'Or(I1:Int :: _,, I2:Int :: _) => (I1 |Int I2) :: tempType  //temporary type, will be casted anyway
//rule /* B1 | B2 */ 'Or(B1:Bool :: bool,, B2:Bool :: bool) => (B1 orBool B2) :: bool
//rule /* I1 ^ I2 */ 'ExcOr(I1:Int :: _,, I2:Int :: _) => (I1 xorInt I2) :: tempType
//rule /* B1 ^ B2 */ 'ExcOr(B1:Bool :: bool,, B2:Bool :: bool) => (B1 xorBool B2) :: bool
//rule /* I1 & I2 */ 'And(I1:Int :: _,, I2:Int :: _) => (I1 &Int I2) :: tempType
//rule /* B1 & B2 */ 'And(B1:Bool :: bool,, B2:Bool :: bool) => (B1 andBool B2) :: bool
//
//rule /* I1 == I2 */ 'Eq(I1:Int   :: _,, I2:Int   :: _) => (I1 ==Int I2) :: bool
//rule /* F1 == F2 */ 'Eq(F1:Float :: _,, F2:Float :: _) => (F1 ==Float F2) :: bool
//rule /* B1 == B2 */ 'Eq(B1:Bool  :: _,, B2:Bool  :: _) => (B1 ==Bool B2) :: bool
//rule /* Ref1 == Ref2 */ 'Eq(Ref1:RawRefVal :: _,, Ref2:RawRefVal :: _) => (Ref1 ==K Ref2) :: bool
//
//rule /* V1 != V2 */ 'NotEq(TE1:K,, TE2:K) => 'Not('Eq(TE1,,TE2))
//
//rule /* I1 <  I2 */ 'Lt(I1:Int :: _,, I2:Int :: _) => (I1 <Int I2)::bool
//rule                'Lt(F1:Float :: _,, F2:Float :: _) => (F1 <Float F2)::bool
//rule /* I1 >  I2 */ 'Gt(I1:Int :: _,, I2:Int :: _) => (I1 >Int I2)::bool
//rule                'Gt(F1:Float :: _,, F2:Float :: _) => (F1 >Float F2)::bool
//rule /* I1 <= I2 */ 'LtEq(I1:Int :: _,, I2:Int :: _) => (I1 <=Int I2)::bool
//rule                'LtEq(F1:Float :: _,, F2:Float :: _) => (F1 <=Float F2)::bool
//rule /* I1 >= I2 */ 'GtEq(I1:Int :: _,, I2:Int :: _) => (I1 >=Int I2)::bool
//rule                'GtEq(F1:Float :: _,, F2:Float :: _) => (F1 >=Float F2)::bool
//
//rule /* I1 <<  I2 */ 'LeftShift(I1:Int :: NT1:Type,, I2:Int :: _)
//    => (I1 <<Int (I2 &Int (bitCount(normalizeType(NT1)) -Int 1))) :: tempType //JLS \$15.19
//rule /* I1 >>  I2 */ 'RightShift(I1:Int :: NT1:Type,, I2:Int :: _)
//    => (I1 >>Int (I2 &Int (bitCount(normalizeType(NT1)) -Int 1))) :: tempType
//rule /* I1 >>> I2 */ 'URightShift(I1:Int :: NT1:Type,, I2:Int :: NT2:NumericType)
//  => 'If(
//    (I1 >=Int 0)::bool,,
//    'RightShift(I1 :: NT1,, I2 :: NT2),,
//    'Plus('RightShift(I1::NT1,, I2::NT2),, 'LeftShift(2::NT1,, 'Complement(I2::NT2)))
//  )

rule /* true  || _ */ true :: bool || _ => true

//We use K:K instead of TE:TypedList because 'LazyAnd is used inside the semantics, not only in the source program.
rule /* false || K */ false :: bool || K:K => K

rule /* true  && K */ true :: bool && K:K => K
rule /* false && _ */ false :: bool && _ => false

rule /* I1 | I2 */  I1:Int :: _ | I2:Int :: _ => (I1 |Int I2) :: tempType  //temporary type, will be casted anyway
rule /* B1 | B2 */ B1:Bool :: bool | B2:Bool :: bool => (B1 orBool B2) :: bool
rule /* I1 ^ I2 */ I1:Int :: _ ^ I2:Int :: _ => (I1 xorInt I2) :: tempType
rule /* B1 ^ B2 */ B1:Bool :: bool ^ B2:Bool :: bool => (B1 xorBool B2) :: bool
rule /* I1 & I2 */ I1:Int :: _ & I2:Int :: _ => (I1 &Int I2) :: tempType
rule /* B1 & B2 */ B1:Bool :: bool & B2:Bool :: bool => (B1 andBool B2) :: bool

rule /* I1 == I2 */ I1:Int   :: _ == I2:Int   :: _ => (I1 ==Int I2) :: bool
rule /* F1 == F2 */ F1:Float :: _ == F2:Float :: _ => (F1 ==Float F2) :: bool
rule /* B1 == B2 */ B1:Bool  :: _ == B2:Bool  :: _ => (B1 ==Bool B2) :: bool
rule /* Ref1 == Ref2 */ Ref1:RawRefVal :: _ == Ref2:RawRefVal :: _ => (Ref1 ==K Ref2) :: bool

rule /* V1 != V2 */ TE1:K != TE2:K => !(TE1 == TE2)

rule /* I1 <  I2 */ I1:Int :: _ < I2:Int :: _ => (I1 <Int I2)::bool
rule                F1:Float :: _ < F2:Float :: _ => (F1 <Float F2)::bool
rule /* I1 >  I2 */ I1:Int :: _ > I2:Int :: _ => (I1 >Int I2)::bool
rule                F1:Float :: _ > F2:Float :: _ => (F1 >Float F2)::bool
rule /* I1 <= I2 */ I1:Int :: _ <= I2:Int :: _ => (I1 <=Int I2)::bool
rule                F1:Float :: _ <= F2:Float :: _ => (F1 <=Float F2)::bool
rule /* I1 >= I2 */ I1:Int :: _ >= I2:Int :: _ => (I1 >=Int I2)::bool
rule                F1:Float :: _ >= F2:Float :: _ => (F1 >=Float F2)::bool

rule /* I1 <<  I2 */ I1:Int :: NT1:Type << I2:Int :: _
    => (I1 <<Int (I2 &Int (bitCount(normalizeType(NT1)) -Int 1))) :: tempType //JLS \$15.19
rule /* I1 >>  I2 */ I1:Int :: NT1:Type >> I2:Int :: _
    => (I1 >>Int (I2 &Int (bitCount(normalizeType(NT1)) -Int 1))) :: tempType
rule /* I1 >>> I2 */ I1:Int :: NT1:Type >>> I2:Int :: NT2:NumericType
  => 'If(
    (I1 >=Int 0)::bool,,
    I1 :: NT1 >> I2 :: NT2,,
    (I1::NT1 >> I2::NT2) + ( 2::NT1 << (~ I2::NT2))
  )

//AST-based rule for 'Plus
//rule /* I1 + I2     */ 'Plus(I1:Int :: _,, I2:Int :: _) => (I1 +Int I2) :: tempType
//rule                   'Plus(F1:Float :: _,, F2:Float :: _) => (F1 +Float F2) :: tempType
//rule /* Str1 + Str2 */ 'Plus(Str1:String :: _,, Str2:String :: _)
//    => (Str1 +String Str2) :: classString
//rule /* Str + KR    */ 'Plus(Str:String :: Class:ClassType,, ( KR:KResult => toString(KR) ))
//when       ((typeOf(KR) =/=K classString)
//           andBool Class ==K classString)
//    orBool (KR ==K (null::classString))
//rule /* KR + Str    */ 'Plus(( KR:KResult => toString(KR) ),, Str:String :: Class:ClassType)
//when       ((typeOf(KR) =/=K classString)
//           andBool Class ==K classString)
//    orBool (KR ==K (null::classString))

//the same rule, syntax-based
rule /* I1 + I2     */ I1:Int::_ + I2:Int::_ => (I1 +Int I2) :: tempType
rule /* F1 + F2 */ F1:Float :: _ + F2:Float :: _ => (F1 +Float F2) :: tempType
rule /* Str1 + Str2 */ Str1:String :: _ + Str2:String :: _   => (Str1 +String Str2) :: classString
rule /* Str + KR    */ Str:String :: Class:ClassType + ( KR:KResult => toString(KR) )
when       ((typeOf(KR) =/=K classString)
           andBool Class ==K classString)
    orBool (KR ==K (null::classString))
rule /* KR + Str    */ ( KR:KResult => toString(KR) ) + Str:String :: Class:ClassType
when       ((typeOf(KR) =/=K classString)
           andBool Class ==K classString)
    orBool (KR ==K (null::classString))

rule /* I1 - I2 */ I1:Int :: _ - I2:Int :: _ => (I1 -Int I2) :: tempType
rule /* F1 - F2 */ F1:Float :: _ - F2:Float :: _ => (F1 -Float F2) :: tempType
rule /* I1 * I2 */ I1:Int :: _ * I2:Int :: _ => (I1 *Int I2) :: tempType
rule /* F1 * F2 */ F1:Float :: _ * F2:Float :: _ => (F1 *Float F2) :: tempType
rule /* I1 / I2 */ I1:Int :: _ / I2:Int :: _ => (I1 /Int I2) :: tempType
    			when I2 =/=Int 0
rule /* F1 / F2 */ F1:Float :: _ / F2:Float :: _ => (F1 /Float F2) :: tempType

//totest that the first argument is fully evaluated, right now it may be not evaluated
rule _:TypedVal / 0::_ => throw new class String2Id("java.lang.ArithmeticException") ("/ by zero");

rule /* I1 % I2 */ I1:Int :: _ % I2:Int :: _ => (I1 %Int I2) :: tempType
    			when I2 =/=Int 0
rule /* F1 % F2 */ F1:Float :: _ % F2:Float :: _ => (F1 %Float F2) :: tempType

//totest that the first argument is fully evaluated, right now it may be not evaluated
rule _:TypedVal % 0::_ => throw new class String2Id("java.lang.ArithmeticException") ("/ by zero");

//rule /* I1 - I2    */ 'Minus(I1:Int :: _,, I2:Int :: _) => (I1 -Int I2) :: tempType
//rule                  'Minus(F1:Float :: _,, F2:Float :: _) => (F1 -Float F2) :: tempType
//rule /* I1 * I2    */ 'Mul(I1:Int :: _,, I2:Int :: _) => (I1 *Int I2) :: tempType
//rule                  'Mul(F1:Float :: _,, F2:Float :: _) => (F1 *Float F2) :: tempType
//rule /* I1 / I2    */ 'Div(I1:Int :: _,, I2:Int :: _) => (I1 /Int I2) :: tempType
//    when I2 =/=Int 0
//rule                  'Div(F1:Float :: _,, F2:Float :: _) => (F1 /Float F2) :: tempType
//
////totest that the first argument is fully evaluated, right now it may be not evaluated
//rule 'Div(_:TypedVal,, 0::_) => throw new class String2Id("java.lang.ArithmeticException") ("/ by zero");
//
//rule /* I1 % I2    */ 'Remain(I1:Int :: _,, I2:Int :: _) => (I1 %Int I2) :: tempType
//    when I2 =/=Int 0
//rule                  'Remain(F1:Float :: _,, F2:Float :: _) => (F1 %Float F2) :: tempType
//
////totest that the first argument is fully evaluated, right now it may be not evaluated
//rule 'Remain(_:TypedVal,, 0::_) => throw new class String2Id("java.lang.ArithmeticException") ("/ by zero");

rule [NormalizeLeftOperandToFloat]:
    KL:KLabel((I:Int::_:IntType => Int2Float(I)::float),, _:Float :: _:FloatType)
when
    isFloatBinaryOp(KL)

rule [NormalizeRightOperandToFloat]:
    KL:KLabel(_:Float :: _:FloatType,, (I:Int::_:IntType => Int2Float(I)::float))
when
    isFloatBinaryOp(KL)

syntax K ::= isFloatBinaryOp ( KLabel )       [function]
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
  (++ loc(L:Int)::NT:NumericType):PrefixPostfixExp => loc(L)::NT += rightTypedNumber(1,NT)

// --E
rule /* --loc(L) => loc(L) = lookup(L) - 1 */
  (-- loc(L:Int)::NT:NumericType):PrefixPostfixExp => loc(L)::NT -= rightTypedNumber(1,NT)

rule /* ! B    */ ! B:Bool :: bool => (notBool B) :: bool
rule /* ~ I    */ ~ I:Int :: _ => (~Int I) :: tempType
rule /* + I    */ + I:Int :: _ => I :: tempType
rule /* + F    */ + F:Float :: _ => F :: tempType
rule /* - I    */ - I:Int :: _ => (0 -Int I) :: tempType
rule /* - F    */ - F:Float :: _ => (Int2Float(0) -Float F) :: tempType

// E++
rule /* loc(L)++ => (loc(L) = lookup(L) + 1) - 1 */
   loc(L:Int) :: NT:NumericType ++ =>  (++ loc(L)::NT):PrefixPostfixExp - rightTypedNumber(1,NT)

// E--
rule /* loc(L)-- => (loc(L) = lookup(L) - 1) + 1 */
  loc(L:Int) :: NT:NumericType -- => (-- loc(L)::NT):PrefixPostfixExp + rightTypedNumber(1,NT)

/*@ Computes a TypedVal where value representation is of correct numeric type:
Int when NT is IntType, Float when NT is FloatType*/
syntax K ::= rightTypedNumber ( Int, NumericType )             [function]
rule rightTypedNumber(I:Int, IntT:IntType) => I::IntT
rule rightTypedNumber(I:Int, FloatT:FloatType) => Int2Float(I)::FloatT

/*@ Conditional expression : ?: . Desugared into an if with cast.
The biggest difficulty is computing the expression type, according to JLS1 \$15.24
The whole expression should always come wrapped into a cast, from elaboration.
Thus we don't have to worry about proper type conversion here.*/
//rule 'Cond(CondExp:K,, TrueExp:K,, FalseExp:K) => 'If(CondExp,, TrueExp,, FalseExp)
rule CondExp:K ? TrueExp:K : FalseExp:K => 'If(CondExp,, TrueExp,, FalseExp)
/*@ \subsubsection{Assignment operators}
Both basic assignment and compound assignments like +=, -=, etc. */

context _:KResult = HOLE

rule [Assign]:
    loc(L:Int) :: ResT:Type = V:RawVal :: ResT => store(L, V::ResT) ~> V::ResT

/*@ Desugars compound assign into the underlying operator + assign.

    Question: Why not during elaboration phase?
    Answer:
  - in the LHS of => location L is referred once
  - in the RHS of => it is referred twice
  - at elaboration phase we would have to rewrite the original expresion that produces L
      from one occurence to two occuences.
  - if operator LHS expression have side effects, we would end up with the side effect twice.
  - Example: v[i++] += 1
*/
rule [Compound-Assign]:
    KL:KLabel(loc(L:Int) :: T:Type,, Exp2:K)
    => loc(L)::T = cast(T, getOperatorLabel(KL)(lookup(L, T),, Exp2))
when isCompoundAssignExp(KL(.KList))
//loc(L:Int) :: T:Type += Exp2:K => loc(L)::T = cast(T, (lookup(L, T) + Exp2))
/*@ Returns the KLabel corresponding to the underlying operator of the given compound assignment KLabel.
*/
syntax KLabel ::= getOperatorLabel ( KLabel )         [function]
rule getOperatorLabel('AssignPlus)        => 'Plus
rule getOperatorLabel('AssignMinus)       => 'Minus
rule getOperatorLabel('AssignMul)         => 'Mul
rule getOperatorLabel('AssignDiv)         => 'Div
rule getOperatorLabel('AssignAnd)         => 'And
rule getOperatorLabel('AssignOr)          => 'Or
rule getOperatorLabel('AssignExcOr)       => 'ExcOr
rule getOperatorLabel('AssignRemain)      => 'Remain
rule getOperatorLabel('AssignLeftShift)   => 'LeftShift
rule getOperatorLabel('AssignRightShift)  => 'RightShift
rule getOperatorLabel('AssignURightShift) => 'URightShift

/*@ \subsection{primitive types cast} */

//@ The type of RV could either be NumericType or tempType. This rule matches both.
rule [cast-Number]: cast(NT:NumericType, RV:RawVal::_) => normalize(RV::NT)

rule [cast-Bool]: cast(bool, B:Bool::bool) => B::bool

/*@ \subsubsection{artificial cases of cast, arised during semantics separation} */

rule [cast-void]: cast(void, RV:RawVal::void) => RV::void

//Happens for the qualifier of a static method call
rule [cast-noValue]: cast(_, noValue) => noValue

/*@ \subsection{lvalue semantics} */

/* We cannot use context rules here because of wrapper-related limitations. If a term is wrapped into lvalue
  during heating by a context rule, it will be cooled also from lvalue by the cooling rule. This is unacceptable
  in Java semantics.*/

rule [exp-lvalue-Heat]:
    (. => lvalue(K)) ~> KL:KLabel((K:K => HOLE),, _)
when
    (      KL ==KLabel 'Assign
    orBool isPrefixPostfixExp(KL(.KList)) ==K true
    orBool isCompoundAssignExp(KL(.KList)) ==K true
    )
    andBool notBool (isKResult(K) ==K true)

rule [exp-lvalue-Cool]:
    (KR:KResult => .) ~> KL:KLabel((HOLE => KR),, _)

//rule     (. => lvalue(K)) ~> ((K:K => HOLE) =  _)
//rule     (. => lvalue(K)) ~> ((K:K => HOLE) *=  _)
//rule     (. => lvalue(K)) ~> ((K:K => HOLE) /=  _)
//rule     (. => lvalue(K)) ~> ((K:K => HOLE) %=  _)
//rule     (. => lvalue(K)) ~> ((K:K => HOLE) +=  _)
//rule     (. => lvalue(K)) ~> ((K:K => HOLE) -=  _)
//rule     (. => lvalue(K)) ~> ((K:K => HOLE) <<=  _)
//rule     (. => lvalue(K)) ~> ((K:K => HOLE) >>=  _)
//rule     (. => lvalue(K)) ~> ((K:K => HOLE) >>>=  _)
//rule     (. => lvalue(K)) ~> ((K:K => HOLE) &=  _)
//rule     (. => lvalue(K)) ~> ((K:K => HOLE) ^=  _)
//rule     (. => lvalue(K)) ~> ((K:K => HOLE) |=  _)
//rule     (. => lvalue(K)) ~> ++(K:K => HOLE)
//rule     (. => lvalue(K)) ~> --(K:K => HOLE)
//rule     (. => lvalue(K)) ~> (K:K => HOLE)++
//rule     (. => lvalue(K)) ~> (K:K => HOLE)--
//
//rule     (KR:KResult => .) ~> ((HOLE => KR) =  _)
//rule     (KR:KResult => .) ~> ((HOLE => KR) *=  _)
//rule     (KR:KResult => .) ~> ((HOLE => KR) /=  _)
//rule     (KR:KResult => .) ~> ((HOLE => KR) %=  _)
//rule     (KR:KResult => .) ~> ((HOLE => KR) +=  _)
//rule     (KR:KResult => .) ~> ((HOLE => KR) -=  _)
//rule     (KR:KResult => .) ~> ((HOLE => KR) <<=  _)
//rule     (KR:KResult => .) ~> ((HOLE => KR) >>=  _)
//rule     (KR:KResult => .) ~> ((HOLE => KR) >>>=  _)
//rule     (KR:KResult => .) ~> ((HOLE => KR) &=  _)
//rule     (KR:KResult => .) ~> ((HOLE => KR) ^=  _)
//rule     (KR:KResult => .) ~> ((HOLE => KR) |=  _)
//rule     (KR:KResult => .) ~> ++(HOLE => KR)
//rule     (KR:KResult => .) ~> --(HOLE => KR)
//rule     (KR:KResult => .) ~> (HOLE => KR)++
//rule     (KR:KResult => .) ~> (HOLE => KR)--

/*@ Required when a JVM-related exception (e.g. produced by the semantics at runtime) is thrown inside a lvalue.
*/
rule [lvalue-Throw-desugar]:
    lvalue( throw E:Exp; ) => throw E;
        [structural]

syntax K ::=  store (
                Int,  //OL - the store location
                K     //evaluates to TypedVal - the value to be stored
              ) [strict(2)]

//@ Synchronization checkpoint have to be before the actual assignment, like for lookup.
rule [store]:
    store(L:Int, V:RawVal :: T:Type) => fieldAccessCheckpoint(L) ~> storeImpl(L, V::T)

syntax K ::=  storeImpl (
                Int,  //OL - the store location
                K     //TypedVal - the value to be stored
              )

rule [storeImpl]:
    <k> storeImpl(L:Int, V:RawVal :: T:Type) => . ...</k>
    <store>... L |-> (_ => V) :: T ...</store>

/*@ \subsection{auxiliary terms produced during elaboration} */

rule stmtAndExp(Stmt:K, Exp:K) => Stmt ~> Exp

endmodule
