require "core.k"
require "process-comp-units.k"
require "process-class-decs.k"
require "elaborate-blocks.k"

module PROCESS-LOCAL-CLASSES
    imports CORE
    imports PROCESS-COMP-UNITS
    imports PROCESS-CLASS-DECS
    imports ELABORATE-BLOCKS

rule [elab-ClassDecStm]:
    <k>
      elab('ClassDecStm(ClassDec:K))
      =>   processLocalClassDecStep1(ClassDec, packageId(String2Id("local_$" +String Int2String(LocalId))))
      ...
    </k>
    <nextLocalId> LocalId:Int => LocalId +Int 1 </nextLocalId>

//Register a local class in the given generated package and fully process it.
syntax K ::= "processLocalClassDecStep1" "(" K         //the 'ClassDec term
                                         "," PackageId //the generated package
                                         ")"

rule [processLocalClassDecStep1]:
    <k>
      processLocalClassDecStep1(ClassDec:K, GeneratedPack:PackageId)
      =>   processTypeNames(ClassDec, GeneratedPack)
        ~> processTypeDecsInPCUPhase(ClassDec, GeneratedPack, Class)
        ~> processLocalClassDecStep2(GeneratedPack:PackageId)
      ...
    </k>
    <crntClass> Class:ClassType </crntClass>

//Fully process the class that was registered inside the given package
syntax K ::= "processLocalClassDecStep2" "(" PackageId //the generated package
                                         ")"

rule [processLocalClassDecStep2]:
    <k>
      processLocalClassDecStep2(GeneratedPack:PackageId)
      =>   setEnclosingLocalEnv(Class)
        ~> processClassDecs(setWrap(SetItem(Class)))
        ~> processTypeWithDepends(Class)
        ~> elaborateBlocks(setWrap(SetItem(Class)))

        // processClassDecs will alter <crntClass>, that's why we have to restore it at the end
        ~> restoreAfterProcessLocalClass(OldCrntClass, CT)

        //this is what is left from the original class declaration
        //used at runtime to compute enclosing local environment
        ~> elabRes('ClassDecStm(Class))
      ...
    </k>
    <crntClass> OldCrntClass:ClassType </crntClass>
    <localTypes> ListItem(stEnv(LocalTypes:Map => LocalTypes[Class/Name])) ...</localTypes>
    <contextType> CT:ContextType </contextType>
    <typeNamesMap>... GeneratedPack |-> mapWrap(Name:Id |-> Class:ClassType) ...</typeNamesMap>

//Seths the enclosing local environment for this class, from the cell <elabEnv>
syntax K ::= "setEnclosingLocalEnv" "(" ClassType ")"
rule <k> setEnclosingLocalEnv(Class:ClassType) => . ...</k>
     <elabEnv> ListItem(stEnv(EnclosingLocalEnv:Map)) ...</elabEnv>
     <classType> Class </classType>
     <enclosingLocalEnv> _ => EnclosingLocalEnv </enclosingLocalEnv>

//restore the content of <crntClass> and <contextType> with the given class
syntax K ::= "restoreAfterProcessLocalClass" "(" ClassType //old content of <crntClass>
                                             "," ContextType //old content of <contextType>
                                             ")"

rule [restoreAfterProcessLocalClass]:
    <k> restoreAfterProcessLocalClass(Class:ClassType, CT:ContextType) => . ...</k>
    <crntClass> _ => Class </crntClass>
    <contextType> _ => CT </contextType>

//\section{Local classes - runtime}

//Initialize the registration of local environment, when a local class declaration is encoutered.
//This environment is precisely <env>. It don't contain local vars of the outer env for enclosign classes,
//in case of multi-level local classes.
rule [ClassDecStm-runtime]:
    <k> 'ClassDecStm(Class:ClassType) => . ...</k>
    <env> LocalEnv:Map </env>
    <localClassesEnv> LocalClasses:Map => LocalClasses[mapWrap(LocalEnv)/Class] </localClassesEnv>

//\section{Anonymous classes}

/*Case one - anonymous class implementing an interface. The class body have nothing else
but the members provided in the anonymous class definition block.
*/
rule [elabAnonymous-NewInstance-implements-interface]:
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

rule [elabAnonymous-NewInstance-extends-class]:
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

syntax K ::= "processAnonymousClass" "("
      Id ","        //Class name
      ClassType "," //Base class
      KList ","     //Base interfaces, if any
      K ","         //'NewInstance Arg1
      KList ","     //ActualArgs
      KList ","     //Anonymous class block decs
      K ","         //To be processed into resultListWrap(constructor formal params)
      K             //To be processed into resultListWrap(constructor first line args)
    ")"

//heat consturctor formal params and first line args
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

//Build the part of the constructor of an anonymous class definition corresponding
//to formal params, and args of the superclass constructor invocation, respectively
//First KList - list of actual args
//Second KList - the result
//Thirs arg - a counter used to generate var names
syntax K ::= "buildConstructorFormalParams" "(" KList "," KList "," Int ")"
           | "buildConstructorFirstLineArgs" "(" KList "," KList "," Int ")"

//A wrapper over an arbitrary KList, wrapper being of type KResult.
syntax KResult ::= "resultListWrap" "(" KList ")"

rule buildConstructorFormalParams(
      (_::T:Type => .KList),, _,
      _,, (.KList => 'Param('ListWrap(.KList),,T,,String2Id("$" +String Int2String(Num) ))),
      Num:Int => Num +Int 1
    )

rule buildConstructorFormalParams(.KList, Ks:KList, _) => resultListWrap(Ks)

rule buildConstructorFirstLineArgs(
      (_:K => .KList),, _,
      _,, (.KList => 'ExprName(String2Id("$" +String Int2String(Num) ))),
      Num:Int => Num +Int 1
    )

rule buildConstructorFirstLineArgs(.KList, Ks:KList, _) => resultListWrap(Ks)

rule [elabAnonymous-QNewInstance-extends-class]:
    <k>
      elab('QNewInstance(Qual:TypedExp,, Arg2:K,, Class:ClassType,, Arg4:K,,
          elabRes('ListWrap(ActualArgs:KList)),,
          'Some('ClassBody('ListWrap(AnonClassDecs:KList)))
      ))
      => processQAnonymousClass(
        String2Id("Anonymous_$" +String Int2String(LocalId)),
        Class,
        Qual,
        Arg2,
        ActualArgs,
        AnonClassDecs,
        buildConstructorFormalParams(Qual,,ActualArgs, .KList, 0),
        buildConstructorFirstLineArgs(Qual,,ActualArgs, .KList, 0)
      )
      ...
    </k>
    <nextLocalId> LocalId:Int => LocalId +Int 1 </nextLocalId>
    <classType> Class </classType>
    <metaType> classMetaT </metaType>

//Qualified anonymous class
syntax K ::= "processQAnonymousClass" "("
      Id ","        //Class name
      ClassType "," //Base class
      TypedExp ","  //Qual - qualifer
      K ","         //'NewInstance Arg2
      KList ","     //ActualArgs
      KList ","     //Anonymous class block decs
      K ","         //To be processed into resultListWrap(constructor formal params)
      K             //To be processed into resultListWrap(constructor first line args)
    ")"

//heat consturctor formal params and first line args
context processQAnonymousClass(_,_,_,_,_,_,HOLE,_)
context processQAnonymousClass(_,_,_,_,_,_,_,HOLE)

rule [processQAnonymousClass]:
    processQAnonymousClass(
      Name:Id,
      BaseClass:ClassType,
      Qual:TypedExp,
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
        'NewInstance(Arg2,, 'TypeName(Name),, elabRes('ListWrap(Qual,, ActualArgs)),, 'None(.KList))
      )
    )

//Wrapper of a statement followed by an expression, to be used in a place where an expression is expected,
//such as an anonymous class declaration. Is typed with the type of the expression.
//At runtime is rewritten into the statement, that should evaluate into .K, followed by the expression,
//that should evaluate to value.
syntax K ::= "stmtAndExp" "(" K "," K ")"

//elaboration time
rule elabDispose(stmtAndExp(Stmt:K, Exp:K ::T:Type))
     =>  elabRes(stmtAndExp(Stmt,   Exp   ::T     ) :: T)

//runtime
rule stmtAndExp(Stmt:K, TExp:TypedExp)::_ => Stmt ~> TExp

endmodule
