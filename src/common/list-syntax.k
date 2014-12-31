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

//AnnoVarModList Type   "..."    VarDecId -> FormalParam {cons("VarArityParam")}
rule    'VarArityParam(('AnnoVarModList(A) => toKListWrap('AnnoVarModList(A))),,_) [anywhere]
rule    'VarArityParam(('.List`{""`}(.KList) => [.KList]),,_) [anywhere]


//AnnoVarModList Type VarDecList -> LocalVarDec {prefer, cons("LocalVarDec")}
rule    'LocalVarDec(('AnnoVarModList(A) => toKListWrap('AnnoVarModList(A))),,_) [anywhere]
rule    'LocalVarDec(('.List`{""`}(.KList) => [.KList]),,_) [anywhere]
rule    'LocalVarDec(_,,('VarDecList(A) => toKListWrap('VarDecList(A)))) [anywhere]

//"new" ArrayBaseType DimExpr+ Dim*  -> ArrayCreationExpr {cons("NewArray")}
//"new" ArrayBaseType Dim+ ArrayInit -> ArrayCreationExpr {cons("NewArray")}
rule    'NewArray(_,,('__(D) => toKListWrap('__(D))),,_) [anywhere]
rule    'NewArray(_,,('.List`{""`}(.KList) => [.KList])) [anywhere]

//"{"   VarInitList   "}" -> ArrayInit {cons("ArrayInit")}
//"{" VarInitList "," "}" -> ArrayInit {cons("ArrayInit")}
rule    'ArrayInit(('_`,_(V) => toKListWrap('_`,_(V)))) [anywhere]
rule    'ArrayInit(('.List`{"`,"`}(.KList) => [.KList])) [anywhere]

//"for" "(" LocalVarDec ";" Expr? ";" ExprList ")" Stm -> Stm {cons("For")}
//"for" "(" ExprList ";" Expr? ";" ExprList ")" Stm -> Stm {cons("For")}
rule    'For(_,,('_`,_(Exps) => toKListWrap('_`,_(Exps))),,_) [anywhere]
rule    'For(_,,('.List`{"`,"`}(.KList) => [.KList]),,_) [anywhere]

// AnnoConstrModList TypeParams? Id "(" FormalParamList ")" Throws? -> ConstrHead {cons("ConstrDecHead")}
rule    'ConstrDecHead(('AnnoConstrModList(A) => toKListWrap('AnnoConstrModList(A))),,_) [anywhere]
rule    'ConstrDecHead(('.List`{""`}(.KList) => [.KList]),,_) [anywhere]
rule    'ConstrDecHead(_,,('_`,_(Params) => toKListWrap('_`,_(Params))),,_) [anywhere]
rule    'ConstrDecHead(_,,('.List`{"`,"`}(.KList) => [.KList]),,_) [anywhere]

//"{" ConstrInv? BlockStmList "}" -> ConstrBody {cons("ConstrBody")}
rule    'ConstrBody(_,,('BlockStmList(B) => toKListWrap('BlockStmList(B)))) [anywhere]
rule    'ConstrBody(_,,('.List`{""`}(.KList) => [.KList])) [anywhere]

// TypeArgs? "this"  "(" ExprList ")" ";" -> ConstrInv {cons("AltConstrInv")}
rule    'AltConstrInv(_,,('_`,_(Exps) => toKListWrap('_`,_(Exps)))) [anywhere]
rule    'AltConstrInv(_,,('.List`{"`,"`}(.KList) => [.KList])) [anywhere]

// TypeArgs? "super" "(" ExprList ")" ";" -> ConstrInv {cons("SuperConstrInv")}
rule    'SuperConstrInv(_,,('_`,_(Exps) => toKListWrap('_`,_(Exps)))) [anywhere]
rule    'SuperConstrInv(_,,('.List`{"`,"`}(.KList) => [.KList])) [anywhere]

// Expr "." TypeArgs? "super" "(" ExprList ")" ";" -> ConstrInv {cons("QSuperConstrInv")}
rule    'QSuperConstrInv(_,,('_`,_(Exps) => toKListWrap('_`,_(Exps)))) [anywhere]
rule    'QSuperConstrInv(_,,('.List`{"`,"`}(.KList) => [.KList])) [anywhere]

//AnnoFieldModList Type VarDecList ";" -> FieldDec {cons("FieldDec")}
rule    'FieldDec(('AnnoFieldModList(A) => toKListWrap('AnnoFieldModList(A))),,_) [anywhere]
rule    'FieldDec(('.List`{""`}(.KList) => [.KList]),,_) [anywhere]
rule    'FieldDec(_,,('VarDecList(V) => toKListWrap('VarDecList(V)))) [anywhere]

//"new" TypeArgs? ClassOrInterfaceType "(" ExprList ")" ClassBody? -> Expr {cons("NewInstance")}
rule    'NewInstance(_,,('_`,_(Exps) => toKListWrap('_`,_(Exps))),,_) [anywhere]
rule    'NewInstance(_,,('.List`{"`,"`}(.KList) => [.KList]),,_) [anywhere]
// Expr "." "new" TypeArgs? Id         TypeArgs? "(" ExprList ")" ClassBody? -> Expr {cons("QNewInstance")}
rule    'QNewInstance(_,,('_`,_(Exps) => toKListWrap('_`,_(Exps))),,_) [anywhere]
rule    'QNewInstance(_,,('.List`{"`,"`}(.KList) => [.KList]),,_) [anywhere]

//"try" Block CatchClauseList -> Stm {cons("Try")}
//"try" Block CatchClauseList "finally" Block -> Stm {cons("Try")}
rule    'Try(_,,('__(Catches) => toKListWrap('__(Catches))),,_) [anywhere]
rule    'Try(_,,('.List`{""`}(.KList) => [.KList]),,_) [anywhere]

//"{" SwitchGroupList SwitchLabelList "}" -> SwitchBlock {cons("SwitchBlock")}
rule    'SwitchBlock(('SwitchGroupList(SG) => toKListWrap('SwitchGroupList(SG))),,_) [anywhere]
rule    'SwitchBlock(_,,('SwitchLabelList(SL) => toKListWrap('SwitchLabelList(SL)))) [anywhere]
rule    'SwitchBlock(_,,('.List`{""`}(.KList) => [.KList]),,_) [anywhere]

// SwitchLabelPlusList BlockStmPlusList -> SwitchGroup  {cons("SwitchGroup")}
rule    'SwitchGroup(('SwitchLabelList(SL) => toKListWrap('SwitchLabelList(SL))),,_)    [anywhere]
rule    'SwitchGroup(_,,('BlockStmList(B) => toKListWrap('BlockStmList(B))))    [anywhere]


//AnnoList "package" PackageName ";" -> PackageDec {cons("PackageDec")}
rule    'PackageDec(('AnnoList(A) => toKListWrap('AnnoList(A))),,_) [anywhere]
rule    'PackageDec(('.List`{""`}(.KList) => [.KList]),,_) [anywhere]

//IdList -> PackageName {cons("PackageName")}
rule    'PackageName(('IdList(I) => toKListWrap('IdList(I)))) [anywhere]

//"<" ActualTypeArgList ">" -> TypeArgs {cons("TypeArgs")}
rule    'TypeArgs(('ActualTypeArgList(A) => toKListWrap('ActualTypeArgList(A))))    [anywhere]

//"extends" ClassOrInterfaceTypeList -> TypeBound {cons("TypeBound")}
rule    'TypeBound(('ClassOrInterfaceTypeList(C) => toKListWrap('ClassOrInterfaceTypeList(C))))    [anywhere]

// "<" TypeParamList ">" -> TypeParams {cons("TypeParams")}
rule    'TypeParams(('TypeParamList(A) => toKListWrap('TypeParamList(A))))    [anywhere]

//"implements" InterfaceTypeList -> Interfaces {cons("ImplementsDec")}
rule    'ImplementsDec(('InterfaceTypeList(I) => toKListWrap('InterfaceTypeList(I))))   [anywhere]

//"throws" ExceptionTypeList -> Throws {cons("ThrowsDec")}
rule    'ThrowsDec(('ExceptionTypeList(I) => toKListWrap('ExceptionTypeList(I))))   [anywhere]

//Id DimPlusList -> VarDecId {cons("ArrayVarDecId")}
rule    'ArrayVarDecId(_,,('__(D) => toKListWrap('__(D))))  [anywhere]

//InterfaceDecHead "{" InterfaceMemberDecList "}" -> InterfaceDec {cons("InterfaceDec")}
rule    'InterfaceDec(_,,('InterfaceMemberDecList(I) => toKListWrap('InterfaceMemberDecList(I))))   [anywhere]
rule    'InterfaceDec(_,,('.List`{""`}(.KList) => [.KList])) [anywhere]

//AnnoInterfaceModList "interface" Id TypeParams? ExtendsInterfaces? -> InterfaceDecHead {cons("InterfaceDecHead")}
rule    'InterfaceDecHead(('AnnoInterfaceModList(I) => toKListWrap('AnnoInterfaceModList(I))),,_)   [anywhere]
rule    'InterfaceDecHead(('.List`{""`}(.KList) => [.KList]),,_) [anywhere]

//"extends" InterfaceTypeList -> ExtendsInterfaces {cons("ExtendsInterfaces")}
rule    'ExtendsInterfaces(('InterfaceTypeList(I) => toKListWrap('InterfaceTypeList(I))))   [anywhere]

//AnnoClassModList "enum" Id Interfaces? -> EnumDecHead {cons("EnumDecHead")}
rule    'EnumDecHead(('AnnoClassModList(A) => toKListWrap('AnnoClassModList(A))),,_) [anywhere]
rule    'EnumDecHead(('.List`{""`}(.KList) => [.KList]),,_) [anywhere]

//    "{" EnumConstList     EnumBodyDecs? "}" -> EnumBody {cons("EnumBody")}
//    "{" EnumConstList "," EnumBodyDecs? "}" -> EnumBody {cons("EnumBody")}
rule    'EnumBody(('EnumConstList(E) => toKListWrap(('EnumConstList(E)))),,_) [anywhere]
rule    'EnumBody(('.List`{"`,"`}(.KList) => [.KList]),,_) [anywhere]

//    Id EnumConstArgs? ClassBody?  -> EnumConst {cons("EnumConst")}
rule    'EnumConst(_,,'Some(('_`,_(Exps) => toKListWrap('_`,_(Exps)))),,_) [anywhere]
rule    'EnumConst(_,,'Some(('.List`{"`,"`}(.KList) => [.KList])),,_) [anywhere]

//    ";" ClassBodyDecList -> EnumBodyDecs {cons("EnumBodyDecs")}
rule	'EnumBodyDecs(('ClassBodyDecList(C) => toKListWrap('ClassBodyDecList(C)))) [anywhere]
rule    'EnumBodyDecs(('.List`{""`}(.KList) => [.KList])) [anywhere]

//AnnoConstantModList Type VarDecList ";" -> ConstantDec {cons("ConstantDec")}
rule    'ConstantDec(('AnnoConstantModList(A) => toKListWrap('AnnoConstantModList(A))),,_) [anywhere]
rule    'ConstantDec(('.List`{""`}(.KList) => [.KList]),,_) [anywhere]
rule    'ConstantDec(_,,('VarDecList(V) => toKListWrap('VarDecList(V)))) [anywhere]

//AnnoAbstractMethodModList TypeParams? ResultType Id "(" FormalParamList ")" Throws? ";" -> AbstractMethodDec {cons("AbstractMethodDec")}
rule    'AbstractMethodDec(('AnnoAbstractMethodModList(A) => toKListWrap('AnnoAbstractMethodModList(A))),,_) [anywhere]
rule    'AbstractMethodDec(('.List`{""`}(.KList) => [.KList]),,_) [anywhere]
rule    'AbstractMethodDec(_,,('_`,_(Params) => toKListWrap('_`,_(Params))),,_) [anywhere]
rule    'AbstractMethodDec(_,,('.List`{"`,"`}(.KList) => [.KList]),,_) [anywhere]

//    "@" TypeName "(" ElemValPairList ")" 	-> Anno {cons("Anno")}
rule    'Anno(_,,('ElemValPairList(E) => toKListWrap('ElemValPairList(E)))) [anywhere]
rule    'Anno(_,,('.List`{"`,"`}(.KList) => [.KList])) [anywhere]

//"{" ElemValList     "}" -> ElemVal {cons("ElemValArrayInit")}
//"{" ElemValList "," "}" -> ElemVal {cons("ElemValArrayInit")}
rule    'ElemValArrayInit(('ElemValList(E) => toKListWrap('ElemValList(E))))    [anywhere]
rule    'ElemValArrayInit(('.List`{"`,"`}(.KList) => [.KList]))    [anywhere]

//    AnnoDecHead "{" AnnoElemDecList "}" -> AnnoDec {cons("AnnoDec")}
rule    'AnnoDec(_,,('AnnoElemDecList(A) => toKListWrap('AnnoElemDecList(A)))) [anywhere]
rule    'AnnoDec(_,,('.List`{""`}(.KList) => [.KList])) [anywhere]

//    AbstractMethodModList Type Id "(" ")" DefaultVal? ";" -> AnnoElemDec {cons("AnnoMethodDec")}
rule    'AnnoMethodDec(('AbstractMethodModList(A) => toKListWrap('AbstractMethodModList(A))),,_) [anywhere]
rule    'AnnoMethodDec(('.List`{""`}(.KList) => [.KList]),,_) [anywhere]

//AnnoInterfaceModList "@" "interface" Id -> AnnoDecHead {cons("AnnoDecHead")}
rule    'AnnoDecHead(('AnnoInterfaceModList(I) => toKListWrap('AnnoInterfaceModList(I))),,_)   [anywhere]
rule    'AnnoDecHead(('.List`{""`}(.KList) => [.KList]),,_) [anywhere]
endmodule