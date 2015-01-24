module PACKAGE-SYNTAX
//@ \subsection{CompilationUnits.sdf}
syntax CompilationUnit ::= OptionalPackageDec ImportDecList TypeDecList [klabel('CompilationUnit)]

//@ \subsection{TypeDeclarations.sdf}
syntax TypeDec ::= ClassDec | InterfaceDec | SemiColon

//@ \subsection{ImportDeclarations.sdf}
syntax ImportDec ::= "import" TypeName                  ";"   [klabel('TypeImportDec)]
                   | "import" PackageName       "." "*" ";"  [klabel('TypeImportOnDemandDec)]
                   | "import" "static" TypeName "." Id  ";"  [klabel('StaticImportDec)]
                   | "import" "static" TypeName "." "*" ";"  [klabel('StaticImportOnDemandDec)]

//@ \subsection{PackageDeclarations.sdf}
syntax PackageDec ::= AnnoList "package" PackageName ";"  [klabel('PackageDec)]

endmodule