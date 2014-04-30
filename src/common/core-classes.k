require "core-sorts.k"
require "core-functions.k"
require "aux-strings.k"

//@ \section{Module CORE-CLASSES}
/*@ Auxiliary functions related to classes and packages.
*/

module CORE-CLASSES
    imports CORE-SORTS
    imports CORE-FUNCTIONS
    imports AUX-STRINGS // for retainHead

//@ \subsection{Shortcuts for the most frequently used classes within the semantics}

syntax K ::= "objectClass"                              [function]
rule objectClass => class String2Id("java.lang.Object")

syntax K ::= "stringClass"                              [function]
rule stringClass => class String2Id("java.lang.String")

syntax K ::= "arrayImplClass"                   [function]
rule arrayImplClass => class String2Id("java.lang.ArrayImpl")

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

//@ \subsection{Classes}

//@ Converts a pair of PackagId, Id into a fully qualified class name
syntax K ::=  getClassType (
                PackageId, // the Package Id
                Id        // Simple class name
              )
              [function]

rule getClassType(packageId(PackKId:Id), SimpleClass:Id)
     => class String2Id(Id2String(PackKId) +String "." +String Id2String(SimpleClass))

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

//@ Restore the content of <crntClass> with the given class
syntax K ::=  restoreCrntClass (
                ClassType //old content of <crntClass>
              )

rule [restoreAfterProcessLocalClass]:
    <k> restoreCrntClass(Class:ClassType) => . ...</k>
    <crntClass> _ => Class </crntClass>

//@ Get the internal constructor name for a given class
syntax K ::= getConsName ( ClassType )                               [function]
rule getConsName(class ClassId:Id) => String2Id("$cons$" +String Id2String(ClassId))

//@ \subsection{Elaboration auxiliary functions}

syntax K ::= isPrefixPostfixExpLabel ( KLabel )  [function]
rule isPrefixPostfixExpLabel('PreIncr) => true
rule isPrefixPostfixExpLabel('PreDecr) => true
rule isPrefixPostfixExpLabel('PostIncr) => true
rule isPrefixPostfixExpLabel('PostDecr) => true

//@ Assign***:KLabel(LHS,, RHS)
syntax KLabel ::= "'AssignMul"
                | "'AssignDiv"
                | "'AssignRemain"
                | "'AssignPlus"
                | "'AssignMinus"
                | "'AssignLeftShift"
                | "'AssignRightShift"
                | "'AssignURightShift"
                | "'AssignAnd"
                | "'AssignExcOr"
                | "'AssignOr"

syntax K ::= isCompoundAssignLabel ( KLabel )    [function]
rule isCompoundAssignLabel('AssignPlus) => true
rule isCompoundAssignLabel('AssignMinus) => true
rule isCompoundAssignLabel('AssignMul) => true
rule isCompoundAssignLabel('AssignDiv) => true
rule isCompoundAssignLabel('AssignAnd) => true
rule isCompoundAssignLabel('AssignOr) => true
rule isCompoundAssignLabel('AssignExcOr) => true
rule isCompoundAssignLabel('AssignRemain) => true
rule isCompoundAssignLabel('AssignLeftShift) => true
rule isCompoundAssignLabel('AssignRightShift) => true
rule isCompoundAssignLabel('AssignURightShift) => true

/*@ [skip] Tests if a method declared in class BaseC with access mode Acc is overridden by a method with the same
  signature declared in a subclass SubC.

The method is overridden if either:
  - Acc is protected or public
  - Acc is package and BaseC and SubC are declared in the same package (JLS \$6.6)
*/
syntax K ::=  isOverridden (
                ClassType,  //BaseC
                AccessMode, //BaseAcc
                ClassType   //SubC
              )
              [strict]

rule isOverridden(_, public,    _) => true
rule isOverridden(_, protected, _) => true

//@ Object class cannot match this rule since it has public access mode
rule isOverridden(BaseC:ClassType, package, SubC:ClassType)
    => eqAux(getPackage(getTopLevel(BaseC)), getPackage(getTopLevel(SubC)))

rule isOverridden(_, private, _) => false

//@ \subsection{Computation terms produced during elaboration}

/*@ Wrapper of a statement followed by an expression, to be used in a place where an expression is expected,
such as an anonymous class declaration. Is typed with the type of the expression.
At runtime is rewritten into the statement, that should evaluate into .K, followed by the expression,
that should evaluate to value.*/
syntax K ::= stmtAndExp ( K, K )

syntax Cast ::= cast ( Type, K ) [strict] //strictness on 1-st arcument - for runtime produced terms

endmodule
