require "java-core.k"
require "java-process-comp-units.k"
require "java-process-class-decs.k"
require "java-elaborate-blocks.k"

module JAVA-PROCESS-LOCAL-CLASSES
    imports JAVA-CORE
    imports JAVA-PROCESS-COMP-UNITS
    imports JAVA-PROCESS-CLASS-DECS
    imports JAVA-ELABORATE-BLOCKS

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

//lookup the given local var from the enclosing class. For local classes only.
//Outer local vars may be only read, never written.
syntax K ::= "outerLocalVar" "(" Id ")" //the var name
           | "outerLocalVar" "(" Id "," TypedVal ")" //TypedVal - the object where to search, or enclosing ones
                             [strict(2)]

rule [outerLocalVar-dispatch]:
    <k> outerLocalVar(X:Id)::_ => outerLocalVar(X, 'QThis(Class)::Class) ...</k>
    <crntClass> Class:ClassType </crntClass>

rule [outerLocalVar-found]:
    outerLocalVar(
      X:Id,
      objectClosure(_, <envStack>... ListItem(el(Class, _,_, X |-> L:Int _)) ...</envStack>) :: Class:ClassType
    ) => typedLookup(L)

rule [outerLocalVar-not-found]:
    outerLocalVar(
      X:Id,
      objectClosure(_, <envStack>... ListItem(el(Class, _, Encloser:TypedVal, OuterEnv:Map)) ...</envStack>)
        :: Class:ClassType
      => Encloser
    )
when
    notBool X in keys(OuterEnv)

//Initialize the registration of local environment, when a local class declaration is encoutered.
//This environment is precisely <env>. It don't contain local vars of the outer env for enclosign classes,
//in case of multi-level local classes.
rule [ClassDecStm-runtime]:
    <k> 'ClassDecStm(Class:ClassType) => . ...</k>
    <env> LocalEnv:Map </env>
    <localClassesEnv> LocalClasses:Map => LocalClasses[mapWrap(LocalEnv)/Class] </localClassesEnv>

endmodule
