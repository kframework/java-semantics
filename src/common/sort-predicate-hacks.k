module SORT-PREDICATE-HACKS

/*
The rules in this module are designed to extend the predicates for basic syntactic sorts like Exp or Stmt, and to
ease the restrictions imposed by those predicates.
For example, the syntactic definition of plus : syntax Exp ::= Exp + Exp, will return true for
isExp('Plus(K1,,K2)) only when both K1 and K2 are valid Exp terms, while a rule isExp('Plus(_)) => true
will produce true for any term whose root node has the label 'Plus. This allows us to use variable subsorting inside
rules, to define more rules syntactically.
*/

/*
  Workaround: in a correct semantics these rules should not be needed, as all the labels below
  are associated with expression syntax. Yet, the predicate isExp generated for sort Exp checks not only the
  root label, but also the content of child nodes recursively, and child nodes are sometimes not valid children
  of an expression.

  The predicate isExp() is used in elaboration phase by the rule [elabEnd-default-all-except-expressions].
*/
rule isExp('ArrayAccess(_)) => true
rule isExp('NewInstance(_)) => true    // also in customElabChildren
rule isExp('QNewInstance(_)) => true   // also in customElabChildren
rule isExp('InstanceOf(_)) => true
rule isExp('Invoke(_)) => true
rule isExp('This(_)) => true
rule isExp('QThis(_)) => true
rule isExp('AmbName(_)) => true
rule isExp('ExprName(_)) => true
rule isExp('Field(_)) => true
rule isExp('SuperField(_)) => true
rule isExp('QSuperField(_)) => true
rule isExp('NewArray(_)) => true
rule isExp('CastPrim(_)) => true
rule isExp('CastRef(_)) => true


// Used to define statements syntactically.
rule isStmt(_:K) => true
//rule isStmt('ClassDecStm(_)) => true
//rule isStmt('Block(_)) => true
//rule isStmt('LocalVarDecStm(_)) => true
//rule isStmt('LocalVarDec(_)) => true
//rule isStmt('If(_)) => true
//rule isStmt('While(_)) => true
//rule isStmt('For(_)) => true
//rule isStmt('ForEach(_)) => true
//rule isStmt('Labeled(_)) => true
//rule isStmt('Empty(_)) => true
//rule isStmt('ExprStm(_)) => true
//rule isStmt('AssertStm(_)) => true
//rule isStmt('Switch(_)) => true
//rule isStmt('DoWhile(_)) => true
//rule isStmt('Try(_)) => true
//rule isStmt('Throw(_)) => true
//rule isStmt('Continue(_)) => true
//rule isStmt('Break(_)) => true
//rule isStmt('Return(_)) => true
//rule isStmt('Synchronized(_)) => true
//
//// Special case, a sequence of statements. Might not be needed, we'll better add it to be sure.
//rule isStmt('ListWrap(_)) => true

endmodule
