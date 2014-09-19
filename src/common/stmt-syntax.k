require "core-sorts.k"
require "core-classes.k"

module STMT-SYNTAX
    imports CORE-SORTS
    imports CORE-CLASSES
//todo:be specific
syntax Stmt ::= StmtWithoutTrailing|LabeledStmt|IfThenElseStmt|IfThenStmt|WhileStmt|ForStmt

syntax IfThenElseStmt ::= "if" "(" Exp ")" "{" K "}" "else" "{" K "}" [strict(1),klabel('If)]
syntax IfThenStmt ::= "if" "(" Exp ")" "{" K "}" [strict(1),klabel('If)]
syntax WhileStmt ::= "while" "(" Exp ")" "{" K "}" [strict(1),klabel('While)]
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
//todo:ClassDecStm
syntax BlockStmt ::= Stmt|LocalVarDecStmt|ClassDecStmt
syntax LocalVarDecStmt ::= LocalVarDec ";" [klabel('LocalVarDecStm)]
syntax LocalVarDec ::= KListWrap Type Id [strict(2,3), klabel('LocalVarDec)]


syntax ClassDecStmt ::= "dummyclassdecstm"

syntax Block ::= "{" BlockStmt "}" [klabel('Block)]
syntax EmptyStmt ::= ";" [klabel('Empty)]

syntax AssertStmt ::="assert" Exp ";" [strict, klabel('AssertStm)]
		            |"assert" Exp ":" Exp ";" [strict(1), klabel('AssertStm)]
syntax SwitchStmt ::= "switch" "(" Exp ")" SwitchBlock [strict(1),klabel('Switch)]
syntax SwitchGroup ::= KListWrap KListWrap [klabel('SwitchGroup)]
syntax SwitchLabel ::= "case" Exp ":" [strict, klabel('Case)]
		               |"default:" [klabel('Default)]
syntax SwitchBlock::= "{" KListWrap KListWrap "}" [klabel('SwitchBlock)]
syntax DoStmt ::="do" "{" K "}" "while" "(" K ")"[strict(2),klabel('DoWhile)]
syntax TryStmt ::= "try" Block KListWrap "finally" Block [klabel('Try)]
		           |"try" Block KListWrap [klabel('Try)]
		           //todo:catches

syntax CatchClause ::= "catch" "(" K ")" Block [strict(1),klabel('Catch),result(ExtKResult)]

//syntax Catches ::= List{CatchClause,""}
//syntax KItem ::= toCatches( KListWrap )          [function]
//           | toCatches( KListWrap , Catches ) [function]
//rule [L:KList,,C:CatchClause] => toCatches([L,,C])
//rule toCatches([KLCatches:KList]) => toCatches([KLCatches],.Catches)
//rule toCatches([KLCatches:KList,, C:CatchClause], Catches:Catches) => toCatches([KLCatches], (C Catches))
//rule toCatches([.KList], Catches:Catches) => Catches

syntax StackConsumerStmt ::= "dummyStackConsumerStmt"|ThrowStmt|ContinueStmt|BreakStmt|ReturnStmt
syntax ThrowStmt ::= "throw" K ";" [strict, klabel('Throw)]
syntax ContinueStmt ::= "continue" K ";" [klabel('Continue)]
syntax BreakStmt ::= "break" K ";" [klabel('Break)]
syntax ReturnStmt ::= "return" K ";" [klabel('Return)]

syntax SynchronizedStmt ::= "dummySynchronizedStmt"
                            |"synchronized" "(" Exp ")" Block [strict(1),klabel('Synchronized)]
//todo
syntax ExprStmt ::= StmtExp ";"  [strict, klabel('ExprStm)]
syntax InternalUse ::= TypedVal ";"




endmodule

