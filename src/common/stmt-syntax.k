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

		| "{" K "}" [klabel('Block)]
		| Exp ";"  [strict, klabel('ExprStm)]


syntax Stmt ::= StackConsumerStmt
syntax StackConsumerStmt ::= "dummyStackConsumerStmt"
        |"throw" Exp ";" [strict, klabel('Throw)]
        |"continue" Exp ";" [klabel('Continue)]
		|"break" Exp ";" [klabel('Break)]
		|"return" Exp ";" [klabel('Return)]

endmodule
