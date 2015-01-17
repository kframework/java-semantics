require "core-sorts.k"
require "core-classes.k"
require "shared-syntax.k"

module EXP-SYNTAX
    imports CORE-SORTS
    imports CORE-CLASSES
    imports SHARED-SYNTAX

syntax Exp ::= StmtExp
syntax Exps ::= List{Exp, ","} [seqstrict]

//cannot use this either
//syntax MethodInvokeExp ::= MethodSpec "(" KListWrap ")" [klabel('Invoke)]
//syntax MethodSpec ::= MethodName [klabel('Method)]
//                    |Exp "." K Id [klabel('Method)]
//                    |"super" "." K Id [klabel('SuperMethod)]
//                    |TypeName "." "super" "." K Id [klabel('QSuperMethod)]
//                    |AmbName "." K Id [klabel('GenericMethod)]

syntax MethodName ::= Id | MethodRef
syntax MethodInvokeExp ::= K "." MethodName "(" Exps ")"       [seqstrict(1,3), klabel('MethodImpl)]


syntax ClassOrName ::= Id | ClassType
syntax ClassInstanceCreationExp ::= "new" ClassType "(" Exps ")" [klabel('NewInstance)]
                                   | Exp "." "new" ClassOrName "(" Exps ")"     [seqstrict(1,3), klabel('QNewInstance)]

syntax StmtExp ::= PrefixPostfixExp|AssignExp|MethodInvokeExp|ClassInstanceCreationExp





//todo: change to LHS?
syntax AssignExp ::= K "=" Exp [klabel('Assign)]
syntax AssignExp ::= CompoundAssignExp
syntax CompoundAssignExp ::= "dummyCompoundAssignExp"
                            | Exp "*=" Exp [klabel('AssignMul)]
                            | Exp "/=" Exp [klabel('AssignDiv)]
                            | Exp "%=" Exp [klabel('AssignRemain)]
                            | Exp "+=" Exp [klabel('AssignPlus)]
                            | Exp "-=" Exp [klabel('AssignMinus)]
                            | Exp "<<=" Exp [klabel('AssignLeftShift)]
                            | Exp ">>=" Exp [klabel('AssignRightShift)]
                            | Exp ">>>=" Exp [klabel('AssignURightShift)]
                            | Exp "&=" Exp [klabel('AssignAnd)]
                            | Exp "^=" Exp [klabel('AssignExcOr)]
                            | Exp "|=" Exp [klabel('AssignOr)]

//@ \subsection{UnaryOperators.sdf}
syntax Exp ::= "~" Exp [strict, klabel('Complement)]
             | "!" Exp [strict, klabel('Not)]
             | "+" Exp [strict, klabel('Plus)]
             | "-" Exp [strict, klabel('Minus)]

//@ Operators with side effects - prefix, postfix ++/--
syntax PrefixPostfixExp ::= "dummyPrefixPostfixExp"
syntax PrefixPostfixExp ::=
		  Exp "++" [klabel('PostIncr)]
		| Exp "--" [klabel('PostDecr)]
		> "++" Exp [klabel('PreIncr)]
        | "--" Exp [klabel('PreDecr)]

syntax Exp ::= "(" PrimType ")" [klabel('CastPrim)]
syntax Exp ::= "(" RefType ")"  [klabel('CastRef)]
//@ \subsection{BinaryOperators.sdf}
syntax Exp ::= Exp "*" Exp [seqstrict, klabel('Mul)]
		     | Exp "/" Exp [seqstrict, klabel('Div)]
		     | Exp "%" Exp [seqstrict, klabel('Remain)]
		     > Exp "+" Exp [seqstrict, klabel('Plus)]
 		     | Exp "-" Exp [seqstrict, klabel('Minus)]

syntax Exp ::= Exp "<<" Exp [seqstrict, klabel('LeftShift)]
              | Exp ">>" Exp [seqstrict, klabel('RightShift)]
              | Exp ">>>" Exp [seqstrict, klabel('URightShift)]

syntax Exp ::= Exp ">" Exp [seqstrict, klabel('Gt)]
syntax Exp ::= Exp "<" Exp [seqstrict, klabel('Lt)]
syntax Exp ::= Exp ">=" Exp [seqstrict, klabel('GtEq)]

syntax Exp ::= Exp "||" Exp [strict(1), klabel('LazyOr)]
             | Exp "&&" Exp [strict(1), klabel('LazyAnd)]
             | Exp "|" Exp [seqstrict, klabel('Or)]
             | Exp "^" Exp [seqstrict, klabel('ExcOr)]
             | Exp "&" Exp [seqstrict, klabel('And)]

syntax Exp ::= Exp "?" Exp ":" Exp [klabel('Cond)]
syntax Exp ::= Exp "instanceof" RefType [strict, klabel('InstanceOf)]

//@ \subsection{FieldAccess.sdf}
syntax Exp ::= FieldAccess
syntax FieldAccess ::= Exp "." Id [klabel('Field)]
                       |"super" "." Id [klabel('SuperField)]
//                       |TypeName "." "super" "." Id [klabel('QSuperField)]
//                        |ExprName "." Id [reject]

//TypeName cannot be properly defined, use K instead
syntax Exp ::= "this" [klabel('This)] | K "." "this" [klabel('QThis)]

//@ \subsection{ArrayAccess.sdf}
//syntax ArraySubscript ::= "[" Exp "]"   [bracket]
syntax ArrayAccess ::= Exp "[" Exp "]"    [seqstrict, klabel('ArrayAccess)]
syntax Exp ::= ArrayAccess

//@ \subsection{ArrayCreation.sdf}
/*  Either 'NewArray( T:ElemType,, ['Dim(N1),,'Dim('N2),, ...],, [...,, 'Dim(.KList),, ...] )
    Or     'NewArray( T:ElemType,, [...,, 'Dim(.KList),, ...],, 'ArrayInit(_) )
*/
//cannot put ArrayBaseType instead of Type below, because rules and aux functions use Type
syntax ArrayCreationExp ::= "new" Type DimExps Dims [strict(2), klabel('NewArray)]
syntax ArrayCreationExp ::= "new" Type Dims ArrayInit [klabel('NewArray)]
syntax Exp ::= ArrayCreationExp

syntax ArrayBaseType ::= PrimType
                       | TypeName
                       | TypeName "<" "?" ">" [klabel('UnboundWld)]

syntax Dim ::= "[" "]" [klabel('Dim)]
syntax DimExp ::= "[" Exp "]" [strict, hybrid, klabel('Dim)]

syntax Dims ::= List{Dim,""} // [klabel('DimList)]
syntax DimExps ::= List{DimExp,""} [strict]
endmodule
