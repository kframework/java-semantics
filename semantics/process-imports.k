require "core.k"

/*@ \section{Module PROCESS-IMPORTS}
Rules related to processing import declarations. Part of ProcessCompUnitsPhase.
*/

module PROCESS-IMPORTS
    imports CORE

syntax K ::= "compUnitImportsStart" "(" PackageId // The package of the current compilation unit
                                    ")"

rule [compUnitImportsStart]:
    <k>
      compUnitImportsStart(Pack:PackageId) => 'TypeImportOnDemandDec(packageId(String2Id("java.lang")))
      ...
    </k>
    <typeNamesMap>... Pack |-> mapWrap(PackMap:Map) ...</typeNamesMap>
    <compUnitImports> _ => PackMap </compUnitImports>

//Process kast terms 'TypeImportDec or 'TypeImportOnDemandDec

context 'TypeImportDec(HOLE)

rule [TypeImportDec]:
    <k> 'TypeImportDec(Class:ClassType) => . ...</k>
    <typeNamesMap>... _ |-> mapWrap(X:Id |-> Class _) ...</typeNamesMap>
    <compUnitImports> Imp:Map => Imp[Class / X] </compUnitImports>

context 'TypeImportOnDemandDec(HOLE)

rule [TypeImportOnDemandDec]:
    <k>
      'TypeImportOnDemandDec(Pack:PackageId) => importOnDemandImpl(PackMap)
      ...
    </k>
    <typeNamesMap>... Pack |-> mapWrap(PackMap:Map) ...</typeNamesMap>
    <compUnitImports> Imp:Map </compUnitImports>

//import to <compUnitImports> cell public packages in the given map.
syntax K ::= "importOnDemandImpl" "(" Map ")"

rule [importOnDemandImplPublic]:
    <k> importOnDemandImpl((X:Id |-> Class:ClassType => .) _) ...</k>
    <compUnitImports> Imp:Map => Imp[Class / X] </compUnitImports>
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
    <typeNamesMap> PackMap:Map </typeNamesMap>
when notBool Pack in keys(PackMap)

endmodule

