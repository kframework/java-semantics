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

/* Question: how do we know if bases were already resolved for this class or not?
  Answer: When resolveBases(Class) is consumed by the rule [resolveBasesEnd], the class
  clanges its state: CreatedCPP => BasesResolvedCPP
*/
rule [resolveBasesTopLevelStart]:
    <k> (. => resolveBases(Class, RawExtends, RawImplements)) ~> processClassDecs(_) ...</k>
    <classType> Class:ClassType </classType>
    <rawExtends> RawExtends:K </rawExtends>
    <rawImplements> 'ListWrap(RawImplements:KList) </rawImplements>
    <enclosingClass> noClass </enclosingClass>
    <preprocessingPhase> CreatedCPP </preprocessingPhase>
    <crntClass> _ => Class </crntClass>

rule [resolveBasesInnerStart]:
    <k> (. => resolveBases(Class, RawExtends, RawImplements)) ~> processClassDecs(_) ...</k>
    <class>
      <classType> Class:ClassType </classType>
      <rawExtends> RawExtends:K </rawExtends>
      <rawImplements> 'ListWrap(RawImplements:KList) </rawImplements>
      <enclosingClass> OuterClass:ClassType </enclosingClass>
      <preprocessingPhase> CreatedCPP </preprocessingPhase>
      ...
    </class>
    <class>
      <classType> OuterClass </classType>
      <preprocessingPhase> OuterClassPhase:ClassPreprocessingPhase </preprocessingPhase>
      ...
    </class>
    <crntClass> _ => Class </crntClass>
when
    OuterClassPhase ==K DecsProcessedCPP orBool OuterClassPhase ==K MembersProcessedCPP

//Process the given class from CreatedCPP to BasesResolvedCPP.
syntax K ::= "resolveBases" "(" ClassType //The class for which we resolve bases
                            "," K         //Base class
                            "," KList     //Implements clauses
                            ")"

context resolveBases(_, HOLE, _)      //Heat extends dec
context resolveBases(_,_, _,,HOLE,,_) //Heat implements decs

rule [resolveBases]:
    <k> resolveBases(Class, BaseClass:ClassType, ImplTypes:KList) => . ...</k>
    <classType> Class </classType>
    <rawExtends> _ => BaseClass </rawExtends>
    <rawImplements> _ => 'ListWrap(ImplTypes) </rawImplements>
    <unprocessedBases> .K => 'ListWrap(BaseClass,,ImplTypes) </unprocessedBases>
    <preprocessingPhase> CreatedCPP => BasesResolvedCPP </preprocessingPhase>
when isKResult(ImplTypes)

rule [markBaseProcessed]:
    <k> processClassDecs(_) ...</k>
    <class>
      <unprocessedBases> 'ListWrap((BaseClass:ClassType => .KList) ,,_) </unprocessedBases>
      ...
    </class>
    <class>
      <classType> BaseClass </classType>
      <preprocessingPhase> BaseClassPhase:ClassPreprocessingPhase </preprocessingPhase>
      ...
    </class>
when
    BaseClassPhase ==K DecsProcessedCPP orBool BaseClassPhase ==K MembersProcessedCPP

//this one is for class Object
rule [markNoClassProcessed]:
    <k> processClassDecs(_) ...</k>
    <unprocessedBases> 'ListWrap((noClass => .KList) ,,_) </unprocessedBases>

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
      <rawImplements> 'ListWrap(ImplTypes:KList) </rawImplements>
      <unprocessedBases> 'ListWrap(.KList) </unprocessedBases> => .Bag)

rule [processClassDecsDiscard]:
    processClassDecs(setWrap(.)) => .K

//Converts a term of type KList into a Set
syntax K ::= "kListToSet" "(" KList //a list of some K Terms
                          "," Set     //the result set
                          ")"

rule kListToSet((K:K => .KList),,_ , (_ (.Set => SetItem(K) )))
rule kListToSet(.KList, TypeSet:Set) => setWrap(TypeSet)

//receives a kListToSet term ans saves the resulting set into <imports>
syntax K ::= "saveImplements" "(" ClassType "," K ")" [strict(2)]

rule [saveImplements]:
    <k> saveImplements(Class:ClassType, setWrap(ImplSet:Set)) => . ...</k>
    <classType> Class </classType>
    <implements> .Set => ImplSet </implements>

//Computes the full names map used to resolve
//classes by simple name inside the class specified by the arg 4,
//and stores them inside <imports>.
syntax K ::= "saveImports"  "(" ClassType //Class - the actual class
                            "," ClassType //The outer class of this class, if any,
                                          //or noClass if this is a top-level class
                            "," KList   //The list of base classes
                            "," K         //The toPackage(ClassType), to be computed
                            "," K         //The inner types map of the given class
                            "," K         //The mapWrap(Imports), containing in the end
                                          //the desired Imports map
                            ")"   [strict(5,6)]

//todo K 10341 it looks like [strict] above don't work
context saveImports(_,_,_,_,HOLE,_)
context saveImports(_,_,_,_,_,HOLE)

//Compute the ClassType and the Package representing the given class
rule [saveImportsComputePackage]:
    saveImports(Class:ClassType, _,_,
        .K => toPackage(Class),
        noValue, noValue
    )

//Retrieves the names map of the package corresponding to this class
rule [saveImportsComputeOwnInnerMap]:
    saveImports(_,_,_, Pack:PackageId,
      noValue => getNamesMap(Pack),
      noValue
    )

rule [saveImportsInheritTypes]:
    <k>
      saveImports(_,_, ((BaseClass:ClassType => .KList),, _), Pack:PackageId,
        mapWrap(InnerTypesMap:Map) => mapUnion(BaseClassMap, InnerTypesMap),
        noValue
      )
      ...
    </k>
    <classType> BaseClass </classType>
    <imports> BaseClassMap:Map </imports>

rule [saveImportsDiscardNoClass]:
    saveImports(_,_, ((noClass => .KList),, _), _,_,_)

//Compute the imports map for the ClassType computed at part 1
//when this class is a top-level class
rule [saveImportsComputeImportsTop]:
    <k>
      saveImports(Class:ClassType, noClass, .KList, _, mapWrap(InnerTypesMap:Map),
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
      saveImports(_, OuterClass:ClassType, .KList, _, mapWrap(InnerTypesMap:Map),
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

rule [TypeNameInProcessClassDecsPhaseTop]:
    <k> 'TypeName(X:Id) => Class ...</k>
    <localTypes> ListItem(stEnv(LocalTypes:Map)) ...</localTypes>
    <crntClass> CuClass:ClassType </crntClass>
    <classType> CuClass </classType>
    <preprocessingPhase> CreatedCPP </preprocessingPhase>
    <enclosingClass> noClass </enclosingClass>
    <cuImports>... X |-> Class:ClassType ...</cuImports>
when
    notBool X in keys(LocalTypes)

rule [TypeNameInProcessClassDecsPhaseTopFail]:
    <k> 'TypeName(X:Id) => noValue ...</k>
    <localTypes> ListItem(stEnv(LocalTypes:Map)) ...</localTypes>
    <crntClass> CuClass:ClassType </crntClass>
    <classType> CuClass </classType>
    <preprocessingPhase> CreatedCPP </preprocessingPhase>
    <enclosingClass> noClass </enclosingClass>
    <cuImports> Imp:Map </cuImports>
when
    notBool X in keys(LocalTypes) andBool notBool X in keys(Imp)

rule [TypeNameInProcessClassDecsPhaseInner]:
    <k> 'TypeName(X:Id) => Class ...</k>
    <localTypes> ListItem(stEnv(LocalTypes:Map)) ...</localTypes>
    <crntClass> CuClass:ClassType </crntClass>
    <class>
      <classType> CuClass </classType>
      <preprocessingPhase> CreatedCPP </preprocessingPhase>
      <enclosingClass> class Outer </enclosingClass>
      ...
    </class>
    <class>
      <classType> class Outer </classType>
      <imports>... X |-> Class:ClassType ...</imports>
      ...
    </class>
when
    notBool X in keys(LocalTypes)

rule [TypeNameInProcessClassDecsPhaseInnerFail]:
    <k> 'TypeName(X:Id) => noValue ...</k>
    <localTypes> ListItem(stEnv(LocalTypes:Map)) ...</localTypes>
    <crntClass> CuClass:ClassType </crntClass>
    <class>
      <classType> CuClass </classType>
      <preprocessingPhase> CreatedCPP </preprocessingPhase>
      <enclosingClass> class Outer </enclosingClass>
      ...
    </class>
    <class>
      <classType> class Outer </classType>
      <imports> Imp:Map </imports>
      ...
    </class>
when
    notBool X in keys(LocalTypes) andBool notBool X in keys(Imp)

endmodule
