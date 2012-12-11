require "java-core.k"
require "java-subtyping.k"
require "java-process-classes.k"
require "java-expressions.k"
require "java-statements.k"
require "java-arrays.k"
require "java-static-init.k"
require "java-var-lookup.k"

module JAVA-CLASSES
    imports JAVA-CORE
    imports JAVA-SUBTYPING
    imports JAVA-PROCESS-CLASSES
    imports JAVA-EXPRESSIONS
    imports JAVA-STATEMENTS
    imports JAVA-ARRAYS
    imports JAVA-STATIC-INIT
    imports JAVA-VAR-LOOKUP

//@ \subsection{Unused Labels}
syntax KLabel ::= "'TypeImportOnDemandDec" | "'TypeImportDec"
                | "'PackageOrTypeName" | "'Native"

/*@ \section{Object and method closures}
The only change to untyped KOOL's values is that closures are now typed
(their last argument holds their type). */

//@ \subsection{Type labels}
//@Here we rewrite java type ast into simple types

rule 'ClassOrInterfaceType(TypeK:K,, _) => TypeK [structural]
rule 'InterfaceType(TypeK:K,, _) => TypeK        [structural]
rule 'ClassType(TypeK:K,, _) => TypeK            [structural]

rule [TypeName]:
    'TypeName(X:Id) => class X  [structural]

//ignore the qualifier of a type - for now
rule [TypeNameQualified]:
    'TypeName(_,, X:Id) => class X  [structural]

rule [rtString]:
    class X:Id => rtString
when
    Id2String(X) ==String "String"
        [structural]

//@ \subsection{Auxiliary operations}

//@ \texttt{bindto} also checks the well-formedness of the method parameters

syntax K ::= "bindto" List{K}
                  "," List{K}  //List{KResult}

rule [bindto]:
    <k>
      bindto paramImpl(T:Type, X:Id),, RestP:List{K}, TV:TypedVal,, RestV:List{K}
      => 'ExprStm('Assign('ExprName(X),,TV:TypedVal)) ~> bindto RestP, RestV
      ...
    </k>
    <env> Env:Map => Env[L/X] </env>
    <store>... . => L |-> undefined :: T ...</store>
    <nextLoc> L:Int => L +Int 1 </nextLoc>

rule [bindtoEmpty]:
    <k> bindto .List{K},.List{K} => . ...</k>
        [structural]

//@ \texttt{typeOf and toString}

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
rule typeOf(objectClosure(_, (<envStack>ListItem((Class:ClassType, _)) _</envStack>)))
     => Class [anywhere]
rule typeOf(arrayRef( arrayOf T:Type, _, _)) => arrayOf T [anywhere]

/*@ \subsection{New}
The semantics of \texttt{new} in dynamically typed KOOL is also
similar to that in untyped KOOL, the main difference being the
management of the return types.  Indeed, when a new object is created
we also have to stack the current type in the \textsf{return} cell in
order to be recovered after the creation of the new object.  Only the
first rule below needs to be changed; the others are identical to
those in untyped KOOL. */

//resolve new instance expression target type
context 'NewInstance(_:K,, HOLE,, _)

//resolve new instance expression parameter values
context 'NewInstance(_:K,,_:K,, 'ListWrap(_,,HOLE,,_),, _)

rule [NewInstance]:
    <k>
      'NewInstance(
        _:K,,
        Class:ClassType,,
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
      create(Class:ClassType)
      => create(BaseClassK) ~> setCrntClass(Class) ~> env(StaticEnv) ~> S ~> addEnvLayer
      ...
    </k>
    <classType> Class </classType>
    <extends> BaseClassK:K </extends>
    <fieldDecs> S:K </fieldDecs>
    <staticEnv> StaticEnv:Map </staticEnv>
        [structural]

rule [createEmptyDiscard]:
    <k> create( .K ) => . ...</k> [structural]

syntax K ::= "setCrntClass" "(" Id ")"

rule [setCrntClass]:
    <k> setCrntClass(Class:ClassType) => . ...</k>
    <crntClass> _ => Class </crntClass>
        [structural]

syntax K ::= "addEnvLayer"

rule [addEnvLayer]:
    <k> addEnvLayer => . ...</k>
    <env> Env:Map => . </env>
    <crntClass> Class:ClassType </crntClass>
    <envStack> . => ListItem((Class, <env>Env</env>)) ...</envStack>
        [structural]

syntax K ::= "storeObj"

rule [storeObj]:
    <k> storeObj => . ...</k>
    <crntObj>
      Obj:Bag
      <crntClass> Class:ClassType </crntClass>
      <location> L:Int </location>
    </crntObj>
    <store>
      ...
      . => L |-> objectClosure(L, Obj) :: Class
      ...
    </store>

syntax K ::= "invokeConstr" "(" Int "," ClassType "," List{K} ")"

rule [invokeConstr]:
    invokeConstr(OL:Int, Class:ClassType, Vals:List{K})
    => 'ExprStm('Invoke(
          'Method('MethodName( typedLookup(OL),, getConsName(Class) )),,
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
