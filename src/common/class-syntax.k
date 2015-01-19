require "array-syntax.k"
require "exp-syntax.k"
module CLASS-SYNTAX
imports ARRAY-SYNTAX
imports EXP-SYNTAX
//@ \subsection{ClassDeclarations.sdf}
syntax ClassBody ::= "{" ClassBodyDecList "}" [klabel('ClassBody)]
syntax ClassDecHead ::= AnnoClassModList "class" Id K K K [klabel('ClassDecHead)]
syntax ClassDec ::= ClassDecHead ClassBody [klabel('ClassDec)]
syntax ClassDec ::= EnumDec
syntax ClassMod ::= Public
                  | Private
                  | Protected
                  | Abstract
                  | Final
                  | Static
                  | StrictFP
syntax AnnoClassMod ::= Anno | ClassMod
syntax Super ::= "extends" ClassType    [klabel('SuperDec)]
syntax Interfaces ::= "implements" InterfaceTypeList    [klabel('ImplementsDec)]
syntax ClassBodyDec ::= InstanceInit | StaticInit

//@ \subsection{ConstructorDeclarations.sdf}
syntax ConstrMod ::= Public
                  | Private
                  | Protected
syntax AnnoConstrMod ::= Anno | ConstrMod
//@ \subsection{EnumDeclarations.sdf}
syntax EnumDecHead ::= AnnoClassModList "enum" Id Interfaces [prefer, klabel('EnumDecHead)]
                     | AnnoClassModList "enum" Id            [klabel('EnumDecHead)]
syntax EnumDec ::= EnumDecHead EnumBody [klabel('EnumDec)]
syntax EnumBody ::= "{" EnumConstList EnumBodyDecs"}" [prefer, klabel('EnumBody)]
                  | "{" EnumConstList "}" [klabel('EnumBody)]
                  | "{" EnumConstList "," EnumBodyDecs "}" [prefer, klabel('EnumBody)]
                  | "{" EnumConstList "," "}" [klabel('EnumBody)]
syntax EnumConst ::= Id EnumConstArgs ClassBody [klabel('EnumConst)]
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
//syntax MethodDecHead ::= AnnoMethodModList TypeParams Type Id "(" Params ")" Throws [prefer, klabel('MethodDecHead)]
//                       | AnnoMethodModList TypeParams Type Id "(" Params ")"    [klabel('MethodDecHead)]
//syntax MethodDec ::= MethodDecHead MethodBody [klabel('MethodDec)]
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