module PROCESS-LOCAL-CLASSES
    imports CORE-SORTS
    imports CORE-CLASSES
    imports PROCESS-COMP-UNITS //for processTypeDecsInPCUPhase
    imports PROCESS-CLASS-DECS //for processClassDecs
    imports PROCESS-CLASS-MEMBERS //for processTypeWithDepends
    imports ELABORATION-VARS   //for elabLookup

// ClassDecStm('ClassDec(...))

rule [elab-ClassDecStm]:
    elab('ClassDecStm(ClassDec:K)) => processLocalClassDec( ClassDec, generateLocalClassType(ClassDec), false )

//@ generates a ClassType for the given 'ClassDec term representign a local class
syntax KItem ::=  generateLocalClassType(
                K //ClassDec
              )

rule [generateLocalClassType]:
    <k>
      generateLocalClassType('ClassDec('ClassDecHead( _:KListWrap,, ClassName:Id,, _:K,, _:K,, _:K ),, _:K))
      => getClassType(toPackage(CrntClass), String2Id(Id2String(ClassName) +String "$" +String Int2String(LocalId)))
      ...
    </k>
    <crntClass> CrntClass:ClassType </crntClass>
    <nextLocalId> LocalId:Int => LocalId +Int 1 </nextLocalId>

//@ Register a local class in the given generated package and fully process it.
syntax KItem ::=  processLocalClassDec (
                K,          //the 'ClassDec term
                ClassType,  //GeneratedClass:ClassType at substep 1, .K when generated name has been registered.
                Bool        //ClassRegistered - false for substep 1, true for substep 2.
              )
              [strict(2)]

rule [processLocalClassDec-register-name]:
    <k>
      processLocalClassDec(
        'ClassDec(
          'ClassDecHead(
          ( [OldModifiers:KList] => generateLocalClassModifiers( CT, [OldModifiers] ) ),,
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
syntax KListWrap ::= generateLocalClassModifiers( ContextType, KListWrap )  [function]
rule generateLocalClassModifiers( CT:ContextType, [OldModifiers:KList] )
     => #if CT ==K staticCT
          #then ['Static(.KList),,OldModifiers]
          #else [OldModifiers]
        #fi

rule [processLocalClassDec-process]:
    <k>
      processLocalClassDec(ClassDec:K, Class:ClassType, true)
      => registerClass(ClassDec, toPackage(CrntClass), Class, CrntClass)
        ~> localClassTransformIntoInner(Class, localClassGetAccessibleOuterEnv(Class))
        ~> loadElabBuffer
      ...
    </k>
    <crntClass> CrntClass:ClassType </crntClass>

/*@ Passes the freshly discovered/constructed class declaration through all the preprocessing steps
  except elaboration. Only usable for individual classes, when the rest of the classpath is already preprocessed.
*/
syntax KItem ::=  registerClass(
                K,          // ClassDec:K,
                PackageId,  // Pack:PackageId,
                ClassType,  // Class:ClassType,
                ClassType   // EnclosingClass:ClassType
              )

rule [registerClass]:
    registerClass(ClassDec:K, Pack:PackageId, Class:ClassType, EnclosingClass:ClassType)
    =>   processTypeNames([ClassDec], Pack)
      ~> processTypeDecsInPCUPhase([ClassDec], Pack, EnclosingClass)
      ~> processClassDecs(setWrap(SetItem(Class)))
      ~> processTypeWithDepends(Class)
      //~> elaborateBlocks(setWrap(SetItem(Class))) Now that this class's package = Encloser, it
                                                 // will be elaborated by getInnerClasses(Encloser) that follows.

/*@ Computes the accessible outer local environment for the given local class.
  \{Accessible outer env\} = \{the whole outer env\} - \{all names X that could be resolved by elabLookup(Class, X)\}
  elabLookup don't search the var in otuer classes. Just in this class and base classes.
*/
syntax KItem ::=  localClassGetAccessibleOuterEnv( ClassType )
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
syntax KItem ::=  localClassTransformIntoInner (
                ClassType,  //the local class
                K           // computes into mapWrap(Map[Id |-> Type]) - the accessible outer local var environment
              )
              [strict(2)]

rule [localClassTransformIntoInner]:
    localClassTransformIntoInner(Class:ClassType, mapWrap(AccessibleLocalEnv:Map))
    => #if notBool isEmpty(AccessibleLocalEnv) ==K true
         #then localClassTransformIntoInnerImpl(Class:ClassType,
                  mapWrap(
                    AccessibleLocalEnv:Map
                    generateLocalEnvVarName(generateLocalEnvClassType(Class)) |-> generateLocalEnvClassType(Class)
                  )
               )
         #else .K
       #fi

/*@ Same as localClassTransformIntoInner but AccessibleLocalEnv has one more entry
    - the field LocaClass@LocalEnv\_obj that will be created later, a self reference required when a local class
    instantiates either itself or an enclosing local class. See tests 957, 958.
*/
syntax KItem ::=  localClassTransformIntoInnerImpl (
                ClassType,  //the local class
                K           // computes into mapWrap(Map[Id |-> Type]) - the accessible outer local var environment
              )

rule [localClassTransformIntoInnerImpl]:
    <k>
      localClassTransformIntoInnerImpl(Class:ClassType, mapWrap(AccessibleLocalEnv:Map))
      =>  localEnvObjectBuild(generateLocalEnvClassType(Class), AccessibleLocalEnv)
          ~> localClassAugmentFields(Class, generateLocalEnvClassType(Class))
          ~> localClassAugmentConsParams(Class, getConsName(Class), generateLocalEnvClassType(Class))
    ...
    </k>
    <classType> Class </classType>
    <enclosingLocalEnv> _ => AccessibleLocalEnv </enclosingLocalEnv>

syntax KItem ::= generateLocalEnvClassType( ClassType )                              [function]
rule generateLocalEnvClassType(class X:Id) => class String2Id(Id2String(X) +String "$LocalEnv")

/*@ Add the given fields definitions to the given class. The class is in MembersProcessedCPhase*/
syntax KItem ::=  localEnvObjectBuild (
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
                generateLocalClassModifiers( CT, [.KList] ),,
                getSimpleName(LocalEnvClass),,
                'None(.KList),,
                'None(.KList),,
                'None(.KList)
              ),,
              'ClassBody([.KList])
            ),
            LocalEnvClass,
            AccessibleLocalEnv
         )
      ~> appendToElabBuffer(elab(
            'LocalVarDec('None(.KList),, LocalEnvClass,, ['VarDec(
              generateLocalEnvVarName(LocalEnvClass),,
              'NewInstance('None(.KList),, LocalEnvClass,, [.KList],, 'None(.KList) )
            )])
         ))
      ~> localEnvObjectSetFields(
            generateLocalEnvVarName(LocalEnvClass),
            AccessibleLocalEnv
      )
      ...
    </k>
    <contextType> CT:ContextType </contextType>

syntax KItem ::=  localEnvClassAddFieldsAndRegister(
                K,          // 'ClassDec
                ClassType,  // LocalEnvClass
                Map         // AccessibleLocalEnv
              )

rule [localEnvClassAddFieldsAndRegister-add-field]:
    localEnvClassAddFieldsAndRegister(
      'ClassDec(
        'ClassDecHead(_:KList),,
        'ClassBody([_,, ( .KList => 'FieldDec([.KList],, T,, ['VarDec(X)]) )])
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
syntax KItem ::= generateLocalEnvVarName( ClassType )   [function]
rule generateLocalEnvVarName(class X:Id) => String2Id(Id2String(X) +String "_obj")

syntax KItem ::=  localEnvObjectSetFields(
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
syntax KItem ::=  localClassAugmentFields (
                ClassType,  // LocalClass
                ClassType   // LocalEnvClass
              )

rule [localClassAugmentFields]:
    <k> localClassAugmentFields(LocalClass:ClassType, LocalEnvClass:ClassType) => .K ...</k>
    <classType> LocalClass </classType>
    <instanceFields>
      [_,, ( .KList => 'FieldDec([ .KList ],, LocalEnvClass,, ['VarDec(String2Id("$local_env"))]) ) ]
    </instanceFields>

syntax KItem ::=  localClassAugmentConsParams (
                ClassType,  // LocalClass
                Id,         // ConsName - constructor name
                ClassType   // LocalEnvClass
              )
syntax Params ::= addElementToParamsEnd (Params, Param) [function]
rule addElementToParamsEnd(.Params, P:Param) => P,.Params
rule addElementToParamsEnd((Hd:Param, Tl:Params), P:Param) => Hd,addElementToParamsEnd(Tl,P)

rule [localClassAugmentConsParams-augment]:
    <k> localClassAugmentConsParams(LocalClass:ClassType, ConsName:Id, LocalEnvClass:ClassType) ...</k>
    <classType> LocalClass </classType>
    <methods> sig(ConsName:Id, types(TList:KList,, (.KList => LocalEnvClass))) |-> _ ...</methods>
    <methodSignature> sig(ConsName:Id, types(TList:KList,, (.KList => LocalEnvClass))) </methodSignature>
    <methodParams> Ps:Params => addElementToParamsEnd(Ps, (.AnnoVarModList LocalEnvClass String2Id("$local_env"))) </methodParams>
    <methodBody>
      Body:K => [
        'ExprStm('Assign(
          'Field('This(.KList),, String2Id("$local_env") ),,
          'ExprName( String2Id("$local_env") )
        )),,
        Body
      ]
    </methodBody>
when
    notBool getLastKListElement([TList]) ==K LocalEnvClass

rule [localClassAugmentConsParams-end]:
    <k> localClassAugmentConsParams(LocalClass:ClassType, ConsName:Id, LocalEnvClass:ClassType) => .K ...</k>
    <classType> LocalClass </classType>
    <methods> Methods:Map </methods>
when
    notBool haveUnaugmentedConstructors(ConsName, LocalEnvClass, Methods) ==K true

syntax KItem ::= haveUnaugmentedConstructors( Id, ClassType, Map )                [function]
rule haveUnaugmentedConstructors(ConsName:Id, LocalEnvClass:ClassType,
                                 (sig(ConsName:Id, types(TList:KList)) |-> _) _:Map) => true
when
    notBool getLastKListElement([TList]) ==K LocalEnvClass

//@ Elaborates the given node and saves it to <elabBuffer>
syntax KItem ::= appendToElabBuffer ( K ) //[strict, context(result(ElabKResult))] //K bug generalized strictness
context appendToElabBuffer ( HOLE )              [result(ElabKResult)]

rule [appendToElabBuffer]:
    <k> appendToElabBuffer(elabRes(K:K)) => . ...</k>
    <elabBuffer> [_,, (.KList => K)] </elabBuffer>

syntax KItem ::= "loadElabBuffer"

rule [loadElabBuffer]:
    <k> loadElabBuffer => elabRes(ElabBuffer) ...</k>
    <elabBuffer> ElabBuffer:K => [.KList] </elabBuffer>

//@\subsection{Utility functions for other modules}

syntax KItem ::= localClassGetExtraArgs( ClassType )

/*@ When <enclosingLocalEnv> is not empty (only possible for certain local classes),
  we add one more argument to the consturctor call - the local environment object. */
rule [elab-QNewInstance-local-augment-arguments]:
    <k>
      localClassGetExtraArgs(Class:ClassType)
      => #if notBool isEmpty(EnclosingLocalEnv) ==K true
            #then #if Class ==K CrntClass
                    #then elab(['ExprName(String2Id("$local_env"))])
                    #else elab(['ExprName(generateLocalEnvVarName(generateLocalEnvClassType(Class)))])
                  #fi
            #else elab([.KList])
         #fi
      ...
    </k>
    <crntClass> CrntClass:ClassType </crntClass>
    <classType> Class </classType>
    <enclosingLocalEnv> EnclosingLocalEnv:Map </enclosingLocalEnv>

endmodule
