module CONFIGURATION-EXEC
    imports CORE-SORTS
    imports CORE-FUNCTIONS

/*@
The execution configuration consists from the top-level cell \cellref{T}, whose content is divided into three large cell groups. The group \cellref[]{threads} contains one or multiple cells \cellref[]{thread}. Here is included the data related to the execution of a thread, such as the computation, stack, local environment. The second group is contained inside \cellref[]{classes} that have multiple \cellref[]{class} cells -- all the content related to particular classes. The third group consists of the remaining top-level cells.

\paragraph{Threads} Each execution thread has a corresponding \cellref{thread}. Inside a thread, \cellref[K]{k} is represents the actual computation - the sequence of tasks to be executed. Next cells are \cellref[List]{stack} -- the method call stack, and \cellref{methodContext}. The \cellref{methodContext} holds the local context of the executed method:
\begin{itemize}
  \item \cellref[Map{{[}}Id\mapsto{}Int{{]}}]{env} -- the map from local variable names to their location inside \cellref[]{store}.
  \item \cellref[ClassType]{crntClass} -- the current class, the type of \verb|this|
  \item \cellref[Int]{location} -- The location in memory store of the current object.
\end{itemize}

On the next line there are 3 cells related to multithreading:
\begin{itemize}
  \item \cellref{tid} -- the thread identified, generated when the thread is created.
  \item \cellref[Map{{[}}Int\mapsto{}Int{{]}}]{holds} -- a map from Object locations to integer numbers. Map keys are monitor objects on which the current thread has the locks. Map values hold the number of times the lock was acquired.
  \item \cellref[Bool]{interrupted} -- boolean value signaling whether the current thread was interrupted.
\end{itemize}

\paragraph{Classes} The cell \cellref{classes} contains one \cellref{class} for each class in the program, both for supported JDK classes and for user-defined classes. Cell \cellref{class} has the following content:

\begin{itemize}
  \item \cellref[ClassType]{classType} --- the fully qualified class name. This cell serves as identifier for the whole \cellref{class}, thus \cellref{classes} may be seen as a map from class name to \cellref{class} content.
  \item \cellref[ClassMetaType]{classMetaType} --- Whether this type is class or interface. Both are referred hereafter as "classes", making the distinctions only when necessary.
  \item \cellref[ClassPhase]{classPhase} --- Used during unfolding global phase (see below).
  \item \cellref[ClassType]{enclosingClass} --- For inner classes, the direct lexically enclosing class of this class. For top-level classes --- no value.
  \item \cellref[ClassType]{extends} --- The base class.
  \item \cellref[Set {[} ClassType {]} ]{implTrans} --- the transitive closure of implemented interfaces.
  \item \cellref[ Map {[} Signature \mapsto ClassType {]} ]{methods} --- The map of accessible methods. Keys are method signatures, values are classes where methods are defined. Includes both methods declared within this class as well as methods inherited from base classes/ base interfaces.
  \item \cellref[Bag]{methodDecs} --- the collection of method declarations (\cellref{methodDec} cells)in the current class. This cell contains only a subset of methods from \cellref{methods}, as the set of accessible methods from \cellref{methods} also includes methods inherited from base classes/interfaces. Hence the need of two separate collections. Each \cellref[Bag]{methodDec} contains the following data:
  \begin{itemize}
    \item \cellref[Signature]{methodSignature} --- The method signature, acting as identifier of the \cellref{methodDec}
    \item \cellref[ List{[} Param {]} ]{methodParams} --- method parameters
    \item \cellref[K]{methodBody} --- method body
    \item \cellref[AccessMode]{methodAccessMode} --- method access mode
    \item \cellref[ContextType]{methodContextType} --- either static or instance
  \end{itemize}
  \item \cellref[K]{instanceFields} --- The list of instance field declarations, stored as a list of local variable declaration statements, without initializers. Used during object instantiation.
  \item \cellref[K]{staticFields} --- The list of static field declarations, in a similar format as \cellref{instanceFields}
   \item \cellref[K]{staticInit} --- The list of static initializers and static field initializers concatenated into one block. The content of \cellref{staticFields} and \cellref{staticInit} is executed during class static initialization.
   \item \cellref[K]{folded} --- the initial representation of the class in AST format, during unfolding phase (see below).
   \item \cellref[StaticInitStatus]{staticInitStatus} --- the static initialization status of the class. May be either uninitialized, initializing or initialized. The content of this class is used to trigger static initialization of the class on first use.
   \item \cellref[ Map{[} Id \mapsto Location {]} ]{staticEnv} --- The map from static fields declared in this class to their locations in the store. Populated during static initialization. This cell along with \cellref{staticInitStatus} are the only two cells of \cellref{class} altered during program execution, during static initialization. The rest of the cells are populated before the execution.
\end{itemize}

\paragraph{The remaining cells}
The first three cells after \cellref{classes} are important at the beginning of computation:
\begin{itemize}
  \item \cellref[K]{program} --- The initial AST representation of the program, containing both core classes from JDK and user-defined classes.
  \item \cellref[K]{mainClass} --- The class containing the method \verb|main()| --- the starting point of execution. Loaded froma command line argument.
  \item \cellref[K]{globalPhase} --- Computation in the execution semantics may be in one of two global phases: Unfolding and Execution. The role of hte unfolding phase is to convert the AST representation of the program stored in \cellref{program} into the collection of cells \cellref{classes}. When this operation is complete, execution phase follows.
\end{itemize}

The next 4 cells represent the memory model of K-Java:
\begin{itemize}
  \item \cellref[Map{[}Location:Int \mapsto Value:TypedVal{]}]{store} --- the program memory. Map from memory locations to actual values. For reference types only the reference is stored in this cell.
  \item \cellref[ Map{[} Location:Int \mapsto LocMetadata {]} ]{storeMetadata} --- For each location in \cellref{store}, information whether that location is a local variable or field. Used for performance optimization of multi-threaded model-checking.
  \item \cellref[Int]{nextLoc} --- the next available memory location. Incremmented after each allocation.
  \item \cellref[ Map{[} Type \mapsto TypedVal {]} ]{classLiteralsMap} --- A map from types T to objects that represent the value of the expression \verb|T.class| .
  \item \cellref[Bag]{objectStore} --- Represents runtime state of all the instantiated objects. Multiple references to the same object are modeled through multiple entries in \cellref{store} pointing to the same entry in \cellref{objectStore}. The cell contains multiple \cellref{object} cells, each with the following content:
  \begin{itemize}
    \item \cellref[Int]{objectId} --- A unique object identifier, pointed by each reference in \cellref{store}
    \item \cellref[ClassType]{objectType} --- The runtime type of the object.
    \item \cellref[Bag]{layer} --- There could be multiple layer cells inside an \cellref{object}. Each layer represents a concrete class in the inheritance hierarchy, starting from \verb|java.lang.Object| and finishing with \cellref{objectType}. An object layer stores the follosing information:
    \begin{itemize}
      \item \cellref[ClassType]{layerClass} --- The class represented by this layer.
      \item \cellref[Map{[}Id \mapsto Int{]}]{layerEnv} --- A map from instante fields to their loations in the store.
      \item \cellref[TypedVal]{layerEnclosingObject} --- A reference to the directly enclosing object if this object represents an instance inner class, or empty for other types of objects (top-level and static inner).
    \end{itemize}
  \end{itemize}
\end{itemize}

The following cells represent program I/O:
\begin{itemize}
  \item \cellref[List]{in} --- the standard input, represented as pre-parsed list of elements of type Int or String.
  \item \cellref[List]{out} --- the standard output.
\end{itemize}

The next row contains global cells related to multithreading:
\begin{itemize}
  \item \cellref[ Set{[} ObjLocation:Int {]} ]{busy} --- the set of busy objects. E.g. monitor objects for which there is a thread holding the monitor.
  \item \cellref[ Map{[} ThreadId:Int \mapsto OL:Int {]} ]{waitingThreads} --- The map from threads to monitor objects on which respective threads are blocked in a call to \verb|wait()|. Used by the methods \verb|Object.wait()|, \verb|Object.notify()|, \verb|Object.notifyAll()|.
  \item \cellref[Set{[}ThreadId:Int{]}]{terminated} -- the set of identifiers of terminated threads.
\end{itemize}

The rest of the global cells are used for debugging purposes.
*/

configuration
    <T>
      //Configuration part 1: threads
      <threads color="GreenYellow">
        <thread multiplicity="*" color="GreenYellow">
          <k color="Green"> .K </k>

          <stack color="Green"> .List </stack>

          /*The execution context of the current method - local names environment, return type,
            context type and current object.*/
          <methodContext color="Orange">

            //The map from local vars to their location in the store. Also includes outer local vars, for local classes.
            <env color="Crimson"> .Map </env>

            //current class during all phases, including early preprocessing
            <crntClass color="DarkOrange"> noClass </crntClass>

            // OL - location of "this" in store, or noValue in static context
            <location color="DarkOrange"> .K </location>
          </methodContext>

          <br/>
          //Multithreading-related cells

          //Thread Id
          <tid color="BlueViolet"> 0 </tid>

          //Map[OL |-> Count] - the amount of times this thread holds the monitor objects referred bu the keys
          <holds color="BlueViolet"> .Map </holds>

          //Whether this thread was interrupted by another thread by a call to Thread.interrupt()
          <interrupted color="BlueViolet"> false </interrupted>
        </thread>
      </threads>

      <br/>
      <br/>
      //Configuration part 2: classes

      <classes color="Red">
        <class multiplicity="*" color="Red">

          //Class Phase Discovered

          //sort ClassType. Contains the fully qualified class name.
          <classType color="Red"> .K </classType>

          //Either classMetaT or interfaceMetaT. Used in many semantics phases, including execution.
          <classMetaType color="Maroon"> .K </classMetaType>

          //The major phase of <class> lifecycle. See ClassPhase definition.
          <classPhase color="Maroon"> .K </classPhase>

          <br/>
          //Class Phase Created

          //Used by object instantiation
          //noClass if this is a top-level class,
          //ClassType of the enclosing class otherwise
          <enclosingClass color="DarkGoldenrod"> noClass </enclosingClass>

          //Class Phase Decs

          //The base class, or noClass for interfaces and Object.
          <extends color="SpringGreen"> .K </extends>

          //Class Phase Members

          //Transitively implemented interfaces. Used by subtyping rules.
          <implTrans color="DeepPink"> .Set </implTrans>

          /*Signatures of methods accessible to this class (both declared and inherited)
            Map[Sig -> Class]
            Used in elaboration of method calls.*/
          <methods color="Blue"> .Map </methods>

          <br/>
          <br/>

          /*All methods declared in this class.
            Used in elaboration of method calls.*/
          <methodDecs color="Blue">

            <methodDec multiplicity="*" color="Blue">

              //Method signature, of type Signature
              <methodSignature color="Blue"> .K </methodSignature>

              //Method params
              <methodParams color="Blue"> .Params </methodParams>

              //Method body
              <methodBody color="Blue"> .K </methodBody>

              <methodAccessMode color="Blue"> .K </methodAccessMode>

              //Either staticCT or instanceCT
              <methodContextType color="Blue"> .K </methodContextType>

            </methodDec>
          </methodDecs>

          <br/>
          <br/>

          //[...,, 'LocalVarDec(_),, ...] - Instance field declarations. Used during object instantiation.
          <instanceFields color="Indigo"> [.KList] </instanceFields>

          //[...,, 'FieldDec('Static(_),,T,,_),, ...] - Static field declarations. Used during class instantiation.
          <staticFields color="DarkSlateGray"> [.KList] </staticFields>

          //The sequence of static initializers (that also includes field initializers)
          //see static-init.k for more details.
          <staticInit color="DarkSlateGray"> [.KList] </staticInit>

          <br/>
          <br/>
          //Class Phase Folding

          //The whole class folded back into a 'ClassDec(...) node
          <folded color="Teal"> .K </folded>

          <br/>
          <br/>
          //Class Phase Execution - cells only used during execution

          //Initialization status of this class. See static-init.k for more details.
          //Only used during execution phase.
          <staticInitStatus color="Teal"> StaticUninitialized </staticInitStatus>

          /*The map of static fields declared in this class only, and NOT in superclasses or superinterfaces.
            Map[Id -> Location] Used during static variable lookup.*/
          <staticEnv color="DarkSlateGray"> .Map </staticEnv>

        </class>
      </classes>

      <br/>
      <br/>

      //Initial cells, loaded by krun and initial configuration.

      //The initial program loaded by krun. For full mode and preprocessing this is
      //the initial java program, for execution mode it is the folded java program.
      <program color="LightSteelBlue"> $PGM:K </program>

      //Main class, passed as krun argument. We need it from the outside, just like JDK Java.
      <mainClass color="LightSteelBlue"> $MainClass:List </mainClass>

      <globalPhase color="YellowGreen"> UnfoldingPhase </globalPhase>

      <br/>
      <br/>
      //Global Phase Execution

      //Execution memory. Map[Location:Int->Value:TypedVal]. Both local vars and heap vars are stored here.
      <store color="DarkCyan"> .Map </store>

      //The type of each location - whether it is LocalAttr or FieldAttr. Relevant only for multi-threading
      //model checking
      //Map[Location:Int -> LocMetadata].
      <storeMetadata color="DarkCyan"> .Map </storeMetadata>

      //Counter for next location to be used in the cell <store>.
      <nextLoc color="DarkCyan"> 0 </nextLoc>

      //A map from types to objectRef() terms that represent their T.class value
      //Created an used in execution phase, by expressions of the form X.class
      //Type: Map[Type->TypedVal]. Type may be any reference type.
      <classLiteralsMap color="LightPink"> .Map </classLiteralsMap>

      <br/>
      <br/>

      //Represents the storage of objects. Since objects have a complex inner structure,
      //we need to hold them separately if we want to represent that structure as a cell tree.
      <objectStore color="Cyan">
        <object color="Cyan" multiplicity="*">

          //The id of this object. Same as store location for the newly created object reference.
          <objectId color="Cyan"> .K </objectId>

          //The actual object class
          <objectType color="Cyan"> .K </objectType>

          //One layer for each class in the inheritance chain of this object
          <layer color="Cyan" multiplicity="*">

            //The class corresponding to the given chain
            <layerClass color="Cyan"> .K </layerClass>

            //Map[Id |-> Loc] -> fields defined in this layer
            <layerEnv color="Cyan"> .Map </layerEnv>

            //objectRef() ::_ - a reference to the directly enclosing object, or noValue if none.
            <layerEnclosingObject color="Cyan"> noValue </layerEnclosingObject>
          </layer>
        </object>
      </objectStore>

      <br/>
      <br/>

      //Standard input. Each token is a ListItem.
      <in color="LightPink" stream="stdin"> .List </in>

      //Standard output. Each token is a ListItem.
      <out color="LightPink" stream="stdout"> .List </out>

      <br/>
      <br/>
      //Multithreading-related global cells

      //Set[OL:Int] - the set of locations of used monitor objects
      <busy color="LightGreen"> .Set </busy>

      //Map[ThreadId:Int |-> OL:Int] - map from threads to objects they are waiting on
      //waiting on those objects used by methods Object.wait(), Object.notify(), Object.notifyAll().
      <waitingThreads color="LightGreen"> .Map </waitingThreads>

      //Set[ThreadId:Int] The set of terminated threads.
      <terminated color="LightGreen"> .Set </terminated>

      <br/>
      <br/>
      //Cells used for debugging. Not related to the semantics.

      <groupDebug color="Yellow">

        <dissolveEmptyK> false </dissolveEmptyK>

        //When computation finishes, dissolve all cells except <out>,
        //in order to avoid duplicate solutions during model checking.
        <dissolveAllExceptOut> $DissolveAllExceptOut:Bool </dissolveAllExceptOut>

        <debug> .List </debug>

      </groupDebug>
    </T>

endmodule
