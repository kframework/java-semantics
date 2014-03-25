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

todo # Define an outer env class for each local class, at the place of local class definition.
todo # Add to outer env class one field for each outer local var.
  We only need to save the direct local environment. If this is a deep local class,
  indirect local variables will be resolved by the variable lookup mechanism when it will analyse the enclosing class.
  There's no need to change anything here.
todo # Instantiate the outer env class.
todo # Assign to each outer env class field its respective value
todo # Augment each local class constructor with one extra argument - the outer env object
See http://java-semantics.myjetbrains.com/youtrack/issue/KJ-55 for more details.
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
            'ListWrap( (.KList => #if CT ==K staticCT #then 'Static(.KList) #else 'StrictFP(.KList)/*vacuous*/ #fi),,
                        _ ),,
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

rule [processLocalClassDec-process]:
    <k>
      processLocalClassDec(ClassDec:K, Class:ClassType, true)
      => registerClass(ClassDec, toPackage(CrntClass), Class, CrntClass)
        ~> localClassTransformIntoInner(Class, localClassGetAccessibleOuterEnv(Class))

        //this is what is left from the original class declaration
        //used at runtime to compute enclosing local environment
        ~> elabRes('ClassDecStm(Class))
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
      => localClassAugmentFields(Class, AccessibleLocalEnv)
      ~> localClassAugmentConsParams(Class, buildParams(AccessibleLocalEnv))
    ...
    </k>
    <classType> Class </classType>
    <enclosingLocalEnv> _ => AccessibleLocalEnv </enclosingLocalEnv>

rule [localClassAddFields]:
    <k> localClassAugmentFields(Class:ClassType, ((X:Id |-> T:Type => .Map) _:Map)) ...</k>
    <classType> Class </classType>
    <fieldDecs> 'ListWrap(_,, ( .KList => 'LocalVarDec(.K,, T,, 'ListWrap('VarDec(X))) )) </fieldDecs>

rule [localClassAddFields-end]:
    localClassAugmentFields(Class:ClassType, .Map) => .K

/*@ Add the given fields definitions to the given class. The class is in MembersProcessedCPhase*/
syntax K ::=  localClassAugmentFields (
                ClassType,  //The class to be processed
                Map         // Map[Name |-> Type] - the fields
              )

/*@ Converts the given map of the form Map[Name |-> Type] into into KList['Param()]
*/
syntax K ::= buildParams ( Map )
          |  buildParams ( Map, KList )

rule buildParams(Env:Map) => buildParams(Env, .KList)
rule buildParams((Env:Map X:Id |-> T:Type), KL:KList) => buildParams(Env, ('Param(.K,, T,, X),, KL:KList))
rule buildParams(.Map, KL:KList) => resultListWrap(KL)

/*@ Adds the given params at the end of each constructor declaration of the given class.
*/
syntax K ::=  localClassAugmentConsParams (
                ClassType,  // the augmented class
                K           // params to add
              ) [strict(2)]
            | localClassAugmentConsParams (
                ClassType,  // the augmented class
                K,          // params to add
                Map,        // MethodDecs - the methods of the given class. Target for constructors search
                Map,        // new MethodDecs - the augmented methods of the class.
                Map,        //Methods
                Map         // new Methods
              )

rule [localClassAugmentConsParams-start]:
    <k>
      localClassAugmentConsParams(Class:ClassType, resultListWrap(Params:KList))
      => localClassAugmentConsParams(Class, resultListWrap(Params), MethodDecs, .Map, Methods, .Map)
      ...
    </k>
    <classType> Class </classType>
    <methods> Methods:Map </methods>
    <methodDecs> MethodDecs:Map </methodDecs>

rule [localClassAugmentConsParams-method]:
    localClassAugmentConsParams( Class:ClassType, _, ( (sig(Name:Id, Ts:Types) |-> MClosure:K => .Map) _:Map),
                                                     ( (.Map => sig(Name:Id, Ts:Types) |-> MClosure:K) _:Map),
                                 _,_)
when
    Name =/=K getConsName(Class)

rule [localClassAugmentConsParams-constructor]:
    localClassAugmentConsParams( Class:ClassType, resultListWrap(NewParams:KList),
                                 ( (sig(Name:Id, types(TList:KList)) |-> MClosure:K => .Map) _:Map),
            ( (.Map => sig(Name:Id, getTypes(TList,, NewParams)) |-> addFormalParams(MClosure, NewParams)) _:Map),
            (sig(Name:Id, types(TList:KList)) |-> DeclClass:ClassType => .Map) _,
            (.Map => sig(Name:Id, getTypes(TList,, NewParams)) |-> DeclClass:ClassType) _)
when
    Name ==K getConsName(Class)

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

rule [localClassAugmentConsParams-discard]:
    <k>
      localClassAugmentConsParams(Class:ClassType,_, .Map, NewMethodDecs:Map,
                                  RemainingMeth:Map, TransformedMeth:Map) => .K
      ...
    </k>
    <classType> Class </classType>
    <methods> _ => RemainingMeth TransformedMeth </methods>
    <methodDecs> _ => NewMethodDecs </methodDecs>

//\section{Local classes - runtime}

/*@ Initialize the registration of local environment, when a local class declaration is encountered.
This environment is precisely <env>. It don't contain local vars of the outer env for enclosing classes,
in case of multi-level local classes.*/
rule [ClassDecStm-runtime]:
    <k> 'ClassDecStm(Class:ClassType) => . ...</k>
    <env> LocalEnv:Map </env>
    <localClassesEnv> LocalClasses:Map => LocalClasses[mapWrap(LocalEnv)/Class] </localClassesEnv>

endmodule
