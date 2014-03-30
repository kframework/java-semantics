require "core-sorts.k"

module FOLDING
    imports CORE-SORTS

rule [FoldingPhase-start]:
    <k> . => foldingPhase ...</k>
    <globalPhase> ElaborationPhase => FoldingPhase </globalPhase>

/*@ The sole content of <k> cell during FoldingPhase
*/
syntax K ::= "foldingPhase"

rule [fold-start]:
    <k> foldingPhase </k>
    <classType> Class:ClassType </classType>
    <folded>
      . => 'ClassDec(
             'ClassDecHead(
               [Modifiers],,
               Class,,
               'None(.KList),,
               'Some('SuperDec( BaseClassRaw - extends declaration )),,
               'Some('ImplementsDec([ ImplTypesRaw - implements declarations ]))
             ),,
             'ClassBody( [ Decls - member declarations ] )
           )
    </folded>

endmodule

/*
Additions to other modules:

          <clsFolding color="Yellow">

            //Folded representation of this class
            <folded color="Teal"> .Map </folded>

          </clsFolding>

  / * Folds the <class> cells into a preprocessed Java program. The last step of elaboration semantics.
  * /
  | "FoldingPhase"
*/
