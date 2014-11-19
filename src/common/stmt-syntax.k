require "core-sorts.k"
require "core-classes.k"

module STMT-SYNTAX
    imports CORE-SORTS
    imports CORE-CLASSES

syntax Stmt ::= StmtWithoutTrailing|LabeledStmt|IfThenElseStmt|IfThenStmt|WhileStmt|ForStmt
/*
todo:these are SDF syntax
syntax IfThenElseStmt ::= "if" "(" Exp ")" Stmt "else" Stmt [strict(1),klabel('If)]
syntax IfThenStmt ::= "if" "(" Exp ")" Stmt [strict(1),klabel('If)]
syntax WhileStmt ::= "while" "(" Exp ")" Stmt [strict(1),klabel('While)]
syntax DoStmt ::="do" Stmt "while" "(" Exp ")"";"[strict(2),klabel('DoWhile)]
syntax ForStmt ::= "for" "(" LocalVarDecStmt Exp ";" Exps ")" Stmt [klabel('For)]
syntax ForStmt ::= "for" "(" Exps ";" Exp ";" Exps ")" Stmt [klabel('For)]
syntax LabeledStmt ::= Id ":" Stmt [klabel('Labeled)]
*/
syntax LabeledStmt ::= Id ":" K [klabel('Labeled)]
syntax IfThenElseStmt ::= "if" "(" Exp ")" K "else" K [strict(1),klabel('If)]
syntax IfThenStmt ::= "if" "(" Exp ")" K [strict(1),klabel('If)]
syntax WhileStmt ::= "while" "(" K ")" K [strict(1),klabel('While)]
syntax DoStmt ::="do" K "while" "(" K ")"";"[strict(2),klabel('DoWhile)]
syntax ForStmt ::= "for" "(" K ";" K ";" K ")" "{" K "}" [klabel('For)]


syntax StmtWithoutTrailing ::= Block
|EmptyStmt
|ExprStmt
|AssertStmt
|SwitchStmt
|DoStmt
|TryStmt
|StackConsumerStmt
|SynchronizedStmt

syntax BlockStmt ::= Stmt|LocalVarDecStmt|ClassDec
syntax BlockStmts ::= BlockStmt|BlockStmt BlockStmts
syntax LocalVarDecStmt ::= Type Id ";" [klabel('LocalVarDec)]
syntax ClassBody ::= "{" KListWrap "}" [klabel('ClassBody)]
syntax ClassDecHead ::= KListWrap "class" Id K K K [klabel('ClassDecHead)]
syntax ClassDec ::= ClassDecHead ClassBody [klabel('ClassDec)]

//todo:maybe we can try Grigore's proposal with Block
syntax Block ::= "{" K "}" [klabel('Block)]
syntax EmptyStmt ::= ";" [klabel('Empty)]

syntax AssertStmt ::="assert" Exp ";" [strict, klabel('AssertStm)]
		            |"assert" Exp ":" Exp ";" [strict(1), klabel('AssertStm)]

syntax SwitchStmt ::= "switch" "(" Exp ")" SwitchBlock [strict(1),klabel('Switch)]
syntax SwitchBlock::= "{" SwitchGroups SwitchLabels "}" [klabel('SwitchBlock)]
syntax SwitchGroup ::= SwitchLabels BlockStmts [klabel('SwitchGroup)]
syntax SwitchGroups ::= List{SwitchGroup, ""}
syntax SwitchLabel ::= "case" Exp ":" [strict, klabel('Case)]
		               |"default"":" [klabel('Default)]
syntax SwitchLabels ::= List{SwitchLabel, ""}
syntax SwitchGroup ::= KListWrap KListWrap [klabel('SwitchGroup)]
syntax SwitchBlock::= "{" KListWrap KListWrap "}" [klabel('SwitchBlock)]

syntax TryStmt ::= "try" Block CatchClauses "finally" Block [klabel('Try)]
		           |"try" Block CatchClauses [klabel('Try)]
syntax Param ::= Type Id       [klabel('ParamImpl)]
syntax CatchClause ::="catch" "(" Param ")" Block [klabel('Catch)]
syntax CatchClauses ::= List{CatchClause,""} [strict]

syntax StackConsumerStmt ::= "dummyStackConsumerStmt"|ThrowStmt|ContinueStmt|BreakStmt|ReturnStmt

/* SDF syntax
syntax ThrowStmt ::= "throw" Exp ";" [strict, klabel('Throw)]
syntax ContinueStmt ::= "continue" Exp ";" [klabel('Continue)]
syntax BreakStmt ::= "break" Exp ";" [klabel('Break)]
syntax ReturnStmt ::= "return" Exp ";" [klabel('Return)]
*/
syntax BreakStmt ::= "break" K ";" [klabel('Break)]
syntax ContinueStmt ::= "continue" K ";" [klabel('Continue)]
syntax ReturnStmt ::= "return" K ";" [klabel('Return)]
syntax ThrowStmt ::= "throw" K ";" [strict, klabel('Throw)]

syntax SynchronizedStmt ::= "synchronized" "(" Exp ")" Block [strict(1),klabel('Synchronized)]
//todo: replace Exp with StmtExp when all StmtExp are defined
syntax ExprStmt ::= Exp ";"  [strict, klabel('ExprStm)]

endmodule
