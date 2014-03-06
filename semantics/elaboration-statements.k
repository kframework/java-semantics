require "core-sorts.k"
require "classes.k"
require "elaboration-core.k"

module ELABORATION-STATEMENTS
    imports CORE-SORTS
    imports CLASSES             //for setEncloser
    imports ELABORATION-CORE

//@ Elaboration of 'ListWrap, 'Block, 'For or 'Catch - nodes that may contain variable declarations.

/*@ 'ListWrap nodes need to be elaborated left-to-right. Required when direct child elements might contain variable
declarations.
*/
rule customElabHeating('ListWrap, HeadKs:KList,, K:K) => isElab(HeadKs)

/*@ In addition to what defaul elab heating does, when we heat the first argument of 'Block, 'For of 'Catch
we need to save a copy of elaboration environment - e.g. the last entry of <elabEnv> <localTypes>.
This is because these statements are blocks that might declare local variables.
*/
rule [elab-Block-For-Catch-heat-FirstSubterm]:
    <k> elab(KL:KLabel(K:K,, Ks:KList)) => elab(K) ~> elab(KL(CHOLE,, Ks:KList)) ...</k>
    <elabEnv> (. => ElabEnvLI) ElabEnvLI:ListItem ...</elabEnv>
    <localTypes> (. => LocalTypesLI) LocalTypesLI:ListItem ...</localTypes>
when
    (KL ==KLabel 'Block orBool KL ==KLabel 'For orBool KL ==KLabel 'Catch)
    andBool notBool isElab(K)

rule [customElabHeating-For-first-child]:
    customElabHeating('For, KHole:K) => false

//Seqstrict logic: children should be heated left-to-right
rule [customElabHeating-For-next-children]:
    customElabHeating('For, HeadKs:KList,, KPrec:K,, KHole:K) => isElab(HeadKs,,KPrec)

rule [customElabHeating-Catch-first-child]:
    customElabHeating('Catch, KHole:K) => false

rule [customElabHeating-For-next-children]:
    customElabHeating('Catch, K1:K,, KHole:K) => isElab(K1)

rule [elabEnd-Block-For-Catch]:
    elabEnd(KL:KLabel(ElabResL:KList)) => removeLastElabEnv ~> elabRes(KL(ElabResL))
when
    KL ==KLabel 'Block orBool KL ==KLabel 'For orBool KL ==KLabel 'Catch

//@ Local var declarations desugaring

rule [elab-LocalVarDecStm-desugar]:
    elab('LocalVarDecStm('LocalVarDec(Ks:KList))
      => 'LocalVarDec(Ks)
    )                                                   [structural]

//@ Resolve the local var type, required to register the var in <elabEnv>
context elab('LocalVarDec(_:K,, HOLE,, _:K))

rule [elab-LocalVarDec-multi-desugar]:
    elab('LocalVarDec(K:K,, T:Type,, 'ListWrap(Var1:K,, Var2:K,, VarDecs:KList))
      => 'ListWrap('LocalVarDec(K,, T,, 'ListWrap(Var1)),,
            'LocalVarDec(K,, T,, 'ListWrap(Var2,, VarDecs)))
    )                                                   [structural]

rule [elab-LocalVarDec-with-init-desugar]:
    elab('LocalVarDec(K:K,, T:Type,, 'ListWrap('VarDec(X:Id,,InitExp:K)))
    => 'ListWrap('LocalVarDec(K,, T,, 'ListWrap('VarDec(X:Id))),,
        'ExprStm('Assign('ExprName(X),, InitExp))))
when
    getKLabel(InitExp) =/=KLabel 'ArrayInit             [structural]

rule [elab-LocalVarDec]:
    <k>
      elab('LocalVarDec(K:K,, T:Type,, 'ListWrap('VarDec(X:Id))))
      => elabRes('LocalVarDec(K,, T,, 'ListWrap('VarDec(X))))
      ...
    </k>
    <elabEnv> ListItem(mapWrap((. => X |-> T) _)) ...</elabEnv>

//@\subsection{Elaboration of SuperConstrInv, QSuperConstrInv, AltConstrInv}

//@ _:K,, 'ListWrap( Args:KList )
syntax KLabel ::=  "'SuperConstrInv"

//@ Desugaring unqualified superclass constructor invocation into a qualified one
rule [elab-SuperConstrInv-desugar]:
    <k>
      elab(
        'SuperConstrInv(K:K,, 'ListWrap( Args:KList ))
        =>  'QSuperConstrInv(
              getQThisSubclassOf(EnclosingClass, SubEnclosingClass),,
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

rule customElabEnd('QSuperConstrInv) => true

rule [elabEnd-QSuperConstrInv-to-lookupMethod]:
    <k>                                                                     //The signature lookup is unqualified
      (. => lookupMethod(BaseClass, getConsName(BaseClass), noValue, false, cast(BaseClass, 'QThis(BaseClass)), Args))
      ~> elabEnd('QSuperConstrInv(Qual:K,, Arg2:K,, 'ListWrap( Args:KList )))
      ...
    </k>
    <crntClass> Class:ClassType </crntClass>
    <classType> Class </classType>
    <extends> BaseClass:ClassType </extends>

rule [elabEnd-QSuperConstrInv-methodProcessArguments-to-argsElaborated]:
    (methodProcessArguments(_,_,_,_, types(.KList), .KList, ExpectedParamExps:KList, instanceCT) => argsElaborated)
    ~> elabEnd('QSuperConstrInv(_:K,, _:K,, 'ListWrap( _ => ExpectedParamExps )))

//todo pack QSuperConstrInv back into into SuperConstrInv when class is top-level.
rule [elab-QSuperConstrInv]:
    argsElaborated
    ~> elabEnd( 'QSuperConstrInv(Qual:K,, Arg2:K,, 'ListWrap( Args:KList )))
    => elabRes('QSuperConstrInv(Qual,, Arg2,, 'ListWrap( Args )))

rule customElabEnd('AltConstrInv) => true

rule [elabEnd-AltConstrInv-to-lookupMethod]:
    <k>                                                           //lookup could be either qualified or unqualified
      (. => lookupMethod(Class, getConsName(Class), noValue, false, Class, Args))
      ~> elabEnd('AltConstrInv(Arg1:K,, 'ListWrap( Args:KList )))
      ...
    </k>
    <crntClass> Class:ClassType </crntClass>

rule [elabEnd-AltConstrInv-methodProcessArguments-to-argsElaborated]:
    (methodProcessArguments(_,_,_,_, types(.KList), .KList, ExpectedParamExps:KList, instanceCT) => argsElaborated)
    ~> elabEnd('AltConstrInv(Arg1:K,, 'ListWrap( _ => ExpectedParamExps )))

rule [elab-AltConstrInv]:
    argsElaborated
    ~> elabEnd('AltConstrInv(Arg1:K,, 'ListWrap( Args:KList )))
    => elabRes('AltConstrInv(Arg1:K,, 'ListWrap( Args:KList )))

endmodule
