require "java-core.k"
require "java-process-classes.k"

module JAVA-STATIC-INIT
    imports JAVA-CORE
    imports JAVA-PROCESS-CLASSES

syntax K ::= "staticInit" "(" ClassType // Class - the ClassType to be initialized,
                                        // or noClass if this term should be discarded.
                          ")"

rule [staticInit]:
    <k>
      staticInit(Class:ClassType)
      => preInitLocations(LocSet)
      ~> staticInit(BaseClass)
      ~>  'Try(
            StaticInit,,
            'ListWrap(
              'Catch(
                'Param('ListWrap(.KList),,
                  objectClass,,
                  String2Id("e")
                ),,
                'Throw(
                  'NewInstance(
                    'None(.KList),,
                    class String2Id("java.lang.ExceptionInInitializerError"),,
                    'ListWrap(localVar(String2Id("e")) :: objectClass),,
                    'None(.KList)
                  )
                )
              )
            ),,
            restoreEnvObjContext(OldEnvGroup, Obj, CT)
          )
      ...
    </k>
    <envGroup>
      OldEnvGroup:Bag
      => <env> .Map </env> <localClassesEnv> .Map </localClassesEnv>
    </envGroup>
    <crntObj>
      Obj:Bag
      =>  <crntClass> Class </crntClass>
          <location> noValue </location>
    </crntObj>
    <contextType> CT:ContextType => staticCT </contextType>
    <classType> Class </classType>
    <extends> BaseClass:ClassType </extends>
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
    staticInit(noClass) => .K

/*@initialize the given set of locations to their default value.
First step of the static initializing of a class/interface.
*/
syntax K ::= "preInitLocations" "(" Set //The set of locations to be initialized
                                        //to their default value.
                                ")"

rule [preInitLocations]:
    <k> preInitLocations((SetItem(L:Int) => .) _) ...</k>
    <store>... L |-> (uninitialized(_, T:Type) :: _ => default(T)) ...</store>

rule [preInitLocationsDiscard]:
    preInitLocations(.) => .

endmodule
