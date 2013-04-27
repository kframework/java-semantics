require "java-core.k"

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
    (. => elabInit(Body))
    ~> elabMethods( (. => Sig |-> methodClosure(MClass,ParamsLW,CT, CHOLE )::MethodType) _)
    ...
  </k>
  <cuClass> Class:ClassType </cuClass>
  <classType> Class </classType>
  <methods>
    Sig:K |-> methodClosure(MClass:ClassType, ParamsLW:K, CT:ContextType, Body:K) :: MethodType:Type
    => .Map
    ...
  </methods>

rule [elabMethodsCoolMethod]:
    (elabRes(Body:K) => .)
    ~> elabMethods(_ |-> methodClosure(_,_,_, CHOLE => Body)::_ _:Map)

//todo consider eliminating the label constrClosure since it leads to too much duplication.
rule [elabMethodsHeatConstr]:
  <k>
    (. => elabInit(Body))
    ~> elabMethods( (. => Sig |-> constrClosure(MClass,ParamsLW,FirstLine, CHOLE )::MethodType) _)
    ...
  </k>
  <cuClass> Class:ClassType </cuClass>
  <classType> Class </classType>
  <methods>
    Sig:K |-> constrClosure(MClass:ClassType, ParamsLW:K, FirstLine:K, Body:K) :: MethodType:Type
    => .Map
    ...
  </methods>

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
when K =/=K CHOLE

rule [elabStaticEnd]:
    <k> elabRes(K) ~> elabStaticInit => . ...</k>
    <cuClass> Class:ClassType </cuClass>
    <classType> Class </classType>
    <staticInit> CHOLE => K </staticInit>

/*@ \section{Elaboration of code blocks} */

rule [elabHeatOther]:
    (. => elabInit(K)) ~> elab(KL:KLabel(ElabResL:List{K},, (K:K => CHOLE),, _))
when
    isElab(ElabResL) andBool notBool isElab(K) andBool notBool noElab(K)

rule [elabInitHollow]:
    elabInit(K) => elab(K)
when
    notBool needsSpecialElab(K)

rule [elabOtherCool]:
    (elabRes(K) => .) ~> elab(_:KLabel(_,, (CHOLE => elabRes(K)),, _))

rule [elabDisposeOtherStart]:
    elab(KL:KLabel(ElabResL:List{K})) => elabDispose(KL(ElabResL))
when
    isElab(ElabResL) andBool notBool needsSpecialElab(KL(ElabResL))

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
rule isElab(.List{K}) => true               [anywhere]
rule isElab(.K,, _) => false                [anywhere]

rule isElab(KL:KLabel(_),,_) => false
when KL =/=KLabel 'elabRes`(_`)             [anywhere]

//Computes to true if the given arg is a list of terms with none wrapped into elabRes(),
//false otherwise.
syntax K ::= "isNotElab" "(" List{K} ")"        [function]
rule isNotElab(elabRes(_) ,,_) => false         [anywhere]
rule isNotElab(.List{K}) => true                [anywhere]
rule isNotElab((.K => .List{K}),, _)            [anywhere]

rule isNotElab((KL:KLabel(_) => .List{K}),, _)
when KL =/=KLabel 'elabRes`(_`)                 [anywhere]

//Computes true if the given term needs special rules for elaboration, false otherwise
syntax K ::= "needsSpecialElab" "(" K ")"       [function]

//Labels that need special semantics during at the beginning of elab and elabDispose phases.
rule needsSpecialElab(.K) => false

rule needsSpecialElab(KL:KLabel(_)) =>
           KL ==KLabel 'Block

//Labels that should not be heated for elaboration
syntax K ::= "noElab" "(" K ")"                 [function]
rule noElab(.K) => false
rule noElab(KL:KLabel(_)) =>
           KL ==KLabel 'LocalVarDecStm
    orBool KL ==KLabel 'LocalVarDec

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

endmodule
