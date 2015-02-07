module CORE-EXEC
    imports CORE-SORTS
    imports SYNTAX-CONVERSIONS

//@ ListItem content as a stack layer
syntax KItem ::=  sl (
                K,  //K - rest of computation
                Bag //MethContext - the content of <methodContext>
              )

//@ \subsection{Auxiliary methods}

//@ Restore the content of the cell <methodContext>
syntax KItem ::=  restoreMethContext (
                Bag                 //The content of <methodContext>
              )

rule [restoreMethContext]:
    <k> restoreMethContext(MethContext:Bag) => . ...</k>
    <methodContext> _ => MethContext </methodContext>

/*@ \subsection{lvalue and loc syntax} */

syntax KItem ::= lvalue ( K )
syntax RawVal ::= loc ( Int )

endmodule
