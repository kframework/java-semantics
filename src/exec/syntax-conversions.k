require "../common/core-sorts.k"
require "../common/core-functions.k"

/*@ \section{Module SYNTAX-CONVERSIONS}
  Defining the syntax for key portions of the semantics, and converting AST terms back int otheir syntactiv form.
*/

module SYNTAX-CONVERSIONS
    imports CORE-SORTS
    imports CORE-FUNCTIONS

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

rule 'Invoke('Method( 'MethodName( Qual:K,, Name:Id ) ),, Params:KListWrap) => Qual.Name(Params) [structural, anywhere]

syntax Method ::= K "." MethodName "(" KListWrap ")"  [klabel('MethodImpl)]
syntax MethodName ::= Id | MethodRef

endmodule
