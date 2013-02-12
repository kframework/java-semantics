require "java-core.k"
require "java-process-type-names.k"

module JAVA-PROCESS-CLASS-DECS
    imports JAVA-CORE
    imports JAVA-PROCESS-TYPE-NAMES

/*@ \subsection{Third pass - processing class dependencies and imports} */

rule [StartProcessClassDecsPhase]:
    <k> . => processClassesSet(getAllClasses) </k>
    <computationPhase> ProcessCompUnitsPhase => ProcessClassDecsPhase </computationPhase>

//Processes all classes from CreatedCPP to DecsProcessedCPP.
syntax K ::= "processClassesSet" "(" K //setwrap(Set) - the set of all classes
                                 ")"  [strict]

rule [resolveBasesTopLevelStart]:
    <k> (. => resolveBases(Class)) ~> processClassesSet(_) ...</k>
    <classType> Class:ClassType </classType>
    <enclosingClass> noClass </enclosingClass>
    <preprocessingPhase> CreatedCPP </preprocessingPhase>
    <cuClass> _ => Class </cuClass>

rule [resolveBasesInnerStart]:
    <k> (. => resolveBases(Class)) ~> processClassesSet(_) ...</k>
    <class>
      <classType> Class:ClassType </classType>
      <enclosingClass> OuterClass:ClassType </enclosingClass>
      <preprocessingPhase> CreatedCPP </preprocessingPhase>
      ...
    </class>
    <class>
      <classType> OuterClass </classType>
      <preprocessingPhase> DecsProcessedCPP </preprocessingPhase>
      ...
    </class>
    <cuClass> _ => Class </cuClass>

//Process the given class from CreatedCPP to BasesResolvedCPP.
syntax K ::= "resolveBases" "(" ClassType ")"

//The hole used for resolving class bases - extends/implements clauses.
syntax K ::= "BASES$HOLE"

//Resolving the base class
rule [heatRawExtends]:
    <k> (. => BaseClassRaw) ~> resolveBases(Class:ClassType) ...</k>
    <classType> Class </classType>
    <rawExtends> BaseClassRaw:K => BASES$HOLE </rawExtends>
//todo bug - this one don't work, let's try an alternative
//when notBool isKResult(BaseClassRaw)
when        getKLabel(BaseClassRaw) =/=KLabel 'class_
    andBool getKLabel(BaseClassRaw) =/=KLabel 'noClass

rule [coolRawExtends]:
    <k> (BaseClass:ClassType => .) ~> resolveBases(Class:ClassType) ...</k>
    <classType> Class </classType>
    <rawExtends> BASES$HOLE => BaseClass </rawExtends>

//Resolving superinterfaces of both classes and interfaces, order is not important
rule [heatRawImplements]:
    <k> (. => BaseInterfaceRaw) ~> resolveBases(Class:ClassType) ...</k>
    <classType> Class </classType>
    <rawImplements> 'ListWrap(_,, (BaseInterfaceRaw:K => BASES$HOLE),, _) </rawImplements>
//todo same bug as for heatRawExtends
//when notBool isKResult(BaseInterfaceRaw)
when getKLabel(BaseInterfaceRaw) =/=KLabel 'class_

rule [coolRawImplements]:
    <k> (BaseInterface:ClassType => .) ~> resolveBases(Class:ClassType) ...</k>
    <classType> Class </classType>
    <rawImplements> 'ListWrap(_,, (BASES$HOLE => BaseInterface),, _) </rawImplements>

rule [resolveBasesEnd]:
    <k> resolveBases(Class:ClassType) => . ...</k>
    <classType> Class </classType>
    <rawExtends> BaseClass:ClassType </rawExtends>
    <rawImplements> 'ListWrap(ImplTypes:List{K}) </rawImplements>
    <preprocessingPhase> CreatedCPP => BasesResolvedCPP </preprocessingPhase>
when isKResult(ImplTypes)

//For now, the imports map of a class will consist the imports map of the compilation unit +
// direct inner types.
//todo the imports algorithm is very simple and will be updated soon.
//We cannot distinguish between Class == objectClass and others earlier,
//because we don't have Class:ClassType back then.
rule [processClassDecEnd]:
    <k>
      (. => saveImplements(Class, kListToSet(ImplTypes, .Set))
         ~> saveImports(Class, OuterClass, .K, noValue, noValue)
      )
      ~> processClassesSet(setWrap( (SetItem(Class:ClassType) => .Set) _:Set ))
      ...
    </k>
    <classType> Class </classType>
    <enclosingClass> OuterClass:ClassType </enclosingClass>
    <declarations> CBody:K </declarations>
    <metaType> MetaT:MetaType </metaType>
    <preprocessingPhase> BasesResolvedCPP => DecsProcessedCPP </preprocessingPhase>
    <extends> .K => BaseClass </extends>
    ( <rawExtends> BaseClass:ClassType </rawExtends>
      <rawImplements> 'ListWrap(ImplTypes:List{K}) </rawImplements> => .Bag)

rule [processClassesSetDiscard]:
    processClassesSet(setWrap(.)) => .K

//Converts a term of type List{K} into a Set
syntax K ::= "kListToSet" "(" List{K} //a list of some K Terms
                          "," Set     //the result set
                          ")"

rule kListToSet((K:K => .List{K}),,_ , (_ (.Set => SetItem(K) )))
rule kListToSet(.List{K}, TypeSet:Set) => setWrap(TypeSet)

//receives a kListToSet term ans saves the resulting set into <imports>
syntax K ::= "saveImplements" "(" ClassType "," K ")" [strict(2)]

rule [saveImplements]:
    <k> saveImplements(Class:ClassType, setWrap(ImplSet:Set)) => . ...</k>
    <classType> Class </classType>
    <implements> .Set => ImplSet </implements>

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
