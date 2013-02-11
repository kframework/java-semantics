require "java-core.k"
require "java-process-type-names.k"

module JAVA-PROCESS-CLASS-DECS
    imports JAVA-CORE
    imports JAVA-PROCESS-TYPE-NAMES

/*@ \subsection{Third pass - processing class dependencies and imports} */

rule [StartProcessClassDecsPhase]:
    <k> . => processClassesBag(Classes) </k>
    <classes> Classes:Bag </classes>
    <computationPhase> ProcessCompUnitsPhase => ProcessClassDecsPhase </computationPhase>

//todo use getAllClasses instead of <classes> bag
syntax K ::= "processClassesBag" "(" Bag //the content of <classes> cell after ProcessCompUnits
                                 ")"

//Process a top-level class at any time.
rule [processClassesBagTopLevel]:
    <k>
      (. => processClassDec(Class, ClassDec))
      ~> processClassesBag(
        (<class>
          <classType> Class:ClassType </classType>
          <classDec> ClassDec:K </classDec>
          <enclosingClass> noClass </enclosingClass>
          ...
         </class> => .Bag)
        _:Bag
      )
      ...
    </k>
    <cuClass> _ => Class </cuClass>

//Process an inner class only after its OuterClass have reached DecsProcessedCPP phase.
rule [processClassesBagInner]:
    <k>
      (. => processClassDec(Class, ClassDec))
      ~> processClassesBag(
        (<class>
          <classType> Class:ClassType </classType>
          <classDec> ClassDec:K </classDec>
          <enclosingClass> OuterClass </enclosingClass>
          ...
         </class> => .Bag)
        _:Bag
      )
      ...
    </k>
    <cuClass> _ => Class </cuClass>
    <classType> OuterClass </classType>
    <preprocessingPhase> DecsProcessedCPP </preprocessingPhase>

rule [processClassesBagDiscard]:
    processClassesBag(.) => .K

//Process a type from phase CreatedCPP to DecsProcessedCPP
syntax K ::= "processClassDec"  "(" ClassType // The class to be processed
                                "," K         // an original 'ClassDec or 'InterfaceDec term
                                ")"

/*@ \subsection{Class declaration processing}*/

rule [ClassDecNoExtendsDesugar]:
    processClassDec(_, 'ClassDec('ClassDecHead(_:K,, SimpleClass:Id,, _:K,,
        ( 'None(_)
          => 'Some('SuperDec('ClassType(objectClass,, 'None(.List{K}))))
        ),,
        _:K),, _:K
    ))
        [structural]

rule [ClassDecNoImplementsDesugar]:
    processClassDec(_, 'ClassDec('ClassDecHead(_:K,, SimpleClass:Id,, _:K,, _:K,,
        ( 'None(.List{K}) => 'Some('ImplementsDec('ListWrap(.List{K}))) )
      ),, _:K
    ))
        [structural]

//Resolving the base class
context processClassDec(_,
    'ClassDec( 'ClassDecHead(_:K,, _:K,, _:K,, 'Some('SuperDec(HOLE)),,_) ,,_))

//Resolving superinterfaces, order is not important
context processClassDec(_, 'ClassDec('ClassDecHead(_:K,, _:K,, _:K,, _:K,,
          'Some('ImplementsDec('ListWrap(_:List{K},, HOLE,, _:List{K})))
        ),, _:K))

//Resolving superinterfaces of an interface, order is not important
context processClassDec(_, 'InterfaceDec('InterfaceDecHead(_:K,, _:K,, _:K,,
          'Some('ExtendsInterfaces('ListWrap(_:List{K},, HOLE,, _:List{K})))
        ),, _:K))

rule [ClassDec]:
    <k>
      processClassDec(
        Class:ClassType,
        'ClassDec('ClassDecHead('ListWrap(ClassModifiers:List{K}),, SimpleClass:Id,, _:K,,
            'Some('SuperDec(BaseClass:ClassType)),,
            'Some('ImplementsDec('ListWrap(ImplTypes:List{K})))
          ),,
          'ClassBody( 'ListWrap(Decls:List{K}) )
      ))
      =>  classDecImpl(ClassModifiers, Class, BaseClass,
            kListToSet(ImplTypes, .Set),
            classMetaT, OuterClass,
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
            )
          )
      ...
    </k>
    <classType> Class </classType>
    <enclosingClass> OuterClass:ClassType </enclosingClass>
when isKResult(ImplTypes)
        [structural]

rule [InterfaceDecNoExtendsDesugar]:
    processClassDec(_, 'InterfaceDec('InterfaceDecHead(_:K,, SimpleClass:Id,, _:K,,
        ( 'None(.List{K}) => 'Some('ExtendsInterfaces('ListWrap(.List{K}))) )
      ),, _:K
    ))
        [structural]

rule [InterfaceDec]:
    <k>
      processClassDec(Class:ClassType, 'InterfaceDec(
        'InterfaceDecHead(
          'ListWrap(ClassModifiers:List{K}),,
          SimpleClass:Id,,
          _:K,,
          'Some('ExtendsInterfaces('ListWrap(ImplTypes:List{K})))
        ),,
        CBody:K
      ))
      => classDecImpl(ClassModifiers, Class,
              noClass, kListToSet(ImplTypes, .Set),
              interfaceMetaT, OuterClass, CBody)
      ...
    </k>
    <classType> Class </classType>
    <enclosingClass> OuterClass:ClassType </enclosingClass>
when isKResult(ImplTypes)
        [structural]

syntax K ::= "classDecImpl" "(" List{K}       // ClassModifiers, .List{K} for Object
                            "," ClassType     // Class - the actual class
                            "," ClassType     // BaseClass, ClassType for classes
                                              // or noClass for interfaces
                            "," K             // kListToSet(ImplTypes, .Map)
                            "," MetaType      // classCT or interfaceCT
                            "," ClassType     // The outer class of this class, if any,
                                              // or noClass if this is a top-level class
                            "," K             // CBody
                          ")"
        [strict(4)]

//For now, the imports map of a class will consist the imports map of the compilation unit +
// direct inner types.
//todo the imports algorithm is very simple and will be updated soon.
//We cannot distinguish between Class == objectClass and others earlier,
//because we don't have Class:ClassType back then.
rule [classDecImpl]:
    <k>
      classDecImpl(_, Class:ClassType, BaseClass:ClassType, setWrap(TypeSet:Set),
          MetaT:MetaType, OuterClass:ClassType, CBody:K)
      => saveImports(Class, OuterClass, .K, noValue, noValue)
      ...
    </k>
    <classType> Class </classType>
    <extends>
      .K =>
      #if Class =/=K objectClass
        #then BaseClass
        #else noClass
      #fi
    </extends>
    <implements> .Set => TypeSet </implements>
    <declarations> .K => CBody </declarations>
    <metaType> .K => MetaT </metaType>
    <preprocessingPhase> CreatedCPP => DecsProcessedCPP </preprocessingPhase>
    (<classDec> _ </classDec> => .Bag)

//Converts a term of type List{K} into a Set
syntax K ::= "kListToSet" "(" List{K} //a list of some K Terms
                          "," Set     //the result set
                          ")"

rule kListToSet((K:K => .List{K}),,_ , (_ (.Set => SetItem(K) )))
rule kListToSet(.List{K}, TypeSet:Set) => setWrap(TypeSet)

//Computes the full names map used to resolve
//classes by simple name inside the class specified by the arg 4.
syntax K ::= "saveImports"  "(" ClassType //Class - the actual class
                            "," ClassType //The outer class of this class, if any,
                                          //or noClass if this is a top-level class
                            "," K         //The toPackage(ClassType), to be computed
                            "," K         //The inner types map of the given class
                            "," K         //The mapWrap(Imports), containing in the end
                                          //the desired Imports map
                            ")"   [strict(4,5)]

//Compute the ClassType and the Package representing the given class
rule [saveImportsComputePackage]:
    saveImports(Class:ClassType, _,
        .K => toPackage(Class),
        noValue, noValue
    )

rule [saveImportsComputeInnerMap]:
    saveImports(_,_, Pack:PackageId,
      noValue => getNamesMap(Pack),
      noValue
    )

//Compute the imports map for the ClassType computed at part 1
//when this class is a top-level class
rule [saveImportsComputeImportsTop]:
    <k>
      saveImports(Class:ClassType, noClass, _, mapWrap(InnerTypesMap:Map),
        noValue => mapUnion(Imports, InnerTypesMap)
      )
      ...
    </k>
    <classType> Class </classType>
    <cuImports> Imports:Map </cuImports>

//Compute the imports map for the ClassType computed at part 1
//when this class is an inner class
rule [saveImportsComputeImportsInner]:
    <k>
      saveImports(_, OuterClass:ClassType, _, mapWrap(InnerTypesMap:Map),
        noValue => mapUnion(Imports, InnerTypesMap)
      )
      ...
    </k>
    <classType> OuterClass </classType>
    <imports> Imports:Map </imports>
when OuterClass =/=K noClass

//Save the computed Imports map into the <imports> cell of the given class
rule [saveImports]:
    <k>
      saveImports(Class:ClassType, _, _, _, mapWrap(Imports:Map)) => .
      ...
    </k>
    <classType> Class </classType>
    <imports> _ => Imports </imports>
    (<cuImports> _ </cuImports> => .Bag)

//evaluates into a setWrap(S), containing all the classes in the program.
//uses <typeNamesMap> to compute the result
syntax K ::= "getAllClasses"
           | "getAllClasses" "(" Map "," Set ")"

rule [getAllClassesStart]:
    <k> getAllClasses => getAllClasses(NamesMap, .Set) ...</k>
    <typeNamesMap> NamesMap:Map </typeNamesMap>

rule getAllClasses(_ _ |-> mapWrap(_ (_ |-> Class:ClassType => .Map)), _ (.Set => SetItem(Class)))
rule getAllClasses(_ (_ |-> mapWrap(.Map) => .Map), _)
rule getAllClasses(.Map, ClassesSet:Set) => setWrap(ClassesSet)

endmodule
