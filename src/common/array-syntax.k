require "class-syntax.k"
require "list-syntax.k"
module ARRAY-SYNTAX
imports CLASS-SYNTAX
imports LIST-SYNTAX

//@ \subsection{ArrayInitializers.sdf}
syntax ArrayInit ::= "{" VarInits "}" [klabel('ArrayInit)]
syntax ArrayInit ::= "{" VarInits "," "}" [klabel('ArrayInit)]

endmodule