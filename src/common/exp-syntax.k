module EXP-SYNTAX
    imports TYPE-SYNTAX

syntax Exp ::= StmtExp
syntax StmtExp ::= PrefixPostfixExp | AssignExp | MethodInvokeExp | ClassInstanceCreationExp

//@ \paragraph{MethodInvocation}
syntax MethodInvokeExp ::= MethodSpec "(" Exps ")"                      [klabel('Invoke)]
syntax MethodSpec ::= MethodName                                        [klabel('Method)]
                    | Exp "." OptionalTypeArgs Id                       [klabel('Method)]
                    | "super" "." OptionalTypeArgs Id                   [klabel('SuperMethod)]
                    | TypeName "." "super" "." OptionalTypeArgs Id      [klabel('QSuperMethod)]
                    | AmbName "." TypeArgs Id                           [klabel('GenericMethod)]


//@ \paragraph{ClassInstanceCreation}
syntax ClassInstanceCreationExp ::=
    "new" OptionalTypeArgs ClassOrInterfaceType "(" Exps ")" OptionalClassBody
                                                                        [klabel('NewInstance)]
syntax ClassInstanceCreationExp ::=
    Exp "." "new" OptionalTypeArgs Id OptionalTypeArgs "(" Exps ")" OptionalClassBody
                                                                        [klabel('QNewInstance)]


//@ \paragraph{AssignmentOperators}
syntax LHS ::= ExprName | FieldAccess | ArrayAccess
syntax Exp ::= LHS

syntax AssignExp ::= LHS "=" Exp                                       [klabel('Assign)]
syntax AssignExp ::= CompoundAssignExp

syntax CompoundAssignExp ::=  LHS "*=" Exp                             [klabel('AssignMul)]
                            | LHS "/=" Exp                             [klabel('AssignDiv)]
                            | LHS "%=" Exp                             [klabel('AssignRemain)]
                            | LHS "+=" Exp                             [klabel('AssignPlus)]
                            | LHS "-=" Exp                             [klabel('AssignMinus)]
                            | LHS "<<=" Exp                            [klabel('AssignLeftShift)]
                            | LHS ">>=" Exp                            [klabel('AssignRightShift)]
                            | LHS ">>>=" Exp                           [klabel('AssignURightShift)]
                            | LHS "&=" Exp                             [klabel('AssignAnd)]
                            | LHS "^=" Exp                             [klabel('AssignExcOr)]
                            | LHS "|=" Exp                             [klabel('AssignOr)]


//@ \paragraph{UnaryOperators}
syntax Exp ::= "(" PrimType ")" Exp                                    [klabel('CastPrim)]
syntax Exp ::= "(" RefType ")" Exp                                     [klabel('CastRef)]

syntax Exp ::= "~" Exp      [strict, klabel('Complement)]
             | "!" Exp      [strict, klabel('Not)]
             | "+" Exp      [strict, klabel('Plus)]
             | "-" Exp      [strict, klabel('Minus)]

syntax PrefixPostfixExp ::= "++" Exp    [klabel('PreIncr)]
                          | "--" Exp    [klabel('PreDecr)]


//@ \paragraph{Postfix}
syntax PrefixPostfixExp ::= Exp "++"    [klabel('PostIncr)]
                          | Exp "--"    [klabel('PostDecr)]


//@ \paragraph{BinaryOperators}
syntax Exp ::= Exp "*" Exp      [seqstrict, klabel('Mul)]
		     | Exp "/" Exp      [seqstrict, klabel('Div)]
		     | Exp "%" Exp      [seqstrict, klabel('Remain)]
		     > Exp "+" Exp      [seqstrict, klabel('Plus)]
 		     | Exp "-" Exp      [seqstrict, klabel('Minus)]

syntax Exp ::= Exp "<<" Exp     [seqstrict, klabel('LeftShift)]
             | Exp ">>" Exp     [seqstrict, klabel('RightShift)]
             | Exp ">>>" Exp    [seqstrict, klabel('URightShift)]

syntax Exp ::= Exp ">" Exp      [seqstrict, klabel('Gt)]
syntax Exp ::= Exp "<" Exp      [seqstrict, klabel('Lt)]
syntax Exp ::= Exp ">=" Exp     [seqstrict, klabel('GtEq)]

syntax Exp ::= Exp "||" Exp     [strict(1), klabel('LazyOr)]
             | Exp "&&" Exp     [strict(1), klabel('LazyAnd)]
             | Exp "|" Exp      [seqstrict, klabel('Or)]
             | Exp "^" Exp      [seqstrict, klabel('ExcOr)]
             | Exp "&" Exp      [seqstrict, klabel('And)]

syntax Exp ::= Exp "?" Exp ":" Exp                      [klabel('Cond)]

syntax Exp ::= Exp "instanceof" RefType                 [strict, klabel('InstanceOf)]


//@ \paragraph{FieldAccess}
syntax FieldAccess ::= Exp "." Id                       [klabel('Field)]
                     | "super" "." Id                   [klabel('SuperField)]
                     | TypeName "." "super" "." Id      [klabel('QSuperField)]


//@ \paragraph{ArrayAccess}
//syntax ArraySubscript ::= "[" Exp "]"                 [bracket]
syntax ArrayAccess ::= Exp "[" Exp "]"                  [seqstrict, klabel('ArrayAccess)]


//@ \paragraph{ArrayCreation}
/*  Either 'NewArray( T:ElemType,, ['Dim(N1),,'Dim('N2),, ...],, [...,, 'Dim(.KList),, ...] )
    Or     'NewArray( T:ElemType,, [...,, 'Dim(.KList),, ...],, 'ArrayInit(_) )
*/
syntax Exp ::= ArrayCreationExp
//todo:cannot put ArrayBaseType instead of Type below, because rules and aux functions use Type
syntax ArrayCreationExp ::= "new" Type DimExps Dims                 [strict(2), klabel('NewArray)]
syntax ArrayCreationExp ::= "new" Type Dims ArrayInit               [klabel('NewArray)]


syntax ArrayBaseType ::= PrimType
                       | TypeName
                       | TypeName "<" "?" ">"                       [klabel('UnboundWld)]

syntax Dim ::= "[" "]"                                              [klabel('Dim)]
syntax DimExp ::= "[" Exp "]"                                       [strict, hybrid, klabel('Dim)]


//@ \paragraph{ArrayInitializers}
syntax ArrayInit ::= "{" VarInits "}" [klabel('ArrayInit)]
syntax ArrayInit ::= "{" VarInits "," "}" [klabel('ArrayInit)]


//@ \paragraph{Primary}
syntax Exp ::= Literal                                              [klabel('Lit)]
syntax Literal ::= IntLiteral
                 | FloatLiteral
                 | BoolLiteral
                 | CharLiteral
                 | StringLiteral
                 | NullLiteral
                 | ClassLiteral

syntax ClassLiteral ::= Type "." "class"                            [klabel('Class)]
                      | "void" "." "class"                          [klabel('VoidClass)]

syntax Exp ::= "this"                                               [klabel('This)]
             | TypeName "." "this"                                  [klabel('QThis)]

syntax Exp ::= "(" Exp ")"                                          [bracket]

/*previously defined elsewhere for ltl-support, now these syntax are also used for Java,
although we don't incorporate ltl for now, let's keep this independent like this
*/
syntax Exp ::= Exp "<=" Exp [seqstrict, klabel('LtEq)]
		     | Exp "==" Exp [seqstrict, klabel('Eq)]
		     | Exp "!=" Exp [klabel('NotEq)]

endmodule
