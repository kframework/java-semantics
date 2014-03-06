require "core-sorts.k"
require "process-type-names.k"
require "subtyping.k"
require "var-lookup.k"
require "elaboration-core.k"

module ELABORATION-EXPRESSIONS
    imports CORE-SORTS
    imports PROCESS-TYPE-NAMES     //for toPackage()
    imports SUBTYPING
    imports VAR-LOOKUP             //for localVar, lookupField, lookupStaticField
    imports ELABORATION-CORE

//@ Elaboration of rules in java-var-lookup

//@ Both unqualified and qualified AmbName.
rule [elabEnd-AmbName]:
    elabEnd('AmbName(Ks:KList)) => elabEnd('ExprName(Ks)) ?? 'TypeName(Ks) ?? 'PackageName('ListWrap(Ks))

syntax KLabel ::= "'ExprName"

//@ "localVar" is defined in the module VAR-LOOKUP.
rule [elabEnd-ExprName-unqualified]:
    <k> elabEnd('ExprName(X:Id)) => elabEnd(localVar(X)) ?? externalVar(X, Class) ...</k>
    <crntClass> Class:ClassType </crntClass>

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
      elabOuterLocalVar(X:Id, Class:ClassType) => elabRes(cast(T, localVar(X)))
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

rule [elabEnd-localVar-ok]:
  <k> elabEnd(localVar(X:Id)) => elabRes(cast(T, localVar(X))) ...</k>
  <elabEnv> ListItem(mapWrap(X |-> T:Type _)) ...</elabEnv>

rule [elabEnd-localVar-to-noValue]:
  <k> elabEnd(localVar(X:Id)) => noValue ...</k>
  <elabEnv> ListItem(mapWrap(ElabEnv:Map)) ...</elabEnv>
when notBool (X in keys(ElabEnv))

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

rule [elabEnd-This]:
    <k> elabEnd('This(.KList) => 'QThis(Class)) ...</k>
    <crntClass> Class:ClassType </crntClass>

rule [elabEnd-QThis-InstanceCT]:
    <k> elabEnd('QThis(Class:ClassType)) => elabRes(cast(Class, 'QThis(Class))) ...</k>
    <contextType> instanceCT </contextType>

rule [elabEnd-QThis-StaticCT]:
    <k> elabEnd('QThis(_)) => noValue ...</k>
    <contextType> staticCT </contextType>

rule [elabEnd-Field-QualRef]:
    elabEnd('Field(cast(Class:ClassType, Qual:K),, X:Id))
    => elabFieldImpl(cast(Class, Qual), X, elabLookup(X, Class))

rule [elabEnd-Field-QualClass]:
    elabEnd('Field(Class:ClassType,, X:Id))
    => elabFieldImpl(noValue, X, elabLookup(X, Class))

rule [elabEnd-SuperField]:
    <k>
      elabEnd('SuperField(X:Id) => 'QSuperField(Class,, X:Id))
      ...
    </k>
    <crntClass> Class:ClassType </crntClass>

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
    => elabRes(cast(T, lookupStaticField(Class,X)))

//@for constant fields
rule elabFieldImpl(_,_, TV:TypedVal) => TV

rule elabFieldImpl(_,_, noValue) => noValue

/*@ \subsection{Elaboration of numeric expressions} */

/*@ Expression labels are not converted by the default rule in the phase elabDispose() => elabRes(...)
    Each expression needs a specialized rule for disposing, that will compute, among others,
    the type of the expression.
*/
syntax K ::= isExpressionLabel ( KLabel ) [function]
rule isExpressionLabel(KL:KLabel) =>
    //Infix operators
    /* ||  */        (KL ==KLabel 'LazyOr)
    /* &&  */ orBool (KL ==KLabel 'LazyAnd)
    /* |   */ orBool (KL ==KLabel 'Or)
    /* ^   */ orBool (KL ==KLabel 'ExcOr)
    /* &   */ orBool (KL ==KLabel 'And)
    /* ==  */ orBool (KL ==KLabel 'Eq)
    /* !=  */ orBool (KL ==KLabel 'NotEq)
    /* <   */ orBool (KL ==KLabel 'Lt)
    /* >   */ orBool (KL ==KLabel 'Gt)
    /* <=  */ orBool (KL ==KLabel 'LtEq)
    /* >=  */ orBool (KL ==KLabel 'GtEq)
    /* <<  */ orBool (KL ==KLabel 'LeftShift)
    /* >>  */ orBool (KL ==KLabel 'RightShift)
    /* >>> */ orBool (KL ==KLabel 'URightShift)
    /* +   */ orBool (KL ==KLabel 'Plus)
    /* -   */ orBool (KL ==KLabel 'Minus)
    /* *   */ orBool (KL ==KLabel 'Mul)
    /* /   */ orBool (KL ==KLabel 'Div)
    /* %   */ orBool (KL ==KLabel 'Remain)

    //Prefix operators
    /* ++  */ orBool (KL ==KLabel 'PreIncr)
    /* --  */ orBool (KL ==KLabel 'PreDecr)
    /* !   */ orBool (KL ==KLabel 'Not)
    /* ~   */ orBool (KL ==KLabel 'Complement)
    /* +   */ //'Plus   - defined earlier
    /* -   */ //'Minus  - defined earlier

    //Postfix operators
    /* ++  */ orBool (KL ==KLabel 'PostIncr)
    /* --  */ orBool (KL ==KLabel 'PostDecr)

    //Ternary operators
      /* ? : */ orBool (KL ==KLabel 'Cond)
      /* =   */ orBool (KL ==KLabel 'Assign)

                orBool isCompoundAssignLabel(KL)
                orBool isNonNumericExp(KL)
                orBool isAuxFuncExpressionLabel(KL)

syntax K ::= isCompoundAssignLabel ( KLabel ) [function]
rule isCompoundAssignLabel(KL:KLabel) =>
           (KL ==KLabel 'AssignPlus)
    orBool (KL ==KLabel 'AssignMinus)
    orBool (KL ==KLabel 'AssignMul)
    orBool (KL ==KLabel 'AssignDiv)
    orBool (KL ==KLabel 'AssignAnd)
    orBool (KL ==KLabel 'AssignOr)
    orBool (KL ==KLabel 'AssignExcOr)
    orBool (KL ==KLabel 'AssignRemain)
    orBool (KL ==KLabel 'AssignLeftShift)
    orBool (KL ==KLabel 'AssignRightShift)
    orBool (KL ==KLabel 'AssignURightShift)

syntax K ::= isNonNumericExp ( KLabel )       [function]
rule isNonNumericExp(KL:KLabel) =>
           (KL ==KLabel 'ArrayAccess)
    orBool (KL ==KLabel 'NewInstance)   // also in customElabChildren
    orBool (KL ==KLabel 'QNewInstance)  // also in customElabChildren
    orBool (KL ==KLabel 'InstanceOf)
    orBool (KL ==KLabel 'Invoke)
    orBool (KL ==KLabel 'This)
    orBool (KL ==KLabel 'QThis)
    orBool (KL ==KLabel 'AmbName)
    orBool (KL ==KLabel 'ExprName)
    orBool (KL ==KLabel 'Field)
    orBool (KL ==KLabel 'SuperField)
    orBool (KL ==KLabel 'QSuperField)
    orBool (KL ==KLabel 'NewArray)
    orBool (KL ==KLabel 'CastPrim)
    orBool (KL ==KLabel 'CastRef)

/*@ Auxiliary functions that should be threated as expressions in the elaboration phase.
*/
syntax K ::= isAuxFuncExpressionLabel ( KLabel )    [function]
rule isAuxFuncExpressionLabel(KL:KLabel)
    =>     KL ==KLabel 'localVar
    orBool KL ==KLabel 'cast
    orBool KL ==KLabel 'stmtAndExp
    orBool KL ==KLabel 'getQThisSubclassOf

rule [elabEnd-BoolOnlyResultExp-binary]:
    elabEnd(KL:KLabel(TE1:K,, TE2:K)) => elabRes(cast(bool, KL(TE1,,TE2)))
when
           (KL ==KLabel 'LazyOr)
    orBool (KL ==KLabel 'LazyAnd)
    orBool (KL ==KLabel 'Eq)
    orBool (KL ==KLabel 'NotEq)
    orBool (KL ==KLabel 'Lt)
    orBool (KL ==KLabel 'Gt)
    orBool (KL ==KLabel 'LtEq)
    orBool (KL ==KLabel 'GtEq)

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
           (KL ==KLabel 'PreIncr)
    orBool (KL ==KLabel 'PreDecr)
    orBool (KL ==KLabel 'PostIncr)
    orBool (KL ==KLabel 'PostDecr)

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
    condType(T1:Type,T2:Type) => 'If(subtype(T1,T2),, T2,, T1)
when
    T1 =/=K char andBool T2 =/=K char

rule [condType-SecondChar]:
    condType(T1:Type, char) => condType(char, T1)
when
    T1 =/=K char

rule [condType-FirstChar]:
    condType(char, T2:Type) => 'If(subtype(char, T2),, T2,, int)

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
    isCompoundAssignLabel(KL)

/*@ \subsection{Elaboration of non-numeric expressions} */

//@ elab cast
rule elabEnd('CastRef(T:Type,, TExp:K)  => cast(T, TExp))      [structural]
rule elabEnd('CastPrim(T:Type,, TExp:K) => cast(T, TExp))      [structural]

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
                #else getQThisSubclassOf(CrntClass, EnclosingClass)
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
  If this is not an anynymous class then 6-th argument is also default heated.
*/
rule customElabHeating('QNewInstance, Ks:KList,,KHole:K)
     => length(Ks,,KHole) in (SetItem(1) SetItem(2) SetItem(4) SetItem(5))
        orBool (length(Ks,,KHole) ==K 6 andBool KHole ==K 'None(.KList))

//@ Heat the class name if it is not a simple name.
context elab('QNewInstance(_:K,,_:K,, HOLE,, _))
when
    notBool isId(HOLE) ==K true

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
    (. => lookupMethod(Class, getConsName(Class), noValue, false, Class, Args)) ~>
    elabEnd('QNewInstance(Qual:K,, Arg2:K,, Class:ClassType,, Arg4:K,, 'ListWrap(Args:KList),, 'None(.KList)))

rule [elabEnd-QNewInstance-methodProcessArguments-to-argsElaborated]:
    (methodProcessArguments(_,_,_,_, types(.KList), .KList, ExpectedParamExps:KList, instanceCT) => argsElaborated)
    ~> elabEnd('QNewInstance(_:K,, _:K,, _:K,, _:K,, (_:K => 'ListWrap(ExpectedParamExps)),, _:K))

//@ Marker indicating that arguments of the following 'QNewInstance have been elaborated
syntax K ::= "argsElaborated"

/*@ All new instance creation expressions are converted into qualified ones - 'QNewInstance, during elaboration phase.
  For instance inner classes, the qualifier will be a valid expression for the qualifier. For other classes qualifier
  will be noValue. At this stage 'QNewInstance is wrapped in elabEnd.
*/
rule [elabEnd-QNewInstance-argsElaborated-qualified-end]:
    <k>
      argsElaborated
      ~> elabEnd('QNewInstance( cast(_, QualExp:K),, Arg2:K,, Class:ClassType,, Arg4:K,,
                                ExpectedArgsList:K,, 'None(.KList) ))
      => elabRes(cast(Class, 'QNewInstance( cast(EnclosingClass, QualExp:K),, Arg2,,
                                            getSimpleName(Class),, Arg4,, ExpectedArgsList,, 'None(.KList))))
      ...
    </k>
    <classType> Class </classType>
    <enclosingClass> EnclosingClass:ClassType </enclosingClass>

/*@ A 'QNewInstance with target noValue should be packed back into a NewInstance, for compatibility with Java.
    It will be desugared again into 'NewInstance at execution phase.
*/
rule [elabEnd-QNewInstance-argsElaborated-to-NewInstance]:
    argsElaborated
    ~> elabEnd('QNewInstance(noValue,, Arg2:K,, Class:ClassType,, Arg4:K,, ExpectedArgsList:K,,'None(.KList)))
    => elabRes(cast(Class, 'NewInstance(Arg2,, Class,, ExpectedArgsList,, 'None(.KList))))

rule [elabEnd-InstanceOf]:
    elabEnd('InstanceOf(TExp:K,, RT2:RefType)) => elabRes(cast(bool, 'InstanceOf(TExp,, RT2)))

/*@ \subsubsection{Elaboration of class literals} */

//@ Class literal types are heated by this rule.
context elab('Lit('Class(HOLE)))

rule [elab-Lit-Class]:
    elab('Lit('Class(T:Type))) => elabRes(cast(class String2Id("java.lang.Class"), 'Lit('Class(T:Type))))

/*@ \subsubsection{Elaboration of array-related expressions} */

rule [elabEnd-ArrayAccess]:
    elabEnd('ArrayAccess(cast(arrayOf T:Type, TargetExp:K),, IndexTE:K))
    => elabRes(cast(T, 'ArrayAccess(cast(arrayOf T, TargetExp),, IndexTE)))

rule [elabEnd-Field-ArrayLength]:
    elabEnd('Field(cast(arrayOf T:Type, Qual:K),, X:Id))
    => elabRes(cast(int, lookupField(cast(arrayOf T, Qual), arrayOf T, X)))
when
    Id2String(X) ==String "length"

context 'ArrayType(HOLE)
rule 'ArrayType(T:Type) => arrayOf T     [structural]

syntax KLabel ::= "'NewArray"

rule [elabEnd-NewArray-EmptyDims]:
    elabEnd('NewArray( (T:Type => arrayOf T),, _:K,,
        'ListWrap( ( 'Dim(.KList) => .KList ) ,,_:KList) ))
        [structural]

rule [elabEnd-NewArray]:
    elabEnd('NewArray(T:Type,, 'ListWrap(Dims:KList),, 'ListWrap(.KList)))
    => elabExpAndType(newArrayImpl(T, 'ListWrap(Dims), default(T), .KList), getArrayType(T, Dims))
        [structural]

//@ Computes the array type based on allocated elem type and number of allocated dimensions.
syntax K ::= getArrayType ( Type, KList )                          [function]
rule getArrayType(T:Type, K:K,,Dims:KList) => getArrayType(arrayOf T, Dims)
rule getArrayType(T:Type, .KList) => T

rule [elabEnd-NewArray-ArrayInit-Preprocess]:
    elabEnd('NewArray((T:Type => arrayOf T),, 'ListWrap(('Dim(.KList) => .KList),, _),, 'ArrayInit(_)))

rule [elabEnd-NewArray-ArrayInit]:
    elabEnd('NewArray(arrayOf T:Type,, 'ListWrap(.KList),, 'ArrayInit('ListWrap(InitContent:KList))))
    => elabRes(cast(arrayOf T, newArrayImpl(T, 'ListWrap(length(InitContent)::int), .K, InitContent)))

//@ Counts the number of elements in the KList list. Evaluates to an cast(int, Int) .
syntax K ::= length ( KList )                                       [function]
           | length ( Int, KList )                                  [function]

rule length(Ks:KList) => length(0, Ks)
rule length(I:Int, K:K,, Ks:KList) => length(I +Int 1, Ks)
rule length(I:Int, .KList) => I

endmodule
