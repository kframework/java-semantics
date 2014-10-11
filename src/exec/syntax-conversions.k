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
rule 'Param(_,, K:K,, X:Id) => P{K X} [structural]

//add P to {} in case of ambiguity
syntax Param ::= "P{" K Id "}"        [klabel('ParamImpl)]

syntax Params ::= List{Param, ","}

syntax KItem ::= toParams( KListWrap )          [function]
           | toParams( KListWrap , Params ) [function]

rule toParams([KLParams:KList]) => toParams([KLParams], .Params)
rule toParams([KLParams:KList,, 'Param(_,, K:K,, X:Id)], Params:Params) => toParams([KLParams], (P{K X},Params))
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
//syntax StmtExp ::= K "." MethodName "(" Exps ")"       [seqstrict(1,3), klabel('MethodImpl)]
syntax MethodName ::= Id | MethodRef

/*@ \subsection{Local variable declaration}*/

//@ 'LocalVarDec(\_:K,, T:Type,, ['VarDec(X:Id)])
syntax KLabel ::= "'LocalVarDec"
                | "'VarDec"

//rule 'LocalVarDec(_:K,, T:Type,,['VarDec(X:Id)]) => T X;  [structural]

//syntax Stmt ::= VarDec


/*@ \subsection{Cast}*/

syntax Exp ::= "(" "(" Type ")" K ")" [klabel('CastImpl)]
rule ((T:Type) K:K) => cast(T, K)

/*@ \subsection{Identifier (name) expression}*/

//Naked identifier on top of computation
//syntax Exp ::= Id
rule X:Id => 'ExprName(X)
rule lvalue(X:Id) => lvalue('ExprName(X))

/* 'NewInstance( _:K,, Class:ClassType,, [Args],, 'None(.KList) )

    Although we could have just 'QNewInstance at runtime, having runtime semantics for 'NewInstance is preferred
    because we have a lot of 'Throw('NewInstance()) through our runtime semantics.
*/
syntax KLabel ::= "'NewInstance"

rule 'NewInstance( 'None(.KList),, Class:ClassType,, [ Args:KList ],, 'None(.KList) )
     => new Class( toExps([Args]) )

syntax Exp ::= "new" ClassType "(" Exps ")"

// 'QNewInstance( Qual,, _:K,, Class,, _:K,, [Args],, 'None(.KList) )
syntax KLabel ::= "'QNewInstance"

rule 'QNewInstance( Qual:Exp,, _:K,, ClassOrName:ClassOrName,, _:K,, [Args:KList],, _:K )
     => Qual . new ClassOrName( toExps([Args]) )

syntax ClassOrName ::= Id | ClassType

//totest model check - test the arguments evaluation order
syntax Exp ::= Exp "." "new" ClassOrName "(" Exps ")"     [seqstrict(1,3)]

/*@Unpack 'NewInstance back into 'QNewInstance.
  The difference between desugaring and unpacking is that unpacking is an artificial procedure required to separate
  elaboration from execution. In the elaboration phase there is a opposite packing rule tht creates this construct.
*/
rule [NewInstance-to-QNewInstance-unpack]:
    new Class:ClassType(ArgExps:Exps)
    => noValue . new Class:ClassType(ArgExps:Exps)

/*@ \subsection{Syntactic lists - Exps, TypedVals, ClassTypes}*/

/*@
  A list of expressions, usually a list of arguments of a method or constructor.
*/
syntax Exps ::= List{Exp, ","} [seqstrict]

syntax KItem ::= toExps( KListWrap )        [function]
           | toExps( KListWrap , Exps ) [function]

rule toExps([Args:KList]) => toExps([Args], .Exps)
rule toExps([Args:KList,, Arg:Exp], Es:Exps) => toExps([Args], (Arg,Es))
rule toExps([.KList], Es:Exps) => Es

syntax KItem ::= toKListWrap( Exps )              [function]
           | toKListWrap( KListWrap , Exps )  [function]

rule toKListWrap(Args:Exps) => toKListWrap([.KList], Args)
rule toKListWrap([Args:KList], (Arg:Exp, Es:Exps)) => toKListWrap([Args,, Arg], (Es))
rule toKListWrap([Args:KList], .Exps) => [Args]

syntax Exps ::= TypedVals
syntax TypedVals ::= List{TypedVal, ","}

//@ Converts a TypedVals term to Types. Uses typeOf underneath.
syntax KItem ::=  getTypes (
                TypedVals     // a list of source values
              )
              [function]
            | getTypes(Types, TypedVals)  [function]

rule getTypes(TVs:TypedVals) => getTypes(types(.KList), TVs)
rule getTypes( types(Ts:KList), (_ :: T:Type, TVs:TypedVals) ) => getTypes( types(Ts,,T), TVs )
rule getTypes(types(Ts:KList), .TypedVals) => types(Ts)

syntax KResult ::= ClassTypes
syntax ClassTypes ::= List{ClassType, ","}

endmodule
