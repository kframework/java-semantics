require "java-core.k"

module JAVA-PRIMITIVE-TYPES
    imports JAVA-CORE

//@ \subsection{Type labels}
//@Here we rewrite java type ast into simple types

rule 'Byte(.KList) => byte [structural, anywhere]
rule 'Short(.KList) => short [structural, anywhere]
rule 'Int(.KList) => int [structural, anywhere]
rule 'Long(.KList) => long [structural, anywhere]
rule 'Char(.KList) => char [structural, anywhere]
rule 'Boolean(.KList) => bool [structural, anywhere]
rule 'Void(.KList) => void [structural, anywhere]

//@ \subsection{Integer types normalization}

syntax K ::= "bitCount" "(" Type ")" [function]
rule bitCount(byte) => 8 [anywhere]
rule bitCount(short) => 16 [anywhere]
rule bitCount(int) => 32 [anywhere]
rule bitCount(long) => 64 [anywhere]
rule bitCount(char) => 16 [anywhere]

syntax K ::= "normalize" "(" TypedVal ")" [function]

rule normalize(I:Int :: NT:NumericType)
    =>  #if isInRange(I::NT)
          #then I::NT
          #else normalizeImpl(I::NT)
        #fi
when NT =/=K char [anywhere]

rule normalize(I:Int :: char)
    =>  #if isInRange(I::char)
          #then I :: char
          #else toUnsigned(normalizeImpl(I::char))
        #fi [anywhere]

syntax K ::= "isInRange" "(" TypedExp ")"                                          [function]
rule isInRange(I:Int::byte) => ((I >=Int -128) andBool (I <=Int 127))              [structural, anywhere]
rule isInRange(I:Int::short) => ((I >=Int -32768) andBool (I <=Int 32767))         [structural, anywhere]
rule isInRange(I:Int::int) => ((I >=Int -2147483648) andBool (I <=Int 2147483647)) [structural, anywhere]
rule isInRange(I:Int::long) => ((I >=Int -9223372036854775808)
                          andBool (I <=Int  9223372036854775807))                  [structural, anywhere]
rule isInRange(I:Int::char) => ((I >=Int 0) andBool (I <=Int 65535))               [structural, anywhere]

rule isInRange(K:K::_) => true
when notBool (isInt(K) ==K true)                                                   [structural, anywhere]

syntax K ::= "normalizeImpl" "(" TypedVal ")" [function]

rule normalizeImpl(I:Int :: T:Type)
    => normalizeSign((((I &Int ((1 <<Int bitCount(T)) -Int 1))
        +Int (1 <<Int bitCount(T)))
        &Int ((1 <<Int bitCount(T)) -Int 1)) :: T) [anywhere]

syntax K ::= "normalizeSign" "(" TypedVal ")" [function]

rule normalizeSign(I:Int :: T:Type)
    =>  #if I <=Int ((1 <<Int (bitCount(T) -Int 1)) -Int 1)
          #then I :: T
          #else I -Int (1 <<Int bitCount(T)) :: T
        #fi [anywhere]

syntax K ::= "toUnsigned" "(" TypedVal ")" [function]
rule toUnsigned(I:Int :: T:Type)
    =>  #if I >=Int 0
          #then I :: T
          #else I +Int (1 <<Int bitCount(T)) :: T
        #fi [anywhere]

syntax K ::= "normalizeType" "(" Type ")" [function]
rule normalizeType(ILT:IntOrLongType) => ILT [anywhere]

rule normalizeType(NT:NumericType) => int
when (NT =/=K int) andBool (NT =/=K long) [anywhere]

syntax K ::= "normalizeType" "(" Type "," Type ")" [function]

rule normalizeType(NT1:NumericType, NT2:NumericType) => int
when (NT1 =/=K long) andBool (NT2 =/=K long) [anywhere]

rule normalizeType(NT1:NumericType, NT2:NumericType) => long
when (NT1 ==K long) orBool (NT2 ==K long) [anywhere]

//not technically primitive types, but here is the most appropriate place to put the rules
rule normalizeType(rtString, _) => rtString
rule normalizeType(_, rtString) => rtString

//Other cases. Required by the rule CompoundAssign
rule normalizeType(T1:Type,T2:Type) => T1
when notBool (isNumericType(T1) ==K true) andBool (T1 =/=K rtString)  andBool (T2 =/=K rtString)

endmodule
