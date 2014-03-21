require "core-sorts.k"
require "core-classes.k"
require "process-type-names.k"
require "subtyping.k"
require "var-lookup.k"
require "elaboration-core.k"
require "elaboration-method-invoke.k"

module ELABORATION-EXPRESSIONS
    imports CORE-SORTS
    imports CORE-CLASSES
    imports PROCESS-TYPE-NAMES     //for toPackage()
    imports SUBTYPING
    imports VAR-LOOKUP             //for lookupField, lookupStaticField
    imports ELABORATION-CORE
                                        //todo we should move all that depents on this to ELABORATION-METHOD-INVOKE
    imports ELABORATION-METHOD-INVOKE   // for lookupMethod

//@ Elaboration of rules in java-var-lookup

syntax KLabel ::= "'AmbName"

//@ Both unqualified and qualified AmbName.
rule [elabEnd-AmbName]:
    elabEnd('AmbName(Ks:KList)) => elabEnd('ExprName(Ks)) ?? 'TypeName(Ks) ?? 'PackageName('ListWrap(Ks))

rule [elabEnd-ExprName-localVar-ok]:
    <k> elabEnd('ExprName(X:Id)) => elabRes(cast(T, 'ExprName(X))) ...</k>
    <elabEnv> ListItem(mapWrap(X |-> T:Type _)) ...</elabEnv>

rule [elabEnd-localVar-to-noValue]:
    <k> elabEnd('ExprName(X:Id)) => externalVar(X, Class) ...</k>
    <elabEnv> ListItem(mapWrap(ElabEnv:Map)) ...</elabEnv>
    <crntClass> Class:ClassType </crntClass>
when notBool (X in keys(ElabEnv))

//@ This could be either a field, or a local var of some enclosing block.
syntax K ::=  externalVar (
                Id,       //X - var name
                ClassType //Class - innermost class where the name should be searched
              )

rule [externalVar]:
    <k>
      externalVar(X:Id, Class:ClassType)
      => elabEnd('Field( cast(Class, 'QThis(Class)),, X ))
          ?? elabOuterLocalVar(X, Class) ?? externalVar(X, EnclosingClass)
      ...
    </k>
    <classType> Class </classType>
    <enclosingClass> EnclosingClass:ClassType </enclosingClass>

rule [externalVar-noClass]:
    externalVar(_, noClass) => noValue

//@Attempts to resolve this expression into a local var from the enclosing local environment
//@of type being precisely the given class.
syntax K ::=  elabOuterLocalVar (
                Id,       //X - var name
                ClassType //Class - the class where the name should be searched
              )

rule [elabOuterLocalVar-ok]:
    <k>
      elabOuterLocalVar(X:Id, Class:ClassType) => elabRes(cast(T, 'ExprName(X)))
      ...
    </k>
    <classType> Class </classType>
    <enclosingLocalEnv>... X |-> T:Type ...</enclosingLocalEnv>

rule [elabOuterLocalVar-not-found]:
    <k>
      elabOuterLocalVar(X:Id, Class:ClassType) => noValue
      ...
    </k>
    <classType> Class </classType>
    <enclosingLocalEnv> EnclosingLocalEnv:Map </enclosingLocalEnv>
when
    notBool X in keys(EnclosingLocalEnv)

rule [elabEnd-ExprName-qualified]:
    elabEnd('ExprName(QualK:K,,X:Id)) => elabEnd('Field(QualK,,X))

rule [elabEnd-Field-of-package]:
    elabEnd('Field( _:PackageId,, _:Id )) => noValue  [structural]

rule [elabEnd-Field-of-noValue]:
    elabEnd('Field( noValue,, _:Id )) => noValue      [structural]

//@Computation of instance and static environment of a class, e.g. set of fields

//@Searches the given field name in the given type (set of types), both static and instance context.
syntax K ::=  elabLookup (
                Id,       //The field to search
                ClassType //The current class under search
              )
            | elabLookup (
                Id, //The field to search
                Set //A set of interfaces under search
              )

rule [elabLookup-FoundInstance]:
    <k> elabLookup(X:Id, CT:ClassType) => FEntry ...</k>
    <classType> CT </classType>
    <instanceEnv>... X |-> FEntry:K ...</instanceEnv>

rule [elabLookup-FoundStatic]:
    <k> elabLookup(X:Id, CT:ClassType) => fieldEntry(CT,X,T, staticCT) ...</k>
    <classType> CT </classType>
    <staticEnv>... X |-> L:Int ...</staticEnv>
    <store>... L |-> _ :: T:Type  ...</store>

rule [elabLookup-FoundConstant]:
    <k> elabLookup(X:Id, CT:ClassType) => TV ...</k>
    <classType> CT </classType>
    <constantEnv>... X |-> TV:TypedVal ...</constantEnv>

/*@If X is not found in the current class, search for it first in base interfaces, then in the base class.
This order is necessary to avoid the case when base class have a private field X, and base
interfaces have a public one. In this case we should choose the field from the interface.
*/
rule [elabLookup-NextClass]:
    <k>
      elabLookup(X:Id, CT:ClassType) => elabLookup(X, BaseInterfaces) ?? elabLookup(X, BaseClass)
      ...
    </k>
    <classType> CT </classType>
    <extends> BaseClass:ClassType </extends>
    <implements> BaseInterfaces:Set </implements>
    <instanceEnv> InstanceEnv:Map </instanceEnv>
    <staticEnv> StaticEnv:Map </staticEnv>
    <constantEnv> ConstantEnv:Map </constantEnv>
when
    notBool ((X in keys(InstanceEnv)) orBool (X in keys(StaticEnv)) orBool (X in keys(ConstantEnv)))

rule [elabLookup-NotFound]:
    elabLookup(X:Id, noClass) => noValue

rule [elabLookup-Set]:
    elabLookup(X:Id, SetItem(Class:ClassType) Rest:Set)
    => elabLookup(X, Class) ?? elabLookup(X, Rest)

rule [elabLookup-Set-NotFound]:
    elabLookup(_, .Set) => noValue

syntax KLabel ::= "'This"

rule [elabEnd-This]:
    <k> elabEnd('This(.KList) => 'QThis(Class)) ...</k>
    <crntClass> Class:ClassType </crntClass>

rule [elabEnd-QThis-InstanceCT]:
    <k> elabEnd('QThis(Class:ClassType)) => elabRes(cast(Class, 'QThis(Class))) ...</k>
    <contextType> instanceCT </contextType>

rule [elabEnd-QThis-StaticCT]:
    <k> elabEnd('QThis(_)) => noValue ...</k>
    <contextType> staticCT </contextType>

syntax KLabel ::= "'Field"

rule [elabEnd-Field-QualRef]:
    elabEnd('Field(cast(Class:ClassType, Qual:K),, X:Id))
    => elabFieldImpl(cast(Class, Qual), X, elabLookup(X, Class))

rule [elabEnd-Field-QualClass]:
    elabEnd('Field(Class:ClassType,, X:Id))
    => elabFieldImpl(noValue, X, elabLookup(X, Class))

//@ 'SuperField(X:Id)
syntax KLabel ::= "'SuperField"

rule [elabEnd-SuperField]:
    <k>
      elabEnd('SuperField(X:Id) => 'QSuperField(Class,, X:Id))
      ...
    </k>
    <crntClass> Class:ClassType </crntClass>

//@ 'QSuperField(Class:ClassType,, X:Id)
syntax KLabel ::= "'QSuperField"

rule [elabEnd-QSuperField]:
    <k>
      elabEnd('QSuperField(Class:ClassType,, X:Id))
      => elabFieldImpl(cast(Class, 'QThis(Class)), X, elabLookup(X, BaseClass))
      ...
    </k>
    <classType> Class </classType>
    <extends> BaseClass:ClassType </extends>

//@Computed the Cast expression for a given expression and its type
syntax K ::=  elabFieldImpl (
                K,  // Field qualifier exp (noValue for fields qualified by a class)
                Id, // X - the field name
                K   //elabLookup(...), computes into fieldEntry(...) or noValue
              )
              [strict(3)]

rule elabFieldImpl(SourceExp:K, X:Id, fieldEntry(Class:ClassType,_,T:Type, instanceCT))
    => elabRes(cast(T, lookupField(SourceExp,Class,X)))

rule elabFieldImpl(_, X:Id, fieldEntry(Class:ClassType,_,T:Type, staticCT))
    => elabRes(cast(T, 'ExprName(Class,, X)))

//@for constant fields
rule elabFieldImpl(_,_, TV:TypedVal) => TV

rule elabFieldImpl(_,_, noValue) => noValue

/*@ \subsection{Elaboration of numeric expressions} */

/*@ Expression labels are not converted by the default rule in the phase elabDispose() => elabRes(...)
    Each expression needs a specialized rule for disposing, that will compute, among others,
    the type of the expression.
*/
syntax K ::= isExpressionLabel ( KLabel )     [function]

    //Infix operators
rule isExpressionLabel('LazyOr) => true       /* ||  */
rule isExpressionLabel('LazyAnd) => true      /* &&  */
rule isExpressionLabel('Or) => true           /* |   */
rule isExpressionLabel('ExcOr) => true        /* ^   */
rule isExpressionLabel('And) => true          /* &   */
rule isExpressionLabel('Eq) => true           /* ==  */
rule isExpressionLabel('NotEq) => true        /* !=  */
rule isExpressionLabel('Lt) => true           /* <   */
rule isExpressionLabel('Gt) => true           /* >   */
rule isExpressionLabel('LtEq) => true         /* <=  */
rule isExpressionLabel('GtEq) => true         /* >=  */
rule isExpressionLabel('LeftShift) => true    /* <<  */
rule isExpressionLabel('RightShift) => true   /* >>  */
rule isExpressionLabel('URightShift) => true  /* >>> */
rule isExpressionLabel('Plus) => true         /* +   */
rule isExpressionLabel('Minus) => true        /* -   */
rule isExpressionLabel('Mul) => true          /* *   */
rule isExpressionLabel('Div) => true          /* /   */
rule isExpressionLabel('Remain) => true       /* %   */

    //Prefix operators
rule isExpressionLabel('PreIncr) => true      /* ++  */
rule isExpressionLabel('PreDecr) => true      /* --  */
rule isExpressionLabel('Not) => true          /* !   */
rule isExpressionLabel('Complement) => true   /* ~   */
    /* +   */ //'Plus   - defined earlier
    /* -   */ //'Minus  - defined earlier

    //Postfix operators
rule isExpressionLabel('PostIncr) => true     /* ++  */
rule isExpressionLabel('PostDecr) => true     /* --  */

    //Ternary operators
rule isExpressionLabel('Cond) => true         /* ? : */
rule isExpressionLabel('Assign) => true       /* =   */

rule isExpressionLabel(KL:KLabel) => true
when
           isCompoundAssignLabel(KL) ==K true
    orBool isNonNumericExp(KL) ==K true
    orBool isAuxFuncExpressionLabel(KL) ==K true

syntax K ::= isNonNumericExp ( KLabel )       [function]
rule isNonNumericExp('ArrayAccess) => true
rule isNonNumericExp('NewInstance) => true    // also in customElabChildren
rule isNonNumericExp('QNewInstance) => true   // also in customElabChildren
rule isNonNumericExp('InstanceOf) => true
rule isNonNumericExp('Invoke) => true
rule isNonNumericExp('This) => true
rule isNonNumericExp('QThis) => true
rule isNonNumericExp('AmbName) => true
rule isNonNumericExp('ExprName) => true
rule isNonNumericExp('Field) => true
rule isNonNumericExp('SuperField) => true
rule isNonNumericExp('QSuperField) => true
rule isNonNumericExp('NewArray) => true
rule isNonNumericExp('CastPrim) => true
rule isNonNumericExp('CastRef) => true

/*@ Auxiliary functions that should be threated as expressions in the elaboration phase.
*/
syntax K ::= isAuxFuncExpressionLabel ( KLabel )    [function]
rule isAuxFuncExpressionLabel('cast) => true
rule isAuxFuncExpressionLabel('stmtAndExp) => true

syntax K ::= isBoolResultBinaryExpLabel ( KLabel )  [function]
rule isBoolResultBinaryExpLabel('LazyOr) => true
rule isBoolResultBinaryExpLabel('LazyAnd) => true
rule isBoolResultBinaryExpLabel('Eq) => true
rule isBoolResultBinaryExpLabel('NotEq) => true
rule isBoolResultBinaryExpLabel('Lt) => true
rule isBoolResultBinaryExpLabel('Gt) => true
rule isBoolResultBinaryExpLabel('LtEq) => true
rule isBoolResultBinaryExpLabel('GtEq) => true

rule [elabEnd-BoolResultBinaryExp]:
    elabEnd(KL:KLabel(TE1:K,, TE2:K)) => elabRes(cast(bool, KL(TE1,,TE2)))
when
    isBoolResultBinaryExpLabel(KL) ==K true

rule [elabEnd-BoolOnlyResultExp-unary]:
    elabEnd('Not(TE:K)) => elabRes(cast(bool,'Not(TE)))

rule [elabEnd-BinaryNumOperandNumResultExp]:
    elabEnd(KL:KLabel(TE1:K,, TE2:K))
    => elabExpAndType(KL(TE1,, TE2), normalizeType(typeOf(TE1), typeOf(TE2)))
when
           (KL ==KLabel 'Or)
    orBool (KL ==KLabel 'ExcOr)
    orBool (KL ==KLabel 'And)
    orBool (KL ==KLabel 'Plus)
    orBool (KL ==KLabel 'Minus)
    orBool (KL ==KLabel 'Mul)
    orBool (KL ==KLabel 'Div)
    orBool (KL ==KLabel 'Remain)

rule [elabEnd-BitShift]:
    elabEnd(KL:KLabel(TE1:K,, TE2:K))
    => elabExpAndType(KL(TE1,, TE2), normalizeType(typeOf(TE1)))
when
           (KL ==KLabel 'LeftShift)
    orBool (KL ==KLabel 'RightShift)
    orBool (KL ==KLabel 'URightShift)

rule [elabEnd-UnaryNumeric]:
    elabEnd(KL:KLabel(TE1:K)) => elabExpAndType(KL(TE1), normalizeType(typeOf(TE1)))
when
           (KL ==KLabel 'Plus)
    orBool (KL ==KLabel 'Minus)
    orBool (KL ==KLabel 'Complement)

rule [elabEnd-PrefixPostfix]:
    elabEnd(KL:KLabel(cast(T1:Type, Exp1:K))) => elabRes(cast(T1, KL(Exp1)))
when
    isPrefixPostfixExpLabel(KL) ==K true

syntax K ::= isPrefixPostfixExpLabel ( KLabel )  [function]
rule isPrefixPostfixExpLabel('PreIncr) => true
rule isPrefixPostfixExpLabel('PreDecr) => true
rule isPrefixPostfixExpLabel('PostIncr) => true
rule isPrefixPostfixExpLabel('PostDecr) => true

rule [elabEnd-StringPlusAny]:
    elabEnd('Plus(TE1:K,, TE2:K)) => elabRes(cast(stringClass,'Plus(TE1,, TE2)))
when
    typeOf(TE1) ==K stringClass orBool typeOf(TE2) ==K stringClass

rule [elabEnd-Cond]:
    elabEnd('Cond(CondTE:K,, TE1:K,, TE2:K))
    => elabExpAndType('Cond(CondTE,, TE1,, TE2), condType(typeOf(TE1), typeOf(TE2)))

/*@ Computes the type of a conditional expression.
    Operands evaluate into types.
*/
syntax K ::= condType ( Type, Type ) [strict]

rule [condType-NoChar]:
    condType(T1:Type,T2:Type) => ifAux(subtype(T1,T2), T2, T1)
when
    T1 =/=K char andBool T2 =/=K char

rule [condType-SecondChar]:
    condType(T1:Type, char) => condType(char, T1)
when
    T1 =/=K char

rule [condType-FirstChar]:
    condType(char, T2:Type) => ifAux(subtype(char, T2), T2, int)

/*@ Heats the second argument, that is reduced into a type.
    The whole expression is then rewritten into elabRes(cast(SecondArgAsType, FirstArg))
    We cannot eliminate this wrapper because the second argument in all usage places is not a function.
*/
syntax K ::= elabExpAndType ( K, K )  [strict(2)]
rule elabExpAndType(K:K, T:Type) => elabRes(cast(T, K))

rule [elabEnd-Assign-SameType]:
    elabEnd('Assign(cast(T1:Type, Exp1:K),, TExp2:K)) => elabRes(cast(T1, 'Assign(Exp1,, TExp2)))
when
    T1 ==K typeOf(TExp2)

rule [elabEnd-Assign-DiffType]:
    elabEnd('Assign( cast(T1:Type, Exp1:K),, (TE2:K => cast(T1, TE2)) ))
when
    T1 =/=K typeOf(TE2)

rule [elabEnd-CompoundAssign]:
    elabEnd(KL:KLabel(cast(T1:Type, Exp1:K),, TE2:K)) => elabRes(cast(T1, KL(Exp1,, TE2)))
when
    isCompoundAssignLabel(KL) ==K true

/*@ \subsection{Elaboration of non-numeric expressions} */

syntax KLabel ::= "'CastPrim"
                | "'CastRef"
//@ elab cast
rule elabEnd('CastPrim(T:Type,, TExp:K) => cast(T, TExp))      [structural]
rule elabEnd('CastRef(T:Type,, TExp:K)  => cast(T, TExp))      [structural]

rule [elabEnd-cast]:
    elabEnd(cast(T1:Type, TExp:K)) => elabRes(cast(T1, TExp))

/*@ \subsubsection{Elaboration of 'NewInstance and 'QNewInstance} */

/*@ elab('NewInstance()) is strict in arguments 2 and 3 - class name and constrctor arguments.
    Constrctor arguments have to be heated if this class is anonymous.
*/
rule customElabHeating('NewInstance, Ks:KList) => length(Ks) in (SetItem(2) SetItem(3))

rule [elab-NewInstance]:
    <k>
      elab(
        'NewInstance(Arg1:K,, Class:ClassType,, ActualArgsList:K,, 'None(.KList))
        =>  'QNewInstance(
              #if CT ==K staticCT
                #then noValue
                #else findQualifierOfType(CrntClass, EnclosingClass)
              #fi,,
              Arg1,, Class,, 'None(.KList),, ActualArgsList,, 'None(.KList)
            )
      )
      ...
    </k>
    <crntClass> CrntClass:ClassType </crntClass>
    <classType> Class </classType>
    <enclosingClass> EnclosingClass:ClassType </enclosingClass>
    <classContextType> CT:ContextType </classContextType>

/*@ elab('QNewInstance()) is strict in all its arguments except the class name (3) and anonymous body(6).
  - Argument (3) is heated if it is not a simple name but a precusros to a type
  - argument (6) is heated if it is 'None() - an empty body.
*/
rule customElabHeating('QNewInstance, Ks:KList,,KHole:K)
     => length(Ks,,KHole) in (SetItem(1) SetItem(2) SetItem(4) SetItem(5))
        orBool (length(Ks,,KHole) ==K 3 andBool notBool isId(KHole) ==K true) //isId(KHole) => class not resolved yet
        orBool (length(Ks,,KHole) ==K 6 andBool KHole ==K 'None(.KList))      // KHole =/= 'None(_) => anon. class

//Resolve the class name with the help of qualifier type
rule [elab-QNewInstance-resolve-class]:
    elab('QNewInstance(elabRes(cast(QualClass:ClassType, _)),, _:K,,
      (Name:Id => resolveInnerClass(QualClass, Name)),,
    _))

/*@ Resolve the simple name of an inner class to a fully qualified class name in
    a qualified new like: o.new A(...);
*/
syntax K ::=  resolveInnerClass (
                ClassType,  //QualClass - the type of the qualifier
                Id          //Name - instantiated class simple name
              )

rule isAuxFuncElabNaked('resolveInnerClass) => true

rule [resolveInnerClass]:
    <k>
      resolveInnerClass(QualClass:ClassType, Name:Id)
      => getClassIfExists(toPackage(QualClass), Name) ?? resolveInnerClass(BaseQualClass, Name)
      ...
    </k>
    <classType> QualClass </classType>
    <extends> BaseQualClass:ClassType </extends>

//@ If with the fiven package and name exists, return this class. Otherwise return noValue
syntax K ::= getClassIfExists ( PackageId, Id )

rule [getClassIfExists]:
    <k>
      getClassIfExists(Pack:PackageId, Name:Id)
      =>  #if Name in keys(NamesToClasses)
            #then getClassType(Pack:PackageId, Name:Id)
            #else noValue
          #fi
      ...
    </k>
    <namesToClasses>... Pack:PackageId |-> mapWrap(NamesToClasses:Map) ...</namesToClasses>

rule [elabEnd-QNewInstance-to-lookupMethod]:
    (. => lookupMethod(Class, false, getConsName(Class), Args)) ~>
    elabEnd('QNewInstance(Qual:K,, Arg2:K,, Class:ClassType,, Arg4:K,, 'ListWrap(Args:KList),, 'None(.KList)))

/*@ All new instance creation expressions are converted into qualified ones - 'QNewInstance, during elaboration phase.
  For instance inner classes, the qualifier will be a valid expression for the qualifier. For other classes qualifier
  will be noValue. At this stage 'QNewInstance is wrapped in elabEnd.
*/
rule [elabEnd-QNewInstance-methodLookupResult-qualified-end]:
    <k>
      methodLookupResult(_, ExpectedParamExps:KList, instanceCT)
      ~> elabEnd('QNewInstance( cast(_, QualExp:K),, Arg2:K,, Class:ClassType,, Arg4:K,,
                                _:K,, 'None(.KList) ))
      => elabRes(cast(Class, 'QNewInstance( cast(EnclosingClass, QualExp:K),, Arg2,, getSimpleName(Class),,
                                            Arg4,, 'ListWrap(ExpectedParamExps),, 'None(.KList))))
      ...
    </k>
    <classType> Class </classType>
    <enclosingClass> EnclosingClass:ClassType </enclosingClass>

/*@ A 'QNewInstance with target noValue should be packed back into a NewInstance, for compatibility with Java.
    It will be desugared again into 'NewInstance at execution phase.
*/
rule [elabEnd-QNewInstance-methodLookupResult-to-NewInstance]:
    methodLookupResult(_, ExpectedParamExps:KList, instanceCT)
    ~> elabEnd('QNewInstance(noValue,, Arg2:K,, Class:ClassType,, Arg4:K,, _:K,, 'None(.KList)))
    => elabRes(cast(Class, 'NewInstance(Arg2,, Class,, 'ListWrap(ExpectedParamExps),, 'None(.KList))))

rule [elabEnd-InstanceOf]:
    elabEnd('InstanceOf(TExp:K,, RT2:RefType)) => elabRes(cast(bool, 'InstanceOf(TExp,, RT2)))

/*@ \subsubsection{Elaboration of class literals} */

//@ Class literal types are heated by this rule.
context elab('Lit('Class(HOLE)))

rule [elab-Lit-Class]:
    elab('Lit('Class(T:Type))) => elabRes(cast(class String2Id("java.lang.Class"), 'Lit('Class(T:Type))))

endmodule
