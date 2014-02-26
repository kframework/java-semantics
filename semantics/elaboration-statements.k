require "core.k"
require "classes.k"
require "elaboration-core.k"

module ELABORATION-STATEMENTS
    imports CORE
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

rule [elab-QSuperConstrInv]:
    <k>
      elab(
        'QSuperConstrInv(Qual:K,, _,, 'ListWrap( Args:KList ))
        => 'ListWrap(
              setEncloser('This(.KList), BaseClass, Qual),,
              'ExprStm('Invoke(
                'SuperMethod('None(.KList),, getConsName(BaseClass) ),,
                'ListWrap(Args)
              )),,
              elabRes(IInit)  //This block was already elaborated. Rule [elabInstanceEnd]
            )
      )
      ...
    </k>
    <crntClass> Class:ClassType </crntClass>
    <classType> Class </classType>
    <extends> BaseClass:ClassType </extends>
    <instanceInit> IInit:K </instanceInit>

rule [elab-AltConstrInv]:
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

/*@ \subsection{Elaboration of statements - step elabEnd} */

rule [elabEnd-statements]:
    elabEnd(KL:KLabel(Ks:KList)) => elabRes(KL(Ks))
when
    notBool isExpressionLabel(KL)

endmodule
