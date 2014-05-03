/*@ \section{Module SYNTAX-CONVERSIONS}
  Defining the syntax for key portions of the semantics, and converting AST terms back int otheir syntactiv form.
*/

module SYNTAX-CONVERSIONS
    imports CORE-SORTS
    imports CORE-FUNCTIONS
    imports CORE-CLASSES    //for cast
    imports CORE-EXEC

// 'Param(\_:K,, T:Type,, X:Id). Consumed by initParams().
syntax KLabel ::= "'Param"

rule 'Param(_,, K:K,, X:Id) => {K X} [structural, anywhere]

syntax Param ::= "{" K Id "}"        [klabel('ParamImpl)]

// Required for getTypes()
rule typeOf('ParamImpl(T:Type,, _:Id)) => T

/*
General structure:

'Invoke(
  'Method(
    'MethodName(
      QualifierExp:Expression,,
      Name:Id
    )
  ),,
  [Args] - argument expressions
)
*/
syntax KLabel ::= "'Invoke"

/* 'Method(Qual:K,, \_:K,, Name:Id)
    'Method('MethodName(Qual:K,, Name:Id))
*/
syntax KLabel ::= "'Method"
                | "'MethodName"

rule 'Invoke('Method( 'MethodName( Qual:K,, Name:Id ) ),, Params:KListWrap) => Qual.Name(Params) [structural]

syntax Method ::= K "." MethodName "(" KListWrap ")"  [klabel('MethodImpl)]
syntax MethodName ::= Id | MethodRef

syntax KLabel ::= "'If"
rule 'If(K1:K,,K2:K) => if (K1) {K2} else {.K}        [structural]
rule 'If(K1:K,,K2:K,,K3:K) => if (K1) {K2} else {K3}  [structural]

syntax Stmt ::= "if" "(" K ")" "{" K "}" "else" "{" K "}" [strict(1)]

//@ 'LocalVarDec(\_:K,, T:Type,, ['VarDec(X:Id)])
syntax KLabel ::= "'LocalVarDec"
                | "'VarDec"

rule 'LocalVarDec(_:K,, T:Type,,['VarDec(X:Id)]) => T X;  [structural]

syntax VarDec ::= Type Id ";"   [klabel('VarDecImpl)]

//@ 'Assign(loc(L)::T,, V::T)
syntax KLabel ::= "'Assign"

rule 'Assign(K1:K,, K2:K) => K1 = K2

syntax Assign ::= K "=" K       [klabel('AssignImpl)]

syntax Stmt ::= K ";"           [klabel('ExprStmImpl)]

rule K:K; => 'ExprStm(K)

syntax Exp ::= "(" "(" Type ")" K ")" [klabel('CastImpl)]
rule ((T:Type) K:K) => cast(T, K)

//Naked identifier on top of computation
rule X:Id => 'ExprName(X)
rule lvalue(X:Id) => lvalue('ExprName(X))

endmodule
