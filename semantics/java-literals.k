module JAVA-LITERALS
    imports JAVA-CORE

//@ \section{Auxiliary constructs}

declare charAt : String Int -> String
define charAt(Str:String, Pos:Int) => substrString(Str, Pos, 1)

declare lastChar : String -> String
define lastChar(Str) => charAt(Str, lengthString(Str) -Int 1)

declare stringRemoveLast : String -> String
define stringRemoveLast(Str) => substrString(Str, 0, lengthString(Str) -Int 1)

declare substrFrom : String Int -> String
define substrFrom(Str, I) => substrString(Str, I, lengthString(Str) -Int I)

declare hexToInt : String -> Int
define hexToInt(Str) => hexToInt(0, Str)

declare hexToInt : Int String -> Int

define hexToInt(I:Int, Str:String) => hexToInt( I, charAt(Str,0),
    substrString(Str, 1, lengthString(Str) -Int 1) )
when
    Str =/=String ""

define hexToInt(I:Int, "") => I

/*
  first argument - upper digits already converted
  second argument - one char - current digit
  third argument - next digits
*/
declare hexToInt : Int String String -> Int
define hexToInt(I, Digit:String, Str:String) =>
    hexToInt( (I *Int 16) +Int hexDigitToInt(Digit), Str )

declare hexDigitToInt : String -> Int

define hexDigitToInt(Digit) => asciiString(Digit) -Int asciiString("0")
    when    asciiString(Digit) >=Int asciiString("0")
    andBool asciiString(Digit) <=Int asciiString("9")

define hexDigitToInt(Digit) => asciiString(Digit) -Int asciiString("A") +Int 10
    when    asciiString(Digit) >=Int asciiString("A")
    andBool asciiString(Digit) <=Int asciiString("F")

define hexDigitToInt(Digit) => asciiString(Digit) -Int asciiString("a") +Int 10
    when    asciiString(Digit) >=Int asciiString("a")
    andBool asciiString(Digit) <=Int asciiString("f")

declare octaToInt : String -> Int
define octaToInt(Str) => octaToInt(0, Str)

declare octaToInt : Int String -> Int

define octaToInt(I:Int, Str:String) => octaToInt( I, charAt(Str,0),
    substrString(Str, 1, lengthString(Str) -Int 1) )
when
    Str =/=String ""

define octaToInt(I:Int, "") => I

/*
  first argument - upper digits already converted
  second argument - one char - current digit
  third argument - next digits
*/
declare octaToInt : Int String String -> Int
define octaToInt(I, Digit:String, Str:String) =>
    octaToInt( (I *Int 8) +Int octaDigitToInt(Digit), Str )

declare octaDigitToInt : String -> Int

define octaDigitToInt(Digit) => hexDigitToInt(Digit)

declare octaAsciiToInt : Int -> Int
define octaAsciiToInt(I) => octaDigitToInt(charString(I))

declare hexAsciiToInt : Int -> Int
define hexAsciiToInt(I) => hexDigitToInt(charString(I))

//@ \section{Integer literals}

rule [LitDeci]:
    'Lit('Deci(Str))
    =>  #if lastChar(Str) ==String "l" orBool lastChar(Str) ==String "L"
          #then String2Int(stringRemoveLast(Str)) :: long
          #else String2Int(Str                  ) :: int
        #fi
        [anywhere]

rule [LitHexa]:
    'Lit('Hexa(Str))
    =>  #if lastChar(Str) ==String "l" orBool lastChar(Str) ==String "L"
          #then normalize(hexToInt(substrFrom(stringRemoveLast(Str), 2)) :: long)
          #else normalize(hexToInt(substrFrom(Str,                   2)) :: int )
        #fi
        [anywhere]

rule [LitOcta]:
    'Lit('Octa(Str))
    =>  #if lastChar(Str) ==String "l" orBool lastChar(Str) ==String "L"
          #then normalize(octaToInt(substrFrom(stringRemoveLast(Str), 1)) :: long)
          #else normalize(octaToInt(substrFrom(Str,                   1)) :: int )
        #fi
        [anywhere]

//@ \section{bool literals}
rule 'Lit('Bool('True(.List{K}))) => true::bool
    [anywhere]

rule 'Lit('Bool('False(.List{K}))) => false::bool
    [anywhere]

//@ \section{char literals}

rule 'Lit('Char('Single( I ))) => charString( I ) :: char

rule 'Lit('Char('NamedEscape(  98 ))) => "\b" :: char
rule 'Lit('Char('NamedEscape( 116 ))) => "\t" :: char
rule 'Lit('Char('NamedEscape( 110 ))) => "\n" :: char
rule 'Lit('Char('NamedEscape( 102 ))) => "\f" :: char
rule 'Lit('Char('NamedEscape( 114 ))) => "\r" :: char

rule 'Lit('Char('NamedEscape( 34 ))) => "\"" :: char
rule 'Lit('Char('NamedEscape( 39 ))) => "\'" :: char
rule 'Lit('Char('NamedEscape( 92 ))) => "\\" :: char

rule 'Lit('Char('OctaEscape1( I )))
    => charString( octaAsciiToInt(I) ) :: char

rule 'Lit('Char('OctaEscape2( I1:Int,, I2:Int )))
    => charString( octaAsciiToInt(I1) *Int 8
              +Int octaAsciiToInt(I2) ) :: char

rule 'Lit('Char('OctaEscape3( I1,, I2,, I3:Int )))
    => charString( octaAsciiToInt(I1) *Int 64
              +Int octaAsciiToInt(I2) *Int 8
              +Int octaAsciiToInt(I3) ) :: char

rule 'Lit('Char('UnicodeEscape(_:K,, I1,, I2,, I3,, I4:Int)))
    => charString( hexAsciiToInt(I1) *Int 4096
              +Int hexAsciiToInt(I2) *Int 256
              +Int hexAsciiToInt(I3) *Int 16
              +Int hexAsciiToInt(I4) ) :: char

//@ \section{String literals}

rule  'Lit('String('ListWrap(K1:K,, K2:K,, Ks:List{K})))
      => 'Plus('Lit('String('ListWrap(K1))),,
               'Lit('String('ListWrap(K2,, Ks)))
          )
        [anywhere]

rule 'Lit('String('ListWrap('Chars(Str:String)))) => Str::rtString  [anywhere]

rule 'Lit('String('ListWrap(K:K))) => toString('Lit('Char(K)))
when getKLabel(K) =/=KLabel 'Chars
        [anywhere]

rule 'Lit('String('ListWrap(.List{K}))) => ""::rtString             [anywhere]

//@ \section{Null literal}

rule 'Lit('Null(.List{K})) => null::nullType  [anywhere]

end module
