require "java-core.k"
require "java-process-type-names.k"
require "java-process-imports.k"

/*
ProcessCompUnitsPhase:
  For each CompUnit separately:
1. Process import decs. Build <compUnitImports>.

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
module JAVA-PROCESS-COMP-UNITS
    imports JAVA-CORE
    imports JAVA-PROCESS-TYPE-NAMES
    imports JAVA-PROCESS-IMPORTS

/*@ \subsection{Second pass - processing declarations} */

rule [StartProcessCompUnitsPhase]:
    <k> . => Pgm </k>
    <programBackup> Pgm:K => . </programBackup>
    <computationPhase> ProcessTypeNamesPhase => ProcessCompUnitsPhase </computationPhase>

//ImpDecs will be processed in the module JAVA-PROCESS-IMPORTS
rule [CompilationUnit]:
    <k>
      'CompilationUnit('Some('PackageDec(_:K,, Pack:PackageId)),,
          ImpDecs:K,, 'ListWrap(Ks:List{K})
      )
      => compUnitImportsStart(Pack) ~> ImpDecs ~> processTypeDecsInPCUPhase(Ks, Pack, noClass)
      ...
    </k>
    <computationPhase> ProcessCompUnitsPhase </computationPhase>

//Wrapper over a list of type decs and possible other terms, required to distinguish
//this phase from other pre-processing phases
//Type declarations are processed in this phase wrapped in a processTypeDecsInPCUPhase
syntax K ::= "processTypeDecsInPCUPhase"  "("
                                    List{K} //The list of terms from which we will
                                            //process just type declarations
                                "," PackageId // the package of the processed types
                                "," ClassType // The outer class of this class, if any,
                                              // or noClass if this is a top-level class
                                ")"

rule [processTypeDecsInPCUPhaseElemDiscard]:
    processTypeDecsInPCUPhase((Label:KLabel(_) => .List{K}),,_ ,_,_)
when notBool( Label ==KLabel 'ClassDec orBool Label ==KLabel 'InterfaceDec
              orBool Label ==KLabel 'bodyAsList
            )

rule [processTypeDecsInPCUPhaseDiscard]:
    processTypeDecsInPCUPhase(.List{K}, _,_) => .K


/*@ \subsection{Class declaration processing}*/

rule [ClassDecNoExtendsDesugar]:
    processTypeDecsInPCUPhase('ClassDec('ClassDecHead(_:K,, SimpleClass:Id,, _:K,,
        ( 'None(_)
          => 'Some('SuperDec('ClassType(objectClass,, 'None(.List{K}))))
        ),,
        _:K),, _:K
    ),,_, _,_)                [structural]

rule [ClassDecNoImplementsDesugar]:
    processTypeDecsInPCUPhase('ClassDec('ClassDecHead(_:K,, SimpleClass:Id,, _:K,, _:K,,
        ( 'None(.List{K}) => 'Some('ImplementsDec('ListWrap(.List{K}))) )
      ),, _:K
    ),,_, _,_)                [structural]

rule [InterfaceDecNoExtendsDesugar]:
    processTypeDecsInPCUPhase('InterfaceDec('InterfaceDecHead(_:K,, SimpleClass:Id,, _:K,,
        ( 'None(.List{K}) => 'Some('ExtendsInterfaces('ListWrap(.List{K}))) )
      ),, _:K
    ),,_, _,_)                [structural]

rule [processTypeDecsInPCUPhaseClassDec]:
    <k>
      processTypeDecsInPCUPhase(
        'ClassDec(
          'ClassDecHead(
            Modifiers:K,,
            SimpleClass:Id,,
            TypeParams:K,,
            'Some('SuperDec(BaseClassRaw:K)),,
            'Some('ImplementsDec('ListWrap(ImplTypesRaw:List{K})))
          ),,
          'ClassBody( 'ListWrap(Decls:List{K}) )
        ),,
        Ks:List{K}, Pack:PackageId, OuterClass:ClassType
      )
      => saveImportsInPCUPhase(getClassType(Pack, SimpleClass))
      ~> processTypeDecsInPCUPhase(Decls, toPackage(getClassType(Pack, SimpleClass)),
          getClassType(Pack, SimpleClass))
      ~> processTypeDecsInPCUPhase(Ks, Pack, OuterClass)
      ...
    </k>
    <classes>
      ...
      ( . =>  <class>
                <classType> getClassType(Pack, SimpleClass) </classType>
                <enclosingClass> OuterClass </enclosingClass>
                <classDec>
                  'ClassDec(
                    'ClassDecHead(
                      Modifiers,,
                      SimpleClass,,
                      TypeParams,,
                      'Some('SuperDec(BaseClassRaw)),,
                      'Some('ImplementsDec('ListWrap(ImplTypesRaw)))
                    ),,
                    'ListWrap(
                      //default constructor
                      //if there is a no-args constructor in Decls, it will overwrite this one
                      'ConstrDec(
                        'ConstrDecHead(
                          'ListWrap('Public(.List{K})),,
                          'None(.List{K}),,
                          SimpleClass,,
                          'ListWrap(.List{K}),,
                          'None(.List{K})
                        ),,
                        'ConstrBody('None(.List{K}),, 'ListWrap(.List{K}))
                      ),,
                      Decls
                  ))
                </classDec>
                <preprocessingPhase> CreatedCPP </preprocessingPhase>
                ...
              </class> )
      ...
    </classes>

rule [processTypeDecsInPCUPhaseInterfaceDec]:
    <k>
      processTypeDecsInPCUPhase(
        'InterfaceDec(
          'InterfaceDecHead(
            Modifiers:K,,
            SimpleClass:Id,,
            TypeParams:K,,
            'Some('ExtendsInterfaces('ListWrap(ImplTypesRaw:List{K})))
          ),,
          'ListWrap(Decls:List{K})
        ),,
        Ks:List{K}, Pack:PackageId, OuterClass:ClassType
      )
      => saveImportsInPCUPhase(getClassType(Pack, SimpleClass))
      ~> processTypeDecsInPCUPhase(Decls, toPackage(getClassType(Pack, SimpleClass)),
          getClassType(Pack, SimpleClass))
      ~> processTypeDecsInPCUPhase(Ks, Pack, OuterClass)
      ...
    </k>
    <classes>
      ...
      ( . =>  <class>
                <classType> getClassType(Pack, SimpleClass) </classType>
                <enclosingClass> OuterClass </enclosingClass>
                <classDec>
                  'InterfaceDec(
                    'InterfaceDecHead(
                      Modifiers,,
                      SimpleClass,,
                      TypeParams,,
                      'Some('ExtendsInterfaces('ListWrap(ImplTypesRaw)))
                    ),,
                    'ListWrap(Decls)
                  )
                </classDec>
                <preprocessingPhase> CreatedCPP </preprocessingPhase>
                ...
              </class> )
      ...
    </classes>

//If the given type is top-level, then save <imports> from the <compUnitImports> cell.
//Otherwise do nothing.
syntax K ::= "saveImportsInPCUPhase" "(" K //is processed into TypeName
                                     ")"

rule [saveImportsInPCUPhase]:
    <k> saveImportsInPCUPhase(Class:ClassType) => . ...</k>
    <compUnitImports> CUImports:Map </compUnitImports>
    <classType> Class </classType>
    <enclosingClass> noClass </enclosingClass>
    <cuImports> .Map => CUImports </cuImports>

rule [saveImportsInPCUPhaseDiscard]:
    <k> saveImportsInPCUPhase(Class:ClassType) => . ...</k>
    <classType> Class </classType>
    <enclosingClass> class _ </enclosingClass>

endmodule
