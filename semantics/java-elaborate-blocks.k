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
           | "elab" "(" K ")"           //Elaborates the given statement/expression. The first step of elaboration.
           | "elabDispose" "(" K ")"    //Intermediate state between elab and elabRes - all subterms were already elaborated.
                                        //Responsible for deleting the elabRes() wrappers of subterms.

//Wraps the elaboration result. Since elaboration may happen at both ElaborateBlocksPhase and ExecutionPhase,
//it cannot be KResult. Actually it is not KResult for HOLE, but is for CHOLE.
syntax K ::= "elabRes" "(" K ")"

//sets the enclosing object for a given object.
//Invoked by invokeConstr and QSuperConstrInv.
//Defined in JAVA-CLASSES
syntax K ::= "setEncloser" "(" TypedExp   //Evaluates to target object
                           "," ClassType  //Class layer for which to set the encloser
                           "," K          //The encloser
                           ")"            [strict(1,3)]

//Computes into an expression of the form elabRes('QThis(QualClass)::QualClass),
//where QualClass is searched in the enclosing context of the first argument,
//being a subclass of the second one.
syntax K ::= "getElabResQThisSubclassOf" "(" ClassType //The context class in which qualifier is searched for.
                                         "," ClassType //Qualifier should be subclass of this class
                                         ")"            [strict(2)]

rule [getElabResQThisSubclassOf]:
    <k>
      getElabResQThisSubclassOf(QualClass:ClassType, ReqClass:ClassType)
      => 'If(
            subtype(QualClass, ReqClass),,
            elabRes('QThis(QualClass)::QualClass),,
            getElabResQThisSubclassOf(QualEncloserClass, ReqClass)
          )
      ...
    </k>
    <classType> QualClass </classType>
    <enclosingClass> QualEncloserClass:ClassType </enclosingClass>
when
    ReqClass =/=K noClass

rule [getElabResQThisSubclassOf-top-level]:
    getElabResQThisSubclassOf(_, noClass) => elabRes(noValue)

//Happens for 'NewInstance expressions for static inner classes.
rule [getElabResQThisSubclassOf-static]:
    getElabResQThisSubclassOf(noClass, _) => elabRes(noValue)

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
                KList   //InitContent - array initializer, if any, or .K if arg 3 is specified.
                          //From arguments 3 and 4 just one may be specified. This initializer is for the whole array,
                          //not for each element as the previous one.
             ")"


rule [elaborateBlocksStart]:
    <k> . => elaborateBlocks(getTopLevelClasses) </k>
    <computationPhase> ProcessClassesPhase => ElaborateBlocksPhase </computationPhase>

//it is important to elaborate the instance initializers before the methods.
//This way, when 'SuperConstrEnv is encountered, it inserts the already elaborated instance
//initializer in its place, avoiding name collisions between consturctor args and fields
//inside instance init.
rule [elaborateBlocks]:
    <k>
      (. => elabInstanceInit ~> elabMethods(MethodDecs) ~> elabStaticInit
        ~> elaborateBlocks(getInnerClasses(Class))
      )
      ~> elaborateBlocks(setWrap((SetItem(Class:ClassType) => .) _:Set))
      ...
    </k>
    <crntClass> _ => Class </crntClass>
    <classType> Class </classType>
    <methodDecs> MethodDecs:Map </methodDecs>

rule [elaborateBlocksDiscard]:
    elaborateBlocks(setWrap(.)) => .

rule [elabMethodsHeatMethodFirstLine]:
    <k>
      (. => addElabEnv ~> elabParams(Params) ~> elab(FirstLine))
      ~> elabMethods( (Sig |-> _ => .Map) _)
      ...
    </k>
    <crntClass> Class:ClassType </crntClass>
    <classType> Class </classType>
    <methodDecs>
      Sig:K |-> methodClosure(MClass:ClassType, 'ListWrap(Params:KList), CT:ContextType,_,_, (FirstLine:K => CHOLE), Body:K) :: MethodType:Type
      ...
    </methodDecs>
    <contextType> _ => CT </contextType>

//Required when processing first constructor line of Object, which is .K
rule [elabDotK]:
    elab(.K) => elabRes(.K)

rule [elabMethodsHeatMethodBody]:
    <k>
      (elabRes(FirstLine:K) => elab(Body)) ~> elabMethods(_:Map)
      ...
    </k>
    <crntClass> Class:ClassType </crntClass>
    <classType> Class </classType>
    <methodDecs>
      Sig:K |-> methodClosure(MClass:ClassType, 'ListWrap(Params:KList), _,_,_, CHOLE => FirstLine, Body:K => CHOLE) :: MethodType:Type
      ...
    </methodDecs>

rule [elabMethodsCoolMethod]:
    <k>
      (elabRes(Body:K) => removeLastElabEnv) ~> elabMethods(_:Map)
      ...
    </k>
    <crntClass> Class:ClassType </crntClass>
    <classType> Class </classType>
    <methodDecs>
      Sig:K |-> methodClosure(MClass:ClassType, 'ListWrap(Params:KList), _,_, methodRT, FirstLine:K, CHOLE => Body) :: MethodType:Type
      ...
    </methodDecs>

rule [elabMethodsCoolConstructor]:
    <k>
      (elabRes(Body:K) => removeLastElabEnv) ~> elabMethods(_:Map)
      ...
    </k>
    <crntClass> Class:ClassType </crntClass>
    <classType> Class </classType>
    <methodDecs>
      Sig:K |-> methodClosure(MClass:ClassType, 'ListWrap(Params:KList), _,_,
        constructorRT => methodRT,
        FirstLine:K => noValue,
        CHOLE => FirstLine ~> Body
      ) :: MethodType:Type
      ...
    </methodDecs>

rule [elabMethodsEnd]:
    elabMethods( .Map ) => .

rule [elabInstanceHeat]:
    <k> (. => addElabEnv ~> elab(K)) ~> elabInstanceInit ...</k>
    <crntClass> Class:ClassType </crntClass>
    <classType> Class </classType>
    <instanceInit> K:K => CHOLE </instanceInit>
    <contextType> _ => instanceCT </contextType>
when K =/=K CHOLE

rule [elabInstanceEnd]:
    <k> elabRes(K) ~> elabInstanceInit => removeLastElabEnv ...</k>
    <crntClass> Class:ClassType </crntClass>
    <classType> Class </classType>
    <instanceInit> CHOLE => K </instanceInit>

rule [elabStaticHeat]:
    <k> (. => addElabEnv ~> elab(K)) ~> elabStaticInit ...</k>
    <crntClass> Class:ClassType </crntClass>
    <classType> Class </classType>
    <staticInit> K:K => CHOLE </staticInit>
    <contextType> _ => staticCT </contextType>
when K =/=K CHOLE

rule [elabStaticEnd]:
    <k> elabRes(K) ~> elabStaticInit => removeLastElabEnv ...</k>
    <crntClass> Class:ClassType </crntClass>
    <classType> Class </classType>
    <staticInit> CHOLE => K </staticInit>

syntax K ::=
    //Adds a new empty layer to <elabEnv>
      "addElabEnv"
    //Removes the last layer from <elabEnv>
    | "removeLastElabEnv"

    //Adds params to the <elabEnv>.
    | "elabParams" "(" KList ")"

rule [addElabEnv]:
    <k> addElabEnv => . ...</k>
    <elabEnv> . => ListItem(stEnv(.Map)) ...</elabEnv>
    <localTypes> . => ListItem(stEnv(.Map)) ...</localTypes>

rule [removeLastElabEnv]:
    <k> removeLastElabEnv => . ...</k>
    <elabEnv> ListItem(_) => . ...</elabEnv>
    <localTypes> ListItem(_) => . ...</localTypes>

rule [elabParams]:
    <k> elabParams((paramImpl(T:Type, X:Id) => .KList) ,,_) ...</k>
    <elabEnv> ListItem(stEnv((. => X |-> T) _)) ...</elabEnv>

rule [elabParamsEnd]:
    elabParams(.KList) => .K

/*@ \section{Elaboration of code blocks} */

//Heating arguments for both expression and statement terms.
//The attribute [strictness-transition] is used as transition attribute for testing strictness.
//This is a rule that may lead to unexpected nondeterminism if it is wrongly implemented.
//In order to expose incorrect nondeterminism we need to modelcheck a program that exposes the nondeterminism.
rule [elabHeatDefault]:
    (. => elab(K)) ~> elab(KL:KLabel(HeadKs:KList,, (K:K => CHOLE),, TailKs:KList))
when
            notBool customElabChildren(KL)
    andBool notBool isElab(K)
    andBool notBool isElabNaked(KL(HeadKs,,K,,TailKs))
    andBool isElab(HeadKs)    //Forces elaboration left-to-right. Required when KL == 'ListWrap of statements.
    [strictness-transition]

//True if children of this label should not be automatically heated for elaboration.
syntax K ::= "customElabChildren" "(" KLabel ")"                [function]
rule customElabChildren(KL:KLabel) =>
           (KL ==KLabel 'Block)
    orBool (KL ==KLabel 'For)
    orBool (KL ==KLabel 'Catch)
    orBool (KL ==KLabel 'LocalVarDecStm)
    orBool (KL ==KLabel 'LocalVarDec)
    orBool (KL ==KLabel 'SuperConstrInv)
    orBool (KL ==KLabel 'QSuperConstrInv)
    orBool (KL ==KLabel 'AltConstrInv)
    orBool (KL ==KLabel 'ClassDecStm)

//Will not match .K - is not isElabNaked. (.K) is matched by [elabDotK].
rule [unwrapElabNaked]:
    elab(K:K) => K
when
    isElabNaked(K)

syntax K ::= "isElabNaked" "(" K ")"                            [function]
rule isElabNaked(K) =>
           (isRawVal(K) ==K true)
    orBool (getKLabel(K) ==KLabel 'TypeName)
    orBool (getKLabel(K) ==KLabel 'ClassOrInterfaceType)
    orBool (getKLabel(K) ==KLabel 'InterfaceType)
    orBool (getKLabel(K) ==KLabel 'ClassType)
    orBool (getKLabel(K) ==KLabel 'ArrayType)
    orBool (getKLabel(K) ==KLabel 'PackageName)
    orBool (getKLabel(K) ==KLabel 'PackageOrTypeName)
    orBool (getKLabel(K) ==KLabel 'Id)
    orBool (getKLabel(K) ==KLabel 'Lit)

rule [elabCoolStatement]:
    (elabRes(K:K) => .) ~> elab(_:KLabel(_,, (CHOLE => elabRes(K)),, _))
when
    notBool (isTypedExp(K) ==K true)

rule [elabCoolExpression]:
    (elabRes(TExp:TypedExp) => .) ~> elab(_:KLabel(_,, (CHOLE => TExp),, _))

rule [elabCoolIndependent]:
    (ElabIndep => .) ~> elab(_:KLabel(_,, (CHOLE => ElabIndep),, _))
when
    isElabIndependent(ElabIndep)

//required by the rule [elabQNewInstance-resolve-class]
rule [elabDisposeCoolIndependent]:
    (ElabIndep => .) ~> elabDispose(_:KLabel(_,, (CHOLE => ElabIndep),, _))
when
    isElabIndependent(ElabIndep)

rule [elabDisposeStartDefault]:
    elab(KL:KLabel(ElabResL:KList)) => elabDispose(KL(ElabResL))
when
            notBool customElabChildren(KL)
    andBool isElab(ElabResL)
    andBool notBool isElabNaked(KL(ElabResL))

rule [elabDisposeProcess]:
    elabDispose(KL:KLabel(_,, (elabRes(K:K) => K),, _))

rule [elabDisposeEnd]:
    elabDispose(KL:KLabel(Ks:KList)) => elabRes(KL(Ks))
when
    notBool isExpressionLabel(KL) andBool haveNoElabRes(Ks)

syntax K ::= "isElabIndependent" "(" K ")"            [function]
rule isElabIndependent(K:K) =>
               (isKResult(K) ==K true)
    orBool (isTypedExp(K) ==K true)

//Computes to true if the given arg is a list of elaboration results, false otherwise.
syntax K ::= "isElab" "(" KList ")"                 [function]
rule isElab(K:K,, Ks:KList)
     =>      ((getKLabel(K) ==KLabel 'elabRes`(_`)) orBool (isElabIndependent(K) ==K true))
     andBool isElab(Ks)

rule isElab(.KList) => true

//Computes to true if the given arg is a list of terms with none being elab-result only,
//false otherwise.
syntax K ::= "haveNoElabRes" "(" KList ")"          [function]
rule haveNoElabRes(K:K,, Ks:KList)
     => (getKLabel(K) =/=KLabel 'elabRes`(_`)) andBool haveNoElabRes(Ks)

rule haveNoElabRes(.KList) => true

//Elaboration of blocks

rule [elabBlockHeat]:
    <k> elab('Block('ListWrap(Ks:KList))) => elab('ListWrap(Ks)) ~> elab('Block(CHOLE)) ...</k>
    <elabEnv> (. => ListItem(StEnvK)) ListItem(StEnvK:K) ...</elabEnv>
    <localTypes> (. => ListItem(LocTypesK)) ListItem(LocTypesK:K) ...</localTypes>

rule [elabForHeatFirstSubterm]:
    <k> (.=> elab(K)) ~> elab('For((K:K => CHOLE),, Ks:KList)) ...</k>
    <elabEnv> (. => ListItem(StEnvK)) ListItem(StEnvK:K) ...</elabEnv>
    <localTypes> (. => ListItem(LocTypesK)) ListItem(LocTypesK:K) ...</localTypes>
when getKLabel(K) =/=KLabel 'elabRes`(_`)

rule [elabForHeatOtherSubterms]:
    (.=> elab(K)) ~> elab('For(_,, elabRes(_),, (K:K => CHOLE),, _))
when getKLabel(K) =/=KLabel 'elabRes`(_`)

//HOLE is transformed into paramImpl
context elab('Catch(HOLE,, _))
when getKLabel(HOLE) =/=KLabel 'elabRes`(_`)

//Catch creates a new env layer and saves its argument.
rule [elabCatch]:
    <k> elab('Catch(Param:KResult,, Body:K)) => elabParams(Param) ~> elab(Body) ~> elab('Catch(elabRes(Param),, CHOLE)) ...</k>
    <elabEnv> (. => ListItem(StEnvK)) ListItem(StEnvK:K) ...</elabEnv>
    <localTypes> (. => ListItem(LocTypesK)) ListItem(LocTypesK:K) ...</localTypes>

rule [elabDisposeBlockForOrCatch]:
    <k> elab(KL:KLabel(ElabResL:KList)) => removeLastElabEnv ~> elabDispose(KL(ElabResL)) ...</k>
when
    isElab(ElabResL)
    andBool ((KL ==KLabel 'Block) orBool (KL ==KLabel 'For) orBool (KL ==KLabel 'Catch))

//Local var decs desugaring

rule [LocalVarDecStmRed]:
    elab('LocalVarDecStm('LocalVarDec(Ks:KList))
      => 'LocalVarDec(Ks)
    )                                                   [structural]

//Resolve the local var type, required to register the var in <elabEnv>
context elab('LocalVarDec(_:K,, HOLE,, _:K))

rule [VarDecMultiDesugar]:
    elab('LocalVarDec(K:K,, T:Type,, 'ListWrap(Var1:K,, Var2:K,, VarDecs:KList))
      => 'ListWrap('LocalVarDec(K,, T,, 'ListWrap(Var1)),,
            'LocalVarDec(K,, T,, 'ListWrap(Var2,, VarDecs)))
    )                                                   [structural]

rule [VarDecWithInitDesugar]:
    elab('LocalVarDec(K:K,, T:Type,, 'ListWrap('VarDec(X:Id,,InitExp:K)))
    => 'ListWrap('LocalVarDec(K,, T,, 'ListWrap('VarDec(X:Id))),,
        'ExprStm('Assign('ExprName(X),, InitExp))))
when
    getKLabel(InitExp) =/=KLabel 'ArrayInit             [structural]

rule [elabLocalVarDec]:
    <k>
      elab('LocalVarDec(K:K,, T:Type,, 'ListWrap('VarDec(X:Id))))
      => elabRes('LocalVarDec(K,, T,, 'ListWrap('VarDec(X))))
      ...
    </k>
    <elabEnv> ListItem(stEnv((. => X |-> T) _)) ...</elabEnv>

//Elaboration of rules in java-var-lookup

//Both unqualified and qualified AmbName.
rule [elabAmbName]:
    elabDispose('AmbName(Ks:KList)) => elabDispose('ExprName(Ks)) ?? 'TypeName(Ks) ?? 'PackageName('ListWrap(Ks))
when
    haveNoElabRes(Ks)

rule [elabExprNameSimple]:
    elabDispose('ExprName(X:Id)) => elabDispose(localVar(X)) ?? elabDispose('Field(X))

rule [elabExprNameQualified]:
    elabDispose('ExprName(QualK:K,,X:Id)) => elabDispose('Field(QualK,,X))

rule [elabLocalVarOk]:
  <k> elabDispose(localVar(X:Id)) => elabRes(localVar(X) :: T) ...</k>
  <elabEnv> ListItem(stEnv(X |-> T:Type _)) ...</elabEnv>

rule [elabLocalVarNoValue]:
  <k> elabDispose(localVar(X:Id)) => noValue ...</k>
  <elabEnv> ListItem(stEnv(StEnv:Map)) ...</elabEnv>
when notBool (X in keys(StEnv))

rule [elabFieldUnqualified]:
    <k>
      elabDispose('Field(X:Id) => 'Field( 'QThis(Class),, X ))
      ...
    </k>
    <crntClass> Class:ClassType </crntClass>

rule [elabFieldWithQThis]:
    <k>
      elabDispose('Field( 'QThis(Class:ClassType),, X ))
      => elab('Field( 'QThis(Class:ClassType) :: Class,, X )) ?? elab('Field( Class,, X))
         ?? elabDispose('Field( 'QThis(EnclosingClass:ClassType),, X ))
      ...
    </k>
    <classType> Class </classType>
    <enclosingClass> EnclosingClass:ClassType </enclosingClass>

rule [FieldOfPackage]:
    elabDispose('Field( _:PackageId,, _:Id )) => noValue  [structural]

rule [FieldOfNoValue]:
    elabDispose('Field( noValue,, _:Id )) => noValue      [structural]

rule [FieldOfQThis-noClass]:
    elabDispose('Field( 'QThis(noClass),, _:Id )) => noValue      [structural]

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
    <store>... L |-> _ :: T  ...</store>
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

rule [elabThis]:
    <k> elabDispose('This(.KList) => 'QThis(Class)) ...</k>
    <crntClass> Class:ClassType </crntClass>

rule [elabQThisInstanceCT]:
    <k> elabDispose('QThis(Class)) => elabRes('QThis(Class) :: Class) ...</k>
    <contextType> instanceCT </contextType>

rule [elabQThisStaticCT]:
    <k> elabDispose('QThis(_)) => noValue ...</k>
    <contextType> staticCT </contextType>

rule [elabFieldQualRef]:
    elabDispose('Field(Qual:K :: Class:ClassType,, X:Id))
    => elabTypedExp(lookupField(Qual::Class, noClass, X), elabLookup(X, Class))

rule [elabFieldQualClass]:
    elabDispose('Field(Class:ClassType,, X:Id))
    => elabTypedExp(lookupStaticField(noClass,X), elabLookup(X, Class))

rule [elabSuperField]:
    <k>
      elabDispose('SuperField(X:Id) => 'QSuperField(Class,, X:Id))
      ...
    </k>
    <crntClass> Class:ClassType </crntClass>

rule [elabQSuperField]:
    <k>
      elabDispose('QSuperField(Class:ClassType,, X:Id))
      => elabTypedExp(lookupField('QThis(Class) :: Class, noClass, X), elabLookup(X, BaseClass))
      ...
    </k>
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

/*@ \section{Elaboration of types} */

rule 'ClassOrInterfaceType(TypeK:K,, _) => TypeK [structural]
rule 'InterfaceType(TypeK:K,, _) => TypeK        [structural]
rule 'ClassType(TypeK:K,, _) => TypeK            [structural]

//resolving fully qualified type names
// A name pack.p2.A is represented as:
// 'TypeName('PackageOrTypeName('PackageOrTypeName(pack),,p2),,A)

context 'PackageOrTypeName(HOLE,, _:K)

rule 'PackageOrTypeName(KRs:KList,, K:K) => 'TypeName(KRs,,K) ?? 'PackageName('ListWrap(KRs,,K))
when isKResult(KRs)                              [structural]

//When we search for a class qualified by another class, we simply convert
//the qualifier into a package.

context 'TypeName(HOLE,,_:Id)

rule [TypeNameQualifiedClass]:
    'TypeName(ClassQ:ClassType,, X:Id) => 'TypeName(toPackage(ClassQ),, X)            [structural]

rule [TypeNameQualifiedPackage]:
    'TypeName(Pack:PackageId,, X:Id) => typeNameQualifiedImpl(getNamesMap(Pack), X)   [structural]

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
    Id2String(X) ==String "String"                      [structural]

rule [TypeName-Local-in-any-Phase]:
    <k> 'TypeName(X:Id) => Class ...</k>
    <localTypes> ListItem(stEnv(X |-> Class:ClassType _)) ...</localTypes>

rule [TypeName-Global]:
    <k> 'TypeName(X:Id) => Class ...</k>
    <localTypes> ListItem(stEnv(LocalTypes:Map)) ...</localTypes>
    <crntClass> CrntClass:ClassType </crntClass>
    <classType> CrntClass </classType>
    <imports>... X |-> Class:ClassType ...</imports>
when
    notBool X in keys(LocalTypes)

rule [TypeName-Global-Fail]:
    <k> 'TypeName(X:Id) => noValue ...</k>
    <localTypes> ListItem(stEnv(LocalTypes:Map)) ...</localTypes>
    <crntClass> CrntClass:ClassType </crntClass>
    <classType> CrntClass </classType>
    <imports> Imp:Map </imports>
when
    notBool X in keys(LocalTypes) andBool notBool (X in keys(Imp))

/*@ \section{Elaboration of numeric expressions} */

//Expression labels are not converted by the default rule in the phase
// elabDispose() => elabRes(...)
//Each expression needs a specialised rule for disposing, that will compute, among others,
//the type of the expression.
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
    orBool (KL ==KLabel 'QNewInstance)
    orBool (KL ==KLabel 'InstanceOf)
    orBool (KL ==KLabel 'castImpl`(_`,_`))
    orBool (KL ==KLabel 'Invoke)
    //also in customElabChildren
    orBool (KL ==KLabel 'This)
    orBool (KL ==KLabel 'QThis)
    orBool (KL ==KLabel 'AmbName)
    orBool (KL ==KLabel 'ExprName)
    orBool (KL ==KLabel 'Field)
    orBool (KL ==KLabel 'SuperField)
    orBool (KL ==KLabel 'QSuperField)
    orBool (KL ==KLabel 'NewArray)
    orBool (KL ==KLabel 'CastPrim)
    orBool (KL ==KLabel 'CastRef)

//It looks like isTypedExp(KList) doesn't work.
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
rule elabDispose('CastRef(T:Type,, TExp:TypedExp)  => castImpl(T, TExp))      [structural]
rule elabDispose('CastPrim(T:Type,, TExp:TypedExp) => castImpl(T, TExp))      [structural]

//Case when Exp was initially a literal, and now is Val::Type
rule [elabCastImplElabIndep]:
    elabDispose(castImpl(T1:Type, Exp:K :: T2:Type)) => elabRes(castImpl(T1, Exp::T2) :: T1)

rule [elabNewInstance]:
    <k>
      elabDispose('NewInstance(Arg1:K,, Class:ClassType,, Arg3:K,, Arg4:K))
      => getElabResQThisSubclassOf(CrntClass, getEnclosingClass(Class))
      ~> elab('QNewInstance(CHOLE,, Arg1,, Class,, 'None(.KList),, Arg3,, Arg4))
      ...
    </k>
    <crntClass> CrntClass:ClassType </crntClass>

rule [elabQNewInstance-resolve-class]:
    (. => resolveInnerClass(QualClass, Name))
    ~> elabDispose('QNewInstance(_::QualClass:ClassType,, _:K,,
      (Name:Id => CHOLE),,
    _))

//resolve the simple name of an inner class to a fully qualified class name in
//a qualified new like: o.new A(...);
syntax K ::= "resolveInnerClass" "(" ClassType //QualClass - the type of the qualifier
                                 "," Id        //Name - instantiated class simple name
                                 ")"

rule [resolveInnerClass]:
    <k>
      resolveInnerClass(QualClass:ClassType, Name:Id)
      => 'If(
            existsClass(toPackage(QualClass), Name),,
            getClassType(toPackage(QualClass), Name),,
            resolveInnerClass(BaseQualClass, Name)
          )
      ...
    </k>
    <classType> QualClass </classType>
    <extends> BaseQualClass:ClassType </extends>

//returns true if in the given package exists a class with given simple name, false otherwise.
syntax K ::= "existsClass" "(" PackageId "," Id ")"

rule [existsClass]:
    <k>
      existsClass(Pack:PackageId, Name:Id) => Name in keys(NamesToClasses)
      ...
    </k>
    <typeNamesMap>... Pack:PackageId |-> mapWrap(NamesToClasses:Map) ...</typeNamesMap>

rule [elabQNewInstance]:
    elabDispose('QNewInstance(Qual:K,, Arg2:K,, T:RefType,, Arg4:K,, Arg5:K,, Arg6:K))
    => elabRes('QNewInstance(Qual,, Arg2,, T,, Arg4,, Arg5,, Arg6) :: T)

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
        'ListWrap( ( 'Dim(.KList) => .KList ) ,,_:KList) ))
        [structural]

rule [NewArray]:
    elabDispose('NewArray(T:Type,, 'ListWrap(Dims:KList),, 'ListWrap(.KList)))
    => getArrayType(T, Dims) ~> elabRes(newArrayImpl(T, 'ListWrap(Dims), default(T), .KList) :: CHOLE)
        [structural]

//computes the array type based on allocated elem type and number of allocated dimensions.
syntax K ::= "getArrayType" "(" Type "," KList ")"
rule getArrayType(T:Type, K:K,,Dims:KList) => getArrayType(arrayOf T, Dims) [structural]
rule getArrayType(T:Type, .KList) => T                                      [structural]

rule [ArrayInitPreprocess]:
    elabDispose('NewArray((T:Type => arrayOf T),, 'ListWrap(('Dim(.KList) => .KList),, _),, 'ArrayInit(_)))

rule [ArrayInit]:
    elabDispose('NewArray(arrayOf T:Type,, 'ListWrap(.KList),, 'ArrayInit('ListWrap(InitContent:KList))))
    => elabRes(newArrayImpl(T, 'ListWrap(count(InitContent)), .K, InitContent) :: arrayOf T)

//counts the number of elements in the KList list. Evaluates to an Int::int .
syntax K ::= "count" "(" KList ")"
           | "count" "(" Int "," KList ")"

rule count(Ks:KList) => count(0, Ks)
rule count(I:Int, K:K,, Ks:KList) => count(I +Int 1, Ks)
rule count(I:Int, .KList) => I::int

//Elaborate all expressions once they reach the top of computation,
//both in elaboration and in execution phase.
//Performance: Using this rule instead of the rule above leads to execution performance decrease by 5%
//in helloWorld, with medium execution time rising from 9.6s to 10.1s
rule [elabExpressions]:
    KL:KLabel(Ks:KList) => elab(KL(Ks))
when
    isExpressionLabel(KL)

//Unwrap elaborated terms in execution phase, so that they could be executed.
rule [elabResInExecutionPhase]:
    <k> (elabRes(K:K) => K) ~> KL(_) ...</k>
    <computationPhase> ExecutionPhase </computationPhase>
when
    KL =/=KLabel 'elab`(_`)

//@Section elaboration of SuperConstrInv, AltConstrInv

//Desugaring unqualified superclass constructor invocation into a qualified one
rule [SuperConstrInv-desugar]:
    <k>
      (. => getElabResQThisSubclassOf(EnclosingClass, SubEnclosingClass))
      ~> elab(
        'SuperConstrInv(K:K,, 'ListWrap( Args:KList ))
        =>  'QSuperConstrInv(
              CHOLE,,
              K,,
              'ListWrap(Args)
            )
      )
      ...
    </k>
    <crntClass> Class:ClassType </crntClass>
    <class>
      <classType> Class </classType>
      <extends> SubClass:ClassType </extends>
      <enclosingClass> EnclosingClass:ClassType </enclosingClass>
      ...
    </class>
    <class>
      <classType> SubClass </classType>
      <enclosingClass> SubEnclosingClass:ClassType </enclosingClass>
      ...
    </class>

rule [QSuperConstrInv]:
    <k>
      elab(
        'QSuperConstrInv(Qual:K,, _,, 'ListWrap( Args:KList ))
        => 'ListWrap(
              setEncloser('This(.KList), BaseClass, Qual),,
              'ExprStm('Invoke(
                'SuperMethod('None(.KList),, getConsName(BaseClass) ),,
                'ListWrap(Args)
              )),,
              IInit
            )
      )
      ...
    </k>
    <crntClass> Class:ClassType </crntClass>
    <classType> Class </classType>
    <extends> BaseClass:ClassType </extends>
    <instanceInit> IInit:K </instanceInit>

rule [AltConstrInv]:
    <k>
      elab(
        'AltConstrInv(_,, 'ListWrap( Args:KList ))
        => 'ExprStm('Invoke(
                  'Method('MethodName( getConsName(Class) )),,
                  'ListWrap(Args)
            ))
      )
      ...
    </k>
    <crntClass> Class:ClassType </crntClass>

//True for 'QThis(_)::T, false otherwise
syntax K ::= "isTypedQThis" "(" K ")"                                    [function]

rule isTypedQThis(K::_) => getKLabel(K) ==KLabel 'QThis

rule isTypedQThis(K) => false
when getKLabel(K) =/=KLabel '_::_

syntax K ::= "getEnclosingClass" "(" ClassType ")"

rule [getEnclosingClass]:
    <k> getEnclosingClass(Class:ClassType) => EnclosingClass ...</k>
    <classType> Class </classType>
    <enclosingClass> EnclosingClass:ClassType </enclosingClass>

endmodule
