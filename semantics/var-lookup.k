require "core-sorts.k"
require "process-class-members.k"
require "subtyping.k"
require "static-init.k"
require "expressions.k"

//@ \section{Module VAR-LOOKUP}

module VAR-LOOKUP
    imports CORE-SORTS
    imports PROCESS-CLASS-MEMBERS
    imports SUBTYPING
    imports STATIC-INIT         //for staticInit()
    imports EXPRESSIONS

//@ \subsection{Names}

//@ Lookup the given local var by name.
syntax K ::= localVar ( Id ) //the var name

rule [localVar]:
    <k> localVar(X:Id) => typedLookup(L) ...</k>
    <env>... X |-> L:Int ...</env>

rule [lvalue-localVar]:
    <k> lvalue(localVar(X:Id)) => typedLoc(L) ...</k>
    <env>... X |-> L:Int ...</env>

/*@ \subsection{Self reference}
Like in untyped KOOL. */

rule [QThis]:
    <k>
      'QThis(Class:ClassType) => lookupQThis(Class, RV::CrntClass)
      ...
    </k>
    <crntClass> CrntClass:ClassType </crntClass>
    <location> OL:Int </location>
    <contextType> instanceCT </contextType>
    <store>
      ...
      OL |-> RV:RawVal :: _
      ...
    </store>

/*@ This case may happen when a field/method is called by simple name in a static context.
Although there should be no qualifier, elaboration phase will introduce the qualifier 'QThis.*/
rule [QThis-static]:
    <k>
      'QThis(_) => noValue
      ...
    </k>
    <contextType> staticCT </contextType>

//@ Search for the right value representing QThis(Class) - an expression of type Class.this
syntax K ::=  lookupQThis (
                ClassType,  //the type of this to look for,
                TypedVal    //the objectClosure where the type should be found
              )

rule [lookupQThis-found]:
    lookupQThis(Class:ClassType, RV:RawVal::Class) => RV::Class

/*@ When we have QThis target class Class, and we look for it in a target object with a different
compile-time type ObjClass, we continue our search in the enclosing object of the layer corresponding to ObjClass.
This way we may have O.B < O.A, with layers O.B and O.A having different enclosing instance of O,
and we will be able to pick the correct enclosing object inside both O.A and O.B.
*/
rule [lookupQThis-next]:
    lookupQThis(Class:ClassType,
      objectClosure(_, (_:KList/*ObjLayers*/,, layer(ObjClass,_, EnclosingObj:KResult, _),, _:KList/*ObjLayers*/), _)
        :: ObjClass:ClassType
    ) => lookupQThis(Class:ClassType, EnclosingObj)
when
    Class =/=K ObjClass

//This case may happen when a field/method is called by simple name in a static context.
//Although there should be no qualifier, elaboration phase will introduce the qualifier noValue.
rule [lookupQThis-on-noValue]:
    lookupQThis(_, noValue) => noValue

/*@ \subsection{Object member access} */

//new rules

//outside lvalue we have strictness rules

//@ Elaboration result of a field access exp.
syntax K ::=  lookupField (
                K,    //Qualifier exp
                Type, //Precise type where the field is defined
                Id    //X - field name
              )

context lookupField(HOLE,_,_)
context lvalue(lookupField(HOLE,_,_))

rule [lookupField]:
    lookupField(
      objectClosure(_,
          (_:KList/*ObjLayers*/,, layer(TargetClass, <env>... X |-> L:Int ...</env>, _,_),, _:KList/*ObjLayers*/), _
        ) ::_,
      TargetClass:ClassType,
      X:Id
    ) => typedLookup(L)
        [anywhere]

rule [lookupField-OfNull]:
    lookupField(null::_, _, _)
    =>  'Throw('NewInstance(
          'None(.KList),,
          class String2Id("java.lang.NullPointerException"),,
          'ListWrap( null ),,
          'None(.KList)
        ))
        [anywhere]

//@ Elaboration result of a static field access expression
syntax K ::=  lookupStaticField (
                Type, //Precise type where the field is defined
                Id    //X - field name
              )

rule [lookupStaticField]:
    <k>
      lookupStaticField(
        TargetClass:ClassType,
        X:Id
      )
      => staticInit(TargetClass) ~> typedLookup(L)
      ...
    </k>
    <classType> TargetClass </classType>
    <staticEnv>... X |-> L:Int ...</staticEnv>

rule [lvalue-lookupStaticField]:
    <k>
      lvalue(lookupStaticField(
          TargetClass:ClassType,
          X:Id
      ))
      => staticInit(TargetClass) ~> lvalue(typedLookup(L))
      ...
    </k>
    <classType> TargetClass </classType>
    <staticEnv>... X |-> L:Int ...</staticEnv>

/*@ \subsection{lvalue and loc} */

//@ Typed version of lookup
syntax K ::= typedLookup ( Int )

rule [typedLookup]:
    <k> typedLookup(L:Int) => lookup(L, T) ...</k>
    <store>... L |-> _::T:Type ...</store>

rule [lvalue-typedLookup]:
    lvalue( typedLookup(L:Int) ) => typedLoc(L)

syntax K ::= typedLoc ( Int )

rule [typedLoc]:
    <k> typedLoc(L:Int) => loc(L)::T ...</k>
    <store>... L |-> _::T:Type ...</store>

rule [lvalue-typedLoc]:
    lvalue(typedLoc(L:Int)) => typedLoc(L)

/*@ \subsection{lookup} */

/*@ Retrieve a value from the store based on its location and the given compile-time type.
  May be wrapped inside lvalue. If lookup is unwrapped, it evaluates to TypedVal - the store value,
  of the type T - the second lookup argument. If lookup is wrapped into lvalue, it evaluates to loc(OL)::T.
*/
syntax Lookup ::= lookup (
                    Int,  //OL - the store location to lookup
                    Type  // T - the compile-time type of the resulting value
                  )

rule [lookup-Location]:
    <k>
      lookup(L:Int, T1:Type) => subtype(T2, T1) ~> true? ~> (V::T1)
      ...
    </k>
    <store>... L |-> V:RawVal :: T2:Type ...</store>
        [transition-threading]

rule lvalue(lookup(L:Int, T:Type)) => loc(L)::T
        [structural]

endmodule
