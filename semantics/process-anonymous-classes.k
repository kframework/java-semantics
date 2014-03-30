require "core-sorts.k"
require "core-classes.k"

//@ \section{Module PROCESS-ANONYMOUS-CLASSES}

module PROCESS-ANONYMOUS-CLASSES
    imports CORE-SORTS
    imports CORE-CLASSES

/*Case one - anonymous class implementing an interface. The class body have nothing else
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
        objectClass,
        Class,
        Arg1,
        ActualArgs,
        AnonClassDecs,
        resultListWrap(.KList),
        resultListWrap(.KList)
      )
      ...
    </k>
    <nextLocalId> LocalId:Int => LocalId +Int 1 </nextLocalId>
    <classType> Class </classType>
    <metaType> interfaceMetaT </metaType>

rule [elab-NewInstance-anonymous-extends-class]:
    <k>
      elab('NewInstance(Arg1:K,, Class:ClassType,,
          elabRes([ActualArgs:KList]),,
          'Some('ClassBody([AnonClassDecs:KList]))
      ))
      => processAnonymousClass(
        String2Id("Anonymous_$" +String Int2String(LocalId)),
        Class,
        .KList,
        Arg1,
        ActualArgs,
        AnonClassDecs,
        buildConstructorFormalParams(ActualArgs, .KList, 0),
        buildConstructorFirstLineArgs(ActualArgs, .KList, 0)
      )
      ...
    </k>
    <nextLocalId> LocalId:Int => LocalId +Int 1 </nextLocalId>
    <classType> Class </classType>
    <metaType> classMetaT </metaType>

syntax K ::=  processAnonymousClass (
                Id,        //Class name
                ClassType, //Base class
                KList,     //Base interfaces, if any
                K,         //'NewInstance Arg1
                KList,     //ActualArgs
                KList,     //Anonymous class block decs
                K,         //To be processed into resultListWrap(constructor formal params)
                K          //To be processed into resultListWrap(constructor first line arguments)
              )

//heat constructor formal params and first line arguments
context processAnonymousClass(_,_,_,_,_,_,HOLE,_)
context processAnonymousClass(_,_,_,_,_,_,_,HOLE)

rule [processAnonymousClass]:
    processAnonymousClass(
      Name:Id,
      BaseClass:ClassType,
      BaseInterfaces:KList,
      Arg1:K,
      ActualArgs:KList,
      AnonClassDecs:KList,
      resultListWrap(ConstructorFormalParams:KList),
      resultListWrap(ConstructorFirstLineArgs:KList)
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
                  [ConstructorFormalParams],,
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
syntax K ::= buildConstructorFormalParams ( KList, KList, Int )
           | buildConstructorFirstLineArgs ( KList, KList, Int )

rule buildConstructorFormalParams(
      (ActualParam:K => .KList),, _,
      _,, (.KList => 'Param([.KList],, typeOf(ActualParam),, String2Id("$" +String Int2String(Num) ))),
      Num:Int => Num +Int 1
    )

rule buildConstructorFormalParams(.KList, Ks:KList, _) => resultListWrap(Ks)

rule buildConstructorFirstLineArgs(
      (_:K => .KList),, _,
      _,, (.KList => 'ExprName(String2Id("$" +String Int2String(Num) ))),
      Num:Int => Num +Int 1
    )

rule buildConstructorFirstLineArgs(.KList, Ks:KList, _) => resultListWrap(Ks)

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
        ActualArgs,
        AnonClassDecs,
        buildConstructorFormalParams(TypedQual,,ActualArgs, .KList, 0),
        buildConstructorFirstLineArgs(TypedQual,,ActualArgs, .KList, 0)
      )
      ...
    </k>
    <nextLocalId> LocalId:Int => LocalId +Int 1 </nextLocalId>
    <classType> Class </classType>
    <metaType> classMetaT </metaType>

//Qualified anonymous class
syntax K ::=  processQAnonymousClass (
                Id,        //Class name
                ClassType, //Base class
                K,         //TypedQual - qualifier
                K,         //'NewInstance Arg2
                KList,     //ActualArgs
                KList,     //Anonymous class block decs
                K,         //To be processed into resultListWrap(constructor formal params)
                K          //To be processed into resultListWrap(constructor first line arguments)
              )

//heat constructor formal params and first line arguments
context processQAnonymousClass(_,_,_,_,_,_,HOLE,_)
context processQAnonymousClass(_,_,_,_,_,_,_,HOLE)

rule [processQAnonymousClass]:
    processQAnonymousClass(
      Name:Id,
      BaseClass:ClassType,
      TypedQual:K,
      Arg2:K,
      ActualArgs:KList,
      AnonClassDecs:KList,
      resultListWrap(ConstructorFormalParams:KList),
      resultListWrap(ConstrQual:K,, ConstructorFirstLineArgs:KList)
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
                  [ConstructorFormalParams],,
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
