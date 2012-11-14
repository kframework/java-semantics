module JAVA-STATIC-INIT
    imports JAVA-CORE

syntax K ::= "staticInit" "(" K // Class - the class to be initialized,
                                // or .K if this term should be discarded.
                          ")"

rule [staticInit]:
    <k>
      staticInit(Class:Id)
      => staticInit(BaseClassK)
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
    <className> Class </className>
    <extends> BaseClassK:K </extends>
    <staticInit> StaticInit:K </staticInit>
    <staticInitDone> false => true </staticInitDone>

rule [staticInitDiscard]:
    <k>
      staticInit(Class:Id) => .
      ...
    </k>
    <className> Class </className>
    <staticInitDone> true </staticInitDone>

rule [staticInitEmpty]:
    staticInit(.K) => .K

endmodule
