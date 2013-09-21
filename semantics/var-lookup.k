require "core.k"
require "subtyping.k"
require "process-classes.k"
require "static-init.k"
require "expressions.k"

//@ \section{Module VAR-LOOKUP}

module VAR-LOOKUP
    imports CORE
    imports SUBTYPING
    imports PROCESS-CLASSES
    imports STATIC-INIT
    imports EXPRESSIONS

//@ \subsection{Names}

//lookup the given local var by name.
syntax K ::= "localVar" "(" Id ")" //the var name

rule [localVar]:
    <k> localVar(X:Id)::_ => typedLookup(L) ...</k>
    <env>... X |-> L:Int ...</env>

rule [lvalueLocalVar]:
    <k> lvalue(localVar(X:Id)::_) => typedLoc(L) ...</k>
    <env>... X |-> L:Int ...</env>

/*@ \subsection{Self reference}
Like in untyped KOOL. */

rule [QThis]:
    <k>
      'QThis(Class:ClassType)::Class => lookupQThis(Class, RV::CrntClass)
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

//This case may happen when a field/method is called by simple name in a static context.
//Although there should be no qualifier, elaboration phase will introduce the qualifier 'QThis.
rule [QThis-static]:
    <k>
      'QThis(_)::_ => noValue
      ...
    </k>
    <contextType> staticCT </contextType>

//Search for the right value representing QThis(Class) - an expression of type Class.this
syntax K ::= "lookupQThis" "(" ClassType  //the type of this to look for
                           "," TypedVal   //the objectClosure where the type should be found
                           ")"

rule [lookupQThis-found]:
    lookupQThis(Class:ClassType, RV:RawVal::Class) => RV::Class

/*When we have Qthis target class Class, and we look for it in a target object with a different
compile-time type ObjClass, we continue our search in the encloser of the layer corresponding to ObjClass.
This way we may have O.B < O.A, with layers O.B and O.A having different enclosing instance of O,
and we will be able to pick the correct encloser inside both O.A and O.B.
*/
rule [lookupQThis-next]:
    lookupQThis(Class:ClassType,
      objectClosure(_, _:List ListItem(el(ObjClass,_, Encloser:KResult, _)) _:List, _)
        :: ObjClass:ClassType
    ) => lookupQThis(Class:ClassType, Encloser)
when
    Class =/=K ObjClass

//This case may happen when a field/method is called by simple name in a static context.
//Although there should be no qualifier, elaboration phase will introduce the qualifier noValue.
rule [lookupQThis-on-noValue]:
    lookupQThis(_, noValue) => noValue

/*@ \subsection{Object member access} */

//new rules

//outside lvalue we have strictness rules

context lookupField(HOLE,_,_)::_
context lvalue(lookupField(HOLE,_,_)::_)

rule [lookupField]:
    lookupField(
      objectClosure(_,
          _:List ListItem(el(TargetClass, <env>... X |-> L:Int ...</env>, _,_)) _:List, _
        ) ::_,
      TargetClass:ClassType,
      X:Id
    )::_ => typedLookup(L)
        [anywhere]

rule [lookupFieldOfNull]:
    lookupField(null::_, _, _)::_
    =>  'Throw('NewInstance(
          'None(.KList),,
          class String2Id("java.lang.NullPointerException"),,
          'ListWrap( null ),,
          'None(.KList)
        ))
        [anywhere]

rule [lookupStaticField]:
    <k>
      lookupStaticField(
        TargetClass:ClassType,
        X:Id
      )::_
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
      )::_ )
      => staticInit(TargetClass) ~> lvalue(typedLookup(L))
      ...
    </k>
    <classType> TargetClass </classType>
    <staticEnv>... X |-> L:Int ...</staticEnv>

/*@ \subsection{lvalue and loc} */

//@Typed version of lookup
syntax K ::= "typedLookup" "(" Int ")"

rule [typedLookup]:
    <k> typedLookup(L:Int) => lookup(L)::T ...</k>
    <store>... L |-> _::T:Type ...</store>

rule [lvalueTypedLookup]:
    <k> lvalue( typedLookup(L:Int) => lookup(L)::T ) ...</k>
    <store>... L |-> _::T:Type ...</store>

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
        [transition-threading]

endmodule
