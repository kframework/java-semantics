module CLASS-SYNTAX
    imports EXP-SYNTAX

//@ \subsection{ClassDeclarations.sdf}
syntax ClassDecHead ::=
    AnnoClassModList "class" Id OptionalTypeParams OptionalSuper OptionalInterfaces
                                                                        [klabel('ClassDecHead)]
syntax ClassBody ::= "{" ClassBodyDecList "}"                           [klabel('ClassBody)]

syntax ClassDec ::= ClassDecHead ClassBody                              [klabel('ClassDec)]
syntax ClassDec ::= EnumDec

syntax ClassMod ::= Public
                  | Private
                  | Protected
                  | Abstract
                  | Final
                  | Static
                  | StrictFP

syntax Anno

syntax AnnoClassMod ::= Anno | ClassMod

syntax Super ::= "extends" JavaClassType                                [klabel('SuperDec)]

syntax Interfaces ::= "implements" InterfaceTypeList                    [klabel('ImplementsDec)]

syntax ClassBodyDec ::= InstanceInit | StaticInit | ClassMemberDec | ConstrDec

syntax ClassMemberDec ::= FieldDec | ClassDec | MethodDec | InterfaceDec | SemiColon

syntax InterfaceDec

syntax SemiColon ::= ";"                                                [klabel('SemiColon)]

//@ \subsection{ConstructorDeclarations.sdf}
syntax ConstrHead ::=
    AnnoConstrModList OptionalTypeParams Id "(" Params ")" OptionalThrows
                                                                        [klabel('ConstrDecHead)]
syntax ConstrBody ::= "{" OptionalConstrInv BlockStmList "}"            [klabel('ConstrBody)]

syntax ConstrDec ::= ConstrHead ConstrBody                              [klabel('ConstrDec)]

syntax ConstrInv ::= OptionalTypeArgs "this"  "(" Exps ")" ";"          [klabel('AltConstrInv)]
syntax ConstrInv ::= OptionalTypeArgs "super"  "(" Exps ")" ";"         [klabel('SuperConstrInv)]
syntax ConstrInv ::= Exp "." OptionalTypeArgs "super"  "(" Exps ")" ";" [klabel('QSuperConstrInv)]

syntax ConstrMod ::= Public
                   | Private
                   | Protected

syntax AnnoConstrMod ::= Anno | ConstrMod


//@ \subsection{EnumDeclarations.sdf}
syntax EnumDecHead ::= AnnoClassModList "enum" Id OptionalInterfaces    [klabel('EnumDecHead)]
/*
Java allows , at the end of List.
This makes copy-pasting easier, especially with one element per line.
*/
syntax EnumBody ::= "{" EnumConstList OptionalEnumBodyDecs"}"           [klabel('EnumBody)]
                  | "{" EnumConstList "," OptionalEnumBodyDecs "}"      [klabel('EnumBody)]

syntax EnumDec ::= EnumDecHead EnumBody                                 [klabel('EnumDec)]

syntax EnumConst ::= Id OptionalEnumConstArgs OptionalClassBody         [klabel('EnumConst)]

syntax EnumConstArgs ::= "(" Exps ")"                                   [bracket]

syntax EnumBodyDecs ::= ";" ClassBodyDecList                            [klabel('EnumBodyDecs)]


//@ \subsection{FieldDeclarations.sdf}
syntax FieldDec ::= AnnoFieldModList Type VarDecList ";"                [klabel('FieldDec)]

syntax VarDec ::= VarDecId                                              [klabel('VarDec)]
                | VarDecId "=" VarInit                                  [klabel('VarDec)]

syntax VarDecId ::= Id | Id Dims                                        [klabel('ArrayVarDecId)]

syntax VarInit ::= Exp | ArrayInit

syntax FieldMod ::= Public
                  | Private
                  | Protected
                  | Final
                  | Static
                  | Transient
                  | Volatile

syntax AnnoFieldMod ::= Anno | FieldMod


//@ \subsection{MethodDeclarations.sdf}
syntax MethodDecHead ::=
    AnnoMethodModList OptionalTypeParams Type Id "(" Params ")" OptionalThrows
                                                                        [klabel('MethodDecHead)]
syntax MethodBody ::= Block | ";"                                       [klabel('NoMethodBody)]
syntax MethodDec ::= MethodDecHead MethodBody                           [klabel('MethodDec)]

syntax Param ::= AnnoVarModList Type VarDecId                           [strict(2), klabel('Param)]
syntax Param ::= AnnoVarModList Type "..." VarDecId                     [klabel('VarArityParam)]

syntax Throws ::= "throws" ExceptionTypeList                            [klabel('ThrowsDec)]

syntax ExceptionType ::= JavaClassType

syntax MethodMod ::= Public
                   | Private
                   | Protected
                   | Abstract
                   | Final
                   | Static
                   | Native
                   | Synchronized
                   | StrictFP

syntax AnnoMethodMod ::= Anno | MethodMod

syntax VarMod ::= Final

syntax AnnoVarMod ::= Anno | VarMod


//@ \subsection{InstanceInitializers.sdf}
syntax InstanceInit ::= Block                                           [klabel('InstanceInit)]


//@ \subsection{StaticInitializers.sdf}
syntax StaticInit ::= "static" Block                                    [klabel('StaticInit)]
syntax Block

endmodule