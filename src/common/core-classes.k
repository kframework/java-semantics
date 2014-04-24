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

/*@ Tests if a method within BaseClass with BaseAccessMode is overwritten by a method with the same signature
    in SubClass with SubAccessMode.
    It is also possible that BaseClass and SubClass are the same, since the same method is inherited by many classes,
    and gets in their <methods> cell.
*/
syntax K ::=  isAccessibleForOverwriting (
                ClassType,  //BaseClass
                AccessMode, //BaseAccessMode
                ClassType   //SubClass
              )
              [strict]

rule isAccessibleForOverwriting(_, public,    _) => true
rule isAccessibleForOverwriting(_, protected, _) => true

//@ Object class cannot match this rule since it has public access mode
rule isAccessibleForOverwriting(BaseClass:ClassType, package, SubClass:ClassType)
    => eqAux(getPackage(getTopLevel(BaseClass)), getPackage(getTopLevel(SubClass)))

rule isAccessibleForOverwriting(_, private, _) => false

//@ Retrieve the content of <methods> for the given class
syntax K ::=  getMethods ( ClassType )
rule [getMethods-ClassType]:
    <k> getMethods(Class:ClassType) => mapWrap(Methods) ...</k>
    <classType> Class </classType>
    <methods> Methods:Map </methods>

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

//@ \subsection{Computation terms produced during elaboration}

//todo analize what of those could be eliminated

/*@ Wrapper of a statement followed by an expression, to be used in a place where an expression is expected,
such as an anonymous class declaration. Is typed with the type of the expression.
At runtime is rewritten into the statement, that should evaluate into .K, followed by the expression,
that should evaluate to value.*/
syntax K ::= stmtAndExp ( K, K )

syntax Cast ::= cast ( Type, K ) [strict] //strictness on 1-st arcument - for runtime produced terms

endmodule
