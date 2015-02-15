/*@ This module initialtes the elaboration phase. It is responsible for elaborating all top-level code blocks
  in the program: methods, constructors, static and instance initializers.
*/
module ELABORATION-TOP-BLOCKS
    imports CORE-SORTS
    imports CORE-PREPROCESSING
    imports ELABORATION-CORE

rule [ElaborationPhase-start]:
    <k> . => elaborateBlocks(getTopLevelClasses) </k>
    <globalPhase> ProcClassMembersPhase => ElaborationPhase  </globalPhase>

/*@ Elaborate the blocks inside all classes.
Argument K = setWrap(Set) - the set of all classes.
*/
syntax KItem ::= elaborateBlocks ( K ) [strict]

/*@ It is important to elaborate the instance initializers before the methods.
    This way, when 'SuperConstrEnv is encountered, it inserts the already elaborated instance
    initializer in its place, avoiding name collisions between constructor arguments and fields
    inside instance init.
*/
rule [elaborateBlocks]:
    <k>
      (.K => elabMethods(Methods) ~> elabStaticInit
        ~> elaborateBlocks(getInnerClasses(Class))
        ~> restoreCrntClass(OldCrntClass)
      )
      ~> elaborateBlocks(setWrap((SetItem(Class:ClassType) => .Set) _:Set))
      ...
    </k>
    <crntClass> OldCrntClass:ClassType => Class </crntClass>
    <classType> Class </classType>
    <methods> Methods:Map </methods>

rule [elaborateBlocks-discard]:
    elaborateBlocks(setWrap(.)) => .

/*@ Elaborates the methods of the current class. The map contains the methods that were not elaborated yet.
When a class elaboration starts, the map is initialized with the contet of <methods> - all the methods accessible in
the current class. Only methods declared in the current class are elaborated. The rest are discarded from the map.
*/
syntax KItem ::= elabMethods ( Map )

rule [elabMethods-Heat-MethodParams]:
    <k>
      (. => addElabEnv ~> elab(ParamsList))
      ~> elabMethods( (Sig:Signature |-> Class => .Map) _)
      ...
    </k>
    <crntClass> Class:ClassType </crntClass>
    <contextType> _ => CT </contextType>
    <classType> Class </classType>
    <methodSignature> Sig </methodSignature>
    <methodParams> ParamsList:K => CHOLE </methodParams>
    <methodContextType> CT:ContextType </methodContextType>

rule [elabMethods-Heat-MethodFirstLine]:
    <k>
      (elabRes(ParamsList:K) => elab(FirstLine)) ~> elabMethods(_:Map)
      ...
    </k>
    <crntClass> Class:ClassType </crntClass>
    <contextType> _ => CT </contextType>
    <classType> Class </classType>
    <methodParams> CHOLE => ParamsList </methodParams>
    <methodConstrFirstLine> FirstLine:K => CHOLE </methodConstrFirstLine>
    <methodContextType> CT:ContextType </methodContextType>

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
    <methodConstrFirstLine> CHOLE => FirstLine </methodConstrFirstLine>
    <methodBody> Body:K => CHOLE </methodBody>

rule [elabMethods-Cool-Method]:
    <k>
      (elabRes(Body:K) => removeLastElabEnv) ~> elabMethods(_:Map)
      ...
    </k>
    <crntClass> Class:ClassType </crntClass>
    <classType> Class </classType>
    (<methodConstrFirstLine> _ </methodConstrFirstLine> => .Bag)
    <methodBody> CHOLE => Body </methodBody>
    <methodMetaType> methodMMT </methodMetaType>

rule [elabMethods-Cool-Constructor]:
    <k>
      (elabRes(Body:K) => removeLastElabEnv) ~> elabMethods(_:Map)
      ...
    </k>
    <crntClass> Class:ClassType </crntClass>
    <classType> Class </classType>
    (<methodConstrFirstLine> FirstLine:K </methodConstrFirstLine> => .Bag)
    <methodBody> CHOLE => [FirstLine,, Body] </methodBody>
    <methodMetaType> constructorMMT => methodMMT </methodMetaType>
//todo mapItemByValue/solution
rule [elabMethods-discard-method]:
    <k> elabMethods(M:Map => M -Map removeMapItemsByValue(M,Class) ) ... </k>
    <crntClass> Class:ClassType </crntClass>

rule [elabMethods-End]:
    elabMethods( .Map ) => .

syntax KItem ::= "elabStaticInit"

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
syntax KItem ::= "addElabEnv"
rule [addElabEnv]:
    <k> addElabEnv => .K ...</k>
    <elabEnv> .List => ListItem(mapWrap(.Map)) ...</elabEnv>
    <localTypes> .List => ListItem(mapWrap(.Map)) ...</localTypes>

endmodule
