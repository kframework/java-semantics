require "builtins/model-checker.k"
require "../common/shared-syntax.k"

module LTL-SUPPORT-SYNTAX
    imports SYNTAX-CONVERSIONS
    imports JAVA-SYNTAX

syntax Prop ::= Exp

//For the sake of second argument of instanceof
//syntax Exp ::= ClassType

//@ Access to static field
syntax Exp ::= ClassType "." Id

//For the RHS of instanceof.
syntax RefType ::= Id

syntax Exp ::= "(" Exp ")" [bracket]

//@ Access to an instance (or static) field
//             | Exp "." Id

//@ <= operator, for LTL formulas, moved to shared syntax
         //   > Exp "<=" Exp

          //| Exp "!=" Exp
//             | "this"
//             | Exp "instanceof" Exp

endmodule

module LTL-SUPPORT
    imports LTL-SUPPORT-SYNTAX
    imports LTL-HOOKS
    imports MODEL-CHECKER-HOOKS
    imports CORE-SORTS
    imports CORE-FUNCTIONS
    imports CORE-CLASSES
    imports CORE-EXEC
    imports VAR-LOOKUP

rule B:Bag |=Ltl KL:KLabel((E:Exp => ltlEval(B, E)),, _:K)
when
    //(KL ==KLabel '_==_ orBool KL ==KLabel '_<=_ orBool KL ==KLabel '_!=_ orBool KL ==KLabel '_instanceof_)
    (KL ==KLabel 'Eq orBool KL ==KLabel 'LtEq orBool KL ==KLabel 'NotEq orBool KL ==KLabel 'InstanceOf)
    andBool notBool isKResult(E) ==K true                                                           [anywhere]

rule B:Bag |=Ltl KL:KLabel(_:K,, (E:Exp => ltlEval(B, E)))
when
    //(KL ==KLabel '_==_ orBool KL ==KLabel '_<=_ orBool KL ==KLabel '_!=_ orBool KL ==KLabel '_instanceof_)
    (KL ==KLabel 'Eq orBool KL ==KLabel 'LtEq orBool KL ==KLabel 'NotEq orBool KL ==KLabel 'InstanceOf)
    andBool notBool isKResult(E) ==K true                                                           [anywhere]

rule B:Bag |=Ltl ((RV1:RawVal::_) == (RV2:RawVal::_)) => RV1 ==K RV2      [anywhere]
rule B:Bag |=Ltl ((RV1:RawVal::_) != (RV2:RawVal::_)) => RV1 =/=K RV2     [anywhere]
rule B:Bag |=Ltl ((I1:Int::_)     <= (I2:Int::_))     => I1 <=Int I2      [anywhere]
rule B:Bag |=Ltl ((objectRef(_, Class:ClassType)::_) instanceof Class) => true  [anywhere]

syntax KItem ::= ltlEval ( Bag , Exp ) [function]

rule [ltlEval-local-var]:
    ltlEval(
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

rule [ltlEval-typedLookup]:
    ltlEval(
      <generatedTop><T>
        <phExec>
          <store>... L |-> TV:TypedVal ...</store>
          ...
        </phExec>
        ...
      </T> </generatedTop>,
      typedLookup(L:Int)
    ) => TV

rule [ltlEval-RawVal]:
    ltlEval(_, RV:RawVal ) => toTypedVal(RV)

rule [ltlEval-qualifier-heat]:
    ltlEval( B:Bag, (E:Exp => ltlEval(B, E)) . _ )
when
    notBool isKResult(E) ==K true

rule [ltlEval-class]:
    ltlEval(
      <generatedTop><T>
        <classes>
          <class>
            <cphDiscovered> <classType> Class:ClassType </classType> ...</cphDiscovered>
            ...
          </class>
          ...
        </classes>
        ...
      </T> </generatedTop>,
      X:Id
    ) => Class
when
    getSimpleName(Class) ==K X

rule [ltlEval-static-field]:
    ltlEval(
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
      Class:ClassType . X:Id => typedLookup(L)
    )

rule [ltlEval-instance-field]:
    ltlEval(
      <generatedTop><T>
        <phExec>
          <objectStore> <object>
            <objectId> OId </objectId>
            <layer>
              <layerClass> QualClass </layerClass>
              <layerEnv>... X |-> L:Int ...</layerEnv>
              ...
            </layer>
            ...
          </object> ...</objectStore>
          ...
        </phExec>
        ...
      </T> </generatedTop>,
      objectRef(OId:Int, _)::QualClass:ClassType . X:Id => typedLookup(L)
    )

rule [ltlEval-this-instance]:
    ltlEval(
      <generatedTop><T>
        <threads>
          <thread>
            <methodContext> <location> OL:Int </location> ...</methodContext>
            ...
          </thread>
          ...
        </threads>
        ...
      </T> </generatedTop>,
      this => typedLookup(OL)
    )

rule [ltlEval-this-static]:
    ltlEval(
      <generatedTop><T>
        <threads>
          <thread>
            <methodContext> <location> noValue </location> ...</methodContext>
            ...
          </thread>
          ...
        </threads>
        ...
      </T> </generatedTop>,
      this
    ) => null

endmodule
