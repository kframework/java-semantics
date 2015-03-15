module ELABORATION-CATEGORIES

/*@ Java KLabels that are processed by default heating/cooling rules of elaboration.
All KLabels that can be part of a code block during elaboration phase,
except those members of customElabChildren or isElabNaked groups.

This predicate should be disjoint with customElabChildren (no longer used) and isElabNaked
*/
syntax KItem ::= defaultElabHeating ( KLabel )                [function]

           /*(KL ==KLabel 'KListWrap)*/
rule defaultElabHeating('Some) => true
rule defaultElabHeating('None) => true
    /*orBool (KL ==KLabel 'Single)
rule defaultElabHeating('NamedEscape) => true
rule defaultElabHeating('OctaEscape1) => true
rule defaultElabHeating('OctaEscape2) => true
rule defaultElabHeating('OctaEscape3) => true
rule defaultElabHeating('UnicodeEscape) => true
rule defaultElabHeating('String) => true
rule defaultElabHeating('Chars) => true*/

rule defaultElabHeating('Assign) => true
rule defaultElabHeating('AssignMul) => true
rule defaultElabHeating('AssignDiv) => true
rule defaultElabHeating('AssignRemain) => true
rule defaultElabHeating('AssignPlus) => true
rule defaultElabHeating('AssignMinus) => true
rule defaultElabHeating('AssignLeftShift) => true
rule defaultElabHeating('AssignRightShift) => true
rule defaultElabHeating('AssignURightShift) => true
rule defaultElabHeating('AssignAnd) => true
rule defaultElabHeating('AssignExcOr) => true
rule defaultElabHeating('AssignOr) => true
rule defaultElabHeating('InstanceOf) => true
rule defaultElabHeating('Mul) => true
rule defaultElabHeating('Div) => true
rule defaultElabHeating('Remain) => true
rule defaultElabHeating('Plus) => true
rule defaultElabHeating('Minus) => true
rule defaultElabHeating('LeftShift) => true
rule defaultElabHeating('RightShift) => true
rule defaultElabHeating('URightShift) => true
rule defaultElabHeating('Lt) => true
rule defaultElabHeating('Gt) => true
rule defaultElabHeating('LtEq) => true
rule defaultElabHeating('GtEq) => true
rule defaultElabHeating('Eq) => true
rule defaultElabHeating('NotEq) => true
rule defaultElabHeating('LazyAnd) => true
rule defaultElabHeating('LazyOr) => true
rule defaultElabHeating('And) => true
rule defaultElabHeating('ExcOr) => true
rule defaultElabHeating('Or) => true
rule defaultElabHeating('Cond) => true
rule defaultElabHeating('PreIncr) => true
rule defaultElabHeating('PreDecr) => true
rule defaultElabHeating('Complement) => true
rule defaultElabHeating('Not) => true
rule defaultElabHeating('CastPrim) => true
rule defaultElabHeating('CastRef) => true
rule defaultElabHeating('PostIncr) => true
rule defaultElabHeating('PostDecr) => true
rule defaultElabHeating('Invoke) => true
rule defaultElabHeating('Method) => true
rule defaultElabHeating('SuperMethod) => true
rule defaultElabHeating('QSuperMethod) => true
rule defaultElabHeating('GenericMethod) => true
rule defaultElabHeating('ArrayAccess) => true
rule defaultElabHeating('Field) => true
rule defaultElabHeating('SuperField) => true
rule defaultElabHeating('QSuperField) => true
rule defaultElabHeating('NewArray) => true
//rule defaultElabHeating('UnboundWld) => true
rule defaultElabHeating('Dim) => true

    /*orBool (KL ==KLabel 'NewInstance)
rule defaultElabHeating('QNewInstance) => true
rule defaultElabHeating('Lit) => true
rule defaultElabHeating('Class) => true
rule defaultElabHeating('VoidClass) => true*/
rule defaultElabHeating('This) => true
rule defaultElabHeating('QThis) => true
    /*orBool (KL ==KLabel 'PackageDec)
rule defaultElabHeating('TypeImportDec) => true
rule defaultElabHeating('TypeImportOnDemandDec) => true //ok
rule defaultElabHeating('StaticImportDec) => true
rule defaultElabHeating('StaticImportOnDemandDec) => true
rule defaultElabHeating('AnnoDec) => true
rule defaultElabHeating('AnnoDecHead) => true
rule defaultElabHeating('AnnoMethodDec) => true
rule defaultElabHeating('Semicolon) => true
rule defaultElabHeating('DefaultVal) => true
rule defaultElabHeating('AbstractMethodDec) => true
rule defaultElabHeating('DeprAbstractMethodDec) => true
rule defaultElabHeating('ConstantDec) => true
rule defaultElabHeating('InterfaceDec) => true
rule defaultElabHeating('InterfaceDecHead) => true
rule defaultElabHeating('ExtendsInterfaces) => true
rule defaultElabHeating('EnumDec) => true
rule defaultElabHeating('EnumDecHead) => true
rule defaultElabHeating('EnumBody) => true
rule defaultElabHeating('EnumConst) => true
rule defaultElabHeating('EnumBodyDecs) => true
rule defaultElabHeating('ConstrDec) => true
rule defaultElabHeating('ConstrDecHead) => true
rule defaultElabHeating('ConstrBody) => true*/
rule defaultElabHeating('AltConstrInv) => true
    /*orBool (KL ==KLabel 'SuperConstrInv)*/
rule defaultElabHeating('QSuperConstrInv) => true
    /*orBool (KL ==KLabel 'StaticInit)
rule defaultElabHeating('InstanceInit) => true*/
rule defaultElabHeating('Empty) => true
rule defaultElabHeating('Labeled) => true
rule defaultElabHeating('ExprStm) => true
rule defaultElabHeating('If) => true
rule defaultElabHeating('AssertStm) => true
rule defaultElabHeating('Switch) => true
rule defaultElabHeating('SwitchBlock) => true
rule defaultElabHeating('SwitchGroup) => true
rule defaultElabHeating('Case) => true
rule defaultElabHeating('Default) => true //default keyword from switch
rule defaultElabHeating('While) => true
rule defaultElabHeating('DoWhile) => true
//rule defaultElabHeating('For) => true
//rule defaultElabHeating('ForEach) => true
rule defaultElabHeating('Break) => true
rule defaultElabHeating('Continue) => true
rule defaultElabHeating('Return) => true
rule defaultElabHeating('Throw) => true
rule defaultElabHeating('Synchronized) => true
rule defaultElabHeating('Try) => true
    /*orBool (KL ==KLabel 'Catch)
rule defaultElabHeating('LocalVarDecStm) => true
rule defaultElabHeating('LocalVarDec) => true
rule defaultElabHeating('Block) => true
rule defaultElabHeating('ClassDecStm) => true
    orBool (KL ==KLabel 'MethodDec)
rule defaultElabHeating('MethodDecHead) => true
rule defaultElabHeating('DeprMethodDecHead) => true
rule defaultElabHeating('Void) => true
rule defaultElabHeating('Param) => true
rule defaultElabHeating('VarArityParam) => true
rule defaultElabHeating('ThrowsDec) => true */
rule defaultElabHeating('NoMethodBody) => true
rule defaultElabHeating('ArrayInit) => true
    /*orBool (KL ==KLabel 'Anno)
rule defaultElabHeating('SingleElemAnno) => true
rule defaultElabHeating('MarkerAnno) => true
rule defaultElabHeating('ElemValPair) => true
rule defaultElabHeating('ElemValArrayInit) => true
rule defaultElabHeating('FieldDec) => true*/
rule defaultElabHeating('VarDec) => true
rule defaultElabHeating('ArrayVarDecId) => true
    /*orBool (KL ==KLabel 'ClassDec)
rule defaultElabHeating('ClassBody) => true
rule defaultElabHeating('ClassDecHead) => true
rule defaultElabHeating('SuperDec) => true
rule defaultElabHeating('ImplementsDec) => true
rule defaultElabHeating('CompilationUnit) => true
rule defaultElabHeating('PackageName) => true*/

rule defaultElabHeating('AmbName) => true
//rule defaultElabHeating('TypeName) => true
rule defaultElabHeating('ExprName) => true

rule defaultElabHeating('MethodName) => true
    /*orBool (KL ==KLabel 'PackageOrTypeName)
rule defaultElabHeating('TypeArgs) => true
rule defaultElabHeating('TypeArgs) => true
rule defaultElabHeating('Wildcard) => true
rule defaultElabHeating('WildcardUpperBound) => true
rule defaultElabHeating('TypeParam) => true
rule defaultElabHeating('TypeBound) => true
rule defaultElabHeating('TypeParams) => true
rule defaultElabHeating('ClassOrInterfaceType) => true
rule defaultElabHeating('ClassType) => true
    orBool (KL ==KLabel 'InterfaceType
rule defaultElabHeating('Member) => true
rule defaultElabHeating('TypeVar) => true
rule defaultElabHeating('ArrayType) => true
rule defaultElabHeating('Boolean) => true
rule defaultElabHeating('Byte) => true
rule defaultElabHeating('Short) => true
rule defaultElabHeating('Int) => true
rule defaultElabHeating('Long) => true
rule defaultElabHeating('Char) => true
rule defaultElabHeating('Float) => true
rule defaultElabHeating('Double) => true
rule defaultElabHeating('Null) => true
rule defaultElabHeating('Bool) => true
rule defaultElabHeating('True) => true
rule defaultElabHeating('False) => true
rule defaultElabHeating('Deci) => true
rule defaultElabHeating('Hexa) => true
rule defaultElabHeating('Octa) => true
rule defaultElabHeating('Public) => true
rule defaultElabHeating('Private) => true
rule defaultElabHeating('Protected) => true
rule defaultElabHeating('Abstract) => true
rule defaultElabHeating('Final) => true
rule defaultElabHeating('Static) => true
rule defaultElabHeating('Native) => true
rule defaultElabHeating('Transient) => true
rule defaultElabHeating('Volatile) => true
rule defaultElabHeating('StrictFP) => true
rule defaultElabHeating('Id) => true*/

//Auxiliary functions that should be default-heated
rule defaultElabHeating('stmtAndExp) => true
rule defaultElabHeating('CatchClauseList) => true
rule defaultElabHeating('FormalParamList) => true

/*@ Naked terms are those that should be computed directly into KResult during elaboration.
  Those are literals, types and packages. They are heated "as is", without being wrapped into elab().
  An exception is the class literal that is not executed during elaboration.

  Some auxiliary functions are also included in this cathegory in order to reduce the usage of elaboration wrappers.
*/
syntax KItem ::= isElabNaked ( K )                            [function]
rule isElabNaked(RV:RawVal) => true
rule isElabNaked('TypeName(_)) => true
rule isElabNaked('ClassOrInterfaceType(_)) => true
rule isElabNaked('InterfaceType(_)) => true
rule isElabNaked('ClassType(_)) => true
rule isElabNaked('ArrayType(_)) => true
rule isElabNaked('PackageName(_)) => true
rule isElabNaked('PackageOrTypeName(_)) => true
rule isElabNaked('Id(_)) => true
rule isElabNaked('Lit(InnerKL:KLabel(_))) => InnerKL =/=KLabel 'Class
rule isElabNaked(_:Id) => true //e.g. #token("Id", "XXX")(.KList)
rule isElabNaked(_) => false [owise]

/*@ Terms that should use custom elaboration rules. For those terms:
    - They will not be automatically heated from their parents into the elab() state.
    - They will not be automatically passed to elabDispose() state. Instead, those terms should have custom rules
      for elaboration start (heating) and elaboration end (cooling).
  Since all the automatic elaboration-related rules are an incredible mess, we have to put all the AST terms into this
    cathegory one by one, and eliminate automatic elaboration heating/cooling rules altogether.
*/
syntax KItem ::= customElabChildren ( KLabel )                [function]
rule customElabChildren(KL:KLabel) =>
           (KL ==KLabel 'KListWrap)       //Elaboration left-to-right if children contain variable declarations
    orBool (KL ==KLabel 'Block)           //Allocation of new <elabEnv>
    orBool (KL ==KLabel 'For)             //Allocation of new <elabEnv>
    orBool (KL ==KLabel 'Catch)           //Allocation of new <elabEnv>
    orBool (KL ==KLabel 'LocalVarDecStm)  //Desugaring into 'Assign and simple 'LocalVarDec
    orBool (KL ==KLabel 'LocalVarDec)     //Desugaring into 'Assign and simple 'LocalVarDec
    orBool (KL ==KLabel 'SuperConstrInv)  //Elaboration of qualifier, only at elab() step
    orBool (KL ==KLabel 'ClassDecStm)     //Elaboration of inner 'ClassDec
    orBool (KL ==KLabel 'NewInstance)     //Elaboration of qualifier, only at elab() step, anonymous body.
    orBool (KL ==KLabel 'QNewInstance)    //Elaboration of name into class, anonymous body.

endmodule
