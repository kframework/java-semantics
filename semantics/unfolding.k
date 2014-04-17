require "core-sorts.k"
require "core-functions.k"

module UNFOLDING
    imports CORE-SORTS
    imports CORE-FUNCTIONS

rule [UnfoldingPhase-start]:
    <k> . => unfoldingPhase </k>
    <globalPhase> FoldingPhase => UnfoldingPhase </globalPhase>

/*@ The sole content of <k> cell during UnfoldingPhase
*/
syntax K ::= "unfoldingPhase"

rule [unfolding-class-inherit-methods-not-object]:
    <k> unfoldingPhase </k>
    <class>
      <classType> Class:ClassType </classType>
      (.Bag => <methods> BaseMethods </methods>)  //Required to be able to call inherited methods
      <folded>
        KL:KLabel(
          'ClassDecHead( _:K,, Class,, _:K,, 'Some('SuperDec( BaseClass:ClassType )),, _:K),,
          _
        )
      </folded>
      <classPhase> FoldedCPhase => UnfoldingStartedCPhase </classPhase>
      ...
    </class>
    <class>
      <classType> BaseClass </classType>
      <methods> BaseMethods:Map </methods>
      <classPhase> UnfoldedCPhase </classPhase>
      ...
    </class>

rule [unfolding-class-inherit-methods-object-and-interfaces]:
    <k> unfoldingPhase </k>
    <classType> Class:ClassType </classType>
    (.Bag => <methods> .Map </methods>)
    <folded>
      KL:KLabel(
        'ClassDecHead( _:K,, Class,, _:K,, 'Some('SuperDec( noClass )),, _:K),,
        _
      )
    </folded>
    <classPhase> FoldedCPhase => UnfoldingStartedCPhase </classPhase>

rule [unfolding-class-members-except-methods]:
    <k> unfoldingPhase </k>
    <classType> Class:ClassType </classType>
    (.Bag => <classMetaType> getClassMetaType(KL) </classMetaType>)
    (.Bag => <classAccessMode> AccessMode:AccessMode </classAccessMode>)
    (.Bag => <extends> BaseClass:ClassType </extends>)
    (.Bag => <implTrans> .Set </implTrans>)
    (.Bag => <instanceFields> [InstanceFields:KList] </instanceFields>)
    (.Bag => <staticFields> [StaticFields:KList] </staticFields>)
    (.Bag => <staticInit> [StaticInit:KList] </staticInit>)
    (.Bag => <methodDecs> .Bag </methodDecs>)
    <folded>
      KL:KLabel(
        'ClassDecHead(
          AccessMode:AccessMode,,
          Class,,
          'None(.KList),,
          'Some('SuperDec( BaseClass:ClassType )),,
          'Some('ImplementsDec( [_] ))
        ),,
        'ClassBody( [
            ( StaticFields:KList,,
              'StaticInit('Block(StaticInit:KList)),,
              InstanceFields:KList
              => .KList
            ),,
            'MethodDec(_),,_:KList
        ] )
      )
    </folded>
    <classPhase> UnfoldingStartedCPhase </classPhase>
when
    notBool containsMethodDecs([InstanceFields]) ==K true

syntax K ::= getClassMetaType ( KLabel )      [function]
rule getClassMetaType('ClassDec) => classCMT
rule getClassMetaType('InterfaceDec) => interfaceCMT

//@ True if given KListWrap contains a 'MethodDec(_) term
syntax K ::= containsMethodDecs(  KListWrap )  [function]
rule containsMethodDecs([_,, 'MethodDec(_),, _]) => true

rule [unfolding-ImplementsDec]:
    <k> unfoldingPhase </k>
    <classType> Class:ClassType </classType>
    <implTrans>... .Set => SetItem(BaseInterface:ClassType) ...</implTrans>
    <folded>
      _:KLabel(
        'ClassDecHead(
          _:K,, _:K,, _:K,, _:K,,
          'Some('ImplementsDec([_,, (BaseInterface => .KList)]))
        ),,
        _
      )
    </folded>
    <classPhase> UnfoldingStartedCPhase </classPhase>

rule [unfolding-MethodDec]:
    <k> unfoldingPhase </k>
    <classType> Class:ClassType </classType>
    <methodDecs>
      (.Bag =>  <methodDec>
                  <methodSignature> sig(Name:Id, getTypes([Params])) </methodSignature>
                  <methodReturnType> ReturnType:Type </methodReturnType>
                  <methodParams> [Params:KList] </methodParams>
                  <methodBody> MethodBody:K </methodBody>
                  <methodAccessMode> Acc:AccessMode </methodAccessMode>
                  <methodContextType> CT:ContextType </methodContextType>
                  ...
                </methodDec>
      )
      ...
    </methodDecs>
    <methods> Env:Map => Env[Class / sig(Name:Id, getTypes([Params]))] </methods>
    <folded>
      _:KLabel(
        'ClassDecHead(_),,
        'ClassBody( [_,, (
          'MethodDec(
            'MethodDecHead(
              [Acc:AccessMode,, CT:ContextType],,
              'None(.KList),,//don't know what should be here
              ReturnType:Type,,
              Name:Id,,
              [Params:KList],,
              'None(.KList) //don't know what should be here
            ),,
            MethodBody:K
          ) => .KList
        )] )
      )
    </folded>
    <classPhase> UnfoldingStartedCPhase </classPhase>

rule [unfolding-class-end]:
    <k> unfoldingPhase </k>
    <classType> Class:ClassType </classType>
    <classMetaType> _ </classMetaType>  //checking that the rule [unfolding-class-start] was executed
    ( <folded>
        _:KLabel(
          'ClassDecHead( _:K,, Class,, _:K,, _:K,, 'Some('ImplementsDec( [.KList] )) ),,
          'ClassBody( [ .KList ] )
        )
      </folded> => .Bag
    )
    <classPhase> UnfoldingStartedCPhase => UnfoldedCPhase </classPhase>

rule [UnfoldingPhase-end]:
    <k> unfoldingPhase => . </k>
    <globalPhase> UnfoldingPhase </globalPhase>
    <classes> ClassesBag:Bag </classes>
when
    notBool containsFoldedClasses(ClassesBag) ==K true

syntax K ::= containsFoldedClasses ( Bag ) [function]
rule containsFoldedClasses(
      <class>
        <cphDiscovered> <classPhase> ClassPhase:ClassPhase </classPhase> ...</cphDiscovered>
        ...
      </class>
      _:Bag
     ) => true
when
    ClassPhase =/=K UnfoldedCPhase

endmodule
