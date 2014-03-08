require "core-sorts.k"
require "core-classes.k"

/*@ \section{Module PROCESS-IMPORTS}
Rules related to processing import declarations. Part of ProcCompUnitsPhase.
*/

module PROCESS-IMPORTS
    imports CORE-SORTS
    imports CORE-CLASSES

syntax K ::=  compUnitImportsStart (
                PackageId // The package of the current compilation unit
              )

rule [compUnitImportsStart]:
    <k>
      compUnitImportsStart(Pack:PackageId) => 'TypeImportOnDemandDec(packageId(String2Id("java.lang")))
      ...
    </k>
    <namesToClasses>... Pack |-> mapWrap(PackMap:Map) ...</namesToClasses>
    <compUnitImports> _ => PackMap </compUnitImports>

//Process K-AST terms 'TypeImportDec or 'TypeImportOnDemandDec

syntax KLabel ::= "'TypeImportDec"
                | "'TypeImportOnDemandDec"

context 'TypeImportDec(HOLE)

rule [TypeImportDec]:
    <k> 'TypeImportDec(Class:ClassType) => . ...</k>
    <namesToClasses>... _ |-> mapWrap(X:Id |-> Class _) ...</namesToClasses>
    <compUnitImports> Imp:Map => Imp[Class / X] </compUnitImports>

context 'TypeImportOnDemandDec(HOLE)

rule [TypeImportOnDemandDec]:
    <k>
      'TypeImportOnDemandDec(Pack:PackageId) => importOnDemandImpl(PackMap)
      ...
    </k>
    <namesToClasses>... Pack |-> mapWrap(PackMap:Map) ...</namesToClasses>
    <compUnitImports> Imp:Map </compUnitImports>

//import to <compUnitImports> cell public packages in the given map.
syntax K ::= importOnDemandImpl ( Map )

rule [importOnDemandImpl-public]:
    <k> importOnDemandImpl((X:Id |-> Class:ClassType => .) _) ...</k>
    <compUnitImports> Imp:Map => Imp[Class / X] </compUnitImports>
    <classesToAccessModes>... Class |-> public ...</classesToAccessModes>

rule [importOnDemandImpl-package]:
    <k> importOnDemandImpl((X:Id |-> Class:ClassType => .) _) ...</k>
    <classesToAccessModes>... Class |-> package ...</classesToAccessModes>

rule [importOnDemandImpl-discard]:
    importOnDemandImpl(.) => .K

/*@ Importing a nonexistent package have no effect.
This is required because some tests import some packages from JDK that are not included in
class-lib.*/
rule [TypeImportOnDemandDec-Unexisting]:
    <k>
      'TypeImportOnDemandDec(Pack:PackageId) => .
      ...
    </k>
    <namesToClasses> PackMap:Map </namesToClasses>
when notBool Pack in keys(PackMap)

endmodule

