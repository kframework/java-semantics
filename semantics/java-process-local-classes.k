require "java-core.k"
require "java-process-comp-units.k"
require "java-elaborate-blocks.k"

module JAVA-PROCESS-LOCAL-CLASSES
    imports JAVA-CORE
    imports JAVA-PROCESS-COMP-UNITS
    imports JAVA-ELABORATE-BLOCKS

rule [elab-ClassDecStm]:
    <k>
      elab('ClassDecStm(ClassDec:K))
      => processTypeDecsInPCUPhase(ClassDec, packageId(String2Id("local_$" +String Int2String(LocalId))), Class)
      ...
    </k>
    <crntClass> Class:ClassType </crntClass>
    <nextLocalId> LocalId:Int => LocalId +Int 1 </nextLocalId>

endmodule
