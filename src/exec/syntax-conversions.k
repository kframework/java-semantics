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

rule 'Invoke('Method( 'MethodName( Qual:K,, Name:Id ) ),, ArgList:KListWrap) => Qual.Name(toExps(ArgList)) [structural]

syntax Method ::= K "." MethodName "(" Exps ")"       [klabel('MethodImpl)]
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
syntax Stmt ::= VarDec

//@ 'Assign(loc(L)::T,, V::T)
syntax KLabel ::= "'Assign"

rule 'Assign(K1:K,, K2:K) => K1 = K2

syntax Exp ::= K "=" K       [klabel('AssignImpl)]

syntax Stmt ::= K ";"           [klabel('ExprStmImpl)]

rule K:K; => 'ExprStm(K)

syntax Exp ::= "(" "(" Type ")" K ")" [klabel('CastImpl)]
rule ((T:Type) K:K) => cast(T, K)

//Naked identifier on top of computation
syntax Exp ::= Id
rule X:Id => 'ExprName(X)
rule lvalue(X:Id) => lvalue('ExprName(X))

// Just for the sake of the rule isOverridden
syntax Exp ::= K "==" K
rule K1:K == K2:K => eqAux(K1, K2)

syntax Stmt ::= "throw" K ";"
rule throw K:K; => 'Throw(K)

syntax Exp ::= "new" ClassType "(" KListWrap ")"
rule new Class:ClassType([Args:KList])
     => 'NewInstance( 'None(.KList),, Class,, [ Args ],, 'None(.KList) )

/*@
  A list of expressions, usually a list of arguments of a method or constructor.
*/
syntax Exps ::= List{Exp, ","} [seqstrict]

syntax Exps ::= TypedVals
syntax TypedVals ::= List{TypedVal, ","}

syntax K ::= toExps( KListWrap )        [function]
           | toExps( KListWrap , Exps ) [function]

rule toExps([Args:KList]) => toExps([Args], .Exps)
rule toExps([Args:KList,, Arg:Exp], Es:Exps) => toExps([Args], (Arg,Es))
rule toExps([.KList], Es:Exps) => Es

syntax K ::= toKListWrap( Exps )              [function]
           | toKListWrap( KListWrap , Exps )  [function]

rule toKListWrap(Args:Exps) => toKListWrap([.KList], Args)
rule toKListWrap([Args:KList], (Arg:Exp, Es:Exps)) => toKListWrap([Args,, Arg], (Es))
rule toKListWrap([Args:KList], .Exps) => [Args]

//@ Converts a TypedVals term to Types. Uses typeOf underneath.
syntax K ::=  getTypes (
                TypedVals     // a list of source values
              )
              [function]
            | getTypes(Types, TypedVals)  [function]

rule getTypes(TVs:TypedVals) => getTypes(types(.KList), TVs)
rule getTypes( types(Ts:KList), (_ :: T:Type, TVs:TypedVals) ) => getTypes( types(Ts,,T), TVs )
rule getTypes(types(Ts:KList), .TypedVals) => types(Ts)

endmodule
