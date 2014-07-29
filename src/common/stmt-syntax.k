require "core-sorts.k"
require "core-classes.k"

module STMT-SYNTAX
    imports CORE-SORTS
    imports CORE-CLASSES

syntax Stmt ::= "if" "(" K ")" "{" K "}" "else" "{" K "}" [strict(1),klabel('If)]
		| "if" "(" K ")" "{" K "}" [strict(1),klabel('If)]
endmodule
