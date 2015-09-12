module CORE-FUNCTIONS
    imports CORE-SORTS
    imports AUX-STRINGS
    imports JAVA-SYNTAX

//@ \subsection{Shortcuts for the most frequently used classes within the semantics}

syntax ClassType ::= "classObject"
    [function, latex(\terminal{Object})]
rule classObject => class String2Id("java.lang.Object")

syntax ClassType ::= "classString"
    [function, latex(\terminal{String})]
rule classString => class String2Id("java.lang.String")

syntax ClassType ::= "classNullPointerException"
    [function, latex(\terminal{NullPointerException})]
rule classNullPointerException => class String2Id("java.lang.NullPointerException")

syntax ClassType ::= "classArrayImpl"                   [function]
rule classArrayImpl => class String2Id("java.lang.ArrayImpl")

//@ \subsubsection{Computation terms produced during elaboration}
/*@ These auxiliary terms functions that should be threated as expressions in the elaboration phase.
*/
syntax Exp ::= LHS
syntax LHS ::= AuxTermExp
/*@ Wrapper of a statement followed by an expression, to be used in a place where an expression is expected,
such as an anonymous class declaration. Is typed with the type of the expression.
At runtime is rewritten into the statement, that should evaluate into .K, followed by the expression,
that should evaluate to value.*/
syntax AuxTermExp ::= stmtAndExp ( K, K )

syntax AuxTermExp ::= cast ( Type, K ) [strict] //strictness on 1-st arcument - for runtime produced terms

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
syntax KItem ::= toTypedVal ( RawVal )                                               [function]
rule toTypedVal(I:Int) => I :: int                                                  [structural]
rule toTypedVal(B:Bool) => B :: bool                                                [structural]
rule toTypedVal(Str:String) => Str :: classString                                   [structural]
rule toTypedVal(null) => null :: nullType                                           [structural]
rule toTypedVal( objectRef(OL:Int, Class:ClassType) )
    => objectRef(OL:Int, Class:ClassType) :: Class                                  [structural]

rule toTypedVal(arrayRef(T:Type, L:Int, M:Int)) => arrayRef(T, L, M) :: T           [structural]
rule toTypedVal(F:Float) => F :: float                                              [structural]

//@ Converts a KList of terms to Types. Uses typeOf underneath.todo repitition
syntax KItem ::= getTypes ( Exps )              [function]     // a list of source expressions
               | getTypes ( Types, Exps )       [function]

rule getTypes( Ps:Exps ) => getTypes(types(.KList), Ps)
rule getTypes( types(Ts:KList), (T:Exp, Ps:Exps) ) => getTypes( types(Ts,,typeOf(T)), Ps )
rule getTypes( types(Ts:KList), .Exps) => types(Ts)

//@ Converts a TypedVals term to Types. Uses typeOf underneath.
syntax KItem ::= getTypes ( TypedVals )          [function]    // a list of source values
               | getTypes ( Types, TypedVals )   [function]

rule getTypes( TVs:TypedVals) => getTypes(types(.KList), TVs)
rule getTypes( types(Ts:KList), (_ :: T:Type, TVs:TypedVals) ) => getTypes( types(Ts,,T), TVs )
rule getTypes( types(Ts:KList), .TypedVals) => types(Ts)

syntax KItem ::= getTypes ( Params )            [function]
               | getTypes ( Types , Params )    [function]

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
syntax MKR ::= mapWrap ( Map )

/*@ The union of two maps. Arguments are of the form mapWrap(Map). In this operation, elements of the second map
    overwrite elements of the first map if they collide.
*/
syntax KItem ::=  mapUnion (
                K,  //mapWrap(Map)
                K   //mapWrap(Map)
              )
              [strict]

rule mapUnion(mapWrap( M1:Map => M1[K1 <- K2] ), mapWrap( _:Map (K1:K |-> K2:K => .Map) ))
rule mapUnion(mapWrap(M1:Map), mapWrap(.Map)) => mapWrap(M1)

//@ Substracts from the given map the value given (match is on the value), may cause infinite loop if not used in the right place
syntax KItem ::= removeMapItemsByValue (Map,K)             [function]
               | removeMapItemsByValue (Map,K,Map)         [function]
               | removeMapItemsByValue (K,K,Map,K,Map)     [function]

rule removeMapItemsByValue(M:Map, V:K) => removeMapItemsByValue(M, V, .Map)
rule removeMapItemsByValue((Key:K |-> Value:K) Remains:Map, V:K, M:Map) => removeMapItemsByValue(Key, Value, Remains, V, M)
rule removeMapItemsByValue(Key:K, V, Remains:Map, V:K, M:Map) => removeMapItemsByValue(Remains, V, M)
rule removeMapItemsByValue(Key:K, Value:K, Remains:Map, V:K, M:Map) => removeMapItemsByValue(Remains, V, M (Key |-> Value))
when Value =/=K V
rule removeMapItemsByValue(.Map, V:K, M:Map) => M

//todo how to realise non-determinism: remove an arbitrary item with that value
syntax KItem ::= removeOneMapItemByValue (Map,K)             [function]
               | removeOneMapItemByValue (Map,K,Map)         [function]
               | removeOneMapItemByValue (K,K,Map,K,Map)     [function]

rule removeOneMapItemByValue(M:Map, V:K) => removeOneMapItemByValue(M, V, .Map)
rule removeOneMapItemByValue((Key:K |-> Value:K) Remains:Map, V:K, M:Map) => removeOneMapItemByValue(Key, Value, Remains, V, M)
rule removeOneMapItemByValue(Key:K, V, Remains:Map, V:K, M:Map) => Remains M
rule removeOneMapItemByValue(Key:K, Value:K, Remains:Map, V:K, M:Map) => removeOneMapItemByValue(Remains, V, M (Key |-> Value))
when Value =/=K V
rule removeOneMapItemByValue(.Map, V:K, M:Map) => M

//@ Find map items by partial key, not used now
syntax KItem ::= mapItemsByPartialKey (Map,K)             [function]
               | mapItemsByPartialKey (Map,K,Map)         [function]
               | mapItemsByPartialKey (K,K,Map,K,Map)     [function]

rule mapItemsByPartialKey(M:Map, V:K) => mapItemsByPartialKey(M, V, .Map)
rule mapItemsByPartialKey((Key:K |-> Value:K) Remains:Map, V:K, M:Map) => mapItemsByPartialKey(Key, Value, Remains, V, M)
rule mapItemsByPartialKey(sig(I:Id, T:Types), Value:K, Remains:Map, I, M:Map)
     => mapItemsByPartialKey(Remains, I, M (sig(I,T) |-> Value))
rule mapItemsByPartialKey(sig(I:Id, T:Types), Value:K, Remains:Map, V:K, M:Map) => mapItemsByPartialKey(Remains, V, M)
when I =/=K V
rule mapItemsByPartialKey(.Map, V:K, M:Map) => M

syntax KItem ::= isEmpty( Map )   [function]
rule isEmpty(.Map) => true
rule isEmpty(_) => false            [owise]

/*@A wrapper for sets, similar to the one for maps.*/
syntax MKR ::= setWrap ( Set )

/*The union of two sets. Arguments are of the form setWrap(Set).*/
syntax KItem ::=  setUnion (
                K,  //setWrap(Set)
                K   //setWrap(Set)
              )
              [strict]
rule setUnion(setWrap(S1:Set), setWrap(S2:Set)) => setWrap(S1 S2)

syntax Set ::= getSet ( K )           [function]
rule getSet(setWrap(S1:Set)) => S1

/*@ the concatenation of two kr[KList] items */
syntax KItem ::= klistConcat ( KRListWrap, KRListWrap ) [strict]
rule klistConcat(kr[KL1:KList], kr[KL2:KList]) => kr[KL1,,KL2]

//@ Counts the number of elements in the KList list. Evaluates to an Int.
syntax KItem ::= length ( KListWrap )                                   [function]
               | length ( Int, KListWrap )                              [function]

rule length([Ks:KList]) => length(0, [Ks])
rule length(I:Int, [K:K,, Ks:KList]) => length(I +Int 1, [Ks])
rule length(I:Int, [.KList]) => I

//syntax KItem ::= getFirstKListElements( KListWrap )                     [function]
//               | getFirstKListElements( KListWrap, KListWrap )          [function]
//
//rule getFirstKListElements([Kl:KList]) => getFirstKListElements([Kl],,[.KList])
//rule getFirstKListElements([Ho:K,, Hd:K,, Tl:KList], [Kl:KList]) => getFirstKListElements([Hd,,Tl],[Kl,,Ho])
//rule getFirstKListElements([Hd:K,, .KList],, [Kl:KList]) => Kl
//rule getFirstKListElements([.KList],, [.KList]) => .KList

syntax KItem ::= getLastKListElement( KListWrap )                       [function]

rule getLastKListElement([Ho:K,, Hd:K,, Tl:KList]) => getLastKListElement([Hd,,Tl])
rule getLastKListElement([Hd:K,, .KList]) => Hd
rule getLastKListElement([.KList]) => .K

syntax Params ::= addElementToParamsEnd (Params, Param) [function]
rule addElementToParamsEnd(.Params, P:Param) => P,.Params
rule addElementToParamsEnd((Hd:Param, Tl:Params), P:Param) => Hd,addElementToParamsEnd(Tl,P)

syntax ClassBodyDecList ::= addElementToClassBodyDecListEnd (ClassBodyDecList, ClassBodyDec) [function]
rule addElementToClassBodyDecListEnd(.ClassBodyDecList, P:K) => 'ClassBodyDecList(P,, .ClassBodyDecList)
rule addElementToClassBodyDecListEnd('ClassBodyDecList(Hd:K,,Tl:K), P:K) => 'ClassBodyDecList(Hd,, addElementToClassBodyDecListEnd(Tl,P))

syntax ClassBodyDecList ::= appendClassBodyDecList(ClassBodyDecList, ClassBodyDecList) [function]
rule appendClassBodyDecList(CBDs:ClassBodyDecList, (Hd:ClassBodyDec Tl:ClassBodyDecList)) =>
     appendClassBodyDecList(addElementToClassBodyDecListEnd(CBDs, Hd), Tl)
rule appendClassBodyDecList(CBDs:ClassBodyDecList, .ClassBodyDecList) => CBDs

syntax BlockStmList ::= addElementToBlockStmListEnd (BlockStmList, BlockStmt) [function]
rule addElementToBlockStmListEnd(.BlockStmList, P:K) => 'BlockStmList(P,, .BlockStmList)
rule addElementToBlockStmListEnd('BlockStmList(Hd:K,,Tl:K), P:K) => 'BlockStmList(Hd,, addElementToBlockStmListEnd(Tl,P))

syntax Exps ::= addElementToExpsEnd (Exps, Exp) [function]
rule addElementToExpsEnd(.Exps, P:Exp) => P,.Exps
rule addElementToExpsEnd((Hd:Exp, Tl:Exps), P:Exp) => Hd,addElementToExpsEnd(Tl,P)

syntax Exps ::= appendExps(Exps, Exps) [function]
rule appendExps(AExps:Exps, (Hd:Exp, Tl:Exps)) => appendExps(addElementToExpsEnd(AExps, Hd), Tl)
rule appendExps(AExps:Exps, .Exps) => AExps

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
syntax KListWrap ::= "[" KList "]" [klabel('KListWrap), latex(\terminal{[} {#1} \terminal{]})]


//@ Sequence of terms and of any other statements. The first term is moved to the top of computation.
rule [S1:K,, Stmts:KList] => S1 ~> [Stmts]        [structural]
rule [.KList] => .K                               [structural]

rule 'ClassBodyDecList(Hd:K,,Tl:K) => Hd ~> Tl
rule .ClassBodyDecList => .

//@ A wrapper over an arbitrary KList, wrapper being of type KResult.
syntax KRListWrap ::= "kr" "[" KList "]"          [latex(\terminal{kr[} {#1} \terminal{]})]
syntax MKR ::= KRListWrap

endmodule
