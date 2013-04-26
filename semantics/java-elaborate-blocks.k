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
           | "elab" "(" K ")"           //Elaborates the given statement/expression.
           | "elabEnd" "(" K ")"        //Intermediate state between elab and elabRes - all subterms were already elaborated.
                                        //Deleting the elabRes() wrappers of subterms
           | "elabRes" "(" K ")"        //Wraps the elaboration result.

rule [elabMethodsHeatMethod]:
  <k>
    (. => elab(Body))
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
    (. => elab(Body))
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
    <k> (. => elab(K)) ~> elabInstanceInit ...</k>
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
    <k> (. => elab(K)) ~> elabStaticInit ...</k>
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

rule [elabOtherHeat]:
    (. => elab(K)) ~> elab(KL:KLabel(_,, (K:K => CHOLE),, _))
when
    notBool isElab(K)

rule [elabOtherCool]:
    (elabRes(K) => .) ~> elab(_:KLabel(_,, (CHOLE => elabRes(K)),, _))

rule [elabEndStart]:
    elab(KL:KLabel(ElabResL:List{K})) => elabEnd(KL(ElabResL))
when
    isElab(ElabResL)

rule [elabEndProcess]:
    elabEnd(KL:KLabel(_,, (elabRes(K:K) => K),, _))

rule [elabEndEnd]:
    elabEnd(KL:KLabel(Ks:List{K})) => elabRes(KL(Ks))
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

endmodule
