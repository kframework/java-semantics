module LITERAL-SYNTAX
    imports LEXICAL-SYNTAX
    imports LIST-SYNTAX

//@ \subsection{BooleanLiterals.sdf}
syntax BoolLiteral ::= Boolean                          [klabel('Bool)]
syntax Boolean ::= "true"                               [onlyLabel, klabel('True)]
syntax Boolean ::= "false"                              [onlyLabel, klabel('False)]


//@ \subsection{CharacterLiterals.sdf} todo
syntax SingleChar// ::= Token{[\r\n\'\\]}//don't understand ^?

syntax CharContent ::= SingleChar                       [klabel('Single)]
                     | UnicodeEscape
                     | EscapeSeq
//Problem: Multiple lookahead not fully supported (does not appear when tested in small language)
syntax CharLiteral //::= "'" CharContent "'"  [klabel('Char)]


//@ \subsection{EscapeSequences.sdf}
syntax EscapeSeq ::= OctaEscape | NamedEscape

syntax NamedEscape ::= Token{"\\" [btnfr\"\'\\]}         [onlyLabel, klabel('NamedEscape)]
syntax OctaEscape ::= Token{"\\" [0-7]}                  [onlyLabel, klabel('OctaEscape1)]
                    | Token{"\\" [0-3][0-7]}             [onlyLabel, klabel('OctaEscape2)]
                    | Token{"\\" [4-7][0-7]}             [onlyLabel, klabel('OctaEscape2)]
                    | Token{"\\" [0-3][0-7][0-7]}        [onlyLabel, klabel('OctaEscape3)]


//@ \subsection{FloatingPointLiterals.sdf} todo
syntax FloatLiteral ::= Float                            [klabel('Float)]


//@ \subsection{IntegerLiterals.sdf}
syntax DeciLiteral ::= Token{[1-9][0-9]* [lL]?}         [onlyLabel]
syntax HexaLiteral ::= Token{[0][xX][0-9a-fA-F]+ [lL]?} [onlyLabel]
syntax OctaLiteral ::= Token{[0][0-7]+ [lL]?}           [onlyLabel]

syntax IntLiteral ::= DeciLiteral [klabel('Deci)]
                    | HexaLiteral [klabel('Hexa)]
                    | OctaLiteral [klabel('Octa)]


//@ \subsection{NullLiteral.sdf}
syntax NullLiteral ::= "null"     [klabel('Null)]


//@ \subsection{StringLiterals.sdf} todo
syntax StringLiteral ::= "\"" StringPartList "\""       [klabel('String)]

syntax StringPart ::= StringChars                       [klabel('Chars)]
                    | UnicodeEscape
                    | EscapeSeq

syntax StringChars //::= Token {~[\"\\\n\13]}

endmodule