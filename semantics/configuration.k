require "core.k"

//@ \section{Module CONFIGURATION}

module CONFIGURATION
    imports CORE

configuration
    <T color="red">
      <threads color="orange">
        <thread multiplicity="*" color="yellow">
          <k color="green"> $PGM:K </k>
          <envGroup>

            //The map from local vars to their location in store. Also inclused outer lcoal ars, for local classes.
            <env color="violet"> .Map </env>

            //Map[Id -> mapWrap(Map[Id -> Loc])]
            //A map associating to any local class accessible in this environment its outer local environment.
            //The local environment is determined in the place where the class is declared.
            //When a local class is instantiated, its enclosing environment is taken from this map.
            //This cell have the same lifecycle as <env>, that is why they are both grouped to <envGroup>
            <localClassesEnv> .Map </localClassesEnv>
          </envGroup>

          <br/>
          <control color="cyan">
            <stack color="blue"> .List </stack>
            <return color="LimeGreen"> void </return> // holds method return type

            //Current method/block context type - either staticCT or instanceCT
            //Used both during elaboration and execution
            <contextType> staticCT </contextType>
            <br/>
            <crntObj color="Fuchsia">
              //current class during all phases, including early preprocessing
              <crntClass> .K </crntClass>

              <location multiplicity="?"> .K </location>
            </crntObj>
          </control>

          <br/>
          //Threading-related cells

          //Thread Id
          <tid color="pink"> 0 </tid>

          //Map[OL |-> Count] - the amount of times this thread holds the monitor objects referred bu the keys
          <holds color="black"> .Map </holds>

          //Whether this thread was interrupted by another thread by a call to Thread.interrupt()
          <interrupted> false </interrupted>
        </thread>
      </threads>

      <br/>
      <store color="white"> .Map </store>
      <in color="magenta" stream="stdin"> .List </in>
      <out color="brown" stream="stdout"> .List </out>
      <nextLoc color="gray"> 0 </nextLoc>

      <br/>
      //cell type: Map[PackageId->Map[Id->ClassType]], Id = simple name, ClassType = full name
      <typeNamesMap> .Map </typeNamesMap>

      <classesToAccessModes> .Map </classesToAccessModes>

      <br/>
      <classes color="Fuchsia">
        <class multiplicity="*" color="Fuchsia">

          //sort ClassType. Contains the fully qualified class name.
          <classType color="Fuchsia"> .K </classType>

          //The base class, or noClass for Object. For interfaces: Object.
          <extends color="Fuchsia"> .K </extends>

          //Directly implemented interfaces, the resolved content of implements clause.
          <implements> .Set </implements>

          //Transitively implemented interfaces.
          <implTrans> .Set </implTrans>

          <br/>

          <rawExtends> .K </rawExtends>
          <rawImplements> .K </rawImplements>
          <unprocessedBases> .K </unprocessedBases>//base classes that didn't
                                                   //reached the state DecsProcessedCPP yet.

          <br/>
          <declarations color="purple"> .K </declarations>

          //Either classMetaT or interfaceMetaT
          <metaType> .K </metaType>

          <br/>

          //'LocalVarDec for each field
          <fieldDecs color="purple"> 'ListWrap(.KList) </fieldDecs>

          //Signatures of methods accessible to this class (declared or inherited)
          //Map[sig -> Class]
          <methods color="purple"> .Map </methods>

          //All methods declared in this class. Map[sig -> methodClosure :: MethodType ]
          <methodDecs color="purple"> .Map </methodDecs>

          <br/>
          //The map of instance fields declared in this class, but not in superclasses.
          //Map[Id -> fieldEntry(Class, X, T, ContextType)] (declaring class, field name, field type)
          //Used in elaboration phase
          <instanceEnv> .Map </instanceEnv>

          <instanceInit> 'ListWrap(.KList) </instanceInit>

          //The map of static fields declared in this class only, and NOT in superclasses or superinterfaces.
          //Map[Id -> Location]
          <staticEnv> .Map </staticEnv>

          //The map of compile-time constant fields. We consider compile-time constants only final static fields
          //initialized with a literal expression.
          //Map[Id -> TypedVal]
          <constantEnv> .Map </constantEnv>

          <br/>
          //The sequence of static initializers (that also includes field initializers)
          <staticInit> 'ListWrap(.KList) </staticInit>

          //Initialization status of this class
          //see static-init.k for more details.
          <staticInitStatus> StaticUninitialized </staticInitStatus>

          <br/>
          <cuImports> .Map </cuImports> //imports of the enclosing CU, for top-level classes only.

          //Map[Id -> ClassType]. Map of classes accessible by simple name inside this class.
          <imports> .Map </imports>

          <br/>
          <enclosingClass> noClass </enclosingClass> //noClass if this is a top-level class,
                                                     //ClassType of the enclosing class otherwise

          //For local classes only. Map[Id -> Type] of vars accessible from the DIRECT enclosing local env.
          //If we have more levels of Local classes nesting, more external local environments
          //will be attached to more external classes.
          //Used during elaboration phase only.
          <enclosingLocalEnv> .Map </enclosingLocalEnv>

          <br/>
          //The major phase of <class> lifetime. See ClassPreprocessingPhase definition.
          <preprocessingPhase> .K </preprocessingPhase>
        </class>
      </classes>

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
      //Used in process-class-decs phase.
      <crntCuImports> .Map </crntCuImports>

      <computationPhase> ProcessTypeNamesPhase </computationPhase>
      //required in ProcessCompUnitsPhase
      <programBackup> $PGM:K </programBackup>

      <br/>

      //Set[OL:Int] - the set of locations of used monitor objects
      <busy color="cyan"> .Set </busy>

      //Map[ThreadId:Int |-> OL:Int] - map from threads to objects they are waiting on
      //waiting on those objects used by methods Object.wait(), Object.notify(), Object.notifyAll().
      <waitingThreads> .Map </waitingThreads>

      <terminated color="red"> .Set </terminated>

      <br/>

      <dissolveEmptyK> true </dissolveEmptyK>
      <dissolveClasses> true </dissolveClasses>

      //When computation finishes, dissolve all cells except <out>,
      //in order to avoid duplicate solutions during model checking.
      <dissolveAllExceptOut> $ModelCheck:Bool </dissolveAllExceptOut>

      <debug> .List </debug>
    </T>

endmodule
