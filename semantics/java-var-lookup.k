require "java-core.k"
require "java-subtyping.k"
require "java-process-classes.k"
require "java-static-init.k"
require "java-expressions.k"

module JAVA-VAR-LOOKUP
    imports JAVA-CORE
    imports JAVA-SUBTYPING
    imports JAVA-PROCESS-CLASSES
    imports JAVA-STATIC-INIT
    imports JAVA-EXPRESSIONS

//@ \subsection{Names}

//lookup the given local var by name. Return noValue if none found.
syntax K ::= "localVar" "(" Id //the var name
                        ")"

rule [localVarOK]:
    <k> localVar(X:Id)::_ => typedLookup(L) ...</k>
    <env>... X |-> L:Int ...</env>

rule [lvalueExprNameLocal]:
    <k> lvalue(localVar(X:Id)::_) => typedLoc(L) ...</k>
    <env>... X |-> L:Int ...</env>

/*@ \subsection{Self reference}
Like in untyped KOOL. */

//todo reconsider after elabration phase will work
rule [This]:
    <k>
      'This(.List{K})::Class:ClassType
      => objectClosure(OL, Obj) :: Class
      ...
    </k>
    <crntObj>
      Obj:Bag
      <crntClass> Class </crntClass>
      <location> OL:Int </location>
    </crntObj>
    <contextType> instanceCT </contextType>

/*@ \subsection{Object member access} */

//new rules

//outside lvalue we have strictness rules

context lookupField(HOLE,_,_)::_
context lvalue(lookupField(HOLE,_,_)::_)

rule [lookupField]:
    lookupField(
      objectClosure(_,
          <envStack>... ListItem((TargetClass, <env>... X |-> L:Int ...</env>)) ...</envStack>
        ) ::_,
      TargetClass:ClassType,
      X:Id
    )::_ => typedLookup(L)
        [anywhere]

rule [lookupFieldOfNull]:
    lookupField(null::_, _, _)::_
    =>  'Throw('NewInstance(
          'None(.List{K}),,
          class String2Id("java.lang.NullPointerException"),,
          'ListWrap( null ),,
          'None(.List{K})
        ))
        [structural, anywhere]

//Cannot put mark this rule with [anywhwre] to avoid duplicate, because it will be matched in ElaborateBlocks phase.
rule [lookupStaticField]:
    <k>
      lookupStaticField(
        TargetClass:ClassType,
        X:Id
      )::_ => typedLookup(L)
      ...
    </k>
    <classType> TargetClass </classType>
    <staticEnv>... X |-> L ...</staticEnv>

rule [lvalue-lookupStaticField]:
    <k>
      lvalue(
        lookupStaticField(
          TargetClass:ClassType,
          X:Id
        )::_ => typedLookup(L)
      )
      ...
    </k>
    <classType> TargetClass </classType>
    <staticEnv>... X |-> L ...</staticEnv>

/*@ \subsection{lvalue and loc} */

//@Typed version of lookup
syntax K ::= "typedLookup" "(" Int ")"

rule [typedLookup]:
    <k> typedLookup(L:Int) => lookup(L)::T ...</k>
    <store>... L |-> _::T:Type ...</store>

rule [lvalueTypedLookup]:
    <k> lvalue( typedLookup(L:Int) => lookup(L)::T ) ...</k>
    <store>... L |-> _::T:Type ...</store>

rule [typedLookupUninitialized]:
    <k> (. => staticInit(Class)) ~> typedLookup(L:Int) ...</k>
    <store>... L |-> uninitialized(Class:ClassType, T:Type) ...</store>

rule [lvalueTypedLookupUninitialized]:
    <k> (. => staticInit(Class)) ~> lvalue(typedLookup(L:Int)) ...</k>
    <store>... L |-> uninitialized(Class:ClassType, T:Type) ...</store>

rule <k> lvalue(lookup(L:Int)::T:Type) => loc(L)::T ...</k>  [structural]

syntax K ::= "typedLoc" "(" Int ")"

rule [typedLoc]:
    <k> typedLoc(L:Int) => loc(L)::T ...</k>
    <store>... L |-> _::T:Type ...</store>

rule [lvalueTypedLoc]:
    <k> lvalue( typedLoc(L:Int) => loc(L)::T ) ...</k>
    <store>... L |-> _::T:Type ...</store>

/*@ \subsection{lookup} */

rule [lookupLocation]:
    <k>
      lookup(L:Int) :: T1:Type
      => subtype(T2, T1) ~> true? ~> (V::T1)
      ...
    </k>
    <store>... L |-> V:RawVal :: T2:Type ...</store>

endmodule
