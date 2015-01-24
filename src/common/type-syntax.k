require "core-sorts.k"
require "name-syntax.k"
require "list-syntax.k"
module TYPE-SYNTAX
    imports CORE-SORTS
    imports NAME-SYNTAX
    imports LIST-SYNTAX
//@ \subsection{Main.sdf}
syntax Type ::= PrimType
              | RefType
/*Denis' syntax: actually in sdf "void" together with Type composed ResultType,
since now "void" is Type, there is no need for another syntax of ResultType.*/
              | "void" [klabel('Void)]

//@ \subsection{ParameterizedTypes.sdf}
syntax TypeArgs ::= "<" ActualTypeArgList ">"        [klabel('TypeArgs)]
syntax ActualTypeArg ::= Type
                        | "?" OptionalWildcardBound    [klabel('Wildcard)]

syntax WildcardBound ::= "extends" RefType [klabel('WildcardUpperBound)]
                        |"super"   RefType [klabel('WildcardLowerBound)]

//@ \subsection{PrimitiveTypes.sdf}
syntax IntOrLongType ::= "int" [klabel('Int)] | "long" [klabel('Long)]
syntax IntType ::= "byte" [klabel('Byte)]| "short" [klabel('Short)]| IntOrLongType | "char" [klabel('Char)]
syntax FloatType ::= "float" [klabel('Float)] | "double" [klabel('Double)]

//NumType in sdf
syntax NumericType ::= IntType | FloatType
syntax PrimType ::= NumericType | "bool" [klabel('Boolean)] //"boolean" in sdf

//@ \subsection{ReferenceTypes.sdf}
    /*@ A fully qualified class name, or noClass where no valid class could be computed.*/
syntax ClassOrInterfaceType ::= TypeDecSpec [klabel('ClassOrInterfaceType)]
                              | TypeDecSpec TypeArgs [prefer, klabel('ClassOrInterfaceType)]
syntax InterfaceType ::= TypeDecSpec [klabel('InterfaceType)]
                       | TypeDecSpec TypeArgs [prefer, klabel('InterfaceType)]
syntax ClassType ::= TypeDecSpec [klabel('ClassType)]
                   | TypeDecSpec TypeArgs [prefer, klabel('ClassType)]

//Denis' syntax (I made ClassType a sub of ClassOrInterfaceType for simplicity of other syntax definitions)
syntax ClassOrInterfaceType ::= ClassType
syntax ClassType ::= "class" Id
                   | "noClass"        [latex({\dotCt{K}})]

syntax TypeDecSpec ::= TypeName
                     | TypeDecSpec TypeArgs "." Id [klabel('Member)]

syntax TypeVar ::= TypeVarId   [klabel('TypeVar)]

syntax ArrayType ::= Type "[" "]"   [strict, klabel('ArrayType)] | "arrayOf" Type
//The sdf syntax (left) is different from Denis' syntax (right), so added anywhere rule here
rule 'ArrayType(T:Type) => arrayOf T     [anywhere]

syntax RefType ::= ClassOrInterfaceType | ArrayType

/* Denis' syntax: A reference type is either a class type, an array type, the null type or a String type. The null type is specified
        by the JLS although inaccessible to the programmer. String objects and types are not threated as regular objects
        in the present semantics for performance reasons.
*/
syntax RefType ::= "nullType"

//@ \subsection{TypeVariables.sdf}
syntax TypeVarId ::= Id
syntax TypeBound ::= "extends" ClassOrInterfaceTypeList     [klabel('TypeBound)]
syntax TypeParam ::= TypeVarId OptionalTypeBound           [klabel('TypeParam)]
syntax TypeParams ::= "<" TypeParamList ">"        [klabel('TypeParams)]

endmodule