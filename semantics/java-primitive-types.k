module JAVA-PRIMITIVE-TYPES
    imports JAVA-CORE

//@ \subsection{Type labels}
//@Here we rewrite java type ast into simple types

rule 'Byte(.List{K}) => byte [structural anywhere]
rule 'Short(.List{K}) => short [structural anywhere]
rule 'Int(.List{K}) => int [structural anywhere]
rule 'Long(.List{K}) => long [structural anywhere]
rule 'Char(.List{K}) => char [structural anywhere]
rule 'Boolean(.List{K}) => bool [structural anywhere]
rule 'Void(.List{K}) => void [structural anywhere]

//@ \subsection{Integer types normalization}

declare bitCount : Type -> Int
define bitCount(byte) => 8
define bitCount(short) => 16
define bitCount(int) => 32
define bitCount(long) => 64
define bitCount(char) => 16

declare normalize : TypedVal -> TypedVal

define normalize(I:Int :: NT:NumericType)
    =>  #if isInRange(I::NT)
          #then I::NT
          #else normalizeImpl(I::NT)
        #fi
when NT =/=K char

define normalize(I:Int :: char)
    =>  #if isInRange(I::char)
          #then I :: char
          #else toUnsigned(normalizeImpl(I::char))
        #fi

declare isInRange : TypedVal -> Bool
define isInRange(I::byte) => (I >=Int -128 andBool I <=Int 127)              [structural]
define isInRange(I::short) => (I >=Int -32768 andBool I <=Int 32767)         [structural]
define isInRange(I::int) => (I >=Int -2147483648 andBool I <=Int 2147483647) [structural]
define isInRange(I::long) => (I >=Int -9223372036854775808
                      andBool I <=Int  9223372036854775807)                  [structural]
define isInRange(I::char) => (I >=Int 0 andBool I <=Int 65535)               [structural]

declare normalizeImpl : TypedVal -> TypedVal

define normalizeImpl(I:Int :: T:Type)
    => normalizeSign((((I &Int ((1 <<Int bitCount(T)) -Int 1))
        +Int (1 <<Int bitCount(T)))
        &Int ((1 <<Int bitCount(T)) -Int 1)) :: T)

declare normalizeSign : TypedVal -> TypedVal

define normalizeSign(I:Int :: T)
    =>  #if I <=Int ((1 <<Int (bitCount(T) -Int 1)) -Int 1)
          #then I :: T
          #else I -Int (1 <<Int bitCount(T)) :: T
        #fi

declare toUnsigned : TypedVal -> TypedVal
define toUnsigned(I:Int :: T)
    =>  #if I >=Int 0
          #then I :: T
          #else I +Int (1 <<Int bitCount(T)) :: T
        #fi

//promote the result type based on unary operator argument type, and normalize the result.
declare normalize : Int NumericType -> TypedVal
define normalize(I, NT) => normalize(I :: normalizeType(NT))

//promote the result type based on binary operator arguments type, and normalize the result.
declare normalize : Int NumericType NumericType -> TypedVal
define normalize(I, NT1:NumericType, NT2:NumericType ) => normalize(I :: normalizeType(NT1,NT2))

declare normalizeType : NumericType -> IntOrLongType
define normalizeType(ILT:IntOrLongType) => ILT

define normalizeType(NT) => int
when NT =/=K int andBool NT =/=K long

//todo debug changes
declare normalizeType : NumericType NumericType -> IntOrLongType

define normalizeType(NT1, NT2) => int
when NT1 =/=K long andBool NT2 =/=K long

define normalizeType(NT1, NT2) => long
when NT1 ==K long orBool NT2 ==K long

end module
