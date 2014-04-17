require "core-sorts.k"

module FOLDING
    imports CORE-SORTS

//todo unfold when folding phase will be ready.
/*rule [FoldingPhase-start]:
    <k> . => foldingPhase ...</k>
    <globalPhase> ElaborationPhase => FoldingPhase </globalPhase>*/

/*@ The sole content of <k> cell during FoldingPhase
*/
syntax K ::= "foldingPhase"

/*So far top-level classes only.*/
rule [fold-start]:
    <k> foldingPhase </k>
    <classType> Class:ClassType </classType>
    <classMetaType> classCMT </classMetaType>
    <classAccessMode> AccessMode:AccessMode </classAccessMode>
    <enclosingClass> noClass </enclosingClass>
    <extends> BaseClass:ClassType </extends>
    <implTrans> ImplTrans:Set </implTrans>
    <instanceFields> [FieldDecs:KList] </instanceFields>
    <folded>
      .K => 'ClassDec(
              'ClassDecHead(
                //JDK comp: #if AccessMode ==K package #then [.KList] #else [AccessMode] #fi
                AccessMode,,
                Class,,
                'None(.KList),,
                //JDK comp: #if BaseClass ==K noClass #then 'None(_) #else 'Some('SuperDec( BaseClass )) #fi
                'Some('SuperDec( BaseClass )),,
                'Some('ImplementsDec( setToKListWrap(ImplTrans) ))
              ),,
              'ClassBody( [FieldDecs /*,, kListWrapConcat( *//*todo all elements of the body*//*)*/] )
            )
    </folded>

syntax K ::=  setToKListWrap ( Set ) [function]
            | setToKListWrap ( Set, KListWrap ) [function]

rule setToKListWrap(S1:Set) => setToKListWrap ( S1, [.KList] )
rule setToKListWrap( _:Set (SetItem(K:K) => .Set), [_,, (.KList => K)] )
rule setToKListWrap(.Set, [Ks:KList]) => [Ks]

/*@ Concatenates a KListWrap of KListWrap elements into one single KListWrap */
syntax K ::=  kListWrapConcat ( KListWrap // [...,, KListWrap ,,...]
                              ) [function]
            | kListWrapConcat ( KListWrap, // [...,, KListWrap ,,...] - the original list
                                KListWrap  // [...] - the result
                              ) [function]

rule kListWrapConcat([Ks:KList]) => kListWrapConcat([Ks], [.KList])
rule kListWrapConcat([_,, ([Ks:KList] => .KList)], [(.KList => Ks),, _])
rule kListWrapConcat([.KList], [Ks:KList]) => [Ks]

endmodule
