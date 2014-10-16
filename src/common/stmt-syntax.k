require "core-sorts.k"
require "core-classes.k"

module STMT-SYNTAX
    imports CORE-SORTS
    imports CORE-CLASSES
//todo:be specific
syntax Stmt ::= "if" "(" K ")" "{" K "}" "else" "{" K "}" [strict(1),klabel('If)]
		|"if" "(" K ")" "{" K "}" [strict(1),klabel('If)]
		|"while" "(" K ")" "{" K "}" [strict(1),klabel('While)]
		|"do" "{" K "}" "while" "(" K ")"[strict(2),klabel('DoWhile)]
		|"for" "(" K ";" K ";" K ")" "{" K "}" [klabel('For)]


		|Exp ";"  [strict, klabel('ExprStm)]
		|"assert" Exp ";" [strict, klabel('AssertStm)]
		|"assert" Exp ":" Exp ";" [strict(1), klabel('AssertStm)]
		|Id ":" K [klabel('Labeled)]
		|"switch" "(" Exp ")" SwitchBlock [strict(1),klabel('Switch)]
		|"try" K KListWrap "finally" Block [klabel('Try)]
		|"try" K KListWrap [klabel('Try)]
		|"catch" "(" K ")" Block [klabel('Catch)]
//todo:change K above and below
syntax Block ::= "{" K "}" [klabel('Block)]

syntax SwitchGroup ::= KListWrap KListWrap [klabel('SwitchGroup)]
syntax SwitchLabel ::= "case" Exp ":" [strict, klabel('Case)]
		               |"default:" [klabel('Default)]
syntax SwitchBlock::= "{" KListWrap KListWrap "}" [klabel('SwitchBlock)]

syntax Stmt ::= StackConsumerStmt | EmptyStmt
syntax EmptyStmt ::= ";" [klabel('Empty)]
syntax StackConsumerStmt ::= "dummyStackConsumerStmt"
        |"throw" K ";" [strict, klabel('Throw)]
        |"continue" K ";" [klabel('Continue)]
		|"break" K ";" [klabel('Break)]
		|"return" K ";" [klabel('Return)]



endmodule

