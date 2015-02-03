module STMT-SYNTAX
    imports CLASS-SYNTAX

//@ \subsection{Blocks.sdf}
syntax BlockStmt ::= Stmt | LocalVarDecStmt | ClassDec  [klabel('ClassDecStm)]
syntax Block ::= "{" BlockStmList "}"                   [klabel('Block)]


//@ \subsection{LocalVariableDeclaraions.sdf}
syntax LocalVarDecStmt ::= LocalVarDec ";"              [prefer, klabel('LocalVarDecStm)]
syntax LocalVarDec ::= AnnoVarModList Type VarDecList   [prefer, klabel('LocalVarDec)]


//@ \subsection{Statements.sdf}
syntax Stmt ::= StmtWithoutTrailing
              | LabeledStmt
              | IfThenElseStmt
              | IfThenStmt
              | WhileStmt
              | ForStmt

syntax StmtWithoutTrailing ::= Block
                             | EmptyStmt
                             | ExprStmt
                             | AssertStmt
                             | SwitchStmt
                             | DoStmt
                             | TryStmt
                             | StackConsumerStmt
                             | SynchronizedStmt

syntax StackConsumerStmt ::= ThrowStmt | ContinueStmt | BreakStmt | ReturnStmt

syntax IfThenElseStmt ::= "if" "(" Exp ")" Stmt "else" Stmt        [strict(1), klabel('If)]
syntax IfThenStmt ::= "if" "(" Exp ")" Stmt                        [prefer, strict(1), klabel('If)]

syntax WhileStmt ::= "while" "(" Exp ")" Stmt                      [strict(1),klabel('While)]

syntax ForStmt ::= "for" "(" LocalVarDec ";" OptionalExp ";" Exps ")" Stmt      [klabel('For)]
syntax ForStmt ::= "for" "(" Exps ";" OptionalExp ";" Exps ")" Stmt             [klabel('For)]
syntax ForStmt ::= "for" "(" Param ":" Exp ")" Stmt                             [klabel('ForEach)]

syntax LabeledStmt ::= Id ":" Stmt                                              [klabel('Labeled)]

syntax EmptyStmt ::= ";"                                            [klabel('Empty)]

syntax ExprStmt ::= Exp ";"                                         [strict, klabel('ExprStm)]

syntax AssertStmt ::= "assert" Exp ";"                              [strict, klabel('AssertStm)]
		            | "assert" Exp ":" Exp ";"                      [strict(1), klabel('AssertStm)]

syntax SwitchStmt  ::= "switch" "(" Exp ")" SwitchBlock             [strict(1), klabel('Switch)]
syntax SwitchBlock ::= "{" SwitchGroupList SwitchLabelList "}"      [klabel('SwitchBlock)]
syntax SwitchGroup ::= SwitchLabelList BlockStmList                 [klabel('SwitchGroup)]
syntax SwitchLabel ::= "case" Exp ":"                               [klabel('Case)]
		             | "default"  ":"                               [klabel('Default)]

syntax DoStmt ::= "do" Stmt "while" "(" Exp ")" ";"                 [strict(2), klabel('DoWhile)]

syntax CatchClause ::= "catch" "(" Param ")" Block                  [klabel('Catch)]
syntax TryStmt ::= "try" Block CatchClauses "finally" Block         [klabel('Try)]
		         | "try" Block CatchClauses                         [klabel('Try)]

syntax ThrowStmt ::= "throw" Exp ";"                                [strict, klabel('Throw)]
syntax ContinueStmt ::= "continue" OptionalId ";"                   [klabel('Continue)]
syntax BreakStmt ::= "break" OptionalId ";"                         [klabel('Break)]
syntax ReturnStmt ::= "return" OptionalExp ";"                      [klabel('Return)]

syntax SynchronizedStmt ::= "synchronized" "(" Exp ")" Block   [strict(1), klabel('Synchronized)]

endmodule
