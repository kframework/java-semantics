module PROCESS-TYPE-NAMES
    imports CORE-SORTS
    imports CORE-CLASSES
    imports AUX-STRINGS // for retainTail
    imports CORE-PREPROCESSING

/*@
First pass - collecting globally accessible names in the program. This includes packages,
top-level classes and inner classes. In each compilation unit just class declarations
(both global and inner) are processed. Results are stored in the cell <namesToClasses>.

The initial configuration contains the initial program in cells <k> and <program>, and global phase is ProcTypeNamesPhase.
*/

/*@ \subsection{Compilation units}*/

// 'CompilationUnit('Some('PackageDec(_,, Pack:PackageId)),, _)
rule [CompilationUnit-DefaultPackage-Desugar]:
    'CompilationUnit(
      ( 'None(_) => 'Some('PackageDec(.AnnoList,, 'PackageName( .IdList ))) ),,
      _
    )

//resolve the package name
context 'CompilationUnit('Some('PackageDec(_,, HOLE)),, _)

rule [CompilationUnit]:
    <k>
      'CompilationUnit('Some('PackageDec(_,, Pack:PackageId)),, _:K,,
          Decs:K
      ) => processTypeNames(Decs, Pack)
      ...
    </k>
    <globalPhase> ProcTypeNamesPhase </globalPhase>

/*@ \subsection{Packages}*/

rule [PackageName-Start]:
    'PackageName(Ks:K) => packageNameImpl("", Ks)                                       [structural]

syntax KItem ::= packageNameImpl ( String, IdList )

//cannot remove, sometimes the first argument is packageId
rule [packageNameImpl-FirstInnerDesugar]:
    packageNameImpl(_:String, 'IdList((X:Id => packageId(X)),, Ks:K))                   [structural]

rule [packageNameImpl-FirstPack]:
    packageNameImpl("", 'IdList(packageId(NextKId:Id),, Ks:K))
    => packageNameImpl(Id2String(NextKId), Ks)                                          [structural]

rule [packageNameImpl-NextPack]:
    packageNameImpl(Str:String, 'IdList(packageId(NextKId:Id),, Ks:K))
    => packageNameImpl(Str +String "." +String Id2String(NextKId), Ks)
when Str =/=String ""                                                                   [structural]

rule [packageNameImpl-End]:
    packageNameImpl(Str:String, .IdList) => packageId(String2Id(Str))                   [structural]

/*@ \subsection{Class declaration}*/

/*@ Wrapper of declarations inside a compilation unit. Used to distinguish
ProcTypeNamesPhase from ProcCompUnitsPhase*/
syntax KItem ::=  processTypeNames (
                K,    //declarations inside a compilation unit
                PackageId // the package of the processed types
              )

rule [processTypeNames-AddPackage]:
    <k> processTypeNames(_, PackId:PackageId) ...</k>
    <namesToClasses> PackMap:Map => PackMap[PackId <- mapWrap(.Map)] </namesToClasses>
when notBool PackId in keys(PackMap)

/*@ A type name is either class or interface name. Anonymous labels will be one of:
      - 'ClassDec('ClassDecHead(...))
      - 'InterfaceDec('InterfaceDecHead(...))
*/

rule [processTypeNamesClass]:
    <k>
      processTypeNames(
        (_:KLabel('ClassDec('ClassDecHead(Modifiers:AnnoClassModList,, SimpleClass:Id,, _),, 'ClassBody(Body:K)),, Tl:K) => Tl),
        PackId:PackageId
      )
      ~> ( . => processTypeNames(Body, toPackage(getClassType(PackId,SimpleClass))) )
      ...
    </k>
    <namesToClasses>
      ...
      PackId |-> mapWrap(
        ClassesMap:Map => ClassesMap[SimpleClass <- getClassType(PackId,SimpleClass)]
      )
      ...
    </namesToClasses>
    ( . =>  <class>
              <classType> getClassType(PackId,SimpleClass) </classType>
              <classMetaType> classCMT </classMetaType>
              <classPhase> DiscoveredCPhase </classPhase>
              <classAccessMode> getAccessMode(Modifiers) </classAccessMode>
              ...
            </class> )

rule [processTypeNamesInterface]:
    <k>
      processTypeNames(
        (_:KLabel('InterfaceDec('InterfaceDecHead(Modifiers:AnnoInterfaceModList,, SimpleClass:Id,, _),, Body:K),, Tl:K) => Tl),
        PackId:PackageId
      )
      ~> ( . => processTypeNames(Body, toPackage(getClassType(PackId,SimpleClass))) )
      ...
    </k>
    <namesToClasses>
      ...
      PackId |-> mapWrap(
        ClassesMap:Map => ClassesMap[SimpleClass <- getClassType(PackId,SimpleClass)]
      )
      ...
    </namesToClasses>
    ( . =>  <class>
              <classType> getClassType(PackId,SimpleClass) </classType>
              <classMetaType> interfaceCMT </classMetaType>
              <classPhase> DiscoveredCPhase </classPhase>
              <classAccessMode> getAccessMode(Modifiers) </classAccessMode>
              ...
            </class> )

rule [processTypeNames-ElemDiscard]:
    processTypeNames((_:KLabel(Label:KLabel(_),, Tl:K) => Tl), _)
when notBool( Label ==KLabel 'ClassDec orBool Label ==KLabel 'InterfaceDec )

//We match PackId in <namesToClasses> just to be sure that the package was added to the map.
rule [processTypeNames-Discard]:
    <k> processTypeNames(EmptyList, PackId:PackageId) => . ...</k>
    <namesToClasses>... PackId |-> _ ...</namesToClasses>
when EmptyList ==K .TypeDecList orBool EmptyList ==K .ClassBodyDecList orBool EmptyList ==K .InterfaceMemberDecList

/*@ Is converted into a processTypeNames. The first argument is a class/interface body. This function
  have to extract the list of memers from the body and pass them to processTypeNames.
*/
//syntax KItem ::= processInnerTypes ( K , PackageId )
//rule processInnerTypes('ClassBody([Ks:KList]), Pack:PackageId) => processTypeNames([Ks], Pack)
//rule processInnerTypes([Ks:KList], Pack:PackageId) => processTypeNames([Ks], Pack)             //interface body

/*@ \subsection{Auxiliary constructs}*/

/*@ Computes the metaType based on type declaration label*/
syntax KItem ::=  getMetaType (
                KLabel //type declaration label
              )
              [function]

rule getMetaType('ClassDec) => classCMT
rule getMetaType('InterfaceDec) => interfaceCMT

//@ Returns the types map for the given package, or mapWrap(.Map) if there's no such package.
syntax KItem ::=  getNamesMap  (
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
