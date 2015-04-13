module CORE-CLASSES
    imports CORE-SORTS
    imports CORE-FUNCTIONS
    imports AUX-STRINGS // for retainHead
    imports EXP-SYNTAX //for definitions of sort Exp
    imports STMT-SYNTAX //for definitions of sort Stmt

//@ \subsection{Packages}

/*@A Java package.*/
syntax PackageId ::= packageId ( Id )
syntax MKR ::= PackageId

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


//@ Since RawVal terms can easily be converted into TypedVal, they are also of sort Exp.
syntax Exp ::= TypedVal | RawVal





endmodule
