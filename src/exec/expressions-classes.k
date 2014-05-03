/*@ \section{Module EXPRESSIONS-CLASSES}
  Class-related expressions.
*/

module EXPRESSIONS-CLASSES
    imports CORE-SORTS
    imports CORE-CLASSES //for cast
    imports SUBTYPING
    imports TO-STRING

/*@ \subsection{Instance Of} */

//@ 'InstanceOf(V::T,, T2)
syntax KLabel ::= "'InstanceOf"

context 'InstanceOf(HOLE,,_)

rule [InstanceOf]:
    'InstanceOf(V:RawVal::_,, RT2:RefType)
    =>  'LazyAnd((V =/=K null),, subtype(typeOf(V), RT2))

/*@ \subsection{Cast} */

rule [cast-RefType]:
    cast(RT1:RefType, V:RawVal :: RT2:RefType)
    =>  ifAux(
          subtype(typeOf(V), RT1),
          (V::RT1),
          'Throw('NewInstance(
                  'None(.KList),,
                  class String2Id("java.lang.ClassCastException"),,
                  [ 'Plus('Plus(toString(typeOf(V)),, " cannot be cast to "),,
                      toString(RT1)) ],,
                  'None(.KList)
          ))
        )

endmodule
