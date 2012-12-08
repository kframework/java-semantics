module JAVA-STATIC-INIT
    imports JAVA-CORE

syntax K ::= "staticInit" "(" K // Class - the class to be initialized,
                                // or .K if this term should be discarded.
                          ")"

rule [staticInit]:
    <k>
      staticInit(Class:Id)
      => preInitLocations(LocSet)
      ~> staticInit(BaseClassK)
      ~>  'Try(
            StaticInit,,
            'ListWrap(
              'Catch(
                'Param('ListWrap(.List{K}),,
                  class String2Id("Object"),,
                  String2Id("e")
                ),,
                'Throw(
                  'NewInstance(
                    'None(.List{K}),,
                    class String2Id("ExceptionInInitializerError"),,
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
    <classSimpleName> Class </classSimpleName>
    <extends> BaseClassK:K </extends>
    <staticInit> StaticInit:K </staticInit>
    <staticInitLocations> LocSet:Set </staticInitLocations>
    <staticInitDone> false => true </staticInitDone>

rule [staticInitDiscard]:
    <k>
      staticInit(Class:Id) => .
      ...
    </k>
    <classSimpleName> Class </classSimpleName>
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
