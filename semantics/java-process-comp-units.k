module JAVA-PROCESS-COMP-UNITS
    imports JAVA-CORE

/*@ \subsection{First pass - processing declarations} */

rule [DefaultPackageDesugar]:
    'CompilationUnit(
      ( 'None(_) => 'Some('PackageDec(.K,, 'PackageName( 'ListWrap(.List{K}) ))) ),,
      _,,_)

rule [CompilationUnit]:
    <k>
      'CompilationUnit('Some('PackageDec(_,, 'PackageName( 'ListWrap(Ks:List{K}) ))),,_,,K:K)
      => setCuPackage("", Ks) ~> K
      ...
    </k>

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

/*@ \subsection{Class declaration}
Like in untyped KOOL. */

rule [ClassDecNoExtendsDesugar]:
    'ClassDec('ClassDecHead(_:K,, Class:Id,, _:K,,
        ( 'None(_)
          => 'Some('SuperDec('ClassType(class String2Id("Object"),, 'None(.List{K}))))
        ),,
        _:K),, _:K
    )
        [structural]

rule [ClassDecNoImplementsDesugar]:
    'ClassDec('ClassDecHead(_:K,, Class:Id,, _:K,, _:K,,
        ( 'None(.List{K}) => 'Some('ImplementsDec('ListWrap(.List{K}))) )
      ),, _:K
    )
        [structural]

rule [ClassDec]:
      'ClassDec('ClassDecHead('ListWrap(ClassModifiers:List{K}),, Class:Id,, _:K,,
          'Some('SuperDec('ClassType(class BaseClass:Id,, _:K))),,
          'Some('ImplementsDec('ListWrap(ImplTypes:List{K})))
        ),,
        'ClassBody( CBody:K )
      )  => classDecImpl(ClassModifiers, Class, BaseClass, typesToSet(ImplTypes, .Set), classMetaT,
              //default constructor
              //if there is a no-args constructor in CBody, it will overwrite this one
              'ConstrDec(
                'ConstrDecHead(
                  'ListWrap('Public(.List{K})),,
                  'None(.List{K}),,
                  Class,,
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
    'InterfaceDec('InterfaceDecHead(_:K,, Class:Id,, _:K,,
        ( 'None(.List{K}) => 'Some('ExtendsInterfaces('ListWrap(.List{K}))) )
      ),, _:K
    )
        [structural]

rule [InterfaceDec]:
    'InterfaceDec(
      'InterfaceDecHead(
        'ListWrap(ClassModifiers:List{K}),,
        Class:Id,,
        _:K,,
        'Some('ExtendsInterfaces('ListWrap(ImplTypes:List{K})))
      ),,
      CBody:K
    ) => classDecImpl(ClassModifiers, Class, .K, typesToSet(ImplTypes, .Set),
            interfaceMetaT, CBody)
when isKResult(ImplTypes)
        [structural]

syntax K ::= "classDecImpl" "("
                                List{K}       // ClassModifiers, .List{K} for Object
                            "," Id            // Class:Id
                            "," K             // BaseClassK, Id for classes or .K for interfaces
                            "," K             // typesToSet(ImplTypes, .Map)
                            "," MetaType      // classCT or interfaceCT
                            "," K             // CBody
                          ")"
        [strict(4)]

rule [classDecImpl]:
    <k>
      classDecImpl(_, Class:Id, BaseClassK:K, setKResult(TypeSet:Set), MetaT:MetaType, CBody:K)
      => .K
      ...
    </k>
    <cuPackage> Pack:PackageId </cuPackage>
    <crntClass> _ => Class </crntClass>
    <classes>
      ...
      ( . =>  <class>
                <package> Pack </package>
                <className> Class </className>
                <extends>
                  #if Id2String(Class) =/=String "Object"
                    #then BaseClassK
                    #else .K
                  #fi
                </extends>
                <implements> TypeSet </implements>
                <declarations> CBody </declarations>
                <metaType> MetaT </metaType>
                ...
              </class> )
      ...
    </classes>

/*@ \subsection{Method declaration} */

syntax K ::= "typesToSet" "(" List{K} //a list of class types "class Id"
                          "," Set     //the result map
                          ")"
syntax KResult ::= "setKResult" "(" Set ")" //set wrapper of type KResult

rule typesToSet((class Class:Id => .List{K}),,_ , (_ (.Set => SetItem(Class) )))
rule typesToSet(.List{K}, TypeSet:Set) => setKResult(TypeSet)

endmodule
