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

//todo remove aux
rule [ClassDec]:
      'ClassDec('ClassDecHead('ListWrap(ClassModifiers:List{K}),, Class,, _:K,,
          'Some('SuperDec('ClassType(class BaseClass:Id,, _:K))),,
          'Some('ImplementsDec('ListWrap(ImplTypes:List{KResult})))
        ),,
        'ClassBody( CBody:K )
      )  => classDecImpl(ClassModifiers, Class, BaseClass, ImplTypes, classMetaT,
              //public empty constructor
              //will be overwritten by any other constructor in S
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
      'ListWrap(CBody)
    ) => classDecImpl(ClassModifiers, Class, .K, ImplTypes, interfaceMetaT, CBody)
        [structural]

syntax K ::= "aux" "(" List{K} ")"
syntax K ::= "classDecImpl" "("
                                List{K}       // ClassModifiers, .List{K} for Object
                            "," Id            // Class
                            "," Id            // BaseClass
                            "," List{KResult} // ImplTypes
                            "," MetaType      // classCT or interfaceCT
                            "," K             // CBody
                          ")"

//todo use ImplTypes
rule [classDecImpl]:
    <k>
      classDecImpl(_, Class, BaseClass, ImplTypes, MetaT:MetaType, CBody)
        => checkForMain(CBody)
      ...
    </k>
    <cuPackage> Pack:Package </cuPackage>
    <crntClass> _ => Class </crntClass>
    <classes>
      ...
      ( . =>  <class>
                <className> Class </className>
                <extends> BaseClass </extends>
                <package> Pack </package>
                <declarations> CBody </declarations>
                //bug: uncommenting this line causes infinite loop
                //<metaType> MetaT </metaType>
                ...
              </class> )
      ...
    </classes>

rule [classDecImplObject]:
    <k> classDecImpl(.List{K}, Class, BaseClass, _, classMetaT, CBody) => . ...</k>
    <cuPackage> Pack </cuPackage>
    <classes>
      ...
      ( . =>  <class>
                <className> Class </className>
                <extends> .K </extends>
                <package> Pack </package>
                <declarations> CBody </declarations>
                //bug: uncommenting this line causes infinite loop
                //<metaType> classMetaT </metaType>
                ...
              </class> )
      ...
    </classes>
when Id2String(Class) ==String "Object"

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

end module
