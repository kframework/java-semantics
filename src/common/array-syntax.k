require "class-syntax.k"
module ARRAY-SYNTAX
imports CLASS-SYNTAX

//@ \subsection{ArrayInitializers.sdf}
syntax ArrayInit ::= "{" VarInits "}" [klabel('ArrayInit)]
syntax ArrayInit ::= "{" VarInits "," "}" [klabel('ArrayInit)]
syntax VarInits ::= List{VarInit, ","} //  [klabel('VarInitList)]

endmodule