require "core-sorts.k"
require "core-classes.k"
require "process-comp-units.k"
require "process-class-decs.k"

//@ \section{Module PROCESS-LOCAL-CLASSES}

module PROCESS-LOCAL-CLASSES
    imports CORE-SORTS
    imports CORE-CLASSES
    imports PROCESS-COMP-UNITS
    imports PROCESS-CLASS-DECS

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
      =>   setEnclosingLocalEnv(Class)
        ~> processClassDecs(setWrap(SetItem(Class)))
        ~> processTypeWithDepends(Class)
        //~> elaborateBlocks(setWrap(SetItem(Class))) Now that this class's package = Encloser, it
                                                   // will be elaborated by getInnerClasses(Encloser) that follows.

        // processClassDecs will alter <crntClass>, that's why we have to restore it at the end
        ~> localClassTransformIntoInner(Class)  //todo have to be implemented before processTypeWithDepends,
                                                //todo or processTypeWithDepends have to be non-recursive
        ~> restoreAfterProcessLocalClass(OldCrntClass, CT)

        //this is what is left from the original class declaration
        //used at runtime to compute enclosing local environment
        ~> elabRes('ClassDecStm(Class))
      ...
    </k>
    <crntClass> OldCrntClass:ClassType </crntClass>
    <contextType> CT:ContextType </contextType>

//@ Sets the enclosing local environment for this class, from the cell <elabEnv>
syntax K ::= setEnclosingLocalEnv ( ClassType )
rule <k> setEnclosingLocalEnv(Class:ClassType) => . ...</k>
     <elabEnv> ListItem(mapWrap(EnclosingLocalEnv:Map)) ...</elabEnv>
     <classType> Class </classType>
     <enclosingLocalEnv> _ => EnclosingLocalEnv </enclosingLocalEnv>

//restore the content of <crntClass> and <contextType> with the given class
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
syntax K ::= localClassTransformIntoInner ( ClassType )

rule [localClassTransformIntoInner]:
    <k>
      localClassTransformIntoInner(Class:ClassType)
      => localClassAugmentFields(Class, EnclosingLocalEnv)
      ~> localClassAugmentConsParams(Class, buildParams(EnclosingLocalEnv))
      ...
    </k>
    <elabEnv> ListItem(mapWrap(EnclosingLocalEnv:Map)) ...</elabEnv>

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

//\section{Anonymous classes}

/*Case one - anonymous class implementing an interface. The class body have nothing else
but the members provided in the anonymous class definition block.
*/
rule [elab-NewInstance-anonymous-implements-interface]:
    <k>
      elab('NewInstance(Arg1:K,, Class:ClassType,,
          elabRes('ListWrap(ActualArgs:KList)),,
          'Some('ClassBody('ListWrap(AnonClassDecs:KList)))
      ))
      => processAnonymousClass(
        String2Id("Anonymous_$" +String Int2String(LocalId)),
        objectClass,
        Class,
        Arg1,
        ActualArgs,
        AnonClassDecs,
        resultListWrap(.KList),
        resultListWrap(.KList)
      )
      ...
    </k>
    <nextLocalId> LocalId:Int => LocalId +Int 1 </nextLocalId>
    <classType> Class </classType>
    <metaType> interfaceMetaT </metaType>

rule [elab-NewInstance-anonymous-extends-class]:
    <k>
      elab('NewInstance(Arg1:K,, Class:ClassType,,
          elabRes('ListWrap(ActualArgs:KList)),,
          'Some('ClassBody('ListWrap(AnonClassDecs:KList)))
      ))
      => processAnonymousClass(
        String2Id("Anonymous_$" +String Int2String(LocalId)),
        Class,
        .KList,
        Arg1,
        ActualArgs,
        AnonClassDecs,
        buildConstructorFormalParams(ActualArgs, .KList, 0),
        buildConstructorFirstLineArgs(ActualArgs, .KList, 0)
      )
      ...
    </k>
    <nextLocalId> LocalId:Int => LocalId +Int 1 </nextLocalId>
    <classType> Class </classType>
    <metaType> classMetaT </metaType>

syntax K ::=  processAnonymousClass (
                Id,        //Class name
                ClassType, //Base class
                KList,     //Base interfaces, if any
                K,         //'NewInstance Arg1
                KList,     //ActualArgs
                KList,     //Anonymous class block decs
                K,         //To be processed into resultListWrap(constructor formal params)
                K          //To be processed into resultListWrap(constructor first line arguments)
              )

//heat constructor formal params and first line arguments
context processAnonymousClass(_,_,_,_,_,_,HOLE,_)
context processAnonymousClass(_,_,_,_,_,_,_,HOLE)

rule [processAnonymousClass]:
    processAnonymousClass(
      Name:Id,
      BaseClass:ClassType,
      BaseInterfaces:KList,
      Arg1:K,
      ActualArgs:KList,
      AnonClassDecs:KList,
      resultListWrap(ConstructorFormalParams:KList),
      resultListWrap(ConstructorFirstLineArgs:KList)
    )
    => elab(
      stmtAndExp(
        'ClassDecStm(
          'ClassDec(
            'ClassDecHead(
              'ListWrap(.KList),,
              Name,,
              'None(.KList),,
              'Some('SuperDec(BaseClass)),,
              'Some('ImplementsDec('ListWrap(BaseInterfaces)))
            ),,
            'ClassBody('ListWrap(
              AnonClassDecs,,

              //Anonymous class constructor
              'ConstrDec(
                'ConstrDecHead(
                  'ListWrap('Public(.KList)),,
                  'None(.KList),,
                  Name,,
                  'ListWrap(ConstructorFormalParams),,
                  'None(.KList)
                ),,
                'ConstrBody(
                  'Some('SuperConstrInv('None(.KList),,'ListWrap(ConstructorFirstLineArgs))),,
                  'ListWrap(.KList)
                )
              )
            ))
          )
        ),
        'NewInstance(Arg1,, 'TypeName(Name),, elabRes('ListWrap(ActualArgs)),, 'None(.KList))
      )
    )

/*@ Build the part of the constructor of an anonymous class definition corresponding
to formal params, and arguments of the superclass constructor invocation, respectively
First KList - list of actual arguments
Second KList - the result
Third arg - a counter used to generate var names
*/
syntax K ::= buildConstructorFormalParams ( KList, KList, Int )
           | buildConstructorFirstLineArgs ( KList, KList, Int )

rule buildConstructorFormalParams(
      (ActualParam:K => .KList),, _,
      _,, (.KList => 'Param('ListWrap(.KList),, typeOf(ActualParam),, String2Id("$" +String Int2String(Num) ))),
      Num:Int => Num +Int 1
    )

rule buildConstructorFormalParams(.KList, Ks:KList, _) => resultListWrap(Ks)

rule buildConstructorFirstLineArgs(
      (_:K => .KList),, _,
      _,, (.KList => 'ExprName(String2Id("$" +String Int2String(Num) ))),
      Num:Int => Num +Int 1
    )

rule buildConstructorFirstLineArgs(.KList, Ks:KList, _) => resultListWrap(Ks)

rule [elab-QNewInstance-anonymous-extends-class]:
    <k>
      elab('QNewInstance(elabRes(TypedQual:K),, elabRes(Arg2:K),, Class:ClassType,, elabRes(Arg4:K),,
          elabRes('ListWrap(ActualArgs:KList)),,
          'Some('ClassBody('ListWrap(AnonClassDecs:KList)))
      ))
      => processQAnonymousClass(
        String2Id("Anonymous_$" +String Int2String(LocalId)),
        Class,
        TypedQual,
        Arg2,
        ActualArgs,
        AnonClassDecs,
        buildConstructorFormalParams(TypedQual,,ActualArgs, .KList, 0),
        buildConstructorFirstLineArgs(TypedQual,,ActualArgs, .KList, 0)
      )
      ...
    </k>
    <nextLocalId> LocalId:Int => LocalId +Int 1 </nextLocalId>
    <classType> Class </classType>
    <metaType> classMetaT </metaType>

//Qualified anonymous class
syntax K ::=  processQAnonymousClass (
                Id,        //Class name
                ClassType, //Base class
                K,         //TypedQual - qualifier
                K,         //'NewInstance Arg2
                KList,     //ActualArgs
                KList,     //Anonymous class block decs
                K,         //To be processed into resultListWrap(constructor formal params)
                K          //To be processed into resultListWrap(constructor first line arguments)
              )

//heat constructor formal params and first line arguments
context processQAnonymousClass(_,_,_,_,_,_,HOLE,_)
context processQAnonymousClass(_,_,_,_,_,_,_,HOLE)

rule [processQAnonymousClass]:
    processQAnonymousClass(
      Name:Id,
      BaseClass:ClassType,
      TypedQual:K,
      Arg2:K,
      ActualArgs:KList,
      AnonClassDecs:KList,
      resultListWrap(ConstructorFormalParams:KList),
      resultListWrap(ConstrQual:K,, ConstructorFirstLineArgs:KList)
    )
    => elab(
      stmtAndExp(
        'ClassDecStm(
          'ClassDec(
            'ClassDecHead(
              'ListWrap(.KList),,
              Name,,
              'None(.KList),,
              'Some('SuperDec(BaseClass)),,
              'Some('ImplementsDec('ListWrap(.KList)))
            ),,
            'ClassBody('ListWrap(
              AnonClassDecs,,

              //Anonymous class constructor
              'ConstrDec(
                'ConstrDecHead(
                  'ListWrap('Public(.KList)),,
                  'None(.KList),,
                  Name,,
                  'ListWrap(ConstructorFormalParams),,
                  'None(.KList)
                ),,
                'ConstrBody(
                  'Some('QSuperConstrInv(ConstrQual,,'None(.KList),,'ListWrap(ConstructorFirstLineArgs))),,
                  'ListWrap(.KList)
                )
              )
            ))
          )
        ),
        'NewInstance(Arg2,, 'TypeName(Name),, elabRes('ListWrap(TypedQual,, ActualArgs)),, 'None(.KList))
      )
    )

endmodule
