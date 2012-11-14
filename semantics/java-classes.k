module JAVA-CLASSES
    imports JAVA-CORE
    imports JAVA-PROCESS-CLASSES
    imports JAVA-EXPRESSIONS
    imports JAVA-STATEMENTS
    imports JAVA-ARRAYS
    imports JAVA-STATIC-INIT

//@ \subsection{Unused Labels}
syntax KLabel ::= "'TypeImportOnDemandDec" | "'PackageName" | "'Native"

//@ \section{aux constructs defined in other modules}

//typed version of lookup
syntax K ::= "typedLookup" "(" Int ")"

/*@ \section{Object and method closures}
The only change to untyped KOOL's values is that closures are now typed
(their last argument holds their type). */

//@ \subsection{Type labels}
//@Here we rewrite java type ast into simple types

rule 'TypeName(X:Id) => class X  [structural, anywhere]

rule
    class X:Id => rtString
when
    Id2String(X) ==String "String"
        [structural, anywhere]

rule 'ClassOrInterfaceType(T:Type,, _) => T [structural, anywhere]
rule 'InterfaceType(T:Type,, _) => T        [structural, anywhere]

//@ \subsection{Auxiliary operations}

//@ \texttt{bindto} also checks the well-formedness of the method parameters

syntax K ::= "bindto" List{K}
                  "," List{K}  //List{KResult}

rule [bindto]:
    <k>
      (. => 'ExprStm('Assign('ExprName(X),,TV:TypedVal)))
      ~> bindto( ('Param(_,, T:Type,, X:Id) => .List{K}),, _:List{K} ),
          ( (TV => .List{K}),, _:List{K} )
      ...
    </k>
    <env> Env:Map => Env[L/X] </env>
    <store>... . => L |-> undefined :: T ...</store>
    <nextLoc> L:Int => L +Int 1 </nextLoc>

rule [bindtoEmpty]:
    <k> bindto .List{K},.List{K} => . ...</k>
        [structural]

//@ \texttt{typeOf and toString}

rule typeOf('Param(_:K,,K:K,,_)) => K [anywhere]

rule toString(objectClosure(I:Int, Obj:Bag) :: T:Type)
    =>  'Invoke(
          'MethodName(objectClosure(I, Obj) :: T,, String2Id("toString")),,
          'ListWrap(.List{K})
        )
        [anywhere]

/*@ \subsection{Changes to SIMPLE Semantics}
We extend/change the semantics of several SIMPLE constructs in order
to take advantage of the richer KOOL semantic infrastructure and thus
get more from the existing SIMPLE constructs. */

//@ \texttt{typeOf for raw values of reference type}
rule typeOf(Str:String) => rtString [anywhere]
rule typeOf(null) => nullType [anywhere]
rule typeOf(objectClosure(_, (<envStack>ListItem((Class:Id, _)) _</envStack>)))
     => class Class [anywhere]
rule typeOf(arrayRef( arrayOf T:Type, _, _)) => arrayOf T [anywhere]

/*@ \subsection{New}
The semantics of \texttt{new} in dynamically typed KOOL is also
similar to that in untyped KOOL, the main difference being the
management of the return types.  Indeed, when a new object is created
we also have to stack the current type in the \textsf{return} cell in
order to be recovered after the creation of the new object.  Only the
first rule below needs to be changed; the others are identical to
those in untyped KOOL. */

context 'NewInstance(_:K,,_:K,, 'ListWrap(_,,HOLE,,_),, _)

rule [NewInstance]:
    <k>
      'NewInstance(
        _:K,,
        class Class:Id,,
        'ListWrap( Vals:List{K} ),,
        _:K
      )
      => staticInit(Class)
        ~> create(Class)
        ~> storeObj
        ~> restoreEnvAndObj(Env, Obj)
        ~> invokeConstr(L, Class, Vals)
        ~> typedLookup(L)
      ...
    </k>
    <env> Env:Map => . </env>
    <crntObj>
      Obj:Bag
      =>  <crntClass> .K </crntClass>
          <envStack> .List </envStack>
          <location> L </location>
    </crntObj>
    <nextLoc> L:Int => L +Int 1 </nextLoc>
when isKResult(Vals)

syntax K ::= "create" "(" K ")"

rule [create]:
    <k>
      create(Class:Id)
      => create(BaseClassK) ~> setCrntClass(Class) ~> env(StaticEnv) ~> S ~> addEnvLayer
      ...
    </k>
    <className> Class </className>
    <extends> BaseClassK:K </extends>
    <fieldDecs> S:K </fieldDecs>
    <staticEnv> StaticEnv:Map </staticEnv>
        [structural]

rule [createEmptyDiscard]:
    <k> create( .K ) => . ...</k> [structural]

syntax K ::= "setCrntClass" "(" Id ")"

rule [setCrntClass]:
    <k> setCrntClass(Class:Id) => . ...</k>
    <crntClass> _ => Class </crntClass>
        [structural]

syntax K ::= "addEnvLayer"

//The content of an <envStack> ListItem() </envStack>
syntax K ::= "(" Id "," BagItem ")"

rule [addEnvLayer]:
    <k> addEnvLayer => . ...</k>
    <env> Env:Map => . </env>
    <crntClass> Class:Id </crntClass>
    <envStack> . => ListItem((Class, <env>Env</env>)) ...</envStack>
        [structural]

syntax K ::= "storeObj"

rule [storeObj]:
    <k> storeObj => . ...</k>
    <crntObj>
      Obj:Bag
      <crntClass> Class:Id </crntClass>
      <location> L:Int </location>
    </crntObj>
    <store>
      ...
      . => L |-> objectClosure(L, Obj) :: class Class
      ...
    </store>

syntax K ::= "invokeConstr" "(" Int "," Id "," List{K} ")"

rule [invokeConstr]:
    invokeConstr(OL:Int, ClassName:Id, Vals:List{K})
    => 'ExprStm('Invoke(
          'Method('MethodName( typedLookup(OL),, getConsName(ClassName) )),,
          'ListWrap( Vals )
        ))
when isKResult(Vals)

/*@ \subsection{Instance Of}
Like in untyped KOOL. */

syntax KLabel ::= "'InstanceOf" [seqstrict]

rule [InstanceOf]:
    'InstanceOf(V:RawVal::_,, RT2:RefType)
    =>  #if V =/=K null
          #then subtype(typeOf(V), RT2)
          #else false::bool
        #fi

/*@ \subsection{Cast}
Unlike in untyped KOOL, in typed KOOL we actually check that the object
can indeed be cast to the claimed type. */

syntax KLabel ::= "'CastRef"
rule 'CastRef(K1:K,, K2:K) => castImpl(K1,K2)   [structural]

rule [CastRef]:
    <k>
      castImpl(RT1:RefType, V:RawVal :: RT2:RefType)
      =>  'If(
            subtype(typeOf(V), RT1),,
            (V::RT1),,
            'Throw('NewInstance(
                    'None(.List{K}),,
                    'class_(String2Id("ClassCastException")),,
                    'ListWrap( 'Plus('Plus(toString(typeOf(V)),, " cannot be cast to "::rtString),,
                        toString(RT1)) ),,
                    'None(.List{K})
                  ))
          )
      ...
    </k>

endmodule
