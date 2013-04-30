require "java-core.k"
require "java-var-lookup.k"
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

syntax KResult ::= "elabRes" "(" K ")"  //Wraps the elaboration result

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
  <methods>
    Sig:K |-> methodClosure(MClass:ClassType, 'ListWrap(Params:List{K}), CT:ContextType, Body:K) :: MethodType:Type
    => .Map
    ...
  </methods>
  <elabContextType> _ => CT </elabContextType>
  <elabEnv> _ => ListItem(stEnv(.Map)) </elabEnv>

rule [elabMethodsCoolMethod]:
    (elabRes(Body:K) => .)
    ~> elabMethods(_ |-> methodClosure(_,_,_, CHOLE => Body)::_ _:Map)

//todo consider eliminating the label constrClosure since it leads to too much duplication.
rule [elabMethodsHeatConstr]:
  <k>
    (. => elabParams(Params) ~> elabInit(Body))
    ~> elabMethods( (. => Sig |-> constrClosure(MClass,'ListWrap(Params),FirstLine, CHOLE )::MethodType) _)
    ...
  </k>
  <cuClass> Class:ClassType </cuClass>
  <classType> Class </classType>
  <methods>
    Sig:K |-> constrClosure(MClass:ClassType, 'ListWrap(Params:List{K}), FirstLine:K, Body:K) :: MethodType:Type
    => .Map
    ...
  </methods>
  <elabContextType> _ => instanceCT </elabContextType>
  <elabEnv> _ => ListItem(stEnv(.Map)) </elabEnv>

rule [elabMethodsCoolConstr]:
    (elabRes(Body:K) => .)
    ~> elabMethods(_ |-> constrClosure(_,_,_, CHOLE => Body)::_ _:Map)

rule [elabMethodsEnd]:
    <k> elabMethods( Methods:Map ) => . ...</k>
    <cuClass> Class:ClassType </cuClass>
    <classType> Class </classType>
    <methods> .Map => Methods </methods>

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

rule [elabCoolDefault]:
    (ElabK => .) ~> elab(_:KLabel(_,, (CHOLE => ElabK),, _))
when
    isElab(ElabK)

rule [elabDisposeStartDefault]:
    elab(KL:KLabel(ElabResL:List{K})) => elabDispose(KL(ElabResL))
when
    isElab(ElabResL) andBool notBool customElabDispose(KL(ElabResL))

rule [elabDotK]:
    elab(.K) => elabRes(.K)

rule [elabDisposeProcess]:
    elabDispose(KL:KLabel(_,, (K:K => unElab(K)),, _))
when
    notBool isNotElab(K)

rule [elabDisposeEnd]:
    elabDispose(KL:KLabel(Ks:List{K})) => elabRes(KL(Ks))
when
    isNotElab(Ks)

//Invoked during elabDispose. Transforms the term from elab result to normal.
syntax K ::= "unElab" "(" K ")"                 [function]
rule unElab(elabRes(K:K)) => K                  [anywhere]
rule unElab(K:::_) => K                         [anywhere]

//Computes to true if the given arg is a list of terms wrapped into elabRes(), false otherwise.
syntax K ::= "isElab" "(" List{K} ")"           [function]
rule isElab((elabRes(_) => .List{K}) ,,_)       [anywhere]
rule isElab((_:::_ => .List{K}) ,,_)            [anywhere]
rule isElab((noValue => .List{K}) ,,_)          [anywhere]
rule isElab((stEnv(_) => .List{K}) ,,_)         [anywhere]
rule isElab(.List{K}) => true                   [anywhere]
rule isElab(.K,, _) => false                    [anywhere]

rule isElab(KL:KLabel(_),,_) => false
when KL =/=KLabel 'elabRes`(_`)                 [anywhere]

//Computes to true if the given arg is a list of terms with none wrapped into elabRes(),
//false otherwise.
syntax K ::= "isNotElab" "(" List{K} ")"        [function]
rule isNotElab(elabRes(_) ,,_) => false         [anywhere]
rule isNotElab(_:::_ ,,_) => false              [anywhere]
rule isNotElab((noValue => .List{K}) ,,_)       [anywhere]
rule isNotElab((stEnv(_) => .List{K}) ,,_)      [anywhere]
rule isNotElab(.List{K}) => true                [anywhere]
rule isNotElab((.K => .List{K}),, _)            [anywhere]

rule isNotElab((KL:KLabel(_) => .List{K}),, _)
when KL =/=KLabel 'elabRes`(_`)                 [anywhere]

//Returns true if the term needs special rules to be heated for elaboration, false otherwise.
syntax K ::= "customElabInit" "(" K ")"                 [function]

rule customElabInit(.K) => false
rule customElabInit(KL:KLabel(_)) =>
           KL ==KLabel 'LocalVarDecStm
    orBool KL ==KLabel 'LocalVarDec

//Computes true if the given term needs special rules for elaboration, false otherwise
syntax K ::= "customElab" "(" K ")"             [function]

//Labels that need special semantics during at the beginning of elab and elabDispose phases.
rule customElab(.K) => false

rule customElab(KL:KLabel(KLArgs:List{K})) =>
           (KL ==KLabel 'Block)

//Computes true if the given term needs special rules to startelab dispose phase, false otherwise.
syntax K ::= "customElabDispose" "(" K ")"       [function]

//Labels that need special semantics during at the beginning of elab and elabDispose phases.
rule customElabDispose(.K) => false

rule customElabDispose(KL:KLabel(_)) =>
           (KL ==KLabel 'Block)
    orBool (KL ==KLabel 'AmbName)
    orBool (KL ==KLabel 'ExprName)
    orBool (KL ==KLabel 'localVar`(_`))
    orBool (KL ==KLabel 'This)
    orBool (KL ==KLabel 'Field)
    orBool (KL ==KLabel 'noValue)
    orBool (KL ==KLabel 'TypeName)

//Elaboration of blocks

rule [elabInitBlock]:
    <k> elabInit('Block(Ks:List{K})) => elab('Block(Ks)) ...</k>
    <elabEnv> (. => ListItem(StEnvK)) ListItem(StEnvK:K) ...</elabEnv>

rule [elabDisposeBlockStart]:
    <k> elab('Block(ElabResL:List{K})) => elabDispose('Block(ElabResL)) ...</k>
    <elabEnv> (ListItem(_) => .) ...</elabEnv>
when
    isElab(ElabResL)

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
//At least types of fields should be computed upfront. We need them to compute instanceElabEnv.
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
    elab('AmbName(Ks:List{K})) => elab('ExprName(Ks)) ?? elab('TypeName(Ks)) ?? elab('PackageName('ListWrap(Ks)))
when
    isElab(Ks)

rule [elabExprNameSimple]:
    elab('ExprName(ResK:K)) => elab(localVar(ResK)) ?? elab('Field(ResK))
when
    isElab(ResK)

rule [elabExprNameQualified]:
    elab('ExprName(K1:K,,K2:K)) => elab('Field(K1,,K2))
when
    isElab(K1) andBool isElab(K2)

rule [elabLocalVarOk]:
  <k> elab(localVar(elabRes(X:Id))) => localVar(X) ::: T ...</k>
  <elabEnv> ListItem(stEnv(X |-> T:Type _)) ...</elabEnv>

rule [elabLocalVarNoValue]:
  <k> elab(localVar(elabRes(X:Id))) => noValue ...</k>
  <elabEnv> ListItem(stEnv(StEnv:Map)) ...</elabEnv>
when notBool (X in keys(StEnv))

//todo add outerStaticField option
rule [elabFieldUnqualified]:
    <k>
      elab('Field(Arg:K))
      => elab('Field( 'This(.List{K}),, Arg )) ?? elab('Field( Class,, Arg))
         //?? elab(outerStaticField(Class, Arg))
      ...
    </k>
    <cuClass> Class:ClassType </cuClass>
when
    isElab(Arg)

rule [FieldOfPackage]:
    'Field( _:PackageId,, _:K ) => noValue  [structural, anywhere]

rule [FieldOfNoValue]:
    'Field( noValue,, _:K ) => noValue      [structural, anywhere]

rule [elabNoValue]:
    elab(noValue) => noValue

//Computationof instance and static environment of a class
//e.g. set of fields

//Computes a stEnv() - environment of all instance fields of the given class
//No static fields
syntax K ::= "instanceElabEnv" "(" ClassType ")"
           | "instanceElabEnv" "("            //The working form
                                  ClassType "," //The classes remaining to search, noClass if none
                                  List{K} "," //List of LocalVarDec - content of <fieldDecs> of currently searched class
                                  Map         //Collected fields so far
                                ")"

rule [instanceElabEnvStart]:
    <k> instanceElabEnv(CT:ClassType) => instanceElabEnv(BaseClass, FDecs, .Map) ...</k>
    <classType> CT </classType>
    <extends> BaseClass:ClassType </extends>
    <fieldDecs> 'ListWrap(FDecs:List{K}) </fieldDecs>
    <preprocessingPhase> MembersProcessedCPP </preprocessingPhase>

rule [instanceElabEnv]:
    instanceElabEnv(_, ('LocalVarDec(T:Type,, 'ListWrap('VarDec(X:Id,, _))) => .List{K}),,_, (. => X |-> T) _)

rule [instanceElabEnvNextClass]:
    <k> instanceElabEnv(CT:ClassType, .List{K}, Env:Map) => instanceElabEnv(BaseClass, FDecs, Env) ...</k>
    <classType> CT </classType>
    <extends> BaseClass:ClassType </extends>
    <fieldDecs> 'ListWrap(FDecs:List{K}) </fieldDecs>

rule [instanceElabEnvEnd]:
    instanceElabEnv(noClass, .List{K}, Env:Map) => stEnv(Env)

//Computes a stEnv() - environment of all static fields of the given class
syntax K ::= "staticElabEnv" "(" ClassType ")"
           | "staticElabEnv" "("                //The working form
                                  ClassType "," //The classes remaining to search, noClass if none
                                  Map ","       //Content of <staticEnv> to be processed: Map[Id -> Loc]
                                  Map           //Collected fields so far
                                ")"

rule [staticElabEnvStart]:
    <k> staticElabEnv(CT:ClassType) => staticElabEnv(BaseClass, CuEnv, .Map) ...</k>
    <classType> CT </classType>
    <extends> BaseClass:ClassType </extends>
    <staticEnv> CuEnv:Map </staticEnv>
    <preprocessingPhase> MembersProcessedCPP </preprocessingPhase>

rule [staticElabEnv]:
    <k> staticElabEnv(_, (X:Id |-> L:Int => .) _, (. => X |-> T) _) ...</k>
    <store>... L |-> uninitialized(_,T:Type)  ...</store>

rule [staticElabEnvNextClass]:
    <k> staticElabEnv(CT:ClassType, .Map, Env:Map) => staticElabEnv(BaseClass, CuEnv, Env) ...</k>
    <classType> CT </classType>
    <extends> BaseClass:ClassType </extends>
    <staticEnv> CuEnv:Map </staticEnv>

rule [staticElabEnvEnd]:
    staticElabEnv(noClass, .Map, Env:Map) => stEnv(Env)

rule [elabThisInstanceCT]:
    <k> elab('This(.List{K})) => 'This(.List{K}) ::: Class ...</k>
    <elabContextType> instanceCT </elabContextType>
    <cuClass> Class:ClassType </cuClass>

rule [elabThisStaticCT]:
    <k> elab('This(.List{K})) => noValue ...</k>
    <elabContextType> staticCT </elabContextType>

rule [elabFieldQualRef]:
    elab('Field(Qual:K ::: T:Type,, elabRes(X:Id)))
    => elabTypedExp('Field(Qual,,X), elabLookup(X, instanceElabEnv(T)))

rule [elabFieldQualClass]:
    elab('Field(elabRes(Class:ClassType),, elabRes(X:Id)))
    => elabTypedExp('Field(Class,,X), elabLookup(X, staticElabEnv(Class)))

//computes the type of the given Id in the given Env:Map, or noValue if the Id is not in the Map.
syntax K ::= "elabLookup" "(" Id  //The Id to search
                          "," K   //computes into stEnv(Map) - the map where Id is searched
                          ")" [strict(2)]

rule [elabLookupOk]:
    elabLookup(X:Id, stEnv(X |-> T:Type _)) => T

rule [elabLookupNoValue]:
    elabLookup(X:Id, stEnv(Env:Map)) => noValue
when
    notBool (X in keys(Env))

//Computed the TypedExp expression for a given expression and its type
syntax K ::= "elabTypedExp" "(" K //The original expression to be typed
                            "," K //elabLookup(...), computes into Type or noValue
                            ")"  [strict(2)]

rule elabTypedExp(Exp:K, T:Type) => Exp ::: T
rule elabTypedExp(_, noValue) => noValue

//todo This is simplified semantics, no packages yet.
rule [elabTypeName]:
  elab('TypeName(elabRes(X:Id))) => elabRes('TypeName(X:Id))
when
    Id2String(X) =/=String "System"

endmodule
