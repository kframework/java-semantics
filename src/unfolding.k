require "core-sorts.k"
require "core-functions.k"

module UNFOLDING
    imports CORE-SORTS
    imports CORE-FUNCTIONS

rule [UnfoldingPhase-start]:
    <k> . => unfoldingPhase </k>
    <globalPhase> FoldingPhase => UnfoldingPhase </globalPhase>
    <lastGlobalPhase> ExecutionPhase </lastGlobalPhase>

/*@ The sole content of <k> cell during UnfoldingPhase
*/
syntax K ::= "unfoldingPhase"

rule [unfolding-class-unfold-top-level]:
    <k> unfoldingPhase </k>
    (.Bag =>  <class>
                <classType> getClassFromClassDec(ClassDec) </classType>
                <enclosingClass> noClass </enclosingClass>
                <folded> ClassDec </folded>
                <classPhase> FoldedCPhase </classPhase>
                ...
              </class>
    )
    <program> [(ClassDec:K => .KList),, _] </program>

rule [unfolding-class-unfold-inner]:
    <k> unfoldingPhase </k>
    (.Bag =>  <class>
                <classType> getClassFromClassDec(ClassDecKL(ClassDecKs)) </classType>
                <enclosingClass> EnclosingClass </enclosingClass>
                <folded> ClassDecKL(ClassDecKs) </folded>
                <classPhase> FoldedCPhase </classPhase>
                ...
              </class>
    )
    <class>
      <classType> EnclosingClass:ClassType </classType>
      <folded>
        _:KLabel(
          'ClassDecHead(_),,
          'ClassBody( [( ClassDecKL:KLabel(ClassDecKs:KList) => .KList),, _] )
        )
      </folded>

      /*It is ok to unfold inner classes only after this class entered UnfoldingStartedCPhase,
        e.g. after it's base class have been completely unfolded.
        This is always possible, because a Java class cannot depend on itself (JLS7 $8.1.4 p.192)
      */
      <classPhase> UnfoldingStartedCPhase </classPhase>
      ...
    </class>
when
    ClassDecKL ==KLabel 'ClassDec orBool ClassDecKL ==KLabel 'InterfaceDec

syntax K ::= getClassFromClassDec ( K )   [function]
rule getClassFromClassDec(_:KLabel('ClassDecHead( _:K,, Class:ClassType,, _:KList),, _)) => Class

rule [unfolding-class-inherit-methods-not-object]:
    <k> unfoldingPhase </k>
    <class>
      <classType> Class:ClassType </classType>
      <methods> .Map => BaseMethods </methods>  //Required to be able to call inherited methods
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
    <classMetaType> _ => getClassMetaType(KL) </classMetaType>
    <classAccessMode> _ => AccessMode:AccessMode </classAccessMode>
    <extends> _ => BaseClass:ClassType </extends>
    <instanceFields> [_ => InstanceFields:KList] </instanceFields>
    <staticFields> [_ => StaticFields:KList] </staticFields>
    <staticInit> [_ => StaticInit:KList] </staticInit>
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
              'StaticInit('Block(StaticInit:KList)),, //this particular construct assures that
                                                      //this rule will match in the right moment
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
        'ClassBody( [(
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
        ),, _] )
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
    <program> [.KList] </program>
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
