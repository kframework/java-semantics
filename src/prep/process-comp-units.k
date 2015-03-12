module PROCESS-COMP-UNITS
    imports CORE-SORTS
    imports CORE-CLASSES
    imports PROCESS-TYPE-NAMES
    imports PROCESS-IMPORTS     //for compUnitImportsStart()

/*@
\begin{markdown}
\paragraph{Module Overview} For each Compilation unit:

  - Process import declarations. Build \verb|<compUnitImports>|.

For each class C in CompUnit:

  - Add to \verb|<class>| containing C the cells mentioned in configuration doc.
  - Process inner classes of C.

\end{markdown}
*/

rule [ProcCompUnitsPhase-start]:
    <k> . => Program </k>
    (<program> Program:K </program> => .)
     <globalPhase> ProcTypeNamesPhase => ProcCompUnitsPhase  </globalPhase>

//@ Import declarations are processed in the module PROCESS-IMPORTS
rule [CompilationUnit]:
    <k>
      'CompilationUnit('Some('PackageDec(_:K,, Pack:PackageId)),,
          ImpDecs:K,, [Ks:KList]
      )
      => compUnitImportsStart(Pack) ~> ImpDecs ~> processTypeDecsInPCUPhase([Ks], Pack, noClass)
      ...
    </k>
    <globalPhase> ProcCompUnitsPhase  </globalPhase>

/*@ Wrapper over a list of type declarations and possible other terms, required to distinguish
this phase from other preprocessing phases
Type declarations are processed in this phase wrapped in a processTypeDecsInPCUPhase*/
syntax KItem ::=  processTypeDecsInPCUPhase  (
                KListWrap,  //The list of terms from which we will process just type declarations
                PackageId,  //The package of the processed types
                ClassType   //The outer class of this class, if any, or noClass if this is a top-level class
              )

rule [processTypeDecsInPCUPhase-Expand]:
    (. => processTypeDecsInPCUPhase([K1], Pack, OuterClass))
    ~> processTypeDecsInPCUPhase([(K1:K => .KList),, _:K,, _], Pack:PackageId, OuterClass:ClassType)

rule [processTypeDecsInPCUPhase-Discard]:
    processTypeDecsInPCUPhase([.KList], _,_) => .K

rule [processTypeDecsInPCUPhase-ElemDiscard]:
    processTypeDecsInPCUPhase([Label:KLabel(_)], _,_) => .
when notBool( Label ==KLabel 'ClassDec orBool Label ==KLabel 'InterfaceDec )

rule [processTypeDecsInPCUPhase-typeDec-ComputeFullName]:
    processTypeDecsInPCUPhase(
      [KL:KLabel(_:KLabel(_:K,, (SimpleClass:Id => getClassType(Pack,SimpleClass)),, _:KList),, _)],
      Pack:PackageId, _
    )                [structural]

/*@
Structure of 'ClassDec:

\begin{verbatim}
'ClassDec(
  'ClassDecHead(
    [Modifiers],,
    Class:ClassType,,
    'None(.KList),,
    'Some('SuperDec( BaseClassRaw - extends declaration )),,
    'Some('ImplementsDec([ ImplTypesRaw - implements declarations ]))
  ),,
  'ClassBody( [ Decls --- member declarations ] )
)
\end{verbatim}
*/

rule [ClassDec-NoExtendsDesugar]:
    processTypeDecsInPCUPhase(
      ['ClassDec('ClassDecHead(_:KListWrap,, Class:ClassType,, _:K,,
        ( 'None(_)
          => 'Some('SuperDec(
                #if (Class =/=K classObject)
                  #then 'ClassType(classObject,, 'None(.KList))
                  #else noClass
                #fi
              ))
        ),,
        _:K),, _:K
      )],
      Pack:PackageId, _
    )                [structural]

rule [ClassDec-NoImplementsDesugar]:
    processTypeDecsInPCUPhase(['ClassDec('ClassDecHead(_:KListWrap,, Class:ClassType,, _:K,, _:K,,
        ( 'None(.KList) => 'Some('ImplementsDec([.KList])) )
      ),, _:K
    )], _,_)                [structural]

rule [InterfaceDec-NoExtendsDesugar]:
    processTypeDecsInPCUPhase(['InterfaceDec('InterfaceDecHead(_:K,, Class:ClassType,, _:K,,
        ( 'None(.KList) => 'Some('ExtendsInterfaces([.KList])) )
      ),, _:K
    )], _,_)                [structural]

rule [processTypeDecsInPCUPhase-ClassDec]:
    <k>
      processTypeDecsInPCUPhase(
        ['ClassDec(
          'ClassDecHead( Modifiers:KListWrap,, Class:ClassType,, _:K,,
            'Some('SuperDec(BaseClassRaw:K)),,
            'Some('ImplementsDec(ImplTypesRaw:KListWrap))
          ),,
          'ClassBody( [Decls:KList] )
        )],
        Pack:PackageId, OuterClass:ClassType
      )
      => saveImportsInPCUPhase(Class)
      ~> processTypeDecsInPCUPhase([Decls], toPackage(Class), Class)
      ...
    </k>
    <classType> Class </classType>
    <classPhase> DiscoveredCPhase => StoredCPhase </classPhase>
    <enclosingClass> _ => OuterClass </enclosingClass>
    <rawExtends> _ => BaseClassRaw </rawExtends>
    <rawImplements> _ => ImplTypesRaw </rawImplements>
    <rawDeclarations>
      _ => [
                Decls,,

                //Default constructor.
                //If there is a no-arguments constructor in Decls, this one will be discarded
                'ConstrDec(
                  'ConstrDecHead(
                    ['Public(.KList)],,
                    'None(.KList),,
                    getSimpleName(Class),,
                    [.KList],,
                    'None(.KList)
                  ),,
                  'ConstrBody('None(.KList),, [.KList])
                )
            ]
    </rawDeclarations>
    <classContextType>
      _ =>  #if OuterClass ==K noClass
              #then staticCT
              #else getContextType(Modifiers)
            #fi
    </classContextType>

rule [processTypeDecsInPCUPhase-IInterfaceDec]:
    <k>
      processTypeDecsInPCUPhase(
        ['InterfaceDec(
          'InterfaceDecHead( _:K,, Class:ClassType,, _:K,,
            'Some('ExtendsInterfaces(ImplTypesRaw:K))
          ),,
          [Decls:KList]
        )],
        Pack:PackageId, OuterClass:ClassType
      )
      => saveImportsInPCUPhase(Class)
      ~> processTypeDecsInPCUPhase([Decls], toPackage(Class), Class)
      ...
    </k>
    <classType> Class </classType>
    <classPhase> DiscoveredCPhase => StoredCPhase </classPhase>
    <enclosingClass> _ => OuterClass </enclosingClass>
    <rawExtends> _ => noClass </rawExtends>
    <rawImplements> _ => ImplTypesRaw </rawImplements>
    <rawDeclarations> _ => [Decls] </rawDeclarations>
    <classContextType> _ => staticCT </classContextType>

/*@ If the given type is top-level, then save \verb|<imports>| from the \verb|<compUnitImports>| cell.
Otherwise do nothing.*/
syntax KItem ::=  saveImportsInPCUPhase (
                K //is processed into TypeName
              )

rule [saveImportsInPCUPhase]:
    <k> saveImportsInPCUPhase(Class:ClassType) => . ...</k>
    <compUnitImports> CUImports:Map </compUnitImports>
    <classType> Class </classType>
    <enclosingClass> noClass </enclosingClass>
    <cuImports> .Map => CUImports </cuImports>

rule [saveImportsInPCUPhase-Discard]:
    <k> saveImportsInPCUPhase(Class:ClassType) => . ...</k>
    <classType> Class </classType>
    <enclosingClass> class _ </enclosingClass>

endmodule
