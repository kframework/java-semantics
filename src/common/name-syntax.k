module NAME-SYNTAX
    imports LITERAL-SYNTAX

syntax PackageName ::= IdList                           [klabel('PackageName)]

syntax AmbName ::= Id                                   [klabel('AmbName)]
                 | AmbName "." Id                       [klabel('AmbName)]

syntax PackageOrTypeName ::= Id                         [klabel('PackageOrTypeName)]
                           | PackageOrTypeName "." Id   [strict(1), klabel('PackageOrTypeName)]

syntax ExprName::= Id                                   [klabel('ExprName)]
                 | AmbName "." Id                       [klabel('ExprName)]

syntax TypeName ::= Id                                  [klabel('TypeName)]
                  | PackageOrTypeName "." Id            [strict(1), klabel('TypeName)]

syntax MethodName ::= Id                                [klabel('MethodName)]
                    | AmbName "." Id                    [klabel('MethodName)]

endmodule