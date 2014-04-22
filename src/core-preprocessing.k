require "core-sorts.k"
require "core-functions.k"

//@ \section{Module CORE-PREPROCESSING}
/*@ Auxiliary functions related to preprocessing phases only.
*/

module CORE-PREPROCESSING
    imports CORE-SORTS
    imports CORE-FUNCTIONS

//@ \subsection{Auxiliary constructs for retrieving a set of classes}

/*@ Returns a setWrap(Set[ClassType]), containing all top level classes in the program.
    Uses <namesToClasses> to compute the result. Used by the starting rule of several preprocessing phases.
*/
syntax K ::= "getTopLevelClasses"
           | getTopLevelClasses ( Map, Set )

rule [getTopLevelClasses-start]:
    <k> getTopLevelClasses => getTopLevelClasses(NamesMap, .Set) ...</k>
    <namesToClasses> NamesMap:Map </namesToClasses>

rule [getTopLevelClasses-top-level]:
    <k>
      getTopLevelClasses(_ _ |-> mapWrap(_ (_ |-> Class:ClassType => .Map)), _ (.Set => SetItem(Class)))
      ...
    </k>
    <classType> Class </classType>
    <enclosingClass> noClass </enclosingClass>

rule [getTopLevelClasses-not-top-level]:
    <k>
      getTopLevelClasses(_ _ |-> mapWrap(_ (_ |-> Class:ClassType => .Map)), _)
      ...
    </k>
    <classType> Class </classType>
    <enclosingClass> class _ </enclosingClass>

rule getTopLevelClasses(_ (_ |-> mapWrap(.Map) => .Map), _)
rule getTopLevelClasses(.Map, ClassesSet:Set) => setWrap(ClassesSet)

/*@ Returns a setWrap(Set[ClassType]), containing all direct inner classes of the given class.
    Uses <namesToClasses> to compute the result.
*/
syntax K ::= getInnerClasses ( ClassType )
           | getInnerClasses ( Map, Set )

rule [getInnerClasses-start-have-inner]:
    <k> getInnerClasses(Class:ClassType) => getInnerClasses(InnerClassesMap, .Set) ...</k>
    <namesToClasses>... Pack:PackageId |-> mapWrap(InnerClassesMap:Map) ...</namesToClasses>
when
    Pack ==K toPackage(Class)

rule getInnerClasses( (_ |-> Class:ClassType => .Map) _, (.Set => SetItem(Class)) _)
rule getInnerClasses(.Map, ClassesSet:Set) => setWrap(ClassesSet)

rule [getInnerClasses-no-inners]:
    <k> getInnerClasses(Class:ClassType) => setWrap(.Set) ...</k>
    <namesToClasses> TypeNamesMap:Map </namesToClasses>
when
    notBool toPackage(Class) in keys(TypeNamesMap)

endmodule
