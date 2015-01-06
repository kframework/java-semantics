require "lexical-syntax.k"
require "list-syntax.k"
module LITERAL-SYNTAX
imports LEXICAL-SYNTAX
imports LIST-SYNTAX
//@ \subsection{BooleanLiterals.sdf} todo
syntax BoolLiteral ::= Bool [klabel('Bool)]
//syntax Bool ::= true [klabel('True)] todo:"true"?

//@ \subsection{CharacterLiterals.sdf} todo
syntax SingleChar// ::= Token{[\r\n\'\\]}//don't unserstand ^?
syntax CharContent ::= SingleChar [klabel('Single)]
                     | UnicodeEscape
                     | EscapeSeq
//syntax CharLiteral ::= "'" CharContent "'"  [klabel('Char)]                   Multiple lookahead not fully supported

//@ \subsection{EscapeSequences.sdf}

syntax EscapeSeq ::= OctaEscape | NamedEscape
syntax NamedEscape ::= Token{"\\" [btnfr\"\'\\]}         [klabel('NamedEscape)]
syntax OctaEscape ::= Token{"\\" [0-7]}                  [klabel('OctaEscape1)]
                    | Token{"\\" [0-3][0-7]}             [klabel('OctaEscape2)]
                    | Token{"\\" [4-7][0-7]}             [klabel('OctaEscape2)]
                    | Token{"\\" [0-3][0-7][0-7]}        [klabel('OctaEscape3)]

//@ \subsection{FloatingPointLiterals.sdf} todo

//@ \subsection{IntegerLiterals.sdf}
//inline token declaration not allowed
//syntax Ll ::= Token{[lL]} cannot define "L"

//java heap space problem, same code on small language test works
//syntax DeciNumeral ::=  Token{[1-9][0-9]*} //| "0"
//syntax DeciLiteral ::= DeciNumeral
//
//syntax HexaNumeral ::= Token{[0][xX] [0-9a-fA-F]+}
//syntax HexaLiteral ::= HexaNumeral
//
//syntax OctaNumeral ::= Token{[0]     [0-7]+}
//syntax OctaLiteral ::= OctaNumeral
//
//syntax IntLiteral ::= DeciLiteral [klabel('Deci)]
//                    | HexaLiteral [klabel('Hexa)]
//                    | OctaLiteral [klabel('Octa)]


//@ \subsection{NullLiteral.sdf}
syntax NullLiteral ::= "null" [klabel('Null)]

//@ \subsection{StringLiterals.sdf} todo
syntax StringLiteral ::= "\"" StringPartList "\"" [klabel('String)]
syntax StringPart ::= StringChars [klabel('Chars)]
                    | UnicodeEscape
                    | EscapeSeq
syntax StringChars //::= Token {~[\"\\\n\13]}

endmodule