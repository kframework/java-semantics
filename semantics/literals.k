require "core.k"
require "aux-strings.k"
require "primitive-types.k"

//@ \section{Module LITERALS}

module LITERALS
    imports CORE
    imports AUX-STRINGS
    imports PRIMITIVE-TYPES
    imports ELABORATE-BLOCKS //for elab(), should disappear after semantics separation

//@ \subsection{Auxiliary constructs}

syntax K ::= "hexToInt" "(" String ")"                                  [function]
rule hexToInt(Str:String) => hexToInt(0, Str)

syntax K ::= "hexToInt" "(" Int "," String ")"                          [function]

rule hexToInt(I:Int, Str:String) => hexToInt( I, retainHead(Str, 1), trimHead(Str, 1) )
when
    Str =/=String ""

rule hexToInt(I:Int, "") => I

/*
  first argument - upper digits already converted
  second argument - one char - current digit
  third argument - next digits
*/
syntax K ::= "hexToInt" "(" Int "," String "," String ")"               [function]
rule hexToInt(I:Int, Digit:String, Str:String)
     => hexToInt( (I *Int 16) +Int hexDigitToInt(Digit), Str )

syntax K ::= "hexDigitToInt" "(" String ")"                             [function]

rule hexDigitToInt(Digit:String) => ordChar(Digit) -Int ordChar("0")
when        (ordChar(Digit) >=Int ordChar("0"))
    andBool (ordChar(Digit) <=Int ordChar("9"))

rule hexDigitToInt(Digit:String) => ordChar(Digit) -Int ordChar("A") +Int 10
when        (ordChar(Digit) >=Int ordChar("A"))
    andBool (ordChar(Digit) <=Int ordChar("F"))

rule hexDigitToInt(Digit:String) => ordChar(Digit) -Int ordChar("a") +Int 10
when        (ordChar(Digit) >=Int ordChar("a"))
    andBool (ordChar(Digit) <=Int ordChar("f"))

syntax K ::= "octaToInt" "(" String ")"                                 [function]
rule octaToInt(Str:String) => octaToInt(0, Str)

syntax K ::= "octaToInt" "(" Int "," String ")"                         [function]

rule octaToInt(I:Int, Str:String) => octaToInt( I, retainHead(Str, 1), trimHead(Str, 1) )
when
    Str =/=String ""

rule octaToInt(I:Int, "") => I

/*
  first argument - upper digits already converted
  second argument - one char - current digit
  third argument - next digits
*/
syntax K ::= "octaToInt" "(" Int "," String "," String ")"              [function]
rule octaToInt(I:Int, Digit:String, Str:String) =>
    octaToInt( (I *Int 8) +Int octaDigitToInt(Digit), Str )

syntax K ::= "octaDigitToInt" "(" String ")"                            [function]

rule octaDigitToInt(Digit:String) => hexDigitToInt(Digit)

syntax K ::= "octaAsciiToInt" "(" Int ")"                               [function]
rule octaAsciiToInt(I:Int) => octaDigitToInt(chrChar(I))

syntax K ::= "hexAsciiToInt" "(" Int ")"                                [function]
rule hexAsciiToInt(I:Int) => hexDigitToInt(chrChar(I))

//@ \subsection{Integer literals}

rule [LitDeci]:
    'Lit('Deci(Str:String))
    =>  #if (lastChar(Str) ==String "l") orBool (lastChar(Str) ==String "L")
          #then String2Int(trimTail(Str, 1)) :: long
          #else String2Int(Str             ) :: int
        #fi

rule [LitHexa]:
    'Lit('Hexa(Str:String))
    =>  #if (lastChar(Str) ==String "l") orBool (lastChar(Str) ==String "L")
          #then normalize(hexToInt(trimHead(trimTail(Str, 1), 2)) :: long)
          #else normalize(hexToInt(trimHead(Str,              2)) :: int )
        #fi

rule [LitOcta]:
    'Lit('Octa(Str:String))
    =>  #if (lastChar(Str) ==String "l") orBool (lastChar(Str) ==String "L")
          #then normalize(octaToInt(trimHead(trimTail(Str, 1), 1)) :: long)
          #else normalize(octaToInt(trimHead(Str,              1)) :: int )
        #fi

//@ \subsection{float literals}

rule [LitFloat]:
    'Lit('Float(Str:String))
    =>  #if (lastChar(Str) ==String "f") orBool (lastChar(Str) ==String "F")
          #then String2Float(trimTail(Str, 1)) :: float
          #else #if (lastChar(Str) ==String "d") orBool (lastChar(Str) ==String "D")
                  #then String2Float(trimTail(Str, 1)) :: double
                  #else String2Float(Str             ) :: double
                #fi
        #fi

//@ \subsection{bool literals}
rule 'Lit('Bool('True(.KList))) => true

rule 'Lit('Bool('False(.KList))) => false

//@ \subsection{char literals}
//@ Chars are represented as int values, as described in java specification.

rule 'Lit('Char('Single( I:Int ))) => I :: char

//todo the three escape characters below are not parsed by K3 in their nice form
rule 'Lit('Char('NamedEscape(  98 ))) =>                 8 :: char  // \b
rule 'Lit('Char('NamedEscape( 102 ))) =>                12 :: char  // \f
rule 'Lit('Char('NamedEscape(  39 ))) =>                39 :: char  // \'

rule 'Lit('Char('NamedEscape( 116 ))) => ordChar("\t") :: char
rule 'Lit('Char('NamedEscape( 110 ))) => ordChar("\n") :: char
rule 'Lit('Char('NamedEscape( 114 ))) => ordChar("\r") :: char

rule 'Lit('Char('NamedEscape(  34 ))) => ordChar("\"") :: char  //"
rule 'Lit('Char('NamedEscape(  92 ))) => ordChar("\\") :: char  //"

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

//@ \subsection{String literals}

rule  'Lit('String('ListWrap(K1:K,, K2:K,, Ks:KList)))
      => elab('Plus('Lit('String('ListWrap(K1))),,
               'Lit('String('ListWrap(K2,, Ks)))
          ))

rule 'Lit('String('ListWrap('Chars(Str:String)))) => Str

rule 'Lit('String('ListWrap(K:K))) => toString('Lit('Char(K)))
when getKLabel(K) =/=KLabel 'Chars

rule 'Lit('String('ListWrap(.KList))) => ""

//@ \subsection{Null literal}

rule 'Lit('Null(.KList)) => null

endmodule
