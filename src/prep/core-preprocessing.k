/*@ \section{Module CORE-PREPROCESSING}
    Auxiliary functions related to preprocessing phases only.
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

//@ Returns the access mode of a method closure given as argument
syntax K ::= getMethodAccessMode ( MethodRef )   [strict]
rule [getMethodAccessMode]:
    <k>
      getMethodAccessMode( methodRef(Sig:Signature, Class:ClassType) ) => Acc
      ...
    </k>
    <classType> Class </classType>
    <methodSignature> Sig </methodSignature>
    <methodAccessMode> Acc:AccessMode </methodAccessMode>

syntax K ::=  getContextType (
                KListWrap       //[...] - the list of method attributes
              )
              [function]

rule getContextType(['Static(_),,_]) => staticCT

rule getContextType([(KL:KLabel(_) => .KList),, _])
when        KL =/=KLabel 'Static

rule getContextType([.KList])      => instanceCT

/*@Extracts the access mode from the list of modifiers of some Java entity.*/
syntax K ::=  getAccessMode (
                KListWrap //[...] - the list of class/method attributes
              )
              [function]

rule getAccessMode(['Public(_),,_])    => public
rule getAccessMode(['Protected(_),,_]) => protected
rule getAccessMode(['Private(_),,_])   => private

rule getAccessMode([(KL:KLabel(_) => .KList),, _])
when        (KL =/=KLabel 'Public)
    andBool (KL =/=KLabel 'Protected)
    andBool (KL =/=KLabel 'Private)

rule getAccessMode([.KList]) => package

endmodule
