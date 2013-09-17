require "core.k"

//todo: investigate why the execution hangs at the very beginning

module PROCESS-TYPE-NAMES
    imports CORE
    imports LITERALS // for retainTail

/*@ \subsection{First pass - processing top level names} */

rule [PackageNameStart]:
    'PackageName('ListWrap(Ks:KList)) => packageNameImpl("", Ks:KList)                  [structural]

//Aux construct for processing packages
syntax K ::= "packageNameImpl" "(" String "," KList ")"

rule [PackageNameFirstInnerDesugar]:
    packageNameImpl(_:String, (X:Id => packageId(X)),, Ks:KList)                        [structural]

rule [PackageNameFirstPack]:
    packageNameImpl("", packageId(NextKId:Id),, Ks:KList)
    => packageNameImpl(Id2String(NextKId), Ks)                                          [structural]

rule [PackageNameNextPack]:
    packageNameImpl(Str:String, packageId(NextKId:Id),, Ks:KList)
    => packageNameImpl(Str +String "." +String Id2String(NextKId), Ks)
when Str =/=String ""                                                                   [structural]

rule [PackageNameEnd]:
    packageNameImpl(Str:String, .KList) => packageId(String2Id(Str))                    [structural]

rule [DefaultPackageDesugar]:
    'CompilationUnit(
      ( 'None(_) => 'Some('PackageDec(.K,, 'PackageName( 'ListWrap(.KList) ))) ),,
      _
    )

//resolve the package name
context 'CompilationUnit('Some('PackageDec(_:K,, HOLE)),, _)

rule [CompilationUnit]:
    <k>
      'CompilationUnit('Some('PackageDec(_:K,, Pack:PackageId)),, _:K,,
          'ListWrap(Decs:KList)
      ) => processTypeNames(Decs, Pack)
      ...
    </k>
    <computationPhase> ProcessTypeNamesPhase </computationPhase>

/*@ \subsection{Class declaration}*/

//Wrapper of declarations inside a compilation unit. Used to distinguish
//ProcessTypeNamesPhase from ProcessCompUnitsPhase
syntax K ::= "processTypeNames" "(" KList //declarations inside a compilation unit
                              "," PackageId // the package of the processed types
                              ")"

rule [processTypeNamesAddPackage]:
    <k> processTypeNames(_, PackId:PackageId) ...</k>
    <typeNamesMap> PackMap:Map => PackMap[mapWrap(.Map) / PackId] </typeNamesMap>
when notBool PackId in keys(PackMap)

//May be both class or interface name
//Anonymous labels will be one of:
//  - 'ClassDec('ClassDecHead(...))
//  - 'InterfaceDec('InterfaceDecHead(...))
rule [processTypeNames]:
    <k>
      processTypeNames(
        (DecLabel:KLabel(_:KLabel(Modifiers:K,, SimpleClass:Id,, _),, CBody:K) => .KList),, _,
        PackId:PackageId
      )
      ~> ( . => processTypeNames(bodyAsList(CBody), toPackage(getClassType(PackId,SimpleClass))) )
      ...
    </k>
    <typeNamesMap>
      ...
      PackId |-> mapWrap(
        ClassesMap:Map => ClassesMap[getClassType(PackId,SimpleClass) / SimpleClass]
      )
      ...
    </typeNamesMap>
    <classesToAccessModes>
      _ (. => getClassType(PackId,SimpleClass) |-> getAccessMode(Modifiers))
    </classesToAccessModes>
when DecLabel ==KLabel 'ClassDec orBool DecLabel ==KLabel 'InterfaceDec

rule [processTypeNamesElemDiscard]:
    processTypeNames((Label:KLabel(_) => .KList),,_ ,_)
when notBool( (Label ==KLabel 'ClassDec) orBool (Label ==KLabel 'InterfaceDec)
              orBool (Label ==KLabel 'bodyAsList`(_`)) //todo semantics seems to work without this condition
            )

//We match PackId in <typeNamesMap> just to be sure that the package was added to the map.
rule [processTypeNamesDiscard]:
    <k> processTypeNames(.KList, PackId:PackageId) => .K ...</k>
    <typeNamesMap>... PackId |-> _ ...</typeNamesMap>

//Converts a pair of PackagId, Id into a fully qualified class name
syntax K ::= "getClassType" "(" PackageId // the Package Id
                            "," Id        // Simple class name
                            ")"                                 [function]

rule [getclassType]:
    getClassType(packageId(PackKId:Id), SimpleClass:Id)
    => class String2Id(Id2String(PackKId) +String "." +String Id2String(SimpleClass))

//Converts a fully qualified class type into a simple name (Id)
syntax K ::= "getSimpleName" "(" ClassType ")"                  [function]
rule getSimpleName(class ClassId:Id)
    => String2Id(retainTail(
      Id2String(ClassId),
      rfindString(Id2String(ClassId), ".", lengthString(Id2String(ClassId))) +Int 1
    ))

//Receives a class/interface body as K, and extracts the KList part of it
syntax K ::= "bodyAsList"  "(" K         //The class body to be processed
                           ")"                                  [function]

//The difference between classes and interfaces structure is purely due to Java-Front syntax whim.
rule [bodyAsListClass]:
    bodyAsList('ClassBody('ListWrap(Ks:KList))) => Ks

rule [bodyAsListInterface]:
    bodyAsList('ListWrap(Ks:KList)) => Ks

//Returns the types map for the given package, or mapWrap(.Map) if there's no such package.
syntax K ::= "getNamesMap"  "(" PackageId //The package for which we want to retrieve the types map
                            ")"

rule [getTypesMapFound]:
    <k> getNamesMap(Pack:PackageId) => mapWrap(NamesMap) ...</k>
    <typeNamesMap>... Pack |-> mapWrap(NamesMap:Map) ...</typeNamesMap>

rule [getTypesMapNotFound]:
    <k> getNamesMap(Pack:PackageId) => mapWrap(.Map) ...</k>
    <typeNamesMap> BigMap:Map </typeNamesMap>
when notBool Pack in keys(BigMap)

endmodule
