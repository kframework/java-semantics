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
          [Decs:KList]
      ) => processTypeNames([Decs], Pack)
      ...
    </k>
    <globalPhase> ProcTypeNamesPhase </globalPhase>

/*@ \subsection{Packages}*/

// 'PackageName([Ks])

rule [PackageName-Start]:
    'PackageName([Ks:KList]) => packageNameImpl("", [Ks:KList])                  [structural]

//Aux construct for processing packages
syntax KItem ::= packageNameImpl ( String, KListWrap )

rule [packageNameImpl-FirstInnerDesugar]:
    packageNameImpl(_:String, [(X:Id => packageId(X)),, Ks:KList])                        [structural]

rule [packageNameImpl-FirstPack]:
    packageNameImpl("", [packageId(NextKId:Id),, Ks:KList])
    => packageNameImpl(Id2String(NextKId), [Ks])                                          [structural]

rule [packageNameImpl-NextPack]:
    packageNameImpl(Str:String, [packageId(NextKId:Id),, Ks:KList])
    => packageNameImpl(Str +String "." +String Id2String(NextKId), [Ks])
when Str =/=String ""                                                                   [structural]

rule [packageNameImpl-End]:
    packageNameImpl(Str:String, [.KList]) => packageId(String2Id(Str))                  [structural]

//todo repitition

rule [PackageName-Start]:
    'PackageName(Ks:IdList) => packageNameImpl("", Ks)                  [structural]

//Aux construct for processing packages
syntax PackageId ::= packageNameImpl ( String, IdList )             [function]

rule [packageNameImpl-FirstPack]:
    packageNameImpl("", NextKId:Id . Ks:IdList)
    => packageNameImpl(Id2String(NextKId), Ks)                                          [structural]

rule [packageNameImpl-NextPack]:
    packageNameImpl(Str:String, NextKId:Id . Ids:IdList)
    => packageNameImpl(Str +String "." +String Id2String(NextKId), Ids)
when Str =/=String ""                                                                   [structural]

rule [packageNameImpl-End]:
    packageNameImpl(Str:String, .IdList) => packageId(String2Id(Str))                  [structural]

/*@ \subsection{Class declaration}*/

/*@ Wrapper of declarations inside a compilation unit. Used to distinguish
ProcTypeNamesPhase from ProcCompUnitsPhase*/
syntax KItem ::=  processTypeNames (
                KListWrap,    //declarations inside a compilation unit
                PackageId // the package of the processed types
              )

rule [processTypeNames-AddPackage]:
    <k> processTypeNames(_, PackId:PackageId) ...</k>
    <namesToClasses> PackMap:Map => PackMap[PackId <- mapWrap(.Map)] </namesToClasses>
when notBool PackId in keys(PackMap)

/*@ A type name is either class or interface name. Anonymous labels will be one of:
      - 'ClassDec('ClassDecHead(...))
      - 'InterfaceDec('InterfaceDecHead(...))
      todo repitition*/
rule [processTypeNamesClass]:
    <k>
      processTypeNames(
        [('ClassDec('ClassDecHead(Modifiers:AnnoClassModList,, SimpleClass:Id,, _),, CBody:K) => .KList),, _],
        PackId:PackageId
      )
      ~> ( . => processInnerTypes(CBody, toPackage(getClassType(PackId,SimpleClass))) )
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
        [('InterfaceDec('InterfaceDecHead(Modifiers:AnnoInterfaceModList,, SimpleClass:Id,, _),, CBody:K) => .KList),, _],
        PackId:PackageId
      )
      ~> ( . => processInnerTypes(CBody, toPackage(getClassType(PackId,SimpleClass))) )
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
    processTypeNames([(Label:KLabel(_) => .KList),, _], _)
when notBool( (Label ==KLabel 'ClassDec) orBool (Label ==KLabel 'InterfaceDec) )

//We match PackId in <namesToClasses> just to be sure that the package was added to the map.
rule [processTypeNames-Discard]:
    <k> processTypeNames([.KList], PackId:PackageId) => .K ...</k>
    <namesToClasses>... PackId |-> _ ...</namesToClasses>

/*@ Is converted into a processTypeNames. The first argument is a class/interface body. This function
  have to extract the list of memers from the body and pass them to processTypeNames.
*/
syntax KItem ::= processInnerTypes ( K , PackageId )
rule processInnerTypes('ClassBody([Ks:KList]), Pack:PackageId) => processTypeNames([Ks], Pack)
rule processInnerTypes([Ks:KList], Pack:PackageId) => processTypeNames([Ks], Pack)             //interface body

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
