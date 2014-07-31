require "core-sorts.k"
require "core-classes.k"

module STMT-SYNTAX
    imports CORE-SORTS
    imports CORE-CLASSES

syntax Stmt ::= "if" "(" K ")" "{" K "}" "else" "{" K "}" [strict(1),klabel('If)]
		|"if" "(" K ")" "{" K "}" [strict(1),klabel('If)]
		|"while" "(" K ")" "{" K "}" [strict(1),klabel('While)]
		|"do" "{" K "}" "while" "(" K ")"[strict(2),klabel('DoWhile)]
		|"for" "(" K ";" K ";" K ")" "{" K "}" [klabel('For)]
		//|"break" [klabel('Break)]
		|"break" Exp [klabel('Break)]
endmodule
