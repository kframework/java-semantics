require "core-sorts.k"
require "core-classes.k"

//@ \section{Module PROCESS-CLASS-MEMBERS}

module PROCESS-CLASS-MEMBERS
    imports CORE-SORTS
    imports CORE-CLASSES

//@ \subsection{Auxiliary functions}

syntax K ::=  getContextType (
                K               //'ListWrap(...) - the list of method attributes
              )
              [function]

rule getContextType('ListWrap('Static(_),,_)) => staticCT

rule getContextType('ListWrap((KL:KLabel(_) => .KList),, _))
when        KL =/=KLabel 'Static

rule getContextType('ListWrap(.KList))      => instanceCT

//@ Evaluates to true::bool if synchronized is among modifiers, false otherwise
syntax K ::=  isSynchronized (
                K //'ListWrap(...) - the list of method attributes
              )
              [function]

rule isSynchronized('ListWrap('Synchronized(_),,_)) => true::bool

rule isSynchronized('ListWrap((KL:KLabel(_) => .KList),, _))
when        KL =/=KLabel 'Synchronized

rule isSynchronized('ListWrap(.KList)) => false::bool

//@ Used to provide an approximate implementation of the distinction between static constant and non-constant fields.
syntax K ::=  isFinal (
                K //'ListWrap(...) - the list of method attributes
              )
              [function]

rule isFinal('ListWrap('Final(_),,_)) => true

rule isFinal('ListWrap((KL:KLabel(_) => .KList),, _))
when        KL =/=KLabel 'Final

rule isFinal('ListWrap(.KList))      => false

/*@ \subsection{Third pass - processing class members} */

syntax K ::=  processClasses (
                K //setWrap(Set) - the set of all classes
              )         [strict]
            | processTypeWithDepends (
                ClassType  //the class to be processed,
                           //or noClass if no processing is required
              )
            | processType (
                ClassType  //the class to be processed
              )

/*@ We need to process Object first. Thus when we will process any interfaces,
    Object class will already be processed.*/
rule [Start-ProcClassMembersPhase]:
    <k> . => processTypeWithDepends(objectClass) ~> processClasses(getTopLevelClasses) </k>
     <globalPhase> ProcClassDecsPhase => ProcClassMembersPhase  </globalPhase>

rule [processClasses]:
    (. => processTypeWithDepends(Class))
    ~>  processClasses(setWrap( (SetItem(Class:ClassType) => .) _:Set))

rule [processClasses-Discard]:
    processClasses(setWrap(.)) => .

rule [processTypeWithDepends]:
    <k>
      processTypeWithDepends(Class:ClassType)
      => processTypeWithDepends(BaseClass) ~> processClasses(setWrap(ISet)) ~> processType(Class)
      ~> processClasses(getInnerClasses(Class))
      ...
    </k>
    <classType> Class </classType>
    <extends> BaseClass:ClassType </extends>
    <implements> ISet:Set </implements>
    <classPhase> DecsProcessedCPhase </classPhase>

rule [processTypeWithDepends-Discard]:
    <k> processTypeWithDepends(Class:ClassType) => . ...</k>
    <classType> Class </classType>
    <classPhase> MembersProcessedCPhase </classPhase>

rule [processTypeWithDepends-Discard2]:
    processTypeWithDepends(noClass) => .K

/*@ For each class compute the set of inherited interfaces, inherit all the members,
process inner declarations. Compute the following class cells:
  <implTrans>
  <fieldDecs>
  <methods>
  <methodDecs>
  <instanceInit>
  <staticEnv>
  <staticInit>

First we inherit methods from interfaces, then from the base class, and in the end we add methods declared in this
  class. Each new method overwrites previous methods with the same signature.
*/
rule [processType]:
    <k>
      processType(Class:ClassType) => computeImplTrans(SetItem(BaseClass) ISet)
          ~> tryInheritSet(ISet)

          //interfaces should also contain the members of Object
          ~> ifAux((MetaT ==K interfaceMetaT), tryInherit(objectClass), .K)

          ~> tryInherit(BaseClass)
          ~> Decls
      ...
    </k>
    <class>
      <classType> Class </classType>
      <extends> BaseClass:ClassType </extends>
      <implements> ISet:Set </implements>
      <implTrans> . => ISet </implTrans>
      ( <rawDeclarations> Decls:K </rawDeclarations> => .Bag)
      <metaType> MetaT:MetaType </metaType>
      <classPhase> DecsProcessedCPhase => MembersProcessedCPhase </classPhase>
      ...
    </class>
    <crntClass> _ => Class </crntClass>

//Could happen when hierarchies of inheritance and that of enclosing get messed up.
rule [processType-discard]:
    <k> processType(Class:ClassType) => . ...</k>
    <classType> Class </classType>
    <classPhase> MembersProcessedCPhase </classPhase>

//@ Compute <implTrans> cell - interfaces transitively implemented
syntax K ::= computeImplTrans ( Set )

rule [computeImplTrans]:
    <k>
      (. => saveImplTrans(setUnion(setWrap(ITrans), setWrap(BaseItfITrans))))
      ~> computeImplTrans( (SetItem(BaseItf:ClassType) => .) _)
      ...
    </k>
    <crntClass> Class:ClassType </crntClass>
    <classType> Class </classType>
    <implTrans> ITrans:Set </implTrans>
    <classType> BaseItf </classType>
    <implTrans> BaseItfITrans:Set </implTrans>

rule [computeImplTrans-Elem-Discard]: computeImplTrans( (SetItem(noClass) => .) _)

rule [computeImplTrans-Discard]: computeImplTrans(.) => .

syntax K ::=  saveImplTrans (
                K //setWrap(ISet) - transitive set of inherited interfaces
              )
              [strict]

rule <k> saveImplTrans(setWrap(S1:Set)) => . ...</k>
     <crntClass> Class:ClassType </crntClass>
     <classType> Class </classType>
     <implTrans> _ => S1 </implTrans>

//@ Inherits the methods of the base class, based on rules in JLS \$8.4.8 paragraph 1
syntax K ::= tryInheritSet ( Set )
           | tryInherit ( ClassType )
           | tryInheritImpl ( Map )

rule [tryInheritSet]:
    (. => tryInherit(Class:ClassType)) ~> tryInheritSet( (SetItem(Class) => .) _)

rule [tryInheritSet-Discard]: tryInheritSet(.) => .

rule [tryInherit]:
    <k>
      tryInherit(Class:ClassType) => tryInheritImpl(Env)
      ...
    </k>
    <classType> Class </classType>
    <methods> Env:Map </methods>

rule [tryInherit-Discard]:
    tryInherit(noClass) => .K

rule [tryInheritImpl-Unfold]:
    <k> (. => tryInheritImpl(MI)) ~> tryInheritImpl( (MI:MapItem => .) _:MapItem _) ...</k>

rule [tryInheritImpl]:
    <k>
      tryInheritImpl(Sig:K |-> DecClass:ClassType)
      => ifAux(
            isInheritable(getMethodAccessMode(TV)),
            inherit(Sig |-> DecClass),
            .K
          )
      ...
    </k>
    <classType> DecClass </classType>
    <methodDecs>... Sig |-> TV:TypedVal ...</methodDecs>

rule [tryInheritImpl-empty-Discard]: tryInheritImpl(.Map) => .

syntax K ::= isInheritable ( K )                        [strict]

rule [isInheritable]:
    <k>
      isInheritable(BaseAccessMode:AccessMode)
      => isAccessibleForOverwriting(BaseClass, BaseAccessMode, Class)
      ...
    </k>
    <crntClass> Class:ClassType </crntClass>
    <classType> Class </classType>
    <extends> BaseClass:ClassType </extends>

/*@ Tests if a method within BaseClass with BaseAccessMode is overwritten by a method with the same signature
in SubClass with SubAccessMode.
It is also possible that BaseClass and SubClass are the same, since the same method is inherited by many classes,
and gets in their <methods> cell.*/
syntax K ::=  isAccessibleForOverwriting (
                ClassType,  //BaseClass
                AccessMode, //BaseAccessMode
                ClassType   //SubClass
              )
              [strict]

rule isAccessibleForOverwriting(_, public,    _) => true
rule isAccessibleForOverwriting(_, protected, _) => true

//@ Object class cannot match this rule since it has public access mode
rule isAccessibleForOverwriting(BaseClass:ClassType, package, SubClass:ClassType)
    => eqAux(getPackage(getTopLevel(BaseClass)), getPackage(getTopLevel(SubClass)))

rule isAccessibleForOverwriting(_, private, _) => false

/*@ Inherit a list of methods by the current class. The inherited methods overwrite previous methods
  with the same signature in <methods>
*/
syntax K ::=  inherit (
                Map //Map[Signature |-> ClassType] - the map of signatures
              )

rule [inherit]:
    <k> inherit(Sig:K |-> DeclClass:ClassType) => . ...</k>
    <crntClass> Class:ClassType </crntClass>
    <class>
      <classType> Class </classType>
      <methods> Env:Map => Env[DeclClass/Sig] </methods>
      ...
    </class>

//@ Returns the access mode of a method closure given as argument
syntax K ::= getMethodAccessMode ( TypedVal )   [strict]
rule getMethodAccessMode( methodClosure(_,_,_, Acc:AccessMode, _,_,_)::_ ) => Acc

//@ Returns the context type of a method closure given as argument
syntax K ::= getMethodContextType ( TypedVal )  [strict]
rule getMethodContextType( methodClosure(_,_, CT:ContextType, _,_,_,_) :: _ ) => CT

//@ Returns the class in which this method was defined
syntax K ::= getMethodDeclaringClass ( TypedVal )   [function]
rule getMethodDeclaringClass( methodClosure(Class:ClassType, _,_,_,_,_,_)::_ ) => Class

//@ Returns the return type of a method closure given as argument
syntax K ::= getMethodReturnType ( TypedVal )       [function]
rule getMethodReturnType( _::methodType(_, T:Type ) ) => T

/*@ \subsection{Method declaration}
Methods are now typed and we need to store their types in their
closures, so that their type contract can be checked at invocation
time.  The rule below is conceptually similar to that of untyped KOOL;
the only difference is the addition of the types.  */

//@ 'MethodDec('MethodDecHead(_:K,, _:K,, _:Type,, _:Id,, 'ListWrap(_,, 'Param(_:K,, HOLE,,_:K),, _),, _:K),, _:K)
syntax KLabel ::= "'MethodDec"
                | "'MethodDecHead"

//resolving the return type
context 'MethodDec('MethodDecHead(_:K,, _:K,, HOLE,, _),, _)

//Resolve parameter types
context 'MethodDec('MethodDecHead(_:K,, _:K,, _:Type,, _:Id,, 'ListWrap(_,, 'Param(_:K,, HOLE,,_:K),, _),, _:K),, _:K)

rule [MethodDec]:
    <k>
      'MethodDec(
        'MethodDecHead(Modifiers:K,, _:K,, ReturnType:Type,, Name:Id,,
            'ListWrap(Params:KList),, _:K
        ),,
        S:K
      )
      => storeMethod('ListWrap(Params),
            getContextType(Modifiers), getAccessMode(Modifiers), isSynchronized(Modifiers), methodRT, noValue, S,
            methodType(sig(Name, getTypes(Params)), ReturnType))
      ...
    </k>
    <crntClass> Class:ClassType </crntClass>
when
    paramTypesResolved(Params)                        [structural]

syntax K ::= paramTypesResolved( KList )              [function]
rule paramTypesResolved(('Param(_:K,, T:Type,, _:Id) => .KList),, _)
rule paramTypesResolved(.KList) => true

syntax KLabel ::= "'AbstractMethodDec"
                | "'NoMethodBody"

rule [AbstractMethodDec]:
    'AbstractMethodDec(_:K,, Ks:KList)
    =>  'MethodDec(
          'MethodDecHead('ListWrap('Public(.KList),,'Abstract(.KList)),, Ks),,
          'NoMethodBody(.KList)
        )

syntax K ::=  storeMethod (
                K,           //'ListWrap(Params)
                K,           //will evaluate to ContextType - staticCT or instanceCT
                K,           //will evaluate to AccessMode
                K,           //IsSync:bool - whether method is synchronized or not
                RoutineType, //either methodRT or constructorRT
                K,           //FirstLine for constructor, noValue for method.
                K,           //S - method body
                MethodType   //method closure type: methodType(Signature, ReturnType)
              )

rule [storeMethod]:
    <k>
      storeMethod('ListWrap(Params:KList), CT:ContextType, Acc:AccessMode, false::bool, RT:RoutineType, FirstLine:K, Body:K,
          methodType(Sig:Signature, ReturnType:Type)) => .
      ...
    </k>
    <crntClass> Class:ClassType </crntClass>
    <classType> Class </classType>
    <methods> Env:Map => Env[Class / Sig] </methods>
    <methodDecs>
      DecsEnv:Map => DecsEnv[
        methodClosure(Class, 'ListWrap(Params), CT, Acc, RT, FirstLine, Body) :: methodType(Sig,ReturnType) / Sig
      ]
    </methodDecs>

syntax KLabel ::= "'ConstrDec"
                | "'ConstrDecHead"
                | "'ConstrBody"

rule [ConstrDec-SuperCall-Desugar]:
    <k>
      'ConstrDec(
        'ConstrDecHead(_:K,, _:K,, Name:Id,, _:KList),,
        'ConstrBody(
          (
            'None(_)
            => 'Some('SuperConstrInv( 'None(.KList),, 'ListWrap(.KList) ))
          ),,
          _:K
        )
      )
      ...
    </k>
    <crntClass> Class:ClassType </crntClass>
when
    Class =/=K objectClass

rule [ConstrDec-Object-Desugar]:
    <k>
      'ConstrDec(
        'ConstrDecHead(_:K,, _:K,, Name:Id,, _:KList),,
        'ConstrBody(
          (
            'None(_) => 'Some(.K)
          ),,
          _:K
        )
      )
      ...
    </k>
    <crntClass> Class:ClassType </crntClass>
when
    Class ==K objectClass

//Resolve parameter types
context 'ConstrDec('ConstrDecHead(_:K,, _:K,, _:Id,, 'ListWrap(_,, 'Param(_:K,, HOLE,,_:K),, _),, _),, _:K)

rule [ConstrDec]:
    <k>
      'ConstrDec('ConstrDecHead(Modifiers:K,, _:K,, Name:Id,, 'ListWrap(Params:KList),, _),,
          'ConstrBody(
        'Some(FirstLine:K) ,,S:K))
      => storeMethod('ListWrap(Params),
          instanceCT, getAccessMode(Modifiers), isSynchronized(Modifiers), constructorRT, FirstLine, S,
          methodType(sig(getConsName(Class), getTypes(Params)), void))
      ...
    </k>
    <crntClass> Class:ClassType </crntClass>
when paramTypesResolved(Params)

//@ Get the internal constructor name for a given class
syntax K ::= getConsName ( ClassType )                               [function]
rule getConsName(class ClassId:Id) => String2Id("$cons$" +String Id2String(ClassId))

//@ 'FieldDec(Modifiers:K,, T:Type,, 'ListWrap('VarDec(X:Id,, InitExp:K),, _))
syntax KLabel ::= "'FieldDec"

//resolve field declaration type
context 'FieldDec(_:K,, HOLE,, _)

rule [FieldDec-Multi-Desugar]:
    (. => 'FieldDec(SomeK,, T,, 'ListWrap(K1))) ~>
    'FieldDec(SomeK:K,, T:Type,, 'ListWrap((K1:K => .KList),, K2:K,, Ks:KList))

rule [FieldDec-with-init-desugar]:
    'FieldDec(Modifiers:K,, T:Type,, 'ListWrap('VarDec(X:Id,,(InitExp:K => .KList)) ))
    ~> (. => 'InstanceInit('ExprStm('Assign('ExprName(X),, InitExp))))
when
            (getKLabel(InitExp) =/=KLabel 'ArrayInit)
    andBool (getContextType(Modifiers) ==K instanceCT)
        [structural]

rule [FieldDec-to-LocalVarDec]:
    <k> 'FieldDec(Modifiers:K,, T:Type,, 'ListWrap('VarDec(X:Id))) => . ...</k>
    <crntClass> Class:ClassType </crntClass>
    <classType> Class </classType>
    <fieldDecs> 'ListWrap(_,, ( .KList => 'LocalVarDec(.K,, T,, 'ListWrap('VarDec(X))) )) </fieldDecs>
when
    getContextType(Modifiers) ==K instanceCT
        [structural]

syntax KLabel ::= "'InstanceInit"

rule [InstanceInit]:
    <k> 'InstanceInit(K:K) => . ...</k>
    <crntClass> Class:ClassType </crntClass>
    <classType> Class </classType>
    <instanceInit> 'ListWrap(_,,(.KList => K)) </instanceInit>
        [structural]

/*@ Desugaring a static field declaration with initializer into a declaration without initializer.
Followed by a static initializer block, if this field is not a compile-time constant.*/
rule [FieldDec-StaticInit-Desugar]:
    'FieldDec(Modifiers:K,, T:Type,, 'ListWrap('VarDec(X:Id,,(InitExp:K => .KList)) ))
    ~> (. => 'StaticInit('ExprStm('Assign('ExprName(X),, InitExp))))
when
            (getKLabel(InitExp) =/=KLabel 'ArrayInit)
    andBool (getContextType(Modifiers) ==K staticCT)

    //condition for not being compile-time constant
    andBool notBool(        isFinal(Modifiers)
                    andBool (getKLabel(InitExp) ==KLabel 'Lit orBool isKResult(InitExp) ==K true)
                   )
        [structural]

rule [FieldDec-Static]:
    <k> 'FieldDec(Modifiers:K,, T:Type,, 'ListWrap('VarDec(X:Id))) => . ...</k>
    <crntClass> Class:ClassType </crntClass>
    <classType> Class </classType>
    <staticEnv> Env:Map => Env[L/X] </staticEnv>
    <store>... . => L |-> default(T) ...</store>
    <nextLoc> L:Int => L +Int 1 </nextLoc>
when
    getContextType(Modifiers) ==K staticCT
        [structural]

syntax KLabel ::= "'StaticInit"

rule [StaticInit-Save]:
    <k> 'StaticInit(K:K) => . ...</k>
    <crntClass> Class:ClassType </crntClass>
    <classType> Class </classType>
    <staticInit> 'ListWrap(_,,(.KList => K)) </staticInit>
        [structural]

syntax KLabel ::= "'ConstantDec"

/*@ The parser represents interface fields as 'ConstantDec labels.
  This rule desugars them into 'FieldDec labels and adds the modifiers "public static final".
  Interface fields are not necessarily compile-time constants.
*/
rule [ConstantDec-Desugar]:
    'ConstantDec('ListWrap(ModifiersKs:KList),, TypeK:K,, VarDecs:K)
    => 'FieldDec(
          'ListWrap(ModifiersKs,, 'Public(.KList),, 'Static(.KList),, 'Final(.KList)),,
          TypeK,, VarDecs
        )

/*@Subsection compile-time constants*/

//compute the value of a compile-time constant
context 'FieldDec(Modifiers:K,, T:Type,, 'ListWrap('VarDec(X:Id,, HOLE) ))
when
            getContextType(Modifiers) ==K staticCT
    //condition for not being compile-time constant
    andBool isFinal(Modifiers) andBool getKLabel(HOLE) ==KLabel 'Lit

rule [FieldDec-compile-time-constant]:
    <k>
      'FieldDec(Modifiers:K,, T:Type,, 'ListWrap('VarDec(X:Id,, TV:TypedVal) )) => .
      ...
    </k>
    <crntClass> Class:ClassType </crntClass>
    <classType> Class </classType>
    <constantEnv> Env:Map => Env[TV/X] </constantEnv>
when
            getContextType(Modifiers) ==K staticCT
    andBool isFinal(Modifiers)

/*@ Discard inner class declarations at this phase. They are processed when their
    respective <class> tag is encountered as part of processClasses.
*/
rule [ClassDec-discard]: 'ClassDec(_) => .
rule [InterfaceDec-discard]: 'InterfaceDec(_) => .

endmodule
