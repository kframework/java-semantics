module CORE-EXEC
    imports CORE-SORTS

//@ ListItem content as a stack layer
syntax KItem ::=  sl (
                K,  //K - rest of computation
                Bag //MethContext - the content of <methodContext>
              )

//@ \subsection{Auxiliary methods}

//@ Restore the content of the cell <methodContext>
syntax Stmt ::=  restoreMethContext (
                Bag                 //The content of <methodContext>
              )

rule [restoreMethContext]:
    <k> restoreMethContext(MethContext:Bag) => . ...</k>
    <methodContext> _ => MethContext </methodContext>

/*@ \subsection{lvalue and loc syntax} */

syntax KItem ::= lvalue ( K ) //lvalue of sth evaluates to location (loc/fieldloc) :: Type
syntax RawVal ::= Loc
syntax Loc ::= StoreLoc | FieldLoc | ArrayElemLoc
syntax StoreLoc ::= loc ( Int )
syntax FieldLoc ::= fieldloc (Int, ClassType, Id) //instance
                  | fieldloc (ClassType, Id)      //static
syntax ArrayElemLoc ::= aeloc (Int, Int)

endmodule
