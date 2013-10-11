require "core.k"

//@ \section{Module CONFIGURATION}

module CONFIGURATION
    imports CORE

//todo for now we organized the cells inside <class> based on the phase where they are used.
//It would make more sense to organize them based on when they are computed, to reflect the way the configuration
//evolves across phases.
configuration
    <T color="Red">
      <threads color="Orange">
        <thread multiplicity="*" color="GreenYellow">
          <k color="Green"> $PGM:K </k>

          <stack color="LimeGreen"> .List </stack>

          //! \smallskip
          <br/>

          //The execution context of the current method - local names environment, return type,
          //context type and current object.
          <methodContext color="LightBlue">

            <envGroup color="Yellow">

              //@The map from local vars to their location in the store. Also includes outer local vars, for local classes.
              <env color="LightBlue"> .Map </env>

              /*@ Map[Id -> mapWrap(Map[Id -> Loc])] */
              //A map associating to any local class accessible in this environment its outer local environment.
              //The local environment is determined in the place where the class is declared.
              //When a local class is instantiated, its enclosing environment is taken from this map.
              //This cell have the same lifecycle as <env>, that is why they are both grouped to <envGroup>
              <localClassesEnv color="LightBlue"> .Map </localClassesEnv>
            </envGroup>

            <br/>
            <return color="Cyan"> void </return> // holds method return type

            /*Current method/block context type - either staticCT or instanceCT
            Used both during elaboration and execution*/
            <contextType color="Cyan"> staticCT </contextType>

            <br/>
            <crntObj color="Fuchsia">
              //current class during all phases, including early preprocessing
              <crntClass color="Fuchsia"> .K </crntClass>

              <location color="Fuchsia" multiplicity="?"> .K </location>
            </crntObj>
          </methodContext>

          <br/>
          <br/>

          //Multithreading-related cells
          <threadData color="Yellow">

            //Thread Id
            <tid color="Pink"> 0 </tid>

            //Map[OL |-> Count] - the amount of times this thread holds the monitor objects referred bu the keys
            <holds color="Pink"> .Map </holds>

            //Whether this thread was interrupted by another thread by a call to Thread.interrupt()
            <interrupted color="Pink"> false </interrupted>

          </threadData>
        </thread>
      </threads>

      <br/>
      <br/>

      <classes color="Mahogany">
        <class multiplicity="*" color="Maroon">

          //Cells used during execution phase
          <clsExec color="Yellow">

            //sort ClassType. Contains the fully qualified class name.
            <classType color="Red"> .K </classType>

            //The base class, or noClass for Object. For interfaces: Object.
            <extends color="Fuchsia"> .K </extends>

            //Transitively implemented interfaces. Used by subtyping rules.
            <implTrans color="Lavender"> .Set </implTrans>

            //Used by object instantiation
            <enclosingClass color="Fuchsia"> noClass </enclosingClass> //noClass if this is a top-level class,
                                                       //ClassType of the enclosing class otherwise

            <br/>

            //Either classMetaT or interfaceMetaT. Used in many semantics phases, including execution.
            <metaType color="Brown"> .K </metaType>

            //a "ListWrap containing a 'LocalVarDec for each field. Used during object instantiation.
            <fieldDecs color="Blue"> 'ListWrap(.KList) </fieldDecs>

            //The map of static fields declared in this class only, and NOT in superclasses or superinterfaces.
            //Map[Id -> Location]
            //Used during object instantiation.
            <staticEnv color="Blue"> .Map </staticEnv>

            <br/>

            //The sequence of static initializers (that also includes field initializers)
            //see static-init.k for more details.
            <staticInit color="Salmon"> 'ListWrap(.KList) </staticInit>

            //Initialization status of this class
            //see static-init.k for more details.
            <staticInitStatus color="Salmon"> StaticUninitialized </staticInitStatus>

          </clsExec>

          <br/>
          <br/>

          //Cells used during elaboration phase
          <clsElab color="Yellow">

            //Directly implemented interfaces, the resolved content of implements clause.
            //Only used during preprocessing. Mostly to compute <implTrans>, and when transitive list of
            //interfaces is not needed.
            <implements color="Lavender"> .Set </implements>

            //Signatures of methods accessible to this class (both declared and inherited)
            //Map[Sig -> Class]
            //Used in elaboration of method calls.
            <methods color="SkyBlue"> .Map </methods>

            //All methods declared in this class. Map[Sig -> methodClosure :: MethodType ]
            //Used in elaboration of method calls.
            <methodDecs color="SkyBlue"> .Map </methodDecs>

            <br/>

            //The map of instance fields declared in this class, but not in superclasses.
            //Map[Id -> fieldEntry(Class, X, T, ContextType)] (declaring class, field name, field type)
            //Used in elaboration phase
            <instanceEnv color="Cyan"> .Map </instanceEnv>

            //Contains concatenated instance initializer blocks and instance field initializers.
            //Used by constructor invocation elaboration.
            <instanceInit color="Cyan"> 'ListWrap(.KList) </instanceInit>

            //The map of compile-time constant fields. We consider compile-time constants only final static fields
            //initialized with a literal expression.
            //Constant references are replaced by their values during elaboration phase.
            //Map[Id -> TypedVal]
            <constantEnv color="Cyan"> .Map </constantEnv>

            <br/>

            //Map[Id -> ClassType]. Map of classes accessible by simple name inside this class.
            //Used by type resolution in elaboration phase.
            <imports color="Cyan"> .Map </imports>

            //For local classes only. Map[Id -> Type] of vars accessible from the DIRECT enclosing local env.
            //If we have more levels of Local classes nesting, more external local environments
            //will be attached to more external classes.
            //Used during elaboration phase only.
            <enclosingLocalEnv color="Cyan"> .Map </enclosingLocalEnv>

          </clsElab>

          <br/>
          <br/>

          //Cells used in early preprocessing phases only
          <clsPrep color="Yellow">

            <rawExtends color="Goldenrod"> .K </rawExtends>
            <rawImplements color="Goldenrod"> .K </rawImplements>

            //The list of class members, in their raw form.
            <rawDeclarations color="Goldenrod"> .K </rawDeclarations>

            <br/>

            <unprocessedBases color="Goldenrod"> .K </unprocessedBases>//base classes that didn't
                                                     //reached the state DecsProcessedCPP yet.

            //Used in ProcessClassDecsPhase
            <cuImports color="Goldenrod"> .Map </cuImports> //imports of the enclosing CU, for top-level classes only.

          </clsPrep>

          <br/>
          <br/>

          //The major phase of <class> lifecycle. See ClassPreprocessingPhase definition.
          <preprocessingPhase color="Brown"> .K </preprocessingPhase>
        </class>
      </classes>

      <br/>
      <br/>
      //cell type: Map[PackageId->Map[Id->ClassType]], Id = simple name, ClassType = full name
      <typeNamesMap> .Map </typeNamesMap>

      <classesToAccessModes> .Map </classesToAccessModes>

      <br/>
      <br/>

      //Main class, passed as krun argument. We need it from the outside, just like JDK Java.
      <mainClass> $MainClass:ListItem </mainClass>

      <compUnitImports> .Map </compUnitImports>

      //A map from types to objectClosure() terms that represent their T.class value
      <classLiteralsMap> .Map </classLiteralsMap>
      <br/>

      //The local variables environment during elaboration
      //Represents a stack. each ListItem contains a Map[Id -> Type]
      <elabEnv> ListItem(stEnv(.Map)) </elabEnv>

      //Map of local classes, used only in the elaboration phase
      <localTypes> ListItem(stEnv(.Map)) </localTypes>

      //Used to generate unique package names for local classes
      <nextLocalId> 1 </nextLocalId>

      <br/>

      //The map of classes accessible by simple name for declarations within current compilation unit.
      //Used in ProcessClassDecsPhase.
      <crntCuImports> .Map </crntCuImports>

      <computationPhase> ProcessTypeNamesPhase </computationPhase>
      //required in ProcessCompUnitsPhase
      <programBackup> $PGM:K </programBackup>

      <br/>
      <br/>

      <store color="White"> .Map </store>
      <nextLoc color="Gray"> 0 </nextLoc>

      <in color="Magenta" stream="stdin"> .List </in>
      <out color="Brown" stream="stdout"> .List </out>

      <br/>
      <br/>

      //Set[OL:Int] - the set of locations of used monitor objects
      <busy color="Cyan"> .Set </busy>

      //Map[ThreadId:Int |-> OL:Int] - map from threads to objects they are waiting on
      //waiting on those objects used by methods Object.wait(), Object.notify(), Object.notifyAll().
      <waitingThreads> .Map </waitingThreads>

      <terminated color="Red"> .Set </terminated>

      <br/>
      <br/>

      <dissolveEmptyK> true </dissolveEmptyK>
      <dissolveClasses> true </dissolveClasses>

      //When computation finishes, dissolve all cells except <out>,
      //in order to avoid duplicate solutions during model checking.
      <dissolveAllExceptOut> $ModelCheck:Bool </dissolveAllExceptOut>

      <debug> .List </debug>
    </T>

endmodule
