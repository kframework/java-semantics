require "core-sorts.k"
require "process-type-names.k"
require "process-imports.k"

/*@ \section{Module PROCESS-COMP-UNITS}
ProcCompUnitsPhase:
  For each CompUnit separately:
1. Process import declarations. Build <compUnitImports>.

  For each class C in CompUnit separately:
2. For each class save the <class> cell with just the following:
  - <classType> - since we process CU content recursively, should be available
  - <enclosingClass>
  - <imports> - just for top-level classes, imports are taken from the <compUnitImports>.
              For inner classes this cell is still empty.
  - <classDec> - content of its 'ClassDec term. When this term is non-empty
    then the class has not been preprocessed yet.

3. Process inner classes of C.

  This way we will have fast access to the declaration of a class, and will be able to
process declarations in a less-restricted order.
*/
module PROCESS-COMP-UNITS
    imports CORE-SORTS
    imports PROCESS-TYPE-NAMES
    imports PROCESS-IMPORTS     //for compUnitImportsStart()

/*@ \subsection{Second pass - processing declarations} */

rule [ProcCompUnitsPhase-start]:
    <k> . => Program </k>
    (<program> Program:K </program> => .)
     <globalPhase> ProcTypeNamesPhase => ProcCompUnitsPhase  </globalPhase>

//ImpDecs will be processed in the module PROCESS-IMPORTS
rule [CompilationUnit]:
    <k>
      'CompilationUnit('Some('PackageDec(_:K,, Pack:PackageId)),,
          ImpDecs:K,, 'ListWrap(Ks:KList)
      )
      => compUnitImportsStart(Pack) ~> ImpDecs ~> processTypeDecsInPCUPhase(Ks, Pack, noClass)
      ...
    </k>
    <globalPhase> ProcCompUnitsPhase  </globalPhase>

/*@ Wrapper over a list of type declarations and possible other terms, required to distinguish
this phase from other preprocessing phases
Type declarations are processed in this phase wrapped in a processTypeDecsInPCUPhase*/
syntax K ::=  processTypeDecsInPCUPhase  (
                KList,      //The list of terms from which we will process just type declarations
                PackageId,  //The package of the processed types
                ClassType   //The outer class of this class, if any, or noClass if this is a top-level class
              )

rule [processTypeDecsInPCUPhase-Expand]:
    (. => processTypeDecsInPCUPhase(K1, Pack, OuterClass))
    ~> processTypeDecsInPCUPhase((K1:K => .KList),, _:K,,_, Pack:PackageId, OuterClass:ClassType)

rule [processTypeDecsInPCUPhase-Discard]:
    processTypeDecsInPCUPhase(.KList, _,_) => .K

rule [processTypeDecsInPCUPhase-ElemDiscard]:
    processTypeDecsInPCUPhase(Label:KLabel(_), _,_) => .
when notBool( Label ==KLabel 'ClassDec orBool Label ==KLabel 'InterfaceDec )

/*@ \subsection{Class declaration processing}*/

rule [processTypeDecsInPCUPhase-typeDec-ComputeFullName]:
    processTypeDecsInPCUPhase(
      KL:KLabel(_:KLabel(_:K,, (SimpleClass:Id => getClassType(Pack,SimpleClass)),, _:KList),, _),
      Pack:PackageId, _
    )                [structural]

rule [ClassDec-NoExtendsDesugar]:
    processTypeDecsInPCUPhase('ClassDec('ClassDecHead(_:K,, Class:ClassType,, _:K,,
        ( 'None(_)
          => 'Some('SuperDec(
                #if (Class =/=K objectClass)
                  #then 'ClassType(objectClass,, 'None(.KList))
                  #else noClass
                #fi
              ))
        ),,
        _:K),, _:K
    ), Pack:PackageId, _)                [structural]

rule [ClassDec-NoImplementsDesugar]:
    processTypeDecsInPCUPhase('ClassDec('ClassDecHead(_:K,, Class:ClassType,, _:K,, _:K,,
        ( 'None(.KList) => 'Some('ImplementsDec('ListWrap(.KList))) )
      ),, _:K
    ), _,_)                [structural]

rule [InterfaceDec-NoExtendsDesugar]:
    processTypeDecsInPCUPhase('InterfaceDec('InterfaceDecHead(_:K,, Class:ClassType,, _:K,,
        ( 'None(.KList) => 'Some('ExtendsInterfaces('ListWrap(.KList))) )
      ),, _:K
    ), _,_)                [structural]

rule [processTypeDecsInPCUPhase-ClassDec]:
    <k>
      processTypeDecsInPCUPhase(
        'ClassDec(
          'ClassDecHead( _:K,, Class:ClassType,, _:K,,
            'Some('SuperDec(BaseClassRaw:K)),,
            'Some('ImplementsDec(ImplTypesRaw:K))
          ),,
          'ClassBody( 'ListWrap(Decls:KList) )
        ),
        Pack:PackageId, OuterClass:ClassType
      )
      => saveImportsInPCUPhase(Class)
      ~> processTypeDecsInPCUPhase(Decls, toPackage(Class), Class)
      ...
    </k>
    ( . =>  <class>
              <classType> Class </classType>
              <enclosingClass> OuterClass </enclosingClass>
              <rawExtends> BaseClassRaw </rawExtends>
              <rawImplements> ImplTypesRaw </rawImplements>
              <rawDeclarations>
                'ListWrap(
                    //default constructor
                    //if there is a no-arguments constructor in Decls, it will overwrite this one
                    'ConstrDec(
                      'ConstrDecHead(
                        'ListWrap('Public(.KList)),,
                        'None(.KList),,
                        getSimpleName(Class),,
                        'ListWrap(.KList),,
                        'None(.KList)
                      ),,
                      'ConstrBody('None(.KList),, 'ListWrap(.KList))
                    ),,
                    Decls
                )
              </rawDeclarations>
              <metaType> classMetaT </metaType>
              <classPhase> CreatedCPhase </classPhase>
              ...
            </class> )

rule [processTypeDecsInPCUPhase-IInterfaceDec]:
    <k>
      processTypeDecsInPCUPhase(
        'InterfaceDec(
          'InterfaceDecHead( _:K,, Class:ClassType,, _:K,,
            'Some('ExtendsInterfaces(ImplTypesRaw:K))
          ),,
          'ListWrap(Decls:KList)
        ),
        Pack:PackageId, OuterClass:ClassType
      )
      => saveImportsInPCUPhase(Class)
      ~> processTypeDecsInPCUPhase(Decls, toPackage(Class), Class)
      ...
    </k>
    ( . =>  <class>
              <classType> Class </classType>
              <enclosingClass> OuterClass </enclosingClass>
              <rawExtends> noClass </rawExtends>
              <rawImplements> ImplTypesRaw </rawImplements>
              <rawDeclarations> 'ListWrap(Decls) </rawDeclarations>
              <metaType> interfaceMetaT </metaType>
              <classPhase> CreatedCPhase </classPhase>
              ...
            </class> )

/*@ If the given type is top-level, then save <imports> from the <compUnitImports> cell.
Otherwise do nothing.*/
syntax K ::=  saveImportsInPCUPhase (
                K //is processed into TypeName
              )

rule [saveImportsInPCUPhase]:
    <k> saveImportsInPCUPhase(Class:ClassType) => . ...</k>
    <compUnitImports> CUImports:Map </compUnitImports>
    <classType> Class </classType>
    <enclosingClass> noClass </enclosingClass>
    <cuImports> .Map => CUImports </cuImports>

rule [saveImportsInPCUPhase-Discard]:
    <k> saveImportsInPCUPhase(Class:ClassType) => . ...</k>
    <classType> Class </classType>
    <enclosingClass> class _ </enclosingClass>

endmodule
