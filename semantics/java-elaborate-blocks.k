require "java-core.k"
require "java-var-lookup.k"
require "java-process-type-names.k"
require "java-process-classes.k"

/* Elaborate the composition of code blocks of a class - the last step of preprocessing.
During this phase we inspect the contents of method bodies, instance initializers and
static initializers of a class and perform the following transformations:
  - each variable name x is resolved into either:
    - x - a local var
    - Class.x - a static var defined in the class Class
    - field(obj, Class, x) - a field of object obj declared in the class Class.
      obj could also be 'This.
  - each method name is resolved into either:
    - Class.m - a static method defined in the class Class
    - method(obj, Class, x) - an instance method of object obj declared in the class Class.
      obj could also be 'This. The actual version of the method will be looked up at runtime.
  - each method signature is resolved into its appropriate overloaded version. To
    denote the version, each actual parameter will be casted to the type of the actual parameter.
  - each expression Exp will be replaced with a corresponding typed expression Exp :: T,
    T being the compile-time type of the expression.

    During elaboration, elaborated members will be wrapped into elab().
*/

// todo: Anything that evaluates to Type should be naked, anything else - not.

module JAVA-ELABORATE-BLOCKS
    imports JAVA-CORE
    imports JAVA-VAR-LOOKUP //for localVar
    imports JAVA-PROCESS-TYPE-NAMES //for toPackage()
    imports JAVA-PROCESS-CLASSES //for paramImpl

syntax K ::= "elaborateBlocks" "(" K ")" [strict] //Elaborate the blocks inside all classes.
                                        //K = setWrap(Set) - the set of all classes.
           | "elabMethods" "(" Map ")"  //Elaborates the methods of the current class.
                                        //The map contains already elaborated methods.
                                        //Initially the map is empty.
           | "elabInstanceInit"
           | "elabStaticInit"
           | "elabInit" "(" K ")"       //The first step of elaboration. Performs some initialization.
           | "elab" "(" K ")"           //Elaborates the given statement/expression.
           | "elabDispose" "(" K ")"    //Intermediate state between elab and elabRes - all subterms were already elaborated.
                                        //Responsible for deleting the elabRes() wrappers of subterms.

//Wraps the elaboration result. Since elaboration may happen at both ElaborateBlocksPhase and ExecutionPhase,
//it cannot be KResult. Actually it is not KResult for HOLE, but is for CHOLE.
syntax K ::= "elabRes" "(" K ")"

//Chain of responsibility.
//Evaluate the first argument. if it is KResult (except noValue) or elabRes(), the result of the ?? expression is
//the result of the first argument. Otherwise, if the first argument evaluates to noValue, the result of the
//?? expression is the result of the second argument.
syntax K ::= K "??" K [right]

rule [chainOfResponsibilityHeat]:
    (. => Arg1) ~> (Arg1:K => CHOLE) ?? _
when
    notBool isElab(Arg1)

rule [chainOfResponsibilityResult1]:
    ElabRes:K ~> (CHOLE ?? _) => ElabRes
when isElab(ElabRes) andBool (ElabRes =/=K noValue)

rule [chainOfResponsibilityResult2]:
    noValue ~> (CHOLE ?? K:K) => K

//Elaboration result of a field access exp.
syntax K ::= "lookupField" "(" K    //Qualifier exp
                           "," Type //Precise type where the field is defined
                           "," Id   //X - field name
                           ")"
//Elaboration result of a static field access expression
            | "lookupStaticField" "(" Type //Precise type where the field is defined
                                  "," Id   //X - field name
                                  ")"

//Elaboration result of expressions new T[]...
syntax K ::= "newArrayImpl" "("
                Type ","  // T - type of each allocated element. So for new int[1][1][][], T will be "arrayOf arrayOf int".
                K ","     // 'ListWrap(Dims) - array dimensions
                K ","     // InitExp - expression used to initialize each array element, or .K if arg 4 is specified.
                List{K}   //InitContent - array initializer, if any, or .K if arg 3 is specified.
                          //From arguments 3 and 4 just one may be specified. This initializer is for the whole array,
                          //not for each element as the previous one.
             ")"


rule [elaborateBlocksStart]:
    <k> . => elaborateBlocks(getAllClasses) </k>
    <computationPhase> ProcessClassesPhase => ElaborateBlocksPhase </computationPhase>
    (<cuClass> _ </cuClass> => .Bag)

rule [elaborateBlocks]:
    <k>
      (. => elabMethods(MethodDecs) ~> elabInstanceInit ~> elabStaticInit)
      ~> elaborateBlocks(setWrap((SetItem(Class:ClassType) => .) _:Set))
      ...
    </k>
    <crntClass> _ => Class </crntClass>
    <classType> Class </classType>
    <methodDecs> MethodDecs:Map </methodDecs>

rule [elaborateBlocksDiscard]:
    elaborateBlocks(setWrap(.)) => .

rule [elabMethodsHeatMethod]:
    <k>
      (. => elabParams(Params) ~> elabInit(Body))
      ~> elabMethods( (Sig |-> _ => .Map) _)
      ...
    </k>
    <crntClass> Class:ClassType </crntClass>
    <classType> Class </classType>
    <methodDecs>
      Sig:K |-> methodClosure(MClass:ClassType, 'ListWrap(Params:List{K}), CT:ContextType, (Body:K => CHOLE)) :: MethodType:Type
      ...
    </methodDecs>
    <contextType> _ => CT </contextType>
    <elabEnv> _ => ListItem(stEnv(.Map)) </elabEnv>

rule [elabMethodsCoolMethod]:
    <k>
      (elabRes(Body:K) => .) ~> elabMethods(_:Map)
      ...
    </k>
    <crntClass> Class:ClassType </crntClass>
    <classType> Class </classType>
    <methodDecs>
      _ |-> methodClosure(_,_,_, (CHOLE => Body)) :: _
      ...
    </methodDecs>

//todo consider eliminating the label constrClosure since it leads to too much duplication.
rule [elabMethodsHeatConstrFirstLine]:
    <k>
      (. => elabParams(Params) ~> elabInit(FirstLine))
      ~> elabMethods( (Sig |-> _ => .Map) _)
      ...
    </k>
    <crntClass> Class:ClassType </crntClass>
    <classType> Class </classType>
    <methodDecs>
      Sig:K |-> constrClosure(MClass:ClassType, 'ListWrap(Params:List{K}), (FirstLine:K => CHOLE), Body:K) :: MethodType:Type
      ...
    </methodDecs>
    <contextType> _ => instanceCT </contextType>
    <elabEnv> _ => ListItem(stEnv(.Map)) </elabEnv>

rule [elabMethodsHeatConstrBody]:
    <k>
      (elabRes(FirstLine:K) => elabInit(Body)) ~> elabMethods(_:Map)
      ...
    </k>
    <crntClass> Class:ClassType </crntClass>
    <classType> Class </classType>
    <methodDecs>
      Sig:K |-> constrClosure(MClass:ClassType, 'ListWrap(Params:List{K}), CHOLE => FirstLine, Body:K => CHOLE) :: MethodType:Type
      ...
    </methodDecs>

rule [elabMethodsCoolConstr]:
    <k>
      (elabRes(Body:K) => .) ~> elabMethods(_:Map)
      ...
    </k>
    <crntClass> Class:ClassType </crntClass>
    <classType> Class </classType>
    <methodDecs>
      Sig:K |-> constrClosure(MClass:ClassType, 'ListWrap(Params:List{K}), FirstLine:K, CHOLE => Body) :: MethodType:Type
      ...
    </methodDecs>

rule [elabMethodsEnd]:
    elabMethods( .Map ) => .

rule [elabInstanceHeat]:
    <k> (. => elabInit(K)) ~> elabInstanceInit ...</k>
    <crntClass> Class:ClassType </crntClass>
    <classType> Class </classType>
    <instanceInit> K:K => CHOLE </instanceInit>
    <contextType> _ => instanceCT </contextType>
    <elabEnv> _ => ListItem(stEnv(.Map)) </elabEnv>
when K =/=K CHOLE

rule [elabInstanceEnd]:
    <k> elabRes(K) ~> elabInstanceInit => . ...</k>
    <crntClass> Class:ClassType </crntClass>
    <classType> Class </classType>
    <instanceInit> CHOLE => K </instanceInit>

rule [elabStaticHeat]:
    <k> (. => elabInit(K)) ~> elabStaticInit ...</k>
    <crntClass> Class:ClassType </crntClass>
    <classType> Class </classType>
    <staticInit> K:K => CHOLE </staticInit>
    <contextType> _ => staticCT </contextType>
    <elabEnv> _ => ListItem(stEnv(.Map)) </elabEnv>
when K =/=K CHOLE

rule [elabStaticEnd]:
    <k> elabRes(K) ~> elabStaticInit => . ...</k>
    <crntClass> Class:ClassType </crntClass>
    <classType> Class </classType>
    <staticInit> CHOLE => K </staticInit>

//Adds params to the <elabEnv>.
syntax K ::= "elabParams" "(" List{K} ")"
rule [elabParams]:
    <k> elabParams((paramImpl(T:Type, X:Id) => .List{K}) ,,_) ...</k>
    <elabEnv> ListItem(stEnv((. => X |-> T) _)) ...</elabEnv>

rule [elabParamsEnd]:
    elabParams(.List{K}) => .K

/*@ \section{Elaboration of code blocks} */

//todo if we make this rule structural, I expect many things to go wrong.
//It should make possible heating of components inside TypedExp.
//Actually that's wrong - TypedExp will never be wrapped inside elab() -
//in the worst case it will be wrapped inside elabInit(), then unwrapped by [elabInitNakedUnwrap].
rule [elabHeatDefault]:
    (. => elabInit(K)) ~> elab(KL:KLabel(ElabResL:List{K},, (K:K => CHOLE),, _))
when
    isElab(ElabResL) andBool notBool isElab(K) andBool notBool customElabInit(K)

rule [elabInitDefault]:
    elabInit(K) => elab(K)
when
    notBool customElab(K)
    andBool notBool (
             isElabIndependent(K)
      orBool (isRawVal(K) ==K true)
      orBool (getKLabel(K) ==KLabel 'TypeName)
      orBool (getKLabel(K) ==KLabel 'ArrayType)
      orBool (getKLabel(K) ==KLabel 'PackageName)
      orBool (getKLabel(K) ==KLabel 'PackageOrTypeName)
      orBool (getKLabel(K) ==KLabel 'Id)
      orBool (getKLabel(K) ==KLabel 'Lit)
    )                                             [structural]

//Will not match .K - is not KL(Ks). (.K) is matched by the next rule.
rule [elabInitNakedUnwrap]:
    elabInit((KL:KLabel(Ks:List{K}))) => KL(Ks)
when
           isElabIndependent(KL(Ks))
    orBool (isRawVal(KL(Ks)) ==K true)
    orBool (KL ==KLabel 'TypeName)
    orBool (KL ==KLabel 'ArrayType)
    orBool (KL ==KLabel 'PackageName)
    orBool (KL ==KLabel 'PackageOrTypeName)
    orBool (KL ==KLabel 'Id)
    orBool (KL ==KLabel 'Lit)                     [structural]

//Required when processing first constructor line of Object, which is .K
rule [elabInitDotK]:
    elabInit(.K) => elabRes(.K)

rule [elabCoolDefault]:
    (ElabK => .) ~> elab(_:KLabel(_,, (CHOLE => ElabK),, _))
when
    isElab(ElabK)

rule [elabDisposeStartDefault]:
    elab(KL:KLabel(ElabResL:List{K})) => elabDispose(KL(ElabResL))
when
            isElab(ElabResL)
    andBool (notBool customElabDispose(KL(ElabResL)))

rule [elabDisposeProcess]:
    elabDispose(KL:KLabel(_,, (K:K => unElab(K)),, _))
when
    isElabOnly(K)

rule [elabDisposeEnd]:
    elabDispose(KL:KLabel(Ks:List{K})) => elabRes(KL(Ks))
when
    isNotElab(Ks) andBool notBool customElabRes(KL)

//true if this label is elaborated, but is not un-elaborated.
syntax K ::= "isElabOnly" "(" K ")"                   [function]
rule isElabOnly(K:K) => getKLabel(K) ==KLabel 'elabRes`(_`)

syntax K ::= "isElabIndependent" "(" K ")"            [function]
rule isElabIndependent(K:K) =>
           (K ==K .K)
    orBool (isKResult(K) ==K true)
    orBool (isTypedExp(K) ==K true)

//Invoked during elabDispose. Transforms the term from elab result to normal.
syntax K ::= "unElab" "(" K ")"                 [function]
rule unElab(elabRes(K:K)) => K

//Computes to true if the given arg is a list of elaboration results, false otherwise.
syntax K ::= "isElab" "(" List{K} ")"           [function]
rule isElab((K:K => .List{K}) ,,_)
when (isElabOnly(K) ==K true) orBool (isElabIndependent(K) ==K true)

rule isElab(K:K,,_) => false
when notBool (
           (isElabOnly(K) ==K true)
    orBool (isElabIndependent(K) ==K true))

rule isElab(.List{K}) => true

//Computes to true if the given arg is a list of terms with none being elab-result only,
//false otherwise.
syntax K ::= "isNotElab" "(" List{K} ")"        [function]
rule isNotElab(K:K,,_) => false
when isElabOnly(K)

rule isNotElab((K:K => .List{K}),,_)
when notBool (isElabOnly(K) ==K true)

rule isNotElab(.List{K}) => true

//Returns true if the term needs special rules to be heated for elaboration, false otherwise.
syntax K ::= "customElabInit" "(" K ")"         [function]

rule customElabInit(.K) => false
rule customElabInit(KL:KLabel(_)) =>
           KL ==KLabel 'LocalVarDecStm
    orBool KL ==KLabel 'LocalVarDec
    orBool KL ==KLabel 'ClassOrInterfaceType
    orBool KL ==KLabel 'InterfaceType
    orBool KL ==KLabel 'ClassType

//Computes true if the given term needs special rules for elaboration, false otherwise
syntax K ::= "customElab" "(" K ")"             [function]

rule customElab(KL:KLabel(KLArgs:List{K})) =>
           (KL ==KLabel 'Block)
    orBool (KL ==KLabel 'For)
    orBool (KL ==KLabel 'Catch)

rule customElab(.K) => true

//Computes true if the given term needs special rules for the phase elab => elabDispose
syntax K ::= "customElabDispose" "(" K ")"       [function]

rule customElabDispose(KL:KLabel(Ks:List{K})) =>
           (KL ==KLabel 'Block)
    orBool (KL ==KLabel 'For)
    orBool (KL ==KLabel 'Catch)
    orBool (KL ==KLabel 'This)
    orBool (isType(KL(Ks)) ==K true)

//Computes true if the given term needs special rules for the phase elabDispose => elabRes
syntax K ::= "customElabRes" "(" KLabel ")"       [function]

rule customElabRes(KL:KLabel) =>
    isExpressionLabel(KL)
    //ex isElabNaked
    orBool (KL ==KLabel 'TypeName)
    orBool (KL ==KLabel 'ArrayType)
    orBool (KL ==KLabel 'PackageName)
    orBool (KL ==KLabel 'PackageOrTypeName)
    orBool (KL ==KLabel 'Field)
    orBool (KL ==KLabel 'SuperField)
    orBool (KL ==KLabel 'AmbName)
    orBool (KL ==KLabel 'ExprName)
    orBool (KL ==KLabel 'NewArray)

//Elaboration of blocks

rule [elabInitBlockOrFor]:
    <k> elabInit(KL:KLabel(Ks:List{K})) => elab(KL(Ks)) ...</k>
    <elabEnv> (. => ListItem(StEnvK)) ListItem(StEnvK:K) ...</elabEnv>
when
    (KL ==KLabel 'Block) orBool (KL ==KLabel 'For)

rule [elabDisposeBlockStart]:
    <k> elab(KL:KLabel(ElabResL:List{K})) => elabDispose(KL(ElabResL)) ...</k>
    <elabEnv> (ListItem(_) => .) ...</elabEnv>
when
    isElab(ElabResL)
    andBool ((KL ==KLabel 'Block) orBool (KL ==KLabel 'For) orBool (KL ==KLabel 'Catch))

//Local var decs desugaring

rule [LocalVarDecStmRed]:
    elab('ListWrap(_,,(
      'LocalVarDecStm('LocalVarDec(_,, TypeK:K,, 'ListWrap(Ks:List{K})))
      => 'LocalVarDec(TypeK,, 'ListWrap(Ks))
    ),,_))                                            [structural]

//Resolve the local var type, required to register the var in <elabEnv>
context elab('ListWrap(_,,'LocalVarDec(HOLE,,_),,_))

rule [VarDecMultiDesugar]:
    elab('ListWrap(_,,(
      'LocalVarDec(T:Type,, 'ListWrap(Var1:K,, Var2:K,, VarDecs:List{K}))
      => 'LocalVarDec(T,, 'ListWrap(Var1)),,
         'LocalVarDec(T,, 'ListWrap(Var2,, VarDecs))
    ),,_))                                            [structural]

rule [VarDecWithInitDesugar]:
    elab('ListWrap(_,,(
    'LocalVarDec(T:Type,, 'ListWrap('VarDec(X1:Id,,InitExp:K)))
    => 'LocalVarDec(T,, 'ListWrap('VarDec(X1:Id))),,
       'ExprStm('Assign('ExprName(X1),, InitExp))
    ),,_))
when
    getKLabel(InitExp) =/=KLabel 'ArrayInit           [structural]

rule [elabHeatLocalVarDec]:
    <k>
      (. => elabInit('LocalVarDec(T,, 'ListWrap('VarDec(X)))))
      ~> elab(KL:KLabel(ElabResL:List{K},,
        ('LocalVarDec(T:Type,, 'ListWrap('VarDec(X:Id))) => CHOLE),,
      _))
      ...
    </k>
    <elabEnv> ListItem(stEnv((. => X |-> T) _)) ...</elabEnv>
when
    isElab(ElabResL)

//Elaboration of rules in java-var-lookup

rule [elabAmbName]:
    elabDispose('AmbName(Ks:List{K})) => elabDispose('ExprName(Ks)) ?? 'TypeName(Ks) ?? 'PackageName('ListWrap(Ks))

rule [elabExprNameSimple]:
    elabDispose('ExprName(ResK:K)) => elabDispose(localVar(ResK)) ?? elabDispose('Field(ResK))

rule [elabExprNameQualified]:
    elabDispose('ExprName(K1:K,,K2:K)) => elabDispose('Field(K1,,K2))

rule [elabLocalVarOk]:
  <k> elabDispose(localVar(X:Id)) => elabRes(localVar(X) :: T) ...</k>
  <elabEnv> ListItem(stEnv(X |-> T:Type _)) ...</elabEnv>

rule [elabLocalVarNoValue]:
  <k> elabDispose(localVar(X:Id)) => noValue ...</k>
  <elabEnv> ListItem(stEnv(StEnv:Map)) ...</elabEnv>
when notBool (X in keys(StEnv))

rule [elabFieldUnqualified]:
    <k>
      elabDispose('Field(Arg:K))
      => elab('Field( 'This(.List{K}),, Arg )) ?? elab('Field( Class,, Arg))
         ?? outerStaticField(Class, Arg)
      ...
    </k>
    <crntClass> Class:ClassType </crntClass>
when
    isElab(Arg)

rule [FieldOfPackage]:
    elabDispose('Field( _:PackageId,, _:K )) => noValue  [structural]

rule [FieldOfNoValue]:
    elabDispose('Field( noValue,, _:K )) => noValue      [structural]

//Computationof instance and static environment of a class
//e.g. set of fields

//Searches the given field name in the given type, both static and instance context.
syntax K ::= "elabLookup" "("
                                      Id ","    //The field to search
                                      ClassType //The current class under search
                                  ")"

rule [elabLookupFoundInstance]:
    <k> elabLookup(X, CT:ClassType) => FEntry ...</k>
    <classType> CT </classType>
    <instanceEnv>... X |-> FEntry:K ...</instanceEnv>

rule [elabLookupFoundStatic]:
    <k> elabLookup(X, CT:ClassType) => fieldEntry(CT,X,T, staticCT) ...</k>
    <classType> CT </classType>
    <instanceEnv> InstanceEnv:Map </instanceEnv>
    <staticEnv>... X |-> L:Int ...</staticEnv>
    <store>... L |-> uninitialized(_,T:Type)  ...</store>
when
    notBool (X in keys(InstanceEnv))

rule [elabLookupNextClass]:
    <k> elabLookup(X:Id, CT:ClassType) => elabLookup(X, BaseClass) ...</k>
    <classType> CT </classType>
    <extends> BaseClass:ClassType </extends>
    <instanceEnv> InstanceEnv:Map </instanceEnv>
    <staticEnv> StaticEnv:Map </staticEnv>
when
    notBool ((X in keys(InstanceEnv)) orBool (X in keys(StaticEnv)))

rule [elabLookupNotFound]:
    elabLookup(X:Id, noClass) => noValue

rule [elabThisInstanceCT]:
    <k> elab('This(.List{K})) => elabRes('This(.List{K}) :: Class) ...</k>
    <crntClass> Class:ClassType </crntClass>
    <contextType> instanceCT </contextType>

rule [elabThisStaticCT]:
    <k> elab('This(.List{K})) => noValue ...</k>
    <contextType> staticCT </contextType>

rule [elabFieldQualRef]:
    elabDispose('Field(Qual:K :: Class:ClassType,, X:Id))
    => elabTypedExp(lookupField(Qual::Class, noClass, X), elabLookup(X, Class))

rule [elabFieldQualClass]:
    elabDispose('Field(Class:ClassType,, X:Id))
    => elabTypedExp(lookupStaticField(noClass,X), elabLookup(X, Class))

rule [elabSuperField]:
    <k>
      elabDispose('SuperField(X:Id))
      => elabTypedExp(lookupField('This(.List{K})::Class, noClass, X), elabLookup(X, BaseClass))
      ...
    </k>
    <crntClass> Class:ClassType </crntClass>
    <contextType> instanceCT </contextType>
    <classType> Class </classType>
    <extends> BaseClass:ClassType </extends>

//Computed the TypedExp expression for a given expression and its type
syntax K ::= "elabTypedExp" "(" K //The original expression to be typed
                            "," K //elabLookup(...), computes into fieldEntry(...) or noValue
                            ")"  [strict(2)]

rule elabTypedExp(lookupField(TE:TypedExp,_,X:Id), fieldEntry(Class:ClassType,_,T:Type, instanceCT)) => elabRes(lookupField(TE,Class,X) :: T)
rule elabTypedExp(lookupField(TE:TypedExp,_,X:Id), fieldEntry(Class:ClassType,_,T:Type, staticCT)) => elabRes(lookupStaticField(Class,X) :: T)
rule elabTypedExp(lookupStaticField(_,X:Id), fieldEntry(Class:ClassType,_,T:Type, staticCT)) => elabRes(lookupStaticField(Class,X) :: T)
rule elabTypedExp(_, noValue) => noValue

//HOLE is transformed into paramImpl
context elabInit('Catch(HOLE,, _))

//Catch creates a new env layer and saves its argument.
rule [elabInitCatch]:
    <k> elabInit('Catch(Param:KResult,, Body:K)) => elabParams(Param) ~> elab('Catch(Param,, Body)) ...</k>
    <elabEnv> (. => ListItem(StEnvK)) ListItem(StEnvK:K) ...</elabEnv>


/*@ \section{Elaboration of types} */

rule 'ClassOrInterfaceType(TypeK:K,, _) => TypeK [structural, anywhere]
rule 'InterfaceType(TypeK:K,, _) => TypeK        [structural, anywhere]
rule 'ClassType(TypeK:K,, _) => TypeK            [structural, anywhere]

//resolving fully qualified type names
// A name pack.p2.A is represented as:
// 'TypeName('PackageOrTypeName('PackageOrTypeName(pack),,p2),,A)

context 'PackageOrTypeName(HOLE,, _:K)

rule 'PackageOrTypeName(KRs:List{K},, K:K) => 'TypeName(KRs,,K) ?? 'PackageName('ListWrap(KRs,,K))
when isKResult(KRs)

//When we search for a class qualified by another class, we simply convert
//the qualifier into a package.

context 'TypeName(HOLE,,_:Id)

rule [TypeNameQualifiedClass]:
    'TypeName(ClassQ:ClassType,, X:Id) => 'TypeName(toPackage(ClassQ),, X)

rule [TypeNameQualifiedPackage]:
    'TypeName(Pack:PackageId,, X:Id) => typeNameQualifiedImpl(getNamesMap(Pack), X)

//Retrieves the ClassType for the given names map and simple class name
syntax K ::= "typeNameQualifiedImpl" "(" K "," Id ")" [strict(1)]

rule [typeNameQualifiedImplFound]:
    typeNameQualifiedImpl(mapWrap(X |-> Class:ClassType _), X:Id) => Class

rule [typeNameQualifiedImplNotFound]:
    typeNameQualifiedImpl(mapWrap(NamesMap:Map), X:Id) => noValue
when notBool X in keys(NamesMap)
//end of section

//limitations:
// - All string types should be referred by simple name "String".
//    Fully qualified name java.lang.String is not allowed.
// - No other classes with name "String" are possiblle.
rule [TypeNameString]:
    'TypeName(X:Id) => rtString
when
    Id2String(X) ==String "String"    [structural, anywhere]

rule [TypeNameInExecutionPhase]:
    <k> 'TypeName(X:Id) => Class ...</k>
    <computationPhase> ElaborateBlocksPhase </computationPhase>
    <crntClass> CrntClass:ClassType </crntClass>
    <classType> CrntClass </classType>
    <imports>... X |-> Class:ClassType ...</imports>

rule [TypeNameInExecutionPhaseFail]:
    <k> 'TypeName(X:Id) => noValue ...</k>
    <computationPhase> ElaborateBlocksPhase </computationPhase>
    <crntClass> CrntClass:ClassType </crntClass>
    <classType> CrntClass </classType>
    <imports> Imp:Map </imports>
when
    notBool (X in keys(Imp))

/*@ \section{Outer static fields} */

//Search for fields with this name in the outer classes of the given class, if any.
syntax K ::= "outerStaticField" "(" ClassType //The original class. We will search in
                                              //its outer classes
                                "," Id        //The field name
                                ")"

rule [outerStaticField]:
    <k>
      outerStaticField(Class:ClassType, X:Id)
      => elab('Field(EnclosingClass,, X)) ?? outerStaticField(EnclosingClass, X)
      ...
    </k>
    <classType> Class </classType>
    <enclosingClass> EnclosingClass:ClassType </enclosingClass>

rule [outerStaticFieldDiscard]:
    outerStaticField(noClass, _) => noValue

/*@ \section{Elaboration of numeric expressions} */

syntax K ::= "isExpressionLabel" "(" KLabel ")" [function]
rule isExpressionLabel(KL:KLabel) =>
           (KL ==KLabel 'localVar`(_`))

    //Infix operators
    /* ||  */ orBool (KL ==KLabel 'LazyOr)
    /* &&  */ orBool (KL ==KLabel 'LazyAnd)
    /* |   */ orBool (KL ==KLabel 'Or)
    /* ^   */ orBool (KL ==KLabel 'ExcOr)
    /* &   */ orBool (KL ==KLabel 'And)
    /* ==  */ orBool (KL ==KLabel 'Eq)
    /* !=  */ orBool (KL ==KLabel 'NotEq)
    /* <   */ orBool (KL ==KLabel 'Lt)
    /* >   */ orBool (KL ==KLabel 'Gt)
    /* <=  */ orBool (KL ==KLabel 'LtEq)
    /* >=  */ orBool (KL ==KLabel 'GtEq)
    /* <<  */ orBool (KL ==KLabel 'LeftShift)
    /* >>  */ orBool (KL ==KLabel 'RightShift)
    /* >>> */ orBool (KL ==KLabel 'URightShift)
    /* +   */ orBool (KL ==KLabel 'Plus)
    /* -   */ orBool (KL ==KLabel 'Minus)
    /* *   */ orBool (KL ==KLabel 'Mul)
    /* /   */ orBool (KL ==KLabel 'Div)
    /* %   */ orBool (KL ==KLabel 'Remain)

    //Prefix operators
    /* ++  */ orBool (KL ==KLabel 'PreIncr)
    /* --  */ orBool (KL ==KLabel 'PreDecr)
    /* !   */ orBool (KL ==KLabel 'Not)
    /* ~   */ orBool (KL ==KLabel 'Complement)
    /* +   */ //'Plus   - defined earlier
    /* -   */ //'Minus  - defined earlier

    //Postfix operators
    /* ++  */ orBool (KL ==KLabel 'PostIncr)
    /* --  */ orBool (KL ==KLabel 'PostDecr)

    //Ternary operators
      /* ? : */ orBool (KL ==KLabel 'Cond)
      /* =   */ orBool (KL ==KLabel 'Assign)

                orBool isCompoundAssignLabel(KL)
                orBool isNonNumericExp(KL)

syntax K ::= "isCompoundAssignLabel" "(" KLabel ")" [function]
rule isCompoundAssignLabel(KL:KLabel) =>
           (KL ==KLabel 'AssignPlus)
    orBool (KL ==KLabel 'AssignMinus)
    orBool (KL ==KLabel 'AssignMul)
    orBool (KL ==KLabel 'AssignDiv)
    orBool (KL ==KLabel 'AssignAnd)
    orBool (KL ==KLabel 'AssignOr)
    orBool (KL ==KLabel 'AssignExcOr)
    orBool (KL ==KLabel 'AssignRemain)
    orBool (KL ==KLabel 'AssignLeftShift)
    orBool (KL ==KLabel 'AssignRightShift)
    orBool (KL ==KLabel 'AssignURightShift)

syntax K ::= "isNonNumericExp" "(" KLabel ")"       [function]
rule isNonNumericExp(KL:KLabel) =>
           (KL ==KLabel 'ArrayAccess)
    orBool (KL ==KLabel 'NewInstance)
    orBool (KL ==KLabel 'InstanceOf)
    orBool (KL ==KLabel 'castImpl`(_`,_`))
    orBool (KL ==KLabel 'Invoke)

//It looks like isTypedExp(List{K}) doesn't work.
rule [elabBoolOnlyResultExpBinary]:
    elabDispose(KL:KLabel(TE1:TypedExp,, TE2:TypedExp)) => elabRes(KL(TE1,,TE2) :: bool)
when
           (KL ==KLabel 'LazyOr)
    orBool (KL ==KLabel 'LazyAnd)
    orBool (KL ==KLabel 'Eq)
    orBool (KL ==KLabel 'NotEq)
    orBool (KL ==KLabel 'Lt)
    orBool (KL ==KLabel 'Gt)
    orBool (KL ==KLabel 'LtEq)
    orBool (KL ==KLabel 'GtEq)

rule [elabBoolOnlyResultExpUnary]:
    elabDispose('Not(TE:TypedExp)) => elabRes('Not(TE) :: bool)

rule [elabBoolOperandBoolResultExp]:
    elabDispose(KL:KLabel(Exp1:K::bool,, Exp2:K::bool)) => elabRes(KL(Exp1::bool,, Exp2::bool) :: bool)
when
           (KL ==KLabel 'Or)
    orBool (KL ==KLabel 'ExcOr)
    orBool (KL ==KLabel 'And)

rule [elabBinaryNumOperandNumResultExp]:
    elabDispose(KL:KLabel(Exp1:K::NT1:NumericType,, Exp2:K::NT2:NumericType)) => elabRes(KL(Exp1::NT1,, Exp2::NT2) :: normalizeType(NT1,NT2))
when
           (KL ==KLabel 'Or)
    orBool (KL ==KLabel 'ExcOr)
    orBool (KL ==KLabel 'And)
    orBool (KL ==KLabel 'Plus)
    orBool (KL ==KLabel 'Minus)
    orBool (KL ==KLabel 'Mul)
    orBool (KL ==KLabel 'Div)
    orBool (KL ==KLabel 'Remain)

rule [elabBitShift]:
    elabDispose(KL:KLabel(Exp1:K::NT1:NumericType,, Exp2:K::NT2:NumericType)) => elabRes(KL(Exp1::NT1,, Exp2::NT2) :: normalizeType(NT1))
when
           (KL ==KLabel 'LeftShift)
    orBool (KL ==KLabel 'RightShift)
    orBool (KL ==KLabel 'URightShift)

rule [elabUnaryNumeric]:
    elabDispose(KL:KLabel(Exp:K::NT:NumericType)) => elabRes(KL(Exp::NT) :: normalizeType(NT))
when
           (KL ==KLabel 'Plus)
    orBool (KL ==KLabel 'Minus)
    orBool (KL ==KLabel 'Complement)

rule [elabPrefixPostfix]:
    elabDispose(KL:KLabel(Exp:K::NT:NumericType)) => elabRes(KL(Exp::NT) :: NT)
when
           (KL ==KLabel 'PreIncr)
    orBool (KL ==KLabel 'PreDecr)
    orBool (KL ==KLabel 'PostIncr)
    orBool (KL ==KLabel 'PostDecr)

rule [elabStringPlusAny]:
    elabDispose('Plus(Exp:K::rtString,, TE:TypedExp)) => elabRes('Plus(Exp::rtString,, TE) :: rtString)

rule [elabAnyPlusString]:
    elabDispose('Plus(TE:TypedExp,, Exp:K::rtString)) => elabRes('Plus(TE,, Exp::rtString) :: rtString)

rule [elabCond]:
    elabDispose('Cond(CondTE:TypedExp,, Exp1:K::T1:Type,, Exp2:K::T2:Type))
    => condType(T1, T2) ~> elabRes('Cond(CondTE,, Exp1::T1,, Exp2::T2) :: CHOLE)

//Used for the type of 'Cond and newArrayImpl
rule [elabResCoolExpType]:
    (T:Type => .K) ~> elabRes(_ :: (CHOLE => T))

//computes the type of a conditional expression
//Operands evaluate into types
syntax K ::= "condType" "(" Type "," Type ")" [strict]

rule [condTypeNoChar]:
    condType(T1:Type,T2:Type) => 'If(subtype(T1,T2),, T2,, T1)
when
    T1 =/=K char andBool T2 =/=K char

rule [condTypeSecondChar]:
    condType(T1:Type, char) => condType(char, T1)
when
    T1 =/=K char

rule [condTypeFirstChar]:
    condType(char, T2:Type) => 'If(subtype(char, T2),, T2,, int)

rule [elabAssign]:
    elabDispose('Assign(Exp1:K::T1:Type,, Exp2:K::T2:Type))
    =>
        #if (isNumericType(T1) ==K true)
          #then isInRange(Exp2::T1)::bool
          #else subtype(T2, T1)
        #fi ~> true? ~>
        elabRes('Assign(Exp1::T1,, Exp2::T2) :: T1)

rule [elabCompoundAssign]:
    elabDispose(KL:KLabel(Exp1:K::T1:Type,, TE:TypedExp)) => elabRes(KL(Exp1::T1,, TE) :: T1)
when
    isCompoundAssignLabel(KL)

/*@ \section{Elaboration of non-numeric expressions} */

//elab cast
rule 'CastRef(K1:K,, K2:K)  => castImpl(K1,K2)      [structural, anywhere]
rule 'CastPrim(K1:K,, K2:K) => castImpl(K1,K2)      [structural, anywhere]

//Case when Exp was initially a literal, and now is Val::Type
rule [elabCastImplElabIndep]:
    elabDispose(castImpl(T1:Type, Exp:K :: T2:Type)) => elabRes(castImpl(T1, Exp::T2) :: T1)

rule [elabNewInstance]:
      elabDispose('NewInstance(Arg1:K,, T:RefType,, Arg3:K,, Arg4:K))
      => elabRes('NewInstance(Arg1:K,, T:RefType,, Arg3:K,, Arg4:K) :: T)

rule [elabInstanceOf]:
    elabDispose('InstanceOf(TE:TypedExp,, RT2:RefType)) => elabRes('InstanceOf(TE,, RT2) :: bool)

context 'Lit('Class(HOLE))

rule [elabLitClass]:
    'Lit('Class(T:Type)) => elabRes('Lit('Class(T:Type)) :: class String2Id("java.lang.Class"))

rule [elabArrayAccess]:
    elabDispose('ArrayAccess(TargetExp:K::arrayOf T:Type,, IndexTE:TypedExp)) => elabRes('ArrayAccess(TargetExp::arrayOf T,, IndexTE) :: T)

rule [elabArrayLength]:
    elabDispose('Field(Qual:K :: arrayOf T:Type,, X:Id))
    => elabRes(lookupField(Qual:: arrayOf T, arrayOf T, X) :: int)
when
    Id2String(X) ==String "length"

context 'ArrayType(HOLE)
rule 'ArrayType(T:Type) => arrayOf T     [structural]

rule [NewArrayEmptyDims]:
    elabDispose('NewArray( (T:Type => arrayOf T),, _:K,,
        'ListWrap( ( 'Dim(.List{K}) => .List{K} ) ,,_:List{K}) ))
        [structural]

rule [NewArray]:
    elabDispose('NewArray(T:Type,, 'ListWrap(Dims:List{K}),, 'ListWrap(.List{K})))
    => getArrayType(T, Dims) ~> elabRes(newArrayImpl(T, 'ListWrap(Dims), default(T), .List{K}) :: CHOLE)
        [structural]

//computes the array type based on allocated elem type and number of allocated dimensions.
syntax K ::= "getArrayType" "(" Type "," List{K} ")"
rule getArrayType(T:Type, K:K,,Dims:List{K}) => getArrayType(arrayOf T, Dims) [structural]
rule getArrayType(T:Type, .List{K}) => T                                      [structural]

rule [ArrayInitPreprocess]:
    elabDispose('NewArray((T:Type => arrayOf T),, 'ListWrap(('Dim(.List{K}) => .List{K}),, _),, 'ArrayInit(_)))

rule [ArrayInit]:
    elabDispose('NewArray(arrayOf T:Type,, 'ListWrap(.List{K}),, 'ArrayInit('ListWrap(InitContent:List{K}))))
    => elabRes(newArrayImpl(T, 'ListWrap(count(InitContent)), .K, InitContent) :: arrayOf T)

//counts the number of elements in the List{K} list. Evaluates to an Int::int .
syntax K ::= "count" "(" List{K} ")"
           | "count" "(" Int "," List{K} ")"

rule count(Ks:List{K}) => count(0, Ks)
rule count(I:Int, K:K,, Ks:List{K}) => count(I +Int 1, Ks)
rule count(I:Int, .List{K}) => I::int

//Old rule, used when only method invocations were elaborated at both elaboration and execution time.
/*rule [elabInvoke]:
    'Invoke(Ks:List{K}) => elab('Invoke(Ks))
*/

//Elaborate all expressions once they reach the top of computation,
//both in elaboration and in execution phase.
//Performance: Using this rule instead of the rule above leads to execution performance decrease by 5%
//in helloWorld, with medium execution time rising from 9.6s to 10.1s
rule [elabExpressions]:
    KL:KLabel(Ks:List{K}) => elab(KL(Ks))
when
    isExpressionLabel(KL)

//Unwrap elaborated terms in execution phase, so that they could be executed.
rule [elabResInExecutionPhase]:
    <k> (elabRes(K:K) => K) ~> KL(_) ...</k>
    <computationPhase> ExecutionPhase </computationPhase>
when
    KL =/=KLabel 'elab`(_`)

endmodule
