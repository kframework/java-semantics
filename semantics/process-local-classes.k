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

//@ ClassDecStm('ClassDec(...))
syntax KLabel ::= "'ClassDecStm"

rule [elab-ClassDecStm]:
    <k>
      elab('ClassDecStm(ClassDec:K))
      =>   processLocalClassDecStep1( ClassDec, toPackage(CrntClass),
              getClassType(toPackage(CrntClass),
                           String2Id(Id2String(getNameFromClassDec(ClassDec)) +String "$" +String Int2String(LocalId))),
              false
           )
      ...
    </k>
    <crntClass> CrntClass:ClassType </crntClass>
    <nextLocalId> LocalId:Int => LocalId +Int 1 </nextLocalId>

syntax K ::=  getNameFromClassDec ( K //the 'ClassDec(...)
                                  )  [function]
rule getNameFromClassDec('ClassDec('ClassDecHead( _:K,, Name:Id,, _:K,, _:K,, _:K ),, _:K)) => Name

//@ Register a local class in the given generated package and fully process it.
syntax K ::=  processLocalClassDecStep1 (
                K,          //the 'ClassDec term
                PackageId,  //the package = the enclosing class
                ClassType,  //GeneratedClass:ClassType at substep 1, .K when generated name have been registered.
                Bool        //ClassRegistered - false for substep 1, true for substep 2.
              )

rule [processLocalClassDecStep1-register-name]:
    <k>
      processLocalClassDecStep1(
        'ClassDec(
          'ClassDecHead(
            'ListWrap( (.KList => #if CT ==K staticCT #then 'Static(.KList) #else 'StrictFP(.KList)/*vacuous*/ #fi),,
                        _ ),,
            (InitName:Id => getSimpleName(GeneratedClass)),,
            _:K,, _:K,, _:K
          ),, _:K
        ),
        Pack:PackageId, GeneratedClass:ClassType, false => true
      )
      ...
    </k>
    <localTypes> ListItem(mapWrap(LocalTypes:Map => LocalTypes[GeneratedClass / InitName])) ...</localTypes>
    <contextType> CT:ContextType </contextType>

rule [processLocalClassDecStep1-process]:
    <k>
      processLocalClassDecStep1(ClassDec:K, Pack:PackageId, Class:ClassType, true)
      =>   processTypeNames(ClassDec, Pack)
        ~> processTypeDecsInPCUPhase(ClassDec, Pack, CrntClass)
        ~> processLocalClassDecStep2(Class)
      ...
    </k>
    <crntClass> CrntClass:ClassType </crntClass>

//@ Fully process the local class
syntax K ::=  processLocalClassDecStep2 (
                ClassType //the generated class
              )

rule [processLocalClassDecStep2]:
    <k>
      processLocalClassDecStep2(Class:ClassType)
      =>   processClassDecs(setWrap(SetItem(Class)))
        ~> processTypeWithDepends(Class)
        //~> elaborateBlocks(setWrap(SetItem(Class))) Now that this class's package = Encloser, it
                                                   // will be elaborated by getInnerClasses(Encloser) that follows.

        // processClassDecs will alter <crntClass>, that's why we have to restore it at the end
                                                        //todo have to be implemented before processTypeWithDepends,
                                                        //todo or processTypeWithDepends have to be non-recursive
        ~> localClassTransformIntoInner(Class, localClassGetAccessibleOuterEnv(Class))
        ~> restoreAfterProcessLocalClass(OldCrntClass, CT)

        //this is what is left from the original class declaration
        //used at runtime to compute enclosing local environment
        ~> elabRes('ClassDecStm(Class))
      ...
    </k>
    <crntClass> OldCrntClass:ClassType </crntClass>
    <contextType> CT:ContextType </contextType>

/*@ Computes the accessible outer local environment for the given local class. */
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

//@ Restore the content of <crntClass> and <contextType> with the given class
syntax K ::=  restoreAfterProcessLocalClass (
                ClassType, //old content of <crntClass>
                ContextType //old content of <contextType>
              )

rule [restoreAfterProcessLocalClass]:
    <k> restoreAfterProcessLocalClass(Class:ClassType, CT:ContextType) => . ...</k>
    <crntClass> _ => Class </crntClass>
    <contextType> _ => CT </contextType>

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
      localClassTransformIntoInner(Class:ClassType, mapWrap(EnclosingLocalEnv:Map))
      => localClassAugmentFields(Class, EnclosingLocalEnv)
      ~> localClassAugmentConsParams(Class, buildParams(EnclosingLocalEnv))
    ...
    </k>
    <classType> Class </classType>
    <enclosingLocalEnv> _ => EnclosingLocalEnv </enclosingLocalEnv>

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
