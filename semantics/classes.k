require "core-sorts.k"
require "process-type-names.k"
require "subtyping.k"
require "process-class-members.k"
require "expressions.k"
require "statements.k"
require "arrays.k"
require "static-init.k"
require "var-lookup.k"

/*@ \section{Module CLASSES}
Object closures. The only change to untyped KOOL's values is that closures are now typed
(their last argument holds their type).
*/
module CLASSES
    imports CORE-SORTS
    imports PROCESS-TYPE-NAMES
    imports SUBTYPING
    imports PROCESS-CLASS-MEMBERS
    imports EXPRESSIONS
    imports STATEMENTS
    imports ARRAYS
    imports STATIC-INIT
    imports VAR-LOOKUP

/*@ \subsection{New instance creation}*/

//@ _:K,, Class:ClassType,, 'ListWrap(Args),, 'None(.KList)
syntax KLabel ::= "'NewInstance"

/*@Unpack 'NewInstance back into 'QNewInstance.
  The difference between desugaring and unpacking is that unpacking is an artificial procedure required to separate
  elaboration from execution. In the elaboration phase there is a opposite packing rule tht creates this construct.
*/
rule [NewInstance-to-QNewInstance-unpack]:
    'NewInstance(Arg1:K,, Class:ClassType,, ActualArgsList:K,, 'None(.KList))
    => 'QNewInstance(noValue,, Arg1,, Class,, 'None(.KList),, ActualArgsList,, 'None(.KList))

//@ Qual,, _:K,, Class,, _:K,, 'ListWrap(Args),, 'None(.KList)
syntax KLabel ::= "'QNewInstance"

//@Resolve new instance qualifier
context 'QNewInstance(HOLE,, _:KList)

//totest model check - test the arguments evaluation order
/*@ Resolve new instance expression parameter values
*/
context 'QNewInstance(_:KResult,,_:K,,_:K,,_:K,, 'ListWrap(_,,HOLE,,_),, _)

rule [QNewInstance-resolve-class]:
    'QNewInstance(_::QualT:ClassType,,_:K,, (Name:Id => getClassType(toPackage(QualT), Name)),,_:K,, _:K,, _)

/*@ Qualified new instance creation expression. Unqualified new expressions are rewritten into qualified ones by other
rules and also reach this point.*/
rule [QNewInstance]:
    <k>
      'QNewInstance(
        EnclosingObj:KResult,,
        _:K,,
        Class:ClassType,,
        _:K,,
        'ListWrap( Vals:KList ),,
        _:K
      )
      => staticInit(Class)
        ~> create(Class)
        ~> restoreMethContext(<envGroup> OldEnvGroup </envGroup> <crntObj> OldCrntObj </crntObj> RestMethContext)
        ~> setOuterLocalEnvForHierarchy(L, Class)
        ~> setObjLocalClassesEnv(L)
        ~> invokeConstr(L, Class, Vals, EnclosingObj)
        ~> typedLookup(L)
      ...
    </k>
    <methodContext>
      <envGroup>
        OldEnvGroup:Bag
        => <env> .Map </env> <localClassesEnv> .Map </localClassesEnv>
      </envGroup>
      <crntObj>
        OldCrntObj:Bag
        =>  <crntClass> .K </crntClass>
            <location> L </location>
      </crntObj>
      RestMethContext:Bag
    </methodContext>
    <store>
      ...
      . => L |-> objectClosure(L, .KList, .Map) :: Class
      ...
    </store>
    <nextLoc> L:Int => L +Int 1 </nextLoc>
when isKResult(Vals)

syntax K ::=  create ( ClassType )

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

rule [create-empty-discard]:
    create( noClass ) => .K
        [structural]

syntax K ::=  setCrntClass ( ClassType )

rule [setCrntClass]:
    <k> setCrntClass(Class:ClassType) => . ...</k>
    <crntClass> _ => Class </crntClass>
        [structural]

syntax K ::=  "addEnvLayer"

rule [addEnvLayer]:
    <k> addEnvLayer => . ...</k>
    <env> Env:Map => . </env>
    <crntClass> Class:ClassType </crntClass>
    <location> L:Int </location>
    <store>
      ...
      L |-> objectClosure(L,
          ( ( .KList => layer(Class, <env>Env</env>, noValue, .Map) ),, _:KList/*ObjLayers*/ ), _)::_
      ...
    </store>
        [structural]

syntax K ::=  invokeConstr (
                Int,        //OL - object location
                ClassType,  //The target class
                KList,      //Arguments, evaluated
                K           //EnclosingObj - the typed enclosing object, if any. Otherwise - noValue
              )

/*@ This rule cannot be simplified - we have to alter the newly created object from the store.
    The context inside <methodContext> is the context that called "new Obj()" expression.
    Constructor calls are elaborated during execution phase.
*/
rule [invokeConstr]:
    invokeConstr(OL:Int, Class:ClassType, Vals:KList, EnclosingObj:KResult)
    => setEncloser(lookup(OL, Class), Class, EnclosingObj)
    ~> 'ExprStm('Invoke(
          'Method('MethodName( typedLookup(OL),, getConsName(Class) )),,
          'ListWrap( Vals )
        ))

/*@ Sets the enclosing object for a given object.
    Invoked by invokeConstr and QSuperConstrInv. Defined in CLASSES.
*/
syntax K ::=  setEncloser (
                K,          //Evaluates to source object
                ClassType,  //Class layer in the source object for which to set the enclosing object.
                K           //The enclosing object
              )
              [strict(1,3)]

rule [setEncloser-value]:
    <k>
      setEncloser(objectClosure(OL:Int, _,_)::_, Class:ClassType, EncloserRV:RawVal::_) => .
      ...
    </k>
    <store>
      ...
      OL |->
        objectClosure(_, (_:KList/*ObjLayers*/,, layer(Class,_, _ => EncloserRV::EncloserClass, _),, _:KList/*ObjLayers*/), _)::_
      ...
    </store>
    <classType> Class </classType>
    <enclosingClass> EncloserClass:ClassType </enclosingClass>

rule [setEncloser-noValue]:
    setEncloser(_,_, noValue) => .

//@ Restore the content of the cell <methodContext>
syntax K ::=  restoreMethContext (
                Bag                 //The content of <methodContext>
              )

rule [restoreMethContext]:
    <k> restoreMethContext(MethContext:Bag) => . ...</k>
    <methodContext> _ => MethContext </methodContext>

/*@ Set outerLocalEnv for precisely the class layer Class. If sourceCalss is registered in
    <localClassesEnv>, take from there.
*/
syntax K ::=  setOuterLocalEnvForClass (
                Int,        //OL - object location,
                ClassType,  //Class - the layer for which we aim to set outerLocalEnv
                ClassType   //SourceClass - the candidate source class. Registered in <localClassesEnv>
              )

/*@ If SourceClass is registered in <localClassesEnv> we will take its corresponding Env, and set is
    as outerLocalEnv for the layer Class.
*/
rule [setOuterLocalEnvForClass-found]:
    <k> setOuterLocalEnvForClass(OL:Int, Class:ClassType, SourceClass:ClassType) => . ...</k>
    <store>
      ...
      OL |->
        objectClosure(_, ( _:KList/*ObjLayers*/,, layer(Class,_,_, _ => CurrentEnv),, _:KList/*ObjLayers*/), _)::_
      ...
    </store>
    <localClassesEnv>... SourceClass |-> mapWrap(CurrentEnv:Map) ...</localClassesEnv>

/*@ If SourceClass is not registered in <localClassesEnv>, it is not a direct local class.
    We attempt to replace it with its enclosing class,
    until eventually we will reach a local class.
*/
rule [setOuterLocalEnvForClass-not-found]:
    <k> setOuterLocalEnvForClass(OL:Int, Class:ClassType, SourceClass:ClassType => SourceEnclosingClass) ...</k>
    <localClassesEnv> LocalClassesEnv:Map </localClassesEnv>
    <classType> SourceClass </classType>
    <enclosingClass> SourceEnclosingClass:ClassType </enclosingClass>
when
    notBool SourceClass in keys(LocalClassesEnv)

//@ Otherwise we will reach noClass, and the whole term will be discarded.
rule setOuterLocalEnvForClass(_,_, noClass) => .

/*@ Set the outerLocalEnv for all layers of the <crntObj>, from the cell <localClassesEnv>,
    for the given class and its bases
*/
syntax K ::=  setOuterLocalEnvForHierarchy ( Int, ClassType )

rule [setOuterLocalEnvForHierarchy]:
    <k>
      (. => setOuterLocalEnvForClass(OL, Class, Class))
      ~> setOuterLocalEnvForHierarchy(OL:Int, Class:ClassType => BaseClass)
      ...
    </k>
    <classType> Class </classType>
    <extends> BaseClass:ClassType </extends>

rule setOuterLocalEnvForHierarchy(_, noClass) => .

//@ Set the content of <localClassesEnv> - in the 3rd argument of objectClosure().
syntax K ::=  setObjLocalClassesEnv ( Int )

rule [setObjLocalClassesEnv]:
    <k> setObjLocalClassesEnv(OL:Int) => . ...</k>
    <store>
      ...
      OL |-> objectClosure(_,_, _ => LocalClassesEnv)::_
      ...
    </store>
    <localClassesEnv> LocalClassesEnv:Map </localClassesEnv>

/*@ \subsection{Instance Of} */

context 'InstanceOf(HOLE,,_)

rule [InstanceOf]:
    'InstanceOf(V:RawVal::_,, RT2:RefType)
    =>  'LazyAnd((V =/=K null),, subtype(typeOf(V), RT2))

/*@ \subsection{Cast} */

rule [cast-RefType]:
    cast(RT1:RefType, V:RawVal :: RT2:RefType)
    =>  'If(
          subtype(typeOf(V), RT1),,
          (V::RT1),,
          'Throw('NewInstance(
                  'None(.KList),,
                  class String2Id("java.lang.ClassCastException"),,
                  'ListWrap( 'Plus('Plus(toString(typeOf(V)),, " cannot be cast to "),,
                      toString(RT1)) ),,
                  'None(.KList)
          ))
        )

endmodule
