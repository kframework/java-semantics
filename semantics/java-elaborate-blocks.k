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

syntax K ::= "elabRes" "(" K ")"  //Wraps the elaboration result

syntax K ::= K "??" K [right]

rule [chainOfResponsibilityHeat]:
    (. => K) ~> (K:K => CHOLE) ?? _
when notBool (isElab(K) ==K true)

rule [chainOfResponsibilityCool]:
    (ElabRes:K => .) ~> (CHOLE => ElabRes) ?? _
when isElab(ElabRes) ==K true

rule [chainOfResponsibility1]:
    ElabRes:K ?? _ => ElabRes
when isElab(ElabRes) andBool (ElabRes =/=K noValue)

rule [chainOfResponsibility2]:
    noValue ?? K:K => K

//Elaboration result of a field access exp.
syntax K ::= "lookupField" "(" K    //Qualifier exp
                               "," Type //Precise type where the field is defined
                               "," Id   //X - field name
                               ")"
//Elaboration result of a static field access expression
            | "lookupStaticField" "(" Type //Precise type where the field is defined
                                      "," Id   //X - field name
                                      ")"

rule [elaborateBlocksStart]:
    <k> . => elaborateBlocks(getAllClasses) </k>
    <computationPhase> ProcessClassesPhase => ElaborateBlocksPhase </computationPhase>

rule [elaborateBlocks]:
    <k>
      (. => elabMethods(.Map) ~> elabInstanceInit ~> elabStaticInit)
      ~> elaborateBlocks(setWrap((SetItem(Class:ClassType) => .) _:Set))
      ...
    </k>
    <cuClass> _ => Class </cuClass>

rule [elaborateBlocksDiscard]:
    elaborateBlocks(setWrap(.)) => .

rule [elabMethodsHeatMethod]:
  <k>
    (. => elabParams(Params) ~> elabInit(Body))
    ~> elabMethods( (. => Sig |-> methodClosure(MClass,'ListWrap(Params),CT, CHOLE )::MethodType) _)
    ...
  </k>
  <cuClass> Class:ClassType </cuClass>
  <classType> Class </classType>
  <methodDecs>
    Sig:K |-> methodClosure(MClass:ClassType, 'ListWrap(Params:List{K}), CT:ContextType, Body:K) :: MethodType:Type
    => .Map
    ...
  </methodDecs>
  <elabContextType> _ => CT </elabContextType>
  <elabEnv> _ => ListItem(stEnv(.Map)) </elabEnv>

rule [elabMethodsCoolMethod]:
    (elabRes(Body:K) => .)
    ~> elabMethods(_ |-> methodClosure(_,_,_, CHOLE => Body)::_ _:Map)

//todo consider eliminating the label constrClosure since it leads to too much duplication.
rule [elabMethodsHeatConstrFirstLine]:
  <k>
    (. => elabParams(Params) ~> elabInit(FirstLine))
    ~> elabMethods( (. => Sig |-> constrClosure(MClass, 'ListWrap(Params), CHOLE, Body )::MethodType) _)
    ...
  </k>
  <cuClass> Class:ClassType </cuClass>
  <classType> Class </classType>
  <methodDecs>
    Sig:K |-> constrClosure(MClass:ClassType, 'ListWrap(Params:List{K}), FirstLine:K, Body:K) :: MethodType:Type
    => .Map
    ...
  </methodDecs>
  <elabContextType> _ => instanceCT </elabContextType>
  <elabEnv> _ => ListItem(stEnv(.Map)) </elabEnv>

rule [elabMethodsHeatConstrBody]:
    (elabRes(FirstLine:K) => elabInit(Body))
    ~> elabMethods(_ |-> constrClosure(_,_, CHOLE => FirstLine, Body => CHOLE )::_ _:Map)

rule [elabMethodsCoolConstr]:
    (elabRes(Body:K) => .)
    ~> elabMethods(_ |-> constrClosure(_,_,_, CHOLE => Body)::_ _:Map)

rule [elabMethodsEnd]:
    <k> elabMethods( Methods:Map ) => . ...</k>
    <cuClass> Class:ClassType </cuClass>
    <classType> Class </classType>
    <methodDecs> .Map => Methods </methodDecs>

rule [elabInstanceHeat]:
    <k> (. => elabInit(K)) ~> elabInstanceInit ...</k>
    <cuClass> Class:ClassType </cuClass>
    <classType> Class </classType>
    <instanceInit> K:K => CHOLE </instanceInit>
    <elabContextType> _ => instanceCT </elabContextType>
    <elabEnv> _ => ListItem(stEnv(.Map)) </elabEnv>
when K =/=K CHOLE

rule [elabInstanceEnd]:
    <k> elabRes(K) ~> elabInstanceInit => . ...</k>
    <cuClass> Class:ClassType </cuClass>
    <classType> Class </classType>
    <instanceInit> CHOLE => K </instanceInit>

rule [elabStaticHeat]:
    <k> (. => elabInit(K)) ~> elabStaticInit ...</k>
    <cuClass> Class:ClassType </cuClass>
    <classType> Class </classType>
    <staticInit> K:K => CHOLE </staticInit>
    <elabContextType> _ => staticCT </elabContextType>
    <elabEnv> _ => ListItem(stEnv(.Map)) </elabEnv>
when K =/=K CHOLE

rule [elabStaticEnd]:
    <k> elabRes(K) ~> elabStaticInit => . ...</k>
    <cuClass> Class:ClassType </cuClass>
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

rule [elabHeatDefault]:
    (. => elabInit(K)) ~> elab(KL:KLabel(ElabResL:List{K},, (K:K => CHOLE),, _))
when
    isElab(ElabResL) andBool notBool isElab(K) andBool notBool customElabInit(K)

rule [elabInitDefault]:
    elabInit(K) => elab(K)
when
    notBool customElab(K)

//Required when processing first constructor line of Object, which is .K
rule [elabInitDotK]:
    elabInit(.K) => elabRes(.K)

rule [elabCoolDefault]:
    (ElabK => .) ~> elab(_:KLabel(_,, (CHOLE => ElabK),, _))
when
    isElab(ElabK)

rule [elabCoolNaked]:
    (ElabK => .) ~> _:KLabel(_,, (CHOLE => ElabK),, _)
when
    isElab(ElabK)

//todo check why this rule leads to a construct like
//elab ( 'TypeName(elabRes ( (packageId ( "pack" )) ),, A))
//if packageId is KResult, thus is ElabIndependent, thus cannot be matched by this rule
//and this rule is the only way for a term to get wrapped into elabRes().
rule [elabDisposeStartDefault]:
    elab(KL:KLabel(ElabResL:List{K})) => elabDispose(KL(ElabResL))
when
            isElab(ElabResL)
    andBool (notBool customElabDispose(KL(ElabResL)))
    andBool (notBool isElabIndependent(KL(ElabResL)))
    andBool (notBool isElabNaked(KL(ElabResL)))

rule [elabIndependentUnwrap]:
    elab(K:K) => K
when
    isElabIndependent(K) orBool isElabNaked(K)       [structural]

rule [elabDisposeProcess]:
    elabDispose(KL:KLabel(_,, (K:K => unElab(K)),, _))
when
    isElabOnly(K)

rule [elabDisposeEnd]:
    elabDispose(KL:KLabel(Ks:List{K})) => elabRes(KL(Ks))
when
    isNotElab(Ks)

//true if this label is elaborated, but is not un-elaborated.
syntax K ::= "isElabOnly" "(" K ")"                   [function]
rule isElabOnly(K:K) => getKLabel(K) ==KLabel 'elabRes`(_`)

syntax K ::= "isElabIndependent" "(" K ")"            [function]
rule isElabIndependent(K:K) =>
           (K ==K .K)
    orBool (isId(K) ==K true)
    orBool (isString(K) ==K true)
    orBool (isKResult(K) ==K true)
    orBool (isTypedExp(K) ==K true)

//Invoked during elabDispose. Transforms the term from elab result to normal.
syntax K ::= "unElab" "(" K ")"                 [function]
rule unElab(elabRes(K:K)) => K                  [anywhere]

//Computes to true if the given arg is a list of elaboration results, false otherwise.
syntax K ::= "isElab" "(" List{K} ")"           [function]
rule isElab((K:K => .List{K}) ,,_)
when isElabOnly(K) orBool isElabIndependent(K)  [anywhere]

rule isElab(K:K,,_) => false
when notBool (
           (isElabOnly(K) ==K true)
    orBool (isElabIndependent(K) ==K true))     [anywhere]

rule isElab(.List{K}) => true                   [anywhere]

//Computes to true if the given arg is a list of terms with none being elab-result only,
//false otherwise.
syntax K ::= "isNotElab" "(" List{K} ")"        [function]
rule isNotElab(K:K,,_) => false
when isElabOnly(K)                              [anywhere]

rule isNotElab((K:K => .List{K}),,_)
when notBool (isElabOnly(K) ==K true)           [anywhere]

rule isNotElab(.List{K}) => true                [anywhere]

//Returns true if the term needs special rules to be heated for elaboration, false otherwise.
syntax K ::= "customElabInit" "(" K ")"         [function]

rule customElabInit(.K) => false                [anywhere]
rule customElabInit(KL:KLabel(_)) =>
           KL ==KLabel 'LocalVarDecStm
    orBool KL ==KLabel 'LocalVarDec
    orBool KL ==KLabel 'ClassOrInterfaceType
    orBool KL ==KLabel 'InterfaceType
    orBool KL ==KLabel 'ClassType               [anywhere]

//Returns true if the term should be heated unwrapped in elabInit, false otherwise
syntax K ::= "isElabNaked" "(" K ")"         [function]

rule isElabNaked(.K) => false
rule isElabNaked(KL:KLabel(_)) =>
           (KL ==KLabel 'TypeName)
    orBool (KL ==KLabel 'PackageOrTypeName)
    orBool (KL ==KLabel 'PackageName)
    orBool (KL ==KLabel 'Field)
    orBool (KL ==KLabel 'SuperField)
    orBool (KL ==KLabel 'AmbName)
    orBool (KL ==KLabel 'ExprName)

rule [elabHeatQualOfNaked]:
    (. => elabInit(K)) ~> KL:KLabel((K:K => CHOLE),, _:Id)
when
    (
             (KL ==KLabel 'TypeName)
      orBool (KL ==KLabel 'PackageOrTypeName)
      orBool (KL ==KLabel 'Field)
      orBool (KL ==KLabel 'AmbName)
      orBool (KL ==KLabel 'ExprName)
    )
    andBool notBool isElab(K)

//Computes true if the given term needs special rules for elaboration, false otherwise
syntax K ::= "customElab" "(" K ")"             [function]

rule customElab(KL:KLabel(KLArgs:List{K})) =>
           (KL ==KLabel 'Block)
    orBool (KL ==KLabel 'For)
    orBool (KL ==KLabel 'Catch)

rule customElab(.K) => true

//Computes true if the given term needs special rules to startelab dispose phase, false otherwise.
syntax K ::= "customElabDispose" "(" K ")"       [function]

rule customElabDispose(KL:KLabel(Ks:List{K})) =>
           (KL ==KLabel 'Block)
    orBool (KL ==KLabel 'For)
    orBool (KL ==KLabel 'Catch)
    orBool (KL ==KLabel 'localVar`(_`))
    orBool (KL ==KLabel 'This)
    orBool (KL ==KLabel 'castImpl`(_`,_`))
    orBool (isType(KL(Ks)) ==K true)            [anywhere]

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

//todo this should not work. T should be resolved after elaboration of 'LocalVarDec
//At least types of fields should be computed upfront. We need them to compute elabLookup.
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
    'AmbName(Ks:List{K}) => 'ExprName(Ks) ?? 'TypeName(Ks) ?? 'PackageName('ListWrap(Ks))
when
    isElab(Ks)

rule [elabExprNameSimple]:
    'ExprName(ResK:K) => elab(localVar(ResK)) ?? 'Field(ResK)
when
    isElab(ResK)

rule [elabExprNameQualified]:
    'ExprName(K1:K,,K2:K) => 'Field(K1,,K2)
when
    isElab(K1) andBool isElab(K2)

rule [elabLocalVarOk]:
  <k> elab(localVar(X:Id)) => localVar(X) :: T ...</k>
  <elabEnv> ListItem(stEnv(X |-> T:Type _)) ...</elabEnv>

rule [elabLocalVarNoValue]:
  <k> elab(localVar(X:Id)) => noValue ...</k>
  <elabEnv> ListItem(stEnv(StEnv:Map)) ...</elabEnv>
when notBool (X in keys(StEnv))

rule [elabFieldUnqualified]:
    <k>
      'Field(Arg:K)
      => 'Field( 'This(.List{K}),, Arg ) ?? 'Field( Class,, Arg)
         ?? outerStaticField(Class, Arg)
      ...
    </k>
    <cuClass> Class:ClassType </cuClass>
when
    isElab(Arg)

rule [FieldOfPackage]:
    'Field( _:PackageId,, _:K ) => noValue  [structural]

rule [FieldOfNoValue]:
    'Field( noValue,, _:K ) => noValue      [structural]

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
    <k> elab('This(.List{K})) => 'This(.List{K}) :: Class ...</k>
    <elabContextType> instanceCT </elabContextType>
    <cuClass> Class:ClassType </cuClass>

rule [elabThisStaticCT]:
    <k> elab('This(.List{K})) => noValue ...</k>
    <elabContextType> staticCT </elabContextType>

rule [elabFieldQualRef]:
    'Field(Qual:K :: T:Type,, X:Id)
    => elabTypedExp(lookupField(Qual::T, noClass, X), elabLookup(X, T))

rule [elabFieldQualClass]:
    'Field(Class:ClassType,, X:Id)
    => elabTypedExp(lookupStaticField(noClass,X), elabLookup(X, Class))

rule [elabSuperField]:
    <k>
      'SuperField(X:Id)
      => elabTypedExp(lookupField('This(.List{K})::Class, noClass, X), elabLookup(X, BaseClass))
      ...
    </k>
    <cuClass> Class:ClassType </cuClass>
    <classType> Class </classType>
    <extends> BaseClass:ClassType </extends>

//Computed the TypedExp expression for a given expression and its type
syntax K ::= "elabTypedExp" "(" K //The original expression to be typed
                            "," K //elabLookup(...), computes into fieldEntry(...) or noValue
                            ")"  [strict(2)]

rule elabTypedExp(lookupField(TE:TypedExp,_,X:Id), fieldEntry(Class:ClassType,_,T:Type, instanceCT)) => lookupField(TE,Class,X) :: T
rule elabTypedExp(lookupField(TE:TypedExp,_,X:Id), fieldEntry(Class:ClassType,_,T:Type, staticCT)) => lookupStaticField(Class,X) :: T
rule elabTypedExp(lookupStaticField(_,X:Id), fieldEntry(Class:ClassType,_,T:Type, staticCT)) => lookupStaticField(Class,X) :: T
rule elabTypedExp(_, noValue) => noValue

//elab cast
rule 'CastRef(K1:K,, K2:K) => castImpl(K1,K2)       [structural, anywhere]
rule 'CastPrim(K1:K,, K2:K) => castImpl(K1,K2)      [structural, anywhere]

//Case when Exp was initially a literal, and now is Val::Type
rule [elabCastImplElabIndep]:
    <k> elab(castImpl(T:Type, Exp:K)) => castImpl(T, Exp) :: T ...</k>
    <debug>... . => ListItem(castImpl(T,Exp)) </debug>
when isElabIndependent(Exp)

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

rule 'PackageOrTypeName(KRs:List{K},, K:K) => 'TypeName(KRs,,K) ?? 'PackageName('ListWrap(KRs,,K))
when isKResult(KRs)

//When we search for a class qualified by another class, we simply convert
//the qualifier into a package.
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
    <cuClass> CrntClass:ClassType </cuClass>
    <classType> CrntClass </classType>
    <imports>... X |-> Class:ClassType ...</imports>

rule [TypeNameInExecutionPhaseFail]:
    <k> 'TypeName(X:Id) => noValue ...</k>
    <computationPhase> ElaborateBlocksPhase </computationPhase>
    <cuClass> CrntClass:ClassType </cuClass>
    <classType> CrntClass </classType>
    <imports> Imp:Map </imports>
when notBool  ((X in keys(Imp))
              orBool (Id2String(X) ==String "System")
              orBool (Id2String(X) ==String "Integer")
              orBool (Id2String(X) ==String "Scanner"))

/*@ \section{Outer static fields} */

//Search for fields with this name in the outer classes of the given class, if any.
syntax K ::= "outerStaticField" "(" ClassType //The original class. We will search in
                                              //its outer classes
                                "," Id        //The field name
                                ")"

rule [outerStaticField]:
    <k>
      outerStaticField(Class:ClassType, X:Id)
      => 'Field(EnclosingClass,, X) ?? outerStaticField(EnclosingClass, X)
      ...
    </k>
    <classType> Class </classType>
    <enclosingClass> EnclosingClass:ClassType </enclosingClass>

rule [outerStaticFieldDiscard]:
    outerStaticField(noClass, _) => noValue

endmodule
