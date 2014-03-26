require "core-sorts.k"
require "core-classes.k"
require "process-comp-units.k"
require "process-class-decs.k"
require "elaboration-vars.k"

//@ \section{Module PROCESS-LOCAL-CLASSES}

module PROCESS-LOCAL-CLASSES
    imports CORE-SORTS
    imports CORE-CLASSES
    imports PROCESS-COMP-UNITS //for processTypeDecsInPCUPhase
    imports PROCESS-CLASS-DECS //for processClassDecs
    imports ELABORATION-VARS   //for elabLookup

/*@ ClassDecStm('ClassDec(...))
*/
syntax KLabel ::= "'ClassDecStm"

rule [elab-ClassDecStm]:
    elab('ClassDecStm(ClassDec:K)) => processLocalClassDec( ClassDec, generateLocalClassType(ClassDec), false )

//@ generates a ClassType for the given 'ClassDec term representign a local class
syntax K ::=  generateLocalClassType(
                K //ClassDec
              )

rule [generateLocalClassType]:
    <k>
      generateLocalClassType('ClassDec('ClassDecHead( _:K,, ClassName:Id,, _:K,, _:K,, _:K ),, _:K))
      => getClassType(toPackage(CrntClass), String2Id(Id2String(ClassName) +String "$" +String Int2String(LocalId)))
      ...
    </k>
    <crntClass> CrntClass:ClassType </crntClass>
    <nextLocalId> LocalId:Int => LocalId +Int 1 </nextLocalId>

//@ Register a local class in the given generated package and fully process it.
syntax K ::=  processLocalClassDec (
                K,          //the 'ClassDec term
                ClassType,  //GeneratedClass:ClassType at substep 1, .K when generated name have been registered.
                Bool        //ClassRegistered - false for substep 1, true for substep 2.
              )
              [strict(2)]

rule [processLocalClassDec-register-name]:
    <k>
      processLocalClassDec(
        'ClassDec(
          'ClassDecHead(
          ( 'ListWrap(OldModifiers:KList) => generateLocalClassModifiers( CT, OldModifiers ) ),,
            (InitName:Id => getSimpleName(GeneratedClass)),,
            _:K,, _:K,, _:K
          ),, _:K
        ),
        GeneratedClass:ClassType, false => true
      )
      ...
    </k>
    <localTypes> ListItem(mapWrap(LocalTypes:Map => LocalTypes[GeneratedClass / InitName])) ...</localTypes>
    <contextType> CT:ContextType </contextType>

//@ The second argument: existing modifiers
syntax K ::= generateLocalClassModifiers( ContextType, KList )  [function]
rule generateLocalClassModifiers( CT:ContextType, OldModifiers:KList )
     => #if CT ==K staticCT
          #then 'ListWrap('Static(.KList),,OldModifiers)
          #else 'ListWrap(OldModifiers)
        #fi

rule [processLocalClassDec-process]:
    <k>
      processLocalClassDec(ClassDec:K, Class:ClassType, true)
      => registerClass(ClassDec, toPackage(CrntClass), Class, CrntClass)
        ~> localClassTransformIntoInner(Class, localClassGetAccessibleOuterEnv(Class))

        //this is what is left from the original class declaration
        //used at runtime to compute enclosing local environment
        ~> appendToElabBuffer(elabRes('ClassDecStm(Class)))
        ~> loadElabBuffer
      ...
    </k>
    <crntClass> CrntClass:ClassType </crntClass>

/*@ Passes the freshly discovered/constructed class declaration through all the preprocessing steps
  except elaboration. Only usable for individual classes, when the rest of the classpath is already preprocessed.
*/
syntax K ::=  registerClass(
                K,          // ClassDec:K,
                PackageId,  // Pack:PackageId,
                ClassType,  // Class:ClassType,
                ClassType   // EnclosingClass:ClassType
              )

rule [registerClass]:
    registerClass(ClassDec:K, Pack:PackageId, Class:ClassType, EnclosingClass:ClassType)
    =>   processTypeNames(ClassDec, Pack)
      ~> processTypeDecsInPCUPhase(ClassDec, Pack, EnclosingClass)
      ~> processClassDecs(setWrap(SetItem(Class)))
      ~> processTypeWithDepends(Class)
      //~> elaborateBlocks(setWrap(SetItem(Class))) Now that this class's package = Encloser, it
                                                 // will be elaborated by getInnerClasses(Encloser) that follows.

/*@ Computes the accessible outer local environment for the given local class.
  {Accessible outer env} = (the whole outer env} - {all names X that could be resolved by elabLookup(Class, X)}
  elabLookup don't search the var in otuer classes. Just in this class and base classes.
*/
syntax K ::=  localClassGetAccessibleOuterEnv( ClassType )
            | localClassGetAccessibleOuterEnv(
                ClassType,  //the local class
                Map,        //The full outer local environment
                Map,        //The filtered outer local environment
                Id,         //Temporary. The last searched var name. Necessary if it is constant
                K           //Temporary. Tests each local var if it is also a field
              )
              [strict(5)]

rule [localClassGetAccessibleOuterEnv-start]:
    <k>
      localClassGetAccessibleOuterEnv(Class:ClassType)
      => localClassGetAccessibleOuterEnv(Class, EnclosingLocalEnv, .Map, .K, noValue)
      ...
    </k>
    <elabEnv> ListItem(mapWrap(EnclosingLocalEnv:Map)) ...</elabEnv>

rule [localClassGetAccessibleOuterEnv-start-test]:
    localClassGetAccessibleOuterEnv(
      Class:ClassType,
      (X:Id |-> T:Type => .Map) _:Map,
      (.Map => X:Id |-> T:Type) _:Map,
      _ => X,
      noValue => elabLookup(X, Class)
    )

rule [localClassGetAccessibleOuterEnv-test-found]:
    localClassGetAccessibleOuterEnv(
      Class:ClassType,
      _:Map,
      (X:Id |-> _ => .Map) _:Map,
      X:Id,
      KR:KResult => noValue
    )
when
    KR =/=K noValue

rule [localClassGetAccessibleOuterEnv-end]:
    localClassGetAccessibleOuterEnv( Class:ClassType, .Map, NewOuterEnv:Map, _, noValue ) => mapWrap(NewOuterEnv)

/*@ Convert the given local class into an equivalent inner class, with the following transformations:
  - Add a field to the class for each outer local variable
  - For each constructor add an argument for each outer local variable
*/
syntax K ::=  localClassTransformIntoInner (
                ClassType,  //the local class
                K           // computes into mapWrap(Map[Id |-> Type]) - the accessible outer local var environment
              )
              [strict(2)]

rule [localClassTransformIntoInner]:
    <k>
      localClassTransformIntoInner(Class:ClassType, mapWrap(AccessibleLocalEnv:Map))
      => #if notBool isEmpty(AccessibleLocalEnv) ==K true
           #then localEnvObjectBuild(generateLocalEnvClassType(Class), AccessibleLocalEnv)
                 ~> localClassAugmentFields(Class, generateLocalEnvClassType(Class))
                 ~> localClassAugmentConsParams(Class, getConsName(Class), generateLocalEnvClassType(Class))
           #else .K
         #fi
    ...
    </k>
    <classType> Class </classType>
    <enclosingLocalEnv> _ => AccessibleLocalEnv </enclosingLocalEnv>

syntax K ::= generateLocalEnvClassType( ClassType )                              [function]
rule generateLocalEnvClassType(class X:Id) => class String2Id(Id2String(X) +String "$LocalEnv")

/*@ Add the given fields definitions to the given class. The class is in MembersProcessedCPhase*/
syntax K ::=  localEnvObjectBuild (
                K,          // LocalEnvClass - The name of the local env class
                Map         // Map[Name |-> Type] - the fields
              )
              [strict(1)]

rule [localEnvObjectBuild]:
    <k>
      localEnvObjectBuild(LocalEnvClass:ClassType, AccessibleLocalEnv:Map)
      => localEnvClassAddFieldsAndRegister(
            'ClassDec(
              'ClassDecHead(
                generateLocalClassModifiers( CT, .KList ),,
                getSimpleName(LocalEnvClass),,
                'None(.KList),,
                'None(.KList),,
                'None(.KList)
              ),,
              'ClassBody('ListWrap(.KList))
            ),
            LocalEnvClass,
            AccessibleLocalEnv
         )
      ~> appendToElabBuffer(elab(
            'LocalVarDec('None(.KList),, LocalEnvClass,, 'ListWrap('VarDec(
              generateLocalEnvVarName(LocalEnvClass),,
              'NewInstance('None(.KList),, LocalEnvClass,, 'ListWrap(.KList),, 'None(.KList) )
            )))
         ))
      ~> localEnvObjectSetFields(
            generateLocalEnvVarName(LocalEnvClass),
            AccessibleLocalEnv
      )
      ...
    </k>
    <contextType> CT:ContextType </contextType>

syntax K ::=  localEnvClassAddFieldsAndRegister(
                K,          // 'ClassDec
                ClassType,  // LocalEnvClass
                Map         // AccessibleLocalEnv
              )

rule [localEnvClassAddFieldsAndRegister-add-field]:
    localEnvClassAddFieldsAndRegister(
      'ClassDec(
        'ClassDecHead(_:KList),,
        'ClassBody('ListWrap(_,, ( .KList => 'FieldDec('ListWrap(.KList),, T,, 'ListWrap('VarDec(X))) )))
      ), _,
      (X:Id |-> T:Type => .Map) _:Map
    )

rule [localEnvClassAddFieldsAndRegister-register]:
    <k>
      localEnvClassAddFieldsAndRegister( ClassDec:K, LocalEnvClass:ClassType, .Map )
      => registerClass(ClassDec, toPackage(CrntClass), LocalEnvClass, CrntClass)
      ...
    </k>
    <crntClass> CrntClass:ClassType </crntClass>

//@ should be function because Id is not a KResult
syntax K ::= generateLocalEnvVarName( ClassType )   [function]
rule generateLocalEnvVarName(class X:Id) => String2Id(Id2String(X) +String "_obj")

syntax K ::=  localEnvObjectSetFields(
                Id,    // LocalEnvVar
                Map    // AccessibleLocalEnv
              )

rule [localEnvObjectSetFields]:
    (. => appendToElabBuffer(elab( 'ExprStm('Assign('Field('ExprName(LocalEnvVar),,X),, 'ExprName(X))) )))
    ~> localEnvObjectSetFields(
      LocalEnvVar:Id,
      (X:Id |-> _:Type => .Map) _:Map
    )

rule [localEnvObjectSetFields-discard]:
    localEnvObjectSetFields(_, .Map) => .K

/*@ Add the given fields definitions to the given class. The class is in MembersProcessedCPhase*/
syntax K ::=  localClassAugmentFields (
                ClassType,  // LocalClass
                ClassType   // LocalEnvClass
              )

rule [localClassAugmentFields]:
    <k> localClassAugmentFields(LocalClass:ClassType, LocalEnvClass:ClassType) => .K ...</k>
    <classType> LocalClass </classType>
    <fieldDecs>
      'ListWrap(_,, ( .KList => 'LocalVarDec(.K,, LocalEnvClass,, 'ListWrap('VarDec(String2Id("$local_env")))) ) )
    </fieldDecs>

syntax K ::=  localClassAugmentConsParams (
                ClassType,  // LocalClass
                Id,         // ConsName - constructor name
                ClassType   // LocalEnvClass
              )
              [strict(2)]

rule [localClassAugmentConsParams-augment]:
    <k> localClassAugmentConsParams(LocalClass:ClassType, ConsName:Id, LocalEnvClass:ClassType) ...</k>
    <classType> LocalClass </classType>
    <methods> sig(ConsName:Id, types(TList:KList,, (.KList => LocalEnvClass))) |-> _ ...</methods>
    <methodDecs>
      sig(ConsName:Id, types(TList:KList,, (.KList => LocalEnvClass)))
      |-> (MClosure:K => addFormalParams(MClosure, 'Param(.K,, LocalEnvClass,, String2Id("$local_env"))))
      ...
    </methodDecs>
when
    notBool getLastKListElement(TList) ==K LocalEnvClass

rule [localClassAugmentConsParams-end]:
    <k> localClassAugmentConsParams(LocalClass:ClassType, ConsName:Id, LocalEnvClass:ClassType) => .K ...</k>
    <classType> LocalClass </classType>
    <methods> Methods:Map </methods>
    <methodDecs> MethodDecs:Map </methodDecs>
when
    notBool haveUnaugmentedConstructors(ConsName, LocalEnvClass, Methods) ==K true

syntax K ::= haveUnaugmentedConstructors( Id, ClassType, Map )                [function]
rule haveUnaugmentedConstructors(ConsName:Id, LocalEnvClass:ClassType,
                                 (sig(ConsName:Id, types(TList:KList)) |-> _) _:Map) => true
when
    notBool getLastKListElement(TList) ==K LocalEnvClass

//@ Add to the given methodClosure the given formal parameters
syntax K ::= addFormalParams ( K, KList)                     [function]

rule addFormalParams( methodClosure(_, 'ListWrap(ExistingParams:KList,, (.KList => NewParams)), _,_,_,_,
                      Body:K => 'ListWrap(extraParamAssignments(NewParams),, Body)
                      )
                      ::methodType(sig( Name:Id, types(TList:KList) => getTypes(TList,, NewParams) ), _),
                      NewParams:KList => .KList)
when
    length(NewParams) >Int 0

rule addFormalParams( MClosure:K, .KList) => MClosure

syntax K ::= extraParamAssignments( KList ) [function]

rule extraParamAssignments('Param(_:K,,_:Type,,X:Id),, Rest:KList)
     => 'ExprStm('Assign( 'Field('This(.KList),, X ),, 'ExprName( X ) )),,
        extraParamAssignments(Rest:KList)

rule extraParamAssignments(.KList) => .KList

//@ Elaborates the given node and saves it to <elabBuffer>
syntax K ::= appendToElabBuffer ( K ) //[strict, context(result(ElabKResult))] //K bug generalized strictness
context appendToElabBuffer ( HOLE )              [result(ElabKResult)]

rule [appendToElabBuffer]:
    <k> appendToElabBuffer(elabRes(K:K)) => . ...</k>
    <elabBuffer> 'ListWrap(_,, (.KList => K)) </elabBuffer>

syntax K ::= "loadElabBuffer"

rule [loadElabBuffer]:
    <k> loadElabBuffer => elabRes(ElabBuffer) ...</k>
    <elabBuffer> ElabBuffer:K => 'ListWrap(.KList) </elabBuffer>

//\section{Local classes - runtime}

/*@ Initialize the registration of local environment, when a local class declaration is encountered.
This environment is precisely <env>. It don't contain local vars of the outer env for enclosing classes,
in case of multi-level local classes.*/
rule [ClassDecStm-runtime]:  //todo probably have to be removed
    'ClassDecStm(Class:ClassType) => .K

endmodule
