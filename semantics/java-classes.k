require "java-core.k"
require "java-process-type-names.k"
require "java-subtyping.k"
require "java-process-classes.k"
require "java-expressions.k"
require "java-statements.k"
require "java-arrays.k"
require "java-static-init.k"
require "java-var-lookup.k"

module JAVA-CLASSES
    imports JAVA-CORE
    imports JAVA-PROCESS-TYPE-NAMES
    imports JAVA-SUBTYPING
    imports JAVA-PROCESS-CLASSES
    imports JAVA-EXPRESSIONS
    imports JAVA-STATEMENTS
    imports JAVA-ARRAYS
    imports JAVA-STATIC-INIT
    imports JAVA-VAR-LOOKUP

/*@ \section{Object and method closures}
The only change to untyped KOOL's values is that closures are now typed
(their last argument holds their type). */

//@ \subsection{Type labels}
//@Here we rewrite java type ast into simple types

//Hapens during process-imports sub-phase. This is of course an approximation.
rule [TypeNameInProcessCompUnitsPhase]:
    <k> 'TypeName(X:Id) => noValue ...</k>
    <computationPhase> ProcessCompUnitsPhase </computationPhase>

rule [TypeNameInProcessClassDecsPhaseTop]:
    <k> 'TypeName(X:Id) => Class ...</k>
    <computationPhase> ProcessClassDecsPhase </computationPhase>
    <cuClass> CuClass:ClassType </cuClass>
    <classType> CuClass </classType>
    <enclosingClass> noClass </enclosingClass>
    <cuImports>... X |-> Class:ClassType ...</cuImports>

rule [TypeNameInProcessClassDecsPhaseTopFail]:
    <k> 'TypeName(X:Id) => noValue ...</k>
    <computationPhase> ProcessClassDecsPhase </computationPhase>
    <cuClass> CuClass:ClassType </cuClass>
    <classType> CuClass </classType>
    <enclosingClass> noClass </enclosingClass>
    <cuImports> Imp:Map </cuImports>
when notBool X in keys(Imp)

rule [TypeNameInProcessClassDecsPhaseInner]:
    <k> 'TypeName(X:Id) => Class ...</k>
    <computationPhase> ProcessClassDecsPhase </computationPhase>
    <cuClass> CuClass:ClassType </cuClass>
    <class>
      <classType> CuClass </classType>
      <enclosingClass> class Outer </enclosingClass>
      ...
    </class>
    <class>
      <classType> class Outer </classType>
      <imports>... X |-> Class:ClassType ...</imports>
      ...
    </class>

rule [TypeNameInProcessClassDecsPhaseInnerFail]:
    <k> 'TypeName(X:Id) => noValue ...</k>
    <computationPhase> ProcessClassDecsPhase </computationPhase>
    <cuClass> CuClass:ClassType </cuClass>
    <class>
      <classType> CuClass </classType>
      <enclosingClass> class Outer </enclosingClass>
      ...
    </class>
    <class>
      <classType> class Outer </classType>
      <imports> Imp:Map </imports>
      ...
    </class>
when notBool X in keys(Imp)

rule [TypeNameInProcessClassesPhase]:
    <k> 'TypeName(X:Id) => Class ...</k>
    <computationPhase> ProcessClassesPhase </computationPhase>
    <cuClass> CuClass:ClassType </cuClass>
    <classType> CuClass </classType>
    <imports>... X |-> Class:ClassType ...</imports>

rule [TypeNameInProcessClassesPhaseFail]:
    <k> 'TypeName(X:Id) => noValue ...</k>
    <computationPhase> ProcessClassesPhase </computationPhase>
    <cuClass> CuClass:ClassType </cuClass>
    <classType> CuClass </classType>
    <imports> Imp:Map </imports>
when
    notBool (X in keys(Imp))

//@ \subsection{Auxiliary operations}

//@ \texttt{typeOf and toString}

rule toString(objectClosure(I:Int, Obj:Bag) :: T:Type)
    =>  'Invoke(
          'MethodName(objectClosure(I, Obj) :: T,, String2Id("toString")),,
          'ListWrap(.KList)
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

//resolve new instance expression parameter values
context 'NewInstance(_:K,,_:K,, 'ListWrap(_,,HOLE,,_),, _)::_

rule [NewInstance]:
    <k>
      'NewInstance(
        _:K,,
        Class:ClassType,,
        'ListWrap( Vals:KList ),,
        _:K
      )::Class
      => staticInit(Class)
        ~> create(Class)
        ~> storeObj
        ~> restoreEnvObjContext(Env, Obj, CT)
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
    <contextType> CT:ContextType </contextType>
    <nextLoc> L:Int => L +Int 1 </nextLoc>
when isKResult(Vals)

syntax K ::= "create" "(" ClassType ")"

rule [create]:
    <k>
      create(Class:ClassType)
      => create(BaseClass) ~> setCrntClass(Class) ~> env(StaticEnv) ~> S ~> addEnvLayer
      ...
    </k>
    <classType> Class </classType>
    <extends> BaseClass:ClassType </extends>
    <fieldDecs> S:K </fieldDecs>
    <staticEnv> StaticEnv:Map </staticEnv>
        [structural]

rule [createEmptyDiscard]:
    <k> create( noClass ) => . ...</k> [structural]

syntax K ::= "setCrntClass" "(" ClassType ")"

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

syntax K ::= "invokeConstr" "(" Int "," ClassType "," KList ")"

rule [invokeConstr]:
    <k>
      invokeConstr(OL:Int, Class:ClassType, Vals:KList)
      => 'ExprStm('Invoke(
            'Method('MethodName( lookup(OL)::T,, getConsName(Class) )),,
            'ListWrap( Vals )
          ))
      ...
    </k>
    <store>... OL |-> _::T:Type ...</store>
when isKResult(Vals)

/*@ \subsection{Instance Of}
Like in untyped KOOL. */

context 'InstanceOf(HOLE,,_)::_

rule [InstanceOf]:
    'InstanceOf(V:RawVal::_,, RT2:RefType) :: bool
    =>  'LazyAnd((V =/=K null),, subtype(typeOf(V), RT2))::bool

/*@ \subsection{Cast}
Unlike in untyped KOOL, in typed KOOL we actually check that the object
can indeed be cast to the claimed type. */

rule [CastRef]:
    <k>
      castImpl(RT1:RefType, V:RawVal :: RT2:RefType)::RT1
      =>  'If(
            subtype(typeOf(V), RT1),,
            (V::RT1),,
            'Throw('NewInstance(
                    'None(.KList),,
                    (class String2Id("java.lang.ClassCastException")),,
                    'ListWrap( 'Plus('Plus(toString(typeOf(V)),, " cannot be cast to ")::rtString,,
                        toString(RT1))::rtString ),,
                    'None(.KList)
                  ))
          )
      ...
    </k>

endmodule
