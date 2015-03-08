module PRIMITIVE-TYPES
    imports SUBTYPING

//@ \subsection{Integer types normalization}

syntax Int ::= bitCount ( Type ) [function]
rule bitCount(byte) => 8
rule bitCount(short) => 16
rule bitCount(int) => 32
rule bitCount(long) => 64
rule bitCount(char) => 16

/*@ Symbolic execution limitation: this construct cannot be [function]
    When conditionals are needed, implementation have to use 'If - the symbolically processed version of if.
*/
syntax KItem ::= normalize ( TypedVal )

rule normalize(I:Int :: IntT:IntType)
    =>  ifAux(isInRange(I::IntT),
          I::IntT,
          normalizeImpl(I::IntT)
        )
when IntT =/=K char

rule normalize(I:Int :: char)
    =>  ifAux(isInRange(I::char),
          I :: char,
          toUnsigned(normalizeImpl(I::char))
        )

rule normalize(I:Int :: FloatT:FloatType) => Int2Float(I,53,11)::FloatT

rule normalize(F:Float :: IntT:IntType) => normalize(Float2Int(F) :: IntT:IntType)

rule normalize(F:Float :: FloatT:FloatType) => F::FloatT

//@ Symbolic execution limitation: this construct cannot be [function]
syntax KItem ::= isInRange ( TypedVal )
rule isInRange(I:Int::byte) => ((I >=Int -128) andBool (I <=Int 127))
rule isInRange(I:Int::short) => ((I >=Int -32768) andBool (I <=Int 32767))
rule isInRange(I:Int::int) => ((I >=Int -2147483648) andBool (I <=Int 2147483647))
rule isInRange(I:Int::long) => ((I >=Int -9223372036854775808)
                          andBool (I <=Int  9223372036854775807))
rule isInRange(I:Int::char) => ((I >=Int 0) andBool (I <=Int 65535))

rule isInRange(RV:RawVal::_) => true
when notBool (isInt(RV) ==K true)

/*@ Symbolic execution limitation: this construct cannot be [function]
*/
syntax KItem ::= normalizeImpl ( TypedVal )

rule normalizeImpl(I:Int :: T:Type)
    => normalizeSign((((I &Int ((1 <<Int bitCount(T)) -Int 1))
        +Int (1 <<Int bitCount(T)))
        &Int ((1 <<Int bitCount(T)) -Int 1)) :: T)

/*@ Symbolic execution limitation: this construct cannot be [function]
    When conditionals are needed, implementation have to use 'If - the symbolically processed version of if.
*/
syntax KItem ::= normalizeSign ( TypedVal )       [strict]

rule normalizeSign(I:Int :: T:Type)
    =>  ifAux(I <=Int ((1 <<Int (bitCount(T) -Int 1)) -Int 1),
          I :: T,
          I -Int (1 <<Int bitCount(T)) :: T
        )

/*@ Symbolic execution limitation: this construct cannot be [function]
    When conditionals are needed, implementation have to use 'If - the symbolically processed version of if.
*/
syntax KItem ::= toUnsigned ( TypedVal )          [strict]
rule toUnsigned(I:Int :: T:Type)
    =>  ifAux(I >=Int 0,
          I :: T,
          I +Int (1 <<Int bitCount(T)) :: T
        )

syntax KItem ::= normalizeType ( Type )           [function]
rule normalizeType(ILT:IntOrLongType) => ILT

rule normalizeType(FT:FloatType) => FT

rule normalizeType(IT:IntType) => int
when (IT =/=K int) andBool (IT =/=K long)

/*@ Important! Binary normalizeType cannot be function because it uses sybtype in implementation.
*/
syntax KItem ::= normalizeType ( Type, Type )   [function]

rule normalizeType(NT1:IntType, NT2:IntType) => int
when (NT1 =/=K long) andBool (NT2 =/=K long)

rule normalizeType(NT1:IntType, NT2:IntType) => long
when (NT1 ==K long) orBool (NT2 ==K long)

rule normalizeType(T:Type, FT:FloatType) => ifAux(subtype(T, FT), FT, T)
rule normalizeType(FT:FloatType, T:Type) => ifAux(subtype(T, FT), FT, T)

//not technically primitive types, but here is the most appropriate place to put the rules
rule normalizeType(Class:ClassType, _) => Class
when (Class ==K classString)

rule normalizeType(_, Class:ClassType) => Class
when (Class ==K classString)

//Other cases. Required by the rule CompoundAssign
rule normalizeType(T1:Type, T2:Type) => T1
when notBool (isNumericType(T1) ==K true) andBool (T2 =/=K classString)

rule normalizeType(bool, bool) => bool

endmodule
