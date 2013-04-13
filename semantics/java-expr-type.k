require "java-core.k"
require "java-expressions.k"
require "java-arrays.k"

module JAVA-EXPR-TYPE
    imports JAVA-CORE
    imports JAVA-EXPRESSIONS
    imports JAVA-ARRAYS

rule [getExpTypeValue]:
    getExpType(_::T:Type) => T

rule [getExpTypeNewInstance]:
    getExpType('NewInstance(_:K,, Class:ClassType,, _)) => Class

rule [getExpTypeNewArrayReduce]:
    getExpType(newArrayImpl((T:Type => arrayOf T), 'ListWrap((Dim:TypedVal => .List{K}),,_), _:K))

rule [getExpTypeNewArray]:
    getExpType(newArrayImpl(T:Type, 'ListWrap(.List{K}), _:K)) => T

//getExpTypeExprName
//also good for field access
context getExpType(HOLE)
when
    getKLabel(HOLE) ==KLabel 'ExprName

//todo getExpType for method invocation needs to determine the right method signature

rule [getExpTypeArrayAccessHeat]:
    (. => getExpType(TargetK)) ~> getExpType('ArrayAccess((TargetK:K => EXPHOLE),,_))
when
    notBool (isKResult(TargetK) ==K true)

rule [getExpTypeArrayAccess]:
    getExpType('ArrayAccess(arrayOf T:Type,, _)) => T

rule [getExpTypeNumToNumHeat]:
    (. => getExpType(TargetK)) ~> getExpType(KL:KLabel(_,,(TargetK:K => EXPHOLE),,_))
when
    isNumToNum(KL)
    andBool notBool (isType(TargetK) ==K true)

rule [getExpTypeUnary]:
    getExpType(KL:KLabel(T:Type)) => T
when
    isNumToNum(KL)

rule [getExpTypeBinaryNum]:
    getExpType(KL:KLabel(T1:Type,, T2:Type)) => normalizeType(T1,T2)
when
    isBinaryNum(KL)

rule [getExpTypeShiftOp]:
    getExpType(KL:KLabel(T:Type,, _)) => normalizeType(T)
when
    isShiftOp(KL)

syntax K ::= "isNumToNum" "(" KLabel ")"        [function]

rule isNumToNum(KL:KLabel) =>
         KL ==KLabel 'PostIncr
  orBool KL ==KLabel 'PostDecr
  orBool KL ==KLabel 'PreIncr
  orBool KL ==KLabel 'PreDecr
  orBool KL ==KLabel 'Complement
  orBool isBinaryNum(KL)
  orBool isShiftOp(KL)                         [anywhere]

syntax K ::= "isBinaryNum" "(" KLabel ")"      [function]

rule isBinaryNum(KL:KLabel) =>
         KL ==KLabel 'Plus
  orBool KL ==KLabel 'Minus
  orBool KL ==KLabel 'Mul
  orBool KL ==KLabel 'Div
  orBool KL ==KLabel 'Remain                    [anywhere]

syntax K ::= "isShiftOp" "(" KLabel ")"         [function]

rule isShiftOp(KL:KLabel) =>
         KL ==KLabel 'LeftShift
  orBool KL ==KLabel 'RightShift
  orBool KL ==KLabel 'URightShift               [anywhere]

rule [getExpTypeBooleanOnly]:
    getExpType(KL:KLabel(_)) => bool
when
    isAnyToBool(KL)

syntax K ::= "isAnyToBool" "(" KLabel ")"     [function]

rule isAnyToBool(KL:KLabel) =>
         KL ==KLabel 'Not
  orBool KL ==KLabel 'LazyOr
  orBool KL ==KLabel 'LazyAnd
  orBool KL ==KLabel 'Eq
  orBool KL ==KLabel 'NotEq
  orBool KL ==KLabel 'Lt
  orBool KL ==KLabel 'Gt
  orBool KL ==KLabel 'LtEq
  orBool KL ==KLabel 'GtEq
  orBool KL ==KLabel 'InstanceOf                [anywhere]

rule [getExpTypeCastImpl]:
    getExpType(castImpl(TypeK:K, _)) => TypeK

//Custom HOLE used in the EXP-TYPE module.
syntax K ::= "EXPHOLE"

rule [ExpTypeCool]:
    (KR:K => .) ~> getExpType(_(_,,(EXPHOLE => KR),,_))
when
    isKResult(KR)                                       [structural]

//todo default hack rule, will be removed once all expression types will be properly covered
context getExpType(HOLE)
when
    notBool isCoveredExprTypeKLabel(getKLabel(HOLE))

syntax K ::= "isCoveredExprTypeKLabel" "(" KLabel ")"   [function]

rule isCoveredExprTypeKLabel(KL:KLabel) =>
         KL ==KLabel '_::_
  orBool KL ==KLabel 'NewInstance
  orBool KL ==KLabel 'newArrayImpl`(_`,_`,_`)
  orBool KL ==KLabel 'ExprName
  orBool KL ==KLabel 'ArrayAccess
  orBool isNumToNum(KL)
  orBool isAnyToBool(KL)
  orBool KL ==KLabel 'castImpl`(_`,_`)                  [anywhere]

endmodule
