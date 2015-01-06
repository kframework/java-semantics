require "lexical-syntax.k"
module LITERAL-SYNTAX
imports LEXICAL-SYNTAX
//@ \subsection{BooleanLiterals.sdf} todo
syntax BoolLiteral ::= Bool [klabel('Bool)]
//syntax Bool ::= true [klabel('True)] todo:"true"?

//@ \subsection{CharacterLiterals.sdf} todo
syntax SingleChar //::= Token{~[\r\n\'\\]} token not ok
syntax CharContent ::= SingleChar [klabel('Single)]
                     | UnicodeEscape
                     | EscapeSeq
//syntax CharLiteral ::= "'" CharContent "'"  [klabel('Char)]                   Multiple lookahead not fully supported

//@ \subsection{EscapeSequences.sdf}

syntax EscapeSeq ::= OctaEscape | NamedEscape
syntax NamedEscape ::= Token{"\\" [btnfr\"\'\\]}         [klabel('NamedEscape)]
syntax OctaEscape ::= Token{"\\" LastOcta}               [klabel('OctaEscape1)]
                    | Token{"\\" [0-3][0-7]}             [klabel('OctaEscape2)]
                    | Token{"\\" [4-7][0-7]}             [klabel('OctaEscape2)]
                    | Token{"\\" [0-3][0-7][0-7]}        [klabel('OctaEscape3)]
syntax LastOcta ::= Token{[0-7]}
//how to write restrictions?

//@ \subsection{FloatingPointLiterals.sdf} todo
//@ \subsection{IntegerLiterals.sdf}
//inline token declaration not allowed
//syntax Ll ::= Token{[lL]?}
//
//syntax DeciNumeral ::=  Token{[1-9][0-9]*} //| "0"
//syntax DeciLiteral ::= DeciNumeral Ll
//
//syntax HexaNumeral ::= Token{[0][xX] [0-9a-fA-F]+}
//syntax HexaLiteral ::= HexaNumeral Ll
//syntax OctaNumeral ::= Token{[0]     [0-7]+}
//syntax OctaLiteral ::= OctaNumeral Ll
//
//syntax IntLiteral ::= DeciLiteral [klabel('Deci)]
//                    | HexaLiteral [klabel('Hexa)]
//                    | OctaLiteral [klabel('Octa)]

endmodule