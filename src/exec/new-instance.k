module NEW-INSTANCE
    imports CORE-SORTS
    imports CORE-FUNCTIONS
    imports CORE-EXEC   //for sl, restoreMethContext
    imports STATIC-INIT // for staticInit
    imports VAR-LOOKUP  //for typedLookup()
    imports SYNTAX-CONVERSIONS  //for toExps()

/*@
\subsection{Background}

In this subsection we present the fragment of configuration used by runtime method
  invocation. The figure below contains the cells and their sorts.

\vspace{3ex}

\kwrap{
\kall{T}{\manualBRBlock{
  \kall[GreenYellow]{threads}{
    \kall[GreenYellow]{thread*}{
      \kall[Green]{k}{\variable[K]{K}{user}}
      \cellSep
      \kall[Orange]{methodContext}{
        \kall[Crimson]{env}{ Map \left[Id \mapsto Int \right] }
        \cellSep
        \kall[DarkOrange]{crntClass}{ ClassType }
        \cellSep
        \kall[DarkOrange]{location}{ Int }
      }
    }
  }
  \cellBR
  \cellBR
  \kall[Red]{classes}{
    \kall[Red]{class*}{
      \kall[Red]{classType}{ ClassType }
      \cellSep
      \kall[DarkGoldenrod]{enclosingClass}{ ClassType }
      \cellSep
      \kall[SpringGreen]{extends}{ ClassType }
      \cellSep
      \kall[Indigo]{instanceFields}{List[FieldDec]}
    }
  }
  \cellBR
  \cellBR
  \kall[DarkCyan]{store}{Map \left[Int \mapsto TypedVal \right]}
  \cellSep
  \kall[DarkCyan]{nextLoc}{Int}
  \cellBR
  \cellBR
  \kall[Cyan]{objectStore}{
    \kall[Cyan]{object*}{
      \kall[Cyan]{objectId}{Int}
      \cellSep
      \kall[Cyan]{objectType}{ClassType}
      \cellSep
      \kall[Cyan]{layer*}{
        \kall[Cyan]{layerClass}{ClassType}
        \cellSep
        \kall[Cyan]{layerEnv}{ Map \left[Id \mapsto Int \right] }
        \cellSep
        \kall[Cyan]{layerEnclosingObject}{ K }
      }
    }
  }
}}
}

\vspace{3ex}

The cell \cellref[]{k} stores the current computation. Inside \cellref[]{env} we store the local environment -- a map
  from variable names to their locations in the store. The cell \cellref[]{methodContext} store information about the
  current object -- the one accessible through the keyword this. Both \cellref[]{env} and \cellref[]{methodContext} play
  a special role in object instantiation.

The cell \cellref[]{class} contains various sub-cells holding the content of that class. The
  first cell in \cellref[]{classType} of sort ClassType that holds the fully qualified class name.
  This cell is a unique identifier of a class, and is used as a key to access other cells inside a \cellref[]{class}.
  Next relevant cells inside \cellref[]{class} are \cellref[]{enclosingClass} - the directly enclosing class in case
  this class is an inner class. The vase class is stored inside \cellref[]{extends} and the list of declarations of
  instance fields without identifiers is stored in \cellref[]{instanceFields}.

The next two cells are related to the store. The cell \cellref[]{store} has a central role in the semantics -- it is
  the map from object locations (values in the cell \cellref[]{env}) to their actual typed values.
  The cell \cellref[]{nextLoc} is the counter of store locations.

The remaining big group of cells -- \cellref[]{objectStore} contains the inner structure of objects.
  The \cellref[]{objectId} is an unique identifier of the object. Every reference to this object in the store is
  a reference to this id. Inside \cellref[]{objectType} is the actual runtime type of the object. Next we have a list
  of \cellref[]{layer} cells, each of them representing an inheritance layer of the object. Starting from class
  Object and ending with the actual object type. Inside each layer \cellref[]{layerClass} stores its
  associated class, \cellref[]{layerEnv} -- the fields and \cellref[]{layerEnclosingObject} -- the enclosing object,
  in the case when \cellref[]{layerClass} is a non-static inner class. The complex rules for Java inner classes
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
After the new instance expression has been normalized, the qualifier and the arguments are brought to the top of
  computation by the strictness rules and evaluated. Qualifier is evaluated first, and arguments are evaluated
  left-to-right according to JLS.

When all the subexpressions of new have been evaluated, the main rule for new could apply. This rule touches a large
  number of cells, that will be explained next.
  First the current value of the counter inside \cellref[]{nextLoc} is used as the location of the newly created object.
  The counter is incremented for the next use.
  Inside \cellref[]{objectStore} a new cell \cellref[]{object} is created for the new object. For now it has just two
  sub-cells specified -- \cellref[]{objectId} and \cellref[]{objectType}, and no layers. Curiously we don't have
  to specify neither \cellref[]{object} nor \cellref[]{objectStore} cells explicitly here, we have to specify just
  the cells inside them that are modified. The capability to ignore surrounding cells when they can be automatically
  inferred is called configuration abstraction, another K feature\cite{k-jlap}. In the cell \cellref[]{store}
  a new entry is created with key being L and value - a reference to the newly created object in \cellref[]{object}.
  The content of \cellref[]{methodContext} is reset to a default state. This default state is required
  by rules that are applied next.

Inside \cellref[]{k} the new instance expression is rewritten into a sequence of computations that will be executed
  by the following rules. The auxiliary function staticInit() triggers static initialization of the instantiated class,
  in case it was not triggered earlier. Next, the function create() populates the layers of the object inside
  \cellref[]{object} This also includes allocation of all instance fields, and their initialization to the default value.
  Field initializers are not executed yet. The function setEncloser() sets the enclosing object for the current class,
  if the current class is an inner class. If some of the base classes are also inner classes, the encloser for their
  respective \cellref[]{layer} will be set as part of constructor invocation.

The next term in the computation (the one starting with typedLookup(L)) might look a bit weird, but it is in fact
  the invocation of the constructor. This term represents a mix of Java syntax for method invocation and auxiliary
  functions defined inside K-Java. It illustrates, among others, the power of K parser. Now, after all memory
  allocation procedures have been completed, it is the right time for it to be invoked. Preprocessing semantics
  transforms all constructors into plain methods. The function typedLookup(L) is evaluated into the object stored
  at the location L, that will serve as a qualifier for constructor invocation. The function getConsName() converts
  the class name into the name of the constructor method. What remains is plain Java syntax for method invocation.

The last two terms bring computation to the state required to continue execution. Function restoreMethoContext()
  restores \cellref[]{methodContext} to the the state before object creation. The last term is the result value of
  the object instantiation expression.
*/
rule [qualified-new-instance]:
    <k>
      (Qual:KResult . new Class:ClassType( Args:TypedVals ))
      => staticInit(Class)
        ~> create(Class)
        ~> setEncloser(typedLookup(L), Class, Qual)
        ~> (typedLookup(L) .getConsName(Class) (Args);)
        ~> restoreMethContext(MethContext)
        ~> typedLookup(L)
      ...
    </k>
    <store>... .Map => L |-> objectRef(L, Class) :: Class ...</store>
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
    <storeMetadata>... .Map => L |-> LocalLocMetadata ...</storeMetadata>

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
    <env> Env:Map => Env[X <- L] </env>
    <store>... .Map => L |-> default(T) ...</store>
    <storeMetadata>... .Map => L |-> FieldLocMetadata ...</storeMetadata>
    <nextLoc> L:Int => L +Int 1 </nextLoc>

//@\subsection{Execution of QSuperConstrInv, AltConstrInv}

// 'QSuperConstrInv( Qual:K,, _:K,, [ Args:KList ] )
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
rule [AltConstrInv]:
    <k>
      'AltConstrInv(_,, [ Args:KList ])
      => 'QThis(Class) .getConsName(Class) (toExps([Args]));
      ...
    </k>
    <crntClass> Class:ClassType </crntClass>

endmodule
