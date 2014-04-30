require "../common/core-sorts.k"
require "../common/core-classes.k"
require "core-preprocessing.k"

//@ \section{Module PROCESS-CLASS-MEMBERS}

module PROCESS-CLASS-MEMBERS
    imports CORE-SORTS
    imports CORE-CLASSES
    imports CORE-PREPROCESSING

/*@ \subsection{Third pass - processing class members} */

/*@ We need to process Object first. Thus when we will process any interfaces,
    Object class will already be processed.*/
rule [Start-ProcClassMembersPhase]:
    <k> . => processTypeWithDepends(objectClass) ~> processClasses(getTopLevelClasses) </k>
    <globalPhase> ProcClassDecsPhase => ProcClassMembersPhase  </globalPhase>

syntax K ::=  processClasses (
                K //setWrap(Set) - the set of all classes
              )
              [strict]

rule [processClasses]:
    (. => processTypeWithDepends(Class))
    ~>  processClasses(setWrap( (SetItem(Class:ClassType) => .) _:Set))

rule [processClasses-Discard]:
    processClasses(setWrap(.)) => .

syntax K ::=  processTypeWithDepends (
                ClassType  //the class to be processed,
                           //or noClass if no processing is required
              )

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

syntax K ::=  processType (
                ClassType  //the class to be processed
              )

/*@ For each class compute the set of inherited interfaces, inherit all the members,
process inner declarations. Compute the following class cells:
  <implTrans>
  <instanceFields>
  <methods>
  <methodDecs>
  <instanceInit> - temporary cell, deleted after class body is processed.
  <staticEnv>
  <staticInit>

First we inherit methods from interfaces, then from the base class, and in the end we add methods declared in this
  class. Each new method overwrites previous methods with the same signature.
*/
rule [processType]:
    <k>
      processType(Class:ClassType) => computeImplTrans(SetItem(BaseClass) ISet)
          ~> tryInheritSet(ISet)

          //interfaces should also contain the members of Object.
          //In fact we could add object methods to classes as well
          ~> ifAux((MetaT ==K interfaceCMT), tryInherit(objectClass), .K)

          ~> tryInherit(BaseClass) //Method implementation from the base class could potentially
                                   //overwrite methods inherited from interfaces
          ~> Decls  //methods declared here will overwrite inherited methods

          //performance problem - adds 1s of execution to helloWorld, Windows.
          ~> convertInstanceInitIntoMethod

          ~> restoreCrntClass(OldCrntClass)
      ...
    </k>
    <crntClass> OldCrntClass:ClassType => Class </crntClass>
    <class>
      <classType> Class </classType>
      <extends> BaseClass:ClassType </extends>
      <implements> ISet:Set </implements>
      <implTrans> . => ISet </implTrans>
      ( <rawDeclarations> Decls:K </rawDeclarations> => .Bag)
      <classMetaType> MetaT:ClassMetaType </classMetaType>
      <classPhase> DecsProcessedCPhase => MembersProcessedCPhase </classPhase>
      ...
    </class>

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
    tryInheritImpl(Sig:K |-> DecClass:ClassType)
    => ifAux(
          isInheritable(getMethodAccessMode(methodRef(Sig, DecClass))),
          inherit(methodRef(Sig, DecClass)),
          .K
       )

rule [tryInheritImpl-empty-Discard]: tryInheritImpl(.Map) => .

syntax K ::= isInheritable ( AccessMode )                        [strict]

rule [isInheritable]:
    <k>
      isInheritable(BaseAccessMode:AccessMode)
      => isOverridden(BaseClass, BaseAccessMode, Class)
      ...
    </k>
    <crntClass> Class:ClassType </crntClass>
    <classType> Class </classType>
    <extends> BaseClass:ClassType </extends>

/*@ Inherit a method by the current class. The inherited method overwrites previous methods
  with the same signature in <methods>
*/
syntax K ::=  inherit ( MethodRef )

rule [inherit]:
    <k> inherit(methodRef(Sig:Signature, DecClass:ClassType)) => . ...</k>
    <crntClass> Class:ClassType </crntClass>
    <classType> Class </classType>
    <methods> Env:Map => Env[DecClass/Sig] </methods>

/*@ \subsection{Method declaration}
Methods are now typed and we need to store their types in their
closures, so that their type contract can be checked at invocation
time.  The rule below is conceptually similar to that of untyped KOOL;
the only difference is the addition of the types.  */

/*@
'MethodDec(
  'MethodDecHead(
    Modifiers:KListWrap,,
    _:K,,
    ReturnType:Type,,
    Name:Id,,
    [_,, 'Param(_:K,, HOLE,,_:K),, _],,
    _:K
  ),,
  Body:K
)
*/
syntax KLabel ::= "'MethodDec"
                | "'MethodDecHead"

//resolving the return type
context 'MethodDec('MethodDecHead(_:K,, _:K,, HOLE,, _),, _)

//Resolve parameter types
context 'MethodDec('MethodDecHead(_:K,, _:K,, _:Type,, _:Id,, [_,, 'Param(_:K,, HOLE,,_:K),, _],, _:K),, _:K)

rule [MethodDec]:
    <k>
      'MethodDec(
        'MethodDecHead(Modifiers:KListWrap,, _:K,, ReturnType:Type,, Name:Id,,
            [Params:KList],, _:K
        ),,
        Body:K //could be 'Block([...]) or 'NoMethodBody
      )
      => storeMethod([Params],
            getContextType(Modifiers), getAccessMode(Modifiers), isSynchronized(Modifiers), methodMMT, noValue, Body,
            sig(Name, getTypes([Params])), ReturnType)
      ...
    </k>
    <crntClass> Class:ClassType </crntClass>
when
    paramTypesResolved([Params])                            [structural]

syntax K ::= paramTypesResolved( KListWrap )              [function]
rule paramTypesResolved([('Param(_:K,, T:Type,, _:Id) => .KList),, _])
rule paramTypesResolved([.KList]) => true

syntax KLabel ::= "'AbstractMethodDec"
                | "'NoMethodBody"

rule [AbstractMethodDec]:
    'AbstractMethodDec(_:K,, Ks:KList)
    =>  'MethodDec(
          'MethodDecHead(['Public(.KList),,'Abstract(.KList)],, Ks),,
          'NoMethodBody(.KList)
        )

syntax K ::=  storeMethod (
                KListWrap,   //[Params]
                ContextType, //will evaluate to ContextType - staticCT or instanceCT
                AccessMode,  //will evaluate to AccessMode
                TypedVal,    //IsSync:bool - whether method is synchronized or not
                MethodMetaType, //either methodMMT or constructorMMT
                K,           //FirstLine for constructor, noValue for method.
                K,           //S - method body. Either [...] or 'NoMethodBody(_)
                Signature,   //method signature
                Type         //method return type
              )

rule [storeMethod-Synchronized-method-inst-desugar]:
    storeMethod(_, instanceCT, _, (true => false)::bool, _,_,
        Body:K => 'Synchronized('This(.KList),, Body),
        _,_)

rule [storeMethod-Synchronized-method-static-desugar]:
    <k>
      storeMethod(_, staticCT, _, (true => false)::bool, _,_,
          Body:K => 'Synchronized('Lit('Class(Class)),, Body),
          _,_)
      ...
    </k>
    <crntClass> Class:ClassType </crntClass>

rule [storeMethod]:
    <k>
      storeMethod([Params:KList], CT:ContextType, Acc:AccessMode, false::bool, MMT:MethodMetaType, FirstLine:K,
                  Body:K, Sig:Signature, ReturnType:Type) => .
      ...
    </k>
    <crntClass> Class:ClassType </crntClass>
    <classType> Class </classType>
    <methods> Env:Map => Env[Class / Sig] </methods>
    ( .Bag => <methodDec>
                     <methodSignature> Sig </methodSignature>
                     <methodReturnType> ReturnType </methodReturnType>
                     <methodParams> [Params] </methodParams>
                     <methodConstrFirstLine> FirstLine </methodConstrFirstLine>
                     <methodBody> Body </methodBody>
                     <methodAccessMode> Acc </methodAccessMode>
                     <methodContextType> CT </methodContextType>
                     <methodMetaType> MMT </methodMetaType>
              </methodDec>
         )
when
    notBool (Sig in keys(Env) andBool MMT ==K constructorMMT)

/*@ Discard the default consturctor that was added by the rule [processTypeDecsInPCUPhase-ClassDec]
    if this class already have a default constructor.
*/
rule [storeMethod-discard-default-constructor]:
    <k>
      storeMethod([.KList],_,_,_, constructorMMT, _,_, Sig:Signature, _) => .
      ...
    </k>
    <crntClass> Class:ClassType </crntClass>
    <classType> Class </classType>
    <methods>... Sig |-> _ ...</methods>

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
            => 'Some('SuperConstrInv( 'None(.KList),, [.KList] ))
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
context 'ConstrDec('ConstrDecHead(_:K,, _:K,, _:Id,, [_,, 'Param(_:K,, HOLE,,_:K),, _],, _),, _:K)

rule [ConstrDec]:
    <k>
      'ConstrDec('ConstrDecHead(Modifiers:KListWrap,, _:K,, Name:Id,, [Params:KList],, _),,
          'ConstrBody(
        'Some(FirstLine:K) ,,[BodyKs:KList]))
      => storeMethod([Params],
          instanceCT, getAccessMode(Modifiers), isSynchronized(Modifiers), constructorMMT, FirstLine,
          'Block([

            //Performance problem - the #if below adds 3s of execution to helloWorld, 25s total, Windows.
            //Invocation of instance initializer converted into a method.
            #if getKLabel(FirstLine) ==KLabel 'SuperConstrInv orBool getKLabel(FirstLine) ==KLabel 'QSuperConstrInv
              #then 'ExprStm('Invoke('Method('MethodName( String2Id("$instance_init") )),, [.KList]))
              #else [.KList] //vacuous
            #fi,,
            BodyKs
          ]),
          sig(getConsName(Class), getTypes([Params])), void)
      ...
    </k>
    <crntClass> Class:ClassType </crntClass>
when paramTypesResolved([Params])

//@ 'FieldDec(Modifiers:K,, T:Type,, ['VarDec(X:Id,, InitExp:K),, _])
syntax KLabel ::= "'FieldDec"

//resolve field declaration type
context 'FieldDec(_:K,, HOLE,, _)

rule [FieldDec-Multi-Desugar]:
    (. => 'FieldDec(SomeK,, T,, [K1])) ~>
    'FieldDec(SomeK:K,, T:Type,, [(K1:K => .KList),, K2:K,, Ks:KList])

rule [FieldDec-with-init-desugar]:
    'FieldDec(Modifiers:KListWrap,, T:Type,, ['VarDec(X:Id,,(InitExp:K => .KList)) ])
    ~> (. => 'InstanceInit('ExprStm('Assign('ExprName(X),, InitExp))))
when
            (getKLabel(InitExp) =/=KLabel 'ArrayInit)
    andBool (getContextType(Modifiers) ==K instanceCT)
        [structural]

rule [FieldDec-to-LocalVarDec]:
    <k> 'FieldDec(Modifiers:KListWrap,, T:Type,, ['VarDec(X:Id)]) => . ...</k>
    <crntClass> Class:ClassType </crntClass>
    <classType> Class </classType>
    <instanceFields> [_,, ( .KList => 'LocalVarDec(.K,, T,, ['VarDec(X)]) )] </instanceFields>
when
    getContextType(Modifiers) ==K instanceCT
        [structural]

syntax KLabel ::= "'InstanceInit"

rule [InstanceInit]:
    <k> 'InstanceInit(K:K) => . ...</k>
    <crntClass> Class:ClassType </crntClass>
    <classType> Class </classType>
    <instanceInit> [_,,(.KList => K)] </instanceInit>
        [structural]

/*@ Desugaring a static field declaration with initializer into a declaration without initializer.
Followed by a static initializer block, if this field is not a compile-time constant.*/
rule [FieldDec-StaticInit-Desugar]:
    'FieldDec(Modifiers:KListWrap,, T:Type,, ['VarDec(X:Id,,(InitExp:K => .KList)) ])
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
    <k> 'FieldDec(Modifiers:KListWrap,, T:Type,, ['VarDec(X:Id)]) => . ...</k>
    <crntClass> Class:ClassType </crntClass>
    <classType> Class </classType>
    <staticFields> [_,, ( .KList => 'FieldDec('Static(.KList),, T,, ['VarDec(X)]) )] </staticFields>
when
    getContextType(Modifiers) ==K staticCT
        [structural]

syntax KLabel ::= "'StaticInit"

rule [StaticInit-Save]:
    <k> 'StaticInit(K:K) => . ...</k>
    <crntClass> Class:ClassType </crntClass>
    <classType> Class </classType>
    <staticInit> [_,,(.KList => K)] </staticInit>
        [structural]

syntax KLabel ::= "'ConstantDec"

/*@ The parser represents interface fields as 'ConstantDec labels.
  This rule desugars them into 'FieldDec labels and adds the modifiers "public static final".
  Interface fields are not necessarily compile-time constants.
*/
rule [ConstantDec-Desugar]:
    'ConstantDec([ModifiersKs:KList],, TypeK:K,, VarDecs:KListWrap)
    => 'FieldDec(
          [ModifiersKs,, 'Public(.KList),, 'Static(.KList),, 'Final(.KList)],,
          TypeK,, VarDecs
        )

/*@Subsection compile-time constants*/

//compute the value of a compile-time constant
context 'FieldDec(Modifiers:K,, T:Type,, ['VarDec(X:Id,, HOLE) ])
when
            getContextType(Modifiers) ==K staticCT
    //condition for not being compile-time constant
    andBool isFinal(Modifiers) andBool getKLabel(HOLE) ==KLabel 'Lit

rule [FieldDec-compile-time-constant]:
    <k>
      'FieldDec(Modifiers:KListWrap,, T:Type,, ['VarDec(X:Id,, TV:TypedVal) ]) => .
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

syntax K ::= "convertInstanceInitIntoMethod"

rule [convertInstanceInitIntoMethod]:
    <k>
      convertInstanceInitIntoMethod
      => storeMethod([.KList], instanceCT, private, false::bool, methodMMT, noValue, 'Block([InstanceInitKs]),
                      sig(String2Id("$instance_init"), types(.KList)), void)
      ...
    </k>
    <crntClass> Class:ClassType </crntClass>
    <classType> Class </classType>
    (<instanceInit> [InstanceInitKs:KList] </instanceInit> => .Bag)

//@ \subsection{Auxiliary functions}

//@ Evaluates to true::bool if synchronized is among modifiers, false otherwise
syntax K ::=  isSynchronized (
                KListWrap       //[...] - the list of method attributes
              )
              [function]

rule isSynchronized(['Synchronized(_),,_]) => true::bool

rule isSynchronized([(KL:KLabel(_) => .KList),, _])
when        KL =/=KLabel 'Synchronized

rule isSynchronized([.KList]) => false::bool

//@ Used to provide an approximate implementation of the distinction between static constant and non-constant fields.
syntax K ::=  isFinal (
                KListWrap   //[...] - the list of method attributes
              )
              [function]

rule isFinal(['Final(_),,_]) => true

rule isFinal([(KL:KLabel(_) => .KList),, _])
when        KL =/=KLabel 'Final

rule isFinal([.KList])      => false

endmodule
