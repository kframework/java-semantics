module LIST-SYNTAX

/*A module for list only, for the easy of implementation and management.
 There are six lists ((formal)params, dims, dimexps, exps, varinits, catchclauses)
 already defined before, because there is no automatic refactor for rename, and also those
 defined are used in semantic rules, we leave them unchanged.*/

syntax InterfaceTypeList         ::= List{InterfaceType,","}         [klabel('InterfaceTypeList)]
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
syntax Dims         ::= List{Dim,""} // [klabel('DimList)]
syntax DimExps      ::= List{DimExp,""} [strict]
syntax VarInits     ::= List{VarInit, ","} // [klabel('VarInitList)]
syntax CatchClauses ::= List{CatchClause,""} [klabel('CatchClauseList), strict]
syntax Params       ::= List{Param, ","}   // [klabel('FormalParamList)]

//context 'FormalParamList(HOLE,,_) [result(ExtKResult)]
//context 'FormalParamList(_,,HOLE) [result(ExtKResult)]

syntax KLabel::= "'DimList"
               | "'DimExprList"
               | "'ExprList"
               | "'VarInitList"
               | "'CatchClauseList"
               | "'FormalParamList"

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
/*Below is simple macros for changing from UserList(parser output) to KListWrap(many rules using),
but it is not easy to manipulate them to allow single removal for a particular List.
I change back to the stupid way temproraily, because that would ease single removal.
*/
//rule '.List`{""`}(.KList)   => [.KList]                             [macro]
//rule '.List`{"."`}(.KList)  => [.KList]                             [macro]
//rule '.List`{"&"`}(.KList)  => [.KList]                             [macro]
//rule '.List`{"`,"`}(.KList) => [.KList]                             [macro]
//rule 'SwitchLabelList(Hd,,[Tl:KList])           => [Hd,,Tl]         [macro]
//rule 'SwitchGroupList(Hd,,[Tl:KList])           => [Hd,,Tl]         [macro]
//rule 'BlockStmList(Hd,,[Tl:KList])              => [Hd,,Tl]         [macro]
//rule 'InterfaceTypeList(Hd,,[Tl:KList])         => [Hd,,Tl]         [macro]
//rule 'ExceptionTypeList(Hd,,[Tl:KList])         => [Hd,,Tl]         [macro]
//rule 'IdList(Hd,,[Tl:KList])                    => [Hd,,Tl]         [macro]
//rule 'TypeDecList(Hd,,[Tl:KList])               => [Hd,,Tl]         [macro]
//rule 'VarDecList(Hd,,[Tl:KList])                => [Hd,,Tl]         [macro]
//rule 'ImportDecList(Hd,,[Tl:KList])             => [Hd,,Tl]         [macro]
//rule 'ActualTypeArgList(Hd,,[Tl:KList])         => [Hd,,Tl]         [macro]
//rule 'ClassOrInterfaceTypeList(Hd,,[Tl:KList])  => [Hd,,Tl]         [macro]
//rule 'TypeParamList(Hd,,[Tl:KList])             => [Hd,,Tl]         [macro]
//rule 'AbstractMethodModList(Hd,,[Tl:KList])     => [Hd,,Tl]         [macro]
//rule 'AnnoAbstractMethodModList(Hd,,[Tl:KList]) => [Hd,,Tl]         [macro]
//rule 'AnnoMethodModList(Hd,,[Tl:KList])         => [Hd,,Tl]         [macro]
//rule 'AnnoVarModList(Hd,,[Tl:KList])            => [Hd,,Tl]         [macro]
//rule 'AnnoClassModList(Hd,,[Tl:KList])          => [Hd,,Tl]         [macro]
//rule 'AnnoConstrModList(Hd,,[Tl:KList])         => [Hd,,Tl]         [macro]
//rule 'AnnoConstantModList(Hd,,[Tl:KList])       => [Hd,,Tl]         [macro]
//rule 'AnnoFieldModList(Hd,,[Tl:KList])          => [Hd,,Tl]         [macro]
//rule 'AnnoInterfaceModList(Hd,,[Tl:KList])      => [Hd,,Tl]         [macro]
//rule 'AnnoList(Hd,,[Tl:KList])                  => [Hd,,Tl]         [macro]
//rule 'AnnoElemDecList(Hd,,[Tl:KList])           => [Hd,,Tl]         [macro]
//rule 'InterfaceMemberDecList(Hd,,[Tl:KList])    => [Hd,,Tl]         [macro]
//rule 'ElemValPairList(Hd,,[Tl:KList])           => [Hd,,Tl]         [macro]
//rule 'ElemValList(Hd,,[Tl:KList])               => [Hd,,Tl]         [macro]
//rule 'StringPartList(Hd,,[Tl:KList])            => [Hd,,Tl]         [macro]
//rule 'ClassBodyDecList(Hd,,[Tl:KList])          => [Hd,,Tl]         [macro]
//rule 'DimList(Hd,,[Tl:KList])         => [Hd,,Tl]    [macro]
//rule 'DimExprList(Hd,,[Tl:KList])     => [Hd,,Tl]    [macro]
//rule 'ExprList(Hd,,[Tl:KList])        => [Hd,,Tl]    [macro]
//rule 'VarInitList(Hd,,[Tl:KList])     => [Hd,,Tl]    [macro]
//rule 'CatchClauseList(Hd,,[Tl:KList]) => [Hd,,Tl]    [macro]
//rule 'FormalParamList(Hd,,[Tl:KList]) => [Hd,,Tl]    [macro]

syntax KItem ::= toKListWrap(K) [function]
                | toKListWrap(K, KListWrap) [function]

rule toKListWrap(UL) => toKListWrap(UL,[.KList])

rule toKListWrap(Label:KLabel(Hd,,Tl), [L:KList]) => toKListWrap(Tl, [L,,Hd])
rule toKListWrap(Label:KLabel(.KList), KL:KListWrap) => KL


//AnnoClassModList "class" Id  TypeParams? Super? Interfaces? -> ClassDecHead {cons("ClassDecHead")}
rule    'ClassDecHead(('AnnoClassModList(A) => toKListWrap('AnnoClassModList(A))),,_) [macro]
rule    'ClassDecHead(('.List`{""`}(.KList) => [.KList]),,_) [macro]

//PackageDec? ImportDecList TypeDecList -> CompilationUnit   {cons("CompilationUnit")}
rule    'CompilationUnit(_,,('ImportDecList(I) => toKListWrap('ImportDecList(I))),,_) [macro]
rule    'CompilationUnit(_,,('.List`{""`}(.KList) => [.KList]),,_) [macro]
rule    'CompilationUnit(_,,('TypeDecList(T) => toKListWrap('TypeDecList(T))))[macro]


// "{" ClassBodyDecList "}" -> ClassBody {cons("ClassBody")}
rule    'ClassBody(('ClassBodyDecList(C) => toKListWrap('ClassBodyDecList(C)))) [macro]
rule    'ClassBody(('.List`{""`}(.KList) => [.KList])) [macro]

//AnnoMethodModList TypeParams? ResultType Id "(" FormalParamList ")" Throws?  -> MethodDecHead {cons("MethodDecHead")}
rule    'MethodDecHead(('AnnoMethodModList(A) => toKListWrap('AnnoMethodModList(A))),,_) [macro]
rule    'MethodDecHead(('.List`{""`}(.KList) => [.KList]),,_) [macro]
rule    'MethodDecHead(_,,('FormalParamList(Params) => toKListWrap('FormalParamList(Params))),,_) [macro]
rule    'MethodDecHead(_,,('.List`{"`,"`}(.KList) => [.KList]),,_) [macro]

//"{" BlockStmList "}" -> Block {cons("Block")}
rule    'Block('BlockStmList(B) => toKListWrap('BlockStmList(B))) [macro]
rule    'Block(('.List`{""`}(.KList) => [.KList])) [macro]

//MethodSpec "(" ExprList ")" -> Expr {cons("Invoke")}
rule    'Invoke(_,,('ExprList(Exps) => toKListWrap('ExprList(Exps)))) [macro]
rule    'Invoke(_,,('.List`{"`,"`}(.KList) => [.KList])) [macro]

//"\"" StringPartList "\"" -> StringLiteral {cons("String")}
rule    'String(('StringPartList(S) => toKListWrap('StringPartList(S)))) [macro]
rule    'String(('.List`{""`}(.KList) => [.KList])) [macro]

//AnnoVarModList Type       VarDecId -> FormalParam {cons("Param")}
//rule    'Param(('AnnoVarModList(A) => toKListWrap('AnnoVarModList(A))),,_) [macro]
//rule    'Param(('.List`{""`}(.KList) => [.KList]),,_) [macro]

//AnnoVarModList Type   "..."    VarDecId -> FormalParam {cons("VarArityParam")}
//rule    'VarArityParam(('AnnoVarModList(A) => toKListWrap('AnnoVarModList(A))),,_) [macro]
//rule    'VarArityParam(('.List`{""`}(.KList) => [.KList]),,_) [macro]


//AnnoVarModList Type VarDecList -> LocalVarDec {prefer, cons("LocalVarDec")}
//rule    'LocalVarDec(('AnnoVarModList(A) => toKListWrap('AnnoVarModList(A))),,_) [macro]
//rule    'LocalVarDec(('.List`{""`}(.KList) => [.KList]),,_) [macro]
rule    'LocalVarDec(_,,('VarDecList(A) => toKListWrap('VarDecList(A)))) [macro]

//"new" ArrayBaseType DimExpr+ Dim*  -> ArrayCreationExpr {cons("NewArray")}
//"new" ArrayBaseType Dim+ ArrayInit -> ArrayCreationExpr {cons("NewArray")}
rule    'NewArray(_,,('DimExprList(D) => toKListWrap('DimExprList(D))),,_) [macro]
rule    'NewArray(_,,('DimList(D) => toKListWrap('DimList(D))),,_) [macro]
rule    'NewArray(_,,('.List`{""`}(.KList) => [.KList])) [macro]

//"{"   VarInitList   "}" -> ArrayInit {cons("ArrayInit")}
//"{" VarInitList "," "}" -> ArrayInit {cons("ArrayInit")}
rule    'ArrayInit(('VarInitList(V) => toKListWrap('VarInitList(V)))) [macro]
rule    'ArrayInit(('.List`{"`,"`}(.KList) => [.KList])) [macro]

//"for" "(" LocalVarDec ";" Expr? ";" ExprList ")" Stm -> Stm {cons("For")}
//"for" "(" ExprList ";" Expr? ";" ExprList ")" Stm -> Stm {cons("For")}
rule    'For(_,,('ExprList(Exps) => toKListWrap('ExprList(Exps))),,_) [macro]
rule    'For(_,,('.List`{"`,"`}(.KList) => [.KList]),,_) [macro]

// AnnoConstrModList TypeParams? Id "(" FormalParamList ")" Throws? -> ConstrHead {cons("ConstrDecHead")}
rule    'ConstrDecHead(('AnnoConstrModList(A) => toKListWrap('AnnoConstrModList(A))),,_) [macro]
rule    'ConstrDecHead(('.List`{""`}(.KList) => [.KList]),,_) [macro]
rule    'ConstrDecHead(_,,('FormalParamList(Params) => toKListWrap('FormalParamList(Params))),,_) [macro]
rule    'ConstrDecHead(_,,('.List`{"`,"`}(.KList) => [.KList]),,_) [macro]

//"{" ConstrInv? BlockStmList "}" -> ConstrBody {cons("ConstrBody")}
rule    'ConstrBody(_,,('BlockStmList(B) => toKListWrap('BlockStmList(B)))) [macro]
rule    'ConstrBody(_,,('.List`{""`}(.KList) => [.KList])) [macro]

// TypeArgs? "this"  "(" ExprList ")" ";" -> ConstrInv {cons("AltConstrInv")}
rule    'AltConstrInv(_,,('ExprList(Exps) => toKListWrap('ExprList(Exps)))) [macro]
rule    'AltConstrInv(_,,('.List`{"`,"`}(.KList) => [.KList])) [macro]

// TypeArgs? "super" "(" ExprList ")" ";" -> ConstrInv {cons("SuperConstrInv")}
rule    'SuperConstrInv(_,,('ExprList(Exps) => toKListWrap('ExprList(Exps)))) [macro]
rule    'SuperConstrInv(_,,('.List`{"`,"`}(.KList) => [.KList])) [macro]

// Expr "." TypeArgs? "super" "(" ExprList ")" ";" -> ConstrInv {cons("QSuperConstrInv")}
rule    'QSuperConstrInv(_,,('ExprList(Exps) => toKListWrap('ExprList(Exps)))) [macro]
rule    'QSuperConstrInv(_,,('.List`{"`,"`}(.KList) => [.KList])) [macro]

//AnnoFieldModList Type VarDecList ";" -> FieldDec {cons("FieldDec")}
rule    'FieldDec(('AnnoFieldModList(A) => toKListWrap('AnnoFieldModList(A))),,_) [macro]
rule    'FieldDec(('.List`{""`}(.KList) => [.KList]),,_) [macro]
rule    'FieldDec(_,,('VarDecList(V) => toKListWrap('VarDecList(V)))) [macro]

//"new" TypeArgs? ClassOrInterfaceType "(" ExprList ")" ClassBody? -> Expr {cons("NewInstance")}
rule    'NewInstance(_,,('ExprList(Exps) => toKListWrap('ExprList(Exps))),,_) [macro]
rule    'NewInstance(_,,('.List`{"`,"`}(.KList) => [.KList]),,_) [macro]

// Expr "." "new" TypeArgs? Id         TypeArgs? "(" ExprList ")" ClassBody? -> Expr {cons("QNewInstance")}
rule    'QNewInstance(_,,('ExprList(Exps) => toKListWrap('ExprList(Exps))),,_) [macro]
rule    'QNewInstance(_,,('.List`{"`,"`}(.KList) => [.KList]),,_) [macro]

//"try" Block CatchClauseList -> Stm {cons("Try")}
//"try" Block CatchClauseList "finally" Block -> Stm {cons("Try")}
//macros for changing CatchClauseList to KListWrap are removed

//"{" SwitchGroupList SwitchLabelList "}" -> SwitchBlock {cons("SwitchBlock")}
rule    'SwitchBlock(('SwitchGroupList(SG) => toKListWrap('SwitchGroupList(SG))),,_) [macro]
rule    'SwitchBlock(_,,('SwitchLabelList(SL) => toKListWrap('SwitchLabelList(SL)))) [macro]
rule    'SwitchBlock(_,,('.List`{""`}(.KList) => [.KList]),,_) [macro]

// SwitchLabelPlusList BlockStmPlusList -> SwitchGroup  {cons("SwitchGroup")}
rule    'SwitchGroup(('SwitchLabelList(SL) => toKListWrap('SwitchLabelList(SL))),,_)    [macro]
rule    'SwitchGroup(_,,('BlockStmList(B) => toKListWrap('BlockStmList(B))))    [macro]


//AnnoList "package" PackageName ";" -> PackageDec {cons("PackageDec")}
rule    'PackageDec(('AnnoList(A) => toKListWrap('AnnoList(A))),,_) [macro]
rule    'PackageDec(('.List`{""`}(.KList) => [.KList]),,_) [macro]

//IdList -> PackageName {cons("PackageName")}
rule    'PackageName(('IdList(I) => toKListWrap('IdList(I)))) [macro]

//"<" ActualTypeArgList ">" -> TypeArgs {cons("TypeArgs")}
rule    'TypeArgs(('ActualTypeArgList(A) => toKListWrap('ActualTypeArgList(A))))    [macro]

//"extends" ClassOrInterfaceTypeList -> TypeBound {cons("TypeBound")}
rule    'TypeBound(('ClassOrInterfaceTypeList(C) => toKListWrap('ClassOrInterfaceTypeList(C))))    [macro]

// "<" TypeParamList ">" -> TypeParams {cons("TypeParams")}
rule    'TypeParams(('TypeParamList(A) => toKListWrap('TypeParamList(A))))    [macro]

//"implements" InterfaceTypeList -> Interfaces {cons("ImplementsDec")}
rule    'ImplementsDec(('InterfaceTypeList(I) => toKListWrap('InterfaceTypeList(I))))   [macro]

//"throws" ExceptionTypeList -> Throws {cons("ThrowsDec")}
rule    'ThrowsDec(('ExceptionTypeList(I) => toKListWrap('ExceptionTypeList(I))))   [macro]

//Id DimPlusList -> VarDecId {cons("ArrayVarDecId")}
rule    'ArrayVarDecId(_,,('DimList(D) => toKListWrap('DimList(D))))  [macro]

//InterfaceDecHead "{" InterfaceMemberDecList "}" -> InterfaceDec {cons("InterfaceDec")}
rule    'InterfaceDec(_,,('InterfaceMemberDecList(I) => toKListWrap('InterfaceMemberDecList(I))))   [macro]
rule    'InterfaceDec(_,,('.List`{""`}(.KList) => [.KList])) [macro]

//AnnoInterfaceModList "interface" Id TypeParams? ExtendsInterfaces? -> InterfaceDecHead {cons("InterfaceDecHead")}
rule    'InterfaceDecHead(('AnnoInterfaceModList(I) => toKListWrap('AnnoInterfaceModList(I))),,_)   [macro]
rule    'InterfaceDecHead(('.List`{""`}(.KList) => [.KList]),,_) [macro]

//"extends" InterfaceTypeList -> ExtendsInterfaces {cons("ExtendsInterfaces")}
rule    'ExtendsInterfaces(('InterfaceTypeList(I) => toKListWrap('InterfaceTypeList(I))))   [macro]

//AnnoClassModList "enum" Id Interfaces? -> EnumDecHead {cons("EnumDecHead")}
rule    'EnumDecHead(('AnnoClassModList(A) => toKListWrap('AnnoClassModList(A))),,_) [macro]
rule    'EnumDecHead(('.List`{""`}(.KList) => [.KList]),,_) [macro]

//    "{" EnumConstList     EnumBodyDecs? "}" -> EnumBody {cons("EnumBody")}
//    "{" EnumConstList "," EnumBodyDecs? "}" -> EnumBody {cons("EnumBody")}
rule    'EnumBody(('EnumConstList(E) => toKListWrap(('EnumConstList(E)))),,_) [macro]
rule    'EnumBody(('.List`{"`,"`}(.KList) => [.KList]),,_) [macro]

//    Id EnumConstArgs? ClassBody?  -> EnumConst {cons("EnumConst")}
rule    'EnumConst(_,,'Some(('ExprList(Exps) => toKListWrap('ExprList(Exps)))),,_) [macro]
rule    'EnumConst(_,,'Some(('.List`{"`,"`}(.KList) => [.KList])),,_) [macro]

//    ";" ClassBodyDecList -> EnumBodyDecs {cons("EnumBodyDecs")}
rule	'EnumBodyDecs(('ClassBodyDecList(C) => toKListWrap('ClassBodyDecList(C)))) [macro]
rule    'EnumBodyDecs(('.List`{""`}(.KList) => [.KList])) [macro]

//AnnoConstantModList Type VarDecList ";" -> ConstantDec {cons("ConstantDec")}
rule    'ConstantDec(('AnnoConstantModList(A) => toKListWrap('AnnoConstantModList(A))),,_) [macro]
rule    'ConstantDec(('.List`{""`}(.KList) => [.KList]),,_) [macro]
rule    'ConstantDec(_,,('VarDecList(V) => toKListWrap('VarDecList(V)))) [macro]

//AnnoAbstractMethodModList TypeParams? ResultType Id "(" FormalParamList ")" Throws? ";" -> AbstractMethodDec {cons("AbstractMethodDec")}
rule    'AbstractMethodDec(('AnnoAbstractMethodModList(A) => toKListWrap('AnnoAbstractMethodModList(A))),,_) [macro]
rule    'AbstractMethodDec(('.List`{""`}(.KList) => [.KList]),,_) [macro]
rule    'AbstractMethodDec(_,,('FormalParamList(Params) => toKListWrap('FormalParamList(Params))),,_) [macro]
rule    'AbstractMethodDec(_,,('.List`{"`,"`}(.KList) => [.KList]),,_) [macro]

//    "@" TypeName "(" ElemValPairList ")" 	-> Anno {cons("Anno")}
rule    'Anno(_,,('ElemValPairList(E) => toKListWrap('ElemValPairList(E)))) [macro]
rule    'Anno(_,,('.List`{"`,"`}(.KList) => [.KList])) [macro]

//"{" ElemValList     "}" -> ElemVal {cons("ElemValArrayInit")}
//"{" ElemValList "," "}" -> ElemVal {cons("ElemValArrayInit")}
rule    'ElemValArrayInit(('ElemValList(E) => toKListWrap('ElemValList(E))))    [macro]
rule    'ElemValArrayInit(('.List`{"`,"`}(.KList) => [.KList]))    [macro]

//    AnnoDecHead "{" AnnoElemDecList "}" -> AnnoDec {cons("AnnoDec")}
rule    'AnnoDec(_,,('AnnoElemDecList(A) => toKListWrap('AnnoElemDecList(A)))) [macro]
rule    'AnnoDec(_,,('.List`{""`}(.KList) => [.KList])) [macro]

//    AbstractMethodModList Type Id "(" ")" DefaultVal? ";" -> AnnoElemDec {cons("AnnoMethodDec")}
rule    'AnnoMethodDec(('AbstractMethodModList(A) => toKListWrap('AbstractMethodModList(A))),,_) [macro]
rule    'AnnoMethodDec(('.List`{""`}(.KList) => [.KList]),,_) [macro]

//AnnoInterfaceModList "@" "interface" Id -> AnnoDecHead {cons("AnnoDecHead")}
rule    'AnnoDecHead(('AnnoInterfaceModList(I) => toKListWrap('AnnoInterfaceModList(I))),,_)   [macro]
rule    'AnnoDecHead(('.List`{""`}(.KList) => [.KList]),,_) [macro]
endmodule