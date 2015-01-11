require "core-sorts.k"
require "name-syntax.k"
require "list-syntax.k"
module TYPE-SYNTAX
    imports CORE-SORTS
    imports NAME-SYNTAX
    imports LIST-SYNTAX
//@ \subsection{Main.sdf}
syntax Type ::= PrimitiveType //PrimType in sdf
              | RefType
//Denis' syntax
              | "void" [klabel('Void)]

//@ \subsection{ParameterizedTypes.sdf}
syntax TypeArgs ::= "<" ActualTypeArgList ">"        [klabel('TypeArgs)]
syntax ActualTypeArg ::= Type
                        | "?" WildcardBound    [prefer, klabel('Wildcard)]
                        | "?"                  [klabel('Wildcard)]
syntax WildcardBound ::= "extends" RefType [klabel('WildcardUpperBound)]
                        |"super"   RefType [klabel('WildcardLowerBound)]

//@ \subsection{PrimitiveTypes.sdf}
syntax IntOrLongType ::= "int" [klabel('Int)] | "long" [klabel('Long)]
syntax IntType ::= "byte" [klabel('Byte)]| "short" [klabel('Short)]| IntOrLongType | "char" [klabel('Char)]
syntax FloatType ::= "float" [klabel('Float)] | "double" [klabel('Double)]

//NumType in sdf
syntax NumericType ::= IntType | FloatType
syntax PrimitiveType ::= NumericType | "bool" [klabel('Boolean)] //"boolean" in sdf

//@ \subsection{ReferenceTypes.sdf} todo
    /*@ A fully qualified class name, or noClass where no valid class could be computed.*/
syntax ClassOrInterfaceType ::= TypeDecSpec [klabel('ClassOrInterfaceType)]
                              | TypeDecSpec TypeArgs [prefer, klabel('ClassOrInterfaceType)]
syntax InterfaceType ::= TypeDecSpec [klabel('InterfaceType)]
                       | TypeDecSpec TypeArgs [prefer, klabel('InterfaceType)]
syntax ClassType ::= TypeDecSpec [klabel('ClassType)]
                   | TypeDecSpec TypeArgs [prefer, klabel('ClassType)]
//Denis' syntax
syntax ClassType ::= "class" Id
                   | "noClass"        [latex({\dotCt{K}})]

syntax TypeDecSpec ::= TypeName
                     | TypeDecSpec TypeArgs "." Id [klabel('Member)]

//syntax TypeVar ::= TypeVarId   [klabel('TypeVar)]

syntax ArrayType ::= Type "[" "]"   [klabel('ArrayType)]
//The above syntax is different from Denis' arrayType syntax, so added anywhere rule here
rule    (T:Type [])<:ArrayType => arrayOf T [anywhere]

syntax RefType ::= ClassOrInterfaceType | ArrayType

/* Denis' syntax: A reference type is either a class type, an array type, the null type or a String type. The null type is specified
        by the JLS although inaccessible to the programmer. String objects and types are not threated as regular objects
        in the present semantics for performance reasons.
*/
syntax RefType ::= ClassType
                 | "arrayOf" Type
                 | "nullType"

//@ \subsection{TypeVariables.sdf} todo
//syntax TypeVarId ::= Id
//syntax TypeBound ::= "extends" ClassOrInterfaceTypeList     [klabel('TypeBound)]
//syntax TypeParam ::= TypeVarId                     [klabel('TypeParam)]
//                   | TypeVarId TypeBound           [prefer, klabel('TypeParam)]
//syntax TypeParams ::= "<" TypeParamList ">"        [klabel('TypeParams)]

endmodule