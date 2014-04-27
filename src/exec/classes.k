require "../common/core-sorts.k"
require "../common/core-functions.k"
require "../common/core-classes.k"
require "../common/subtyping.k"
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
    imports CORE-FUNCTIONS
    imports CORE-CLASSES
    imports SUBTYPING
    imports EXPRESSIONS
    imports STATEMENTS
    imports ARRAYS
    imports STATIC-INIT
    imports VAR-LOOKUP

/*@ \subsection{New instance creation}*/

/*@ 'NewInstance( _:K,, Class:ClassType,, [Args],, 'None(.KList) )

    Although we could have just 'QNewInstance at runtime, having runtime semantics for 'NewInstance is preferred
    because we have a lot of 'Throw('NewInstance()) through our runtime semantics.
*/
syntax KLabel ::= "'NewInstance"

/*@Unpack 'NewInstance back into 'QNewInstance.
  The difference between desugaring and unpacking is that unpacking is an artificial procedure required to separate
  elaboration from execution. In the elaboration phase there is a opposite packing rule tht creates this construct.
*/
rule [NewInstance-to-QNewInstance-unpack]:
    'NewInstance(Arg1:K,, Class:ClassType,, ActualArgsList:KListWrap,, 'None(.KList))
    => 'QNewInstance(noValue,, Arg1,, Class,, 'None(.KList),, ActualArgsList,, 'None(.KList))

//@ 'QNewInstance( Qual,, _:K,, Class,, _:K,, [Args],, 'None(.KList) )
syntax KLabel ::= "'QNewInstance"

//@Resolve new instance qualifier
context 'QNewInstance(HOLE,, _:KList)

//totest model check - test the arguments evaluation order
/*@ Resolve new instance expression parameter values
*/
context 'QNewInstance(_:KResult,,_:K,,_:K,,_:K,, [_,,HOLE,,_],, _)

rule [QNewInstance-resolve-class]:
    'QNewInstance(_::QualT:ClassType,,_:K,, (Name:Id => getClassType(toPackage(QualT), Name)),,_:K,, _:KListWrap,, _)

/*@ Qualified new instance creation expression. Unqualified new expressions are rewritten into qualified ones by other
rules and also reach this point.*/
rule [QNewInstance]:
    <k>
      'QNewInstance(
        EnclosingObj:KResult,,
        _:K,,
        Class:ClassType,,
        _:K,,
        [Args:KList],,
        _:K
      )
      => staticInit(Class)
        ~> create(Class)
        ~> restoreMethContext(MethContext)
        ~> invokeConstr(L, Class, [Args], EnclosingObj)
        ~> typedLookup(L)
      ...
    </k>
    <methodContext>
      MethContext:Bag
      =>  <env> .Map </env>
          <return> void </return>
          <crntClass> .K </crntClass>
          <location> L </location>
    </methodContext>
    <store>
      ...
      . => L |-> objectRef(L, Class) :: Class
      ...
    </store>
    (.Bag =>  <object>
                <objectId> L </objectId>
                <objectType> Class </objectType>
              </object>
    )
    <nextLoc> L:Int => L +Int 1 </nextLoc>
when isKResult(Args)

syntax K ::=  create ( ClassType )

rule [create]:
    <k>
      create(Class:ClassType)
      => create(BaseClass) ~> setCrntClass(Class) ~> FieldDecs ~> addEnvLayer
      ...
    </k>
    <classType> Class </classType>
    <extends> BaseClass:ClassType </extends>
    <instanceFields> FieldDecs:K </instanceFields>
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
    <location> OId:Int </location>
    <object>
      <objectId> OId </objectId>
      (.Bag =>  <layer>
                  <layerClass> Class </layerClass>
                  <layerEnv> Env </layerEnv>
                  ...
                </layer>
      )
      ...
    </object>
        [structural]

syntax K ::=  invokeConstr (
                Int,        //OL - object location
                ClassType,  //The target class
                KListWrap,  //Arguments, evaluated
                K           //EnclosingObj - the typed enclosing object, if any. Otherwise - noValue
              )

/*@ This rule cannot be simplified - we have to alter the newly created object from the store.
    The context inside <methodContext> is the context that called "new Obj()" expression.
    Constructor calls are elaborated during execution phase.
*/
rule [invokeConstr]:
    invokeConstr(OL:Int, Class:ClassType, [Args:KList], EnclosingObj:KResult)
    => setEncloser(lookup(OL, Class), Class, EnclosingObj)
    ~> 'ExprStm('Invoke(
          'Method('MethodName( typedLookup(OL),, getConsName(Class) )),,
          [ Args ]
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
      setEncloser(objectRef(OId:Int, _)::_, Class:ClassType, EncloserRV:RawVal::_) => .
      ...
    </k>
    <objectId> OId </objectId>
    <layerClass> Class </layerClass>
    <layerEnclosingObject> _ => EncloserRV::EncloserClass </layerEnclosingObject>
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

/*@ \subsection{Instance Of} */

//@ 'InstanceOf(V::T,, T2)
syntax KLabel ::= "'InstanceOf"

context 'InstanceOf(HOLE,,_)

rule [InstanceOf]:
    'InstanceOf(V:RawVal::_,, RT2:RefType)
    =>  'LazyAnd((V =/=K null),, subtype(typeOf(V), RT2))

/*@ \subsection{Cast} */

rule [cast-RefType]:
    cast(RT1:RefType, V:RawVal :: RT2:RefType)
    =>  ifAux(
          subtype(typeOf(V), RT1),
          (V::RT1),
          'Throw('NewInstance(
                  'None(.KList),,
                  class String2Id("java.lang.ClassCastException"),,
                  [ 'Plus('Plus(toString(typeOf(V)),, " cannot be cast to "),,
                      toString(RT1)) ],,
                  'None(.KList)
          ))
        )

//@\subsection{Execution of QSuperConstrInv, AltConstrInv}

//@ 'QSuperConstrInv( Qual:K,, _:K,, [ Args:KList ] )
syntax KLabel ::=  "'QSuperConstrInv"

rule [QSuperConstrInv]:
    <k>
      'QSuperConstrInv(Qual:K,, _,, [ Args:KList ])
      => setEncloser('QThis(Class), BaseClass, Qual)
         ~> 'ExprStm('Invoke(
              'QSuperMethod(Class,, .K,, getConsName(BaseClass)),,
              [Args]
            ))
      ...
    </k>
    <crntClass> Class:ClassType </crntClass>
    <classType> Class </classType>
    <extends> BaseClass:ClassType </extends>

//@ 'AltConstrInv( _:K,, [ Args:KList ] )
syntax KLabel ::= "'AltConstrInv"

rule [AltConstrInv]:
    <k>
      'AltConstrInv(_,, [ Args:KList ])
      => 'ExprStm('Invoke(
                'Method('MethodName( 'QThis(Class),, getConsName(Class) )),,
                [Args]
          ))
      ...
    </k>
    <crntClass> Class:ClassType </crntClass>

endmodule
