require "core.k"
require "process-type-names.k"

//@ \section{Module PROCESS-CLASS-DECS}

module PROCESS-CLASS-DECS
    imports CORE
    imports PROCESS-TYPE-NAMES

/*@ \subsection{Third pass - processing class dependencies and imports} */

//Processes all classes from CreatedCPhase to DecsProcessedCPhase.
syntax K ::= "processClassDecs" "(" K //setWrap(Set) - the set of all classes
                                ")"  [strict]

rule [StartProcClassDecsPhase]:
    <k> . => processClassDecs(getTopLevelClasses) </k>
     <globalPhase> ProcCompUnitsPhase => ProcClassDecsPhase  </globalPhase>

/* Question: how do we know if bases were already resolved for this class or not?
  Answer: When resolveBases(Class) is consumed by the rule [resolveBasesEnd], the class
  changes its state: CreatedCPhase => BasesResolvedCPhase
*/
rule [resolveBasesTopLevelStart]:
    <k> (. => resolveBases(Class, RawExtends, RawImplements)) ~> processClassDecs(_) ...</k>
    <classType> Class:ClassType </classType>
    <rawExtends> RawExtends:K </rawExtends>
    <rawImplements> 'ListWrap(RawImplements:KList) </rawImplements>
    <enclosingClass> noClass </enclosingClass>
    <cuImports> CuImports:Map </cuImports>
    <classPhase> CreatedCPhase </classPhase>
    <crntClass> _ => noClass </crntClass>
    <compUnitImports> _ => CuImports </compUnitImports>

rule [resolveBasesInnerStart]:
    <k> (. => resolveBases(Class, RawExtends, RawImplements)) ~> processClassDecs(_) ...</k>
    <class>
      <classType> Class:ClassType </classType>
      <rawExtends> RawExtends:K </rawExtends>
      <rawImplements> 'ListWrap(RawImplements:KList) </rawImplements>
      <enclosingClass> OuterClass:ClassType </enclosingClass>
      <classPhase> CreatedCPhase </classPhase>
      ...
    </class>
    <class>
      <classType> OuterClass </classType>
      <classPhase> OuterClassPhase:ClassPhase </classPhase>
      ...
    </class>
    <crntClass> _ => OuterClass </crntClass>
    <compUnitImports> _ => .Map </compUnitImports>
when
    OuterClassPhase ==K DecsProcessedCPhase orBool OuterClassPhase ==K MembersProcessedCPhase

//Process the given class from CreatedCPhase to BasesResolvedCPhase.
syntax K ::= "resolveBases" "(" ClassType //The class for which we resolve bases
                            "," K         //Base class
                            "," KList     //Implements clauses
                            ")"

context resolveBases(_, HOLE, _)      //Heat extends declaration
context resolveBases(_,_, _,,HOLE,,_) //Heat implements declarations

rule [resolveBases]:
    <k> resolveBases(Class:ClassType, BaseClass:ClassType, ImplTypes:KList) => . ...</k>
    <classType> Class </classType>
    <rawExtends> _ => BaseClass </rawExtends>
    <rawImplements> _ => 'ListWrap(ImplTypes) </rawImplements>
    <unprocessedBases> .K => 'ListWrap(BaseClass,,ImplTypes) </unprocessedBases>
    <classPhase> CreatedCPhase => BasesResolvedCPhase </classPhase>
when isKResult(ImplTypes)

rule [markBaseProcessed]:
    <k> processClassDecs(_) ...</k>
    <class>
      <unprocessedBases> 'ListWrap((BaseClass:ClassType => .KList) ,,_) </unprocessedBases>
      ...
    </class>
    <class>
      <classType> BaseClass </classType>
      <classPhase> BaseClassPhase:ClassPhase </classPhase>
      ...
    </class>
when
    BaseClassPhase ==K DecsProcessedCPhase orBool BaseClassPhase ==K MembersProcessedCPhase

//this one is for class Object
rule [markNoClassProcessed]:
    <k> processClassDecs(_) ...</k>
    <unprocessedBases> 'ListWrap((noClass => .KList) ,,_) </unprocessedBases>

rule [processClassDecEnd]:
    <k>
      processClassDecs(setWrap( SetItem(Class:ClassType) RestClasses:Set ))
      =>   saveImplements(Class, kListToSet(ImplTypes, .Set))
        ~> saveImports(Class, OuterClass, (BaseClass,,ImplTypes), noValue, mapWrap(.Map), noValue)
        ~> processClassDecs(setUnion(setWrap(RestClasses), getInnerClasses(Class)))
      ...
    </k>
    <classType> Class </classType>
    <enclosingClass> OuterClass:ClassType </enclosingClass>
    <rawDeclarations> CBody:K </rawDeclarations>
    <metaType> MetaT:MetaType </metaType>
    <classPhase> BasesResolvedCPhase => DecsProcessedCPhase </classPhase>
    <extends> .K => BaseClass </extends>
    ( <rawExtends> BaseClass:ClassType </rawExtends>
      <rawImplements> 'ListWrap(ImplTypes:KList) </rawImplements> => .Bag)
    ( <unprocessedBases> 'ListWrap(.KList) </unprocessedBases> => .Bag)

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
                            "," KList     //The list of base classes
                            "," K         //mapWrap(outer classes), to be computed
                            "," K         //mapWrap(inherited classes), to be computed. Starts with mapWrap(.Map)
                            "," K         //the result map, to be computed
                            ")"   [strict(4,5,6)]

//todo K 10341 it looks like [strict] above don't work
context saveImports(_,_,_,HOLE,_,_)
context saveImports(_,_,_,_,HOLE,_)
context saveImports(_,_,_,_,_,HOLE)

//Compute outer classes if this class is a top-level class
rule [saveImportsComputeExternalTop]:
    <k>
      saveImports(Class:ClassType, noClass, _,
        noValue => mapWrap(ExternalMap),
      _,_)
      ...
    </k>
    <classType> Class </classType>
    <cuImports> ExternalMap:Map </cuImports>

//Compute outer classes if this class is an inner class.
rule [saveImportsComputeExternalInner]:
    <k>
      saveImports(_, OuterClass:ClassType, _,
        noValue => mapWrap(ExternalMap),
      _,_)
      ...
    </k>
    <classType> OuterClass </classType>
    <imports> ExternalMap:Map </imports>

//Second add names inherited from each base type, but don't override inner classes
rule [saveImportsInheritTypes]:
    <k>
      saveImports(_,_, ((BaseClass:ClassType => .KList),, _), _,
        mapWrap(InheritedMap:Map) => mapUnion(mapWrap(InheritedMap), mapWrap(BaseClassMap)),
        _
      )
      ...
    </k>
    <classType> BaseClass </classType>
    <imports> BaseClassMap:Map </imports>

rule [saveImportsDiscardNoClass]:
    saveImports(_,_, ((noClass => .KList),, _), _,_,_)

/*Compute the final result - the combined accessible classes map, with this components in order:
  - external names
  - local block names (for local classes only)
  - inherited names
  - inner names
*/
rule [saveImportsComputeResult]:
    <k>
      saveImports(Class:ClassType,_, .KList, mapWrap(ExternalMap:Map), mapWrap(InheritedMap:Map),
        noValue => mapUnion(
          mapUnion(
            mapWrap(ExternalMap),
            mapWrap(LocalTypes)),
          mapUnion(
            mapWrap(InheritedMap),
            getNamesMap(toPackage(Class)))
        )
      )
      ...
    </k>
    <localTypes> ListItem(stEnv(LocalTypes:Map)) ...</localTypes>
    <classType> BaseClass:ClassType </classType>
    <imports> BaseClassMap:Map </imports>

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
