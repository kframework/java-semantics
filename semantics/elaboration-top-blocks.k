require "core.k"
require "elaboration-core.k"

/*@ This module initialtes the elaboration phase. It is responsible for elaborating all top-level code blocks
  in the program: methods, constructors, static and instance initializers.
*/
module ELABORATION-TOP-BLOCKS
    imports CORE
    imports ELABORATION-CORE

rule [elaborateBlocksStart]:
    <k> . => elaborateBlocks(getTopLevelClasses) </k>
    <globalPhase> ProcClassMembersPhase => ElaborationPhase  </globalPhase>

//@It is important to elaborate the instance initializers before the methods.
//@This way, when 'SuperConstrEnv is encountered, it inserts the already elaborated instance
//@initializer in its place, avoiding name collisions between constructor arguments and fields
//@inside instance init.
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

//@Required when processing first constructor line of Object, which is .K
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
    <k> elabRes(K:K) ~> elabInstanceInit => removeLastElabEnv ...</k>
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
    <k> elabRes(K:K) ~> elabStaticInit => removeLastElabEnv ...</k>
    <crntClass> Class:ClassType </crntClass>
    <classType> Class </classType>
    <staticInit> CHOLE => K </staticInit>

//@Adds a new empty layer to <elabEnv>
syntax K ::= "addElabEnv"
rule [addElabEnv]:
    <k> addElabEnv => . ...</k>
    <elabEnv> . => ListItem(stEnv(.Map)) ...</elabEnv>
    <localTypes> . => ListItem(stEnv(.Map)) ...</localTypes>

endmodule
