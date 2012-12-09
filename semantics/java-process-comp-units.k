require "java-core.k"

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
    'ClassDec('ClassDecHead(_:K,, SimpleClass:Id,, _:K,,
        ( 'None(_)
          => 'Some('SuperDec('ClassType(class String2Id("Object"),, 'None(.List{K}))))
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

//todo - How will we resolve the class definition order problem?
//What if the base class was not encountered yet?

//Resolving the base class
context 'ClassDec('ClassDecHead(_:K,, _:K,, _:K,,
          'Some('SuperDec('ClassType(HOLE,, _:K))),,
          _:K
        ),,
        _:K
      )

//Resolving superinterfaces
context 'ClassDec('ClassDecHead(_:K,, _:K,, _:K,, _:K,,
          'Some('ImplementsDec('ListWrap(KRs:List{K},, HOLE,, _:List{K})))
        ),,
        _:K
      )
when isKResult(KRs)

rule [ClassDec]:
      'ClassDec('ClassDecHead('ListWrap(ClassModifiers:List{K}),, SimpleClass:Id,, _:K,,
          'Some('SuperDec('ClassType(BaseClass:ClassType,, _:K))),,
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
    <crntClass> _ => getClassType(Pack, SimpleClass) </crntClass>
    <classes>
      ...
      ( . =>  <class>
                <classType> getClassType(Pack, SimpleClass) </classType>
                <package> Pack </package>
                <classSimpleName> SimpleClass </classSimpleName>
                <extends>
                  #if getClassType(Pack, SimpleClass) =/=K class String2Id("Object")
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

//returns the fully qualified class name from given parameters
syntax K ::= "getClassType" "(" PackageId // the Package Id
                            "," Id        // Simple class name
                            ")"                                 [function]

//todo uncomment true implementation of this function
/*
rule [getclassTypePackagePresent]:
    getClassType(packageId(PackStr:String), SimpleClass:Id)
    => class String2Id(PackStr +String "." +String Id2String(SimpleClass))
        [structural, anywhere]
*/

rule getClassType(_, SimpleClass:Id) => class SimpleClass

/*@ \subsection{Method declaration} */

syntax K ::= "typesToSet" "(" List{K} //a list of ClassType terms
                          "," Set     //the result map
                          ")"
syntax KResult ::= "setKResult" "(" Set ")" //set wrapper of type KResult

rule typesToSet((Class:ClassType => .List{K}),,_ , (_ (.Set => SetItem(Class) )))
rule typesToSet(.List{K}, TypeSet:Set) => setKResult(TypeSet)

endmodule
