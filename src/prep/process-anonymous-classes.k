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
          elabRes(ActualArgs:Exps),,
          'Some('ClassBody(AnonClassDecs:K))
      ))
      => processAnonymousClass(
        String2Id("Anonymous_$" +String Int2String(LocalId)),
        classObject,
        (Class, .HeatedInterfaceTypeList),
        Arg1,
        ActualArgs,
        AnonClassDecs,
        .Params,
        .Exps
      )
      ...
    </k>
    <nextLocalId> LocalId:Int => LocalId +Int 1 </nextLocalId>
    <classType> Class </classType>
    <classMetaType> interfaceCMT </classMetaType>

rule [elab-NewInstance-anonymous-extends-class]:
    <k>
      elab('NewInstance(Arg1:K,, Class:ClassType,,
          elabRes(ActualArgs:Exps),,
          'Some('ClassBody(AnonClassDecs:K))
      ))
      => processAnonymousClass(
        String2Id("Anonymous_$" +String Int2String(LocalId)),
        Class,
        .HeatedInterfaceTypeList,
        Arg1,
        ActualArgs,
        AnonClassDecs,
        buildConstructorFormalParams(ActualArgs, .Params, 0),
        buildConstructorFirstLineArgs(ActualArgs, .Exps, 0)
      )
      ...
    </k>
    <nextLocalId> LocalId:Int => LocalId +Int 1 </nextLocalId>
    <classType> Class </classType>
    <classMetaType> classCMT </classMetaType>

syntax KItem ::=  processAnonymousClass (
                Id,        //Class name
                ClassType, //Base class
                HeatedInterfaceTypeList, //Base interfaces, if any. In fact either zero or one interface is possible at this point.
                K,         //'NewInstance Arg1
                Exps,      //ActualArgs
                K,         //Anonymous class block decs
                K,         //To be processed into formal params
                K          //To be processed into kr[constructor first line arguments]
              )

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
      BaseInterfaces:HeatedInterfaceTypeList,
      Arg1:K,
      ActualArgs:Exps,
      AnonClassDecs:K,
      ConstructorFormalParams:Params,
      ConstructorFirstLineArgs:Exps
    )
    => elab(
      stmtAndExp(
        'ClassDecStm(
          'ClassDec(
            'ClassDecHead(
              .AnnoClassModList,,
              Name,,
              'None(.KList),,
              'Some('SuperDec(BaseClass)),,
              'Some('ImplementsDec(BaseInterfaces))
            ),,
            'ClassBody(addElementToClassBodyDecListEnd(
              AnonClassDecs,

              //Anonymous class constructor
              'ConstrDec(
                'ConstrDecHead(
                  'AnnoConstrModList('Public(.KList),, .AnnoConstrModList),,
                  'None(.KList),,
                  Name,,
                  ConstructorFormalParams,,
                  'None(.KList)
                ),,
                'ConstrBody(
                  'Some('SuperConstrInv('None(.KList),,ConstructorFirstLineArgs)),,
                  .BlockStmList
                )
              )
            ))
          )
        ),
        'NewInstance(Arg1,, 'TypeName(Name),, elabRes(ActualArgs),, 'None(.KList))
      )
    )

/*@ Build the part of the constructor of an anonymous class definition corresponding
to formal params, and arguments of the superclass constructor invocation, respectively
First KList - list of actual arguments
Second KList - the result
Third arg - a counter used to generate var names
*/
syntax KItem ::= buildConstructorFormalParams ( Exps, Params, Int )     [function]
               | buildConstructorFirstLineArgs ( Exps, Exps, Int )      [function]

rule buildConstructorFormalParams((Hd:Exp, Tl:Exps), P:Params, Num:Int) =>
     buildConstructorFormalParams(Tl, addElementToParamsEnd(P, .AnnoVarModList typeOf(Hd) String2Id("$" +String Int2String(Num))), Num +Int 1)

rule buildConstructorFormalParams(.Exps, P:Params, _) => P

rule buildConstructorFirstLineArgs((Hd:Exp, Tl:Exps), E:Exps, Num:Int) =>
     buildConstructorFirstLineArgs(Tl, addElementToExpsEnd(E, 'ExprName(String2Id("$" +String Int2String(Num)))), Num +Int 1)

rule buildConstructorFirstLineArgs(.Exps, E:Exps, _) => E

rule [elab-QNewInstance-anonymous-extends-class]:
    <k>
      elab('QNewInstance(elabRes(TypedQual:Exp),, elabRes(Arg2:K),, Class:ClassType,, elabRes(Arg4:K),,
          elabRes(ActualArgs:Exps),,
          'Some('ClassBody(AnonClassDecs:K))
      ))
      => processQAnonymousClass(
        String2Id("Anonymous_$" +String Int2String(LocalId)),
        Class,
        TypedQual,
        Arg2,
        ActualArgs,
        AnonClassDecs,
        buildConstructorFormalParams((TypedQual, ActualArgs), .Params, 0),
        buildConstructorFirstLineArgs((TypedQual, ActualArgs), .Exps, 0)
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
                Exps,      //ActualArgs
                K,         //Anonymous class block decs
                K,         //To be processed into formal params
                K          //To be processed into kr[constructor first line arguments]
              )

rule [processQAnonymousClass]:
    processQAnonymousClass(
      Name:Id,
      BaseClass:ClassType,
      TypedQual:K,
      Arg2:K,
      ActualArgs:Exps,
      AnonClassDecs:K,
      ConstructorFormalParams:Params,
      'ExprList(ConstrQual:Exp,, ConstructorFirstLineArgs:Exps)
    )
    => elab(
      stmtAndExp(
        'ClassDecStm(
          'ClassDec(
            'ClassDecHead(
              .AnnoClassModList,,
              Name,,
              'None(.KList),,
              'Some('SuperDec(BaseClass)),,
              'Some('ImplementsDec(.InterfaceTypeList))
            ),,
            'ClassBody(addElementToClassBodyDecListEnd(
              AnonClassDecs,

              //Anonymous class constructor
              'ConstrDec(
                'ConstrDecHead(
                  'AnnoConstrModList('Public(.KList),, .AnnoConstrModList),,
                  'None(.KList),,
                  Name,,
                  ConstructorFormalParams,,
                  'None(.KList)
                ),,
                'ConstrBody(
                  'Some('QSuperConstrInv(ConstrQual,,'None(.KList),, ConstructorFirstLineArgs)),,
                  .BlockStmList
                )
              )
            ))
          )
        ),
        'NewInstance(Arg2,, 'TypeName(Name),, elabRes('ExprList(TypedQual,, ActualArgs)),, 'None(.KList))
      )
    )

endmodule
