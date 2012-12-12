require "java-core.k"
require "java-process-top-level-names.k"
require "java-process-imports.k"

module JAVA-PROCESS-COMP-UNITS
    imports JAVA-CORE
    imports JAVA-PROCESS-TOP-LEVEL-NAMES
    imports JAVA-PROCESS-IMPORTS

/*@ \subsection{Second pass - processing declarations} */

rule [StartProcessCompUnitsPhase]:
    <k> . => Pgm </k>
    <programBackup> Pgm:K => . </programBackup>
    <computationPhase> ProcessTopLevelNamesPhase => ProcessCompUnitsPhase </computationPhase>

//Impdecs will be processed in the module JAVA-PROCESS-IMPORTS
rule [CompilationUnit]:
    <k>
      'CompilationUnit('Some('PackageDec(_:K,, Pack:PackageId)),,
          ImpDecs:K,, K:K
      )
      => compUnitImportsStart ~> ImpDecs ~> K
      ...
    </k>
    <cuPackage> _ => Pack </cuPackage>
    <computationPhase> ProcessCompUnitsPhase </computationPhase>

/*@ \subsection{Class declaration processing}*/

rule [ClassDecNoExtendsDesugar]:
    'ClassDec('ClassDecHead(_:K,, SimpleClass:Id,, _:K,,
        ( 'None(_)
          => 'Some('SuperDec('ClassType(objectClass,, 'None(.List{K}))))
        ),,
        _:K),, _:K
    )
        [structural]

rule [ClassDecNoImplementsDesugar]:
    'ClassDec('ClassDecHead(_:K,, SimpleClass:Id,, _:K,, _:K,,
        ( 'None(.List{K}) => 'Some('ImplementsDec('ListWrap(.List{K}))) )
      ),, _:K
    )
        [structural]

//Resolving the base class
context 'ClassDec( 'ClassDecHead(_:K,, _:K,, _:K,, 'Some('SuperDec(HOLE)),,_) ,,_)

//Resolving superinterfaces, order is not important
context 'ClassDec('ClassDecHead(_:K,, _:K,, _:K,, _:K,,
          'Some('ImplementsDec('ListWrap(_:List{K},, HOLE,, _:List{K})))
        ),, _:K)

//Resolving superinterfaces of an interface, order is not important
context 'InterfaceDec('InterfaceDecHead(_:K,, _:K,, _:K,,
          'Some('ExtendsInterfaces('ListWrap(_:List{K},, HOLE,, _:List{K})))
        ),, _:K)

rule [ClassDec]:
      'ClassDec('ClassDecHead('ListWrap(ClassModifiers:List{K}),, SimpleClass:Id,, _:K,,
          'Some('SuperDec(BaseClass:ClassType)),,
          'Some('ImplementsDec('ListWrap(ImplTypes:List{K})))
        ),,
        'ClassBody( CBody:K )
      )  => classDecImpl(ClassModifiers, SimpleClass, BaseClass, typesToSet(ImplTypes, .Set),
              classMetaT,
              //default constructor
              //if there is a no-args constructor in CBody, it will overwrite this one
              'ConstrDec(
                'ConstrDecHead(
                  'ListWrap('Public(.List{K})),,
                  'None(.List{K}),,
                  SimpleClass,,
                  'ListWrap(.List{K}),,
                  'None(.List{K})
                ),,
                'ConstrBody('None(.List{K}),, 'ListWrap(.List{K}))
              )
              ~> CBody
            )
when isKResult(ImplTypes)
        [structural]

rule [InterfaceDecNoExtendsDesugar]:
    'InterfaceDec('InterfaceDecHead(_:K,, SimpleClass:Id,, _:K,,
        ( 'None(.List{K}) => 'Some('ExtendsInterfaces('ListWrap(.List{K}))) )
      ),, _:K
    )
        [structural]

rule [InterfaceDec]:
    'InterfaceDec(
      'InterfaceDecHead(
        'ListWrap(ClassModifiers:List{K}),,
        SimpleClass:Id,,
        _:K,,
        'Some('ExtendsInterfaces('ListWrap(ImplTypes:List{K})))
      ),,
      CBody:K
    ) => classDecImpl(ClassModifiers, SimpleClass, .K, typesToSet(ImplTypes, .Set),
            interfaceMetaT, CBody)
when isKResult(ImplTypes)
        [structural]

syntax K ::= "classDecImpl" "("
                                List{K}       // ClassModifiers, .List{K} for Object
                            "," Id            // SimpleClass:Id, simple class name
                            "," K             // BaseClassK, ClassType for classes or .K for interfaces
                            "," K             // typesToSet(ImplTypes, .Map)
                            "," MetaType      // classCT or interfaceCT
                            "," K             // CBody
                          ")"
        [strict(4)]

rule [classDecImpl]:
    <k>
      classDecImpl(_, SimpleClass:Id, BaseClassK:K, setKResult(TypeSet:Set), MetaT:MetaType, CBody:K)
      => .K
      ...
    </k>
    <cuPackage> Pack:PackageId </cuPackage>
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
