require "java-core.k"
require "java-process-type-names.k"

module JAVA-PROCESS-CLASS-DECS
    imports JAVA-CORE
    imports JAVA-PROCESS-TYPE-NAMES

/*@ \subsection{Third pass - processing class dependencies and imports} */

rule [StartProcessClassDecsPhase]:
    <k> . => processClassesSet(getAllClasses) </k>
    <computationPhase> ProcessCompUnitsPhase => ProcessClassDecsPhase </computationPhase>

syntax K ::= "processClassesSet" "(" K //setwrap(Set) - the set of all classes
                                 ")"  [strict]

//Process a top-level class at any time.
rule [processClassesSetTopLevel]:
    <k>
      (. => processClassDec(Class))
      ~> processClassesSet(setWrap( (SetItem(Class:ClassType) => .) _ ))
      ...
    </k>
    <cuClass> _ => Class </cuClass>
    <classType> Class:ClassType </classType>
    <enclosingClass> noClass </enclosingClass>

//Process an inner class only after its OuterClass have reached DecsProcessedCPP phase.
rule [processClassesSetInner]:
    <k>
      (. => processClassDec(Class))
      ~> processClassesSet(setWrap( (SetItem(Class:ClassType) => .) _ ))
      ...
    </k>
    <cuClass> _ => Class </cuClass>
    <class>
      <classType> Class:ClassType </classType>
      <enclosingClass> OuterClass </enclosingClass>
      ...
    </class>
    <class>
      <classType> OuterClass </classType>
      <preprocessingPhase> DecsProcessedCPP </preprocessingPhase>
      ...
    </class>

rule [processClassesSetDiscard]:
    processClassesSet(setWrap(.)) => .K

//Process a type from phase CreatedCPP to DecsProcessedCPP
syntax K ::= "processClassDec"  "(" ClassType // The class to be processed
                                ")"

//The preprocessing hole, used for custom heating/cooling rules across multiple cells
syntax K ::= "PREP$HOLE"

//Resolving the base class
//Todo this rule should be applied and is not.
rule [heatRawExtends]:
    <k> (. => BaseClassRaw) ~> processClassDec(Class:ClassType) ...</k>
    <classType> Class </classType>
    <rawExtends> BaseClassRaw:K => PREP$HOLE </rawExtends>
//todo bug - this one don't work, let's try an alternative
//when notBool isKResult(BaseClassRaw)
when getKLabel(BaseClassRaw) =/=KLabel 'class_

rule [coolRawExtends]:
    <k> (BaseClass:ClassType => .) ~> processClassDec(Class:ClassType) ...</k>
    <classType> Class </classType>
    <rawExtends> PREP$HOLE => BaseClass </rawExtends>

//Resolving superinterfaces of both classes and interfaces, order is not important
rule [heatRawImplements]:
    <k> (. => BaseInterfaceRaw) ~> processClassDec(Class:ClassType) ...</k>
    <classType> Class </classType>
    <rawImplements> 'ListWrap(_,, (BaseInterfaceRaw:K => PREP$HOLE),, _) </rawImplements>
//todo same bug as for heatRawExtends
//when notBool isKResult(BaseInterfaceRaw)
when getKLabel(BaseInterfaceRaw) =/=KLabel 'class_
        [transition]

rule [coolRawImplements]:
    <k> (BaseInterface:ClassType => .) ~> processClassDec(Class:ClassType) ...</k>
    <classType> Class </classType>
    <rawImplements> 'ListWrap(_,, (PREP$HOLE => BaseInterface),, _) </rawImplements>
        [transition]

rule [processClassDec]:
    <k>
      processClassDec(Class:ClassType)
      =>  classDecImpl(.List{K}, Class, BaseClass,
            kListToSet(ImplTypes, .Set),
            MetaT, OuterClass, CBody
          )
      ...
    </k>
    <classType> Class </classType>
    <enclosingClass> OuterClass:ClassType </enclosingClass>

    //(<rawExtends> BaseClass:ClassType </rawExtends>
    //<rawImplements> 'ListWrap(ImplTypes:List{K}) </rawImplements> => .Bag)
    <rawExtends> BaseClass:ClassType </rawExtends>
    <rawImplements> 'ListWrap(ImplTypes:List{K}) </rawImplements>

    <declarations> CBody:K </declarations>
    <metaType> MetaT:MetaType </metaType>
when isKResult(ImplTypes)
        [transition]

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
    <preprocessingPhase> CreatedCPP => DecsProcessedCPP </preprocessingPhase>

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
