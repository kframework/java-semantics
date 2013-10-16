/*@ \section{Module CONFIGURATION}

The configuration is divided into three large cell groups. The group $\kall{threads}{}$ contains one or multiple cells $\kall{thread}{}$. Here is the data related to the execution of a thread, such as the computation, stack, local environment. The second group is contained inside $\kall{classes}{}$ that have multiple $\kall{class}{}$ cells -- anything class-related. What remains are the top-level cells -- the third group. Top-level cells are related to memory store, global thread-synchronization data and auxiliary cells for debugging.

Some cells in this configuration are not used within the rules. They serve only for grouping other cells by context. Grouping cells are colored yellow, whereas actual semantics cells have other colors.

While describing the configuration we will denote with $\kall{cell}{\begin{array}{@{}c@{}}{\kall{}{}... \ \kall{}{}}\end{array}}$ a container cell, holding another cells, and with $\kall{cell}{Type}$ a leaf cell and its type.

During the preprocessing phase there is only one $\kall{thread}{\begin{array}{@{}c@{}}{\kall{}{}... \ \kall{}{}}\end{array}}$ where the whole program with all its classes is preprocessed. During execution phase there might be multiple $\kall{thread}{}$ cells -- one per actual running thread. The cell $\kall{thread}{}$ contains leaf-cells $\kall{k}{}$ and $\kall{stack}{}$ and container cells $\kall{methodContext}{\begin{array}{@{}c@{}}{\kall{}{}... \ \kall{}{}}\end{array}}$ and $\kall{threadData}{\begin{array}{@{}c@{}}{\kall{}{}... \ \kall{}{}}\end{array}}$. The cell $\kall{k}{}$ is the actual computation, both during preprocessing and execution. When after a preprocessing phase the cell $\kall{k}{}$ remains empty, evaluation transitions into the next phase. If the cell $\kall{k}{}$ remains empty during the execution phase, the enclosing thread is terminated. The cell $\kall{stack}{}$ is the thread stack.

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

The evaluation phase of the semantics is stored in $\kall{globalPhase}{}$. The cell is initialized with the id of the first phase - ProcTypeNamesPhase.

Next are the cells from the group $\kall{phStart}{\begin{array}{@{}c@{}}{\kall{}{}... \ \kall{}{}}\end{array}}$ that exist since the program beginning:

\begin{itemize}
\item $\kall{program}{K}$ -- The input program, in AST format.
\item $\kall{mainClass}{String}$ -- The initial class, containing the method main().
\end{itemize}

Both cells are initialized with arguments passed through command-line, as is the case with JDK Java.

The remaining global cells are grouped by the phase when they first come into play. Thus, the cells within $\kall{phTN}{}$ are populated during Process Type Names phase, the cells from $\kall{phCU}{}$ -- during Process Compilation Unit and so on. The last group of global cells, $\kall{groupDebug}{}$ serve for debugging purposes only.

In the phase Process Type Names the semantics passes through all compilation units and computes two global cells:

\begin{itemize}
\item $\kall{namesToClasses}{Map[PackageId\mapsto{}Map[Id\mapsto{}ClassType]]}$ A two-level map. First level is a map from package names to another map. That second-level map maps simple class names within a package to fully-qualified class names. This cell is extensively used through the semantics. The map contains both top-level and inner classes. for inner classes, the package where they are registered is the fully qualified class name of the directly enclosing class.
\item $\kall{classesToAccessModes}{Map[ClassType\mapsto{}AccessMode]}$ -- A map from class names to their respective access mode, for each class registered in the previous cell.
\end{itemize}

The phase Process Compilation Units takes again as input the whole program, and thoroughly processes each compilation unit. This time data collected at the previous phase is used to process compilation unit imports. Imports data is stored temporarily in the cell:

\begin{itemize}
\item $\kall{compUnitImports}{Map[Id\mapsto{}ClassType]}$ A map from all type names accessible in this compilation unit to their respective fully qualified class names. This includes both names imported through imports declarations and classes declared in the same package.
\end{itemize}

Next during this phase each class declaration is first processed and stored in a separate $\kall{class}{}$ cell. Again, both top-level and inner classes are considered. Each class have three cells that are central to the semantics:

\begin{itemize}
\item $\kall{className}{ClassType}$ -- The fully qualified class name.
\item $\kall{metaType}{MetaType}$ -- Whether this type is class or interface. To avoid terminology superfluousness, we will refer from now on to both classes and interfaces as "classes", making distinctions only when necessary.
\item $\kall{classPhase}{ClassPhase}$ -- class processing phase. In addition to global computation phase, each class have its own phase of existence. Class phases are directly related to global phases. Thus, during each global phase each class should transition to a certain class phase. However the relationship is not one-to-one: we might observe several per-class transitions in one global phase, and none in another. Class phases are required because the order in which classes are preprocessed is generally not their literal order, and cannot be predicted upfront. As we will see later, classes are processed in the order of their dependencies. The class phases are:

\begin{itemize}
\item Created -- the initial phase. At the end of Process Compilation Units all classes are registered as "created".
\item Bases Resolved
\item Declaration Processed
\item Members Processed
\end{itemize}

\end{itemize}

In addition to the three cells above, during Process Compilation Units the following cells are computed for each class. They are grouped under $\kall{cphCreated}{\begin{array}{@{}c@{}}{\kall{}{}... \ \kall{}{}}\end{array}}$ :

\begin{itemize}
\item $\kall{enclosingClass}{ClassType}$ -- the directly enclosing class, for inner classes. The value noClass fr top-level classes.
\item $\kall{rawExtends}{K}$ -- The extends clause of this class, in its original AST form.
\item $\kall{rawImplements}{K}$ -- The implements clause, in AST form.
\item $\kall{rawDeclarations}{K}$ -- The class body, in AST form.
\item $\kall{cuImports}{Map[Id\mapsto{}ClassType]}$ -- For top-level classes, the content of the cell $\kall{compUnitImports}{}$ for this compilation unit. For inner classes - an empty map. With this cell, each top-level class have access to the names map required to resolve its extends/implements clauses.
\end{itemize}

As we can see, the cells saved during the class phase Created contain all the data of the original class AST. Thus, initial AST representation of the program is no longer needed. In fact, the cell $\kall{program}{}$ is discarded at the end of Process Compilation Units. Future preprocessing phases will use class data in this initial form to compute other cells within $\kall{class}{}$, finally used for execution.

Next phase is Process Class Declarations. Here each class passes through two more class phases: Bases Processed and Declarations Processed. First, for each class the semantics attempts to resolve its extends/implements clauses into fully qualified class names. The order in which dependencies are resolved depends on both class inheritance relationships as well as nesting relationships. Once the dependencies of a class are resolved, they are stored into a temporary cell:

\begin{itemize}
\item $\kall{unprocessedBases}{K}$ -- Initialized with the list of fully qualified class names for classes mentioned in extends/implements clauses of this class.
\end{itemize}

Once $\kall{unprocessedBases}{K}$ are saved the class enters into the phase Bases Resolved. It then waits in this phase until all extends/implements classes reach the phase Declarations Processed. To determine this state the cell $\kall{unprocessedBases}{K}$ is used. Once a class reaches the phase Declarations Processed, it deletes itself from all the cells $\kall{unprocessedBases}{K}$ of other classes. Thus, when all extends/implements dependencies of a class reach the phase Declarations Processed, the content of the cell $\kall{unprocessedBases}{K}$ of this class will be empty. Once in this state, the class enters into the phase Declarations Processed itself and computes three more cells:

\begin{itemize}
\item $\kall{extends}{ClassType}$ -- The base class, fully qualified.
\item $\kall{implements}{Set[ClassType]}$ -- The list of directly implemented interfaces, fully qualified.
\item $\kall{imports}{Map[Id\mapsto{}ClassType]}$ -- The map of classes accessible by simple name within the body of this class. The rules for computing this map are complex and include the following sources:

\begin{itemize}
\item Imports declarations of the current compilation unit, for top-level classes.
\item Classes within the same package as this class, for top level classes.
\item Classes accessible within the body of the directly enclosing class, for inner classes.
\item Inner classes inherited from base classes, e.g. from extends/implements clauses.
\item Inner classes of this class itself.
\end{itemize}

The need to cover all these cases leads to the intricate order in which class dependencies are resolved.
\end{itemize}

When a class enters the phase Declarations Processed, the cells $\kall{rawExtends}{}$, $\kall{rawImplements}{}$ and $\kall{unprocessedBases}{K}$ are no longer needed and are discarded. Once all classes reach the phase Declarations Processed the computation proceeds to the next global phase.

During the global phase Process Class Members each class processes its members and reaches the state Members Processes. Until then the class body is stored inside $\kall{rawDeclarations}{}$. The class members could be:

\begin{itemize}
\item fields
\item methods
\item constructors
\item static and instance initializers
\end{itemize}

Based on this data, the following cells are computed:

\begin{itemize}
\item $\kall{implTrans}{Set[ClassType]}$ -- The transitive closure of implemented interfaces. In the remaining phases this set is used by the subtyping relationship.
\item $\kall{methods}{Map[Signature\mapsto{}ClassType]}$ -- The map from method signatures to classes where they are defined. This cell includes all methods accessible within this class, or through a qualified expression of type this class. This includes both methods declared within this class as well as inherited from base classes/ base interfaces.
\item $\kall{methodDecs}{Map[Signature\mapsto{}MethodClosure]}$ -- The map from method signatures to actual method implementations. This cell includes only methods defined within the body of the present class.
\item $\kall{fieldDecs}{K}$ -- The list of instance field declarations, converted into local variable declaration statements, without initializers. Used as part of object instantiation.
\item $\kall{instanceEnv}{Map[Id\mapsto Field Entry]}$ -- the same fields as in $\kall{fieldDecs}{}$ but in a different form. Used in the elaboration phase.
\item $\kall{instanceInit}{K}$ -- The list of instance initializers of the class combined into one big instance initializer. Instance field initializers are also concatenated into this cell in their textual order. The content of this cell is executed as part of object instantiation.
\item $\kall{staticEnv}{Map[Id \mapsto Location]}$ -- The map from static fields declared in this class to their locations in the store. Since static fields have only one instance per class declaration, once such a field declaration is reached a location in the store is immediately allocated for it.
\item $\kall{staticInit}{K}$ -- The list of static initializers and static field initializers concatenated into a big one. Invoked during class static initialization.
\item $\kall{constantEnv}{Map[Id \mapsto Value]}$ -- The map from constants to their actual values. Constants in Java have a slightly different semantics compared to final static fields. In particular, accessing them don't trigger static initialization of the declaring class.
\end{itemize}

Once all the cells above are computed the class proceeds into the phase Members Processed and the cell $\kall{rawDeclarations}{}$ is deleted.

\pagebreak
*/
