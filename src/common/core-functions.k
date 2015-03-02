module CORE-FUNCTIONS
    imports CORE-SORTS
    imports CORE-CLASSES
    imports JAVA-SYNTAX
/*@ Returns the type associated with various K terms. The implementation is scattered among various K files.
  For a type - the type itself. For a typed expression - the type component. For some raw values - their most common
    type.
*/
syntax KItem ::= typeOf ( K )                           [function]
rule typeOf(T:Type) => T
rule typeOf(_ :: T:Type) => T
rule typeOf(Str:String) => classString
rule typeOf(null) => nullType
rule typeOf(objectRef(_, Class:ClassType)) => Class
rule typeOf(arrayRef( arrayOf T:Type, _, _)) => arrayOf T

/* Required by getTypes in elaboration phase, invoked by lookupMethod. */
rule typeOf(cast(T:Type, _)) => T

// Required for getTypes()
rule typeOf('Param(_:K,, T:Type,, _:Id)) => T

/*@The default value for all types. Used for field initializers.*/
syntax KItem ::= default ( Type )                       [function]
rule default(IntT:IntType) => 0 :: IntT
rule default(FloatT:FloatType) => 0.0 :: FloatT
rule default(bool) => false :: bool
rule default(RT:RefType) => null :: RT

/*@ Whenever naked RawVal reaches the top of computation, it have to be converted into TypedVal */
rule Val:RawVal => toTypedVal(Val)                                                  [structural]

/*@ Converts a RawVal into a TypedVal, by adding a default type for the given value.
    Greatly simplifies many rules, because now we can use raw values in the RHS, instead of typed values.

    Have to be [function] for LTL
*/
syntax KItem ::= toTypedVal ( RawVal )                                                  [function]
rule toTypedVal(I:Int) => I :: int                                                  [structural]
rule toTypedVal(B:Bool) => B :: bool                                                [structural]
rule toTypedVal(Str:String) => Str :: classString                                   [structural]
rule toTypedVal(null) => null :: nullType                                           [structural]
rule toTypedVal( objectRef(OL:Int, Class:ClassType) )
    => objectRef(OL:Int, Class:ClassType) :: Class                                  [structural]

rule toTypedVal(arrayRef(T:Type, L:Int, M:Int)) => arrayRef(T, L, M) :: T           [structural]

//@ Converts a KList of terms to Types. Uses typeOf underneath.
syntax KItem ::=  getTypes (
                KListWrap     //[...,, KResult,, ...] - a list of source expressions
              )
              [function]

// Without the second side condition it would be an infinite loop
rule getTypes([_,, (K:K => typeOf(K)),, _])
when
    isType(K) =/=K true andBool getKLabel(K) =/=KLabel 'typeOf

rule getTypes([Ts:KList]) => types(Ts)
when
    isKResult(Ts)

syntax KItem ::= getTypes ( Params ) [function]
               | getTypes ( Types , Params ) [function]
rule getTypes( Ps:Params ) => getTypes(types(.KList), Ps)
rule getTypes( types(Ts:KList), (_:AnnoVarModList T:Type _:Id , Ps:Params) ) => getTypes( types(Ts,,T), Ps )
rule getTypes( types(Ts:KList), .Params) => types(Ts)

//@ \subsubsection{Other auxiliary constructs}

/*@ Generalized equality with strictness, suitable to compare not only TypedVal-s but any K terms.
*/
syntax KItem ::= eqAux ( K, K )                  [seqstrict]
rule eqAux(KR1:KResult, KR2:KResult) => KR1 ==K KR2

/*@ Alternative version of if, to be used whenever semantics needs an if logic.
  The original 'If will only be used in the source programs.*/
syntax KItem ::= ifAux ( K, K, K )                  [strict(1)]
rule ifAux(true::bool, S:K, _) => S
rule ifAux(false::bool, _, S:K) => S

syntax KItem ::= andAux(K, K)                       [strict(1)]
rule andAux(true::bool, E:K) => E
rule andAux(false::bool, _) => false

syntax KItem ::= orAux(K, K)                        [strict(1)]
rule orAux(true::bool, _) => true
rule orAux(false::bool, E:K) => E

//@ Replaces 'Plus in preprocessing phases
syntax KItem ::= plusAux( K, K )                    [strict]
rule plusAux(Str1:String :: _, Str2:String :: _) => (Str1 +String Str2) :: classString

/*@ A wrapper for maps. Allows holding maps inside an arbitrary expression where a K term is required.
    Also used as part of mapUnion operation in PROCESS-CLASS-MEMBERS
*/
syntax KResult ::= mapWrap ( Map )

/*@ The union of two maps. Arguments are of the form mapWrap(Map). In this operation, elements of the second map
    overwrite elements of the first map if they collide.
*/
syntax KItem ::=  mapUnion (
                K,  //mapWrap(Map)
                K   //mapWrap(Map)
              )
              [strict]

rule mapUnion(mapWrap( M1:Map => M1[K2/K1] ), mapWrap( _:Map (K1:K |-> K2:K => .Map) ))
rule mapUnion(mapWrap(M1:Map), mapWrap(.Map)) => mapWrap(M1)

//@ Substracts fron the given map the keys found in the given set
syntax KItem ::=  mapDiff(
                K,  //mapWrap(Map)
                K   //setWrap(Set)
              )
              [strict]

rule mapDiff( mapWrap( (Key:K |-> _ => .Map) _), setWrap( (SetItem(Key) => .Set) _) )

rule mapDiff( mapWrap( MyMap:Map ), setWrap( (SetItem(Key:K) => .Set) _) )
when
    notBool Key in keys(MyMap)

rule mapDiff(mapWrap( MyMap:Map ), setWrap(.Set)) => mapWrap(MyMap)

syntax KItem ::= isEmpty( Map )   [function]
rule isEmpty(.Map) => true

/*@A wrapper for sets, similar to the one for maps.*/
syntax KResult ::= setWrap ( Set )

/*The union of two sets. Arguments are of the form setWrap(Set).*/
syntax KItem ::=  setUnion (
                K,  //setWrap(Set)
                K   //setWrap(Set)
              )
              [strict]

rule setUnion(setWrap( S1:Set (. => SetItem(K)) ), setWrap( S2:Set (SetItem(K:K) => .) ))
when
    notBool(K in S1)
rule setUnion(setWrap( S1:Set SetItem(K) ), setWrap( S2:Set (SetItem(K:K) => .) ))
rule setUnion(setWrap(S1:Set), setWrap(.Set)) => setWrap(S1)

syntax Set ::= getSet ( K )           [function]
rule getSet(setWrap(S1:Set)) => S1

/*@ the concatenation of two kr[KList] items */
syntax KItem ::= klistConcat ( KRListWrap, KRListWrap ) [strict]
rule klistConcat(kr[KL1:KList], kr[KL2:KList]) => kr[KL1,,KL2]

//@ Counts the number of elements in the KList list. Evaluates to an Int.
syntax KItem ::= length ( KListWrap )                                   [function]
           | length ( Int, KListWrap )                              [function]

syntax KItem ::= getLastKListElement( KListWrap )                       [function]
rule getLastKListElement([_,, K:K]) => K

rule length([Ks:KList]) => length(0, [Ks])
rule length(I:Int, [K:K,, Ks:KList]) => length(I +Int 1, [Ks])
rule length(I:Int, [.KList]) => I

/*@ \subsection{ClassType functions} */

//@ Converts a fully qualified class type into a simple name (Id)
syntax KItem ::= getSimpleName ( ClassType )                  [function]
rule getSimpleName(class ClassId:Id)
    => String2Id(trimHead(
      Id2String(ClassId),
      rfindString(Id2String(ClassId), ".", lengthString(Id2String(ClassId))) +Int 1
    ))

/*@ \subsection{Identifiers}*/

// 'Id(Str:String)

/*@Convert the AST representation of an Id into a K Id.*/
rule 'Id(Str:String) => String2Id(Str)                [structural, anywhere]

/*@ \subsection{Other auxiliary constructs} */

/*@ \texttt{Generic guard.}
    A generic computational guard (should be builtin): it allows the computation to continue only if a prefix
    guard evaluates to true.
*/
syntax KItem ::= "true?"
rule true::bool ~> true? => .  [structural]

//@ \subsection{Definition-wide rules}

/*@ Represent a parser form for a sequence of terms. Is desugared into the pretty form [...]*/
syntax KLabel ::= "'ListWrap"
rule 'ListWrap(Ks:KList) => [Ks]                  [structural, anywhere]
//todo: both 'KListWrap and 'ListWrap are associted with the same production, so how to get rid of it
syntax KListWrap ::= "[" KList "]" [klabel('KListWrap), latex(\terminal{[} {#1} \terminal{]})]

//@ Sequence of terms and of any other statements. The first term is moved to the top of computation.
rule [S1:K,, Stmts:KList] => S1 ~> [Stmts]        [structural]
rule [.KList] => .K                               [structural]

//@ A wrapper over an arbitrary KList, wrapper being of type KResult.
syntax KRListWrap ::= "kr" "[" KList "]"          [latex(\terminal{kr[} {#1} \terminal{]})]
syntax KResult ::= KRListWrap

endmodule
