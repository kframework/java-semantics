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
syntax EnumConstList             ::= List{EnumConst, ","}            [klabel('EnumConstList)]
syntax ClassBodyDecList          ::= List{ClassBodyDec, ""}          [klabel('ClassBodyDecList)]
syntax BlockStmList              ::= List{BlockStmt, ""}             [klabel('BlockStmList)]
syntax SwitchGroupList           ::= List{SwitchGroup, ""}           [klabel('SwitchGroupList)]
syntax SwitchLabelList           ::= List{SwitchLabel, ""}           [klabel('SwitchLabelList)]

syntax Exps                      ::= List{Exp, ","}                  [klabel('ExprList), seqstrict]
syntax Dims                      ::= List{Dim,""}                    [klabel('DimList)]
syntax DimExps                   ::= List{DimExp,""}                 [klabel('DimExprList), strict]
syntax VarInits                  ::= List{VarInit, ","}              [klabel('VarInitList)]
syntax CatchClauses              ::= List{CatchClause,""}            [klabel('CatchClauseList), strict]
syntax Params                    ::= List{Param, ","}                [klabel('FormalParamList)]

context 'FormalParamList(HOLE,,_) [result(Param)]
context 'FormalParamList(_,,HOLE) [result(Params)]

endmodule