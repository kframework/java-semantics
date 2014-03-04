require "core-sorts.k"
require "expressions.k"

module CORE-FUNCTIONS
    imports CORE-SORTS
    imports EXPRESSIONS

/*@ Returns the type associated with various K terms. The implementation is scattered among various K files.
  For a type - the type itself. For a typed expression - the type component. For some raw values - their most common
    type.
*/
syntax K ::= typeOf ( K )                           [function]
rule typeOf(T:Type) => T
rule typeOf(_ :: T:Type) => T
rule typeOf(Str:String) => stringClass
rule typeOf(null) => nullType
rule typeOf(objectClosure(_, (layer(Class:ClassType, _,_,_),, _:KList/*ObjLayers*/), _)) => Class
rule typeOf(arrayRef( arrayOf T:Type, _, _)) => arrayOf T

/* Required by getTypes in elaboration phase, invoked by lookupMethod. */
rule typeOf(cast(T:Type, _)) => T

// Required for getTypes()
rule typeOf('Param(_:K,, T:Type,, _:Id)) => T

/*@The default value for all types. Used for field initializers.*/
syntax K ::= default ( Type )                       [function]
rule default(IntT:IntType) => 0 :: IntT
rule default(FloatT:FloatType) => 0.0 :: FloatT
rule default(bool) => false :: bool
rule default(RT:RefType) => null :: RT

/*@ Whenever naked RawVal reaches the top of computation, it have to be converted into TypedVal */
rule Val:RawVal => toTypedVal(Val)                                                  [structural]

/*@ Converts a RawVal into a TypedVal, by adding a default type for the given value.
    Greatly simplifies many rules, because now we can use raw values in the RHS, instead of typed values.
*/
syntax K ::= toTypedVal ( RawVal )
rule toTypedVal(I:Int) => I :: int                                                  [structural]
rule toTypedVal(B:Bool) => B :: bool                                                [structural]
rule toTypedVal(Str:String) => Str :: stringClass                                   [structural]
rule toTypedVal(null) => null :: nullType                                           [structural]
rule toTypedVal( objectClosure(
      OL:Int,
      (layer(Class:ClassType, BI:BagItem, EnclosingObj:KResult, LocalEnv:Map),, Rest:KList/*ObjLayers*/),
      ObjLocalClassesEnv:Map
    ))
    => objectClosure(
      OL,
      (layer(Class, BI, EnclosingObj, LocalEnv),, Rest),
      ObjLocalClassesEnv
    ) :: Class
                                                                                      [structural]
rule toTypedVal(arrayRef(T:Type, L:Int, M:Int)) => arrayRef(T, L, M) :: T             [structural]

/*@ A list of types. Elements are of sort Type. Used especially to denote argument types of a method.*/
syntax Types ::=  types (
                    KList // List of Type elements, when processed
                  )
syntax KResult ::= Types

//@ Converts a KList of terms to Types. Uses typeOf underneath.
syntax K ::=  getTypes (
                KList     //List{KResult} a list of source expressions
              )
              [function]

rule getTypes(_,, (K:K => typeOf(K)),, _)
when
    notBool isType(K) ==K true

rule getTypes(Ts:KList) => types(Ts)
when
    isKResult(Ts)

//@ \subsubsection{Other auxiliary constructs}

/*@ Generalized equality with strictness, suitable to compare not only TypedVal-s but any K terms.
*/
syntax K ::= eqAux ( K, K )                  [seqstrict]
rule eqAux(KR1:KResult, KR2:KResult) => KR1 ==K KR2

/*@ A wrapper for maps. Allows holding maps inside an arbitrary expression where a K term is required.
    Also used as part of mapUnion operation in PROCESS-CLASS-MEMBERS
*/
syntax KResult ::= mapWrap ( Map )

/*@ The union of two maps. Arguments are of the form mapWrap(Map). In this operation, elements of the second map
    overwrite elements of the first map if they collide.
*/
syntax K ::=  mapUnion (
                K,  //mapWrap(Map)
                K   //mapWrap(Map)
              )
              [strict]

rule mapUnion(mapWrap( M1:Map => M1[K2/K1] ), mapWrap( _:Map (K1:K |-> K2:K => .Map) ))
rule mapUnion(mapWrap(M1:Map), mapWrap(.Map)) => mapWrap(M1)

/*@A wrapper for sets, similar to the one for maps.*/
syntax KResult ::= setWrap ( Set )

/*The union of two sets. Arguments are of the form setWrap(Set).*/
syntax K ::=  setUnion (
                K,  //setWrap(Set)
                K   //setWrap(Set)
              )
              [strict]

rule setUnion(setWrap( S1:Set (. => SetItem(K)) ), setWrap( S2:Set (SetItem(K:K) => .) ))
when
    notBool(K in S1)
rule setUnion(setWrap( S1:Set SetItem(K) ), setWrap( S2:Set (SetItem(K:K) => .) ))
rule setUnion(setWrap(S1:Set), setWrap(.Set)) => setWrap(S1)

/*@ \subsection{Identifiers}*/

/*@Convert the AST representation of an Id into a K Id.*/
rule 'Id(Str:String) => String2Id(Str)                [structural, anywhere]

/*@ \subsection{Other auxiliary constructs} */

/*@ \texttt{Generic guard.}
    A generic computational guard (should be builtin): it allows the computation to continue only if a prefix
    guard evaluates to true.
*/
syntax K ::= "true?"
rule true::bool ~> true? => .  [structural]

endmodule
