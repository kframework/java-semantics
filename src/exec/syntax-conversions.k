module SYNTAX-CONVERSIONS
    imports CORE-SORTS
    imports CORE-FUNCTIONS
    imports CORE-CLASSES    //for cast
    imports CORE-EXEC

/*@ Defining the syntax for key portions of the semantics, and converting AST terms back int otheir syntactiv form.
*/

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

/* 'Method(Qual:K,, \_:K,, Name:Id)
    'Method('MethodName(Qual:K,, Name:Id))
*/
rule 'Invoke('Method( 'MethodName( Qual:K,, Name:Id ) ),, ArgList:KListWrap) => Qual.Name(toExps(ArgList)) [structural]

//totest model check - expressions should be evaluated from left to right. A test for this
//exists, but is unable to expose the problem. This rule have to be made "transition"
//somehow.
//totest - if qualifier evaluates to null, NullPointerException should be thrown after
//the evaluation of the arguments
/*@ Method invocation expression
*/


/*@ \subsection{Local variable declaration}*/
syntax LocalVarDecStmt ::= Type Id ";"
rule 'LocalVarDec(_:K,, T:Type,,['VarDec(X:Id)]) => T X;  [structural]

/*@ \subsection{Cast}*/

syntax Exp ::= "(" "(" Type ")" K ")" [klabel('CastImpl)]
rule ((T:Type) K:K) => cast(T, K)

/*@ \subsection{Identifier (name) expression}*/

//Naked identifier on top of computation
syntax Exp ::= Id
rule X:Id => 'ExprName(X)
rule lvalue(X:Id) => lvalue('ExprName(X))

/* 'NewInstance( _:K,, Class:ClassType,, [Args],, 'None(.KList) )

    Although we could have just 'QNewInstance at runtime, having runtime semantics for 'NewInstance is preferred
    because we have a lot of 'Throw('NewInstance()) through our runtime semantics.
*/
rule 'NewInstance( 'None(.KList),, Class:ClassType,, [ Args:KList ],, 'None(.KList) )
     => new Class( toExps([Args]) )


// 'QNewInstance( Qual,, _:K,, Class,, _:K,, [Args],, 'None(.KList) )
rule 'QNewInstance( Qual:Exp,, _:K,, ClassOrName:ClassOrName,, _:K,, [Args:KList],, _:K )
     => Qual . new ClassOrName( toExps([Args]) )


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

syntax KItem ::= toExps( KListWrap )        [function]
           | toExps( KListWrap , Exps ) [function]

rule toExps([Args]) => toExps([Args], .Exps)
rule toExps([Args,, Arg], Es) => toExps([Args], (Arg,Es))
rule toExps([.KList], Es) => Es

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
