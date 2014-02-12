require "core.k"
require "process-type-names.k"
require "subtyping.k"
require "var-lookup.k"
require "elaboration-core.k"

module ELABORATION-EXPRESSIONS
    imports CORE
    imports PROCESS-TYPE-NAMES     //for toPackage()
    imports SUBTYPING
    imports VAR-LOOKUP             //for localVar
    imports ELABORATION-CORE

//@Elaboration result of a field access exp.
syntax K ::= "lookupField" "(" K    //Qualifier exp
                           "," Type //Precise type where the field is defined
                           "," Id   //X - field name
                           ")"
//@Elaboration result of a static field access expression
            | "lookupStaticField" "(" Type //Precise type where the field is defined
                                  "," Id   //X - field name
                                  ")"

//@Elaboration result of expressions new T[]...
syntax K ::= "newArrayImpl" "("
                Type ","  // T - type of each allocated element. So for new int[1][1][][], T will be "arrayOf arrayOf int".
                K ","     // 'ListWrap(Dims) - array dimensions
                K ","     // InitExp - expression used to initialize each array element, or .K if argument 4 is specified.
                KList     // InitContent - array initializer, if any, or .K if argument 3 is specified.
                          // From arguments 3 and 4 just one may be specified. This initializer is for the whole array,
                          //  not for each element as the previous one.
             ")"

//@ Elaboration of rules in java-var-lookup

//@ Both unqualified and qualified AmbName.
rule [elabAmbName]:
    elabDispose('AmbName(Ks:KList)) => elabDispose('ExprName(Ks)) ?? 'TypeName(Ks) ?? 'PackageName('ListWrap(Ks))
when
    haveNoElabRes(Ks)

//@ "localVar" is defined in the module VAR-LOOKUP.
rule [elabExprNameSimple]:
    <k> elabDispose('ExprName(X:Id)) => elabDispose(localVar(X)) ?? externalVar(X, Class) ...</k>
    <crntClass> Class:ClassType </crntClass>

//@ This could be either a field, or a local var of some enclosing block.
syntax K ::= "externalVar" "(" Id         //X - var name
                           "," ClassType  //Class - innermost class where the name should be searched
                           ")"

rule [externalVar]:
    <k>
      externalVar(X:Id, Class:ClassType)
      => elabDispose('Field( 'QThis(Class),, X )) ?? elabOuterLocalVar(X, Class) ?? externalVar(X, EnclosingClass)
      ...
    </k>
    <classType> Class </classType>
    <enclosingClass> EnclosingClass:ClassType </enclosingClass>

rule [externalVar-noClass]:
    externalVar(_, noClass) => noValue

//@Attempts to resolve this expression into a local var from the enclosing local environment
//@of type being precisely the given class.
syntax K ::= "elabOuterLocalVar" "(" Id         //X - var name
                                 "," ClassType  //Class - the class where the name should be searched
                                 ")"

rule [elabOuterLocalVar-ok]:
    <k>
      elabOuterLocalVar(X:Id, Class:ClassType) => elabRes(localVar(X) :: T)
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

rule [elabExprNameQualified]:
    elabDispose('ExprName(QualK:K,,X:Id)) => elabDispose('Field(QualK,,X))

rule [elabLocalVarOk]:
  <k> elabDispose(localVar(X:Id)) => elabRes(localVar(X) :: T) ...</k>
  <elabEnv> ListItem(stEnv(X |-> T:Type _)) ...</elabEnv>

rule [elabLocalVarNoValue]:
  <k> elabDispose(localVar(X:Id)) => noValue ...</k>
  <elabEnv> ListItem(stEnv(StEnv:Map)) ...</elabEnv>
when notBool (X in keys(StEnv))

rule [elabFieldWithQThis]:
    elabDispose('Field( 'QThis(Class:ClassType),, X:Id ))
    => elab('Field( elabRes('QThis(Class:ClassType) :: Class),, X )) ?? elab('Field( Class,, X))
when
    Class =/=K noClass

rule [FieldOfPackage]:
    elabDispose('Field( _:PackageId,, _:Id )) => noValue  [structural]

rule [FieldOfNoValue]:
    elabDispose('Field( noValue,, _:Id )) => noValue      [structural]

rule [FieldOfQThis-noClass]:
    elabDispose('Field( 'QThis(noClass),, _:Id )) => noValue      [structural]

//@Computation of instance and static environment of a class, e.g. set of fields

//@Searches the given field name in the given type (types), both static and instance context.
syntax K ::= "elabLookup" "("
                                      Id ","    //The field to search
                                      ClassType //The current class under search
                          ")"
           | "elabLookup" "("
                                      Id ","    //The field to search
                                      Set       //A set of interfaces under search
                          ")"

rule [elabLookupFoundInstance]:
    <k> elabLookup(X:Id, CT:ClassType) => FEntry ...</k>
    <classType> CT </classType>
    <instanceEnv>... X |-> FEntry:K ...</instanceEnv>

rule [elabLookupFoundStatic]:
    <k> elabLookup(X:Id, CT:ClassType) => fieldEntry(CT,X,T, staticCT) ...</k>
    <classType> CT </classType>
    <staticEnv>... X |-> L:Int ...</staticEnv>
    <store>... L |-> _ :: T:Type  ...</store>

rule [elabLookupFoundConstant]:
    <k> elabLookup(X:Id, CT:ClassType) => TV ...</k>
    <classType> CT </classType>
    <constantEnv>... X |-> TV:TypedVal ...</constantEnv>

/*@If X is not found in the current class, search for it first in base interfaces, then in the base class.
This order is necessary to avoid the case when base class have a private field X, and base
interfaces have a public one. In this case we should choose the field from the interface.
*/
rule [elabLookupNextClass]:
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

rule [elabLookupNotFound]:
    elabLookup(X:Id, noClass) => noValue

rule [elabLookup-Set]:
    elabLookup(X:Id, SetItem(Class:ClassType) Rest:Set)
    => elabLookup(X, Class) ?? elabLookup(X, Rest)

rule [elabLookup-Set-NotFound]:
    elabLookup(_, .Set) => noValue

rule [elabThis]:
    <k> elabDispose('This(.KList) => 'QThis(Class)) ...</k>
    <crntClass> Class:ClassType </crntClass>

rule [elabQThisInstanceCT]:
    <k> elabDispose('QThis(Class:ClassType)) => elabRes('QThis(Class) :: Class) ...</k>
    <contextType> instanceCT </contextType>

rule [elabQThisStaticCT]:
    <k> elabDispose('QThis(_)) => noValue ...</k>
    <contextType> staticCT </contextType>

rule [elabFieldQualRef]:
    elabDispose('Field(Qual:K :: Class:ClassType,, X:Id))
    => elabFieldImpl(Qual::Class, X, elabLookup(X, Class))

rule [elabFieldQualClass]:
    elabDispose('Field(Class:ClassType,, X:Id))
    => elabFieldImpl(noValue, X, elabLookup(X, Class))

rule [elabSuperField]:
    <k>
      elabDispose('SuperField(X:Id) => 'QSuperField(Class,, X:Id))
      ...
    </k>
    <crntClass> Class:ClassType </crntClass>

rule [elabQSuperField]:
    <k>
      elabDispose('QSuperField(Class:ClassType,, X:Id))
      => elabFieldImpl('QThis(Class) :: Class, X, elabLookup(X, BaseClass))
      ...
    </k>
    <classType> Class </classType>
    <extends> BaseClass:ClassType </extends>

//@Computed the TypedExp expression for a given expression and its type
syntax K ::= "elabFieldImpl" "(" K  // Field qualifier exp (noValue for fields qualified by a class)
                             "," Id // X - the field name
                             "," K  //elabLookup(...), computes into fieldEntry(...) or noValue
                             ")"  [strict(3)]

rule elabFieldImpl(SourceExp:K, X:Id, fieldEntry(Class:ClassType,_,T:Type, instanceCT))
    => elabRes(lookupField(SourceExp,Class,X) :: T)

rule elabFieldImpl(_, X:Id, fieldEntry(Class:ClassType,_,T:Type, staticCT))
    => elabRes(lookupStaticField(Class,X) :: T)

//@for constant fields
rule elabFieldImpl(_,_, TV:TypedVal) => TV

rule elabFieldImpl(_,_, noValue) => noValue

/*@ \subsection{Elaboration of numeric expressions} */

//@ Expression labels are not converted by the default rule in the phase
//@  elabDispose() => elabRes(...)
//@ Each expression needs a specialized rule for disposing, that will compute, among others,
//@ the type of the expression.
syntax K ::= "isExpressionLabel" "(" KLabel ")" [function]
rule isExpressionLabel(KL:KLabel) =>
                     (KL ==KLabel 'localVar`(_`))

    //Infix operators
    /* ||  */ orBool (KL ==KLabel 'LazyOr)
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

syntax K ::= "isCompoundAssignLabel" "(" KLabel ")" [function]
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

syntax K ::= "isNonNumericExp" "(" KLabel ")"       [function]
rule isNonNumericExp(KL:KLabel) =>
           (KL ==KLabel 'ArrayAccess)
    orBool (KL ==KLabel 'NewInstance)   // also in customElabChildren
    orBool (KL ==KLabel 'QNewInstance)  // also in customElabChildren
    orBool (KL ==KLabel 'InstanceOf)
    orBool (KL ==KLabel 'castImpl`(_`,_`))
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
    orBool (KL ==KLabel 'stmtAndExp`(_`,_`))

//@ It looks like isTypedExp(KList) doesn't work.
rule [elabBoolOnlyResultExpBinary]:
    elabDispose(KL:KLabel(TE1:TypedExp,, TE2:TypedExp)) => elabRes(KL(TE1,,TE2) :: bool)
when
           (KL ==KLabel 'LazyOr)
    orBool (KL ==KLabel 'LazyAnd)
    orBool (KL ==KLabel 'Eq)
    orBool (KL ==KLabel 'NotEq)
    orBool (KL ==KLabel 'Lt)
    orBool (KL ==KLabel 'Gt)
    orBool (KL ==KLabel 'LtEq)
    orBool (KL ==KLabel 'GtEq)

rule [elabBoolOnlyResultExpUnary]:
    elabDispose('Not(TE:TypedExp)) => elabRes('Not(TE) :: bool)

rule [elabBoolOperandBoolResultExp]:
    elabDispose(KL:KLabel(Exp1:K::bool,, Exp2:K::bool)) => elabRes(KL(Exp1::bool,, Exp2::bool) :: bool)
when
           (KL ==KLabel 'Or)
    orBool (KL ==KLabel 'ExcOr)
    orBool (KL ==KLabel 'And)

rule [elabBinaryNumOperandNumResultExp]:
    elabDispose(KL:KLabel(Exp1:K::NT1:NumericType,, Exp2:K::NT2:NumericType))
    => elabExpAndType(KL(Exp1::NT1,, Exp2::NT2), normalizeType(NT1,NT2))
when
           (KL ==KLabel 'Or)
    orBool (KL ==KLabel 'ExcOr)
    orBool (KL ==KLabel 'And)
    orBool (KL ==KLabel 'Plus)
    orBool (KL ==KLabel 'Minus)
    orBool (KL ==KLabel 'Mul)
    orBool (KL ==KLabel 'Div)
    orBool (KL ==KLabel 'Remain)

rule [elabBitShift]:
    elabDispose(KL:KLabel(Exp1:K::NT1:NumericType,, Exp2:K::NT2:NumericType))
    => elabExpAndType(KL(Exp1::NT1,, Exp2::NT2), normalizeType(NT1))
when
           (KL ==KLabel 'LeftShift)
    orBool (KL ==KLabel 'RightShift)
    orBool (KL ==KLabel 'URightShift)

rule [elabUnaryNumeric]:
    elabDispose(KL:KLabel(Exp:K::NT:NumericType)) => elabExpAndType(KL(Exp::NT), normalizeType(NT))
when
           (KL ==KLabel 'Plus)
    orBool (KL ==KLabel 'Minus)
    orBool (KL ==KLabel 'Complement)

//@ Heats the second argument, that is reduced into a type.
//@ The whole expression is then rewritten into elabRes(FirstArg::SecondArgAsType)
syntax K ::= "elabExpAndType" "(" K "," K ")"  [strict(2)]
rule elabExpAndType(K:K, T:Type) => elabRes(K::T)

rule [elabPrefixPostfix]:
    elabDispose(KL:KLabel(Exp:K::NT:NumericType)) => elabRes(KL(Exp::NT) :: NT)
when
           (KL ==KLabel 'PreIncr)
    orBool (KL ==KLabel 'PreDecr)
    orBool (KL ==KLabel 'PostIncr)
    orBool (KL ==KLabel 'PostDecr)

rule [elabStringPlusAny]:
    elabDispose('Plus(Exp:K::rtString,, TE:TypedExp)) => elabRes('Plus(Exp::rtString,, TE) :: rtString)

rule [elabAnyPlusString]:
    elabDispose('Plus(TE:TypedExp,, Exp:K::rtString)) => elabRes('Plus(TE,, Exp::rtString) :: rtString)

rule [elabCond]:
    elabDispose('Cond(CondTE:TypedExp,, Exp1:K::T1:Type,, Exp2:K::T2:Type))
    => condType(T1, T2) ~> elabRes('Cond(CondTE,, Exp1::T1,, Exp2::T2) :: CHOLE)

//@ Used for the type of 'Cond and newArrayImpl
rule [elabResCoolExpType]:
    (T:Type => .K) ~> elabRes(_ :: (CHOLE => T))

//@ computes the type of a conditional expression
//@ Operands evaluate into types
syntax K ::= "condType" "(" Type "," Type ")" [strict]

rule [condTypeNoChar]:
    condType(T1:Type,T2:Type) => 'If(subtype(T1,T2),, T2,, T1)
when
    T1 =/=K char andBool T2 =/=K char

rule [condTypeSecondChar]:
    condType(T1:Type, char) => condType(char, T1)
when
    T1 =/=K char

rule [condTypeFirstChar]:
    condType(char, T2:Type) => 'If(subtype(char, T2),, T2,, int)

rule [elabAssignSameType]:
    elabDispose('Assign(Exp1:K::T1:Type,, Exp2:K::T1)) => elabRes('Assign(Exp1::T1,, Exp2::T1) :: T1)

rule [elabAssignDiffType]:
    elabDispose('Assign(
       Exp1:K::T1:Type,,
      (Exp2:K::T2:Type => castImpl(T1, Exp2::T2)::T1)
    ))
when
    T1 =/=K T2

rule [elabCompoundAssign]:
    elabDispose(KL:KLabel(Exp1:K::T1:Type,, TE:TypedExp)) => elabRes(KL(Exp1::T1,, TE) :: T1)
when
    isCompoundAssignLabel(KL)

/*@ \subsection{Elaboration of non-numeric expressions} */

//@ elab cast
rule elabDispose('CastRef(T:Type,, TExp:TypedExp)  => castImpl(T, TExp))      [structural]
rule elabDispose('CastPrim(T:Type,, TExp:TypedExp) => castImpl(T, TExp))      [structural]

//@ Case when Exp was initially a literal, and now is Val::Type
rule [elabCastImplElabIndep]:
    elabDispose(castImpl(T1:Type, Exp:K :: T2:Type)) => elabRes(castImpl(T1, Exp::T2) :: T1)

//@ Heat the class name
context elab('NewInstance(_:K,, HOLE,, _))

//@ Heat the unqualified constructor arguments.
//@ Required if this class is anonymous
rule (. => elab(K)) ~> elab('NewInstance(_:K,,_:K,, (K:K => CHOLE),, _:K))
when
    notBool isElab(K)

rule [elabNewInstance]:
    <k>
      elab('NewInstance(Arg1:K,, Class:ClassType,, ActualArgsList:K,, 'None(.KList)))
      => getElabResQThisSubclassOf(CrntClass, getEnclosingClass(Class))
      ~> elab('QNewInstance(CHOLE,, Arg1,, Class,, 'None(.KList),, ActualArgsList,, 'None(.KList)))
      ...
    </k>
    <crntClass> CrntClass:ClassType </crntClass>

//@ Heat the qualifier in 'QNewInstance
rule (. => elab(K)) ~> elab('QNewInstance((K:K => CHOLE),, _))
when
    notBool isElab(K)

//@ Heat the qualified constructor arguments
rule (. => elab(K)) ~> elab('QNewInstance(_:K,,_:K,,_:K,,_:K,, (K:K => CHOLE),, _:K))
when
    notBool isElab(K)

//@ Heat the class name, if it could be resolved to a type
context elab('QNewInstance(_:K,,_:K,, HOLE,, _))
when
    notBool isId(HOLE)

rule [elabQNewInstance-resolve-class]:
    (. => resolveInnerClass(QualClass, Name))
    ~> elab('QNewInstance(elabRes(_::QualClass:ClassType),, _:K,,
      (Name:Id => CHOLE),,
    _))

//@ Resolve the simple name of an inner class to a fully qualified class name in
//@ a qualified new like: o.new A(...);
syntax K ::= "resolveInnerClass" "(" ClassType //QualClass - the type of the qualifier
                                 "," Id        //Name - instantiated class simple name
                                 ")"

rule [resolveInnerClass]:
    <k>
      resolveInnerClass(QualClass:ClassType, Name:Id)
      => 'If(
            existsClass(toPackage(QualClass), Name),,
            getClassType(toPackage(QualClass), Name),,
            resolveInnerClass(BaseQualClass, Name)
          )
      ...
    </k>
    <classType> QualClass </classType>
    <extends> BaseQualClass:ClassType </extends>

//@ Returns true if in the given package exists a class with given simple name, false otherwise.
syntax K ::= "existsClass" "(" PackageId "," Id ")"

rule [existsClass]:
    <k>
      existsClass(Pack:PackageId, Name:Id) => Name in keys(NamesToClasses)
      ...
    </k>
    <namesToClasses>... Pack:PackageId |-> mapWrap(NamesToClasses:Map) ...</namesToClasses>

/*@ All new instance creation expressions are converted into qualified ones - 'QNewInstance, duringelaboration phase.
  For instance inner classes, the qualifier will be a valid expression for the qualifier. For other classes qualifier
  will be noValue.
*/
rule [elab-QNewInstance]:
    elab('QNewInstance(elabRes(Qual:K),, Arg2:K,, T:RefType,, Arg4:K,, elabRes(ActualArgsList:K),, 'None(.KList)))
    => elabRes('QNewInstance(Qual,, Arg2,, T,, Arg4,, ActualArgsList,, 'None(.KList)) :: T)

rule [elabInstanceOf]:
    elabDispose('InstanceOf(TE:TypedExp,, RT2:RefType)) => elabRes('InstanceOf(TE,, RT2) :: bool)

//@ Class literal types are heated by this rule.
context elab('Lit('Class(HOLE)))

rule [elabLitClass]:
    elab('Lit('Class(T:Type))) => elabRes('Lit('Class(T:Type)) :: class String2Id("java.lang.Class"))

rule [elabArrayAccess]:
    elabDispose('ArrayAccess(TargetExp:K::arrayOf T:Type,, IndexTE:TypedExp))
    => elabRes('ArrayAccess(TargetExp::arrayOf T,, IndexTE) :: T)

rule [elabArrayLength]:
    elabDispose('Field(Qual:K :: arrayOf T:Type,, X:Id))
    => elabRes(lookupField(Qual:: arrayOf T, arrayOf T, X) :: int)
when
    Id2String(X) ==String "length"

context 'ArrayType(HOLE)
rule 'ArrayType(T:Type) => arrayOf T     [structural]

rule [NewArrayEmptyDims]:
    elabDispose('NewArray( (T:Type => arrayOf T),, _:K,,
        'ListWrap( ( 'Dim(.KList) => .KList ) ,,_:KList) ))
        [structural]

rule [NewArray]:
    elabDispose('NewArray(T:Type,, 'ListWrap(Dims:KList),, 'ListWrap(.KList)))
    => getArrayType(T, Dims) ~> elabRes(newArrayImpl(T, 'ListWrap(Dims), default(T), .KList) :: CHOLE)
        [structural]

//@ Computes the array type based on allocated elem type and number of allocated dimensions.
syntax K ::= "getArrayType" "(" Type "," KList ")"
rule getArrayType(T:Type, K:K,,Dims:KList) => getArrayType(arrayOf T, Dims) [structural]
rule getArrayType(T:Type, .KList) => T                                      [structural]

rule [ArrayInitPreprocess]:
    elabDispose('NewArray((T:Type => arrayOf T),, 'ListWrap(('Dim(.KList) => .KList),, _),, 'ArrayInit(_)))

rule [ArrayInit]:
    elabDispose('NewArray(arrayOf T:Type,, 'ListWrap(.KList),, 'ArrayInit('ListWrap(InitContent:KList))))
    => elabRes(newArrayImpl(T, 'ListWrap(count(InitContent)), .K, InitContent) :: arrayOf T)

//@ Counts the number of elements in the KList list. Evaluates to an Int::int .
syntax K ::= "count" "(" KList ")"
           | "count" "(" Int "," KList ")"

rule count(Ks:KList) => count(0, Ks)
rule count(I:Int, K:K,, Ks:KList) => count(I +Int 1, Ks)
rule count(I:Int, .KList) => I::int

//K bug: latex workaround - manual character escape.
//@ True for 'QThis(\_)::T, false otherwise
syntax K ::= "isTypedQThis" "(" K ")"                                    [function]

rule isTypedQThis(K:K::_) => getKLabel(K) ==KLabel 'QThis

rule isTypedQThis(K:K) => false
when getKLabel(K) =/=KLabel '_::_

syntax K ::= "getEnclosingClass" "(" ClassType ")"

rule [getEnclosingClass]:
    <k> getEnclosingClass(Class:ClassType) => EnclosingClass ...</k>
    <classType> Class </classType>
    <enclosingClass> EnclosingClass:ClassType </enclosingClass>

endmodule
