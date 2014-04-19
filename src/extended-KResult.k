require "core-sorts.k"

module EXTENDED-K-RESULT
    imports CORE-SORTS

/*@ Extended K Result.
  Represents KLabels that should be treated as KResult during execution phase, but not during elaboration phase.
*/
syntax ExtKResult ::= "dummy"

rule isExtKResult(KR:KResult) => true

rule isExtKResult('Param(_:K,, T:Type,, _:Id)) => true

endmodule
