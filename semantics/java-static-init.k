require "java-core.k"
require "java-process-classes.k"

module JAVA-STATIC-INIT
    imports JAVA-CORE
    imports JAVA-PROCESS-CLASSES

syntax K ::= "staticInit" "(" K // Class - the ClassType to be initialized,
                                // or .K if this term should be discarded.
                          ")"

rule [staticInit]:
    <k>
      staticInit(Class:ClassType)
      => preInitLocations(LocSet)
      ~> staticInit(BaseClassK)
      ~>  'Try(
            StaticInit,,
            'ListWrap(
              'Catch(
                'Param('ListWrap(.List{K}),,
                  objectClass,,
                  String2Id("e")
                ),,
                'Throw(
                  'NewInstance(
                    'None(.List{K}),,
                    class String2Id("java.lang.ExceptionInInitializerError"),,
                    'ListWrap('ExprName(String2Id("e"))),,
                    'None(.List{K})
                  )
                )
              )
            )
          )
      ~> restoreEnvAndObj(Env, Obj)
      ...
    </k>
    <env> Env:Map => . </env>
    <crntObj>
      Obj:Bag
      =>  <crntClass> Class </crntClass>
          <envStack> .List </envStack>
          <location> noValue </location>
    </crntObj>
    <classType> Class </classType>
    <extends> BaseClassK:K </extends>
    <staticInit> StaticInit:K </staticInit>
    <staticInitLocations> LocSet:Set </staticInitLocations>
    <staticInitDone> false => true </staticInitDone>

rule [staticInitDiscard]:
    <k>
      staticInit(Class:ClassType) => .
      ...
    </k>
    <classType> Class </classType>
    <staticInitDone> true </staticInitDone>

rule [staticInitEmpty]:
    staticInit(.K) => .K

/*@initialize the given set of locations to their default value.
First step of the static initializing of a class/interface.
*/
syntax K ::= "preInitLocations" "(" Set //The set of locations to be initialized
                                        //to their default value.
                                ")"

rule [preInitLocations]:
    <k> preInitLocations((SetItem(L:Int) => .) _) ...</k>
    <store>... L |-> (uninitialized(_, T:Type) => default(T)) ...</store>

rule [preInitLocationsDiscard]:
    preInitLocations(.) => .

endmodule
