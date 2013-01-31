require "java-core.k"
require "java-process-type-names.k"
require "java-process-imports.k"

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
      => compUnitImportsStart(Pack) ~> ImpDecs ~> processTypeDecs(Ks, Pack)
      ...
    </k>
    <computationPhase> ProcessCompUnitsPhase </computationPhase>

//Wrapper over a list of type decs and possible other terms, required to distinguish
//this phase from other pre-processing phases
//Type declarations are processed in this phase wrapped in a processTypeDecs
syntax K ::= "processTypeDecs"  "(" List{K} //The list of terms from which we will
                                            //process just type declarations
                                "," PackageId // the package of the processed types
                                ")"

/*@ \subsection{Class declaration processing}*/

rule [ClassDecNoExtendsDesugar]:
    processTypeDecs('ClassDec('ClassDecHead(_:K,, SimpleClass:Id,, _:K,,
        ( 'None(_)
          => 'Some('SuperDec('ClassType(objectClass,, 'None(.List{K}))))
        ),,
        _:K),, _:K
    ),, _, _)
        [structural]

rule [ClassDecNoImplementsDesugar]:
    processTypeDecs('ClassDec('ClassDecHead(_:K,, SimpleClass:Id,, _:K,, _:K,,
        ( 'None(.List{K}) => 'Some('ImplementsDec('ListWrap(.List{K}))) )
      ),, _:K
    ),, _, _)
        [structural]

//Resolving the base class
context processTypeDecs(
    'ClassDec( 'ClassDecHead(_:K,, _:K,, _:K,, 'Some('SuperDec(HOLE)),,_) ,,_),, _, _)

//Resolving superinterfaces, order is not important
context processTypeDecs('ClassDec('ClassDecHead(_:K,, _:K,, _:K,, _:K,,
          'Some('ImplementsDec('ListWrap(_:List{K},, HOLE,, _:List{K})))
        ),, _:K),, _, _)

//Resolving superinterfaces of an interface, order is not important
context processTypeDecs('InterfaceDec('InterfaceDecHead(_:K,, _:K,, _:K,,
          'Some('ExtendsInterfaces('ListWrap(_:List{K},, HOLE,, _:List{K})))
        ),, _:K),, _, _)

rule [ClassDec]:
      processTypeDecs('ClassDec('ClassDecHead('ListWrap(ClassModifiers:List{K}),, SimpleClass:Id,, _:K,,
          'Some('SuperDec(BaseClass:ClassType)),,
          'Some('ImplementsDec('ListWrap(ImplTypes:List{K})))
        ),,
        'ClassBody( 'ListWrap(Decls:List{K}) )
      ),, Ks:List{K}, Pack:PackageId)
      => classDecImpl(ClassModifiers, SimpleClass, BaseClass, typesToSet(ImplTypes, .Set),
              classMetaT,
              //default constructor
              //if there is a no-args constructor in Decls, it will overwrite this one
              'ListWrap(
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
              ),
              Pack
            )
      ~> processTypeDecs(Ks, Pack)
when isKResult(ImplTypes)
        [structural]

rule [InterfaceDecNoExtendsDesugar]:
    processTypeDecs('InterfaceDec('InterfaceDecHead(_:K,, SimpleClass:Id,, _:K,,
        ( 'None(.List{K}) => 'Some('ExtendsInterfaces('ListWrap(.List{K}))) )
      ),, _:K
    ),, _, _)
        [structural]

rule [InterfaceDec]:
    processTypeDecs('InterfaceDec(
      'InterfaceDecHead(
        'ListWrap(ClassModifiers:List{K}),,
        SimpleClass:Id,,
        _:K,,
        'Some('ExtendsInterfaces('ListWrap(ImplTypes:List{K})))
      ),,
      CBody:K
    ),, Ks:List{K}, Pack:PackageId)
    => classDecImpl(ClassModifiers, SimpleClass, .K, typesToSet(ImplTypes, .Set),
            interfaceMetaT, CBody, Pack)
    ~> processTypeDecs(Ks, Pack)
when isKResult(ImplTypes)
        [structural]

syntax K ::= "classDecImpl" "(" List{K}       // ClassModifiers, .List{K} for Object
                            "," Id            // SimpleClass:Id, simple class name
                            "," K             // BaseClassK, ClassType for classes or .K for interfaces
                            "," K             // typesToSet(ImplTypes, .Map)
                            "," MetaType      // classCT or interfaceCT
                            "," K             // CBody
                            "," PackageId     // The package (outer class) of this class
                          ")"
        [strict(4)]

rule [processTypeDecsElemDiscard]:
    processTypeDecs((Label:KLabel(_) => .List{K}),,_ ,_)
when notBool( Label ==KLabel 'ClassDec orBool Label ==KLabel 'InterfaceDec
              orBool Label ==KLabel 'bodyAsList
            )

rule [processTypeDecsDiscard]:
    processTypeDecs(.List{K}, _) => .K

rule [classDecImpl]:
    <k>
      classDecImpl(_, SimpleClass:Id, BaseClassK:K, setKResult(TypeSet:Set), MetaT:MetaType,
          CBody:K, Pack:PackageId)
      => processTypeDecs(bodyAsList(CBody), toPackage(getClassType(Pack, SimpleClass)))
      ...
    </k>
    <compUnitImports> Imports:Map </compUnitImports>
    <classes>
      ...
      ( . =>  <class>
                <classType> getClassType(Pack, SimpleClass) </classType>
                <extends>
                  #if getClassType(Pack, SimpleClass) =/=K objectClass
                    #then BaseClassK
                    #else .K
                  #fi
                </extends>
                <implements> TypeSet </implements>
                <declarations> CBody </declarations>
                <metaType> MetaT </metaType>
                <imports> Imports </imports>
                ...
              </class> )
      ...
    </classes>

syntax K ::= "typesToSet" "(" List{K} //a list of ClassType terms
                          "," Set     //the result map
                          ")"
syntax KResult ::= "setKResult" "(" Set ")" //set wrapper of type KResult

rule typesToSet((Class:ClassType => .List{K}),,_ , (_ (.Set => SetItem(Class) )))
rule typesToSet(.List{K}, TypeSet:Set) => setKResult(TypeSet)

endmodule
