module CONFIGURATION-PREP
    imports CORE-SORTS
    imports CORE-FUNCTIONS

/*@
The Static semantics consists of several phases that analyze the input program, distribute it from the AST form to a set of cells and finally assembles it back to an AST, this time containing just a subset of features of Java. Each phase digs deeper into a program strucutre, and most phases also store their result into new cells. Below is the list of global phases, in their execution order:

\begin{itemize}
	\item Process Type Names
	\item Process Compilation Units
	\item Process Class Declarations
	\item Process Class Members
	\item Elaboration
	\item Folding
\end{itemize}

The configuration cells may be divided into 2 categories: cells directly placed inside the all-enclosing cell \cellref{T} (top-level cells), and cells inside \cellref{classes}. The cell \cellref{classes} is a collection of \cellref{class} cells, each representing a Java class (both supported classes from JDK and classes defined by the developer). A \cellref{class} contains all components of a class --- such as extends/implements clauses, imports, fields, methods, etc, each distributed into a separate class, in order to be conveniently accessed when needed.

In the remaining of this section are documented all cells of the configuration, ordered by the global phase in which they are first used.

\paragraph{Initial state} The first row contains three cells most relevant to computation initial state:
\begin{itemize}
	\item \cellref[K]{k} --- Holds the current computation in all phases of the semantics. Initializes with the AST representation of the program.
	\item \cellref[K]{program} --- A backup of program AST. Required because the initial AST is needed in both 1st ans 2nd phase of static K-Java, but the first phase destroys the content inside \cellref{k}. Also used in the last phase (Folding) to assemble the preprocessed program.
	\item \cellref[GlobalPhase]{globalPhase} --- The current computation global phase.
\end{itemize}

\paragraph{Process Type Names} During this phase, one global cell is computed:
\begin{itemize}
	\item \cellref[Map{[}PackageId\mapsto{}Map{[}Id\mapsto{}ClassType{]}{]}]{namesToClasses} A two-level map. First level is a map from package names to second-level maps. Second-level maps are from simple class names to fully qualified class names within the package. This cell is extensively used through the semantics. The map contains both top-level and inner classes. For inner classes, their enclosing package is the fully qualified class name of the directly enclosing class.
\end{itemize}

Also during Process Type Names classes are first registered. Again, both top-level and inner classes are covered. In a newly created \cellref[]{class} just a few sub-cells are initialized with data:

\begin{itemize}
	\item \cellref[ClassType]{classType} --- The fully qualified class name. The identifier of the class.
	\item \cellref[ClassMetaType]{classMetaType} --- Whether the type stored in this cell is class or interface. To avoid terminology superfluousness, we will refer hereafter to both classes and interfaces as "classes", making distinctions only when necessary.
	\item \cellref[ClassAccessMode]{classAccessMode} --- The access modifier of the class, either public or package.
	\item \cellref[ClassPhase]{classPhase} --- represents the state of this class. In addition to the global computation phase, each class has its own lifecycle phase. Class phases are required to keep track which classes were processed in the current global phase and which were not. During each global phase all classes should transition to a certain class phase. However, as we shall see, not all global phases change the state of the class. The class phases are:

	\begin{itemize}
		\item Discovered --- the initial phase. At the end of Process Type Names all classes are in the state "Discovered".
		\item Stored
		\item Bases Resolved
		\item Declaration Processed
		\item Members Processed
		\item Folded
	\end{itemize}

\end{itemize}

\paragraph{Process Compilation Units} At the beginning of this phase computation is again initialized with the initial AST from \cellref{program}. The following new cells are filled in inside each \cellref{class}:

\begin{itemize}
	\item \cellref[ClassType]{enclosingClass} -- the directly enclosing class, for inner classes, or no value for top-level classes.
	\item \cellref[K]{rawExtends} -- The extends clause of this class, in its raw (AST) form.
	\item \cellref[K]{rawImplements} -- The implements clause, in AST form.
	\item \cellref[K]{rawDeclarations} -- The class body, in AST form.
	\item \cellref[Map{[}Id\mapsto{}ClassType{]}]{cuImports} -- A map from names accessible inside this class to fully qualified class names they represent. Only computed for top-level classes at this phase. For inner classes this cell remains empty.
	\item \cellref[ContextType]{classContextType} --- Either static or instance, for inner classes. Always static for top-level classes.
\end{itemize}

The class phase changes from Discovered to Stored. As we can see, the cells computed so far contain all the data of the original program. Thus, initial AST representation of the program is no longer needed. In fact, the cell \cellref[]{program} is discarded at the end of Process Compilation Units. The remaining preprocessing phases will use class data in this initial form to compute other cells within \cellref[]{class}, finally used for execution.


Also during Process Compilation Units the following global cell is used:

\begin{itemize}
	\item \cellref[Map{[}Id\mapsto{}ClassType{]}]{compUnitImports} A map from all type names accessible in the current compilation unit (Java file) to their respective fully qualified class names. This includes both classes accessible through imports declarations and classes declared in the package of the current compilation unit. Used to compute \cellref{cuImports} of top-level classes.
\end{itemize}

\paragraph{Process Class Declarations} Here each class passes through two more class phases: Bases Processed and Declarations Processed. First, for each class the semantics attempts to resolve its extends/implements clauses into fully qualified class names. The order in which dependencies are resolved depends on both class inheritance relationships as well as nesting relationships. Once the dependencies of a class are resolved, they are stored into a temporary cell:

\begin{itemize}
\item \cellref[K]{unprocessedBases} -- Initialized with the list of fully qualified class names for classes mentioned in extends/implements clauses of this class.
\end{itemize}

Once the content of \cellref[K]{unprocessedBases} is created, the class enters into Bases Resolved phase. It then waits in this phase until all classes referred in extends/implements reach the phase Declarations Processed. The restrictions in JLS related to class dependencies guarantee that classes cannot have cyclic dependencies, thus a class cannot get locked in the waiting state. The cell \cellref[K]{unprocessedBases} is used to determine the moment when the class may exit the waiting state. Once a class reaches the phase Declarations Processed, is is deleted from cells \cellref[K]{unprocessedBases} of other classes. Thus, when all extends/implements dependencies of a class reach the phase Declarations Processed, the content of the its \cellref[K]{unprocessedBases} cell becomes empty. Once in this state, the class enters into the phase Declarations Processed itself and computes three more cells:

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

During Process Class Declarations the following global cell is first used:
\begin{itemize}
	\item \cellref[ClassType]{crntClass} --- The current class. Used in multiple phases starting from Process Class Declarations.
\end{itemize}

\paragraph{Process Class Members} During this phase each class processes its members and reaches the state Members Processes. Until then, the class body is stored in \cellref[]{rawDeclarations}. A class member could be one of:

\begin{itemize}
	\item field
	\item method
	\item constructor
	\item static or instance initializer
\end{itemize}

The following new class cells are produced:

\begin{itemize}
	\item \cellref[Set{[}ClassType{]}]{implTrans} -- The transitive closure of implemented interfaces. In the remaining phases this set is used by the subtyping relationship.
  \item \cellref[ Map {[} Signature \mapsto ClassType {]} ]{methods} --- The map of accessible methods. Keys are method signatures, values are classes where methods are defined. Includes both methods declared within this class as well as methods inherited from base classes/ base interfaces.
  \item \cellref[Bag]{methodDecs} --- the collection of method declarations (\cellref{methodDec} cells)in the current class. This cell contains only a subset of methods from \cellref{methods}, as the set of accessible methods from \cellref{methods} also includes methods inherited from base classes/interfaces. Hence the need of two separate collections. Each \cellref[Bag]{methodDec} contains the following data:
  \begin{itemize}
    \item \cellref[Signature]{methodSignature} --- The method signature, acting as identifier of the \cellref{methodDec}
		\item \cellref[Type]{methodReturnType} --- Method return type
    \item \cellref[ List{[} Param {]} ]{methodParams} --- method parameters
    \item \cellref[K]{methodConstrFirstLine} --- the first line of a constructor (if this method is indeed a constructor, for other classes than \verb|Object|). It contains a call to another constructor: either \verb|super()| or \verb|this()|.
		\item \cellref[K]{methodBody} --- method body
    \item \cellref[AccessMode]{methodAccessMode} --- method access mode
    \item \cellref[ContextType]{methodContextType} --- either static or instance
		\item \cellref[MethodMetaType]{methodMetaType} --- either method or constructor
  \end{itemize}
  \item \cellref[K]{instanceFields} --- The list of instance field declarations, stored as a list of local variable declaration statements, without initializers. Used during object instantiation.
	\item \cellref[K]{instanceInit} -- The list of instance initializers of the class combined into one big instance initializer. Instance field initializers are also concatenated into this cell in their textual order.
  \item \cellref[K]{staticFields} --- The list of static field declarations, in a similar format to \cellref{instanceFields}
   \item \cellref[K]{staticInit} --- The list of static initializers and static field initializers concatenated into one block.
	\item \cellref[Map{[}Id \mapsto Value{]}]{constantEnv} -- The map from compile-time constants to their actual values. Constants in Java have a slightly different semantics compared to final static fields. In particular, accessing them don't trigger static initialization of the declaring class.
\end{itemize}

Once all the cells above are computed the class proceeds into the phase Members Processed and the cell \cellref[]{rawDeclarations} is deleted.

\paragraph{Elaboration} Here all the code blocks are processed --- method and constructor bodies, static and instance initializers. Most of the information traditionally inferred by the compiler is computed at this phase. More precisely the elaboration performs the following transformations:

\begin{itemize}
\item Each name is resolved into local variable, field, method, class or package. While a method may be distinguished from other cathegories purely syntactically, resolving to other categories requires knowledge of the names existing in the current context.
\item Simple class names are resolved into fully qualified class names. Hereafter all the class names in the code are fully qualified.
\item The compile-time type of each expression is inferred. Thus, when the code reaches execution phase, expressions are no longer in their initial form. The expressions are annotated with their types.
\item For each method call the precise signature in inferred.
\item Local and anonymous classes are processed. The earliest phase where local classes could be discovered is elaboration. Still, local classes have all the features of other classes. Thus they need to be passed through all the preprocessing steps. The whole preprocessing for local classes is performed during the global phase elaboration.
\end{itemize}

Despite this phase being the most complex preprocessing phase of all, it introduces few new cells. Most of them are related to local classes. Inside \cellref[]{class} just one new cell is introduced:

\begin{itemize}
\item \cellref[Map{[}Id \mapsto Type{]}]{enclosingLocalEnv} --- The map from local variables of the current block to their types. Used during local classes processing.
\end{itemize}

Among global cells the following new cells are added:

\begin{itemize}
	\item \cellref[List[mapWrap(Map[Id \mapsto Type])]]{elabEnv} --- A stack where each layer is a map of local variables. Each layer of the stack represents a code block, in the blocks nesting order. Inside each layer, the map is from local variables accessible in that layer to variable types.
	\item \cellref[Int]{contextType} --- The context type of the currently elaborated class. Either static or instance.
	\item \cellref[List[mapWrap(Map[Id \mapsto ClassType])]]{localTypes} --- A cell similar in structure to \cellref{elabEnv}. This time it contains stack layers which are maps from local class names to local class types.
	\item \cellref[Int]{nextLocalId} --- a number used to generate unique fully-qualified class names for local classes.
	\item \cellref[K]{elabBuffer} --- a temporary cell used during elaboration of local classes.
\end{itemize}

During the elaboration phase no cells are consumed. Instead, the code blocks stored inside \cellref[]{methodDecs}, \cellref[]{instanceInit}, \cellref[]{staticInit} are processed and stored back into the same cell. After elaboration the classes remain in the same state --- Members Processed. The state Members Processed is in fact the final state of the cell \cellref[]{class}.

\paragraph{Folding} During the last phase of static semantics the program is assembled from \cellref{classes} back into the AST form. First the content of each class is assembled into \cellref[K]{folded} of the respective class, and the class phase changes to Folded. Second, the AST representation of each class is appended into \cellref{program}. When this phase ends, the content of \cellref{program} is printed to the standart output.
*/

configuration
    <T>
      //Initial cells, loaded by krun and initial configuration.

      <k color="Green"> $PGM:K </k>

      //The initial program loaded by krun. For full mode and preprocessing this is
      //the initial java program, for execution mode it is the folded java program.
      <program color="LightSteelBlue"> $PGM:K </program>

      <globalPhase color="YellowGreen"> ProcTypeNamesPhase </globalPhase>

      <br/>
      <br/>
      //Global phase Process Type Names

      //cell type: Map[PackageId->Map[Id->ClassType]], Id = simple name, ClassType = full name
      //Computed during ProcTypeNamesPhase. Used in all the elaboration phases.
      <namesToClasses color="OrangeRed"> .Map </namesToClasses>

      <br/>
      <br/>
      //Global phase Process Compilation Units

      //Types imported by the current compilation unit. Created in module PROCESS-IMPORTS, part of
      //ProcCompUnitsPhase. Used in ProcCompUnitsPhase when imports for a compilation unit are computed,
      //and in ProcClassDecsPhase, when they are used to lookup extends/implements clauses.
      //Type: Map[Id -> ClassType]
      <compUnitImports color="LightCoral"> .Map </compUnitImports>

      <br/>
      <br/>
      //Global phase Process Class Decs

      //current class during all phases, including early preprocessing
      <crntClass color="DarkOrange"> noClass </crntClass>

      <br/>
      <br/>
      //Global phase Elaboration

      //The local variable environment, created and used during elaboration phase.
      //Represents a stack. Each ListItem contains a Map[Id -> Type]
      <elabEnv color="Orange"> ListItem(mapWrap(.Map)) </elabEnv>

      /*Current method/block context type - either staticCT or instanceCT
      Used both during elaboration*/
      <contextType color="DarkOrange"> staticCT </contextType>

      //The global registry of all local classes
      //When a local class is first encountered in the elaboration phase, a global class name is generated for it
      //and the class is registered in this map.
      //Type: Map[Id->ClassType] - map from simple local names to global names.
      //Used in elaboration phase.
      <localTypes color="Orange"> ListItem(mapWrap(.Map)) </localTypes>

      //Counter used to generate unique package names for local classes. Elaboration phase only.
      <nextLocalId color="Orange"> 1 </nextLocalId>

      //A list of terms that are collected during elaboration phase by a call to appendToElabBuffer()
      //and are restored back to <k> by a call to loadElabBuffer()
      <elabBuffer> [.KList] </elabBuffer>

      <br/>
      <br/>

      <classes color="Red">
        <class multiplicity="*" color="Red">

          //Class phase Discovered

          //sort ClassType. Contains the fully qualified class name.
          <classType color="Red"> .K </classType>

          //Either classMetaT or interfaceMetaT. Used in many semantics phases, including execution.
          <classMetaType color="Maroon"> .K </classMetaType>

          //Class access mode - either public or package.
          <classAccessMode color="Maroon"> .K </classAccessMode>

          //The major phase of <class> lifecycle. See ClassPhase definition.
          <classPhase color="Maroon"> .K </classPhase>

          <br/>
          <br/>
          //Class phase Stored

          //Used by object instantiation
          //noClass if this is a top-level class,
          //ClassType of the enclosing class otherwise
          <enclosingClass color="DarkGoldenrod"> noClass </enclosingClass>

          <rawExtends color="DarkGoldenrod"> .K </rawExtends>
          <rawImplements color="DarkGoldenrod"> .K </rawImplements>

          //The list of class members, in their raw form.
          <rawDeclarations color="DarkGoldenrod"> .K </rawDeclarations>

          //Created in ProcCompUnitsPhase, used in ProcClassDecsPhase
          <cuImports color="DarkGoldenrod"> .Map </cuImports> //imports of the enclosing CU, for top-level classes only.

          //Either staticCT or instanceCT
          <classContextType color="DarkGoldenrod"> .K </classContextType>


          <br/>
          <br/>
          //Class phase Bases Resolved

          <unprocessedBases color="Olive"> .K </unprocessedBases>

          <br/>
          <br/>
          //Class phase Decs Processed

          //The base class, or noClass for interfaces and Object.
          <extends color="SpringGreen"> .K </extends>

          /*Directly implemented interfaces, the resolved content of implements clause.
            Only used during preprocessing. Mostly to compute <implTrans>, and when transitive list of
            interfaces is not needed.*/
          <implements color="SpringGreen"> .Set </implements>

          /*Map[Id -> ClassType]. Map of classes accessible by simple name inside this class.
            Used by type resolution in elaboration phase.*/
          <imports color="SpringGreen"> .Map </imports>

          <br/>
          <br/>
          //Class phase Members Processed

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
              <methodSignature> .K </methodSignature>

              //Method return type
              <methodReturnType> .K </methodReturnType>

              //Method params
              <methodParams> .Params </methodParams>

              // first line, constructors only. Either of:
              //   'SuperInv - superclass constructor invocation
              //   'AltConstrInv - alternate this class constructor invocation
              //   .K - none, if this class is Object
              //   For methods this argument is noValue
              //The content of this cell is moved into method body during elaboration.
              <methodConstrFirstLine> .K </methodConstrFirstLine>

              //Method body
              <methodBody> .K </methodBody>

              <methodAccessMode> .K </methodAccessMode>

              //Either staticCT or instanceCT
              <methodContextType> .K </methodContextType>

              //Either methodMMT or constructorMMT
              <methodMetaType> .K </methodMetaType>

            </methodDec>
          </methodDecs>

          <br/>
          <br/>

          //[...,, 'LocalVarDec(_),, ...] - Instance field declarations. Used during object instantiation.
          <instanceFields color="Indigo"> [.KList] </instanceFields>

          /*Contains concatenated instance initializer blocks and instance field initializers.
            At the end of class processing in the ProcClassMembersPhase the content of this cell is converted into
            the method $instance_init and the cell is deleted. This conversion is required for local classes,
            see test local_cl_955. */
          <instanceInit color="Indigo"> [.KList] </instanceInit>

          //[...,, 'FieldDec('Static(_),,T,,_),, ...] - Static field declarations. Used during class instantiation.
          <staticFields color="DarkSlateGray"> [.KList] </staticFields>

          //The sequence of static initializers (that also includes field initializers)
          //see static-init.k for more details.
          <staticInit color="DarkSlateGray"> [.KList] </staticInit>

          //The map of compile-time constant fields. We consider compile-time constants only final static fields
          //initialized with a literal expression.
          //Constant references are replaced by their values during elaboration phase.
          //Created during process classes phase.
          //Map[Id -> TypedVal]
          <constantEnv color="DarkSlateGray"> .Map </constantEnv>

          <br/>
          <br/>
          //Global phase Elaboration

          //For local classes only. Map[Id -> Type] of vars accessible from the DIRECT enclosing local env.
          //If we have more levels of Local classes nesting, more external local environments
          //will be attached to more external classes.
          //Used during elaboration phase only.
          <enclosingLocalEnv color="Teal"> .Map </enclosingLocalEnv>

          <br/>
          <br/>
          //Global phase Folding

          //The whole class folded back into a 'ClassDec(...) node
          <folded color="Teal"> .K </folded>

        </class>
      </classes>
    </T>

endmodule
