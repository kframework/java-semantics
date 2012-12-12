require "java-core.k"

module JAVA-PROCESS-TOP-LEVEL-NAMES
    imports JAVA-CORE

/*@ \subsection{First pass - processing top level names} */

rule [PackageNameStart]:
    'PackageName('ListWrap(Ks:List{K})) => 'PackageName("",, 'ListWrap(Ks:List{K}))

rule [PackageNameFirstPack]:
    'PackageName("",, 'ListWrap(X:Id,, Ks:List{K}))
    => 'PackageName(Id2String(X),, 'ListWrap(Ks))

rule [PackageNameNextPack]:
    'PackageName(Str:String,, 'ListWrap(X:Id,, Ks:List{K}))
    => 'PackageName(Str +String "." +String Id2String(X),, 'ListWrap(Ks))
when Str =/=String ""

rule [PackageNameEnd]:
    'PackageName(Str:String,, 'ListWrap(.List{K})) => packageId(Str)

rule [DefaultPackageDesugar]:
    'CompilationUnit(
      ( 'None(_) => 'Some('PackageDec(.K,, 'PackageName( 'ListWrap(.List{K}) ))) ),,
      _
    )

//resolve the package name
context 'CompilationUnit('Some('PackageDec(_:K,, HOLE)),, _)

rule [CompilationUnit]:
    <k>
      'CompilationUnit('Some('PackageDec(_:K,, Pack:PackageId)),, _:K,,
          'ListWrap(Decs:List{K})
      ) => processTLNames(Decs)
      ...
    </k>
    <cuPackage> _ => Pack </cuPackage>
    <computationPhase> ProcessTopLevelNamesPhase </computationPhase>

/*@ \subsection{Class declaration}*/

//Wrapper of declarations inside a compilation unit. Used to distinguish
//ProcessTopLevelNamesPhase from ProcessCompUnitsPhase
syntax K ::= "processTLNames" "(" List{K} //declarations inside a compilation unit
                              ")"

rule [processTLNamesAddPackage]:
    <k> processTLNames(_) ...</k>
    <cuPackage> PackId:PackageId </cuPackage>
    <topLevelNamesMap> PackMap:Map => PackMap[mapWrap(.Map) / PackId] </topLevelNamesMap>
when notBool PackId in keys(PackMap)

//May be both class or interface name
//Anonymous labels will be one of:
//  - 'ClassDec('ClassDecHead(...))
//  - 'InterfaceDec('InterfaceDecHead(...))
rule [processTLNames]:
    <k>
      processTLNames(_:KLabel(_:KLabel(Modifiers:K,, SimpleClass:Id,, _),,_ ),, Ks:List{K})
      => processTLNames(Ks)
      ...
    </k>
    <cuPackage> PackId:PackageId </cuPackage>
    <topLevelNamesMap>
      ...
      PackId |-> mapWrap(
        ClassesMap:Map => ClassesMap[getClassType(PackId,SimpleClass) / SimpleClass]
      )
      ...
    </topLevelNamesMap>
    <classesToAccessModes>
      _ (. => getClassType(PackId,SimpleClass) |-> getAccessMode(Modifiers))
    </classesToAccessModes>

rule [processTLNamesDiscard]:
    processTLNames(.List{K}) => .K

//returns the fully qualified class name from given parameters
syntax K ::= "getClassType" "(" PackageId // the Package Id
                            "," Id        // Simple class name
                            ")"                                 [function]

rule [getclassType]:
    getClassType(packageId(PackStr:String), SimpleClass:Id)
    => class String2Id(PackStr +String "." +String Id2String(SimpleClass))
        [structural, anywhere]

endmodule
