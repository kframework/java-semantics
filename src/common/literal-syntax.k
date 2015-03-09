module LITERAL-SYNTAX
    imports LEXICAL-SYNTAX
    imports LIST-SYNTAX

//@ \paragraph{BooleanLiterals}
syntax BoolLiteral ::= Boolean                          [klabel('Bool)]
syntax Boolean ::= "true"                               [onlyLabel, klabel('True)]
syntax Boolean ::= "false"                              [onlyLabel, klabel('False)]


//@ \paragraph{CharacterLiterals}

syntax CharContent ::= SingleChar                       [klabel('Single)]
                     | UnicodeEscape
                     | EscapeSeq

syntax SingleChar
syntax CharLiteral //::= "'" CharContent "'"  [klabel('Char)]

//@ \paragraph{EscapeSequences}
syntax EscapeSeq ::= OctaEscape | NamedEscape

syntax NamedEscape ::= Token{"\\" [btnfr\"\'\\]}         [onlyLabel, klabel('NamedEscape)]
syntax OctaEscape ::= Token{"\\" [0-7]}                  [onlyLabel, klabel('OctaEscape1)]
                    | Token{"\\" [0-3][0-7]}             [onlyLabel, klabel('OctaEscape2)]
                    | Token{"\\" [4-7][0-7]}             [onlyLabel, klabel('OctaEscape2)]
                    | Token{"\\" [0-3][0-7][0-7]}        [onlyLabel, klabel('OctaEscape3)]


//@ \paragraph{FloatingPointLiterals}
syntax FloatLiteral ::= Float                            [klabel('Float)]


//@ \paragraph{IntegerLiterals}
syntax DeciLiteral ::= Token{[1-9][0-9]* [lL]?}         [onlyLabel]
syntax HexaLiteral ::= Token{[0][xX][0-9a-fA-F]+ [lL]?} [onlyLabel]
syntax OctaLiteral ::= Token{[0][0-7]+ [lL]?}           [onlyLabel]

syntax IntLiteral ::= DeciLiteral [klabel('Deci)]
                    | HexaLiteral [klabel('Hexa)]
                    | OctaLiteral [klabel('Octa)]


//@ \paragraph{NullLiteral}
syntax NullLiteral ::= "null"     [klabel('Null)]


//@ \paragraph{StringLiterals}
syntax StringLiteral ::= "\"" StringPartList "\""       [klabel('String)]

syntax StringPart ::= StringChars                       [klabel('Chars)]
                    | UnicodeEscape
                    | EscapeSeq

syntax StringChars //::= Token {~[\"\\\n\13]}


//@ \subsection{UnicodeEscape.sdf}
syntax UnicodeEscape ::= Token {[\\][u]+ [0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]}
                                                    [onlyLabel, klabel('UnicodeEscape)]

endmodule
