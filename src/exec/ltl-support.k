require "builtins/model-checker.k"

module LTL-SUPPORT-SYNTAX
    imports LTL-HOOKS
    imports MODEL-CHECKER-HOOKS
    imports CORE-SORTS
    imports CORE-FUNCTIONS
    imports CORE-CLASSES
    imports CORE-EXEC
    imports SYNTAX-CONVERSIONS
    imports VAR-LOOKUP

syntax Prop ::= "eqTo" "(" Exp "," RawVal ")"
             |  "lt" "(" Exp "," RawVal ")"
             |  "leq" "(" Exp "," RawVal ")"
             |  "gt" "(" Exp "," RawVal ")"
             |  "geq" "(" Exp "," RawVal ")"
             |  "neqTo" "(" Exp "," RawVal ")"
endmodule

module LTL-SUPPORT
    imports LTL-SUPPORT-SYNTAX

//@ Access to static field
syntax Exp ::= ClassType "." Id

//@ Access to an instance field
syntax Exp ::= Exp "." Id

syntax K ::= "val" "(" Bag "," Exp ")" [function]

rule [val-local-var]:
    val(
      <generatedTop><T>
        <threads>
          <thread>
            <methodContext> <env>... X |-> L:Int ...</env> ...</methodContext>
            ...
          </thread>
          ...
        </threads>
        ...
      </T> </generatedTop>,
      X:Id => typedLookup(L)
    )

rule [val-static-field]:
    val(
      <generatedTop><T>
        <classes>
          <class>
            <cphDiscovered> <classType> Class </classType> ...</cphDiscovered>
            <cphExec> <staticEnv>... X |-> L:Int ...</staticEnv> ...</cphExec>
            ...
          </class>
          ...
        </classes>
        ...
      </T> </generatedTop>,
      Class:ClassType.X:Id => typedLookup(L)
    )

rule [val-typedLookup]:
    val(
      <generatedTop><T>
        <phExec>
          <store>... L |-> TV:TypedVal ...</store>
          ...
        </phExec>
        ...
      </T> </generatedTop>,
      typedLookup(L:Int) => TV
    )

rule [val-TypedVal]:
    val(_, RV:RawVal::_ ) => RV

rule [val-qualifier-local-var]:
    val(
      <generatedTop><T>
        <threads>
          <thread>
            <methodContext> <env>... X |-> L:Int ...</env> ...</methodContext>
            ...
          </thread>
          ...
        </threads>
        ...
      </T> </generatedTop>,
      (X:Id => typedLookup(L)) . _
    )

rule [val-qualifier-typedLookup]:
    val(
      <generatedTop><T>
        <phExec>
          <store>... L |-> TV:TypedVal ...</store>
          ...
        </phExec>
        ...
      </T> </generatedTop>,
      (typedLookup(L:Int) => TV) . _
    )

rule [val-instance-field]:
    val(
      <generatedTop><T>
        <phExec>
          <objectStore> <object>
            <objectId> OId </objectId>
            <layerClass> QualClass </layerClass>
            <layerEnv>... X |-> L:Int ...</layerEnv>
            ...
          </object> ...</objectStore>
          ...
        </phExec>
        ...
      </T> </generatedTop>,
      objectRef(OId:Int, _)::QualClass:ClassType . X:Id => typedLookup(L)
    )

rule B:Bag |=Ltl eqTo(E:Exp, I:Int) => true when val(B, E) ==K I    [anywhere]

rule B:Bag |=Ltl neqTo(E:Exp, I:Int) => true when val(B, E) =/=K I  [anywhere]

rule B:Bag |=Ltl lt(E:Exp, I:Int) => true when val(B, E) <Int I   [anywhere]

rule B:Bag |=Ltl leq(E:Exp, I:Int) => true when val(B, E) <=Int I [anywhere]

rule B:Bag |=Ltl gt(E:Exp, I:Int) => true when val(B, E) >Int I   [anywhere]

rule B:Bag |=Ltl geq(E:Exp, I:Int) => true when val(B, E) >=Int I [anywhere]

//Required because String2Id is not accessible in LTL formulas. LTL formulas use program parser.
syntax Id ::= id( String ) [function]
rule id(Str:String) => String2Id(Str)

endmodule
