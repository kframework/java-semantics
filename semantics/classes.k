require "core.k"
require "process-type-names.k"
require "subtyping.k"
require "process-classes.k"
require "expressions.k"
require "statements.k"
require "arrays.k"
require "static-init.k"
require "var-lookup.k"

module CLASSES
    imports CORE
    imports PROCESS-TYPE-NAMES
    imports SUBTYPING
    imports PROCESS-CLASSES
    imports EXPRESSIONS
    imports STATEMENTS
    imports ARRAYS
    imports STATIC-INIT
    imports VAR-LOOKUP

/*@ \section{Object and method closures}
The only change to untyped KOOL's values is that closures are now typed
(their last argument holds their type). */

//@ \subsection{Type labels}
//@Here we rewrite java type ast into simple types

//Happens during process-imports sub-phase. This is of course an approximation.
rule [TypeNameInProcessCompUnitsPhase]:
    <k> 'TypeName(X:Id) => noValue ...</k>
    <computationPhase> ProcessCompUnitsPhase </computationPhase>

//@ \subsection{Auxiliary operations}

//@ \texttt{typeOf and toString}

rule toString(objectClosure(I:Int, Obj:List, ObjLocalClassesEnv:Map) :: T:Type)
    =>  'Invoke(
          'MethodName(objectClosure(I, Obj, ObjLocalClassesEnv) :: T,, String2Id("toString")),,
          'ListWrap(.KList)
        )
        [anywhere]

/*@ \subsection{Changes to SIMPLE Semantics}
We extend/change the semantics of several SIMPLE constructs in order
to take advantage of the richer KOOL semantic infrastructure and thus
get more from the existing SIMPLE constructs. */

//@ \texttt{typeOf for raw values of reference type}
rule typeOf(Str:String) => rtString
rule typeOf(null) => nullType
rule typeOf(objectClosure(_, ListItem(el(Class:ClassType, _,_,_)) _:List, _))
     => Class
rule typeOf(arrayRef( arrayOf T:Type, _, _)) => arrayOf T

/*@ \subsection{New}
The semantics of \texttt{new} in dynamically typed KOOL is also
similar to that in untyped KOOL, the main difference being the
management of the return types.  Indeed, when a new object is created
we also have to stack the current type in the \textsf{return} cell in
order to be recovered after the creation of the new object.  Only the
first rule below needs to be changed; the others are identical to
those in untyped KOOL. */

//resolve new instance qualifier
context 'QNewInstance(HOLE,, _:KList)::_

//resolve new instance expression parameter values
//todo test the expression order using state space search.
context 'QNewInstance(_:KResult,,_:K,,_:K,,_:K,, 'ListWrap(_,,HOLE,,_),, _)::_

rule [QNewInstance]:
    <k>
      'QNewInstance(
        EnclosingObj:KResult,,
        _:K,,
        Class:ClassType,,
        _:K,,
        'ListWrap( Vals:KList ),,
        _:K
      )::Class
      => staticInit(Class)
        ~> create(Class)
        ~> restoreEnvObjContext(OldEnvGroup, Obj, CT)
        ~> setOuterLocalEnvForHierarchy(L, Class)
        ~> setObjLocalClassesEnv(L)
        ~> invokeConstr(L, Class, Vals, EnclosingObj)
        ~> typedLookup(L)
      ...
    </k>
    <envGroup>
      OldEnvGroup:Bag
      => <env> .Map </env> <localClassesEnv> .Map </localClassesEnv>
    </envGroup>
    <crntObj>
      Obj:Bag
      =>  <crntClass> .K </crntClass>
          <location> L </location>
    </crntObj>
    <contextType> CT:ContextType </contextType>
    <store>
      ...
      . => L |-> objectClosure(L, .List, .Map) :: Class
      ...
    </store>
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
    <location> L:Int </location>
    <store>
      ...
      L |-> objectClosure(L,
          ( . => ListItem(el(Class, <env>Env</env>, noValue, .Map)) ) _:List, _)::_
      ...
    </store>
        [structural]

syntax K ::= "invokeConstr" "(" Int       //OL - object location
                            "," ClassType //The target class
                            "," KList     //Arguments, evaluated
                            "," K         //Encloser - the typed enclosing object. if any, or noValue
                            ")"

//This rule cannot be simplified - we have to alter the newly created object from the store.
//The context inside <control> is the context that called "new Obj()" expression.
//Constructor calls are elaborated during execution phase
rule [invokeConstr]:
    invokeConstr(OL:Int, Class:ClassType, Vals:KList, Encloser:KResult)
    => setEncloser(lookup(OL)::Class, Class, Encloser)
    ~> 'ExprStm('Invoke(
          'Method('MethodName( lookup(OL)::Class,, getConsName(Class) )),,
          'ListWrap( Vals )
        ))

rule [setEncloser-value]:
    <k>
      setEncloser(objectClosure(OL:Int, _,_)::_, Class:ClassType, EncloserRV:RawVal::_) => .
      ...
    </k>
    <store>
      ...
      OL |->
        objectClosure(_, _:List ListItem(el(Class,_, _ => EncloserRV::EncloserClass, _)) _:List, _)::_
      ...
    </store>
    <classType> Class </classType>
    <enclosingClass> EncloserClass:ClassType </enclosingClass>

rule [setEncloser-noValue]:
    setEncloser(_,_, noValue) => .

//Set the outerLocalEnv for all layers of the <crntObj>, from the cell <localClassesEnv>,
//for the given class and its bases
syntax K ::= "setOuterLocalEnvForHierarchy" "(" Int "," ClassType ")"

//Set outerLocalEnv for precisely the class layer Class. If sourceCalss is registered in
//<localClassesEnv>, take from there.
           | "setOuterLocalEnvForClass" "(" Int       //OL - object location
                                        "," ClassType //Class - the layer for which we aim to set outerLocalEnv
                                        "," ClassType //SourceClass - the candidate source class
                                                      //registered in <localClassesEnv>
                                        ")"

rule [setOuterLocalEnvForHierarchy]:
    <k>
      (. => setOuterLocalEnvForClass(OL, Class, Class))
      ~> setOuterLocalEnvForHierarchy(OL:Int, Class:ClassType => BaseClass)
      ...
    </k>
    <classType> Class </classType>
    <extends> BaseClass:ClassType </extends>

rule setOuterLocalEnvForHierarchy(_, noClass) => .

//if SourceClass is registered in <localClassesEnv> we will take its corresponding Env, and set is
//as outerLocalEnv for the layer Class.
rule [setOuterLocalEnvForClass-found]:
    <k> setOuterLocalEnvForClass(OL:Int, Class:ClassType, SourceClass:ClassType) => . ...</k>
    <store>
      ...
      OL |->
        objectClosure(_, _:List ListItem(el(Class,_,_, _ => CurrentEnv)) _:List, _)::_
      ...
    </store>
    <localClassesEnv>... SourceClass |-> mapWrap(CurrentEnv:Map) ...</localClassesEnv>

//If SourceClass is not registered in <localClassesEnv>, it is not a direct local class.
//We attempt to replace it with its enclosing class,
//until evenually we will reach a local class.
rule [setOuterLocalEnvForClass-not-found]:
    <k> setOuterLocalEnvForClass(OL:Int, Class:ClassType, SourceClass:ClassType => SourceEnclosingClass) ...</k>
    <localClassesEnv> LocalClassesEnv:Map </localClassesEnv>
    <classType> SourceClass </classType>
    <enclosingClass> SourceEnclosingClass:ClassType </enclosingClass>
when
    notBool SourceClass in keys(LocalClassesEnv)

//Otherwise we will reach noClass, and the whole term will be discarded.
rule setOuterLocalEnvForClass(_,_, noClass) => .

//Set the content of <localClassesEnv> - in the 3rd argument of objectClosure().
syntax K ::= "setObjLocalClassesEnv" "(" Int ")"

rule [setObjLocalClassesEnv]:
    <k> setObjLocalClassesEnv(OL:Int) => . ...</k>
    <store>
      ...
      OL |-> objectClosure(_,_, _ => LocalClassesEnv)::_
      ...
    </store>
    <localClassesEnv> LocalClassesEnv:Map </localClassesEnv>

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
