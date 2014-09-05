require "core-sorts.k"
require "core-classes.k"

module STMT-SYNTAX
    imports CORE-SORTS
    imports CORE-CLASSES
//todo:be specific
syntax Stmt ::= StmtWithoutTrailing|LabeledStmt|IfThenElseStmt|IfThenStmt|WhileStmt|ForStmt

syntax IfThenElseStmt ::= "if" "(" K ")" "{" K "}" "else" "{" K "}" [strict(1),klabel('If)]
syntax IfThenStmt ::= "if" "(" K ")" "{" K "}" [strict(1),klabel('If)]
syntax WhileStmt ::= "while" "(" K ")" "{" K "}" [strict(1),klabel('While)]
syntax ForStmt ::= "for" "(" K ";" K ";" K ")" "{" K "}" [klabel('For)]
syntax LabeledStmt ::= Id ":" K [klabel('Labeled)]


syntax StmtWithoutTrailing ::= Block
|EmptyStmt
|ExprStmt
|AssertStmt
|SwitchStmt
|DoStmt
|TryStmt
|StackConsumerStmt
|SynchronizedStmt

syntax Block ::= "{" K "}" [klabel('Block)]
syntax EmptyStmt ::= ";" [klabel('Empty)]
syntax ExprStmt ::= Exp ";"  [strict, klabel('ExprStm)]
syntax AssertStmt ::="assert" Exp ";" [strict, klabel('AssertStm)]
		            |"assert" Exp ":" Exp ";" [strict(1), klabel('AssertStm)]
syntax SwitchStmt ::= "switch" "(" Exp ")" SwitchBlock [strict(1),klabel('Switch)]
syntax SwitchGroup ::= KListWrap KListWrap [klabel('SwitchGroup)]
syntax SwitchLabel ::= "case" Exp ":" [strict, klabel('Case)]
		               |"default:" [klabel('Default)]
syntax SwitchBlock::= "{" KListWrap KListWrap "}" [klabel('SwitchBlock)]
syntax DoStmt ::="do" "{" K "}" "while" "(" K ")"[strict(2),klabel('DoWhile)]
syntax TryStmt ::= "try" K KListWrap "finally" Block [klabel('Try)]
		           |"try" K KListWrap [klabel('Try)]
		           |"catch" "(" K ")" Block [klabel('Catch)]
syntax StackConsumerStmt ::= "dummyStackConsumerStmt"|ThrowStmt|ContinueStmt|BreakStmt|ReturnStmt
syntax ThrowStmt ::= "throw" K ";" [strict, klabel('Throw)]
syntax ContinueStmt ::= "continue" K ";" [klabel('Continue)]
syntax BreakStmt ::= "break" K ";" [klabel('Break)]
syntax ReturnStmt ::= "return" K ";" [klabel('Return)]
//todo: add syntax
syntax SynchronizedStmt ::= "dummySynchronizedStmt"




endmodule

