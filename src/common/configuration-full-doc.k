/*@
The configuration is divided into three large cell groups. The group $\kall{threads}{}$ contains one or multiple cells $\kall{thread}{}$. Here is the data related to the execution of a thread, such as the computation, stack, local environment. The second group is contained inside $\kall{classes}{}$ that have multiple $\kall{class}{}$ cells -- anything class-related. What remains are the top-level cells -- the third group. Top-level cells are related to memory store, global thread-synchronization data and auxiliary cells for debugging.

Some cells in this configuration are not used within the rules. They serve only for grouping other cells by context. Grouping cells are colored yellow, whereas actual semantics cells have other colors.

While describing the configuration we will denote with $\kall{cell}{\begin{array}{@{}c@{}}{\kall{}{}... \ \kall{}{}}\end{array}}$ a container cell, holding another cells, and with $\kall{cell}{Type}$ a leaf cell and its type.

During the preprocessing phase there is only one $\kall{thread}{\begin{array}{@{}c@{}}{\kall{}{}... \ \kall{}{}}\end{array}}$ where the whole program with all its classes is preprocessed. During execution phase there might be multiple $\kall{thread}{}$ cells -- one per actual running thread. The cell $\kall{thread}{}$ contains leaf-cells $\kall{k}{}$ and $\kall{stack}{}$ and container cells $\kall{methodContext}{\begin{array}{@{}c@{}}{\kall{}{}... \ \kall{}{}}\end{array}}$ and $\kall{threadData}{\begin{array}{@{}c@{}}{\kall{}{}... \ \kall{}{}}\end{array}}$. The cell $\kall{k}{}$ is the actual computation, both during preprocessing phases and execution. When the cell $\kall{k}{}$ remains empty during preprocessing, this represents the end of the current preprocessing phase and transition to the next one. If the cell $\kall{k}{}$ remains empty during the execution, the enclosing thread is terminated. The next cell in order is $\kall{stack}{}$ -- the thread stack.

Inside the cell $\kall{methodContext}{\begin{array}{@{}c@{}}{\kall{}{}... \ \kall{}{}}\end{array}}$ we have various data holding the context of the currently executing method. Here we have:

\begin{itemize}
\item $\kall{env}{Map[Id\mapsto{}Int]}$ -- the map from local variable names to their location inside $\kall{store}{}$.
\item $\kall{localClassesEnv}{}$ is related to local classes and will be explained later.
\item $\kall{return}{Type}$ -- method return type.
\item $\kall{contextType}{ContextType}$ -- may have one of two values: staticCT or instanceCT, depending on whether the current method is static or non-static.
\item $\kall{crntObj}{\begin{array}{@{}c@{}}{\kall{}{}... \ \kall{}{}}\end{array}}$ -- the object associated with the current running method, if any. In non-static contexts $\kall{crntClass}{ClassType}$ contains the compile-time class associated to the current method, and $\kall{location}{Int}$ holds the location of the current object in the store. For static contexts cells have empty values: noClass and $\dotCt{K}$ respectively.
\end{itemize}

The group of cells $\kall{threadData}{\begin{array}{@{}c@{}}{\kall{}{}... \ \kall{}{}}\end{array}}$ contains:

\begin{itemize}
\item $\kall{tid}{Int}$ -- the thread id.
\item $\kall{holds}{Map[Int\mapsto{}Int]}$ -- a map from Object locations to integer numbers. Map keys are monitor objects on which the current thread have the locks. Map values hold the number of times the lock was acquired.
\item $\kall{interrupted}{Bool}$ -- boolean value signaling whether the current thread was interrupted.
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

The current evaluation phase of the semantics is stored in $\kall{globalPhase}{}$. The cell is initialized with the id of the first phase - ProcTypeNamesPhase.

Next are the cells from the group $\kall{phStart}{\begin{array}{@{}c@{}}{\kall{}{}... \ \kall{}{}}\end{array}}$ that exist since the program beginning:

\begin{itemize}
\item $\kall{program}{K}$ -- The input program, in AST format.
\item $\kall{mainClass}{String}$ -- The initial class, containing the method main().
\end{itemize}

Both cells are initialized with arguments passed through command-line, same way as for JDK Java.

The remaining global cells are grouped by the phase when they first come into play. Thus, the cells within $\kall{phTN}{}$ are populated during Process Type Names phase, the cells from $\kall{phCU}{}$ -- during Process Compilation Unit and so on. The last group of global cells, $\kall{groupDebug}{}$ serve for debugging.

\bigskip

In the phase Process Type Names the semantics passes through all compilation units and computes two global cells:

\begin{itemize}
\item $\kall{namesToClasses}{Map[PackageId\mapsto{}Map[Id\mapsto{}ClassType]]}$ A two-level map. First level is a map from package names to another map. That second-level map maps simple class names within a package to fully-qualified class names. This cell is extensively used through the semantics. The map contains both top-level and inner classes. For inner classes, their enclosing package is the fully qualified class name of the directly enclosing class.
\item $\kall{classesToAccessModes}{Map[ClassType\mapsto{}AccessMode]}$ -- A map from class names to their respective access mode, for all classes.
\end{itemize}

\bigskip

The phase Process Compilation Units takes again as input the whole program and analyzes it at a deeper level. This time data collected at the previous phase is used to process compilation unit imports. Imports data is stored temporarily in the cell:

\begin{itemize}
\item $\kall{compUnitImports}{Map[Id\mapsto{}ClassType]}$ A map from all type names accessible in this compilation unit to their respective fully qualified class names. This includes both classes accessible through imports declarations and classes declared in the package of the current compilation unit.
\end{itemize}

Next during this phase each class is stored into a $\kall{class}{}$ cell. Again, both top-level and inner classes are covered. In a newly created a $\kall{class}{}$ just a few sub-cells are initialized with data. Among them three have a central role in the whole semantics:

\begin{itemize}
\item $\kall{className}{ClassType}$ -- The fully qualified class name.
\item $\kall{classMetaType}{ClassMetaType}$ -- Whether the type stored in this cell is class or interface. To avoid
terminology superfluousness, we will refer from now on to both classes and interfaces as "classes", making distinctions only when necessary.
\item $\kall{classPhase}{ClassPhase}$ -- represents the state of this class. In addition to the global computation phase, each class have its own lifecycle phase. Class phases are required to keep track which classes were processed in the current global phase and which were not. During each global phase all classes should transition to a certain class phase. However the relationship between global phases and class phases is not one-to-one. There could be several per-class transitions in one global phase, and none in another. The order in which classes are preprocessed is not their literal order but the order imposed by their dependency relationship. More details will be presented below. The class phases are:

\begin{itemize}
\item Created -- the initial phase. At the end of Process Compilation Units all classes are registered as "created".
\item Bases Resolved
\item Declaration Processed
\item Members Processed
\end{itemize}

\end{itemize}

In addition to the three cells above, during Process Compilation Units a few more cells are saved. They are grouped under $\kall{cphCreated}{\begin{array}{@{}c@{}}{\kall{}{}... \ \kall{}{}}\end{array}}$ :

\begin{itemize}
\item $\kall{enclosingClass}{ClassType}$ -- the directly enclosing class, for inner classes. The value noClass fr top-level classes.
\item $\kall{rawExtends}{K}$ -- The extends clause of this class, in its raw form.
\item $\kall{rawImplements}{K}$ -- The implements clause, in AST form.
\item $\kall{rawDeclarations}{K}$ -- The class body, in AST form.
\item $\kall{cuImports}{Map[Id\mapsto{}ClassType]}$ -- For top-level classes, the content of this cell copies $\kall{compUnitImports}{}$ computed for this compilation unit. For inner classes the cell is empty. The classes in this cell are required to resolve extends/implements clauses of top-level cells.
\end{itemize}

As we can see, the cells saved during the class phase Created contain all the data of the original AST of the class. Thus, initial AST representation of the program is no longer needed. In fact, the cell $\kall{program}{}$ is discarded at the end of Process Compilation Units. The remaining preprocessing phases will use class data in this initial form to compute other cells within $\kall{class}{}$, finally used for execution.

\bigskip

Next phase is Process Class Declarations. Here each class passes through two more class phases: Bases Processed and Declarations Processed. First, for each class the semantics attempts to resolve its extends/implements clauses into fully qualified class names. The order in which dependencies are resolved depends on both class inheritance relationships as well as nesting relationships. Once the dependencies of a class are resolved, they are stored into a temporary cell:

\begin{itemize}
\item $\kall{unprocessedBases}{K}$ -- Initialized with the list of fully qualified class names for classes mentioned in extends/implements clauses of this class.
\end{itemize}

Once $\kall{unprocessedBases}{K}$ are saved the class enters into the phase Bases Resolved. It then waits in this phase until all extends/implements classes reach the phase Declarations Processed. The restrictions inJLS related to class dependencies guarantee that classes cannot have cyclic dependencies, thus a class cannot get locked in the waiting state. The cell $\kall{unprocessedBases}{K}$ is used to determine the moment when the class may exit the waiting state. Once a class reaches the phase Declarations Processed, is is deleted from cells $\kall{unprocessedBases}{K}$ of other classes. Thus, when all extends/implements dependencies of a class reach the phase Declarations Processed, the content of the its $\kall{unprocessedBases}{K}$ cell becomes empty. Once in this state, the class enters into the phase Declarations Processed itself and computes three more cells:

\begin{itemize}
\item $\kall{extends}{ClassType}$ -- The base class, fully qualified.
\item $\kall{implements}{Set[ClassType]}$ -- The list of directly implemented interfaces, fully qualified.
\item $\kall{imports}{Map[Id\mapsto{}ClassType]}$ -- The map of classes accessible by simple name within the body of this class. The rules for computing this map are complex and include the following sources:

\begin{itemize}
\item Imports declarations of the current compilation unit.
\item Classes declared within the package of the current compilation unit.
\item Classes accessible within the body of the directly enclosing class, if the current class is inner class.
\item Inner classes inherited from base classes, e.g. from extends/implements clauses.
\item Inner classes of this class itself.
\end{itemize}

The need to cover all these cases leads to the intricate order in which class dependencies have to be be resolved.
\end{itemize}

When a class enters the phase Declarations Processed, the cells $\kall{rawExtends}{}$, $\kall{rawImplements}{}$ and $\kall{unprocessedBases}{K}$ are no longer needed and are discarded. Once all classes reach this phase the computation proceeds to the next global phase.

\bigskip

During the global phase Process Class Members each class processes its members and reaches the state Members Processes. Until then the class body is stored in $\kall{rawDeclarations}{}$. A class member could be one of:

\begin{itemize}
\item field
\item method
\item constructor
\item static or instance initializer
\end{itemize}

During this global phase class members are distributed into the following cells:

\begin{itemize}
\item $\kall{implTrans}{Set[ClassType]}$ -- The transitive closure of implemented interfaces. In the remaining phases this set is used by the subtyping relationship.
\item $\kall{methods}{Map[Signature\mapsto{}ClassType]}$ -- The map of accessible methods. Keys are method signatures, values are classes where methods are defined. Includes both methods declared within this class as well amd methods inherited from base classes/ base interfaces.
\item $\kall{methodDecs}{Multiple inner cells}$ -- The map of defined methods. Map values are method implementations. This cell includes only methods defined within the body of the present class.
\item $\kall{fieldDecs}{K}$ -- The list of instance field declarations, stored as a list of local variable declaration statements, without initializers. Used during object instantiation.
\item $\kall{instanceEnv}{Map[Id\mapsto Field Entry]}$ -- the same fields as in $\kall{fieldDecs}{}$ but in a different form. Used in the elaboration phase.
\item $\kall{instanceInit}{K}$ -- The list of instance initializers of the class combined into one big instance initializer. Instance field initializers are also concatenated into this cell in their textual order. The content of this cell is executed as part of object instantiation.
\item $\kall{staticEnv}{Map[Id \mapsto Location]}$ -- The map from static fields declared in this class to their locations in the store. Since static fields have only one instance per class declaration, it is possible to allocate a value in the store for them at this phase, when static fields are first reaced.
\item $\kall{staticInit}{K}$ -- The list of static initializers and static field initializers concatenated into one block. Invoked during class static initialization.
\item $\kall{constantEnv}{Map[Id \mapsto Value]}$ -- The map from constants to their actual values. Constants in Java have a slightly different semantics compared to final static fields. In particular, accessing them don't trigger static initialization of the declaring class.
\end{itemize}

Once all the cells above are computed the class proceeds into the phase Members Processed and the cell $\kall{rawDeclarations}{}$ is deleted.

\bigskip

The last preprocessing phase is Elaboration. Here all the code blocks are processed - method and constructor bodies, static and instance initializers. Most of the information traditionally inferred by the compiler is computed at this phase. More precisely the elaboration performs the following transformations:

\begin{itemize}
\item Each name is resolved into local variable, field, method, class or package. While a method may be distinguished from other cathegories purely syntactically, resolving to other categories requires knowledge of the names existing in the current context.
\item Simple class names are resolved into fully qualified class names. Hereafter all the class names in the code are fully qualified.
\item The compile-time type of each expression is inferred. Thus, when the code reaches execution phase, expressions are no longer in their initial form. The expressions are annotated with their types.
\item For each method call the precise signature in inferred.
\item Local and anonymous classes are processed. The earliest phase where local classes could be discovered is elaboration. Still, local classes have all the features of other classes. Thus they need to be passed through all the preprocessing steps. The whole preprocessing for local classes is performed during the global phase elaboration.
\end{itemize}

Despite this phase being the most complex preprocessing phase of all, it introduces few new cells. Most of them are related to local classes. Inside $\kall{class}{}$ just one new cell is introduced:

\begin{itemize}
\item $\kall{enclosingLocalEnv}{Map[Id \mapsto Type]}$ -- The map from local variables of the current block to their types. Used during local classes processing.
\end{itemize}

Among global cells the following new cells are added:

\begin{itemize}
\item $\kall{elabEnv}{List[mapWrap(Map[Id \mapsto Type])]}$ -- A stack where each layer is a map of local variables. Each layer of the stack represents a code block, in the blocks nesting order. Inside each layer, the map is from local variables accessible in that layer to variable types.
\item $\kall{localTypes}{List[mapWrap(Map[Id \mapsto ClassType])]}$ -- A cell similar in structure to the previous one. This time map keys are local classes instead of variables.
\item $\kall{nextLocalId}{Int}$ -- a number used to generate unique fully-qualified class names for local classes.
\end{itemize}

During the elaboration phase no cells are consumed. Instead, the code blocks stored inside $\kall{methodDecs}{}$, $\kall{instanceInit}{}$, $\kall{staticInit}{}$ are processed and stored back into the same cell. After elaboration the classes remain in the same state -- Members Processes. The state Members Processed is in fact the final state of the cell $\kall{class}{}$.

\bigskip

When evaluation reaches the last phase, execution, classes have one more cell to enter into play:

\begin{itemize}
\item $\kall{staticInitStatus}{}$ -- a flag indicating whether the class was statically initialized or not.
\end{itemize}

Among global cells the following are related to execution phase:

\begin{itemize}
\item $\kall{store}{Map[Location:Int \mapsto Value:TypedVal]}$ -- the program memory. Map from memory locations to actual values. The single most important cell of the execution phase.
\item $\kall{nextLoc}{Int}$ -- the number of allocated memory locations. Used to generate unique memory addresses for each allocation.
\item $\kall{in}{List}$ -- the standard input, represented as pre-parsed list of elements of type Int or String.
\item $\kall{out}{List}$ -- the standard output.
\item $\kall{classLiteralsMap}{Map[Type \mapsto TypedVal]}$ -- a map from types T to objects that represent the value of the expression T.class .

\item the remaining cells are related to threads:
\begin{itemize}
\item $\kall{busy}{Set[ObjLocation:Int]}$ -- the set of busy objects. E.g. monitor objects for which there is a thread holding the monitor.
\item $\kall{waitingThreads}{Map[ThreadId:Int \mapsto OL:Int]}$ -- The map from threads to monitor objects on which the threads are blocked in a call to wait(). Used by the methods Object.wait(), Object.notify(), Object.notifyAll().
\item $\kall{terminated}{Set[ThreadId:Int]}$ -- the set of terminated threads.
\end{itemize}

\end{itemize}

The rest of the global cells are related to debugging.

\pagebreak
*/
