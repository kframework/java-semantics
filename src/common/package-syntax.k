module PACKAGE-SYNTAX
    imports CLASS-SYNTAX

syntax CompilationUnit ::= OptionalPackageDec ImportDecList TypeDecList  [klabel('CompilationUnit)]

syntax TypeDec ::= ClassDec | InterfaceDec | SemiColon

syntax ImportDec ::= "import" TypeName                  ";"  [klabel('TypeImportDec)]
                   | "import" PackageName       "." "*" ";"  [klabel('TypeImportOnDemandDec)]
                   | "import" "static" TypeName "." Id  ";"  [klabel('StaticImportDec)]
                   | "import" "static" TypeName "." "*" ";"  [klabel('StaticImportOnDemandDec)]

syntax PackageDec ::= AnnoList "package" PackageName ";"     [klabel('PackageDec)]

endmodule
