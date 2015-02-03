module INTERFACE-SYNTAX
    imports CLASS-SYNTAX

//@ \subsection{AbstractMethodDeclarations.sdf}
syntax AbstractMethodDec ::=
    AnnoAbstractMethodModList OptionalTypeParams Type Id "(" Params ")" OptionalThrows ";"
                                                        [klabel('AbstractMethodDec)]

syntax AbstractMethodMod ::= Public | Abstract
syntax AnnoAbstractMethodMod ::= Anno | AbstractMethodMod


//@ \subsection{Annotations.sdf}
syntax Anno ::= "@" TypeName "(" ElemValPairList ")" 	[klabel('Anno)]
              | "@" TypeName "(" ElemVal ")"            [klabel('SingleElemAnno)]
              | "@" TypeName                            [klabel('MarkerAnno)]

syntax ElemVal ::= Exp
                 | Anno
                 | "{" ElemValList     "}"              [klabel('ElemValArrayInit)]
                 | "{" ElemValList "," "}"              [klabel('ElemValArrayInit)]

syntax ElemValPair ::= Id "=" ElemVal                   [klabel('ElemValPair)]


//@ \subsection{AnnotationTypes.sdf}
syntax AnnoDecHead ::= AnnoInterfaceModList "@" "interface" Id      [klabel('AnnoDecHead)]

syntax AnnoDec ::= AnnoDecHead "{" AnnoElemDecList "}"              [klabel('AnnoDec)]

syntax AnnoElemDec ::= ConstantDec | ClassDec | InterfaceDec | EnumDec | AnnoDec | SemiColon
syntax AnnoElemDec ::= AbstractMethodModList Type Id "(" ")" OptionalDefaultVal ";"
                                                                    [klabel('AnnoMethodDec)]

syntax DefaultVal ::= "default" ElemVal                             [klabel('DefaultVal)]


//@ \subsection{ConstantDeclarations.sdf}
syntax ConstantDec ::= AnnoConstantModList Type VarDecList ";"      [klabel('ConstantDec)]

syntax ConstantMod ::= Public
                     | Static
                     | Final

syntax AnnoConstantMod ::= Anno | ConstantMod


//@ \subsection{InterfaceDeclarations.sdf}
syntax InterfaceDecHead ::=
    AnnoInterfaceModList "interface" Id OptionalTypeParams OptionalExtendsInterfaces
                                                                       [klabel('InterfaceDecHead)]

syntax InterfaceDec ::= InterfaceDecHead "{" InterfaceMemberDecList "}"[klabel('InterfaceDec)]

syntax ExtendsInterfaces ::= "extends" InterfaceTypeList               [klabel('ExtendsInterfaces)]

syntax InterfaceMemberDec ::= ConstantDec | AbstractMethodDec | ClassDec | InterfaceDec | SemiColon

syntax InterfaceMod ::= Public
                      | Private
                      | Protected
                      | Abstract
                      | Final
                      | Static
                      | StrictFP

syntax AnnoInterfaceMod ::= Anno | InterfaceMod

endmodule