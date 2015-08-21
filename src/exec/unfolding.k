module UNFOLDING
    imports CORE-SORTS
    imports CORE-FUNCTIONS
    imports SYNTAX-CONVERSIONS

/*@At the beginning of execution semantics <k> contains the term unfoldingPhase, <program> is non-empty and the global phase is UnfoldingPhase.
*/

syntax KItem ::= "unfoldingPhase"

//@In the initial configuration the cell <threads> is empty, global phase is UnfoldingPhase, <program> is non-empty.
rule [UnfoldingPhase-start]:
    <threads>
      . => <thread> <k> unfoldingPhase </k> ...</thread>
    </threads>
    <globalPhase> UnfoldingPhase </globalPhase>
    <program> [_:K,, _] </program>

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
    <NumOfClassesToUnfold> I:Int => I +Int 1 </NumOfClassesToUnfold>

rule [unfolding-class-unfold-inner]:
    <k> unfoldingPhase </k>
    <NumOfClassesToUnfold> I:Int => I +Int 1 </NumOfClassesToUnfold>
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
          'ClassBody( ( ClassDecKL:KLabel(ClassDecKs:KList) Tl:ClassBodyDecList => Tl ) )
        )
      </folded>

      /*It is ok to unfold inner classes only after this class entered UnfoldingStartedCPhase,
        e.g. after it's base class has been completely unfolded.
        This is always possible, because a Java class cannot depend on itself (JLS7 $8.1.4 p.192)
      */
      <classPhase> UnfoldingStartedCPhase </classPhase>
      ...
    </class>
when
    ClassDecKL ==KLabel 'ClassDec orBool ClassDecKL ==KLabel 'InterfaceDec

syntax KItem ::= getClassFromClassDec ( K )   [function]
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


rule [unfolding-class-members-staticFields]:
    <k> unfoldingPhase </k>
    <classType> Class:ClassType </classType>
    <staticFields> C:ClassBodyDecList => addElementToClassBodyDecListEnd(C, StaticField) </staticFields>
    <folded>
      KL:KLabel(
        'ClassDecHead(
          AccessMode:AccessMode,,
          Class,,
          'None(.KList),,
          'Some('SuperDec( BaseClass:ClassType )),,
          'Some('ImplementsDec( _ ))
        ),,
        'ClassBody(
            ( StaticField:ClassBodyDec Rest:ClassBodyDecList => Rest)
        )
      )
    </folded>
    <classPhase> UnfoldingStartedCPhase </classPhase>
when
    containsStaticInit(Rest)

rule [unfolding-class-members-StaticInit-classMetaType-extends]:
    <k> unfoldingPhase </k>
    <classType> Class:ClassType </classType>
    <classMetaType> _ => getClassMetaType(KL) </classMetaType>
    <extends> _ => BaseClass </extends>
    <staticInit> _ => StaticInit </staticInit>
    <folded>
      KL:KLabel(
        'ClassDecHead(
          AccessMode:AccessMode,,
          Class,,
          'None(.KList),,
          'Some('SuperDec( BaseClass:ClassType )),,
          'Some('ImplementsDec( _ ))
        ),,
        'ClassBody(
            ( 'StaticInit('Block(StaticInit:BlockStmList)) Rest:ClassBodyDecList => Rest )
        )
      )
    </folded>
    <classPhase> UnfoldingStartedCPhase </classPhase>

rule [unfolding-class-members-instanceFields]:
    <k> unfoldingPhase </k>
    <classType> Class:ClassType </classType>
    <instanceFields> C:ClassBodyDecList => addElementToClassBodyDecListEnd(C, InstanceField) </instanceFields>
    <folded>
      KL:KLabel(
        'ClassDecHead(
          AccessMode:AccessMode,,
          Class,,
          'None(.KList),,
          'Some('SuperDec( BaseClass:ClassType )),,
          'Some('ImplementsDec( _ ))
        ),,
        'ClassBody(
            (InstanceField:ClassBodyDec Rest:ClassBodyDecList => Rest)
         )
      )
    </folded>
    <classPhase> UnfoldingStartedCPhase </classPhase>
when
    (notBool containsStaticInit(Rest)) andBool getKLabel(InstanceField) =/=KLabel 'MethodDec

syntax KItem ::= getClassMetaType ( KLabel )
rule getClassMetaType('ClassDec) => classCMT            [anywhere]
rule getClassMetaType('InterfaceDec) => interfaceCMT    [anywhere]

// True if given List contains a 'StaticInit(\_) term
syntax KItem ::= containsStaticInit(  ClassBodyDecList )  [function]
rule containsStaticInit('StaticInit(_) _:ClassBodyDecList) => true
rule containsStaticInit(.ClassBodyDecList) => false
rule containsStaticInit(Hd:ClassBodyDec Rest:ClassBodyDecList) => containsStaticInit(Rest) [owise]

rule [unfolding-ImplementsDec]:
    <k> unfoldingPhase </k>
    <classType> Class:ClassType </classType>
    <implTrans>... .Set => SetItem(BaseInterface) ...</implTrans>
    <folded>
      _:KLabel(
        'ClassDecHead(
          _:K,, _:K,, _:K,, _:K,,
          'Some('ImplementsDec(BaseInterface:ClassType, IL:HeatedInterfaceTypeList => IL))
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
                  <methodSignature> sig(Name:Id, getTypes(Params)) </methodSignature>
                  <methodParams> Params </methodParams>
                  <methodBody> MethodBody:K </methodBody>
                  <methodAccessMode> Acc:AccessMode </methodAccessMode>
                  <methodContextType> CT:ContextType </methodContextType>
                  ...
                </methodDec>
      )
      ...
    </methodDecs>
    <methods> Env:Map => Env[sig(Name:Id, getTypes(Params)) <- Class] </methods>
    <folded>
      _:KLabel(
        'ClassDecHead(_),,
        'ClassBody(
          'MethodDec(
            'MethodDecHead(
              accCT(Acc:AccessMode, CT:ContextType),,
              'None(.KList),,//don't know what should be here
              ReturnType:Type,,
              Name:Id,,
              Params,,
              'None(.KList) //don't know what should be here
            ),,
            MethodBody:K
        ) Tl:ClassBodyDecList => Tl )
      )
    </folded>
    <classPhase> UnfoldingStartedCPhase </classPhase>

rule [unfolding-class-end]:
    <k> unfoldingPhase </k>
    <classType> Class:ClassType </classType>
    <classMetaType> _ </classMetaType>  //checking that the rule [unfolding-class-start] was executed
    ( <folded>
        _:KLabel(
          'ClassDecHead( _:K,, Class,, _:K,, _:K,, 'Some('ImplementsDec( .HeatedInterfaceTypeList )) ),,
          'ClassBody( .ClassBodyDecList )
        )
      </folded> => .Bag
    )
    <classPhase> UnfoldingStartedCPhase => UnfoldedCPhase </classPhase>
    <NumOfClassesToUnfold> I:Int => I -Int 1 </NumOfClassesToUnfold>

rule [UnfoldingPhase-end]:
    <k> unfoldingPhase => . </k>
    <globalPhase> UnfoldingPhase </globalPhase>
    <program> [.KList] </program>
    <classes> ClassesBag:Bag </classes>
    <NumOfClassesToUnfold> 0 </NumOfClassesToUnfold>

endmodule
