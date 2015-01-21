require "array-syntax.k"
require "exp-syntax.k"
module CLASS-SYNTAX
imports ARRAY-SYNTAX
imports EXP-SYNTAX
//@ \subsection{ClassDeclarations.sdf}
syntax ClassDec ::= ClassDecHead ClassBody [klabel('ClassDec)]
syntax ClassDec ::= EnumDec

syntax ClassBody ::= "{" ClassBodyDecList "}" [klabel('ClassBody)]
//todo optionals
syntax ClassDecHead ::= AnnoClassModList "class" Id TypeParams Super Interfaces [prefer, klabel('ClassDecHead)]

syntax ClassMod ::= Public
                  | Private
                  | Protected
                  | Abstract
                  | Final
                  | Static
                  | StrictFP
syntax AnnoClassMod ::= Anno | ClassMod

syntax Super ::= "extends" ClassType                    [klabel('SuperDec)]
syntax Interfaces ::= "implements" InterfaceTypeList    [klabel('ImplementsDec)]

syntax ClassBodyDec ::= InstanceInit | StaticInit | ClassMemberDec | ConstrDec

syntax ClassMemberDec ::= FieldDec | ClassDec | MethodDec | InterfaceDec | SemiColon

syntax SemiColon ::= ";" [klabel('SemiColon)]

//@ \subsection{ConstructorDeclarations.sdf}
//todo optionals
syntax ConstrHead   ::=  AnnoConstrModList TypeParams Type Id "(" Params ")" Throws [prefer, klabel('ConstrDecHead)]
                       | AnnoConstrModList TypeParams Type Id "(" Params ")"    [klabel('ConstrDecHead)]
                       | AnnoConstrModList Type Id "(" Params ")" Throws   [klabel('ConstrDecHead)]
                       | AnnoConstrModList Type Id "(" Params ")"    [klabel('ConstrDecHead)]

syntax ConstrDec ::= ConstrHead ConstrBody                    [klabel('ConstrDec)]
syntax ConstrBody ::= "{" ConstrInv BlockStmList "}"          [prefer, klabel('ConstrBody)]
                    | "{" BlockStmList "}"                    [klabel('ConstrBody)]

syntax ConstrInv ::= TypeArgs "this"  "(" Exps ")" ";"        [prefer, klabel('AltConstrInv)]
syntax ConstrInv ::= "this"  "(" Exps ")" ";"                 [klabel('AltConstrInv)]
syntax ConstrInv ::= TypeArgs "super"  "(" Exps ")" ";"       [prefer, klabel('SuperConstrInv)]
syntax ConstrInv ::= "super"  "(" Exps ")" ";"                [klabel('SuperConstrInv)]
syntax ConstrInv ::= Exp "." TypeArgs "super"  "(" Exps ")" ";" [prefer, klabel('QSuperConstrInv)]
syntax ConstrInv ::= Exp "." "super"  "(" Exps ")" ";"          [klabel('QSuperConstrInv)]

syntax ConstrMod ::= Public
                  | Private
                  | Protected
syntax AnnoConstrMod ::= Anno | ConstrMod

//@ \subsection{EnumDeclarations.sdf}
syntax EnumDecHead ::= AnnoClassModList "enum" Id Interfaces [prefer, klabel('EnumDecHead)]
                     | AnnoClassModList "enum" Id            [klabel('EnumDecHead)]

syntax EnumDec ::= EnumDecHead EnumBody                     [klabel('EnumDec)]

syntax EnumBody ::= "{" EnumConstList EnumBodyDecs"}"       [prefer, klabel('EnumBody)]
                  | "{" EnumConstList "}"                   [klabel('EnumBody)]
                  | "{" EnumConstList "," EnumBodyDecs "}"  [prefer, klabel('EnumBody)]
                  | "{" EnumConstList "," "}"               [klabel('EnumBody)]
//todo optionals
syntax EnumConst ::= Id EnumConstArgs ClassBody [prefer, klabel('EnumConst)]

syntax EnumConstArgs ::= "(" Exps ")"           [bracket]

syntax EnumBodyDecs ::= ";" ClassBodyDecList    [klabel('EnumBodyDecs)]

//@ \subsection{FieldDeclarations.sdf}
syntax FieldDec ::= AnnoFieldModList Type VarDecList ";"    [klabel('FieldDec)]

syntax VarDec ::= VarDecId                [klabel('VarDec)]
               // | VarDecId "=" VarInit    [klabel('VarDec)]

syntax VarDecId ::= Id | Id Dims          [klabel('ArrayVarDecId)]

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
syntax Param ::= AnnoVarModList Type VarDecId           [klabel('Param)]
syntax Param ::= AnnoVarModList Type "..." VarDecId     [klabel('VarArityParam)]

syntax Throws ::= "throws" ExceptionTypeList
syntax ExceptionType ::= ClassType
syntax MethodBody ::= Block | ";" [klabel('NoMethodBody)]
//todo optionals
syntax MethodDecHead ::= AnnoMethodModList TypeParams Type Id "(" Params ")" Throws [prefer, klabel('MethodDecHead)]
                       | AnnoMethodModList TypeParams Type Id "(" Params ")"    [klabel('MethodDecHead)]
                       | AnnoMethodModList Type Id "(" Params ")" Throws   [klabel('MethodDecHead)]
                       | AnnoMethodModList Type Id "(" Params ")"    [klabel('MethodDecHead)]

syntax MethodDec ::= MethodDecHead MethodBody [klabel('MethodDec)]

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
syntax InstanceInit ::= Block           [klabel('InstanceInit)]

//@ \subsection{StaticInitializers.sdf}
syntax StaticInit ::= "static" Block    [klabel('StaticInit)]
endmodule