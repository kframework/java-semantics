module CONFIGURATION
    imports CORE-SORTS
    imports CORE-FUNCTIONS

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

          //Class Phase Discovered

          //sort ClassType. Contains the fully qualified class name.
          <classType color="Red"> .K </classType>

          //Either classMetaT or interfaceMetaT. Used in many semantics phases, including execution.
          <classMetaType color="Maroon"> .K </classMetaType>

 	  //Class access mode - either public or package.
          <classAccessMode color="Maroon"> .K </classAccessMode>

          //The major phase of <class> lifecycle. See ClassPhase definition.
          <classPhase color="Maroon"> .K </classPhase>

          <br/>
          //Class Phase Created

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

          //The base class, or noClass for interfaces and Object.
          <extends color="SpringGreen"> .K </extends>

          /*Directly implemented interfaces, the resolved content of implements clause.
            Only used during preprocessing. Mostly to compute <implTrans>, and when transitive list of
            interfaces is not needed.*/
          <implements color="SpringGreen"> .Set </implements>

          /*Map[Id -> ClassType]. Map of classes accessible by simple name inside this class.
            Used by type resolution in elaboration phase.*/
          <imports color="SpringGreen"> .Map </imports>

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

	      <methodReturnType> .K </methodReturnType>

              //Method params
              <methodParams color="Blue"> .Params </methodParams>

	      // first line, constructors only. Either of:
              //   'SuperInv - superclass constructor invocation
              //   'AltConstrInv - alternate this class constructor invocation
              //   .K - none, if this class is Object
              //   For methods this argument is noValue
              //The content of this cell is moved into method body during elaboration.
              <methodConstrFirstLine> .K </methodConstrFirstLine>

              //Method body
              <methodBody color="Blue"> .K </methodBody>

              <methodAccessMode color="Blue"> .K </methodAccessMode>

              //Either staticCT or instanceCT
              <methodContextType color="Blue"> .K </methodContextType>

              //Either methodMMT or constructorMMT
              <methodMetaType> .K </methodMetaType>

            </methodDec>
          </methodDecs>

          <br/>
          <br/>

          //[...,, 'LocalVarDec(_),, ...] - Instance field declarations. Used during object instantiation.
          <instanceFields color="Indigo"> .ClassBodyDecList </instanceFields>
	  <instanceInit color="Indigo"> .BlockStmList </instanceInit>

          //[...,, 'FieldDec('Static(_),,T,,_),, ...] - Static field declarations. Used during class instantiation.
          <staticFields color="DarkSlateGray"> .ClassBodyDecList </staticFields>

          //The sequence of static initializers (that also includes field initializers)
          //see static-init.k for more details.
          <staticInit color="DarkSlateGray"> .BlockStmList </staticInit>

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

      <globalPhase color="YellowGreen"> ProcTypeNamesPhase </globalPhase>

      <br/>
      <br/>
      //Global Phase Execution

      //Execution memory. Map[Location:Int->Value:TypedVal]. Both local vars and heap vars are stored here.
      <store color="DarkCyan"> .Map </store>

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
      <objectStore color="Cyan" map="" >
        <object color="Cyan" multiplicity="*">

          //The id of this object. Same as store location for the newly created object reference.
          <objectId color="Cyan" key="" > .K </objectId>

          //The actual object class
          <objectType color="Cyan"> .K </objectType>

          //One layer for each class in the inheritance chain of this object
          <layer color="Cyan" multiplicity="*">

            //The class corresponding to the given chain
            <layerClass color="Cyan"> .K </layerClass>

            //Map[Id |-> Loc] -> fields defined in this layer
            <layerEnv color="Cyan"> .Map </layerEnv>

            //objectRef() ::_ - a reference to the directly enclosing object, or noValue if none.
            <layerEnclosingObject color="Cyan"> noValue:>KItem </layerEnclosingObject>
          </layer>
        </object>
      </objectStore>

      <arrayStore color="Cyan" map="" >
              <array color="Cyan" multiplicity="*">
                <arrayId color="Cyan" key="" > .K </arrayId>
                <arrayType color="Cyan"> .K </arrayType>
                <arraystore color="Cyan"> .Map </arraystore>
              </array>
      </arrayStore>

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
