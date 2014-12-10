/*@ \section{Module CORE-CLASSES}
    Auxiliary functions related to classes and packages.
*/

module CORE-CLASSES
    imports CORE-SORTS
    imports CORE-FUNCTIONS
    imports AUX-STRINGS // for retainHead
    imports EXP-SYNTAX //for definitions of sort Exp
    imports STMT-SYNTAX //for definitions of sort Exp

//@ \subsection{Shortcuts for the most frequently used classes within the semantics}

syntax KItem ::= "classObject"
    [function, latex(\terminal{Object})]
rule classObject => class String2Id("java.lang.Object")

syntax KItem ::= "classString"
    [function, latex(\terminal{String})]
rule classString => class String2Id("java.lang.String")

syntax KItem ::= "classNullPointerException"
    [function, latex(\terminal{NullPointerException})]
rule classNullPointerException => class String2Id("java.lang.NullPointerException")

syntax KItem ::= "classArrayImpl"                   [function]
rule classArrayImpl => class String2Id("java.lang.ArrayImpl")

//@ \subsection{Packages}

/*@A Java package.*/
syntax PackageId ::= packageId ( Id )
syntax KResult ::= PackageId

/*@ Converts a term of type ClassType into a term of type PackageId representing this class.
    This is the package for this class' inner classes.
*/
syntax KItem ::= toPackage  ( ClassType )       [function]
rule toPackage(class Class:Id) => packageId(Class)

/*@Returns the package of the given class*/
syntax KItem ::= getPackage ( K )               [strict]
rule getPackage(class ClassId:Id)
    => packageId( String2Id(retainHead(
      Id2String(ClassId),
      rfindString(Id2String(ClassId), ".", lengthString(Id2String(ClassId)))
    )) )

//@ \subsection{Classes}

//@ Converts a pair of PackagId, Id into a fully qualified class name
syntax ClassType ::= getClassType (
                      PackageId,  // the Package Id
                      Id          // Simple class name
                     )
                     [function]

rule getClassType(packageId(PackKId:Id), SimpleClass:Id)
     => class String2Id(Id2String(PackKId) +String "." +String Id2String(SimpleClass))

/*@Returns the top-level class enclosing this class*/
syntax KItem ::= getTopLevel ( ClassType )

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

//@ Restore the content of <crntClass> with the given class
syntax KItem ::=  restoreCrntClass (
                ClassType //old content of <crntClass>
              )

rule [restoreAfterProcessLocalClass]:
    <k> restoreCrntClass(Class:ClassType) => . ...</k>
    <crntClass> _ => Class </crntClass>

//@ Get the internal constructor name for a given class
syntax KItem ::= getConsName ( ClassType )                               [function]
rule getConsName(class ClassId:Id) => String2Id("$cons$" +String Id2String(ClassId))

//@ \subsection{Expressions and their subsorts}

syntax Exp ::= "dummyExp"

syntax Exp ::= NonNumericExp
syntax NonNumericExp ::= "dummyNonNumericExp"

rule isNonNumericExp('ArrayAccess(_)) => true
rule isNonNumericExp('NewInstance(_)) => true    // also in customElabChildren
rule isNonNumericExp('QNewInstance(_)) => true   // also in customElabChildren
rule isNonNumericExp('InstanceOf(_)) => true
//rule isMethodInvokeExp('Invoke(_)) => true
rule isNonNumericExp('Invoke(_)) => true
rule isNonNumericExp('This(_)) => true
rule isNonNumericExp('QThis(_)) => true
rule isNonNumericExp('AmbName(_)) => true
rule isNonNumericExp('ExprName(_)) => true
//rule isMethodInvokeExp('Field(_)) => true
rule isNonNumericExp('Field(_)) => true
rule isNonNumericExp('SuperField(_)) => true
rule isNonNumericExp('QSuperField(_)) => true
rule isNonNumericExp('NewArray(_)) => true
rule isNonNumericExp('CastPrim(_)) => true
rule isNonNumericExp('CastRef(_)) => true


//@ Since RawVal terms can easily be converted into TypedVal, they are also of sort Exp.
syntax Exp ::= TypedVal | RawVal

//@ \subsubsection{Computation terms produced during elaboration}

/*@ These auxiliary terms functions that should be threated as expressions in the elaboration phase.
*/
syntax Exp ::= AuxTermExp

/*@ Wrapper of a statement followed by an expression, to be used in a place where an expression is expected,
such as an anonymous class declaration. Is typed with the type of the expression.
At runtime is rewritten into the statement, that should evaluate into .K, followed by the expression,
that should evaluate to value.*/
syntax AuxTermExp ::= stmtAndExp ( K, K )

syntax AuxTermExp ::= cast ( Type, K ) [strict] //strictness on 1-st arcument - for runtime produced terms

endmodule
