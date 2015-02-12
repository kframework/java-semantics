/*@ \section{Module PROCESS-IMPORTS}
Rules related to processing import declarations. Part of ProcCompUnitsPhase.
*/

module PROCESS-IMPORTS
    imports CORE-SORTS
    imports CORE-CLASSES

syntax KItem ::=  compUnitImportsStart (
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
context 'TypeImportDec(HOLE)
//todo mapItemByValue
//rule [TypeImportDec]:
//    <k> 'TypeImportDec(Class:ClassType) => . ...</k>
//    <namesToClasses>... _ |-> mapWrap((X:Id |-> Class) _) ...</namesToClasses>
//    <compUnitImports> Imp:Map => Imp[X <- Class] </compUnitImports>

context 'TypeImportOnDemandDec(HOLE)

rule [TypeImportOnDemandDec]:
    <k>
      'TypeImportOnDemandDec(Pack:PackageId) => importOnDemandImpl(PackMap)
      ...
    </k>
    <namesToClasses>... Pack |-> mapWrap(PackMap:Map) ...</namesToClasses>
    <compUnitImports> Imp:Map </compUnitImports>

//@ Imports to <compUnitImports> cell public classes from the given map. Classes with package access are ignored.
syntax KItem ::=  importOnDemandImpl (
                Map //Map[X |-> Class] - classes to consider for importing.
              )
//flattens the first mapItem as a walkaround to match mapItem by Value
syntax KItem ::= importOnDemandImpl (Id,ClassType,Map)

rule [importOnDemandImplConversion]:
    importOnDemandImpl((Key:Id |-> Value:ClassType) Remains:Map) => importOnDemandImpl(Key,Value,Remains)
//todo mapItemByValue/ is this solution ok?
//rule [importOnDemandImpl-public]:
//    <k> importOnDemandImpl((X:Id |-> Class:ClassType => .Map) _:Map) ...</k>
//    <compUnitImports> Imp:Map => Imp[X <- Class] </compUnitImports>
//    <classType> Class </classType>
//    <classAccessMode> public </classAccessMode>

//rule [importOnDemandImpl-package]:
//    <k> importOnDemandImpl((X:Id |-> Class:ClassType => .Map) _:Map) ...</k>
//    <classType> Class </classType>
//    <classAccessMode> package </classAccessMode>

rule [importOnDemandImpl-public]:
    <k> (importOnDemandImpl(X:Id, Class:ClassType, Remains:Map) => importOnDemandImpl(Remains)) ...</k>
    <compUnitImports> Imp:Map => Imp[X <- Class] </compUnitImports>
    <classType> Class </classType>
    <classAccessMode> public </classAccessMode>

rule [importOnDemandImpl-package]:
    <k> (importOnDemandImpl(X:Id, Class:ClassType, Remains:Map) => importOnDemandImpl(Remains)) ...</k>
    <classType> Class </classType>
    <classAccessMode> package </classAccessMode>

rule [importOnDemandImpl-discard]:
    importOnDemandImpl(.Map) => .K

/*@ Importing a nonexistent package have no effect.
This is required because some tests import some packages from JDK that are not included in
class-lib.*/
rule [TypeImportOnDemandDec-Unexisting]:
    <k>
      'TypeImportOnDemandDec(Pack:PackageId) => .K
      ...
    </k>
    <namesToClasses> PackMap:Map </namesToClasses>
when notBool Pack in keys(PackMap)

endmodule

