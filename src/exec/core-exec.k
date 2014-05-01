require "../common/core-sorts.k"

//@ \section{Module CORE-EXEC}

module CORE-EXEC
    imports CORE-SORTS

//@ ListItem content as a stack layer
syntax K ::=  sl (
                K,  //K - rest of computation
                Bag //MethContext - the content of <methodContext>
              )

//@ \subsection{Auxiliary methods}

//@ Restore the content of the cell <methodContext>
syntax K ::=  restoreMethContext (
                Bag                 //The content of <methodContext>
              )

rule [restoreMethContext]:
    <k> restoreMethContext(MethContext:Bag) => . ...</k>
    <methodContext> _ => MethContext </methodContext>

endmodule
