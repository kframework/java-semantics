module NAME-SYNTAX
imports LIST-SYNTAX
//todo: why does this pure syntax definition affect krun?
//PackageName, AmbName and PackageorTypeName syntax doesn't cause problems
                     syntax PackageName ::= IdList [klabel('PackageName)]
                     syntax AmbName ::= Id [klabel('AmbName)]
                                      | AmbName "." Id [klabel('AmbName)]
//                     syntax PackageOrTypeName ::= Id [klabel('PackageOrTypeName)]
//                                                | PackageOrTypeName "." Id [klabel('PackageOrTypeName)]

                     syntax MethodName ::= Id //[klabel('MethodName)]
//                                         | AmbName "." Id [klabel('MethodName)]
                     syntax ExprName::= Id  [klabel('ExprName)]
//                                      | AmbName "." Id [klabel('ExprName)]
                     syntax TypeName ::= Id [klabel('TypeName)]
//                                      | PackageOrTypeName "." Id [klabel('TypeName)]
endmodule