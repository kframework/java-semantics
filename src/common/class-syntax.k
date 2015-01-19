require "array-syntax.k"
require "exp-syntax.k"
module CLASS-SYNTAX
imports ARRAY-SYNTAX
imports EXP-SYNTAX
//@ \subsection{ClassDeclarations.sdf}

//@ \subsection{ConstructorDeclarations.sdf}
//@ \subsection{EnumDeclarations.sdf}
//@ \subsection{FieldDeclarations.sdf}
syntax VarInit ::= Exp | ArrayInit
//@ \subsection{MethodDeclarations.sdf}
//@ \subsection{InstanceInitializers.sdf}
//@ \subsection{StaticInitializers.sdf}
endmodule