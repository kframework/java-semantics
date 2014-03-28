require "core-sorts.k"
require "elaboration-core.k"

/*@ This module initialtes the elaboration phase. It is responsible for elaborating all top-level code blocks
  in the program: methods, constructors, static and instance initializers.
*/
module ELABORATION-TOP-BLOCKS
    imports CORE-SORTS
    imports ELABORATION-CORE

rule [elaborateBlocksStart]:
    <k> . => elaborateBlocks(getTopLevelClasses) </k>
    <globalPhase> ProcClassMembersPhase => ElaborationPhase  </globalPhase>

/*@ It is important to elaborate the instance initializers before the methods.
    This way, when 'SuperConstrEnv is encountered, it inserts the already elaborated instance
    initializer in its place, avoiding name collisions between constructor arguments and fields
    inside instance init.
*/
rule [elaborateBlocks]:
    <k>
      (. => elabMethods(MethodDecs) ~> elabStaticInit
        ~> elaborateBlocks(getInnerClasses(Class))
        ~> restoreCrntClass(OldCrntClass)
      )
      ~> elaborateBlocks(setWrap((SetItem(Class:ClassType) => .) _:Set))
      ...
    </k>
    <crntClass> OldCrntClass:ClassType => Class </crntClass>
    <classType> Class </classType>
    <methodDecs> MethodDecs:Map </methodDecs>

rule [elaborateBlocks-discard]:
    elaborateBlocks(setWrap(.)) => .

rule [elabMethods-Heat-MethodParams]:
    <k>
      (. => addElabEnv ~> elab(ParamsList))
      ~> elabMethods( (Sig |-> _ => .Map) _)
      ...
    </k>
    <crntClass> Class:ClassType </crntClass>
    <classType> Class </classType>
    <methodDecs>
      Sig:Signature
      |-> methodClosure(MClass:ClassType, (ParamsList:K => CHOLE), CT:ContextType,_,_,_,_) :: methodType(_,_)
      ...
    </methodDecs>
    <contextType> _ => CT </contextType>

rule [elabMethods-Heat-MethodFirstLine]:
    <k>
      (elabRes(ParamsList:K) => elab(FirstLine)) ~> elabMethods(_:Map)
      ...
    </k>
    <crntClass> Class:ClassType </crntClass>
    <classType> Class </classType>
    <methodDecs>
      Sig:Signature |-> methodClosure(MClass:ClassType, (CHOLE => ParamsList), CT:ContextType,_,_,
                                      (FirstLine:K => CHOLE), Body:K) :: methodType(_,_)
      ...
    </methodDecs>
    <contextType> _ => CT </contextType>

//@Required when processing first line of the constructor of Object, which is .K
rule [elab-DotK]:
    elab(.K) => elabRes(.K)

rule [elabMethods-Heat-MethodBody]:
    <k>
      (elabRes(FirstLine:K) => elab(Body)) ~> elabMethods(_:Map)
      ...
    </k>
    <crntClass> Class:ClassType </crntClass>
    <classType> Class </classType>
    <methodDecs>
      Sig:Signature |-> methodClosure(MClass:ClassType, 'ListWrap(Params:KList), _,_,_,
                                      CHOLE => FirstLine, Body:K => CHOLE) :: methodType(_,_)
      ...
    </methodDecs>

rule [elabMethods-Cool-Method]:
    <k>
      (elabRes(Body:K) => removeLastElabEnv) ~> elabMethods(_:Map)
      ...
    </k>
    <crntClass> Class:ClassType </crntClass>
    <classType> Class </classType>
    <methodDecs>
      Sig:Signature |-> methodClosure(MClass:ClassType, 'ListWrap(Params:KList), _,_, methodRT,
                                      FirstLine:K, CHOLE => Body) :: methodType(_,_)
      ...
    </methodDecs>

rule [elabMethods-Cool-Constructor]:
    <k>
      (elabRes(Body:K) => removeLastElabEnv) ~> elabMethods(_:Map)
      ...
    </k>
    <crntClass> Class:ClassType </crntClass>
    <classType> Class </classType>
    <methodDecs>
      Sig:Signature |-> methodClosure(MClass:ClassType, 'ListWrap(Params:KList), _,_,
        constructorRT => methodRT,
        FirstLine:K => noValue,
        CHOLE => 'ListWrap(FirstLine,, Body)
      ) :: methodType(_,_)
      ...
    </methodDecs>

rule [elabMethods-End]:
    elabMethods( .Map ) => .

rule [elabStaticInit-Heat]:
    <k> (. => addElabEnv ~> elab(K)) ~> elabStaticInit ...</k>
    <crntClass> Class:ClassType </crntClass>
    <classType> Class </classType>
    <staticInit> K:K => CHOLE </staticInit>
    <contextType> _ => staticCT </contextType>
when K =/=K CHOLE

rule [elabStaticInit-End]:
    <k> elabRes(K:K) ~> elabStaticInit => removeLastElabEnv ...</k>
    <crntClass> Class:ClassType </crntClass>
    <classType> Class </classType>
    <staticInit> CHOLE => K </staticInit>

//@Adds a new empty layer to <elabEnv>
syntax K ::= "addElabEnv"
rule [addElabEnv]:
    <k> addElabEnv => . ...</k>
    <elabEnv> . => ListItem(mapWrap(.Map)) ...</elabEnv>
    <localTypes> . => ListItem(mapWrap(.Map)) ...</localTypes>

endmodule
