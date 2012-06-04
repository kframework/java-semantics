module JAVA-PRIMITIVE-TYPES
    imports JAVA-CORE

//@ \subsection{Type labels}
//@Here we rewrite java type ast into simple types

rule 'Byte(_) => byte [structural]
rule 'Short(_) => short [structural]
rule 'Int(_) => int [structural]
rule 'Long(_) => long [structural]
rule 'Char(_) => char [structural]
rule 'Boolean(_) => bool [structural]
rule 'Void(_) => void [structural]

//@ \subsection{Integer types normalization}

declare bitCount : Type -> Int
define bitCount(byte) => 8
define bitCount(short) => 16
define bitCount(int) => 32
define bitCount(long) => 64
define bitCount(char) => 16

declare normalize : TypedVal -> TypedVal

define normalize(I:Int :: byte)
    =>  #if I >=Int -128 andBool I <=Int 127
          #then I :: byte
          #else normalizeImpl(I::byte)
        #fi

define normalize(I:Int :: short)
    =>  #if I >=Int -32768 andBool I <=Int 32767
          #then I :: short
          #else normalizeImpl(I::short)
        #fi

define normalize(I:Int :: int)
    =>  #if I >=Int -2147483648 andBool I <=Int 2147483647
          #then I :: int
          #else normalizeImpl(I::int)
        #fi

define normalize(I:Int :: long)
    =>  #if I >=Int -9223372036854775808 andBool I <=Int 9223372036854775807
          #then I :: long
          #else normalizeImpl(I::long)
        #fi

define normalize(I:Int :: char)
    =>  #if I >=Int 0 andBool I <=Int 65535
          #then I :: char
          #else toUnsigned(normalizeImpl(I::char))
        #fi

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

end module
