//@ \section{Module LABELS-EXEC}

module LABELS-EXEC

/*@ Labels listed here are not used anywhere in the semantics. Some of them may still be produced by parsed programs
    in the test suite.
*/
syntax KLabel ::= "'GenericMethod"
                | "'UnboundWld"
                | "'VoidClass"
                | "'StaticImportDec"
                | "'StaticImportOnDemandDec"
                | "'AnnoDec"
                | "'AnnoDecHead"
                | "'AnnoMethodDec"
                | "'Semicolon"
                | "'DefaultVal"
                | "'DeprAbstractMethodDec"
                | "'EnumDec"
                | "'EnumDecHead"
                | "'EnumBody"
                | "'EnumConst"
                | "'EnumBodyDecs"
                | "'ForEach"
                | "'DeprMethodDecHead"
                | "'VarArityParam"
                | "'ThrowsDec"
                | "'Anno"
                | "'SingleElemAnno"
                | "'MarkerAnno"
                | "'ElemValPair"
                | "'ElemValArrayInit"
                | "'TypeArgs"
                | "'Wildcard"
                | "'WildcardUpperBound"
                | "'TypeParam"
                | "'TypeBound"
                | "'TypeParams"
                | "'Member"
                | "'TypeVar"
                | "'CompilationUnit"
                | "'String"
                | "'SuperDec"

endmodule
