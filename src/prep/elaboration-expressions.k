module ELABORATION-EXPRESSIONS
    imports CORE-SORTS
    imports CORE-CLASSES
    imports ELABORATION-CORE
    imports PRIMITIVE-TYPES

/*@ \subsection{Elaboration of numeric expressions}

Expression labels are not converted by the default rule in the phase elabDispose() => elabRes(...)
  Each expression needs a specialized rule for disposing, that will compute, among others,
  the type of the expression.
*/

syntax KItem ::= isBoolResultBinaryExpLabel ( KLabel )  [function]
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

//rule [elabEnd-PrefixPostfix]:
//    elabEnd(KL:KLabel(cast(T1:Type, Exp1:K))) => elabRes(cast(T1, KL(Exp1)))
//when
//    isPrefixPostfixExp(KL(.KList)) ==K true
rule elabEnd((++cast(T1:Type, Exp1:K)):PrefixPostfixExp) => elabRes(cast(T1, ++Exp1))
rule elabEnd((--cast(T1:Type, Exp1:K)):PrefixPostfixExp) => elabRes(cast(T1, --Exp1))
rule elabEnd(cast(T1:Type, Exp1:K)++) => elabRes(cast(T1, Exp1++))
rule elabEnd(cast(T1:Type, Exp1:K)--) => elabRes(cast(T1, Exp1--))

rule [elabEnd-StringPlusAny]:
    elabEnd('Plus(TE1:K,, TE2:K)) => elabRes(cast(classString,'Plus(TE1,, TE2)))
when
    typeOf(TE1) ==K classString orBool typeOf(TE2) ==K classString

rule [elabEnd-Cond]:
    elabEnd('Cond(CondTE:K,, TE1:K,, TE2:K))
    => elabExpAndType('Cond(CondTE,, TE1,, TE2), condType(typeOf(TE1), typeOf(TE2)))

/*@ Computes the type of a conditional expression.
    Operands evaluate into types.
*/
syntax KItem ::= condType ( Type, Type ) [strict]

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
syntax KItem ::= elabExpAndType ( K, K )  [strict(2)]
rule elabExpAndType(K:K, T:Type) => elabRes(cast(T, K))

rule [elabEnd-Assign-SameType]:
    elabEnd('Assign(cast(T1:Type, Exp1:K),, TExp2:K)) => elabRes(cast(T1, 'Assign(Exp1,, TExp2)))
when
    T1 ==K typeOf(TExp2)

rule [elabEnd-Assign-DiffType]:
    elabEnd('Assign( cast(T1:Type, Exp1:K),, (TE2:K => cast(T1, TE2)) ))
when
    T1 =/=K typeOf(TE2)

//rule [elabEnd-CompoundAssign]:
//    elabEnd(KL:KLabel(cast(T1:Type, Exp1:K),, TE2:K)) => elabRes(cast(T1, KL(Exp1,, TE2)))
//when
//    isCompoundAssignExp(KL(.KList)) ==K true
rule elabEnd(cast(T1:Type, Exp1:K) *= TE2:K) => elabRes(cast(T1, Exp1 *= TE2))
rule elabEnd(cast(T1:Type, Exp1:K) /= TE2:K) => elabRes(cast(T1, Exp1 /= TE2))
rule elabEnd(cast(T1:Type, Exp1:K) %= TE2:K) => elabRes(cast(T1, Exp1 %= TE2))
rule elabEnd(cast(T1:Type, Exp1:K) += TE2:K) => elabRes(cast(T1, Exp1 += TE2))
rule elabEnd(cast(T1:Type, Exp1:K) -= TE2:K) => elabRes(cast(T1, Exp1 -= TE2))
rule elabEnd(cast(T1:Type, Exp1:K) <<= TE2:K) => elabRes(cast(T1, Exp1 <<= TE2))
rule elabEnd(cast(T1:Type, Exp1:K) >>= TE2:K) => elabRes(cast(T1, Exp1 >>= TE2))
rule elabEnd(cast(T1:Type, Exp1:K) >>>= TE2:K) => elabRes(cast(T1, Exp1 >>>= TE2))
rule elabEnd(cast(T1:Type, Exp1:K) &= TE2:K) => elabRes(cast(T1, Exp1 &= TE2))
rule elabEnd(cast(T1:Type, Exp1:K) ^= TE2:K) => elabRes(cast(T1, Exp1 ^= TE2))
rule elabEnd(cast(T1:Type, Exp1:K) |= TE2:K) => elabRes(cast(T1, Exp1 |= TE2))

/*@ \subsection{Elaboration of non-numeric expressions} */

syntax KLabel ::= "'CastPrim"
                | "'CastRef"
//@ elab cast
rule elabEnd('CastPrim(T:Type,, TExp:K) => cast(T, TExp))      [structural]
rule elabEnd('CastRef(T:Type,, TExp:K)  => cast(T, TExp))      [structural]

rule [elabEnd-cast]:
    elabEnd(cast(T1:Type, TExp:K)) => elabRes(cast(T1, TExp))

/*@ \subsubsection{Elaboration of class instanceof} */

rule [elabEnd-InstanceOf]:
    elabEnd('InstanceOf(TExp:K,, RT2:RefType)) => elabRes(cast(bool, 'InstanceOf(TExp,, RT2)))

/*@ \subsubsection{Elaboration of class literals} */

//@ Class literal types are heated by this rule.
context elab('Lit('Class(HOLE)))

rule [elab-Lit-Class]:
    elab('Lit('Class(T:Type))) => elabRes(cast(class String2Id("java.lang.Class"), 'Lit('Class(T:Type))))

endmodule
