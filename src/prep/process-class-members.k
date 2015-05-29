module PROCESS-CLASS-MEMBERS
    imports CORE-SORTS
    imports CORE-CLASSES
    imports CORE-PREPROCESSING

/*@ \subsection{Third pass - processing class members} */

/*@ We need to process Object first. Thus when we will process any interfaces,
    Object class will already be processed.*/
rule [Start-ProcClassMembersPhase]:
    <k> . => processTypeWithDepends(classObject) ~> processClasses(getTopLevelClasses) </k>
    <globalPhase> ProcClassDecsPhase => ProcClassMembersPhase  </globalPhase>

syntax KItem ::=  processClasses (
                K //setWrap(Set) - the set of all classes
              )
              [strict]

rule [processClasses]:
    (. => processTypeWithDepends(Class))
    ~>  processClasses(setWrap( (SetItem(Class:ClassType) => .Set) _:Set))

rule [processClasses-Discard]:
    processClasses(setWrap(.Set)) => .

syntax KItem ::=  processTypeWithDepends (
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

syntax KItem ::=  processType (
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
          ~> ifAux((MetaT ==K interfaceCMT), tryInherit(classObject), .K)

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
      <implTrans> .Set => ISet </implTrans>
      ( <rawDeclarations> Decls:K </rawDeclarations> => .Bag)
      <classMetaType> MetaT:ClassMetaType </classMetaType>
      <classPhase> DecsProcessedCPhase => MembersProcessedCPhase </classPhase>
      ...
    </class>

rule 'ClassBodyDecList(Hd:K,,Tl:K) => Hd ~> Tl
rule .ClassBodyDecList => .

rule 'InterfaceMemberDecList(Hd:K,,Tl:K) => Hd ~> Tl
rule .InterfaceMemberDecList => .

//Could happen when hierarchies of inheritance and that of enclosing get messed up.
rule [processType-discard]:
    <k> processType(Class:ClassType) => . ...</k>
    <classType> Class </classType>
    <classPhase> MembersProcessedCPhase </classPhase>

//@ Compute <implTrans> cell - interfaces transitively implemented
syntax KItem ::= computeImplTrans ( Set )

rule [computeImplTrans]:
    <k>
      (. => saveImplTrans(setUnion(setWrap(ITrans), setWrap(BaseItfITrans))))
      ~> computeImplTrans( (SetItem(BaseItf:ClassType) => .Set) _)
      ...
    </k>
    <crntClass> Class:ClassType </crntClass>
    <classType> Class </classType>
    <implTrans> ITrans:Set </implTrans>
    <classType> BaseItf </classType>
    <implTrans> BaseItfITrans:Set </implTrans>

rule [computeImplTrans-Elem-Discard]: computeImplTrans( (SetItem(noClass) => .Set) _)

rule [computeImplTrans-Discard]: computeImplTrans(.Set) => .K

syntax KItem ::=  saveImplTrans (
                K //setWrap(ISet) - transitive set of inherited interfaces
              )
              [strict]

rule <k> saveImplTrans(setWrap(S1:Set)) => . ...</k>
     <crntClass> Class:ClassType </crntClass>
     <classType> Class </classType>
     <implTrans> _ => S1 </implTrans>

//@ Inherits the methods of the base class, based on rules in JLS \$8.4.8 paragraph 1
syntax KItem ::= tryInheritSet ( Set )
           | tryInherit ( ClassType )
           | tryInheritImpl ( Map )
           | tryInheritImpl ( K , K )

rule [tryInheritSet]:
    (.K => tryInherit(Class:ClassType)) ~> tryInheritSet( (SetItem(Class) => .Set) _)

rule [tryInheritSet-Discard]: tryInheritSet(.Set) => .K

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
    (.K => tryInheritImpl(M, I)) ~> tryInheritImpl((M:K |-> I:K => .Map) _:Map)

rule [tryInheritImpl]:
    tryInheritImpl(Sig:K , DecClass:ClassType)
    => ifAux(
          isInheritable(getMethodAccessMode(methodRef(Sig, DecClass))),
          inherit(methodRef(Sig, DecClass)),
          .K
       )

rule [tryInheritImpl-empty-Discard]: tryInheritImpl(.Map) => .K

syntax KItem ::= isInheritable ( AccessMode )                        [strict]

rule [isInheritable]:
    <k>
      isInheritable(BaseAccessMode:AccessMode)
      => isOverridden(BaseClass, BaseAccessMode, Class)
      ...
    </k>
    <crntClass> Class:ClassType </crntClass>
    <classType> Class </classType>
    <extends> BaseClass:ClassType </extends>

//A copy of isOverridden from METHOD-INVOKE
syntax KItem ::=  isOverridden (
                ClassType,  //BaseC
                AccessMode, //BaseAcc
                ClassType   //SubC
              )

rule isOverridden(_, public,    _) => true
rule isOverridden(_, protected, _) => true

// Object class cannot match this rule since it has public access mode
rule isOverridden(BaseC:ClassType, package, SubC:ClassType)
    => eqAux(getPackage(getTopLevel(BaseC)), getPackage(getTopLevel(SubC)))

rule isOverridden(_, private, _) => false

/*@ Inherit a method by the current class. The inherited method overwrites previous methods
  with the same signature in <methods>
*/
syntax KItem ::=  inherit ( MethodRef )

rule [inherit]:
    <k> inherit(methodRef(Sig:Signature, DecClass:ClassType)) => . ...</k>
    <crntClass> Class:ClassType </crntClass>
    <classType> Class </classType>
    <methods> Env:Map => Env[Sig <- DecClass] </methods>

/*@ \subsection{Method declaration}
Methods are now typed and we need to store their types in their
closures, so that their type contract can be checked at invocation
time.  The rule below is conceptually similar to that of untyped KOOL;
the only difference is the addition of the types.  */

/*
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

//resolving the return type
context 'MethodDec('MethodDecHead(_,, _,, HOLE,, _,, _,, _),, _)

//Resolve parameter types
context 'MethodDec('MethodDecHead(_,, _,, _:Type,, _:Id,, HOLE,, _),, _) [result(Params)]

rule [MethodDec]:
    <k>
      'MethodDec(
        'MethodDecHead(Modifiers:AnnoMethodModList,, _:K,, ReturnType:Type,, Name:Id,,Params:Params,, _:K),,
        Body:K //could be 'Block([...]) or 'NoMethodBody
      )
      => storeMethod(Params,
            getContextType(Modifiers), getAccessMode(Modifiers), isSynchronizedModifiers(Modifiers), methodMMT, noValue, Body,
            sig(Name, getTypes(Params)), ReturnType)
      ...
    </k>
    <crntClass> Class:ClassType </crntClass>

rule [AbstractMethodDec]:
    'AbstractMethodDec(_:AnnoAbstractMethodModList,, Ks:KList)
    =>  'MethodDec(
          'MethodDecHead('AnnoMethodModList('Public(.KList),,'AnnoMethodModList('Abstract(.KList),, .AnnoMethodModList)),, Ks),,
          'NoMethodBody(.KList)
        )

syntax KItem ::=  storeMethod (
                Params,   //[Params]
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
      storeMethod(Params, CT:ContextType, Acc:AccessMode, false::bool, MMT:MethodMetaType, FirstLine:K,
                  Body:K, Sig:Signature, ReturnType:Type) => .
      ...
    </k>
    <crntClass> Class:ClassType </crntClass>
    <classType> Class </classType>
    <methods> Env:Map => Env[Sig <- Class] </methods>
    ( .Bag => <methodDec>
                     <methodSignature> Sig </methodSignature>
                     <methodReturnType> ReturnType </methodReturnType>
                     <methodParams> Params </methodParams>
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
    if this class already has a default constructor.
*/
rule [storeMethod-discard-default-constructor]:
    <k>
      storeMethod(.Params,_,_,_, constructorMMT, _,_, Sig:Signature, _) => .
      ...
    </k>
    <crntClass> Class:ClassType </crntClass>
    <classType> Class </classType>
    <methods>... Sig |-> _ ...</methods>

//Resolve parameter types
context 'ConstrDec('ConstrDecHead(_,, _,, _:Id,, HOLE,, _),, _)   [result(Params)]

rule [ConstrDec-SuperCall-Desugar]:
    <k>
      'ConstrDec(
        'ConstrDecHead(_:K,, _:K,, Name:Id,, _:KList),,
        'ConstrBody(
          (
            'None(_)
            => 'Some('SuperConstrInv( 'None(.KList),, .Exps ))
          ),,
          _:K
        )
      )
      ...
    </k>
    <crntClass> Class:ClassType </crntClass>
when
    Class =/=K classObject

//We don't have synchorinzed as AnnoConstrMod, the fouth argument for storeMethod can be false directly
rule [ConstrDec-Object]:
    <k>
      'ConstrDec(
        'ConstrDecHead(Modifiers:AnnoConstrModList,, _:K,, Name:Id,, Params:Params,, _),,
        'ConstrBody(
          (
            'None(_)
          ),,
          BodyKs:K
        )
      )
      => storeMethod(Params,
                instanceCT, getAccessMode(Modifiers), false::bool, constructorMMT, .K,
                'Block(BodyKs), sig(getConsName(Class), getTypes(Params)), void)
      ...
    </k>
    <crntClass> Class:ClassType </crntClass>
when
    Class ==K classObject

rule [ConstrDec]:
    <k>
      'ConstrDec('ConstrDecHead(Modifiers:AnnoConstrModList,, _:K,, Name:Id,, Params:Params,, _),,
          'ConstrBody(
        'Some(FirstLine:K) ,,BodyKs:K))
      => storeMethod(Params,
          instanceCT, getAccessMode(Modifiers), false::bool, constructorMMT, FirstLine,
          'Block(
            //Performance problem - the #if below adds 3s of execution to helloWorld, 25s total, Windows.
            //Invocation of instance initializer converted into a method.
              'BlockStmList(
              if (getKLabel(FirstLine) ==KLabel 'SuperConstrInv orBool getKLabel(FirstLine) ==KLabel 'QSuperConstrInv)
              String2Id("$instance_init")(.Exps); ,,
              BodyKs)
          ),
          sig(getConsName(Class), getTypes(Params)), void)
      ...
    </k>
    <crntClass> Class:ClassType </crntClass>

// 'FieldDec(Modifiers,, T:Type,, ['VarDec(X:Id,, InitExp:K),, _])

//resolve field declaration type todo use strictness instead
context 'FieldDec(_,, HOLE,, _)

rule [FieldDec-Multi-Desugar]:
    (. => 'FieldDec(SomeK,, T,, 'VarDecList(K1,, .VarDecList))) ~>
    'FieldDec(SomeK:K,, T:Type,, ('VarDecList(K1:K,, 'VarDecList(K2:K,, Ks:K)) => 'VarDecList(K2,, Ks)))

rule [FieldDec-with-init-desugar]:
    'FieldDec(Modifiers:AnnoFieldModList,, T:Type,, 'VarDecList('VarDec(X:Id,,(InitExp:K => .KList)),, .VarDecList))
    ~> (. => 'InstanceInit('ExprStm('Assign('ExprName(X),, InitExp))))
when
            (getKLabel(InitExp) =/=KLabel 'ArrayInit)
    andBool (getContextType(Modifiers) ==K instanceCT)
        [structural]

rule [FieldDec-Instance]:
    <k> 'FieldDec(Modifiers:AnnoFieldModList,, T:Type,, 'VarDecList('VarDec(X:Id),, .VarDecList)) => . ...</k>
    <crntClass> Class:ClassType </crntClass>
    <classType> Class </classType>
    <instanceFields> [_,, ( .KList => 'FieldDec(.AnnoFieldModList,, T,, 'VarDecList('VarDec(X:Id),, .VarDecList)) )] </instanceFields>
when
    getContextType(Modifiers) ==K instanceCT
        [structural]


rule [InstanceInit]:
    <k> 'InstanceInit(K:K) => . ...</k>
    <crntClass> Class:ClassType </crntClass>
    <classType> Class </classType>
    <instanceInit> [_,,(.KList => K)] </instanceInit>
        [structural]

/*@ Desugaring a static field declaration with initializer into a declaration without initializer.
Followed by a static initializer block, if this field is not a compile-time constant.*/
rule [FieldDec-StaticInit-Desugar]:
    'FieldDec(Modifiers:AnnoFieldModList,, T:Type,, 'VarDecList('VarDec(X:Id,,(InitExp:K => .KList)),, .VarDecList))
    ~> (. => 'StaticInit('ExprStm('Assign('ExprName(X),, InitExp))))
when
            (getKLabel(InitExp) =/=KLabel 'ArrayInit)
    andBool (getContextType(Modifiers) ==K staticCT)

    //condition for not being compile-time constant
    andBool notBool(        isFinalModifiers(Modifiers)
                    andBool (getKLabel(InitExp) ==KLabel 'Lit orBool isKResult(InitExp) ==K true)
                   )
        [structural]

rule [FieldDec-Static]:
    <k> 'FieldDec(Modifiers:AnnoFieldModList,, T:Type,, 'VarDecList('VarDec(X:Id),, .VarDecList)) => . ...</k>
    <crntClass> Class:ClassType </crntClass>
    <classType> Class </classType>
    <staticFields> [_,, ( .KList => 'FieldDec('AnnoFieldModList('Static(.KList),, .AnnoFieldModList),, T,, 'VarDecList('VarDec(X),, .VarDecList)) )] </staticFields>
when
    getContextType(Modifiers) ==K staticCT
        [structural]


rule [StaticInit-Save]:
    <k> 'StaticInit(K:K) => . ...</k>
    <crntClass> Class:ClassType </crntClass>
    <classType> Class </classType>
    <staticInit> [_,,(.KList => K)] </staticInit>
        [structural]


/*@ The parser represents interface fields as 'ConstantDec labels.
  This rule desugars them into 'FieldDec labels and adds the modifiers "public static final".
  Interface fields are not necessarily compile-time constants.
*/
rule [ConstantDec-Desugar]:
    'ConstantDec(ModifiersKs:AnnoConstantModList,, TypeK:K,, VarDecs:K)
    => 'FieldDec(
          'AnnoFieldModList('Public(.KList),, 'AnnoFieldModList('Static(.KList),, 'AnnoFieldModList('Final(.KList),,
          ConstantToFieldModifiers(ModifiersKs)))),,
          TypeK,, VarDecs
        )

syntax AnnoFieldModList ::= ConstantToFieldModifiers ( AnnoConstantModList ) [function]
                           |ConstantToFieldModifiers ( AnnoConstantModList, AnnoFieldModList ) [function]
rule ConstantToFieldModifiers(C) => ConstantToFieldModifiers(C, .AnnoFieldModList)
rule ConstantToFieldModifiers(Hd:AnnoConstantMod Tl:AnnoConstantModList, F) => ConstantToFieldModifiers(Tl, 'AnnoFieldModList(Hd,,F))
rule ConstantToFieldModifiers(.AnnoConstantModList, F) => F

/*@Subsection compile-time constants*/

//compute the value of a compile-time constant
context 'FieldDec(Modifiers:AnnoFieldModList,, T:Type,, 'VarDecList('VarDec(X:Id,, HOLE),, .VarDecList))
when
            getContextType(Modifiers) ==K staticCT
    //condition for not being compile-time constant
    andBool isFinalModifiers(Modifiers) andBool getKLabel(HOLE) ==KLabel 'Lit

rule [FieldDec-compile-time-constant]:
    <k>
      'FieldDec(Modifiers:AnnoFieldModList,, T:Type,, 'VarDecList('VarDec(X:Id,, TV:TypedVal),, .VarDecList)) => .
      ...
    </k>
    <crntClass> Class:ClassType </crntClass>
    <classType> Class </classType>
    <constantEnv> Env:Map => Env[X <- TV] </constantEnv>
when
            getContextType(Modifiers) ==K staticCT
    andBool isFinalModifiers(Modifiers)

/*@ Discard inner class declarations at this phase. They are processed when their
    respective <class> tag is encountered as part of processClasses.
*/
rule [ClassDec-discard]: 'ClassDec(_) => .
rule [InterfaceDec-discard]: 'InterfaceDec(_) => .

syntax KItem ::= "convertInstanceInitIntoMethod"

rule [convertInstanceInitIntoMethod]:
    <k>
      convertInstanceInitIntoMethod
      => storeMethod(.Params, instanceCT, private, false::bool, methodMMT, noValue, 'Block([InstanceInitKs]),//todo
                      sig(String2Id("$instance_init"), types(.KList)), void)
      ...
    </k>
    <crntClass> Class:ClassType </crntClass>
    <classType> Class </classType>
    (<instanceInit> [InstanceInitKs:KList] </instanceInit> => .Bag)

//@ \subsection{Auxiliary functions}

//@ Evaluates to true::bool if synchronized is among modifiers, false otherwise
syntax KItem ::=  isSynchronizedModifiers (
                AnnoMethodModList       //[...] - the list of method attributes
              )
              [function]

rule isSynchronizedModifiers(synchronized _:AnnoMethodModList) => true::bool
rule isSynchronizedModifiers(.AnnoMethodModList) => false::bool
rule isSynchronizedModifiers(Hd Rest:AnnoMethodModList) => isSynchronizedModifiers(Rest) when Hd =/=K synchronized

//@ Used to provide an approximate implementation of the distinction between static constant and non-constant fields.
syntax KItem ::=  isFinalModifiers (
                AnnoFieldModList   //[...] - the list of method attributes
              )
              [function]

rule isFinalModifiers(final _) => true
rule isFinalModifiers(Hd Rest:AnnoFieldModList) => isFinalModifiers(Rest) when Hd =/=K final
rule isFinalModifiers(.AnnoFieldModList) => false

endmodule
