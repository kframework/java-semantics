/*@ \section{Module SYNTAX-CONVERSIONS}
  Defining the syntax for key portions of the semantics, and converting AST terms back int otheir syntactiv form.
*/

module SYNTAX-CONVERSIONS
    imports CORE-SORTS
    imports CORE-FUNCTIONS
    imports CORE-CLASSES    //for cast
    imports CORE-EXEC

/*@ \subsection{Method parameter}*/

// 'Param(\_:K,, T:Type,, X:Id). Consumed by initParams().
syntax KLabel ::= "'Param"

//Required for catch
rule 'Param(_,, K:K,, X:Id) => {K X} [structural]

syntax Param ::= "{" K Id "}"        [klabel('ParamImpl)]

syntax Params ::= List{Param, ","}

syntax K ::= toParams( KListWrap )          [function]
           | toParams( KListWrap , Params ) [function]

rule toParams([KLParams:KList]) => toParams([KLParams], .Params)
rule toParams([KLParams:KList,, 'Param(_,, K:K,, X:Id)], Params:Params) => toParams([KLParams], ({K X},Params))
rule toParams([.KList], Params:Params) => Params

// Required for getTypes()
rule typeOf('ParamImpl(T:Type,, _:Id)) => T

/*@ \subsection{Method invocation}*/

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

//totest model check - expressions should be evaluated from left to right. A test for this
//exists, but is unable to expose the problem. This rule have to be made "transition"
//somehow.
//totest - if qualifier evaluates to null, NullPointerException should be thrown after
//the evaluation of the arguments
/*@ Method invocation expression
*/
syntax Exp ::= K "." MethodName "(" Exps ")"       [seqstrict(1,3), klabel('MethodImpl)]
syntax MethodName ::= Id | MethodRef

/*@ \subsection{if statement}*/

syntax KLabel ::= "'If"
rule 'If(K1:K,,K2:K) => if (K1) {K2} else {.K}        [structural]
rule 'If(K1:K,,K2:K,,K3:K) => if (K1) {K2} else {K3}  [structural]

syntax Stmt ::= "if" "(" K ")" "{" K "}" "else" "{" K "}" [strict(1)]

/*@ \subsection{Local variable declaration}*/

//@ 'LocalVarDec(\_:K,, T:Type,, ['VarDec(X:Id)])
syntax KLabel ::= "'LocalVarDec"
                | "'VarDec"

rule 'LocalVarDec(_:K,, T:Type,,['VarDec(X:Id)]) => T X;  [structural]

syntax VarDec ::= Type Id ";"   [klabel('VarDecImpl)]
syntax Stmt ::= VarDec

/*@ \subsection{Assignment expression}*/

//@ 'Assign(loc(L)::T,, V::T)
syntax KLabel ::= "'Assign"

rule 'Assign(K1:K,, K2:K) => K1 = K2

syntax Exp ::= K "=" K       [klabel('AssignImpl)]

/*@ \subsection{Expression statement}*/

rule 'ExprStm(E:Exp) => E;
syntax Stmt ::= Exp ";"      [strict, klabel('ExprStmImpl)]

/*@ \subsection{Cast}*/

syntax Exp ::= "(" "(" Type ")" K ")" [klabel('CastImpl)]
rule ((T:Type) K:K) => cast(T, K)

/*@ \subsection{Identifier (name) expression}*/

//Naked identifier on top of computation
syntax Exp ::= Id
rule X:Id => 'ExprName(X)
rule lvalue(X:Id) => lvalue('ExprName(X))

/*@ \subsection{== expression}*/

// Just for the sake of the rule isOverridden
syntax Exp ::= K "==" K
rule K1:K == K2:K => eqAux(K1, K2)

/*@ \subsection{Throw statement}*/

syntax StackConsumerStmt ::= "throw" Exp ";"
rule throw E:Exp; => 'Throw(E)

/*@ \subsection{Return statement}*/

rule 'Return('None(_)) => return;

syntax StackConsumerStmt ::= "return" ";"

/*@ \subsection{New instance creation}*/

/* 'NewInstance( _:K,, Class:ClassType,, [Args],, 'None(.KList) )

    Although we could have just 'QNewInstance at runtime, having runtime semantics for 'NewInstance is preferred
    because we have a lot of 'Throw('NewInstance()) through our runtime semantics.
*/
syntax KLabel ::= "'NewInstance"

rule 'NewInstance( 'None(.KList),, Class:ClassType,, [ Args:KList ],, 'None(.KList) )
     => new Class( toExps([Args]) )

syntax Exp ::= "new" ClassType "(" Exps ")"

/*@ \subsection{Syntactic lists - Exps, TypedVals, Classes}*/

/*@
  A list of expressions, usually a list of arguments of a method or constructor.
*/
syntax Exps ::= List{Exp, ","} [seqstrict]

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

syntax Exps ::= TypedVals
syntax TypedVals ::= List{TypedVal, ","}

//@ Converts a TypedVals term to Types. Uses typeOf underneath.
syntax K ::=  getTypes (
                TypedVals     // a list of source values
              )
              [function]
            | getTypes(Types, TypedVals)  [function]

rule getTypes(TVs:TypedVals) => getTypes(types(.KList), TVs)
rule getTypes( types(Ts:KList), (_ :: T:Type, TVs:TypedVals) ) => getTypes( types(Ts,,T), TVs )
rule getTypes(types(Ts:KList), .TypedVals) => types(Ts)

syntax KResult ::= Classes
syntax Classes ::= List{ClassType, ","}

endmodule
