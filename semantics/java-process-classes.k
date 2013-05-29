require "java-core.k"
require "java-elaborate-blocks.k"

module JAVA-PROCESS-CLASSES
    imports JAVA-CORE
    imports JAVA-ELABORATE-BLOCKS

//no semantics for 'Abstract and 'NoMethodBody required
//existing semantics for methods covers them too
syntax KLabel ::= "'ThrowsDec" | "'Abstract" | "'NoMethodBody"

syntax K ::= "getContextType" "(" K //'ListWrap(...) - the list of method attributes
                              ")"                           [function]

rule getContextType('ListWrap('Static(_),,_)) => staticCT   [anywhere]

rule getContextType('ListWrap((KL:KLabel(_) => .List{K}),, _))
when        KL =/=KLabel 'Static                            [anywhere]

rule getContextType('ListWrap(.List{K}))      => instanceCT [anywhere]

//@ \section{Process type list}
syntax K ::= "processClasses" "("
                                  K //setWrap(Set) - the set of all classes
                              ")"         [strict]
           | "processTypeWithDepends" "("
                                ClassType  //the class to be processed,
                                           //or noClass if no processing is required
                            ")"
           | "processType" "("
                                ClassType  //the class to be processed
                            ")"

/*@ \subsection{Third pass - processing class members} */

//We need to process Object first. Thus when we will process any interfaces,
//Object class will be already processed.
rule [StartProcessClassesPhase]:
    <k> . => processTypeWithDepends(objectClass) ~> processClasses(getAllClasses) </k>
    <computationPhase> ProcessClassDecsPhase => ProcessClassesPhase </computationPhase>

rule [processClasses]:
    (. => processTypeWithDepends(Class))
    ~>  processClasses(setWrap( (SetItem(Class:ClassType) => .) _:Set))

rule [ProcessTypeListDiscard]:
    processClasses(setWrap(.)) => .

rule [processTypeWithDepends]:
    <k>
      processTypeWithDepends(Class:ClassType)
      => processTypeWithDepends(BaseClass) ~> processClasses(setWrap(ISet)) ~> processType(Class)
      ...
    </k>
    <classType> Class </classType>
    <extends> BaseClass:ClassType </extends>
    <implements> ISet:Set </implements>
    <preprocessingPhase> DecsProcessedCPP </preprocessingPhase>

rule [processTypeWithDependsDiscard]:
    <k> processTypeWithDepends(Class:ClassType) => . ...</k>
    <classType> Class </classType>
    <preprocessingPhase> MembersProcessedCPP </preprocessingPhase>

rule [processTypeWithDependsDiscard2]:
    processTypeWithDepends(noClass) => .K

/*For each class compute the set of inherited interfaces, inherit all the members,
process inner declaraions. Compute the following class cells:
  <implTrans>
  <fieldDecs>
  <methods>
  <instanceInit>
  <staticEnv>
  <staticInit>
  <staticInitLocations>
*/
rule [ProcessType]:
    <k>
      processType(Class:ClassType) => computeImplTrans(SetItem(BaseClass) ISet)
          ~> tryInheritSet(ISet)

          //interfaces should also contain Object members
          ~> 'If((MetaT ==K interfaceMetaT)::bool,, tryInherit(objectClass))

          ~> tryInherit(BaseClass)
          ~> inheritInterfaceFields
          ~> Decls
      ...
    </k>
    <class>
      <classType> Class </classType>
      <extends> BaseClass:ClassType </extends>
      <implements> ISet:Set </implements>
      <implTrans> . => ISet </implTrans>
      ( <declarations> Decls:K </declarations> => .Bag)
      <metaType> MetaT:MetaType </metaType>
      <preprocessingPhase> DecsProcessedCPP => MembersProcessedCPP </preprocessingPhase>
      ...
    </class>
    <cuClass> _ => Class </cuClass>

//compute <implTrans> cell - interfaces transitively implemented
syntax K ::= "computeImplTrans" "(" Set ")"

rule [computeImplTrans]:
    <k>
      (. => saveImplTrans(setUnion(ITrans, BaseItfITrans)))
      ~> computeImplTrans( (SetItem(BaseItf:ClassType) => .) _)
      ...
    </k>
    <cuClass> Class:ClassType </cuClass>
    <classType> Class </classType>
    <implTrans> ITrans:Set </implTrans>
    <classType> BaseItf </classType>
    <implTrans> BaseItfITrans:Set </implTrans>

rule [computeImplTransElemDiscard]: computeImplTrans( (SetItem(noClass) => .) _)

rule [computeImplTransDiscard]: computeImplTrans(.) => .

syntax K ::= "saveImplTrans" "(" K //setWrap(ISet) - transitive set of inherited interfaces
                             ")"  [strict]

rule <k> saveImplTrans(setWrap(S1:Set)) => . ...</k>
     <cuClass> Class:ClassType </cuClass>
     <classType> Class </classType>
     <implTrans> _ => S1 </implTrans>

//inherits the methods of the base class, based on rules in JLS $8.4.8 paragraph 1
syntax K ::= "tryInheritSet" "(" Set ")"
           | "tryInherit" "(" ClassType ")"
           | "tryInheritImpl" "(" Map ")"
           | "inherit" "(" Map ")"  //when checks are made, we are inheriting the method

rule [tryInheritSet]:
    (. => tryInherit(Class:ClassType)) ~> tryInheritSet( (SetItem(Class) => .) _)

rule [tryInheritSetDiscard]: tryInheritSet(.) => .

rule [tryInherit]:
    <k>
      tryInherit(Class:ClassType) => tryInheritImpl(Env)
      ...
    </k>
    <classType> Class </classType>
    <methods> Env:Map </methods>

rule [tryInheritDiscard]:
    tryInherit(noClass) => .K

rule [tryInheritImplUnfold]:
    <k> (. => tryInheritImpl(MI)) ~> tryInheritImpl( (MI:MapItem => .) _:MapItem _) ...</k>

rule [tryInheritImpl]:
    <k>
      tryInheritImpl(Sig:K |-> DecClass:ClassType)
      => 'If(
            isInheritable(getMethodAccessMode(TV)),,
            inherit(Sig |-> DecClass),,
            .K
          )
      ...
    </k>
    <classType> DecClass </classType>
    <methodDecs>... Sig |-> TV:TypedVal ...</methodDecs>

rule [tryInheritImplDiscard]: tryInheritImpl(.) => .

syntax K ::= "isInheritable" "(" K ")"                        [strict]
rule isInheritable(public) => true::bool
rule isInheritable(protected) => true::bool

//Object class cannot match this rule since it has public access mode
rule [isInheritablePackage]:
    <k>
      isInheritable(package)
      => kEq(getPackage(getTopLevel(Class)), getPackage(getTopLevel(BaseClass)))
      ...
    </k>
    <cuClass> Class:ClassType </cuClass>
    <class>
      <classType> Class </classType>
      <extends> BaseClass:ClassType </extends>
      ...
    </class>

rule isInheritable(private) => false::bool

//todo if the same method is inherited say from the base class and interface,
//we're in trouble
rule [inherit]:
    <k> inherit(Sig:K |-> DeclClass:ClassType) => . ...</k>
    <cuClass> Class:ClassType </cuClass>
    <class>
      <classType> Class </classType>
      <methods> Env:Map => Env[DeclClass/Sig] </methods>
      ...
    </class>

//returns the access mode of a method closure given as argument
syntax K ::= "getMethodAccessMode" "(" TypedVal ")"   [function]
rule getMethodAccessMode( _ :: methodType(Acc:AccessMode, _,_,_ ) ) => Acc [anywhere]

//returns the context type of a method closure given as argument
syntax K ::= "getMethodContextType" "(" TypedVal ")"  [function]
rule getMethodContextType( methodClosure(_, _, CT:ContextType, _) :: _ ) => CT [anywhere]
rule getMethodContextType( constrClosure(_,_,_,_) :: _ ) => instanceCT [anywhere]

//returns the class in which this method was defined
syntax K ::= "getMethodDeclaringClass" "(" TypedVal ")"   [function]
rule getMethodDeclaringClass( _ :: methodType(_, Class:ClassType, _,_ ) ) => Class [anywhere]

/*@ \subsection{Method declaration}
Methods are now typed and we need to store their types in their
closures, so that their type contract can be checked at invocation
time.  The rule below is conceptually similar to that of untyped KOOL;
the only difference is the addition of the types.  */

//resolving the return type
context 'MethodDec('MethodDecHead(_:K,, _:K,, HOLE,, _),, _)

//resolving parameters, order is not important
context 'MethodDec('MethodDecHead(_:K,, _:K,, _:Type,, _:Id,, 'ListWrap(_,, HOLE,, _),, _:K),, _:K)

rule [MethodDec]:
    <k>
      'MethodDec(
        'MethodDecHead(Modifiers:K,, _:K,, ReturnType:Type,, Name:Id,,
            'ListWrap(Params:List{K}),, _:K
        ),,
        S:K
      )
      => storeMethod(Name, getTypesFromParams(Params), 'ListWrap(Params),
            getContextType(Modifiers), S,
            methodType(getAccessMode(Modifiers), Class, getTypesFromParams(Params), ReturnType))
      ...
    </k>
    <cuClass> Class:ClassType </cuClass>
when isKResult(Params)
        [structural]

rule [AbstractMethodDec]:
    'AbstractMethodDec(_:K,, Ks:List{K})
    =>  'MethodDec(
          'MethodDecHead('ListWrap('Public(.List{K}),,'Abstract(.List{K})),, Ks),,
          'NoMethodBody(.List{K})
        )

syntax K ::= "storeMethod" "("
                              Id ","  //method name
                              K ","   //will evaluate to Types - a syntactic list of types
                              K ","   //'ListWrap(Params)
                              K ","   //will evaluate to ContextType - staticCT or instanceCT
                              K ","   //S - method body
                              Type    //method closure type
                           ")"

syntax Types ::= "types" "(" List{K} // list of Type elements, when processed
                         ")"
syntax KResult ::= Types

syntax K     ::= "getTypesFromParams" "(" List{K} // list of paramImpl terms,
                                               // to be processed into Type terms
                                      ")"
               | "getTypesFromParams" "(" List{K} "," //resulting types
                                          List{K}     //source paramImpl terms
                                      ")"

rule getTypesFromParams(Ks:List{K}) => getTypesFromParams(.List{K}, Ks:List{K})
        [structural, anywhere]

rule getTypesFromParams(Ts:List{K}, paramImpl(T:Type, _),, Ks:List{K})
     => getTypesFromParams(Ts,, T, Ks)
        [structural, anywhere]

rule getTypesFromParams(Ts:List{K}, .List{K}) => types(Ts)
        [structural, anywhere]

rule [storeMethod]:
    <k>
      storeMethod(Name:Id, Ts:Types, 'ListWrap(Params:List{K}), CT:ContextType, Body:K,
          MethodType:Type) => .
      ...
    </k>
    <cuClass> Class:ClassType </cuClass>
    <classType> Class </classType>
    <methods> Env:Map => Env[Class / sig(Name,Ts)] </methods>
    <methodDecs>
      DecsEnv:Map => DecsEnv[
        methodClosure(Class, 'ListWrap(Params), CT, Body) :: MethodType / sig(Name,Ts)
      ]
    </methodDecs>

//A method signature
//KResult is required in java-method-invoke module
syntax KResult ::= "sig" "(" Id "," Types ")"

rule [ConstrDecSuperCallDesugar]:
    <k>
      'ConstrDec(
        'ConstrDecHead(_:K,, _:K,, Name:Id,, _:List{K}),,
        'ConstrBody(
          (
            'None(_)
            => 'Some('SuperConstrInv( 'None(.List{K}),, 'ListWrap(.List{K}) ))
          ),,
          _:K
        )
      )
      ...
    </k>
    <cuClass> Class:ClassType </cuClass>
when
    Class =/=K objectClass

rule [ConstrDecObjectDesugar]:
    <k>
      'ConstrDec(
        'ConstrDecHead(_:K,, _:K,, Name:Id,, _:List{K}),,
        'ConstrBody(
          (
            'None(_) => 'Some(.K)
          ),,
          _:K
        )
      )
      ...
    </k>
    <cuClass> Class:ClassType </cuClass>
when
    Class ==K objectClass

//resolving constructor parameters, order is not important
context 'ConstrDec('ConstrDecHead(_:K,, _:K,, _:Id,, 'ListWrap(_,, HOLE,, _),, _),, _:K)

rule [ConstrDec]:
    <k>
      'ConstrDec('ConstrDecHead(Modifiers:K,, _:K,, Name:Id,, 'ListWrap(Params:List{K}),, _),,
          'ConstrBody(
        'Some(FirstLine:K) ,,S:K))
      => storeConstructor(Name, 'ListWrap(Params), FirstLine,
          S, methodType(getAccessMode(Modifiers), Class, getTypesFromParams(Params), void))
      ...
    </k>
    <cuClass> Class:ClassType </cuClass>
when isKResult(Params)

syntax K ::= "storeConstructor" "(" Id    // Class name
                                "," K     // 'ListWrap(Params) - formal params
                                "," K     // FirstLine - SyperConstrInv()
                                "," K     // S - constructor body
                                "," Type  // MethodType of the constructor
                                ")"

rule [storeConstructor]:
    <k>
      storeConstructor(Name:Id, 'ListWrap(Params:List{K}), FirstLine:K, S, MethodType:Type) => .
      ...
    </k>
    <cuClass> Class:ClassType </cuClass>
    <classType> Class </classType>
    <methods> Env:Map => Env[Class / sig(getConsName(Class), getTypesFromParams(Params))] </methods>
    <methodDecs>
      DecsEnv:Map => DecsEnv[
        constrClosure(Class, 'ListWrap(Params), FirstLine, S:K) :: MethodType
          / sig(getConsName(Class), getTypesFromParams(Params))
      ]
    </methodDecs>

//@get internal constructor name from a class
syntax K ::= "getConsName" "(" ClassType ")"                               [function]

rule getConsName(class ClassId:Id) => String2Id("$cons$" +String Id2String(ClassId))
        [structural, anywhere]

//resolve field declaration type
context 'FieldDec(_:K,, HOLE,, _)

rule [FieldDecMultiDesugar]:
    (. => 'FieldDec(SomeK,, T,, 'ListWrap(K1))) ~>
    'FieldDec(SomeK:K,, T:Type,, 'ListWrap((K1:K => .List{K}),, K2:K,, Ks:List{K}))

rule [FieldDecInstanceInitDesugar]:
    'FieldDec(Modifiers:K,, T:Type,, 'ListWrap('VarDec(X:Id,,(InitExp:K => .List{K})) ))
    ~> (. => 'InstanceInit('ExprStm('Assign('Field(X),, InitExp))))
when
            (getKLabel(InitExp) =/=KLabel 'ArrayInit)
    andBool (getContextType(Modifiers) ==K instanceCT)
        [structural]

rule [FieldDecToLocalVarDec]:
    <k> 'FieldDec(Modifiers:K,, T:Type,, 'ListWrap('VarDec(X:Id))) => . ...</k>
    <cuClass> Class:ClassType </cuClass>
    <classType> Class </classType>
    <fieldDecs>
      'ListWrap(_,, ( .List{K} => 'LocalVarDec(T,, 'ListWrap('VarDec(X))) ))
    </fieldDecs>
    <instanceEnv> Env:Map => Env[fieldEntry(Class,X,T, instanceCT)/X] </instanceEnv>
when
    getContextType(Modifiers) ==K instanceCT
        [structural]

rule [InstanceInitSave]:
    <k> 'InstanceInit(K:K) => . ...</k>
    <cuClass> Class:ClassType </cuClass>
    <classType> Class </classType>
    <instanceInit> 'ListWrap(_,,(.List{K} => K)) </instanceInit>
        [structural]

rule [FieldDecStaticInitDesugar]:
    'FieldDec(Modifiers:K,, T:Type,, 'ListWrap('VarDec(X:Id,,(InitExp:K => .List{K})) ))
    ~> (. => 'StaticInit('ExprStm('Assign('Field(X),, InitExp))))
when
            (getKLabel(InitExp) =/=KLabel 'ArrayInit)
    andBool (getContextType(Modifiers) ==K staticCT)
        [structural]

rule [StaticFieldDecToLocalVarDec]:
    <k> 'FieldDec(Modifiers:K,, T:Type,, 'ListWrap('VarDec(X:Id))) => . ...</k>
    <cuClass> Class:ClassType </cuClass>
    <classType> Class </classType>
    <staticEnv> Env:Map => Env[L/X] </staticEnv>
    <staticInitLocations> _ (. => SetItem(L)) </staticInitLocations>
    <store>... . => L |-> uninitialized(Class,T) ...</store>
    <nextLoc> L:Int => L +Int 1 </nextLoc>
when
    getContextType(Modifiers) ==K staticCT
        [structural]

rule [StaticInitSave]:
    <k> 'StaticInit(K:K) => . ...</k>
    <cuClass> Class:ClassType </cuClass>
    <classType> Class </classType>
    <staticInit> 'ListWrap(_,,(.List{K} => K)) </staticInit>
        [structural]

/*@ The parser represents interface fields as 'ConstantDec labels.
  This rule desugars them into 'FieldDec labels and adds the modifiers "public static final".
*/
rule [ConstantDecDesugar]:
    'ConstantDec('ListWrap(ModifiersKs:List{K}),, TypeK:K,, VarDecs:K)
    => 'FieldDec(
          'ListWrap(ModifiersKs,, 'Public(.List{K}),, 'Static(.List{K}),, 'Final(.List{K})),,
          TypeK,, VarDecs
        )

//Discard inner class declarations at this phase. They are processed when their
//respective <class> tag is encountered as part of processClasses
rule [ClassDecDiscard]: 'ClassDec(_) => .
rule [InterfaceDecDiscard]: 'InterfaceDec(_) => .

/*@ This procedure adds all the fields in <staticEnv> of all implemented interfaces
into the <staticEnv> of the current class (<cuClass>), in order to be resolved
by variable lookup algorithms.
This procedure is invoked before processing class declarations,
thus class declarations override declarations inherited from interfaces.
*/
syntax K ::= "inheritInterfaceFields"
           | "inheritInterfaceFields" "(" Set "," //set of interfaces to be inherited
                                          K       //mapWrap(Env) map of inherited fields,
                                      ")"         [strict(2)]

rule [inheritInterfaceFieldsStart]:
    <k> inheritInterfaceFields => inheritInterfaceFields(ISet, mapWrap(.Map)) ...</k>
    <cuClass> Class:ClassType </cuClass>
    <classType> Class </classType>
    <implements> ISet:Set </implements>

rule [inheritInterfaceFields]:
    <k>
      inheritInterfaceFields(SetItem(Intf:ClassType) ISet:Set, mapWrap(Env:Map))
      => inheritInterfaceFields(ISet, mapUnion(Env, IntfEnv))
      ...
    </k>
    <classType> Intf </classType>
    <staticEnv> IntfEnv:Map </staticEnv>

rule [inheritInterfaceFieldsEnd]:
    <k>
      inheritInterfaceFields(.Set, mapWrap(Env:Map)) => .
      ...
    </k>
    <cuClass> Class:ClassType </cuClass>
    <classType> Class </classType>
    <staticEnv> _ => Env </staticEnv>

/*@Initial value of static fields. Used to detect the moment when static initialziation
should be triggered, especially for interfaces.
*/
syntax K ::= "uninitialized" "(" ClassType "," // Class - the declaring class
                                 Type          // Type of the variable
                             ")"

/*@Section process 'Param labels*/

context 'Param(_:K,, HOLE,, _:K)
rule 'Param(_:K,, T:Type,, X:Id) => paramImpl(T,X)

syntax KResult ::= "paramImpl" "(" Type "," Id ")"  //processed representation of a 'Param label

endmodule
