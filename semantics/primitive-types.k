require "core.k"
require "subtyping.k"

//@ \section{Module PRIMITIVE-TYPES}

module PRIMITIVE-TYPES
    imports CORE
    imports SUBTYPING

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

syntax K ::= "bitCount" "(" Type ")" [function]
rule bitCount(byte) => 8
rule bitCount(short) => 16
rule bitCount(int) => 32
rule bitCount(long) => 64
rule bitCount(char) => 16

syntax K ::= "normalize" "(" TypedVal ")" [function]

rule normalize(I:Int :: IntT:IntType)
    =>  #if isInRange(I::IntT)
          #then I::IntT
          #else normalizeImpl(I::IntT)
        #fi
when IntT =/=K char

rule normalize(I:Int :: char)
    =>  #if isInRange(I::char)
          #then I :: char
          #else toUnsigned(normalizeImpl(I::char))
        #fi

rule normalize(I:Int :: FloatT:FloatType) => Int2Float(I)::FloatT

rule normalize(F:Float :: IntT:IntType) => normalize(Float2Int(F) :: IntT:IntType)

rule normalize(F:Float :: FloatT:FloatType) => F::FloatT

syntax K ::= "isInRange" "(" TypedVal ")"                                          [function]
rule isInRange(I:Int::byte) => ((I >=Int -128) andBool (I <=Int 127))
rule isInRange(I:Int::short) => ((I >=Int -32768) andBool (I <=Int 32767))
rule isInRange(I:Int::int) => ((I >=Int -2147483648) andBool (I <=Int 2147483647))
rule isInRange(I:Int::long) => ((I >=Int -9223372036854775808)
                          andBool (I <=Int  9223372036854775807))
rule isInRange(I:Int::char) => ((I >=Int 0) andBool (I <=Int 65535))

rule isInRange(RV:RawVal::_) => true
when notBool (isInt(RV) ==K true)

syntax K ::= "normalizeImpl" "(" TypedVal ")" [function]

rule normalizeImpl(I:Int :: T:Type)
    => normalizeSign((((I &Int ((1 <<Int bitCount(T)) -Int 1))
        +Int (1 <<Int bitCount(T)))
        &Int ((1 <<Int bitCount(T)) -Int 1)) :: T)

syntax K ::= "normalizeSign" "(" TypedVal ")" [function]

rule normalizeSign(I:Int :: T:Type)
    =>  #if I <=Int ((1 <<Int (bitCount(T) -Int 1)) -Int 1)
          #then I :: T
          #else I -Int (1 <<Int bitCount(T)) :: T
        #fi

syntax K ::= "toUnsigned" "(" TypedVal ")"          [function]
rule toUnsigned(I:Int :: T:Type)
    =>  #if I >=Int 0
          #then I :: T
          #else I +Int (1 <<Int bitCount(T)) :: T
        #fi

//Important: normalizeType(), both unary and binary is not a function

syntax K ::= "normalizeType" "(" Type ")"           [function]
rule normalizeType(ILT:IntOrLongType) => ILT

rule normalizeType(FT:FloatType) => FT

rule normalizeType(IT:IntType) => int
when (IT =/=K int) andBool (IT =/=K long)

syntax K ::= "normalizeType" "(" Type "," Type ")"

rule normalizeType(NT1:IntType, NT2:IntType) => int
when (NT1 =/=K long) andBool (NT2 =/=K long)

rule normalizeType(NT1:IntType, NT2:IntType) => long
when (NT1 ==K long) orBool (NT2 ==K long)

rule normalizeType(T:Type, FT:FloatType) => 'If(subtype(T, FT),, FT,, T)
rule normalizeType(FT:FloatType, T:Type) => 'If(subtype(T, FT),, FT,, T)

//not technically primitive types, but here is the most appropriate place to put the rules
rule normalizeType(rtString, _) => rtString
rule normalizeType(_, rtString) => rtString

//Other cases. Required by the rule CompoundAssign
rule normalizeType(T1:Type,T2:Type) => T1
when notBool (isNumericType(T1) ==K true) andBool (T1 =/=K rtString)  andBool (T2 =/=K rtString)

rule normalizeType(bool, bool) => bool

endmodule
