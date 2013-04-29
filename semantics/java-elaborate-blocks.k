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

syntax K ::= "elabMethods" "(" Map ")"  //Elaborates the methods of the current class.
                                        //The map contains already elaborated methods.
                                        //Initially the map is empty.
           | "elabInstanceInit"
           | "elabStaticInit"
           | "elabInit" "(" K ")"       //The first step of elaboration. Performs some initialization.
           | "elab" "(" K ")"           //Elaborates the given statement/expression.
           | "elabDispose" "(" K ")"    //Intermediate state between elab and elabRes - all subterms were already elaborated.
                                        //Responsible for deleting the elabRes() wrappers of subterms.

syntax KResult ::= "elabRes" "(" K ")"  //Wraps the elaboration result

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
  <elabEnv> _ => ListItem(stEnv(.Set)) </elabEnv>

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
  <elabEnv> _ => ListItem(stEnv(.Set)) </elabEnv>

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
    <elabEnv> _ => ListItem(stEnv(.Set)) </elabEnv>
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
    <elabEnv> _ => ListItem(stEnv(.Set)) </elabEnv>
when K =/=K CHOLE

rule [elabStaticEnd]:
    <k> elabRes(K) ~> elabStaticInit => . ...</k>
    <cuClass> Class:ClassType </cuClass>
    <classType> Class </classType>
    <staticInit> CHOLE => K </staticInit>

//Adds params to the <elabEnv>.
syntax K ::= "elabParams" "(" List{K} ")"
rule [elabParams]:
    <k> elabParams((paramImpl(_, X:Id) => .List{K}) ,,_) ...</k>
    <elabEnv> ListItem(stEnv((. => SetItem(X)) _)) ...</elabEnv>

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

rule [elabDisposeOtherStart]:
    elab(KL:KLabel(ElabResL:List{K})) => elabDispose(KL(ElabResL))
when
    isElab(ElabResL) andBool notBool customElabDispose(KL(ElabResL))

rule [elabDisposeProcess]:
    elabDispose(KL:KLabel(_,, (elabRes(K:K) => K),, _))

rule [elabDisposeEnd]:
    elabDispose(KL:KLabel(Ks:List{K})) => elabRes(KL(Ks))
when
    isNotElab(Ks)

rule [elabDotK]:
    elab(.K) => elabRes(.K)

//Computes to true if the given arg is a list of terms wrapped into elabRes(), false otherwise.
syntax K ::= "isElab" "(" List{K} ")"       [function]
rule isElab((elabRes(_) => .List{K}) ,,_)   [anywhere]
rule isElab((noValue => .List{K}) ,,_)      [anywhere]
rule isElab((stEnv(_) => .List{K}) ,,_)     [anywhere]
rule isElab(.List{K}) => true               [anywhere]
rule isElab(.K,, _) => false                [anywhere]

rule isElab(KL:KLabel(_),,_) => false
when KL =/=KLabel 'elabRes`(_`)             [anywhere]

//Computes to true if the given arg is a list of terms with none wrapped into elabRes(),
//false otherwise.
syntax K ::= "isNotElab" "(" List{K} ")"        [function]
rule isNotElab(elabRes(_) ,,_) => false         [anywhere]
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

rule [VarListDecDesugar]:
    elab('ListWrap(_,,(
      'LocalVarDec(TypeK:K,, 'ListWrap(Var1:K,, Var2:K,, VarDecs:List{K}))
      => 'LocalVarDec(TypeK,, 'ListWrap(Var1)),,
         'LocalVarDec(TypeK,, 'ListWrap(Var2,, VarDecs))
    ),,_))                                            [structural]

rule [VarDecWithInitDesugar]:
    elab('ListWrap(_,,(
    'LocalVarDec(TypeK:K,, 'ListWrap('VarDec(X1:Id,,InitExp:K)))
    => 'LocalVarDec(TypeK,, 'ListWrap('VarDec(X1:Id))),,
       'ExprStm('Assign('ExprName(X1),, InitExp))
    ),,_))
when
    getKLabel(InitExp) =/=KLabel 'ArrayInit           [structural]

rule [elabHeatLocalVarDec]:
    <k>
      (. => elabInit('LocalVarDec(TypeK,, 'ListWrap('VarDec(X)))))
      ~> elab(KL:KLabel(ElabResL:List{K},,
        ('LocalVarDec(TypeK:K,, 'ListWrap('VarDec(X:Id))) => CHOLE),,
      _))
      ...
    </k>
    <elabEnv> ListItem(stEnv((. => SetItem(X)) _)) ...</elabEnv>
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
  <k> elab(localVar(elabRes(X:Id))) => elabRes(localVar(X)) ...</k>
  <elabEnv> ListItem(stEnv(SetItem(X) _)) ...</elabEnv>

rule [elabLocalVarNoValue]:
  <k> elab(localVar(elabRes(X:Id))) => noValue ...</k>
  <elabEnv> ListItem(stEnv(StEnv:Set)) ...</elabEnv>
when notBool (X in StEnv)

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
                                  Set         //Collected fields so far
                                ")"

rule [instanceElabEnvStart]:
    <k> instanceElabEnv(CT:ClassType) => instanceElabEnv(BaseClass, FDecs, .Set) ...</k>
    <classType> CT </classType>
    <extends> BaseClass:ClassType </extends>
    <fieldDecs> 'ListWrap(FDecs:List{K}) </fieldDecs>

rule [instanceElabEnv]:
    instanceElabEnv(_, ('LocalVarDec(_:K,, 'ListWrap('VarDec(X:Id,, _))) => .List{K}),,_, (. => SetItem(X)) _)

rule [instanceElabEnvNextClass]:
    <k> instanceElabEnv(CT:ClassType, .List{K}, Env:Set) => instanceElabEnv(BaseClass, FDecs, Env) ...</k>
    <classType> CT </classType>
    <extends> BaseClass:ClassType </extends>
    <fieldDecs> 'ListWrap(FDecs:List{K}) </fieldDecs>

rule [instanceElabEnvEnd]:
    instanceElabEnv(noClass, .List{K}, Env:Set) => stEnv(Env)

//Computes a stEnv() - environment of all static fields of the given class
syntax K ::= "staticElabEnv" "(" ClassType ")"
           | "staticElabEnv" "("            //The working form
                                  ClassType "," //The classes remaining to search, noClass if none
                                  Set         //Collected fields so far
                                ")"

rule [instanceElabEnvStart]:
    <k> staticElabEnv(CT:ClassType) => staticElabEnv(BaseClass, keys(CuEnv)) ...</k>
    <classType> CT </classType>
    <extends> BaseClass:ClassType </extends>
    <staticEnv> CuEnv:Map </staticEnv>

rule [instanceElabEnvNextClass]:
    <k> staticElabEnv(CT:ClassType, Env:Set) => staticElabEnv(BaseClass, (Env keys(CuEnv))) ...</k>
    <classType> CT </classType>
    <extends> BaseClass:ClassType </extends>
    <staticEnv> CuEnv:Map </staticEnv>

rule [instanceElabEnvEnd]:
    staticElabEnv(noClass, Env:Set) => stEnv(Env)

rule [elabThisInstanceCT]:
    <k>
      elab('Field(elabRes('This(.List{K})),, elabRes(X:Id)))
      => 'If(
            elabLookup(X, instanceElabEnv(Class)),,
            elabRes('Field('This(.List{K}),,X)),,
            noValue
          )
      ...
    </k>
    <elabContextType> instanceCT </elabContextType>
    <cuClass> Class:ClassType </cuClass>

rule [elabThisStaticCT]:
    <k>
      elab('Field(elabRes('This(.List{K})),, elabRes(X:Id))) => noValue
      ...
    </k>
    <elabContextType> staticCT </elabContextType>

rule [elabFieldStaticField]:
    elab('Field(elabRes(Class:ClassType),, elabRes(X:Id)))
    => 'If(
          elabLookup(X, staticElabEnv(Class)),,
          elabRes('Field(Class,,X)),,
          noValue
        )

//computes true if the given id is in the set of the second argument, false otherwise
syntax K ::= "elabLookup" "(" Id  //The Id to search
                          "," K   //computes into stEnv(Set) - the set where Id is searched
                          ")" [strict(2)]

rule [elabLookup]:
    elabLookup(X:Id, stEnv(Env:Set)) => (X in Env)::bool


//todo This is simplified semantics, no packages yet.
rule [elabTypeName]:
  elab('TypeName(elabRes(X:Id))) => elabRes('TypeName(X:Id))
when
    Id2String(X) =/=String "System"

//todo elab('Field), instance

//for now if class-lib contains only Object, tests that don't contain instance fields pass.

endmodule
