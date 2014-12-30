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
                      syntax   TypeDec::= ClassDec
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

syntax KItem ::= toKListWrap(K) [function]
                | toKListWrap(K, KListWrap) [function]

rule toKListWrap(UL) => toKListWrap(UL,[.KList])

rule toKListWrap(Label:KLabel(Hd,,Tl), [L:KList]) => toKListWrap(Tl, [L,,Hd])

rule toKListWrap('.List`{""`}(.KList), KL:KListWrap) => KL
rule toKListWrap('.List`{"`,"`}(.KList), KL:KListWrap) => KL
rule toKListWrap('.List`{"."`}(.KList), KL:KListWrap) => KL
rule toKListWrap('.List`{"&"`}(.KList), KL:KListWrap) => KL





//AnnoClassModList "class" Id  TypeParams? Super? Interfaces? -> ClassDecHead {cons("ClassDecHead")}
rule    'ClassDecHead(('AnnoClassModList(A) => toKListWrap('AnnoClassModList(A))),,_) [anywhere]
rule    'ClassDecHead(('.List`{""`}(.KList) => [.KList]),,_) [anywhere]

//PackageDec? ImportDecList TypeDecList -> CompilationUnit   {cons("CompilationUnit")}
rule    'CompilationUnit(_,,('ImportDecList(I) => toKListWrap('ImportDecList(I))),,_) [anywhere]
rule    'CompilationUnit(_,,('.List`{""`}(.KList) => [.KList]),,_) [anywhere]
rule    'CompilationUnit(_,,('TypeDecList(T) => toKListWrap('TypeDecList(T))))[anywhere]

// "{" ClassBodyDecList "}" -> ClassBody {cons("ClassBody")}
rule    'ClassBody(('ClassBodyDecList(C) => toKListWrap('ClassBodyDecList(C)))) [anywhere]
rule    'ClassBody(('.List`{""`}(.KList) => [.KList])) [anywhere]

//AnnoMethodModList TypeParams? ResultType Id "(" FormalParamList ")" Throws?  -> MethodDecHead {cons("MethodDecHead")}
rule    'MethodDecHead(('AnnoMethodModList(A) => toKListWrap('AnnoMethodModList(A))),,_) [anywhere]
rule    'MethodDecHead(('.List`{""`}(.KList) => [.KList]),,_) [anywhere]
rule    'MethodDecHead(_,,('_`,_(Params) => toKListWrap('_`,_(Params))),,_) [anywhere]
rule    'MethodDecHead(_,,('.List`{"`,"`}(.KList) => [.KList]),,_) [anywhere]

//"{" BlockStmList "}" -> Block {cons("Block")}
rule    'Block('BlockStmList(B) => toKListWrap('BlockStmList(B))) [anywhere]
rule    'Block(('.List`{""`}(.KList) => [.KList])) [anywhere]

//MethodSpec "(" ExprList ")" -> Expr {cons("Invoke")}
rule    'Invoke(_,,('_`,_(Exps) => toKListWrap('_`,_(Exps)))) [anywhere]
rule    'Invoke(_,,('.List`{"`,"`}(.KList) => [.KList])) [anywhere]

//"\"" StringPartList "\"" -> StringLiteral {cons("String")}
rule    'String(('StringPartList(S) => toKListWrap('StringPartList(S)))) [anywhere]
rule    'String(('.List`{""`}(.KList) => [.KList])) [anywhere]

//AnnoVarModList Type       VarDecId -> FormalParam {cons("Param")}
rule    'Param(('AnnoVarModList(A) => toKListWrap('AnnoVarModList(A))),,_) [anywhere]
rule    'Param(('.List`{""`}(.KList) => [.KList]),,_) [anywhere]

endmodule