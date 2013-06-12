require "java-core.k"
require "java-process-type-names.k"

module JAVA-PROCESS-CLASS-DECS
    imports JAVA-CORE
    imports JAVA-PROCESS-TYPE-NAMES

/*@ \subsection{Third pass - processing class dependencies and imports} */

rule [StartProcessClassDecsPhase]:
    <k> . => processClassDecs(getAllClasses) </k>
    <computationPhase> ProcessCompUnitsPhase => ProcessClassDecsPhase </computationPhase>

//Processes all classes from CreatedCPP to DecsProcessedCPP.
syntax K ::= "processClassDecs" "(" K //setWrap(Set) - the set of all classes
                                ")"  [strict]

rule [resolveBasesTopLevelStart]:
    <k> (. => resolveBases(Class)) ~> processClassDecs(_) ...</k>
    <classType> Class:ClassType </classType>
    <enclosingClass> noClass </enclosingClass>
    <preprocessingPhase> CreatedCPP </preprocessingPhase>
    <cuClass> _ => Class </cuClass>

rule [resolveBasesInnerStart]:
    <k> (. => resolveBases(Class)) ~> processClassDecs(_) ...</k>
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
when notBool (isKResult(BaseClassRaw) ==K true)

rule [coolRawExtends]:
    <k> (BaseClass:ClassType => .) ~> resolveBases(Class:ClassType) ...</k>
    <classType> Class </classType>
    <rawExtends> BASES$HOLE => BaseClass </rawExtends>

//Resolving superinterfaces of both classes and interfaces, order is not important
rule [heatRawImplements]:
    <k> (. => BaseInterfaceRaw) ~> resolveBases(Class:ClassType) ...</k>
    <classType> Class </classType>
    <rawImplements> 'ListWrap(_,, (BaseInterfaceRaw:K => BASES$HOLE),, _) </rawImplements>
when notBool(isKResult(BaseInterfaceRaw) ==K true)

rule [coolRawImplements]:
    <k> (BaseInterface:ClassType => .) ~> resolveBases(Class:ClassType) ...</k>
    <classType> Class </classType>
    <rawImplements> 'ListWrap(_,, (BASES$HOLE => BaseInterface),, _) </rawImplements>

rule [resolveBasesEnd]:
    <k> resolveBases(Class:ClassType) => . ...</k>
    <classType> Class </classType>
    <rawExtends> BaseClass:ClassType </rawExtends>
    <rawImplements> 'ListWrap(ImplTypes:List{K}) </rawImplements>
    <unprocessedBases> .K => 'ListWrap(BaseClass,,ImplTypes) </unprocessedBases>
    <preprocessingPhase> CreatedCPP => BasesResolvedCPP </preprocessingPhase>
when isKResult(ImplTypes)

rule [markBaseProcessed]:
    <k> processClassDecs(_) ...</k>
    <class>
      <unprocessedBases> 'ListWrap((BaseClass:ClassType => .List{K}) ,,_) </unprocessedBases>
      ...
    </class>
    <class>
      <classType> BaseClass </classType>
      <preprocessingPhase> DecsProcessedCPP </preprocessingPhase>
      ...
    </class>

//this one is for class Object
rule [markNoClassProcessed]:
    <k> processClassDecs(_) ...</k>
    <unprocessedBases> 'ListWrap((noClass => .List{K}) ,,_) </unprocessedBases>

rule [processClassDecEnd]:
    <k>
      (. => saveImplements(Class, kListToSet(ImplTypes, .Set))
         ~> saveImports(Class, OuterClass, (BaseClass,,ImplTypes), .K, noValue, noValue)
      )
      ~> processClassDecs(setWrap( (SetItem(Class:ClassType) => .Set) _:Set ))
      ...
    </k>
    <classType> Class </classType>
    <enclosingClass> OuterClass:ClassType </enclosingClass>
    <declarations> CBody:K </declarations>
    <metaType> MetaT:MetaType </metaType>
    <preprocessingPhase> BasesResolvedCPP => DecsProcessedCPP </preprocessingPhase>
    <extends> .K => BaseClass </extends>
    ( <rawExtends> BaseClass:ClassType </rawExtends>
      <rawImplements> 'ListWrap(ImplTypes:List{K}) </rawImplements>
      <unprocessedBases> 'ListWrap(.List{K}) </unprocessedBases> => .Bag)

rule [processClassDecsDiscard]:
    processClassDecs(setWrap(.)) => .K

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
                            "," List{K}   //The list of base classes
                            "," K         //The toPackage(ClassType), to be computed
                            "," K         //The inner types map of the given class
                            "," K         //The mapWrap(Imports), containing in the end
                                          //the desired Imports map
                            ")"   [strict(5,6)]

//Compute the ClassType and the Package representing the given class
rule [saveImportsComputePackage]:
    saveImports(Class:ClassType, _,_,
        .K => toPackage(Class),
        noValue, noValue
    )

rule [saveImportsComputeOwnInnerMap]:
    saveImports(_,_,_, Pack:PackageId,
      noValue => getNamesMap(Pack),
      noValue
    )

rule [saveImportsInheritTypes]:
    <k>
      saveImports(_,_, ((BaseClass:ClassType => .List{K}),, _), Pack:PackageId,
        mapWrap(InnerTypesMap:Map) => mapUnion(BaseClassMap, InnerTypesMap),
        noValue
      )
      ...
    </k>
    <classType> BaseClass </classType>
    <imports> BaseClassMap:Map </imports>

rule [saveImportsDiscardNoClass]:
    saveImports(_,_, ((noClass => .List{K}),, _), _,_,_)

//Compute the imports map for the ClassType computed at part 1
//when this class is a top-level class
rule [saveImportsComputeImportsTop]:
    <k>
      saveImports(Class:ClassType, noClass, .List{K}, _, mapWrap(InnerTypesMap:Map),
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
      saveImports(_, OuterClass:ClassType, .List{K}, _, mapWrap(InnerTypesMap:Map),
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
      saveImports(Class:ClassType, _,_,_,_, mapWrap(Imports:Map)) => .
      ...
    </k>
    <classType> Class </classType>
    <imports> _ => Imports </imports>
    (<cuImports> _ </cuImports> => .Bag)

endmodule
