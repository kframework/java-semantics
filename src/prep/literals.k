module LITERALS
    imports CORE-SORTS
    imports AUX-STRINGS
    imports PRIMITIVE-TYPES

//@ \subsection{Auxiliary constructs}

syntax KItem ::= hexToInt ( String )                                  [function]
rule hexToInt(Str:String) => hexToInt(0, Str)

syntax KItem ::= hexToInt ( Int, String )                             [function]

rule hexToInt(I:Int, Str:String) => hexToInt( I, retainHead(Str, 1), trimHead(Str, 1) )
when
    Str =/=String ""

rule hexToInt(I:Int, "") => I

syntax KItem ::=  hexToInt (
                Int,    //upper digits already converted
                String, //one char - current digit
                String  //next digits
              )
              [function]

rule hexToInt(I:Int, Digit:String, Str:String)
     => hexToInt( (I *Int 16) +Int hexDigitToInt(Digit), Str )

syntax KItem ::= hexDigitToInt ( String )                             [function]

rule hexDigitToInt(Digit:String) => ordChar(Digit) -Int ordChar("0")
when        (ordChar(Digit) >=Int ordChar("0"))
    andBool (ordChar(Digit) <=Int ordChar("9"))

rule hexDigitToInt(Digit:String) => ordChar(Digit) -Int ordChar("A") +Int 10
when        (ordChar(Digit) >=Int ordChar("A"))
    andBool (ordChar(Digit) <=Int ordChar("F"))

rule hexDigitToInt(Digit:String) => ordChar(Digit) -Int ordChar("a") +Int 10
when        (ordChar(Digit) >=Int ordChar("a"))
    andBool (ordChar(Digit) <=Int ordChar("f"))

syntax KItem ::= octaToInt ( String )                                 [function]
rule octaToInt(Str:String) => octaToInt(0, Str)

syntax KItem ::= octaToInt ( Int, String )                         [function]

rule octaToInt(I:Int, Str:String) => octaToInt( I, retainHead(Str, 1), trimHead(Str, 1) )
when
    Str =/=String ""

rule octaToInt(I:Int, "") => I

syntax KItem ::=  octaToInt (
                Int,    //upper digits already converted
                String, //one char - current digit
                String  //next digits
              )
              [function]

rule octaToInt(I:Int, Digit:String, Str:String) =>
    octaToInt( (I *Int 8) +Int octaDigitToInt(Digit), Str )

syntax KItem ::= octaDigitToInt ( String )                            [function]

rule octaDigitToInt(Digit:String) => hexDigitToInt(Digit)

syntax KItem ::= octaAsciiToInt ( Int )                               [function]
rule octaAsciiToInt(I:Int) => octaDigitToInt(chrChar(I))

syntax KItem ::= hexAsciiToInt ( Int )                                [function]
rule hexAsciiToInt(I:Int) => hexDigitToInt(chrChar(I))

//@ \subsection{Integer literals}

rule [Lit-Deci]:
    'Lit('Deci(Str:String))
    =>  #if (lastChar(Str) ==String "l") orBool (lastChar(Str) ==String "L")
          #then String2Int(trimTail(Str, 1)) :: long
          #else String2Int(Str             ) :: int
        #fi

rule [Lit-Hexa]:
    'Lit('Hexa(Str:String))
    =>  #if (lastChar(Str) ==String "l") orBool (lastChar(Str) ==String "L")
          #then normalize(hexToInt(trimHead(trimTail(Str, 1), 2)) :: long)
          #else normalize(hexToInt(trimHead(Str,              2)) :: int )
        #fi

rule [Lit-Octa]:
    'Lit('Octa(Str:String))
    =>  #if (lastChar(Str) ==String "l") orBool (lastChar(Str) ==String "L")
          #then normalize(octaToInt(trimHead(trimTail(Str, 1), 1)) :: long)
          #else normalize(octaToInt(trimHead(Str,              1)) :: int )
        #fi

//@ \subsection{float literals}

rule [Lit-FFloat]:
    'Lit('Float(Str:String))
    =>  #if (lastChar(Str) ==String "f") orBool (lastChar(Str) ==String "F")
          #then String2Float(trimTail(Str, 1)) :: float
          #else #if (lastChar(Str) ==String "d") orBool (lastChar(Str) ==String "D")
                  #then String2Float(trimTail(Str, 1)) :: double
                  #else String2Float(Str             ) :: double
                #fi
        #fi

//@ \subsection{bool literals}

/*  'Lit('Bool('True(.KList)))
    'Lit('Bool('False(.KList)))
*/

rule 'Lit('Bool('True(.KList))) => true

rule 'Lit('Bool('False(.KList))) => false

//@ \subsection{char literals}
//@ Chars are represented as int values, as described in java specification.

//   'Lit('Char('Single( I:Int )))
rule 'Lit('Char('Single( I:Int ))) => I :: char

// 'Lit('Char('NamedEscape( Int ))

//K bug the three escape characters below are not parsed by K3 in their nice form. Confirmed on 04/03/2014.
rule 'Lit('Char('NamedEscape(  98 ))) =>                 8 :: char  // \b
rule 'Lit('Char('NamedEscape( 102 ))) =>                12 :: char  // \f
rule 'Lit('Char('NamedEscape(  39 ))) =>                39 :: char  // \'

rule 'Lit('Char('NamedEscape( 116 ))) => ordChar("\t") :: char
rule 'Lit('Char('NamedEscape( 110 ))) => ordChar("\n") :: char
rule 'Lit('Char('NamedEscape( 114 ))) => ordChar("\r") :: char

rule 'Lit('Char('NamedEscape(  34 ))) => ordChar("\"") :: char  //"
rule 'Lit('Char('NamedEscape(  92 ))) => ordChar("\\") :: char  //"

/*  'Lit('Char('OctaEscape1( I:Int )))
    'Lit('Char('OctaEscape2( I1:Int,, I2:Int )))
    'Lit('Char('OctaEscape3( I1:Int,, I2:Int,, I3:Int )))
*/

rule 'Lit('Char('OctaEscape1( I:Int ))) => octaAsciiToInt(I) :: char

rule 'Lit('Char('OctaEscape2( I1:Int,, I2:Int )))
    =>    octaAsciiToInt(I1) *Int 8
    +Int  octaAsciiToInt(I2)        :: char

rule 'Lit('Char('OctaEscape3( I1:Int,, I2:Int,, I3:Int )))
    =>    octaAsciiToInt(I1) *Int 64
     +Int octaAsciiToInt(I2) *Int  8
     +Int octaAsciiToInt(I3)          :: char

//   'Lit('Char('UnicodeEscape(_:K,, I1:Int,, I2:Int,, I3:Int,, I4:Int)))

rule 'Lit('Char('UnicodeEscape(_,, I1:Int,, I2:Int,, I3:Int,, I4:Int)))
    =>    hexAsciiToInt(I1) *Int 4096
     +Int hexAsciiToInt(I2) *Int  256
     +Int hexAsciiToInt(I3) *Int   16
     +Int hexAsciiToInt(I4)           :: char

//@ \subsection{String literals}

rule  'Lit('String('StringPartList(K1:K,, 'StringPartList(K2:K,, Ks:K))))
      => plusAux( 'Lit('String('StringPartList(K1,, .StringPartList))),
                  'Lit('String('StringPartList(K2,, Ks)))
         )

rule 'Lit('String('StringPartList('Chars(Str:String),, .StringPartList))) => Str

rule 'Lit('String('StringPartList(K:K,, .StringPartList))) => charToString('Lit('Char(K)))
when getKLabel(K) =/=KLabel 'Chars

rule 'Lit('String(.StringPartList)) => ""

syntax KItem ::= charToString ( K ) [strict]
rule charToString(I:Int :: char) => chrChar(I)

//@ \subsection{Null literal}

//   'Lit('Null(.KList))
rule 'Lit('Null(.KList)) => null

endmodule
