require "core-sorts.k"
module TYPE-SYNTAX
    imports CORE-SORTS
//@ \subsection{Main.sdf}
syntax Type ::= PrimitiveType //PrimType in sdf
              | RefType
              | "void" [klabel('Void)]

//@ \subsection{ParameterizedTypes.sdf} todo
syntax TypeArgs ::= "<" ActualTypeArgList ">"        [klabel('TypeArgs)]
syntax ActualTypeArg ::= Type | "?" WildcardBound    [klabel('Wildcard)]
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
syntax ClassType ::= "class" Id
                       | "noClass"        [latex({\dotCt{K}})]

    /* A reference type is either a class type, an array type, the null type or a String type. The null type is specified
        by the JLS although inaccessible to the programmer. String objects and types are not threated as regular objects
        in the present semantics for performance reasons.
    */
syntax RefType ::= ClassType
                     | "arrayOf" Type
                     | "nullType"

//@ \subsection{TypeVariables.sdf} todo

endmodule