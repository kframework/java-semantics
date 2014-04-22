require "core-sorts.k"
require "core-functions.k"

//@ \section{Module CORE-CLASSES}
/*@ Auxiliary functions related to classes and packages.
*/

module CORE-CLASSES
    imports CORE-SORTS
    imports CORE-FUNCTIONS

//@ \subsection{Shortcuts for the most frequently used classes within the semantics}

syntax K ::= "objectClass"                              [function]
rule objectClass => class String2Id("java.lang.Object")

syntax K ::= "stringClass"                              [function]
rule stringClass => class String2Id("java.lang.String")

//@ \subsection{Packages}

/*@A Java package.*/
syntax PackageId ::= packageId ( Id )
syntax KResult ::= PackageId

/*@ Converts a term of type ClassType into a term of type PackageId representing this class.
    This is the package for this class' inner classes.
*/
syntax K ::= toPackage  ( ClassType )       [function]
rule toPackage(class Class:Id) => packageId(Class)

/*@Returns the package of the given class*/
syntax K ::= getPackage ( K )               [strict]
rule getPackage(class ClassId:Id)
    => String2Id(retainHead(
      Id2String(ClassId),
      rfindString(Id2String(ClassId), ".", lengthString(Id2String(ClassId)))
    ))

/*@Returns the top-level class enclosing this class*/
syntax K ::= getTopLevel ( ClassType )

rule [getTopLevel-move-up]:
    <k>
      getTopLevel(Class:ClassType) => getTopLevel(EnclosingClass)
      ...
    </k>
    <classType> Class </classType>
    <enclosingClass> EnclosingClass:ClassType </enclosingClass>
when EnclosingClass =/=K noClass

rule [getTopLevel]:
    <k>
      getTopLevel(Class:ClassType) => Class
      ...
    </k>
    <classType> Class </classType>
    <enclosingClass> noClass </enclosingClass>

syntax KLabel ::=   "'Public"
                  | "'Private"
                  | "'Protected"
                  | "'Abstract"
                  | "'Final"
                  | "'Static"
                  | "'Native"
                  | "'Transient"
                  | "'Volatile"
                  | "'StrictFP"

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

//@ Restore the content of <crntClass> with the given class
syntax K ::=  restoreCrntClass (
                ClassType //old content of <crntClass>
              )

rule [restoreAfterProcessLocalClass]:
    <k> restoreCrntClass(Class:ClassType) => . ...</k>
    <crntClass> _ => Class </crntClass>

//@ \subsection{Auxiliary constructs related to methods}

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

//@ Returns the context type of a method closure given as argument
syntax K ::= getMethodContextType ( MethodRef )  [strict]
rule [getMethodContextType]:
    <k>
      getMethodContextType( methodRef(Sig:Signature, Class:ClassType) ) => CT
      ...
    </k>
    <classType> Class </classType>
    <methodSignature> Sig </methodSignature>
    <methodContextType> CT:ContextType </methodContextType>

syntax K ::= getLookupTargetType ( RefType )    [function]
rule getLookupTargetType(Class:ClassType) => Class
rule getLookupTargetType(arrayOf _) => arrayImplClass

syntax K ::= "arrayImplClass"                   [function]
rule arrayImplClass => class String2Id("java.lang.ArrayImpl")

//@ \subsection{Preprocessing auxiliary functions}

syntax K ::=  getContextType (
                KListWrap       //[...] - the list of method attributes
              )
              [function]

rule getContextType(['Static(_),,_]) => staticCT

rule getContextType([(KL:KLabel(_) => .KList),, _])
when        KL =/=KLabel 'Static

rule getContextType([.KList])      => instanceCT

//@ Get the internal constructor name for a given class
syntax K ::= getConsName ( ClassType )                               [function]
rule getConsName(class ClassId:Id) => String2Id("$cons$" +String Id2String(ClassId))

//@ \subsection{Elaboration auxiliary functions}

syntax K ::= isPrefixPostfixExpLabel ( KLabel )  [function]
rule isPrefixPostfixExpLabel('PreIncr) => true
rule isPrefixPostfixExpLabel('PreDecr) => true
rule isPrefixPostfixExpLabel('PostIncr) => true
rule isPrefixPostfixExpLabel('PostDecr) => true

//@ \subsection{Computation terms produced during elaboration}

/*@ Wrapper of a statement followed by an expression, to be used in a place where an expression is expected,
such as an anonymous class declaration. Is typed with the type of the expression.
At runtime is rewritten into the statement, that should evaluate into .K, followed by the expression,
that should evaluate to value.*/
syntax K ::= stmtAndExp ( K, K )

endmodule
