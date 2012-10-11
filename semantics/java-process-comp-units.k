module JAVA-PROCESS-COMP-UNITS
    imports JAVA-CORE

/*@ \subsection{First pass - processing declarations} */

rule [DefaultPackageDesugar]:
    'CompilationUnit(
      ( 'None(_) => 'Some('PackageDec(.K,, 'PackageName( 'ListWrap(.List{K}) ))) ),,
      _,,_)

rule [CompilationUnit]:
    <k>
      'CompilationUnit('Some('PackageDec(_,, 'PackageName( 'ListWrap(Ks) ))),,_,,K:K) => K
      ...
    </k>
    <cuPackage> _ => package(Ks) </cuPackage>

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
    'ClassDec('ClassDecHead(_:K,, Class,, _:K,, _:K,,
        ( 'None(.List{K}) => 'Some('ImplementsDec('ListWrap(.List{K}))) )
      ),, _:K
    )
        [structural]

rule [ClassDec]:
      'ClassDec('ClassDecHead('ListWrap(ClassModifiers:List{K}),, Class,, _:K,,
          'Some('SuperDec('ClassType(class BaseClass:Id,, _:K))),,
          'Some('ImplementsDec('ListWrap(ImplTypes:List{KResult})))
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
        [structural]

rule [InterfaceDecNoExtendsDesugar]:
    'InterfaceDec('InterfaceDecHead(_:K,, Class,, _:K,,
        ( 'None(.List{K}) => 'Some('ExtendsInterfaces('ListWrap(.List{K}))) )
      ),, _:K
    )
        [structural]

rule [InterfaceDec]:
    'InterfaceDec(
      'InterfaceDecHead(
        'ListWrap(ClassModifiers:List{K}),,
        Class,,
        _:K,,
        'Some('ExtendsInterfaces('ListWrap(ImplTypes)))
      ),,
      CBody
    ) => classDecImpl(ClassModifiers, Class, .K, typesToSet(ImplTypes, .Set),
            interfaceMetaT, CBody)
        [structural]

syntax K ::= "classDecImpl" "("
                                List{K}       // ClassModifiers, .List{K} for Object
                            "," Id            // Class
                            "," K             // BaseClass for classes or .K for interfaces
                            "," K             // typesToSet(ImplTypes, .Map)
                            "," MetaType      // classCT or interfaceCT
                            "," K             // CBody
                          ")"
        [strict(4)]

rule [classDecImpl]:
    <k>
      classDecImpl(_, Class, BaseClassK:K, setKResult(TypeSet), MetaT:MetaType, CBody)
        => checkForMain(CBody)
      ...
    </k>
    <cuPackage> Pack:Package </cuPackage>
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

//for now we consider all static methods found to be main
syntax K ::= "checkForMain" "(" K ")"

rule checkForMain(('ConstrDec(_) => .K) ~> _)

rule (. => checkForStatic(Ks:List{K}) )
    ~> checkForMain('ListWrap(('MethodDec('MethodDecHead('ListWrap(Ks),,_),,_) => .List{K}) ,,_))

syntax K ::= "checkForStatic" "(" List{K} ")"

//For now main method is identified by it's static attribute.
rule <k> checkForStatic('Static(_),,_) => . ...</k>
     <crntClass> Class </crntClass>
     <mainClass> _ => Class </mainClass>

rule checkForStatic((K => .List{K}),, _)
when getKLabel(K) =/=KLabel 'Static

rule checkForStatic(.List{K}) => .

rule checkForMain('ListWrap((K => .List{K}),,_))
when getKLabel(K) =/=KLabel 'MethodDec

rule checkForMain('ListWrap(.List{K})) => .

syntax K ::= "typesToSet" "(" List{K} //a list of class types "class Id"
                          "," Set     //the result map
                          ")"
syntax KResult ::= "setKResult" "(" Set ")" //set wrapper of type KResult

rule typesToSet((class Class => .List{K}),,_ , (_ (.Set => SetItem(Class) )))
rule typesToSet(.List{K}, TypeSet:Set) => setKResult(TypeSet)

end module
