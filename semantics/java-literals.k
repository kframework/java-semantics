require "core.k"
require "primitive-types.k"

module LITERALS
    imports CORE
    imports PRIMITIVE-TYPES

//@ \section{Auxiliary constructs}

syntax K ::= "charAt" "(" String "," Int ")" [function]
rule charAt(Str:String, Pos:Int) => substrString(Str, Pos, 1)

syntax K ::= "lastChar" "(" String ")" [function]
rule lastChar(Str:String) => charAt(Str, lengthString(Str) -Int 1)

syntax K ::= "stringRemoveLast" "(" String ")" [function]
rule stringRemoveLast(Str:String) => substrString(Str, 0, lengthString(Str) -Int 1)

syntax K ::= "substrFrom" "(" String "," Int ")" [function]
rule substrFrom(Str:String, I:Int) => substrString(Str, I, lengthString(Str) -Int I)

syntax K ::= "hexToInt" "(" String ")" [function]
rule hexToInt(Str:String) => hexToInt(0, Str)

syntax K ::= "hexToInt" "(" Int "," String ")" [function]

rule hexToInt(I:Int, Str:String) => hexToInt( I, charAt(Str,0),
    substrString(Str, 1, lengthString(Str) -Int 1) )
when
    Str =/=String ""

rule hexToInt(I:Int, "") => I

/*
  first argument - upper digits already converted
  second argument - one char - current digit
  third argument - next digits
*/
syntax K ::= "hexToInt" "(" Int "," String "," String ")" [function]
rule hexToInt(I:Int, Digit:String, Str:String)
     => hexToInt( (I *Int 16) +Int hexDigitToInt(Digit), Str )

syntax K ::= "hexDigitToInt" "(" String ")" [function]

rule hexDigitToInt(Digit:String) => asciiString(Digit) -Int asciiString("0")
when        (asciiString(Digit) >=Int asciiString("0"))
    andBool (asciiString(Digit) <=Int asciiString("9"))

rule hexDigitToInt(Digit:String) => asciiString(Digit) -Int asciiString("A") +Int 10
when        (asciiString(Digit) >=Int asciiString("A"))
    andBool (asciiString(Digit) <=Int asciiString("F"))

rule hexDigitToInt(Digit:String) => asciiString(Digit) -Int asciiString("a") +Int 10
when        (asciiString(Digit) >=Int asciiString("a"))
    andBool (asciiString(Digit) <=Int asciiString("f"))

syntax K ::= "octaToInt" "(" String ")" [function]
rule octaToInt(Str:String) => octaToInt(0, Str)

syntax K ::= "octaToInt" "(" Int "," String ")" [function]

rule octaToInt(I:Int, Str:String) => octaToInt( I, charAt(Str,0),
    substrString(Str, 1, lengthString(Str) -Int 1) )
when
    Str =/=String ""

rule octaToInt(I:Int, "") => I

/*
  first argument - upper digits already converted
  second argument - one char - current digit
  third argument - next digits
*/
syntax K ::= "octaToInt" "(" Int "," String "," String ")" [function]
rule octaToInt(I:Int, Digit:String, Str:String) =>
    octaToInt( (I *Int 8) +Int octaDigitToInt(Digit), Str )

syntax K ::= "octaDigitToInt" "(" String ")" [function]

rule octaDigitToInt(Digit:String) => hexDigitToInt(Digit)

syntax K ::= "octaAsciiToInt" "(" Int ")" [function]
rule octaAsciiToInt(I:Int) => octaDigitToInt(charString(I))

syntax K ::= "hexAsciiToInt" "(" Int ")" [function]
rule hexAsciiToInt(I:Int) => hexDigitToInt(charString(I))

//@ \section{Integer literals}

rule [LitDeci]:
    'Lit('Deci(Str:String))
    =>  #if (lastChar(Str) ==String "l") orBool (lastChar(Str) ==String "L")
          #then String2Int(stringRemoveLast(Str)) :: long
          #else String2Int(Str                  ) :: int
        #fi

rule [LitHexa]:
    'Lit('Hexa(Str:String))
    =>  #if (lastChar(Str) ==String "l") orBool (lastChar(Str) ==String "L")
          #then normalize(hexToInt(substrFrom(stringRemoveLast(Str), 2)) :: long)
          #else normalize(hexToInt(substrFrom(Str,                   2)) :: int )
        #fi

rule [LitOcta]:
    'Lit('Octa(Str:String))
    =>  #if (lastChar(Str) ==String "l") orBool (lastChar(Str) ==String "L")
          #then normalize(octaToInt(substrFrom(stringRemoveLast(Str), 1)) :: long)
          #else normalize(octaToInt(substrFrom(Str,                   1)) :: int )
        #fi

//@ \section{bool literals}
rule 'Lit('Bool('True(.KList))) => true

rule 'Lit('Bool('False(.KList))) => false

//@ \section{char literals}
//@ Chars are represented as int values, as described in java specification.

rule 'Lit('Char('Single( I:Int ))) => I :: char

//todo the three escape characters below are not parsed by K3 in their nice form
rule 'Lit('Char('NamedEscape(  98 ))) =>                 8 :: char  // \b
rule 'Lit('Char('NamedEscape( 102 ))) =>                12 :: char  // \f
rule 'Lit('Char('NamedEscape(  39 ))) =>                39 :: char  // \'

rule 'Lit('Char('NamedEscape( 116 ))) => asciiString("\t") :: char
rule 'Lit('Char('NamedEscape( 110 ))) => asciiString("\n") :: char
rule 'Lit('Char('NamedEscape( 114 ))) => asciiString("\r") :: char

rule 'Lit('Char('NamedEscape( 34 ))) => asciiString("\"") :: char  //"
rule 'Lit('Char('NamedEscape( 92 ))) => asciiString("\\") :: char  //"

rule 'Lit('Char('OctaEscape1( I:Int ))) => octaAsciiToInt(I) :: char

rule 'Lit('Char('OctaEscape2( I1:Int,, I2:Int )))
    =>    octaAsciiToInt(I1) *Int 8
    +Int  octaAsciiToInt(I2)        :: char

rule 'Lit('Char('OctaEscape3( I1:Int,, I2:Int,, I3:Int )))
    =>    octaAsciiToInt(I1) *Int 64
     +Int octaAsciiToInt(I2) *Int  8
     +Int octaAsciiToInt(I3)          :: char

rule 'Lit('Char('UnicodeEscape(_:K,, I1:Int,, I2:Int,, I3:Int,, I4:Int)))
    =>    hexAsciiToInt(I1) *Int 4096
     +Int hexAsciiToInt(I2) *Int  256
     +Int hexAsciiToInt(I3) *Int   16
     +Int hexAsciiToInt(I4)           :: char

//@ \section{String literals}

rule  'Lit('String('ListWrap(K1:K,, K2:K,, Ks:KList)))
      => 'Plus('Lit('String('ListWrap(K1))),,
               'Lit('String('ListWrap(K2,, Ks)))
          )

rule 'Lit('String('ListWrap('Chars(Str:String)))) => Str

rule 'Lit('String('ListWrap(K:K))) => toString('Lit('Char(K)))
when getKLabel(K) =/=KLabel 'Chars

rule 'Lit('String('ListWrap(.KList))) => ""

//@ \section{Null literal}

rule 'Lit('Null(.KList)) => null

endmodule
