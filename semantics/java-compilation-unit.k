module JAVA-COMPILATION-UNIT
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

rule [ClassDecWithoutExtendsDesugar]:
    'ClassDec('ClassDecHead(_:K,, Class:Id,,
        _:K,,
        ( 'None(_)
          => 'Some('SuperDec('ClassType(class String2Id("Object"),, 'None(.List{K}))))
        ),,
        _:K),, _:K
    )
        [structural]

rule [ClassDec]:
      'ClassDec('ClassDecHead('ListWrap(ClassModifiers:List{K}),, Class,, _:K,,
          'Some('SuperDec('ClassType(class BaseClass:Id,, _:K))),,
          _:K),,
        'ClassBody( CBody:K )
      )  => classDecImpl(ClassModifiers, Class, BaseClass,
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

syntax K ::= "classDecImpl" "(" List{K} "," Id "," Id "," K ")"

rule [classDecImpl]:
    <k> classDecImpl(_, Class, BaseClass, CBody) => checkForMain(CBody) ...</k>
    <cuPackage> Pack:Package </cuPackage>
    <crntClass> _ => Class </crntClass>
    <classes>
      ...
      ( . =>  <class>
                <className> Class </className>
                <extends> BaseClass </extends>
                <package> Pack </package>
                <declarations> CBody </declarations>
              </class> )
      ...
    </classes>

rule [classDecImplObject]:
    <k> classDecImpl(.List{K}, Class, BaseClass, CBody) => . ...</k>
    <cuPackage> Pack </cuPackage>
    <classes>
      ...
      ( . =>  <class>
                <className> Class </className>
                <extends> .K </extends>
                <package> Pack </package>
                <declarations> CBody </declarations>
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

rule [execute]:
    <k> . =>
      //k-ast for new <MainClass>().main(new String[0]);
      'ExprStm(
        'Invoke(
          'Method(
            'NewInstance(
              'None(.List{K}),,
              class MainClass,,
              'ListWrap(.List{K}),,
              'None(.List{K})
            ),,
            'None(.List{K}),,
            String2Id("main")
          ),,
          'ListWrap('NewArray(
              rtString,,
              'ListWrap('Dim(0 :: int)),,
              'ListWrap(.List{K})))
        )
      )
    </k>
    <env> . </env>
    <mainClass> MainClass:Id </mainClass>
    <executionPhase> "ProcessDeclarations" => "Execute" </executionPhase>

end module
