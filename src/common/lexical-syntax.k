module LEXICAL-SYNTAX

//@ \paragraph{Identifiers}
syntax Id ::= ID [klabel('Id)]
syntax ID ::= Token{[A-Za-z\_\$][A-Za-z0-9\_\$]*}   [onlyLabel]

//@ \paragraph{LineTerminators}

syntax CarriageReturn ::= Token{[\r]}               [onlyLabel]
syntax LineTerminator ::= EndOfFile
                        | CarriageReturn
                        | Token{[\n]}               [onlyLabel]
                        | Token{[\r][\n]}           [onlyLabel]

//@ \paragraph{Modifiers}
syntax Public ::= "public"                          [klabel('Public)]
syntax Private ::= "private"                        [klabel('Private)]
syntax Protected ::= "protected"                    [klabel('Protected)]
syntax Abstract ::= "abstract"                      [klabel('Abstract)]
syntax Final ::= "final"                            [klabel('Final)]
syntax Static ::= "static"                          [klabel('Static)]
syntax Native ::= "native"                          [klabel('Native)]
syntax Transient ::= "transient"                    [klabel('Transient)]
syntax Volatile ::= "volatile"                      [klabel('Volatile)]
syntax StrictFP ::= "strictfp"                      [klabel('StrictFP)]
syntax Synchronized ::= "synchronized"              [klabel('Synchronized)]

endmodule
