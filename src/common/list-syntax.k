module LIST-SYNTAX

/*A module for list only, for the easy of implementation and management.
 There are six lists ((formal)params, dims, dimexps, exps, varinits, catchclauses)
 already defined before, because there is no automatic refactor for rename, and also those
 defined are used in semantic rules, we leave them unchanged.*/

syntax InterfaceTypeList         ::= List{InterfaceType,","}         [klabel('InterfaceTypeList), strict]
syntax ExceptionTypeList         ::= List{ExceptionType,","}         [klabel('ExceptionTypeList)]
syntax IdList                    ::= List{Id,"."}                    [klabel('IdList)]
syntax TypeDecList               ::= List{TypeDec,""}                [klabel('TypeDecList)]
syntax VarDecList                ::= List{VarDec,","}                [klabel('VarDecList)]
syntax ImportDecList             ::= List{ImportDec,""}              [klabel('ImportDecList)]
syntax ActualTypeArgList         ::= List{ActualTypeArg,","}         [klabel('ActualTypeArgList)]
syntax ClassOrInterfaceTypeList  ::= List{ClassOrInterfaceType, "&"} [klabel('ClassOrInterfaceTypeList)]
syntax TypeParamList             ::= List{TypeParam,","}             [klabel('TypeParamList)]
syntax AbstractMethodModList     ::= List{AbstractMethodMod, ""}     [klabel('AbstractMethodModList)]
syntax AnnoAbstractMethodModList ::= List{AnnoAbstractMethodMod, ""} [klabel('AnnoAbstractMethodModList)]
syntax AnnoMethodModList         ::= List{AnnoMethodMod, ""}         [klabel('AnnoMethodModList)]
syntax AnnoVarModList            ::= List{AnnoVarMod, ""}            [klabel('AnnoVarModList)]
syntax AnnoClassModList          ::= List{AnnoClassMod, ""}          [klabel('AnnoClassModList)]
syntax AnnoConstrModList         ::= List{AnnoConstrMod, ""}         [klabel('AnnoConstrModList)]
syntax AnnoConstantModList       ::= List{AnnoConstantMod, ""}       [klabel('AnnoConstantModList)]
syntax AnnoFieldModList          ::= List{AnnoFieldMod, ""}          [klabel('AnnoFieldModList)]
syntax AnnoInterfaceModList      ::= List{AnnoInterfaceMod, ""}      [klabel('AnnoInterfaceModList)]
syntax AnnoList                  ::= List{Anno, ""}                  [klabel('AnnoList)]
syntax AnnoElemDecList           ::= List{AnnoElemDec, ""}           [klabel('AnnoElemDecList)]
syntax InterfaceMemberDecList    ::= List{InterfaceMemberDec, ""}    [klabel('InterfaceMemberDecList)]
syntax ElemValPairList           ::= List{ElemValPair,","}           [klabel('ElemValPairList)]
syntax ElemValList               ::= List{ElemVal,","}               [klabel('ElemValList)]
syntax StringPartList            ::= List{StringPart,""}             [klabel('StringPartList)]
syntax EnumConstList             ::= List{ EnumConst, ","}           [klabel(' EnumConstList)]
syntax ClassBodyDecList          ::= List{ClassBodyDec, ""}          [klabel('ClassBodyDecList)]
syntax BlockStmList              ::= List{BlockStmt, ""}             [klabel('BlockStmList)]
syntax SwitchGroupList           ::= List{SwitchGroup, ""}           [klabel('SwitchGroupList)]
syntax SwitchLabelList           ::= List{SwitchLabel, ""}           [klabel('SwitchLabelList)]

syntax Exps         ::= List{Exp, ","} [seqstrict]
syntax Dims         ::= List{Dim,""}  [klabel('DimList)]
syntax DimExps      ::= List{DimExp,""} [klabel('DimExprList), strict]
syntax VarInits     ::= List{VarInit, ","}  [klabel('VarInitList)]
syntax CatchClauses ::= List{CatchClause,""} [klabel('CatchClauseList), strict]
syntax Params       ::= List{Param, ","}   [klabel('FormalParamList)]

context 'FormalParamList(HOLE,,_) [result(Param)]
context 'FormalParamList(_,,HOLE) [result(Params)]

syntax KLabel::= "'ExprList"

syntax UserList     ::= BlockStmList
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


endmodule

module LIST-MACRO
imports CORE-FUNCTIONS

rule '.List`{"'SwitchLabelList"`}(.KList)   => [.KList]                             [macro]
rule '.List`{"'SwitchGroupList"`}(.KList)   => [.KList]                             [macro]
rule '.List`{"'BlockStmList"`}(.KList)   => [.KList]                                [macro]
rule '.List`{"'ExceptionTypeList"`}(.KList)   => [.KList]                           [macro]
rule '.List`{"'IdList"`}(.KList)   => [.KList]                                      [macro]
rule '.List`{"'TypeDecList"`}(.KList)   => [.KList]                                 [macro]
rule '.List`{"'VarDecList"`}(.KList)   => [.KList]                                  [macro]
rule '.List`{"'ImportDecList"`}(.KList)   => [.KList]                               [macro]
rule '.List`{"'ActualTypeArgList"`}(.KList)   => [.KList]                           [macro]
rule '.List`{"'ClassOrInterfaceTypeList"`}(.KList)   => [.KList]                    [macro]
rule '.List`{"'TypeParamList"`}(.KList)   => [.KList]                               [macro]
rule '.List`{"'AbstractMethodModList"`}(.KList)   => [.KList]                       [macro]
rule '.List`{"'AnnoAbstractMethodModList"`}(.KList)   => [.KList]                   [macro]
rule '.List`{"'AnnoMethodModList"`}(.KList)   => [.KList]                           [macro]
rule '.List`{"'AnnoClassModList"`}(.KList)   => [.KList]                            [macro]
rule '.List`{"'AnnoConstrModList"`}(.KList)   => [.KList]                           [macro]
rule '.List`{"'AnnoConstantModList"`}(.KList)   => [.KList]                         [macro]
rule '.List`{"'AnnoFieldModList"`}(.KList)   => [.KList]                            [macro]
rule '.List`{"'AnnoInterfaceModList"`}(.KList)   => [.KList]                        [macro]
rule '.List`{"'AnnoList"`}(.KList)   => [.KList]                                    [macro]
rule '.List`{"'AnnoElemDecList"`}(.KList)   => [.KList]                             [macro]
rule '.List`{"'InterfaceMemberDecList"`}(.KList)   => [.KList]                      [macro]
rule '.List`{"'ElemValPairList"`}(.KList)   => [.KList]                             [macro]
rule '.List`{"'ElemValList"`}(.KList)   => [.KList]                                 [macro]
rule '.List`{"'StringPartList"`}(.KList)   => [.KList]                              [macro]
rule '.List`{"'ClassBodyDecList"`}(.KList)   => [.KList]                            [macro]
//rule '.List`{"'DimExprList"`}(.KList)   => [.KList]                                 [macro]
rule '.List`{"'ExprList"`}(.KList)   => [.KList]                                    [macro]


rule 'SwitchLabelList(Hd,,[Tl:KList])           => [Hd,,Tl]         [macro]
rule 'SwitchGroupList(Hd,,[Tl:KList])           => [Hd,,Tl]         [macro]
rule 'BlockStmList(Hd,,[Tl:KList])              => [Hd,,Tl]         [macro]
rule 'ExceptionTypeList(Hd,,[Tl:KList])         => [Hd,,Tl]         [macro]
rule 'IdList(Hd,,[Tl:KList])                    => [Hd,,Tl]         [macro]
rule 'TypeDecList(Hd,,[Tl:KList])               => [Hd,,Tl]         [macro]
rule 'VarDecList(Hd,,[Tl:KList])                => [Hd,,Tl]         [macro]
rule 'ImportDecList(Hd,,[Tl:KList])             => [Hd,,Tl]         [macro]
rule 'ActualTypeArgList(Hd,,[Tl:KList])         => [Hd,,Tl]         [macro]
rule 'ClassOrInterfaceTypeList(Hd,,[Tl:KList])  => [Hd,,Tl]         [macro]
rule 'TypeParamList(Hd,,[Tl:KList])             => [Hd,,Tl]         [macro]
rule 'AbstractMethodModList(Hd,,[Tl:KList])     => [Hd,,Tl]         [macro]
rule 'AnnoAbstractMethodModList(Hd,,[Tl:KList]) => [Hd,,Tl]         [macro]
rule 'AnnoMethodModList(Hd,,[Tl:KList])         => [Hd,,Tl]         [macro]
rule 'AnnoClassModList(Hd,,[Tl:KList])          => [Hd,,Tl]         [macro]
rule 'AnnoConstrModList(Hd,,[Tl:KList])         => [Hd,,Tl]         [macro]
rule 'AnnoConstantModList(Hd,,[Tl:KList])       => [Hd,,Tl]         [macro]
rule 'AnnoFieldModList(Hd,,[Tl:KList])          => [Hd,,Tl]         [macro]
rule 'AnnoInterfaceModList(Hd,,[Tl:KList])      => [Hd,,Tl]         [macro]
rule 'AnnoList(Hd,,[Tl:KList])                  => [Hd,,Tl]         [macro]
rule 'AnnoElemDecList(Hd,,[Tl:KList])           => [Hd,,Tl]         [macro]
rule 'InterfaceMemberDecList(Hd,,[Tl:KList])    => [Hd,,Tl]         [macro]
rule 'ElemValPairList(Hd,,[Tl:KList])           => [Hd,,Tl]         [macro]
rule 'ElemValList(Hd,,[Tl:KList])               => [Hd,,Tl]         [macro]
rule 'StringPartList(Hd,,[Tl:KList])            => [Hd,,Tl]         [macro]
rule 'ClassBodyDecList(Hd,,[Tl:KList])          => [Hd,,Tl]         [macro]
//rule 'DimExprList(Hd,,[Tl:KList])               => [Hd,,Tl]         [macro]
rule 'ExprList(Hd,,[Tl:KList])                  => [Hd,,Tl]         [macro]


endmodule