module LIST-SYNTAX
imports STMT-SYNTAX
/*This is a module for list only, for the easy of implementation and management.
 We may put lists back into thier relevant package later.
 There are six lists ((formal)params, dims, dimexps, exps, varinits, catchclauses)
 already defined before, because there is no automatic refactor for rename, and also those
 defined are used in semantics, we leave their name and place unchanged, only add corresponding
 klabels. Also, The function(to be implemented) fromUserListToKListWrap will only apply to
 these lists defined here.*/
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


 syntax UserList ::=   BlockStmList
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


                      syntax   InterfaceType
                      syntax   ExceptionType
                      syntax   Id
                      syntax   TypeDec
                      syntax   VarDec
                      syntax   ImportDec
                      syntax   ActualTypeArg
                      syntax   ClassOrInterfaceType
                      syntax   TypeParam
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
                      syntax   StringPart
                      syntax   EnumConst
                      syntax   ClassBodyDec

endmodule

module LIST-MACRO
imports CORE-FUNCTIONS
//rule 'SwitchLabelList(Hd,,Tl) => [Hd,,Tl] [anywhere]
//rule 'SwitchGroupList(Hd,,Tl) => [Hd,,Tl] [anywhere]
//rule 'BlockStmList(Hd,,Tl) => [Hd,,Tl] [anywhere]
//rule 'InterfaceTypeList(Hd,,Tl) => [Hd,,Tl] [anywhere]
//rule 'ExceptionTypeList(Hd,,Tl) => [Hd,,Tl] [anywhere]
//rule 'IdList(Hd,,Tl) => [Hd,,Tl] [anywhere]
//rule 'TypeDecList(Hd,,Tl) => [Hd,,Tl] [anywhere]
//rule 'VarDecList(Hd,,Tl) => [Hd,,Tl] [anywhere]
//rule 'ImportDecList(Hd,,Tl) => [Hd,,Tl] [anywhere]
//rule 'ActualTypeArgList(Hd,,Tl) => [Hd,,Tl] [anywhere]
//rule 'ClassOrInterfaceTypeList(Hd,,Tl) => [Hd,,Tl] [anywhere]
//rule 'TypeParamList(Hd,,Tl) => [Hd,,Tl] [anywhere]
//rule 'AbstractMethodModList(Hd,,Tl) => [Hd,,Tl] [anywhere]
//rule 'AnnoAbstractMethodModList(Hd,,Tl) => [Hd,,Tl] [anywhere]
//rule 'AnnoMethodModList(Hd,,Tl) => [Hd,,Tl] [anywhere]
//rule 'AnnoVarModList(Hd,,Tl) => [Hd,,Tl] [anywhere]

//rule 'AnnoConstrModList(Hd,,Tl) => [Hd,,Tl] [anywhere]
//rule 'AnnoConstantModList(Hd,,Tl) => [Hd,,Tl] [anywhere]
//rule 'AnnoFieldModList(Hd,,Tl) => [Hd,,Tl] [anywhere]
//rule 'AnnoInterfaceModList(Hd,,Tl) => [Hd,,Tl] [anywhere]
//rule 'AnnoList(Hd,,Tl) => [Hd,,Tl] [anywhere]
//rule 'AnnoElemDecList(Hd,,Tl) => [Hd,,Tl] [anywhere]
//rule 'InterfaceMemberDecList(Hd,,Tl) => [Hd,,Tl] [anywhere]
//rule 'ElemValPairList(Hd,,Tl) => [Hd,,Tl] [anywhere]
//rule 'ElemValList(Hd,,Tl) => [Hd,,Tl] [anywhere]
//rule 'EnumConstList(Hd,,Tl) => [Hd,,Tl] [anywhere]
//rule 'StringPartList(Hd,,Tl) => [Hd,,Tl] [anywhere]
//rule 'ClassBodyDecList(Hd,,Tl) => [Hd,,Tl] [anywhere]
//rule '.List`{""`}(.KList) => .KList
syntax KItem ::= toKListWrap(UserList) [function]
                | toKListWrap(UserList, KListWrap) [function]

rule toKListWrap(UL:UserList) => toKListWrap(UL,[.KList])

rule toKListWrap('AnnoClassModList(Hd,,Tl), [L:KList]) => toKListWrap(Tl, [L,,Hd])
rule toKListWrap('ImportDecList(Hd,,Tl), [L:KList]) => toKListWrap(Tl, [L,,Hd])
rule toKListWrap('TypeDecList(Hd,,Tl), [L:KList]) => toKListWrap(Tl, [L,,Hd])

rule toKListWrap('.List`{""`}(.KList), KL:KListWrap) => KL
//rule toKListWrap('.List`{""`}(.KList)) => [.KList]





rule    'ClassDecHead((Mod:UserList => toKListWrap(Mod)),,_) [anywhere]
rule    'CompilationUnit(_,,(ImportDecs:UserList => toKListWrap(ImportDecs)),,_) [anywhere]
rule    'CompilationUnit(_,,(TypeDecs:UserList => toKListWrap(TypeDecs)))[anywhere]


endmodule