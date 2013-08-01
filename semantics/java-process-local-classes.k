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
        ~> elabRes('ListWrap(.KList)) //just to fill the CHOLE in the context term
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
      =>   processClassDecs(setWrap(SetItem(Class)))
        ~> processType(Class)
        ~> elaborateBlocks(setWrap(SetItem(Class)))

        // processClassDecs will alter <crntClass>, that's why we have to restore it at the end
        ~> restoreAfterProcessLocalClass(OldCrntClass, OldLocalTypes[Class/Name])
      ...
    </k>
    <crntClass> OldCrntClass:ClassType </crntClass>
    <localTypes> OldLocalTypes:Map => OldLocalTypes[Class/Name] </localTypes>
    <typeNamesMap>... GeneratedPack |-> mapWrap(Name:Id |-> Class:ClassType) ...</typeNamesMap>

//restore the content of <crntClass> and <localTypes> with the given class
syntax K ::= "restoreAfterProcessLocalClass" "(" ClassType //old content of <crntClass>
                                             "," Map       //old content of <localTypes>
                                             ")"
rule [restoreAfterProcessLocalClass]:
    <k> restoreAfterProcessLocalClass(Class:ClassType, LocalTypes:Map) => . ...</k>
    <crntClass> _ => Class </crntClass>
    <localTypes> _ => LocalTypes </localTypes>

endmodule
