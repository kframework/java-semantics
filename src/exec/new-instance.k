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
  of $\kall{layer}{}$ cells, each of them representing an inheritance layer of the object. Starting from class
  Object and ending with the actual object type. Inside each layer $\kall{layerClass}{}$ stores its
  associated class, $\kall{layerEnv}{}$ -- the fields and $\kall{layerEnclosingObject}{}$ -- the enclosing object,
  in the case when $\kall{layerClass}{}$ is a non-static inner class. The complex rules for Java inner classes
  allow each layer to have its distinctive enclosing object, and we have tests that specifically target this
  requirement.
*/

/*@ \subsection{New instance creation}*/

/*@
When a new instance creation expression reaches the top of computation, first it is normalized to a standard form.
If it is an unqualified expression, an empty qualifier is added. Second, if the class to be instantiated is a simple
name, it have to be converted to a fully qualified class name. At this stage this could only happen for true inner
classes, and the fully qualified name is computed by concatenating the type of the qualifier and the class simple name,
by the rule below.
*/
rule [qualified-new-instance-resolve-class]:
    Qual . new (Name:Id => getClassType(toPackage(typeOf(Qual)), Name)) (_)

/*@
After the new instance expression have been normalized, the qualifier and the arguments are brought to the top of
  computation by the strictness rules and evaluated. Qualifier is evaluated first, and arguments are evaluated
  left-to-right according to JLS.

When all the subexpressions of new have been evaluated, the main rule for new could apply. This rule touches a large
  number of cells, that will be explained next.
  First the current value of the counter inside $\kall{nextLoc}{}$ is used as the location of the newly created object.
  The counter is incremented for the next use.
  Inside $\kall{objectStore}{}$ a new cell $\kall{object}{}$ is created for the new object. For now it have just two
  sub-cells specified -- $\kall{objectId}{}$ and $\kall{objectType}{}$, and no layers. Curiously we don't have
  to specify neither $\kall{object}{}$ nor $\kall{objectStore}{}$ cells explicitly here, we have to specify just
  the cells inside them that are modified. The capability to ignore surrounding cells when they can be automatically
  inferred is called configuration abstraction, another K feature\cite{k-jlap}. In the cell $\kall{store}{}$
  a new entry is created with key being L and value - a reference to the newly created object in $\kall{object}{}$.
  The content of $\kall{methodContext}{}$ is reset to a default state. This default state is required
  by rules that are applied next.

Inside $\kall{k}{}$ the new instance expression is rewritten into a sequence of computations that will be executed
  by the following rules. The auxiliary function staticInit() triggers static initialization of the instantiated class,
  in case it was not triggered earlier. Next, the function create() populates the layers of the object inside
  $\kall{object}{}$ This also includes allocation of all instance fields, and their initialization to the default value.
  Field initializers are not executed yet. The function setEncloser() sets the enclosing object for the current class,
  if the current class is an inner class. If some of the base classes are also inner classes, the encloser for their
  respective $\kall{layer}{}$ will be set as part of constructor invocation.

The next term in the computation (the one starting with typedLookup(L)) might look a bit weird, but it is in fact
  the invocation of the constructor. This term represents a mix of Java syntax for method invocation and auxiliary
  functions defined inside K-Java. It illustrates, among others, the power of K parser. Now, after all memory
  allocation procedures have been completed, it is the right time for it to be invoked. Preprocessing semantics
  transforms all constructors into plain methods. The function typedLookup(L) is evaluated into the object stored
  at the location L, that will serve as a qualifier for constructor invocation. The function getConsName() converts
  the class name into the name of the constructor method. What remains is plain Java syntax for method invocation.

The last two terms bring computation to the state required to continue execution. Function restoreMethoContext()
  restores $\kall{methodContext}{}$ to the the state before object creation. The last term is the result value of
  the object instantiation expression.
*/
rule [qualified-new-instance]:
    <k>
      Qual:KResult . new Class:ClassType( Args:TypedVals )
      => staticInit(Class)
        ~> create(Class)
        ~> setEncloser(typedLookup(L), Class, Qual)
        ~> typedLookup(L) .getConsName(Class) (Args);
        ~> restoreMethContext(MethContext)
        ~> typedLookup(L)
      ...
    </k>
    <store>... . => L |-> objectRef(L, Class) :: Class ...</store>
    <nextLoc> L:Int => L +Int 1 </nextLoc>
    (.Bag =>  <object>
                <objectId> L </objectId>
                <objectType> Class </objectType>
              </object>
    )
    <methodContext>
      MethContext
      =>  <env> .Map </env>
          <crntClass> .K </crntClass>
          <location> L </location>
    </methodContext>
    <storeMetadata>... . => L |-> LocalLocMetadata ...</storeMetadata>

syntax KItem ::=  create ( ClassType )

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

syntax KItem ::=  setCrntClass ( ClassType )

rule [setCrntClass]:
    <k> setCrntClass(Class) => . ...</k>
    <crntClass> _ => Class </crntClass>
        [structural]

syntax KItem ::=  "addEnvLayer"

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

/*@
Sets the enclosing object for a given object.
*/
syntax KItem ::=  setEncloser (
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
         ~> ('Invoke(
              'QSuperMethod(Class,, .K,, getConsName(BaseClass)),,
              [Args]
            );)<:ExprStmt
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
