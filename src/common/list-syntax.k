require "stmt-syntax.k"
require "literal-syntax.k"
require "type-syntax.k"
module LIST-SYNTAX
imports STMT-SYNTAX
imports LITERAL-SYNTAX
imports TYPE-SYNTAX
/*A module for list only, for the easy of implementation and management.
 There are six lists ((formal)params, dims, dimexps, exps, varinits, catchclauses)
 already defined before, because there is no automatic refactor for rename, and also those
 defined are used in semantic rules, we leave them unchanged.*/

syntax InterfaceTypeList ::= List{InterfaceType,","} [klabel('InterfaceTypeList)]
syntax ExceptionTypeList ::= List{ExceptionType,","} [klabel('ExceptionTypeList)]
syntax IdList ::= List{Id,"."} [klabel('IdList)]
syntax TypeDecList ::= List{TypeDec,""} [klabel('TypeDecList)]
syntax VarDecList ::= List{VarDec,","} [klabel('VarDecList)]
syntax ImportDecList ::= List{ImportDec,""} [klabel('ImportDecList)]
syntax ActualTypeArgList ::= List{ActualTypeArg,","} [klabel('ActualTypeArgList)]
syntax ClassOrInterfaceTypeList ::= List{ClassOrInterfaceType, "&"} [klabel('ClassOrInterfaceTypeList)]
syntax TypeParamList ::= List{TypeParam,","} [klabel('TypeParamList)]
syntax AbstractMethodModList ::= List{AbstractMethodMod, ""} [klabel('AbstractMethodModList)]
syntax AnnoAbstractMethodModList ::= List{AnnoAbstractMethodMod, ""} [klabel('AnnoAbstractMethodModList)]
syntax AnnoMethodModList ::= List{AnnoMethodMod, ""} [klabel('AnnoMethodModList)]
syntax AnnoVarModList ::= List{AnnoVarMod, ""} [klabel('AnnoVarModList)]
syntax AnnoClassModList ::= List{AnnoClassMod, ""} [klabel('AnnoClassModList)]
syntax AnnoConstrModList ::= List{AnnoConstrMod, ""} [klabel('AnnoConstrModList)]
syntax AnnoConstantModList ::= List{AnnoConstantMod, ""} [klabel('AnnoConstantModList)]
syntax AnnoFieldModList ::= List{AnnoFieldMod, ""} [klabel('AnnoFieldModList)]
syntax AnnoInterfaceModList ::= List{AnnoInterfaceMod, ""} [klabel('AnnoInterfaceModList)]
syntax AnnoList ::= List{Anno, ""} [klabel('AnnoList)]
syntax AnnoElemDecList ::= List{AnnoElemDec, ""} [klabel('AnnoElemDecList)]
syntax InterfaceMemberDecList ::= List{InterfaceMemberDec, ""} [klabel('InterfaceMemberDecList)]
syntax ElemValPairList ::= List{ElemValPair,","} [klabel('ElemValPairList)]
syntax ElemValList ::= List{ElemVal,","} [klabel('ElemValList)]
syntax StringPartList ::= List{StringPart,""} [klabel('StringPartList)]
syntax EnumConstList ::= List{ EnumConst, ","} [klabel(' EnumConstList)]
syntax ClassBodyDecList ::= List{ClassBodyDec, ""} [klabel('ClassBodyDecList)]
syntax BlockStmList ::= List{BlockStmt, ""} [klabel('BlockStmList)]
syntax SwitchGroupList ::= List{SwitchGroup, ""} [klabel('SwitchGroupList)]
syntax SwitchLabelList ::= List{SwitchLabel, ""} [klabel('SwitchLabelList)]

syntax Exps ::= List{Exp, ","} [seqstrict]
syntax Dims ::= List{Dim,""} // [klabel('DimList)]
syntax DimExps ::= List{DimExp,""} [strict]
syntax VarInits ::= List{VarInit, ","} //  [klabel('VarInitList)]
syntax CatchClauses ::= List{CatchClause,""} [strict]
syntax Params ::= List{Param, ","}

syntax UserList ::=     BlockStmList
                      | SwitchGroupList
                      | SwitchLabelList
                      | InterfaceTypeList
                      | ExceptionTypeList
                      | IdList
                      | TypeDecList
                      | VarDecList
                      | ImportDecList
                      | ActualTypeArgList
                      | ClassOrInterfaceTypeList
                      | TypeParamList
                      | AbstractMethodModList
                      | AnnoAbstractMethodModList
                      | AnnoMethodModList
                      | AnnoVarModList
                      | AnnoClassModList
                      | AnnoConstrModList
                      | AnnoConstantModList
                      | AnnoFieldModList
                      | AnnoInterfaceModList
                      | AnnoList
                      | AnnoElemDecList
                      | InterfaceMemberDecList
                      | ElemValPairList
                      | ElemValList
                      | StringPartList
                      | EnumConstList
                      | ClassBodyDecList

/* todo: Syntax below should be put in other modules when they are perfectly defined. */
                      syntax   InterfaceType
                      syntax   ExceptionType

                      syntax   TypeDec::= ClassDec
                      syntax   VarDec
                      syntax   ImportDec



                      syntax   AbstractMethodMod
                      syntax   AnnoAbstractMethodMod
                      syntax   AnnoMethodMod
                      syntax   AnnoVarMod
                      syntax   AnnoClassMod
                      syntax   AnnoConstrMod
                      syntax   AnnoConstantMod
                      syntax   AnnoFieldMod
                      syntax   AnnoInterfaceMod
                      syntax   Anno
                      syntax   AnnoElemDec
                      syntax   InterfaceMemberDec
                      syntax   ElemValPair
                      syntax   ElemVal

                      syntax   EnumConst
                      syntax   ClassBodyDec

endmodule

module LIST-MACRO
imports CORE-FUNCTIONS

rule '.List`{""`}(.KList) => [.KList] [macro]
rule '.List`{"."`}(.KList) => [.KList] [macro]
rule '.List`{"&"`}(.KList) => [.KList] [macro]
rule '.List`{"`,"`}(.KList) => [.KList] [macro]
rule 'SwitchLabelList(Hd,,[Tl:KList]) => [Hd,,Tl] [macro]
rule 'SwitchGroupList(Hd,,[Tl:KList]) => [Hd,,Tl] [macro]
rule 'BlockStmList(Hd,,[Tl:KList]) => [Hd,,Tl] [macro]
rule 'InterfaceTypeList(Hd,,[Tl:KList]) => [Hd,,Tl] [macro]
rule 'ExceptionTypeList(Hd,,[Tl:KList]) => [Hd,,Tl] [macro]
rule 'IdList(Hd,,[Tl:KList]) => [Hd,,Tl] [macro]
rule 'TypeDecList(Hd,,[Tl:KList]) => [Hd,,Tl] [macro]
rule 'VarDecList(Hd,,[Tl:KList]) => [Hd,,Tl] [macro]
rule 'ImportDecList(Hd,,[Tl:KList]) => [Hd,,Tl] [macro]
rule 'ActualTypeArgList(Hd,,[Tl:KList]) => [Hd,,Tl] [macro]
rule 'ClassOrInterfaceTypeList(Hd,,[Tl:KList]) => [Hd,,Tl] [macro]
rule 'TypeParamList(Hd,,[Tl:KList]) => [Hd,,Tl] [macro]
rule 'AbstractMethodModList(Hd,,[Tl:KList]) => [Hd,,Tl] [macro]
rule 'AnnoAbstractMethodModList(Hd,,[Tl:KList]) => [Hd,,Tl] [macro]
rule 'AnnoMethodModList(Hd,,[Tl:KList]) => [Hd,,Tl] [macro]
rule 'AnnoVarModList(Hd,,[Tl:KList]) => [Hd,,Tl] [macro]
rule 'AnnoClassModList(Hd,,[Tl:KList]) => [Hd,,Tl] [macro]
rule 'AnnoConstrModList(Hd,,[Tl:KList]) => [Hd,,Tl] [macro]
rule 'AnnoConstantModList(Hd,,[Tl:KList]) => [Hd,,Tl] [macro]
rule 'AnnoFieldModList(Hd,,[Tl:KList]) => [Hd,,Tl] [macro]
rule 'AnnoInterfaceModList(Hd,,[Tl:KList]) => [Hd,,Tl] [macro]
rule 'AnnoList(Hd,,[Tl:KList]) => [Hd,,Tl] [macro]
rule 'AnnoElemDecList(Hd,,[Tl:KList]) => [Hd,,Tl] [macro]
rule 'InterfaceMemberDecList(Hd,,[Tl:KList]) => [Hd,,Tl] [macro]
rule 'ElemValPairList(Hd,,[Tl:KList]) => [Hd,,Tl] [macro]
rule 'ElemValList(Hd,,[Tl:KList]) => [Hd,,Tl] [macro]
rule 'StringPartList(Hd,,[Tl:KList]) => [Hd,,Tl] [macro]
rule 'ClassBodyDecList(Hd,,[Tl:KList]) => [Hd,,Tl] [macro]
rule '_`,_(Hd,,[Tl:KList]) => [Hd,,Tl] [macro]
rule '__(Hd,,[Tl:KList]) => [Hd,,Tl] [macro]

//Below is a preparation for the change of parser. possibly used when backend changes.
syntax KLabel::= "'DimList"
                |"'DimExprList"
                |"'ExprList"
                |"'VarInitList"
                |"'CatchClauseList"
                |"'FormalParamList"
rule 'DimList(Hd,,[Tl:KList]) => [Hd,,Tl] [macro]
rule 'DimExprList(Hd,,[Tl:KList]) => [Hd,,Tl] [macro]
rule 'ExprList(Hd,,[Tl:KList]) => [Hd,,Tl] [macro]
rule 'VarInitList(Hd,,[Tl:KList]) => [Hd,,Tl] [macro]
rule 'CatchClauseList(Hd,,[Tl:KList]) => [Hd,,Tl] [macro]
rule 'FormalParamList(Hd,,[Tl:KList]) => [Hd,,Tl] [macro]

endmodule