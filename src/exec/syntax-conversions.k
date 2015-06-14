module SYNTAX-CONVERSIONS
    imports CORE-SORTS
    imports CORE-FUNCTIONS
    imports CORE-CLASSES    //for cast
    imports CORE-EXEC

/*
todo I moved some syntax back to this file because they are not standard java syntax (by SDF), but concrete syntax
that are used in exec-semantics. Ideally, I want to replace these (e.g. MethodInvoke and InstanceCreation) syntax
(and the rules using them) with standard Java syntax. But they are not that bad looking and changing from concrete
to concrete is more difficult than from abstract to concrete, because abstract form are more clear.
So these will be left here for some time.
*/

/*@ \subsection{Method invocation}*/
//Denis' syntax
syntax MethodInvokeExp ::= K "." MethodName "(" Exps ")"   [klabel('MethodImpl)]
/*need the following rule and context here since sometimes Id is the second argument.
difference between
syntax MethodName ::= Id    and
syntax MethodName ::= Id [klabel('MethodName)]
*/
rule isMethodInvokeExp('MethodImpl(_)) => true
context 'MethodImpl(HOLE,,_:K,,_:K)
context 'MethodImpl(_:KResult,,_:K,,HOLE)

/*
General structure:

'Invoke(
  'Method(
    'MethodName(
      QualifierExp:Expression,,
      Name:Id
    )
  ),,
  Args - argument expressions
)
*/
rule 'Invoke('Method( 'MethodName( Qual:K,, Name:Id ) ),, ArgList:Exps) => Qual.Name(ArgList) [structural]

//totest model check - expressions should be evaluated from left to right. A test for this
//exists, but is unable to expose the problem. This rule have to be made "transition"
//somehow.
//totest - if qualifier evaluates to null, NullPointerException should be thrown after
//the evaluation of the arguments

/*@ Function Used when we feed a KListWrap to invokeImpl */
syntax KItem ::= toKListWrap( Exps )              [function]
               | toKListWrap( KListWrap , Exps )  [function]

rule toKListWrap(Args:Exps) => toKListWrap([.KList], Args)
rule toKListWrap([Args:KList], (Arg:Exp, Es:Exps)) => toKListWrap([Args,, Arg], (Es))
rule toKListWrap([Args:KList], .Exps) => [Args]

//Usage: getClassChain,lookupPackageMethod
syntax ClassTypes ::= List{ClassType, ","}
syntax KResult ::= ClassTypes


/*@ \subsection{Local variable declaration}*/
//Denis' syntax
syntax LocalVarDecStmt ::= Type Id ";"
rule 'LocalVarDecStm('LocalVarDec(_:K,, T:Type,,'VarDecList('VarDec(X:Id),, .VarDecList))) => T X;  [structural]


/*@ \subsection{Cast}*/
//this might be confused with castprim or castref
//Denis' syntax
syntax Exp ::= "(" "(" Type ")" K ")" [klabel('CastImpl)]
rule ((T:Type) K:K) => cast(T, K)
rule ( T:RefType ) E:Exp => cast(T,E)
rule ( T:PrimType ) E:Exp => cast(T,E)


/*@ \subsection{Identifier (name) expression}*/
//Denis' syntax
//Naked identifier on top of computation
syntax Exp ::= Id
rule X:Id => 'ExprName(X)
rule lvalue(X:Id) => lvalue('ExprName(X))


/*@ \subsection{New Instance}*/
//Denis' syntax
syntax ClassInstanceCreationExp ::= "new" ClassType "(" Exps ")"
                                  | Exp "." "new" ClassOrName "(" Exps ")"      [seqstrict(1,3)]

/* 'NewInstance( _:K,, Class:ClassType,, Args,, 'None(.KList) )

    Although we could have just 'QNewInstance at runtime, having runtime semantics for 'NewInstance is preferred
    because we have a lot of 'Throw('NewInstance()) through our runtime semantics.
*/
rule 'NewInstance( 'None(.KList),, Class:ClassType,, Args:Exps ,, 'None(.KList) )
     => new Class(Args)

// 'QNewInstance( Qual,, _:K,, Class,, _:K,, Args,, 'None(.KList) )
rule 'QNewInstance( Qual:Exp,, _:K,, ClassOrName:ClassOrName,, _:K,, Args:Exps,, _:K )
     => Qual . new ClassOrName(Args)

/*@Unpack 'NewInstance back into 'QNewInstance.
  The difference between desugaring and unpacking is that unpacking is an artificial procedure required to separate
  elaboration from execution. In the elaboration phase there is a opposite packing rule tht creates this construct.
*/
rule [NewInstance-to-QNewInstance-unpack]:
    new Class:ClassType(ArgExps:Exps)
    => (noValue):>Exp . new Class:ClassType(ArgExps:Exps)

endmodule
