require "core.k"
require "elaboration-core.k"

module ELABORATION-STATEMENTS
    imports CORE
    imports ELABORATION-CORE

//@ Elaboration of blocks

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

//@ HOLE is transformed into paramImpl
context elab('Catch(HOLE,, _))
when getKLabel(HOLE) =/=KLabel 'elabRes`(_`)

//@ Catch creates a new env layer and saves its argument.
rule [elabCatch]:
    <k> elab('Catch(Param:KResult,, Body:K)) => elabParams(Param) ~> elab(Body) ~> elab('Catch(elabRes(Param),, CHOLE)) ...</k>
    <elabEnv> (. => ListItem(StEnvK)) ListItem(StEnvK:K) ...</elabEnv>
    <localTypes> (. => ListItem(LocTypesK)) ListItem(LocTypesK:K) ...</localTypes>

//here we need elabDispose because the block content is a list.
//We could move the elabdospose logic to ListWrap instead of having it here.
rule [elabDisposeBlockForOrCatch]:
    <k> elab(KL:KLabel(ElabResL:KList)) => removeLastElabEnv ~> elabDispose(KL(ElabResL)) ...</k>
when
    isElab(ElabResL)
    andBool ((KL ==KLabel 'Block) orBool (KL ==KLabel 'For) orBool (KL ==KLabel 'Catch))

//@ Local var declarations desugaring

rule [LocalVarDecStmRed]:
    elab('LocalVarDecStm('LocalVarDec(Ks:KList))
      => 'LocalVarDec(Ks)
    )                                                   [structural]

//@ Resolve the local var type, required to register the var in <elabEnv>
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

//@\subsection{Elaboration of SuperConstrInv, AltConstrInv}

//@ Desugaring unqualified superclass constructor invocation into a qualified one
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

endmodule
