/*@ \section{Module CORE-CLASSES}
    Auxiliary functions related to classes and packages.
*/

module CORE-CLASSES
    imports CORE-SORTS
    imports CORE-FUNCTIONS
    imports AUX-STRINGS // for retainHead

//@ \subsection{Shortcuts for the most frequently used classes within the semantics}

syntax K ::= "objectClass"                              [function]
rule objectClass => class String2Id("java.lang.Object")

syntax K ::= "stringClass"
    [function, latex(\terminal{String})]
rule stringClass => class String2Id("java.lang.String")

syntax K ::= "nullPEClass"
    [function, latex(\terminal{NullPointerException})]
rule nullPEClass => class String2Id("java.lang.NullPointerException")

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
    => packageId( String2Id(retainHead(
      Id2String(ClassId),
      rfindString(Id2String(ClassId), ".", lengthString(Id2String(ClassId)))
    )) )

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

//@ \subsection{Expressions and their subsorts}

syntax Exp ::= "dummyExp"

    //Infix operators
rule isExp('LazyOr(_)) => true       /* ||  */
rule isExp('LazyAnd(_)) => true      /* &&  */
rule isExp('Or(_)) => true           /* |   */
rule isExp('ExcOr(_)) => true        /* ^   */
rule isExp('And(_)) => true          /* &   */
rule isExp('Eq(_)) => true           /* ==  */
rule isExp('NotEq(_)) => true        /* !=  */
rule isExp('Lt(_)) => true           /* <   */
rule isExp('Gt(_)) => true           /* >   */
rule isExp('LtEq(_)) => true         /* <=  */
rule isExp('GtEq(_)) => true         /* >=  */
rule isExp('LeftShift(_)) => true    /* <<  */
rule isExp('RightShift(_)) => true   /* >>  */
rule isExp('URightShift(_)) => true  /* >>> */
rule isExp('Plus(_)) => true         /* +   */
rule isExp('Minus(_)) => true        /* -   */
rule isExp('Mul(_)) => true          /* *   */
rule isExp('Div(_)) => true          /* /   */
rule isExp('Remain(_)) => true       /* %   */

    //Prefix operators
rule isExp('Not(_)) => true          /* !   */
rule isExp('Complement(_)) => true   /* ~   */
    /* +   */ //'Plus   - defined earlier
    /* -   */ //'Minus  - defined earlier

    //Ternary operators
rule isExp('Cond(_)) => true         /* ? : */

rule isExp('Assign(_)) => true       /* =   */

syntax Exp ::= NonNumericExp
syntax NonNumericExp ::= "dummyNonNumericExp"

rule isNonNumericExp('ArrayAccess(_)) => true
rule isNonNumericExp('NewInstance(_)) => true    // also in customElabChildren
rule isNonNumericExp('QNewInstance(_)) => true   // also in customElabChildren
rule isNonNumericExp('InstanceOf(_)) => true
rule isNonNumericExp('Invoke(_)) => true
rule isNonNumericExp('This(_)) => true
rule isNonNumericExp('QThis(_)) => true
rule isNonNumericExp('AmbName(_)) => true
rule isNonNumericExp('ExprName(_)) => true
rule isNonNumericExp('Field(_)) => true
rule isNonNumericExp('SuperField(_)) => true
rule isNonNumericExp('QSuperField(_)) => true
rule isNonNumericExp('NewArray(_)) => true
rule isNonNumericExp('CastPrim(_)) => true
rule isNonNumericExp('CastRef(_)) => true

//@ Operators with side effects - prefix, postfix ++/--
syntax Exp ::= PrefixPostfixExp
syntax PrefixPostfixExp ::= "dummyPrefixPostfixExp"

rule isPrefixPostfixExp('PreIncr(_)) => true    /* ++  */
rule isPrefixPostfixExp('PreDecr(_)) => true    /* --  */
rule isPrefixPostfixExp('PostIncr(_)) => true   /* ++  */
rule isPrefixPostfixExp('PostDecr(_)) => true   /* --  */

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

syntax Exp ::= CompoundAssignExp
syntax CompoundAssignExp ::= "dummyCompoundAssignExp"

rule isCompoundAssignExp('AssignPlus(_)) => true
rule isCompoundAssignExp('AssignMinus(_)) => true
rule isCompoundAssignExp('AssignMul(_)) => true
rule isCompoundAssignExp('AssignDiv(_)) => true
rule isCompoundAssignExp('AssignAnd(_)) => true
rule isCompoundAssignExp('AssignOr(_)) => true
rule isCompoundAssignExp('AssignExcOr(_)) => true
rule isCompoundAssignExp('AssignRemain(_)) => true
rule isCompoundAssignExp('AssignLeftShift(_)) => true
rule isCompoundAssignExp('AssignRightShift(_)) => true
rule isCompoundAssignExp('AssignURightShift(_)) => true

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
