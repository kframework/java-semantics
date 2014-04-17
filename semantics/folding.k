require "core-sorts.k"

module FOLDING
    imports CORE-SORTS

rule [FoldingPhase-start]:
    <k> . => foldingPhase </k>
    <globalPhase> ElaborationPhase => FoldingPhase </globalPhase>

/*@ The sole content of <k> cell during FoldingPhase
*/
syntax K ::= "foldingPhase"

/*So far top-level classes only.*/
rule [folding-start]:
    <k> foldingPhase </k>
    <classType> Class:ClassType </classType>
    ( <classMetaType> MetaType:ClassMetaType </classMetaType> => .Bag)
    ( <classAccessMode> AccessMode:AccessMode </classAccessMode> => .Bag)
    ( <extends> BaseClass:ClassType </extends> => .Bag)
    ( <instanceFields> [InstanceFields:KList] </instanceFields> => .Bag)
    ( <staticFields> [StaticFields:KList] </staticFields> => .Bag)
    ( <staticInit> [StaticInit:KList] </staticInit> => .Bag)
    <folded>
      .K => getClassDecLabel(MetaType)
            (
              //JDK comp: #if MetaType ==K classCMT #then 'ClassDecHead #else 'InterfaceDecHead #fi
              'ClassDecHead(
                //JDK comp: #if AccessMode ==K package #then [.KList] #else [AccessMode] #fi
                AccessMode,,
                Class,,
                'None(.KList),,
                //JDK comp: #if BaseClass ==K noClass #then 'None(_) #else 'Some('SuperDec( BaseClass )) #fi
                'Some('SuperDec( BaseClass )),,
                'Some('ImplementsDec( [.KList] )) //processed by [fold-implements-dec]
              ),,
              'ClassBody( [
                  StaticFields,,
                  'StaticInit('Block(StaticInit)),,
                  InstanceFields
                  //instanceInit was converted into method, is not needed here.
              ] )
            )
    </folded>

syntax KLabel ::= getClassDecLabel ( ClassMetaType ) [function]
rule getClassDecLabel ( classCMT ) => 'ClassDec
rule getClassDecLabel ( interfaceCMT ) => 'InterfaceDec

rule [folding-ImplementsDec]:
    <k> foldingPhase </k>
    <classType> Class:ClassType </classType>
    <implTrans>... SetItem(BaseInterface:ClassType) => .Set ...</implTrans>
    <folded>
      _:KLabel(
        'ClassDecHead(
          _:K,, _:K,, _:K,, _:K,,
          'Some('ImplementsDec([_,, (.KList => BaseInterface)]))
        ),,
        _
      )
    </folded>

rule [folding-MethodDec]:
    <k> foldingPhase </k>
    <classType> Class:ClassType </classType>
    ( <methodDec>
        <methodSignature> sig(Name:Id, _) </methodSignature>
        <methodReturnType> ReturnType:Type </methodReturnType>
        <methodParams> [Params:KList] </methodParams>
        <methodBody> MethodBody:K </methodBody>
        <methodAccessMode> Acc:AccessMode </methodAccessMode>
        <methodContextType> CT:ContextType </methodContextType>
        ...
      </methodDec>
      => .Bag
    )
    <folded>
      _:KLabel(
        'ClassDecHead(_),,
        'ClassBody( [_,, (
          .KList => 'MethodDec(
                      'MethodDecHead(
                        [Acc,, CT],,
                        'None(.KList),,//don't know what should be here
                        ReturnType,,
                        Name,,
                        [Params],,
                        'None(.KList) //don't know what should be here
                      ),,
                      MethodBody
                    )

        )] )
      )
    </folded>

rule [folding-class-end]:
    <k> foldingPhase </k>
    <classType> Class:ClassType </classType>
    ( <implTrans> .Set </implTrans> => .Bag)
    ( <methodDecs> .Bag </methodDecs> => .Bag)
    ( <implements> _ </implements> => .Bag)
    ( <methods> _ </methods> => .Bag)
    ( <imports> _ </imports> => .Bag)
    ( <constantEnv> _ </constantEnv> => .Bag)
    ( <enclosingLocalEnv> _ </enclosingLocalEnv> => .Bag)
    <folded> _:KLabel(_) </folded>
    <classPhase> MembersProcessedCPhase => FoldedCPhase </classPhase>

rule [FoldingPhase-end]:
    <k> foldingPhase => . </k>
    <globalPhase> FoldingPhase </globalPhase>
    <classes> ClassesBag:Bag </classes>
when
    notBool containsMembersProcessedClasses(ClassesBag) ==K true

syntax K ::= containsMembersProcessedClasses ( Bag ) [function]
rule containsMembersProcessedClasses(
      <class>
        <cphDiscovered> <classPhase> MembersProcessedCPhase </classPhase> ...</cphDiscovered>
        ...
      </class>
      _:Bag
     ) => true

endmodule
