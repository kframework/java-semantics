require "core-sorts.k"
require "subtyping.k"

//@ \section{Module PRIMITIVE-TYPES}

module PRIMITIVE-TYPES
    imports CORE-SORTS
    imports SUBTYPING

syntax KLabel ::= "'Boolean"
                | "'Byte"
                | "'Short"
                | "'Int"
                | "'Long"
                | "'Char"
                | "'Float"
                | "'Double"
                | "'Void"

//@ \subsection{Type labels}
//@Here we rewrite Java AST terms for primitive types into their corresponding Type.

rule 'Byte(.KList) => byte      [structural, anywhere]
rule 'Short(.KList) => short    [structural, anywhere]
rule 'Int(.KList) => int        [structural, anywhere]
rule 'Long(.KList) => long      [structural, anywhere]
rule 'Char(.KList) => char      [structural, anywhere]
rule 'Float(.KList) => float    [structural, anywhere]
rule 'Double(.KList) => double  [structural, anywhere]
rule 'Boolean(.KList) => bool   [structural, anywhere]
rule 'Void(.KList) => void      [structural, anywhere]

//@ \subsection{Integer types normalization}

syntax K ::= bitCount ( Type ) [function]
rule bitCount(byte) => 8
rule bitCount(short) => 16
rule bitCount(int) => 32
rule bitCount(long) => 64
rule bitCount(char) => 16

/*@ Symbolic execution limitation: this construct cannot be [function]
    When conditionals are needed, implementation have to use 'If - the symbolically processed version of if.
*/
syntax K ::= normalize ( TypedVal )

rule normalize(I:Int :: IntT:IntType)
    =>  'If(isInRange(I::IntT),,
          I::IntT,,
          normalizeImpl(I::IntT)
        )
when IntT =/=K char

rule normalize(I:Int :: char)
    =>  'If(isInRange(I::char),,
          I :: char,,
          toUnsigned(normalizeImpl(I::char))
        )

rule normalize(I:Int :: FloatT:FloatType) => Int2Float(I)::FloatT

rule normalize(F:Float :: IntT:IntType) => normalize(Float2Int(F) :: IntT:IntType)

rule normalize(F:Float :: FloatT:FloatType) => F::FloatT

//@ Symbolic execution limitation: this construct cannot be [function]
syntax K ::= isInRange ( TypedVal )
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
syntax K ::= normalizeImpl ( TypedVal )

rule normalizeImpl(I:Int :: T:Type)
    => normalizeSign((((I &Int ((1 <<Int bitCount(T)) -Int 1))
        +Int (1 <<Int bitCount(T)))
        &Int ((1 <<Int bitCount(T)) -Int 1)) :: T)

/*@ Symbolic execution limitation: this construct cannot be [function]
    When conditionals are needed, implementation have to use 'If - the symbolically processed version of if.
*/
syntax K ::= normalizeSign ( TypedVal )       [strict]

rule normalizeSign(I:Int :: T:Type)
    =>  'If(I <=Int ((1 <<Int (bitCount(T) -Int 1)) -Int 1),,
          I :: T,,
          I -Int (1 <<Int bitCount(T)) :: T
        )

/*@ Symbolic execution limitation: this construct cannot be [function]
    When conditionals are needed, implementation have to use 'If - the symbolically processed version of if.
*/
syntax K ::= toUnsigned ( TypedVal )          [strict]
rule toUnsigned(I:Int :: T:Type)
    =>  'If(I >=Int 0,,
          I :: T,,
          I +Int (1 <<Int bitCount(T)) :: T
        )

syntax K ::= normalizeType ( Type )           [function]
rule normalizeType(ILT:IntOrLongType) => ILT

rule normalizeType(FT:FloatType) => FT

rule normalizeType(IT:IntType) => int
when (IT =/=K int) andBool (IT =/=K long)

/*@ Important! Binary normalizeType cannot be function because it uses sybtype in implementation.
*/
syntax K ::= normalizeType ( Type, Type )

rule normalizeType(NT1:IntType, NT2:IntType) => int
when (NT1 =/=K long) andBool (NT2 =/=K long)

rule normalizeType(NT1:IntType, NT2:IntType) => long
when (NT1 ==K long) orBool (NT2 ==K long)

rule normalizeType(T:Type, FT:FloatType) => ifAux(subtype(T, FT), FT, T)
rule normalizeType(FT:FloatType, T:Type) => ifAux(subtype(T, FT), FT, T)

//not technically primitive types, but here is the most appropriate place to put the rules
rule normalizeType(Class:ClassType, _) => Class
when (Class ==K stringClass)

rule normalizeType(_, Class:ClassType) => Class
when (Class ==K stringClass)

//Other cases. Required by the rule CompoundAssign
rule normalizeType(T1:Type, T2:Type) => T1
when notBool (isNumericType(T1) ==K true) andBool (T2 =/=K stringClass)

rule normalizeType(bool, bool) => bool

endmodule
