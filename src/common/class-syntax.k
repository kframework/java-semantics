require "array-syntax.k"
require "exp-syntax.k"
module CLASS-SYNTAX
imports ARRAY-SYNTAX
imports EXP-SYNTAX
//@ \subsection{FieldDeclarations.sdf}
syntax VarInit ::= Exp | ArrayInit
endmodule