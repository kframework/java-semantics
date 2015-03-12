module CORE-EXEC
    imports CORE-SORTS
    imports SYNTAX-CONVERSIONS

/*@
A collection of utility functions that many other, unrelated modules depend on. Grouped here to minimize
the dependencies between other modules.
*/

//@ ListItem content as a stack layer
syntax KItem ::=  sl (
                K,  //K - rest of computation
                Bag //MethContext - the content of <methodContext>
              )

//@Auxiliary constructs used in variable access semantics.
syntax KItem ::= lvalue ( K )
syntax RawVal ::= loc ( Int )

//@Store to the given location in <store> (first argument) the given value (second argument).
syntax KItem ::=  store (
                Int,  //OL - the store location
                K     //evaluates to TypedVal - the value to be stored
              ) [strict(2)]

//@ Restore the content of the cell \verb|<methodContext>|
syntax KItem ::=  restoreMethContext (
                Bag                 //The content of <methodContext>
              )

rule [restoreMethContext]:
    <k> restoreMethContext(MethContext:Bag) => . ...</k>
    <methodContext> _ => MethContext </methodContext>

endmodule
