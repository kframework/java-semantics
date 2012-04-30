module JAVA-EXPRESSIONS
    imports JAVA-CORE

  syntax K ::= "lvalue" "(" K ")"
  syntax Val ::= "loc" "(" #Int ")"
  declare typeOf :  K -> Type
  syntax K ::= "subtype" List{KResult} "," List{KResult}
  declare unsafeCast : Val Type -> Val

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
                  | /* +   */ 'Plus        [strict]
                  | /* -   */ 'Minus       [strict]

                  //Postfix operators
                  | /* ++  */ 'PostIncr
                  | /* --  */ 'PostDecr

                  //Ternary operators
                  | /* ? : */ 'Cond

  rule /* true  || _ */ 'LazyOr(true,,_) => true
  rule /* false || K */ 'LazyOr(false,,K) => K
  rule /* true  && K */ 'LazyAnd(true,,K) => K
  rule /* false && _ */ 'LazyAnd(false,,_) => false

  rule /* I1 | I2 */ 'Or(I1,,I2) => I1 |Int I2
  rule /* B1 | B2 */ 'Or(B1:#Bool,,B2:#Bool) => B1 orBool B2
  rule /* I1 ^ I2 */ 'ExcOr(I1,,I2) => I1 xorInt I2
  rule /* B1 ^ B2 */ 'ExcOr(B1,,B2) => B1 xorBool B2
  rule /* I1 & I2 */ 'And(I1,,I2) => I1 &Int I2
  rule /* B1 & B2 */ 'And(B1,,B2) => B1 andBool B2

  rule /* V1 == V2 */ 'Eq(V1:Val,,V2:Val) => V1 ==Bool V2
  rule /* V1 != V2 */ 'NotEq(V1,,V2) => V1 =/=Bool V2
  rule /* I1 <  I2 */ 'Lt(I1,,I2) => I1 <Int I2
  rule /* I1 >  I2 */ 'Gt(I1,,I2) => I1 >Int I2
  rule /* I1 <= I2 */ 'LtEq(I1,,I2) => I1 <=Int I2
  rule /* I1 >= I2 */ 'GtEq(I1,,I2) => I1 >=Int I2

  rule /* I1 <<  I2 */ 'LeftShift(I1,,I2) => I1 <<Int (I2 &Int 31) //JLS 15.19
  rule /* I1 >>  I2 */ 'RightShift(I1,,I2) => I1 >>Int (I2 &Int 31)
  rule /* I1 >>> I2 */ 'URightShift(I1,,I2) => 'Cond(I2 >=Int 0,, 'RightShift(I1,,I2),,
      'Plus('RightShift(I1,,I2),, 'LeftShift(2,,'Complement(I2))))

  rule /* I1 + I2     */ 'Plus(I1:#Int,,I2:#Int) => I1 +Int I2
  rule /* Str + KR    */ 'Plus(Str:#String,,KR:KResult) => Str +String toString(KR)
  rule /* KR + Str    */ 'Plus(KR,,Str) => toString(KR) +String Str
      when typeOf(KR) =/=Bool rtString

  rule /* I1 - I2    */ 'Minus(I1,,I2) => _-Int_(I1,I2)
  rule /* I1 * I2    */ 'Mul(I1,,I2) => I1 *Int I2
  rule /* I1 / I2    */ 'Div(I1,,I2) => I1 /Int I2 when I2 =/=Bool 0 //todo ArithmeticException
  rule /* I1 % I2    */ 'Remain(I1,,I2) => I1 %Int I2 when I2 =/=Bool 0 //todo ArithmeticException

  // ++E
  context 'PreIncr(HOLE => lvalue(HOLE))
  rule /* ++loc(L) => loc(L) = lookup(L) + 1 */
    'PreIncr(loc(L)) => 'Assign(loc(L:#Int),, 'Plus(lookup(L),,1))

  // --E
  context 'PreDecr(HOLE => lvalue(HOLE))
  rule /* --loc(L) => loc(L) = lookup(L) - 1 */
    'PreDecr(loc(L)) => 'Assign(loc(L),, 'Minus(lookup(L),,1))

  rule /* ! B    */ 'Not(B:#Bool) => notBool(B)
  rule /* ~ I    */ 'Complement(I:#Int) => ~Int I
  rule /* + I    */ 'Plus(I) => I
  rule /* - I    */ 'Minus(I) => 0 -Int I

  // E++
  context 'PostIncr(HOLE => lvalue(HOLE))
  rule /* loc(L)++ => (loc(L) = lookup(L) + 1) - 1 */
    'PostIncr(loc(L)) => 'Minus( 'Assign(loc(L),, 'Plus(lookup(L),,1)),, 1)

  // E--
  context 'PostDecr(HOLE => lvalue(HOLE))
  rule /* loc(L)-- => (loc(L) = lookup(L) - 1) + 1 */
    'PostDecr(loc(L)) => 'Plus( 'Assign(loc(L),, 'Minus(lookup(L),,1)),, 1)

  //semantically if and ?: are equivalent
  rule 'Cond(Ks:List{K}) => 'If(Ks)

/*@ \subsubsection{Assignment operators}
Typed KOOL allows to assign subtype instance values to supertype lvalues.
Assignment operators are seqstrict according to JLS. */

  syntax KLabel ::=
                  | /* =    */ 'Assign
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

  context 'Assign((HOLE => lvalue(HOLE)),,_)
  context 'Assign(_:KResult,,HOLE)

  rule <k> 'Assign(loc(L),,V) => subtype typeOf(V), typeOf(K) ~> true?
           ~> unsafeCast(V,typeOf(K:K)) ...</k>
       <store>... L |-> (K => unsafeCast(V, typeOf(K))) ...</store> [transition]

  /* loc(L) += E => loc(L) = lookup(L) + E */
  context 'AssignPlus((HOLE => lvalue(HOLE)),,_)
  rule 'AssignPlus(loc(L),,E:K) => 'Assign(loc(L),, 'Plus(lookup(L),, E))

  /* loc(L) -= E => loc(L) = lookup(L) - E */
  context 'AssignMinus((HOLE => lvalue(HOLE)),,_)
  rule 'AssignMinus(loc(L),,E) => 'Assign(loc(L),, 'Minus(lookup(L),, E))

  /* loc(L) *= E => loc(L) = lookup(L) * E */
  context 'AssignMul((HOLE => lvalue(HOLE)),,_)
  rule 'AssignMul(loc(L),,E) => 'Assign(loc(L),, 'Mul(lookup(L),, E))

  /* loc(L) /= E => loc(L) = lookup(L) / E */
  context 'AssignDiv((HOLE => lvalue(HOLE)),,_)
  rule 'AssignDiv(loc(L),,E) => 'Assign(loc(L),, 'Div(lookup(L),, E))

  /* loc(L) &= E => loc(L) = lookup(L) & E */
  context 'AssignAnd((HOLE => lvalue(HOLE)),,_)
  rule 'AssignAnd(loc(L),,E) => 'Assign(loc(L),, 'And(lookup(L),, E))

  /* loc(L) |= E => loc(L) = lookup(L) | E */
  context 'AssignOr((HOLE => lvalue(HOLE)),,_)
  rule 'AssignOr(loc(L),,E) => 'Assign(loc(L),, 'Or(lookup(L),, E))

  /* loc(L) ^= E => loc(L) = lookup(L) ^ E */
  context 'AssignExcOr((HOLE => lvalue(HOLE)),,_)
  rule 'AssignExcOr(loc(L),,E) => 'Assign(loc(L),, 'ExcOr(lookup(L),, E))

  /* loc(L) %= E => loc(L) = lookup(L) % E */
  context 'AssignRemain((HOLE => lvalue(HOLE)),,_)
  rule 'AssignRemain(loc(L),,E) => 'Assign(loc(L),, 'Remain(lookup(L),, E))

  /* loc(L) <<= E => loc(L) = lookup(L) << E */
  context 'AssignLeftShift((HOLE => lvalue(HOLE)),,_)
  rule 'AssignLeftShift(loc(L),,E) => 'Assign(loc(L),, 'LeftShift(lookup(L),, E))

  /* loc(L) >>= E => loc(L) = lookup(L) >> E */
  context 'AssignRightShift((HOLE => lvalue(HOLE)),,_)
  rule 'AssignRightShift(loc(L),,E) => 'Assign(loc(L),, 'RightShift(lookup(L),, E))

  /* loc(L) >>>= E => loc(L) = lookup(L) >>> E */
  context 'AssignURightShift((HOLE => lvalue(HOLE)),,_)
  rule 'AssignURightShift(loc(L),,E) => 'Assign(loc(L),, 'URightShift(lookup(L),, E))

/*@ \subsubsection{lookup} */
  syntax K ::= "lookup" "(" #Int ")"
  rule <k> lookup(L) => V:Val ...</k> <store>... L |-> V ...</store> [transition]

/*@ \subsubsection{Array access}
Check array bounds, as part of the dynamic typing policy. */

  syntax KLabel ::= 'ArrayAccess [seqstrict]
  rule [arrayLookup]:
      'ArrayAccess(arrayRef(_,L,M:#Int),, N:#Int) => lookup(L +Int N)
    when N >=Int 0 andBool N <Int M   [structural anywhere]

//Array length, as defined in JDK
  syntax #Id ::= "length"
  rule 'ExprName(arrayRef(_,_:#Int,N),, length) => N

end module
