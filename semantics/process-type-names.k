require "core-sorts.k"
require "aux-strings.k"

/*@ \section{Module PROCESS-TYPE-NAMES}
First pass - collecting globally accessible names in the program. This includes packages,
top-level classes and inner classes. In each compilation unit just class declarations
(both global and inner) are processed. Results are stored in the cell <namesToClasses>.*/

module PROCESS-TYPE-NAMES
    imports CORE-SORTS
    imports AUX-STRINGS // for retainTail

/*@ \subsection{Compilation units and packages}*/

rule [PackageName-Start]:
    'PackageName('ListWrap(Ks:KList)) => packageNameImpl("", Ks:KList)                  [structural]

//Aux construct for processing packages
syntax K ::= packageNameImpl ( String, KList )

rule [packageNameImpl-FirstInnerDesugar]:
    packageNameImpl(_:String, (X:Id => packageId(X)),, Ks:KList)                        [structural]

rule [packageNameImpl-FirstPack]:
    packageNameImpl("", packageId(NextKId:Id),, Ks:KList)
    => packageNameImpl(Id2String(NextKId), Ks)                                          [structural]

rule [packageNameImpl-NextPack]:
    packageNameImpl(Str:String, packageId(NextKId:Id),, Ks:KList)
    => packageNameImpl(Str +String "." +String Id2String(NextKId), Ks)
when Str =/=String ""                                                                   [structural]

rule [packageNameImpl-End]:
    packageNameImpl(Str:String, .KList) => packageId(String2Id(Str))                    [structural]

rule [CompilationUnit-DefaultPackage-Desugar]:
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
     <globalPhase> ProcTypeNamesPhase  </globalPhase>

/*@ \subsection{Class declaration}*/

/*@ Wrapper of declarations inside a compilation unit. Used to distinguish
ProcTypeNamesPhase from ProcCompUnitsPhase*/
syntax K ::=  processTypeNames (
                KList,    //declarations inside a compilation unit
                PackageId // the package of the processed types
              )

rule [processTypeNames-AddPackage]:
    <k> processTypeNames(_, PackId:PackageId) ...</k>
    <namesToClasses> PackMap:Map => PackMap[mapWrap(.Map) / PackId] </namesToClasses>
when notBool PackId in keys(PackMap)

/*@ May be both class or interface name. Anonymous labels will be one of:
      - 'ClassDec('ClassDecHead(...))
      - 'InterfaceDec('InterfaceDecHead(...))*/
rule [processTypeNames]:
    <k>
      processTypeNames(
        (DecLabel:KLabel(_:KLabel(Modifiers:K,, SimpleClass:Id,, _),, CBody:K) => .KList),, _,
        PackId:PackageId
      )
      ~> ( . => processInnerTypes(CBody, toPackage(getClassType(PackId,SimpleClass))) )
      ...
    </k>
    <namesToClasses>
      ...
      PackId |-> mapWrap(
        ClassesMap:Map => ClassesMap[getClassType(PackId,SimpleClass) / SimpleClass]
      )
      ...
    </namesToClasses>
    <classesToAccessModes>
      _ (. => getClassType(PackId,SimpleClass) |-> getAccessMode(Modifiers))
    </classesToAccessModes>
when DecLabel ==KLabel 'ClassDec orBool DecLabel ==KLabel 'InterfaceDec

rule [processTypeNames-ElemDiscard]:
    processTypeNames((Label:KLabel(_) => .KList),,_,_)
when notBool( (Label ==KLabel 'ClassDec) orBool (Label ==KLabel 'InterfaceDec) )

//We match PackId in <namesToClasses> just to be sure that the package was added to the map.
rule [processTypeNames-Discard]:
    <k> processTypeNames(.KList, PackId:PackageId) => .K ...</k>
    <namesToClasses>... PackId |-> _ ...</namesToClasses>

/*@ Is converted into a processTypeNames. The first argument is a class/interface body. This function
  have to extract the list of memers from the body and pass them to processTypeNames.
*/
syntax K ::= processInnerTypes ( K , PackageId )
rule processInnerTypes('ClassBody('ListWrap(Ks:KList)), Pack:PackageId) => processTypeNames(Ks, Pack)
rule processInnerTypes('ListWrap(Ks:KList), Pack:PackageId) => processTypeNames(Ks, Pack)

/*@ \subsection{Auxiliary constructs}*/

//@ Converts a pair of PackagId, Id into a fully qualified class name
syntax K ::=  getClassType (
                PackageId, // the Package Id
                Id        // Simple class name
              )
              [function]

rule getClassType(packageId(PackKId:Id), SimpleClass:Id)
     => class String2Id(Id2String(PackKId) +String "." +String Id2String(SimpleClass))

//@ Converts a fully qualified class type into a simple name (Id)
syntax K ::= getSimpleName ( ClassType )                  [function]
rule getSimpleName(class ClassId:Id)
    => String2Id(retainTail(
      Id2String(ClassId),
      rfindString(Id2String(ClassId), ".", lengthString(Id2String(ClassId))) +Int 1
    ))

//@ Returns the types map for the given package, or mapWrap(.Map) if there's no such package.
syntax K ::=  getNamesMap  (
                PackageId //The package for which we want to retrieve the types map
              )

rule [getNamesMap-Found]:
    <k> getNamesMap(Pack:PackageId) => mapWrap(NamesMap) ...</k>
    <namesToClasses>... Pack |-> mapWrap(NamesMap:Map) ...</namesToClasses>

rule [getNamesMap-NotFound]:
    <k> getNamesMap(Pack:PackageId) => mapWrap(.Map) ...</k>
    <namesToClasses> BigMap:Map </namesToClasses>
when notBool Pack in keys(BigMap)

endmodule
