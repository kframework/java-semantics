require "java-core.k"

module JAVA-PROCESS-TOP-LEVEL-NAMES
    imports JAVA-CORE

/*@ \subsection{First pass - processing top level names} */

rule [DefaultPackageDesugar]:
    'CompilationUnit(
      ( 'None(_) => 'Some('PackageDec(.K,, 'PackageName( 'ListWrap(.List{K}) ))) ),,
      _,,_)

rule [CompilationUnit]:
    <k>
      'CompilationUnit('Some('PackageDec(_,, 'PackageName( 'ListWrap(Ks:List{K}) ))),, _:K,,
          'ListWrap(Decs:List{K})
      )
      => setCuPackage("", Ks) ~> processTLNames(Decs)
      ...
    </k>
    <computationPhase> ProcessTopLevelNamesPhase </computationPhase>

//converts a package name from List{K} to String and saves it into <cuPackage> cell.
syntax K ::= "setCuPackage" "("
                              String ","  //package converted into String
                              List{K}     //package in original kast format
                            ")"
// package ro.uaic looks in kast like:
// 'PackageName('ListWrap('Id(# "ro"(.List{K})),,'Id(# "uaic"(.List{K}))))
rule setCuPackage("", X:Id ,,Ks:List{K}) => setCuPackage(Id2String(X), Ks)

rule setCuPackage(Str:String, X:Id,,Ks:List{K})
     => setCuPackage(Str +String "." +String Id2String(X), Ks)
when Str =/=String ""

rule <k> setCuPackage(Str:String, .List{K}) => . ...</k>
     <cuPackage> _ => packageId(Str) </cuPackage>

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
      processTLNames((_:KLabel(_:KLabel(_:K,, SimpleClass:Id,, _),,_ ) => .List{K}) ,,_)
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
