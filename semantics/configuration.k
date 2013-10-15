require "core.k"

//@ \section{Module CONFIGURATION}

module CONFIGURATION
    imports CORE

/*@
The configuration is divided into three large cell groups. The group $\kall{threads}{}$ contains one or multiple cells $\kall{thread}{}$. Here is the data related to the execution of a thread, such as the computation, stack, local environment. The second group
is contained inside $\kall{classes}{}$ that have multiple $\kall{class}{}$ cells -- anything class-related.
What remains are the top-level cells -- the third group. Top-level cells are related to memory store,
global thread-synchronization data and auxiliary cells for debugging.

Some cells in this configuration are not used within the rules. They serve only for grouping other cells by context. Grouping cells are colored yellow, whereas actual semantics cells have other colors.

From the evaluation standpoint, the semantics is divided into several preprocessing phases followed by the actual program execution.
Preprocessing phases are roughly equivalent to java compilation. They perform all the computations that would be traditionally expected from the compiler. The evaluation phases are:

\begin{itemize}
\item Process type names
\item Process compilation units
\item Process class declarations
\item Process classes
\item Elaboration
\item Execution
\end{itemize}

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

\pagebreak
*/
configuration
    <T>
      <threads color="GreenYellow">
        <thread multiplicity="*" color="GreenYellow">
          <k color="Green"> $PGM:K </k>

          <stack color="Green"> .List </stack>

          //! \smallskip
          <br/>

          /*The execution context of the current method - local names environment, return type,
            context type and current object.*/
          <methodContext color="Orange">

            <envGroup color="Yellow">

              //The map from local vars to their location in the store. Also includes outer local vars, for local classes.
              <env color="Crimson"> .Map </env>

              /* Map[Id -> mapWrap(Map[Id -> Loc])]
              A map associating to any local class accessible in this environment its outer local environment.
              The local environment is determined in the place where the class is declared.
              When a local class is instantiated, its enclosing environment is taken from this map.
              This cell have the same lifecycle as <env>, that is why they are both grouped to <envGroup>*/
              <localClassesEnv color="Crimson"> .Map </localClassesEnv>
            </envGroup>

            <br/>
            <return color="DarkOrange"> void </return> // holds method return type

            /*Current method/block context type - either staticCT or instanceCT
            Used both during elaboration and execution*/
            <contextType color="DarkOrange"> staticCT </contextType>

            <br/>
            <crntObj color="DarkOrange">
              //current class during all phases, including early preprocessing
              <crntClass color="DarkOrange"> noClass </crntClass>

              <location color="DarkOrange" multiplicity="?"> .K </location>
            </crntObj>
          </methodContext>

          <br/>

          //Multithreading-related cells
          <threadData color="Yellow">

            //Thread Id
            <tid color="BlueViolet"> 0 </tid>

            //Map[OL |-> Count] - the amount of times this thread holds the monitor objects referred bu the keys
            <holds color="BlueViolet"> .Map </holds>

            //Whether this thread was interrupted by another thread by a call to Thread.interrupt()
            <interrupted color="BlueViolet"> false </interrupted>

          </threadData>
        </thread>
      </threads>

      <br/>
      <br/>

      <classes color="Red">
        <class multiplicity="*" color="Red">

          //sort ClassType. Contains the fully qualified class name.
          <classType color="Red"> .K </classType>

          //Either classMetaT or interfaceMetaT. Used in many semantics phases, including execution.
          <metaType color="Maroon"> .K </metaType>

          //The major phase of <class> lifecycle. See ClassPreprocessingPhase definition.
          <preprocessingPhase color="Maroon"> .K </preprocessingPhase>

          <br/>

          <cppCreated color="Yellow">

            //Used by object instantiation
            <enclosingClass color="DarkGoldenrod"> noClass </enclosingClass> //noClass if this is a top-level class,
                                                       //ClassType of the enclosing class otherwise

            <rawExtends color="DarkGoldenrod"> .K </rawExtends>
            <rawImplements color="DarkGoldenrod"> .K </rawImplements>

            <br/>

            //The list of class members, in their raw form.
            <rawDeclarations color="DarkGoldenrod"> .K </rawDeclarations>

            //Created in ProcessCompUnitsPhase, used in ProcessClassDecsPhase
            <cuImports color="DarkGoldenrod"> .Map </cuImports> //imports of the enclosing CU, for top-level classes only.

          </cppCreated>

          <br/>

          <cppBases color="Yellow">
            <unprocessedBases color="Olive"> .K </unprocessedBases>//base classes that didn't
                                                     //reached the state DecsProcessedCPP yet.
          </cppBases>

          <br/>

          <cppDecs color="Yellow">

            //The base class, or noClass for Object. For interfaces: Object.
            <extends color="SpringGreen"> .K </extends>

            /*Directly implemented interfaces, the resolved content of implements clause.
              Only used during preprocessing. Mostly to compute <implTrans>, and when transitive list of
              interfaces is not needed.*/
            <implements color="SpringGreen"> .Set </implements>

            /*Map[Id -> ClassType]. Map of classes accessible by simple name inside this class.
              Used by type resolution in elaboration phase.*/
            <imports color="SpringGreen"> .Map </imports>

          </cppDecs>

          <br/>

          <cppMembers color="Yellow">

            //Transitively implemented interfaces. Used by subtyping rules.
            <implTrans color="DeepPink"> .Set </implTrans>

            /*Signatures of methods accessible to this class (both declared and inherited)
              Map[Sig -> Class]
              Used in elaboration of method calls.*/
            <methods color="Blue"> .Map </methods>

            /*All methods declared in this class. Map[Sig -> methodClosure :: MethodType ]
              Used in elaboration of method calls.*/
            <methodDecs color="Blue"> .Map </methodDecs>

            <br/>

            //a "ListWrap containing a 'LocalVarDec for each field. Used during object instantiation.
            <fieldDecs color="Indigo"> 'ListWrap(.KList) </fieldDecs>

            /*The map of instance fields declared in this class, but not in superclasses.
              Map[Id -> fieldEntry(Class, X, T, ContextType)] (declaring class, field name, field type)
              created in ProcessClassesPhase along with <fieldDecs>, used in elaboration phase.*/
            <instanceEnv color="Indigo"> .Map </instanceEnv>

            <br/>

            /*Contains concatenated instance initializer blocks and instance field initializers.
              Used by constructor invocation elaboration.*/
            <instanceInit color="Indigo"> 'ListWrap(.KList) </instanceInit>

            <br/>

            /*The map of static fields declared in this class only, and NOT in superclasses or superinterfaces.
              Map[Id -> Location]
              Used during object instantiation.*/
            <staticEnv color="DarkSlateGray"> .Map </staticEnv>

            //The sequence of static initializers (that also includes field initializers)
            //see static-init.k for more details.
            <staticInit color="DarkSlateGray"> 'ListWrap(.KList) </staticInit>

            //The map of compile-time constant fields. We consider compile-time constants only final static fields
            //initialized with a literal expression.
            //Constant references are replaced by their values during elaboration phase.
            //Created during process classes phase.
            //Map[Id -> TypedVal]
            <constantEnv color="DarkSlateGray"> .Map </constantEnv>

          </cppMembers>

          <br/>

          //Cells used during elaboration phase
          <clsElab color="Yellow">

            //For local classes only. Map[Id -> Type] of vars accessible from the DIRECT enclosing local env.
            //If we have more levels of Local classes nesting, more external local environments
            //will be attached to more external classes.
            //Used during elaboration phase only.
            <enclosingLocalEnv color="Teal"> .Map </enclosingLocalEnv>

          </clsElab>

          <br/>

          //Cells used during execution phase
          <clsExec color="Yellow">

            //Initialization status of this class. See static-init.k for more details.
            //Only used during execution phase.
            <staticInitStatus color="Teal"> StaticUninitialized </staticInitStatus>

          </clsExec>

        </class>
      </classes>

      <br/>
      <br/>

      <computationPhase  color="YellowGreen"> ProcessTypeNamesPhase </computationPhase>

      <br/>

      <phStart color="Yellow">

        //required in ProcessCompUnitsPhase
        <programBackup color="LightSteelBlue"> $PGM:K </programBackup>

        //Main class, passed as krun argument. We need it from the outside, just like JDK Java.
        <mainClass color="LightSteelBlue"> $MainClass:ListItem </mainClass>

      </phStart>

      <br/>

      <phTN color="Yellow">

        //cell type: Map[PackageId->Map[Id->ClassType]], Id = simple name, ClassType = full name
        //Computed during ProcessTypeNamesPhase. Used in all the elaboration phases.
        <typeNamesMap color="OrangeRed"> .Map </typeNamesMap>

        //cell type: Map[ClassType->AccessMode]
        //Computed during ProcessTypeNamesPhase. Used in ProcessCompUnitsPhase, module PROCESS-IMPORTS
        <classesToAccessModes color="OrangeRed"> .Map </classesToAccessModes>

      </phTN>

      <br/>

      <phCU color="Yellow">

        //Types imported by the current compilation unit. Created in module PROCESS-IMPORTS, part of
        //ProcessCompUnitsPhase. Used in ProcessCompUnitsPhase when imports for a compilation unit are computed,
        //and in ProcessClassdecsPhase, when they are used to lookup extends/implements clauses.
        //Type: Map[Id -> ClassType]
        <compUnitImports color="LightCoral"> .Map </compUnitImports>

      </phCU>

      <br/>

      <phElab color="Yellow">

        //The local variable environment, created and used during elaboration phase.
        //Represents a stack. Each ListItem contains a Map[Id -> Type]
        <elabEnv color="Orange"> ListItem(stEnv(.Map)) </elabEnv>

        //The global registry of all local classes
        //When a local class is first encountered in the elaboration phase, a global class name is generated for it
        //and the class is registered in this map.
        //Type: Map[Id->ClassType] - map from simple local names to global names.
        //Used in elaboration phase.
        <localTypes color="Orange"> ListItem(stEnv(.Map)) </localTypes>

        //Counter used to generate unique package names for local classes. Elaboration phase only.
        <nextLocalId color="Orange"> 1 </nextLocalId>

      </phElab>

      <br/>

      <phExec color="Yellow">

        //Execution memory. Map[Location:Int->Value:TypedVal]. Both local vars and heap vars are stored here.
        <store color="Cyan"> .Map </store>

        //Counter for next location to be used in the cell <store>.
        <nextLoc color="Cyan"> 0 </nextLoc>

        //Standard input. Each token is a ListItem.
        <in color="LightPink" stream="stdin"> .List </in>

        //Standard output. Each token is a ListItem.
        <out color="LightPink" stream="stdout"> .List </out>

        //A map from types to objectClosure() terms that represent their T.class value
        //Created an used in execution phase, by expressions of the form X.class
        //Type: Map[Type->TypedVal]. Type may be any reference type.
        <classLiteralsMap color="LightPink"> .Map </classLiteralsMap>

        <br/>

        //Set[OL:Int] - the set of locations of used monitor objects
        <busy color="LightGreen"> .Set </busy>

        //Map[ThreadId:Int |-> OL:Int] - map from threads to objects they are waiting on
        //waiting on those objects used by methods Object.wait(), Object.notify(), Object.notifyAll().
        <waitingThreads color="LightGreen"> .Map </waitingThreads>

        <terminated color="LightGreen"> .Set </terminated>

      </phExec>

      <br/>

      //Cells used for debugging. Not related to the semantics.
      <groupDebug color="Yellow">

        <dissolveEmptyK> true </dissolveEmptyK>
        <dissolveClasses> true </dissolveClasses>

        //When computation finishes, dissolve all cells except <out>,
        //in order to avoid duplicate solutions during model checking.
        <dissolveAllExceptOut> $ModelCheck:Bool </dissolveAllExceptOut>

        <debug> .List </debug>

      </groupDebug>
    </T>

endmodule
