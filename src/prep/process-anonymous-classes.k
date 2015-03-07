module PROCESS-ANONYMOUS-CLASSES
    imports CORE-SORTS
    imports CORE-CLASSES
    imports ELABORATION-CORE
    imports PROCESS-LOCAL-CLASSES

/*Case one - anonymous class implementing an interface. The class body has nothing else
but the members provided in the anonymous class definition block.
*/
rule [elab-NewInstance-anonymous-implements-interface]:
    <k>
      elab('NewInstance(Arg1:K,, Class:ClassType,,
          elabRes([ActualArgs:KList]),,
          'Some('ClassBody([AnonClassDecs:KList]))
      ))
      => processAnonymousClass(
        String2Id("Anonymous_$" +String Int2String(LocalId)),
        classObject,
        [Class],
        Arg1,
        [ActualArgs],
        [AnonClassDecs],
        .Params,
        kr[.KList]
      )
      ...
    </k>
    <nextLocalId> LocalId:Int => LocalId +Int 1 </nextLocalId>
    <classType> Class </classType>
    <classMetaType> interfaceCMT </classMetaType>

rule [elab-NewInstance-anonymous-extends-class]:
    <k>
      elab('NewInstance(Arg1:K,, Class:ClassType,,
          elabRes([ActualArgs:KList]),,
          'Some('ClassBody([AnonClassDecs:KList]))
      ))
      => processAnonymousClass(
        String2Id("Anonymous_$" +String Int2String(LocalId)),
        Class,
        [.KList],
        Arg1,
        [ActualArgs],
        [AnonClassDecs],
        buildConstructorFormalParams([ActualArgs], .Params, 0),
        buildConstructorFirstLineArgs([ActualArgs], [.KList], 0)
      )
      ...
    </k>
    <nextLocalId> LocalId:Int => LocalId +Int 1 </nextLocalId>
    <classType> Class </classType>
    <classMetaType> classCMT </classMetaType>

syntax KItem ::=  processAnonymousClass (
                Id,        //Class name
                ClassType, //Base class
                KListWrap, //Base interfaces, if any. In fact either zero or one interface is possible at this point.
                K,         //'NewInstance Arg1
                KListWrap, //ActualArgs
                KListWrap, //Anonymous class block decs
                K,         //To be processed into formal params
                K          //To be processed into kr[constructor first line arguments]
              )
              [strict(8)]

/*@ In the current approach stmtAndExp cannot be elliminated from here. The local class declaration
    will be transformed into the instantiation and initialziation of the parameter object.
    This will imply a 'NewInstance and zero or more 'Assign statements.
    Theoretically for anonymous classes the parameter object could be instantiated right in the 'NewInstance
    expression of its local class, with parameters passed as constructor arguments, thus eliminating the need of a
    separate variable declaration. But this would complicate the semantics too much. So in theory,
    we could eliminate stmtAndExp even from this place.
*/
rule [processAnonymousClass]:
    processAnonymousClass(
      Name:Id,
      BaseClass:ClassType,
      [BaseInterfaces:KList],
      Arg1:K,
      [ActualArgs:KList],
      [AnonClassDecs:KList],
      ConstructorFormalParams:Params,
      kr[ConstructorFirstLineArgs:KList]
    )
    => elab(
      stmtAndExp(
        'ClassDecStm(
          'ClassDec(
            'ClassDecHead(
              [.KList],,
              Name,,
              'None(.KList),,
              'Some('SuperDec(BaseClass)),,
              'Some('ImplementsDec([BaseInterfaces]))
            ),,
            'ClassBody([
              AnonClassDecs,,

              //Anonymous class constructor
              'ConstrDec(
                'ConstrDecHead(
                  ['Public(.KList)],,
                  'None(.KList),,
                  Name,,
                  ConstructorFormalParams,,
                  'None(.KList)
                ),,
                'ConstrBody(
                  'Some('SuperConstrInv('None(.KList),,[ConstructorFirstLineArgs])),,
                  [.KList]
                )
              )
            ])
          )
        ),
        'NewInstance(Arg1,, 'TypeName(Name),, elabRes([ActualArgs]),, 'None(.KList))
      )
    )

/*@ Build the part of the constructor of an anonymous class definition corresponding
to formal params, and arguments of the superclass constructor invocation, respectively
First KList - list of actual arguments
Second KList - the result
Third arg - a counter used to generate var names
*/
syntax KItem ::= buildConstructorFormalParams ( KListWrap, Params, Int ) [function]
               | buildConstructorFirstLineArgs ( KListWrap, KListWrap, Int )

rule buildConstructorFormalParams(
      [(ActualParam:K => .KList),,_],
      (P:Params => addElementToParamsEnd(P, .AnnoVarModList typeOf(ActualParam) String2Id("$" +String Int2String(Num)))),
      Num:Int => Num +Int 1
    )

rule buildConstructorFormalParams([.KList], P:Params, _) => P

rule buildConstructorFirstLineArgs(
      [(_:K => .KList),, _],
      [_,, (.KList => 'ExprName(String2Id("$" +String Int2String(Num) )))],
      Num:Int => Num +Int 1
    )

rule buildConstructorFirstLineArgs([.KList], [Ks:KList], _) => kr[Ks]

rule [elab-QNewInstance-anonymous-extends-class]:
    <k>
      elab('QNewInstance(elabRes(TypedQual:K),, elabRes(Arg2:K),, Class:ClassType,, elabRes(Arg4:K),,
          elabRes([ActualArgs:KList]),,
          'Some('ClassBody([AnonClassDecs:KList]))
      ))
      => processQAnonymousClass(
        String2Id("Anonymous_$" +String Int2String(LocalId)),
        Class,
        TypedQual,
        Arg2,
        [ActualArgs],
        [AnonClassDecs],
        buildConstructorFormalParams([TypedQual,,ActualArgs], .Params, 0),
        buildConstructorFirstLineArgs([TypedQual,,ActualArgs], [.KList], 0)
      )
      ...
    </k>
    <nextLocalId> LocalId:Int => LocalId +Int 1 </nextLocalId>
    <classType> Class </classType>
    <classMetaType> classCMT </classMetaType>

//Qualified anonymous class
syntax KItem ::=  processQAnonymousClass (
                Id,        //Class name
                ClassType, //Base class
                K,         //TypedQual - qualifier
                K,         //'NewInstance Arg2
                KListWrap, //ActualArgs
                KListWrap, //Anonymous class block decs
                K,         //To be processed into formal params
                K          //To be processed into kr[constructor first line arguments]
              )
              [strict(8)]

rule [processQAnonymousClass]:
    processQAnonymousClass(
      Name:Id,
      BaseClass:ClassType,
      TypedQual:K,
      Arg2:K,
      [ActualArgs:KList],
      [AnonClassDecs:KList],
      ConstructorFormalParams:Params,
      kr[ConstrQual:K,, ConstructorFirstLineArgs:KList]
    )
    => elab(
      stmtAndExp(
        'ClassDecStm(
          'ClassDec(
            'ClassDecHead(
              [.KList],,
              Name,,
              'None(.KList),,
              'Some('SuperDec(BaseClass)),,
              'Some('ImplementsDec([.KList]))
            ),,
            'ClassBody([
              AnonClassDecs,,

              //Anonymous class constructor
              'ConstrDec(
                'ConstrDecHead(
                  ['Public(.KList)],,
                  'None(.KList),,
                  Name,,
                  ConstructorFormalParams,,
                  'None(.KList)
                ),,
                'ConstrBody(
                  'Some('QSuperConstrInv(ConstrQual,,'None(.KList),,[ConstructorFirstLineArgs])),,
                  [.KList]
                )
              )
            ])
          )
        ),
        'NewInstance(Arg2,, 'TypeName(Name),, elabRes([TypedQual,, ActualArgs]),, 'None(.KList))
      )
    )

endmodule
