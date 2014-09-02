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
//todo:
//		|"{" K "}" [klabel('Block)]
		|Exp ";"  [strict, klabel('ExprStm)]
		|"assert" Exp ";" [strict, klabel('AssertStm)]
		|"assert" Exp ":" Exp ";" [strict(1), klabel('AssertStm)]
		|"switch" "(" K ")" SwitchBlock [strict(1),klabel('Switch)]
		|KListWrap ":" KListWrap [klabel('SwitchGroup)]
		|"case" Exp [strict, klabel('Case)]
		|"default" [klabel('Default)]

syntax SwitchBlock::= "{" KListWrap K "}" [klabel('SwitchBlock)]

syntax Stmt ::= StackConsumerStmt
syntax StackConsumerStmt ::= "dummyStackConsumerStmt"
        |"throw" K ";" [strict, klabel('Throw)]
        |"continue" K ";" [klabel('Continue)]
		|"break" K ";" [klabel('Break)]
		|"return" K ";" [klabel('Return)]

endmodule
