module CONFIGURATION-EXEC
    imports CORE-SORTS
    imports CORE-FUNCTIONS

/*@
The configuration is divided into three large cell groups. The group \cellref[]{threads} contains one or multiple cells \cellref[]{thread}. Here is the data related to the execution of a thread, such as the computation, stack, local environment. The second group is contained inside \cellref[]{classes} that have multiple \cellref[]{class} cells -- anything class-related. What remains are the top-level cells -- the third group. Top-level cells are related to memory store, global thread-synchronization data and auxiliary cells for debugging.

Some cells in this configuration are not used within the rules. They serve only for grouping other cells by context. Grouping cells are colored yellow, whereas actual semantics cells have other colors.

While describing the configuration we will denote with \cellref[\begin{array}{@{}c@{}}{\kall{}{}... \ \kall{}{}}\end{array}]{cell} a container cell, holding another cells, and with \cellref[Type]{cell} a leaf cell and its type.

During the preprocessing phase there is only one \cellref[\begin{array}{@{}c@{}}{\kall{}{}... \ \kall{}{}}\end{array}]{thread} where the whole program with all its classes is preprocessed. During execution phase there might be multiple \cellref[]{thread} cells -- one per actual running thread. The cell \cellref[]{thread} contains leaf-cells \cellref[]{k} and \cellref[]{stack} and container cells \cellref[\begin{array}{@{}c@{}}{\kall{}{}... \ \kall{}{}}\end{array}]{methodContext} and \cellref[\begin{array}{@{}c@{}}{\kall{}{}... \ \kall{}{}}\end{array}]{threadData}. The cell \cellref[]{k} is the actual computation, both during preprocessing phases and execution. When the cell \cellref[]{k} remains empty during preprocessing, this represents the end of the current preprocessing phase and transition to the next one. If the cell \cellref[]{k} remains empty during the execution, the enclosing thread is terminated. The next cell in order is \cellref[]{stack} -- the thread stack.

Inside the cell \cellref[\begin{array}{@{}c@{}}{\kall{}{}... \ \kall{}{}}\end{array}]{methodContext} we have various data holding the context of the currently executing method. Here we have:

\begin{itemize}
\item \cellref[Map{{[}}Id\mapsto{}Int{{]}}]{env} -- the map from local variable names to their location inside \cellref[]{store}.
\item \cellref[]{localClassesEnv} is related to local classes and will be explained later.
\item \cellref[Type]{return} -- method return type.
\item \cellref[ContextType]{contextType} -- may have one of two values: staticCT or instanceCT, depending on whether the current method is static or non-static.
\item \cellref[\begin{array}{@{}c@{}}{\kall{}{}... \ \kall{}{}}\end{array}]{crntObj} -- the object associated with the current running method, if any. In non-static contexts \cellref[ClassType]{crntClass} contains the compile-time class associated to the current method, and \cellref[Int]{location} holds the location of the current object in the store. For static contexts cells have empty values: noClass and $\dotCt{K}$ respectively.
\end{itemize}

The group of cells \cellref[\begin{array}{@{}c@{}}{\kall{}{}... \ \kall{}{}}\end{array}]{threadData} contains:

\begin{itemize}
\item \cellref[Int]{tid} -- the thread id.
\item \cellref[Map{{[}}Int\mapsto{}Int{{]}}]{holds} -- a map from Object locations to integer numbers. Map keys are monitor objects on which the current thread have the locks. Map values hold the number of times the lock was acquired.
\item \cellref[Bool]{interrupted} -- boolean value signaling whether the current thread was interrupted.
\end{itemize}

From the evaluation standpoint, the semantics is divided into several preprocessing phases followed by the actual program execution. Preprocessing phases are roughly equivalent to java compilation. They perform all the computations that would be traditionally expected from the compiler. The evaluation phases are:

\begin{itemize}
\item Process Type Names
\item Process Compilation Units
\item Process Class Declarations
\item Process Class Members
\item Elaboration
\item Execution
\end{itemize}

The current evaluation phase of the semantics is stored in \cellref[]{globalPhase}. The cell is initialized with the id of the first phase - ProcTypeNamesPhase.

Next are the cells from the group \cellref[\begin{array}{@{}c@{}}{\kall{}{}... \ \kall{}{}}\end{array}]{phStart} that exist since the program beginning:

\begin{itemize}
\item \cellref[K]{program} -- The input program, in AST format.
\item \cellref[String]{mainClass} -- The initial class, containing the method main().
\end{itemize}

Both cells are initialized with arguments passed through command-line, same way as for JDK Java.

The remaining global cells are grouped by the phase when they first come into play. Thus, the cells within \cellref[]{phTN} are populated during Process Type Names phase, the cells from \cellref[]{phCU} -- during Process Compilation Unit and so on. The last group of global cells, \cellref[]{groupDebug} serve for debugging.

\bigskip

In the phase Process Type Names the semantics passes through all compilation units and computes two global cells:

\begin{itemize}
\item \cellref[Map{[}PackageId\mapsto{}Map{[}Id\mapsto{}ClassType{]}{]}]{namesToClasses} A two-level map. First level is a map from package names to another map. That second-level map maps simple class names within a package to fully-qualified class names. This cell is extensively used through the semantics. The map contains both top-level and inner classes. For inner classes, their enclosing package is the fully qualified class name of the directly enclosing class.
\item \cellref[Map{{[}}ClassType\mapsto{}AccessMode{{]}}]{classesToAccessModes} -- A map from class names to their respective access mode, for all classes.
\end{itemize}

\bigskip

The phase Process Compilation Units takes again as input the whole program and analyzes it at a deeper level. This time data collected at the previous phase is used to process compilation unit imports. Imports data is stored temporarily in the cell:

\begin{itemize}
\item \cellref[Map{[}Id\mapsto{}ClassType{]}]{compUnitImports} A map from all type names accessible in this compilation unit to their respective fully qualified class names. This includes both classes accessible through imports declarations and classes declared in the package of the current compilation unit.
\end{itemize}

Next during this phase each class is stored into a \cellref[]{class} cell. Again, both top-level and inner classes are covered. In a newly created a \cellref[]{class} just a few sub-cells are initialized with data. Among them three have a central role in the whole semantics:

\begin{itemize}
\item \cellref[ClassType]{className} -- The fully qualified class name.
\item \cellref[ClassMetaType]{classMetaType} -- Whether the type stored in this cell is class or interface. To avoid
terminology superfluousness, we will refer from now on to both classes and interfaces as "classes", making distinctions only when necessary.
\item \cellref[ClassPhase]{classPhase} -- represents the state of this class. In addition to the global computation phase, each class have its own lifecycle phase. Class phases are required to keep track which classes were processed in the current global phase and which were not. During each global phase all classes should transition to a certain class phase. However the relationship between global phases and class phases is not one-to-one. There could be several per-class transitions in one global phase, and none in another. The order in which classes are preprocessed is not their literal order but the order imposed by their dependency relationship. More details will be presented below. The class phases are:

\begin{itemize}
\item Created -- the initial phase. At the end of Process Compilation Units all classes are registered as "created".
\item Bases Resolved
\item Declaration Processed
\item Members Processed
\end{itemize}

\end{itemize}

In addition to the three cells above, during Process Compilation Units a few more cells are saved. They are grouped under \cellref[\begin{array}{@{}c@{}}{\kall{}{}... \ \kall{}{}}\end{array}]{cphCreated} :

\begin{itemize}
\item \cellref[ClassType]{enclosingClass} -- the directly enclosing class, for inner classes. The value noClass fr top-level classes.
\item \cellref[K]{rawExtends} -- The extends clause of this class, in its raw form.
\item \cellref[K]{rawImplements} -- The implements clause, in AST form.
\item \cellref[K]{rawDeclarations} -- The class body, in AST form.
\item \cellref[Map{[}Id\mapsto{}ClassType{]}]{cuImports} -- For top-level classes, the content of this cell copies \cellref[]{compUnitImports} computed for this compilation unit. For inner classes the cell is empty. The classes in this cell are required to resolve extends/implements clauses of top-level cells.
\end{itemize}

As we can see, the cells saved during the class phase Created contain all the data of the original AST of the class. Thus, initial AST representation of the program is no longer needed. In fact, the cell \cellref[]{program} is discarded at the end of Process Compilation Units. The remaining preprocessing phases will use class data in this initial form to compute other cells within \cellref[]{class}, finally used for execution.

\bigskip

Next phase is Process Class Declarations. Here each class passes through two more class phases: Bases Processed and Declarations Processed. First, for each class the semantics attempts to resolve its extends/implements clauses into fully qualified class names. The order in which dependencies are resolved depends on both class inheritance relationships as well as nesting relationships. Once the dependencies of a class are resolved, they are stored into a temporary cell:

\begin{itemize}
\item \cellref[K]{unprocessedBases} -- Initialized with the list of fully qualified class names for classes mentioned in extends/implements clauses of this class.
\end{itemize}

Once \cellref[K]{unprocessedBases} are saved the class enters into the phase Bases Resolved. It then waits in this phase until all extends/implements classes reach the phase Declarations Processed. The restrictions inJLS related to class dependencies guarantee that classes cannot have cyclic dependencies, thus a class cannot get locked in the waiting state. The cell \cellref[K]{unprocessedBases} is used to determine the moment when the class may exit the waiting state. Once a class reaches the phase Declarations Processed, is is deleted from cells \cellref[K]{unprocessedBases} of other classes. Thus, when all extends/implements dependencies of a class reach the phase Declarations Processed, the content of the its \cellref[K]{unprocessedBases} cell becomes empty. Once in this state, the class enters into the phase Declarations Processed itself and computes three more cells:

\begin{itemize}
\item \cellref[ClassType]{extends} -- The base class, fully qualified.
\item \cellref[Set{[}ClassType{]}]{implements} -- The list of directly implemented interfaces, fully qualified.
\item \cellref[Map{[}Id\mapsto{}ClassType{]}]{imports} -- The map of classes accessible by simple name within the body of this class. The rules for computing this map are complex and include the following sources:

\begin{itemize}
\item Imports declarations of the current compilation unit.
\item Classes declared within the package of the current compilation unit.
\item Classes accessible within the body of the directly enclosing class, if the current class is inner class.
\item Inner classes inherited from base classes, e.g. from extends/implements clauses.
\item Inner classes of this class itself.
\end{itemize}

The need to cover all these cases leads to the intricate order in which class dependencies have to be be resolved.
\end{itemize}

When a class enters the phase Declarations Processed, the cells \cellref[]{rawExtends}, \cellref[]{rawImplements} and \cellref[K]{unprocessedBases} are no longer needed and are discarded. Once all classes reach this phase the computation proceeds to the next global phase.

\bigskip

During the global phase Process Class Members each class processes its members and reaches the state Members Processes. Until then the class body is stored in \cellref[]{rawDeclarations}. A class member could be one of:

\begin{itemize}
\item field
\item method
\item constructor
\item static or instance initializer
\end{itemize}

During this global phase class members are distributed into the following cells:

\begin{itemize}
\item \cellref[Set{[}ClassType{]}]{implTrans} -- The transitive closure of implemented interfaces. In the remaining phases this set is used by the subtyping relationship.
\item \cellref[Map{[}Signature\mapsto{}ClassType{]}]{methods} -- The map of accessible methods. Keys are method signatures, values are classes where methods are defined. Includes both methods declared within this class as well amd methods inherited from base classes/ base interfaces.
\item \cellref[\text{Multiple inner cells}]{methodDecs} -- The map of defined methods. Map values are method implementations. This cell includes only methods defined within the body of the present class.
\item \cellref[K]{fieldDecs} -- The list of instance field declarations, stored as a list of local variable declaration statements, without initializers. Used during object instantiation.
\item \cellref[Map{[}Id\mapsto Field Entry{]}]{instanceEnv} -- the same fields as in \cellref[]{fieldDecs} but in a different form. Used in the elaboration phase.
\item \cellref[K]{instanceInit} -- The list of instance initializers of the class combined into one big instance initializer. Instance field initializers are also concatenated into this cell in their textual order. The content of this cell is executed as part of object instantiation.
\item \cellref[Map{[}Id \mapsto Location{]}]{staticEnv} -- The map from static fields declared in this class to their locations in the store. Since static fields have only one instance per class declaration, it is possible to allocate a value in the store for them at this phase, when static fields are first reaced.
\item \cellref[K]{staticInit} -- The list of static initializers and static field initializers concatenated into one block. Invoked during class static initialization.
\item \cellref[Map{[}Id \mapsto Value{]}]{constantEnv} -- The map from constants to their actual values. Constants in Java have a slightly different semantics compared to final static fields. In particular, accessing them don't trigger static initialization of the declaring class.
\end{itemize}

Once all the cells above are computed the class proceeds into the phase Members Processed and the cell \cellref[]{rawDeclarations} is deleted.

\bigskip

The last preprocessing phase is Elaboration. Here all the code blocks are processed - method and constructor bodies, static and instance initializers. Most of the information traditionally inferred by the compiler is computed at this phase. More precisely the elaboration performs the following transformations:

\begin{itemize}
\item Each name is resolved into local variable, field, method, class or package. While a method may be distinguished from other cathegories purely syntactically, resolving to other categories requires knowledge of the names existing in the current context.
\item Simple class names are resolved into fully qualified class names. Hereafter all the class names in the code are fully qualified.
\item The compile-time type of each expression is inferred. Thus, when the code reaches execution phase, expressions are no longer in their initial form. The expressions are annotated with their types.
\item For each method call the precise signature in inferred.
\item Local and anonymous classes are processed. The earliest phase where local classes could be discovered is elaboration. Still, local classes have all the features of other classes. Thus they need to be passed through all the preprocessing steps. The whole preprocessing for local classes is performed during the global phase elaboration.
\end{itemize}

Despite this phase being the most complex preprocessing phase of all, it introduces few new cells. Most of them are related to local classes. Inside \cellref[]{class} just one new cell is introduced:

\begin{itemize}
\item \cellref[Map{[}Id \mapsto Type{]}]{enclosingLocalEnv} -- The map from local variables of the current block to their types. Used during local classes processing.
\end{itemize}

Among global cells the following new cells are added:

\begin{itemize}
\item \cellref[List[mapWrap(Map[Id \mapsto Type])]]{elabEnv} -- A stack where each layer is a map of local variables. Each layer of the stack represents a code block, in the blocks nesting order. Inside each layer, the map is from local variables accessible in that layer to variable types.
\item \cellref[List[mapWrap(Map[Id \mapsto ClassType])]]{localTypes} -- A cell similar in structure to the previous one. This time map keys are local classes instead of variables.
\item \cellref[Int]{nextLocalId} -- a number used to generate unique fully-qualified class names for local classes.
\end{itemize}

During the elaboration phase no cells are consumed. Instead, the code blocks stored inside \cellref[]{methodDecs}, \cellref[]{instanceInit}, \cellref[]{staticInit} are processed and stored back into the same cell. After elaboration the classes remain in the same state -- Members Processes. The state Members Processed is in fact the final state of the cell \cellref[]{class}.

\bigskip

When evaluation reaches the last phase, execution, classes have one more cell to enter into play:

\begin{itemize}
\item \cellref[]{staticInitStatus} -- a flag indicating whether the class was statically initialized or not.
\end{itemize}

Among global cells the following are related to execution phase:

\begin{itemize}
\item \cellref[Map{[}Location:Int \mapsto Value:TypedVal{]}]{store} -- the program memory. Map from memory locations to actual values. The single most important cell of the execution phase.
\item \cellref[Int]{nextLoc} -- the number of allocated memory locations. Used to generate unique memory addresses for each allocation.
\item \cellref[List]{in} -- the standard input, represented as pre-parsed list of elements of type Int or String.
\item \cellref[List]{out} -- the standard output.
\item \cellref[Map{[}Type \mapsto TypedVal{]}]{classLiteralsMap} -- a map from types T to objects that represent the value of the expression T.class .

\item the remaining cells are related to threads:
\begin{itemize}
\item \cellref[Set{[}ObjLocation:Int{]}]{busy} -- the set of busy objects. E.g. monitor objects for which there is a thread holding the monitor.
\item \cellref[Map{[}ThreadId:Int \mapsto OL:Int{]}]{waitingThreads} -- The map from threads to monitor objects on which the threads are blocked in a call to wait(). Used by the methods Object.wait(), Object.notify(), Object.notifyAll().
\item \cellref[Set{[}ThreadId:Int{]}]{terminated} -- the set of terminated threads.
\end{itemize}

\end{itemize}

The rest of the global cells are related to debugging.
*/

configuration
    <T>
      //Configuration part 1: threads
      <threads color="GreenYellow">
        <thread multiplicity="*" color="GreenYellow">
          <k color="Green"> $COMMAND:K </k>

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

          <br/>
          //Class Phase Members

          //Transitively implemented interfaces. Used by subtyping rules.
          <implTrans color="DeepPink"> .Set </implTrans>

          /*Signatures of methods accessible to this class (both declared and inherited)
            Map[Sig -> Class]
            Used in elaboration of method calls.*/
          <methods color="Blue"> .Map </methods>

          /*All methods declared in this class.
            Used in elaboration of method calls.*/
          <methodDecs color="Blue">

            <methodDec multiplicity="*" color="Blue">

              //Method signature, of type Signature
              <methodSignature color="Blue"> .K </methodSignature>

              //Method params
              <methodParams color="Blue"> [.KList] </methodParams>

              //Method body
              <methodBody color="Blue"> .K </methodBody>

              <methodAccessMode color="Blue"> .K </methodAccessMode>

              //Either staticCT or instanceCT
              <methodContextType color="Blue"> .K </methodContextType>

            </methodDec>
          </methodDecs>

          //[...,, 'LocalVarDec(_),, ...] - Instance field declarations. Used during object instantiation.
          <instanceFields color="Indigo"> [.KList] </instanceFields>

          //[...,, 'FieldDec('Static(_),,T,,_),, ...] - Static field declarations. Used during class instantiation.
          <staticFields color="DarkSlateGray"> [.KList] </staticFields>

          //The sequence of static initializers (that also includes field initializers)
          //see static-init.k for more details.
          <staticInit color="DarkSlateGray"> [.KList] </staticInit>

          <br/>
          //Class Phase Folding

          //The whole class folded back into a 'ClassDec(...) node
          <folded color="Teal"> .K </folded>

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
      //Configuration part 3: global cells

      <globalPhase color="YellowGreen"> $STARTPHASE:GlobalPhase </globalPhase>
      <lastGlobalPhase color="YellowGreen"> $ENDPHASE:GlobalPhase </lastGlobalPhase>

      <br/>
      //Global Phase Start

      //The initial program loaded by krun. For full mode and preprocessing this is
      //the initial java program, for execution mode it is the folded java program.
      <program color="LightSteelBlue"> $PGM:K </program>

      //Main class, passed as krun argument. We need it from the outside, just like JDK Java.
      <mainClass color="LightSteelBlue"> $MainClass:List </mainClass>

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

      //Standard input. Each token is a ListItem.
      <in color="LightPink" stream="stdin"> .List </in>

      //Standard output. Each token is a ListItem.
      <out color="LightPink" stream="stdout"> .List </out>

      //A map from types to objectRef() terms that represent their T.class value
      //Created an used in execution phase, by expressions of the form X.class
      //Type: Map[Type->TypedVal]. Type may be any reference type.
      <classLiteralsMap color="LightPink"> .Map </classLiteralsMap>

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
