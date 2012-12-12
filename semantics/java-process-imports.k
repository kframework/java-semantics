require "java-core.k"

module JAVA-PROCESS-IMPORTS
    imports JAVA-CORE

// Rules related to processing import declarations. Part of ProcessCompUnitsPhase.

/*@ \section{Second pass - processing imports} */

syntax K ::= "compUnitImportsStart"

rule [compUnitImportsStart]:
    <k>
      compUnitImportsStart => 'TypeImportOnDemandDec(packageId("java.lang"))
      ...
    </k>
    <cuPackage> Pack:PackageId </cuPackage>
    <topLevelNamesMap>... Pack |-> mapWrap(PackMap:Map) ...</topLevelNamesMap>
    <compUnitImports> _ => PackMap </compUnitImports>

//Process kast terms 'TypeImportDec or 'TypeImportOnDemandDec

context 'TypeImportDec(HOLE)

rule [TypeImportDec]:
    <k> 'TypeImportDec(Class:ClassType) => . ...</k>
    <topLevelNamesMap>... _ |-> mapWrap(X:Id |-> Class _) ...</topLevelNamesMap>
    <compUnitImports> Imp:Map => Imp[Class / X] </compUnitImports>

context 'TypeImportOnDemandDec(HOLE)

rule [TypeImportOnDemandDec]:
    <k>
      'TypeImportOnDemandDec(Pack:PackageId) => importOnDemandImpl(PackMap)
      ...
    </k>
    <topLevelNamesMap>... Pack |-> mapWrap(PackMap:Map) ...</topLevelNamesMap>
    <compUnitImports> Imp:Map </compUnitImports>

//import to <compUnitImports> cell public packages in the given map.
syntax K ::= "importOnDemandImpl" "(" Map ")"

rule [importOnDemandImplPublic]:
    <k> importOnDemandImpl((X:Id |-> Class:ClassType => .) _) ...</k>
    <compUnitImports> _ (. => X |-> Class) </compUnitImports>
    <classesToAccessModes>... Class |-> public ...</classesToAccessModes>

rule [importOnDemandImplPackage]:
    <k> importOnDemandImpl((X:Id |-> Class:ClassType => .) _) ...</k>
    <classesToAccessModes>... Class |-> package ...</classesToAccessModes>

rule [importOnDemandImplDiscard]:
    importOnDemandImpl(.) => .K

//importing an unexisting package have no effect.
//This is required because some tests import some packages from JDK that are not included in
//class-lib.
rule [TypeImportOnDemandUnexisting]:
    <k>
      'TypeImportOnDemandDec(Pack:PackageId) => .
      ...
    </k>
    <topLevelNamesMap> PackMap:Map </topLevelNamesMap>
when notBool Pack in keys(PackMap)

endmodule

