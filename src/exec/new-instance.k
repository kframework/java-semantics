module NEW-INSTANCE
    imports CORE-SORTS
    imports CORE-FUNCTIONS
    imports CORE-EXEC   //for sl, restoreMethContext
    imports STATIC-INIT // for staticInit
    imports VAR-LOOKUP  //for typedLookup()

/*@
\section{Module NEW-INSTANCE}

\subsection{Background}

In this subsection we present the fragment of configuration used by runtime method
  invocation. The figure below contains the cells and their sorts.

\vspace{3ex}

$
\kall{T}{
\begin{array}{@{}c@{}}
\kall[GreenYellow]{threads}{
  \kall[GreenYellow]{thread*}{
  \begin{array}{@{}c@{}}
    \kall[Green]{k}{\variable[K]{K}{user}}
    \mathrel{}\\\mathrel{}
    \kall[Orange]{methodContext}{
      \kall[Crimson]{env}{ Map \left[Id \mapsto Int \right] }
      \mathrel{}\kall[DarkOrange]{crntClass}{ ClassType }
      \mathrel{}\kall[DarkOrange]{location}{ Int }
    }
  \end{array}
  }
}
\mathrel{}\\\mathrel{}\\\mathrel{}
\kall[Red]{classes}{
  \kall[Red]{class*}{
  \begin{array}{@{}c@{}}
    \kall[Red]{classType}{ ClassType } \mathrel{}
    \kall[DarkGoldenrod]{enclosingClass}{ ClassType } \mathrel{}\\\mathrel{}
    \kall[SpringGreen]{extends}{ ClassType } \mathrel{}
    \kall[Indigo]{instanceFields}{List[FieldDec]}
  \end{array}
  }
}
\mathrel{}\\\mathrel{}
\kall[DarkCyan]{store}{Map \left[Int \mapsto TypedVal \right]}
\mathrel{}\kall[DarkCyan]{nextLoc}{Int}
\mathrel{}\\\mathrel{}
\kall[Cyan]{objectStore}{
  \kall[Cyan]{object*}{
    \begin{array}{@{}c@{}}
      \kall[Cyan]{objectId}{Int}
      \mathrel{}\kall[Cyan]{objectType}{ClassType}
      \mathrel{}\\\mathrel{}
      \kall[Cyan]{layer*}{
        \begin{array}{@{}c@{}}
          \kall[Cyan]{layerClass}{ClassType}
          \mathrel{}\kall[Cyan]{layerEnv}{ Map \left[Id \mapsto Int \right] }
          \mathrel{}\\\mathrel{}\kall[Cyan]{layerEnclosingObject}{ K }
        \end{array}
      }
    \end{array}
  }
}
\end{array}
}
$

\vspace{3ex}

The cell $\kall{k}{}$ stores the current computation. Inside $\kall{env}{}$ we store the local environment -- a map
  from variable names to their locations in the store. The cell $\kall{methodContext}{}$ store information about the
  current object -- the one accessible through the keyword this. Both $\kall{env}{}$ and $\kall{methodContext}{}$ play
  a special role in object instantiation.

The cell $\kall{class}{}$ contains various sub-cells holding the content of that class. The
  first cell in $\kall{classType}{}$ of sort ClassType that holds the fully qualified class name.
  This cell is a unique identifier of a class, and is used as a key to access other cells inside a $\kall{class}{}$.
  Next relevant cells inside $\kall{class}{}$ are $\kall{enclosingClass}{}$ - the directly enclosing class in case
  this class is an inner class. The vase class is stored inside $\kall{extends}{}$ and the list of declarations of
  instance fields without identifiers is stored in $\kall{instanceFields}{}$.

The next two cells are related to the store. The cell $\kall{store}{}$ have a central role in the semantics -- it is
  the map from object locations (values in the cell $\kall{env}{}$) to their actual typed values.
  The cell $\kall{nextLoc}{}$ is the counter of store locations.

The remaining big group of cells -- $\kall{objectStore}{}$ contains the inner structure of objects.
  The $\kall{objectId}{}$ is an unique identifier of the object. Every reference to this object in the store is
  a reference to this id. Inside $\kall{objectType}{}$ is the actual runtime type of the object. Next we have a list
  of $\kall{layer}{}$ cells, each of them representing an inheritance layer of the object. starting from class
  Object and finishing twith the actual object type. Inside each layer $\kall{layerClass}{}$ stores its
  associated class, $\kall{layerEnv}{}$ -- the fields and $\kall{layerEnclosingObject}{}$ -- the enclosing object,
  in the case when $\kall{layerClass}{}$ is a non-static inner class. The complex rules for java inner classes
  allow each layer to have its distinctive enclosing object, and we have tests that specifically target this
  requirement.
*/

/*@ \subsection{New instance creation}*/

rule [QNewInstance-resolve-class]:
    Qual . new (Name:Id => getClassType(toPackage(typeOf(Qual)), Name)) (_)

/*@ Qualified new instance creation expression. Unqualified new expressions are rewritten into qualified ones by other
rules and also reach this point.*/
rule [qualified-new-instance]:
    <k>
      Qual:KResult . new Class:ClassType( Args:TypedVals )
      => staticInit(Class)
        ~> create(Class)
        ~> restoreMethContext(MethContext)
        ~> setEncloser(typedLookup(L), Class, Qual)
        ~> typedLookup(L) .getConsName(Class) (Args);
        ~> typedLookup(L)
      ...
    </k>
    <methodContext>
      MethContext
      =>  <env> .Map </env>
          <crntClass> .K </crntClass>
          <location> L </location>
    </methodContext>
    <store>... . => L |-> objectRef(L, Class) :: Class ...</store>
    <storeMetadata>... . => L |-> LocalLocMetadata ...</storeMetadata>
    (.Bag =>  <object>
                <objectId> L </objectId>
                <objectType> Class </objectType>
              </object>
    )
    <nextLoc> L:Int => L +Int 1 </nextLoc>

syntax K ::=  create ( ClassType )

rule [create]:
    <k>
      create(Class)
      => create(BaseClass) ~> setCrntClass(Class) ~> FieldDecs ~> addEnvLayer
      ...
    </k>
    <classType> Class </classType>
    <extends> BaseClass </extends>
    <instanceFields> FieldDecs </instanceFields>
        [structural]

rule [create-empty-discard]:
    create( noClass ) => .K
        [structural]

syntax K ::=  setCrntClass ( ClassType )

rule [setCrntClass]:
    <k> setCrntClass(Class) => . ...</k>
    <crntClass> _ => Class </crntClass>
        [structural]

syntax K ::=  "addEnvLayer"

rule [addEnvLayer]:
    <k> addEnvLayer => . ...</k>
    <env> Env => . </env>
    <crntClass> Class </crntClass>
    <location> OId </location>
    <object>
      <objectId> OId </objectId>
      (.Bag =>  <layer>
                  <layerClass> Class </layerClass>
                  <layerEnv> Env </layerEnv>
                  ...
                </layer>
      )
      ...
    </object>
        [structural]

/*@ Sets the enclosing object for a given object.
    Invoked by invokeConstr and QSuperConstrInv.
*/
syntax K ::=  setEncloser (
                K,          //Evaluates to source object
                ClassType,  //Class layer in the source object for which to set the enclosing object.
                K           //The enclosing object
              )
              [strict(1,3)]

rule [setEncloser-value]:
    <k>
      setEncloser(objectRef(OId, _)::_, Class, EncloserVal::_) => .
      ...
    </k>
    <objectId> OId </objectId>
    <layerClass> Class </layerClass>
    <layerEnclosingObject> _ => EncloserVal::EncloserClass </layerEnclosingObject>
    <classType> Class </classType>
    <enclosingClass> EncloserClass </enclosingClass>

rule [setEncloser-noValue]:
    setEncloser(_,_, noValue) => .

endmodule

module NEW-INSTANCE-REST
    imports CORE-SORTS
    imports CORE-FUNCTIONS
    imports CORE-EXEC   //for sl, restoreMethContext
    imports STATIC-INIT // for staticInit
    imports VAR-LOOKUP  //for typedLookup()
    imports NEW-INSTANCE

//@\subsection{Instance field declarations}

rule [FieldDec-instance]:
    <k> 'FieldDec([.KList],, T:Type,,['VarDec(X:Id)]) => . ...</k>
    <env> Env:Map => Env[L/X] </env>
    <store>... . => L |-> default(T) ...</store>
    <storeMetadata>... . => L |-> FieldLocMetadata ...</storeMetadata>
    <nextLoc> L:Int => L +Int 1 </nextLoc>

//@\subsection{Execution of QSuperConstrInv, AltConstrInv}

// 'QSuperConstrInv( Qual:K,, _:K,, [ Args:KList ] )
syntax KLabel ::=  "'QSuperConstrInv"

rule [QSuperConstrInv]:
    <k>
      'QSuperConstrInv(Qual:K,, _,, [ Args:KList ])
      => setEncloser('QThis(Class), BaseClass, Qual)
         ~> 'Invoke(
              'QSuperMethod(Class,, .K,, getConsName(BaseClass)),,
              [Args]
            );
      ...
    </k>
    <crntClass> Class:ClassType </crntClass>
    <classType> Class </classType>
    <extends> BaseClass:ClassType </extends>

// 'AltConstrInv( _:K,, [ Args:KList ] )
syntax KLabel ::= "'AltConstrInv"

rule [AltConstrInv]:
    <k>
      'AltConstrInv(_,, [ Args:KList ])
      => 'QThis(Class) .getConsName(Class) (toExps([Args]));
      ...
    </k>
    <crntClass> Class:ClassType </crntClass>

endmodule
