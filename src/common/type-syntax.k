module TYPE-SYNTAX
    imports NAME-SYNTAX
    imports OPTIONAL-SYNTAX

//@ \subsection{Main.sdf}
syntax Type ::= PrimType
              | RefType
/*Denis' syntax: actually in sdf "void" together with Type compose ResultType,
since now "void" is Type, there is no need for another syntax of ResultType.*/
              | "void"                                  [klabel('Void)]

//@ \subsection{ParameterizedTypes.sdf}
syntax TypeArgs ::= "<" ActualTypeArgList ">"           [klabel('TypeArgs)]

syntax ActualTypeArg ::= Type
                       | "?" OptionalWildcardBound      [klabel('Wildcard)]

syntax WildcardBound ::= "extends" RefType              [klabel('WildcardUpperBound)]
                       | "super"   RefType              [klabel('WildcardLowerBound)]


//@ \subsection{PrimitiveTypes.sdf}
syntax IntOrLongType ::= "int"                          [klabel('Int)]
                       | "long"                         [klabel('Long)]
syntax IntType ::= "byte"                               [klabel('Byte)]
                 | "short"                              [klabel('Short)]
                 | "char"                               [klabel('Char)]
                 | IntOrLongType

syntax FloatType ::= "float"                            [klabel('Float)]
                   | "double"                           [klabel('Double)]
//sdf NumType
syntax NumericType ::= IntType | FloatType
syntax PrimType ::= NumericType | "bool"                [klabel('Boolean)] //sdf "boolean"


//@ \subsection{ReferenceTypes.sdf}
    /*@ A fully qualified class name, or noClass where no valid class could be computed.*/
syntax ClassOrInterfaceType ::= TypeDecSpec OptionalTypeArgs    [klabel('ClassOrInterfaceType)]

syntax InterfaceType ::= TypeDecSpec OptionalTypeArgs           [klabel('InterfaceType)]
//sdf ClassType, use another name JavaClassType to avoid conflict with Denis' ClassType syntax
syntax JavaClassType ::= TypeDecSpec OptionalTypeArgs           [klabel('ClassType)]

syntax TypeDecSpec ::= TypeName | TypeDecSpec TypeArgs "." Id   [klabel('Member)]

syntax TypeVar ::= TypeVarId                                    [klabel('TypeVar)]

syntax ArrayType ::= Type "[" "]"                               [strict, klabel('ArrayType)]

syntax RefType ::= ClassOrInterfaceType | ArrayType


//@ \subsection{TypeVariables.sdf}
syntax TypeVarId ::= Id

syntax TypeBound ::= "extends" ClassOrInterfaceTypeList         [klabel('TypeBound)]

syntax TypeParam ::= TypeVarId OptionalTypeBound                [klabel('TypeParam)]
syntax TypeParams ::= "<" TypeParamList ">"                     [klabel('TypeParams)]

endmodule