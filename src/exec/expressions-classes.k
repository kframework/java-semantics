module EXPRESSIONS-CLASSES
    imports CORE-SORTS
    imports CORE-CLASSES //for cast
    imports SUBTYPING
    imports TO-STRING
    imports STMT-SYNTAX

/*@ Expressions that operate over objects.
*/

/*@ \subsection{Instanceof operator} */

rule [InstanceOf]:
    V:RawVal::_ instanceof RT2:RefType
    =>  (V =/=K null) && subtype(typeOf(V), RT2)

/*@ \subsection{Cast operator --- reference types} */
rule [cast-RefType]:
    cast(RT1:RefType, V:RawVal :: RT2:RefType)
    =>  ifAux ( subtype(typeOf(V), RT1) ,
        V::RT1,

          throw new class String2Id("java.lang.ClassCastException") (
            toExps([(toString(typeOf(V)) + " cannot be cast to ") + toString(RT1)])
          );
        )

/*@ \subsection{Auxiliary constructs produced during elaboration} */

rule stmtAndExp(Stmt:K, Exp:K) => Stmt ~> Exp

endmodule
