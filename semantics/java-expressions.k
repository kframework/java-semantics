module JAVA-EXPRESSIONS
    imports JAVA-CORE
    imports JAVA-PRIMITIVE-TYPES

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
                | /* +   */ "'Plus"        // strictness already specified
                | /* -   */ "'Minus"       // strictness already specified

                //Postfix operators
                | /* ++  */ "'PostIncr"
                | /* --  */ "'PostDecr"

                //Ternary operators
                | /* ? : */ "'Cond"

rule /* true  || _ */ 'LazyOr(true :: bool,, _) => true :: bool
rule /* false || K */ 'LazyOr(false :: bool,, K:K) => K
rule /* true  && K */ 'LazyAnd(true :: bool,, K:K) => K
rule /* false && _ */ 'LazyAnd(false :: bool,, _:K) => false :: bool

rule /* I1 | I2 */ 'Or(I1:Int :: NT1:NumericType,, I2:Int :: NT2:NumericType)
    => normalize( (I1 |Int I2), NT1, NT2 )
rule /* B1 | B2 */ 'Or(B1:Bool :: bool,, B2:Bool :: bool) => (B1 orBool B2) :: bool
rule /* I1 ^ I2 */ 'ExcOr(I1:Int :: NT1:NumericType,, I2:Int :: NT2:NumericType) => normalize( (I1 xorInt I2), NT1, NT2 )
rule /* B1 ^ B2 */ 'ExcOr(B1:Bool :: bool,, B2:Bool :: bool) => (B1 xorBool B2) :: bool
rule /* I1 & I2 */ 'And(I1:Int :: NT1:NumericType,, I2:Int :: NT2:NumericType) => normalize( (I1 &Int I2), NT1, NT2 )
rule /* B1 & B2 */ 'And(B1:Bool :: bool,, B2:Bool :: bool) => (B1 andBool B2) :: bool

rule /* V1 == V2 */ 'Eq(V1:RawVal :: _,, V2:RawVal :: _) => (V1 ==K V2) :: bool
rule /* V1 != V2 */ 'NotEq(V1:RawVal :: _,, V2:RawVal :: _) => (V1 =/=K V2) :: bool
rule /* I1 <  I2 */ 'Lt(I1:Int :: _,, I2:Int :: _) => (I1 <Int I2) :: bool
rule /* I1 >  I2 */ 'Gt(I1:Int :: _,, I2:Int :: _) => (I1 >Int I2) :: bool
rule /* I1 <= I2 */ 'LtEq(I1:Int :: _,, I2:Int :: _) => (I1 <=Int I2) :: bool
rule /* I1 >= I2 */ 'GtEq(I1:Int :: _,, I2:Int :: _) => (I1 >=Int I2) :: bool

//normalization of first argument of bit shift operator
rule KL:KLabel(I1:Int :: NT1:NumericType,, I2:Int :: NT2:NumericType) => KL(I1 :: normalizeType(NT1),, I2 :: NT2)
    when    KL ==KLabel 'LeftShift
     orBool KL ==KLabel 'RightShift
     orBool KL ==KLabel 'URightShift

rule /* I1 <<  I2 */ 'LeftShift(I1:Int :: ILT:IntOrLongType,, I2:Int :: _)
    => normalize( (I1 <<Int (I2 &Int (bitCount(ILT) -Int 1))) :: ILT ) //JLS 15.19
rule /* I1 >>  I2 */ 'RightShift(I1:Int :: ILT:IntOrLongType,, I2:Int :: _)
    => normalize( (I1 >>Int (I2 &Int (bitCount(ILT) -Int 1))) :: ILT )
rule /* I1 >>> I2 */ 'URightShift(I1:Int :: ILT:IntOrLongType,, I2:Int :: NT:NumericType)
  => 'Cond(
    (I1 >=Int 0)::bool,,
    'RightShift(I1 :: ILT,, I2 :: NT),,
    'Plus('RightShift(I1::ILT,, I2::NT),, 'LeftShift(2::ILT,, 'Complement(I2::NT)))
  )

rule /* I1 + I2     */ 'Plus(I1:Int :: NT1:NumericType,, I2:Int :: NT2:NumericType) => normalize( (I1 +Int I2), NT1, NT2 )
rule /* Str1 + Str2 */ 'Plus(Str1:String :: rtString,, Str2:String :: rtString)
    => (Str1 +String Str2) :: rtString
rule /* Str + KR    */ 'Plus(Str:String :: rtString,, ( KR:KResult => toString(KR) ))
when       typeOf(KR) =/=K rtString
    orBool KR ==K (null::rtString)
rule /* KR + Str    */ 'Plus(( KR:KResult => toString(KR) ),, Str:String :: rtString)
when       typeOf(KR) =/=K rtString
    orBool KR ==K (null::rtString)

rule /* I1 - I2    */ 'Minus(I1:Int :: NT1:NumericType,, I2:Int :: NT2:NumericType) => normalize( (I1 -Int I2), NT1, NT2 )
rule /* I1 * I2    */ 'Mul(I1:Int :: NT1:NumericType,, I2:Int :: NT2:NumericType) => normalize( (I1 *Int I2), NT1, NT2 )
rule /* I1 / I2    */ 'Div(I1:Int :: NT1:NumericType,, I2:Int :: NT2:NumericType) => normalize( (I1 /Int I2), NT1, NT2 )
    when I2 =/=Int 0

//todo test that the first argument is fully evaluated, right now it may be not evaluated
rule                  'Div(_::_     ,, 0::_)
   => 'Throw('NewInstance(
        'None(.List{K}),,
        'class_(String2Id("ArithmeticException")),,
        'ListWrap( "/ by zero" :: rtString ),,
        'None(.List{K})
      ))

rule /* I1 % I2    */ 'Remain(I1:Int :: NT1:NumericType,, I2:Int :: NT2:NumericType) => normalize( (I1 %Int I2), NT1, NT2 )
    when I2 =/=Int 0

//todo test that the first argument is fully evaluated, right now it may be not evaluated
rule                  'Remain(_::_     ,, 0::_)
   => 'Throw('NewInstance(
        'None(.List{K}),,
        'class_(String2Id("ArithmeticException")),,
        'ListWrap( "/ by zero" :: rtString ),,
        'None(.List{K})
      ))

// ++E
context 'PreIncr(HOLE => lvalue(HOLE))
rule /* ++loc(L) => loc(L) = lookup(L) + 1 */
  'PreIncr(loc(L:Int)::NT:NumericType) => 'AssignPlus( loc(L)::NT,, 1::NT )

// --E
context 'PreDecr(HOLE => lvalue(HOLE))
rule /* --loc(L) => loc(L) = lookup(L) - 1 */
  'PreDecr(loc(L:Int)::NT:NumericType) => 'AssignMinus( loc(L)::NT,, 1::NT )

rule /* ! B    */ 'Not(B:Bool :: bool) => (notBool B) :: bool
rule /* ~ I    */ 'Complement(I:Int :: NT:NumericType) => normalize( (~Int I), NT )
rule /* + I    */ 'Plus(I:Int :: NT:NumericType) => normalize( I, NT )
rule /* - I    */ 'Minus(I:Int :: NT:NumericType) => normalize( (0 -Int I), NT )

// E++
context 'PostIncr(HOLE => lvalue(HOLE))
rule /* loc(L)++ => (loc(L) = lookup(L) + 1) - 1 */
  'PostIncr(loc(L:Int) :: NT:NumericType) => 'Minus( 'PreIncr(loc(L)::NT),, 1::NT)

// E--
context 'PostDecr(HOLE => lvalue(HOLE))
rule /* loc(L)-- => (loc(L) = lookup(L) - 1) + 1 */
  'PostDecr(loc(L:Int) :: NT:NumericType) => 'Plus( 'PreDecr(loc(L)::NT),, 1::NT)

//semantically if and ?: are equivalent
rule 'Cond(Ks:List{K}) => 'If(Ks)

/*@ \subsubsection{Assignment operators}
Typed KOOL allows to assign subtype instance values to supertype lvalues.
Assignment operators are seqstrict according to JLS. */

syntax K ::= "isCompoundAssignLabel" "(" KLabel ")" [function]
rule isCompoundAssignLabel(KL:KLabel) =>
           KL ==KLabel 'AssignPlus
    orBool KL ==KLabel 'AssignMinus
    orBool KL ==KLabel 'AssignMul
    orBool KL ==KLabel 'AssignDiv
    orBool KL ==KLabel 'AssignAnd
    orBool KL ==KLabel 'AssignOr
    orBool KL ==KLabel 'AssignExcOr
    orBool KL ==KLabel 'AssignRemain
    orBool KL ==KLabel 'AssignLeftShift
    orBool KL ==KLabel 'AssignRightShift
    orBool KL ==KLabel 'AssignURightShift           [structural, anywhere]

context 'Assign((HOLE => lvalue(HOLE)),,_)
context 'Assign(_:KResult,,HOLE)

//todo check assign expression type in JLS
rule [AssignWithConversion]:
    'Assign(loc(L:Int) :: T1:Type,, V:RawVal :: T2:Type)
    =>  #if isNumericType2(T1)
          #then isInRange(V::T1)::bool
          #else subtype(T2, T1)
        #fi ~> true? ~> 'Assign(loc(L)::T1,, V::T1)
when
    T1 =/=K T2

rule [Assign]:
    <k> 'Assign(loc(L:Int) :: T:Type,, V:RawVal :: T) => V::T ...</k>
    <store>... L |-> (_ => V)::T ...</store>

context KL:KLabel((HOLE => lvalue(HOLE)),,_)
when isCompoundAssignLabel(KL)

rule [CompoundAssign]:
    KL:KLabel(loc(L:Int) :: T:Type,, E:K) => 'Assign(loc(L)::T,,
      castImpl(T, getOpLabel(KL)(lookup(L)::T,, E)))
when isCompoundAssignLabel(KL)

//only for Compound Assign KLabel's
syntax KLabel ::= "getOpLabel" "(" KLabel ")" [function]
rule getOpLabel('AssignPlus) => 'Plus [anywhere]
rule getOpLabel('AssignMinus) => 'Minus [anywhere]
rule getOpLabel('AssignMul) => 'Mul [anywhere]
rule getOpLabel('AssignDiv) => 'Div [anywhere]
rule getOpLabel('AssignAnd) => 'And [anywhere]
rule getOpLabel('AssignOr) => 'Or [anywhere]
rule getOpLabel('AssignExcOr) => 'ExcOr [anywhere]
rule getOpLabel('AssignRemain) => 'Remain [anywhere]
rule getOpLabel('AssignLeftShift) => 'LeftShift [anywhere]
rule getOpLabel('AssignRightShift) => 'RightShift [anywhere]
rule getOpLabel('AssignURightShift) => 'URightShift [anywhere]

/*@ \subsection{primitive types cast} */

syntax KLabel ::= "'CastPrim"
rule 'CastPrim(K1:K,, K2:K) => castImpl(K1,K2)

syntax K ::= "castImpl" "(" Type "," K ")" [seqstrict]
rule [CastNumber]: castImpl(NT:NumericType, I:Int::_) => normalize(I::NT)
rule [CastBool]: castImpl(bool, B:Bool::bool) => B::bool

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
    <k> X:Id => TV ...</k>
    <env>... X |-> L:Int ...</env>
    <store>... L |-> TV:TypedVal ...</store>
        [transition]

rule [lookupLocation]:
    <k>
      lookup(L:Int) :: T1:Type
      => subtype(T2, T1) ~> true? ~> V::T1
      ...
    </k>
    <store>... L |-> V:RawVal :: T2:Type ...</store>
        [transition]

endmodule
