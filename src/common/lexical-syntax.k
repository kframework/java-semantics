module LEXICAL-SYNTAX
//@ \subsection{Modifiers.sdf}
syntax Public ::= "public"  [klabel('Public)]
syntax Private ::= "private"  [klabel('Private)]
syntax Protected ::= "protected" [klabel('Protected)]
syntax Abstract ::= "abstract"  [klabel('Abstract)]
syntax Final ::= "final" [klabel('Final)]
syntax Static ::= "static" [klabel('Static)]
syntax Native ::= "native" [klabel('Native)]
syntax Transient ::= "transient" [klabel('Transient)]
syntax Volatile ::= "volatile" [klabel('Volatile)]
syntax StrictFP ::= "strictfp" [klabel('StrictFP)]
syntax Modifier ::= Public
                  | Private
                  | Protected
                  | Abstract
                  | Final
                  | Static
                  | Native
                  | Transient
                  | Volatile
                  | Strictfp

endmodule