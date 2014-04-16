require "core-sorts.k"
require "core-functions.k"
require "configuration-doc.k"

module CONFIGURATION
    imports CORE-SORTS
    imports CORE-FUNCTIONS

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

          <cphDiscovered color="Yellow">
            //sort ClassType. Contains the fully qualified class name.
            <classType color="Red"> .K </classType>

            //Either classMetaT or interfaceMetaT. Used in many semantics phases, including execution.
            <classMetaType color="Maroon"> .K </classMetaType>

            //Class access mode - either public or package.
            <classAccessMode color="Maroon"> .K </classAccessMode>

            //The major phase of <class> lifecycle. See ClassPhase definition.
            <classPhase color="Maroon"> .K </classPhase>

          </cphDiscovered>

          <br/>

          <cphCreated color="Yellow">

            //Used by object instantiation
            //noClass if this is a top-level class,
            //ClassType of the enclosing class otherwise
            <enclosingClass color="DarkGoldenrod"> noClass </enclosingClass>

            <rawExtends color="DarkGoldenrod"> .K </rawExtends>
            <rawImplements color="DarkGoldenrod"> .K </rawImplements>

            <br/>

            //The list of class members, in their raw form.
            <rawDeclarations color="DarkGoldenrod"> .K </rawDeclarations>

            //Created in ProcCompUnitsPhase, used in ProcClassDecsPhase
            <cuImports color="DarkGoldenrod"> .Map </cuImports> //imports of the enclosing CU, for top-level classes only.

            //Either staticCT or instanceCT
            <classContextType color="DarkGoldenrod"> .K </classContextType>

          </cphCreated>

          <br/>

          <cphBases color="Yellow">
            <unprocessedBases color="Olive"> .K </unprocessedBases>//base classes that didn't
                                                     //reached the state DecsProcessedCPhase yet.
          </cphBases>

          <br/>

          <cphDecs color="Yellow">

            //The base class, or noClass for interfaces and Object.
            <extends color="SpringGreen"> .K </extends>

            /*Directly implemented interfaces, the resolved content of implements clause.
              Only used during preprocessing. Mostly to compute <implTrans>, and when transitive list of
              interfaces is not needed.*/
            <implements color="SpringGreen"> .Set </implements>

            /*Map[Id -> ClassType]. Map of classes accessible by simple name inside this class.
              Used by type resolution in elaboration phase.*/
            <imports color="SpringGreen"> .Map </imports>

          </cphDecs>

          <br/>

          <cphMembers color="Yellow">

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
                <methodSignature> .K </methodSignature>

                //Method return type
                <methodReturnType> .K </methodReturnType>

                //Method params
                <methodParams> [.KList] </methodParams>

                // first line, constructors only. Either of:
                //   'SuperInv - superclass constructor invocation
                //   'AltConstrInv - alternate this class constructor invocation
                //   .K - none, if this class is Object
                //   For methods this argument is noValue
                <methodFirstLine> .K </methodFirstLine>

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

            //[...,, 'LocalVarDec(_),, ...] - Instance field declarations. Used during object instantiation.
            <fieldDecs color="Indigo"> [.KList] </fieldDecs>

            <br/>

            /*Contains concatenated instance initializer blocks and instance field initializers.
              At the end of class processing in the ProcClassMembersPhase the content of this cell is converted into
              the method $instance_init and the cell is deleted. This conversion is required for local classes,
              see test local_cl_955. */
            <instanceInit color="Indigo"> [.KList] </instanceInit>

            <br/>

            //todo add a cell <staticFields>, just like <fieldDecs>
            /*The map of static fields declared in this class only, and NOT in superclasses or superinterfaces.
              Map[Id -> Location]
              Used during object instantiation.*/
            <staticEnv color="DarkSlateGray"> .Map </staticEnv>

            //The sequence of static initializers (that also includes field initializers)
            //see static-init.k for more details.
            <staticInit color="DarkSlateGray"> [.KList] </staticInit>

            //The map of compile-time constant fields. We consider compile-time constants only final static fields
            //initialized with a literal expression.
            //Constant references are replaced by their values during elaboration phase.
            //Created during process classes phase.
            //Map[Id -> TypedVal]
            <constantEnv color="DarkSlateGray"> .Map </constantEnv>

          </cphMembers>

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

          //Cells used during folding phase
          <clsFolding color="Yellow">

            //The whole class folded back into a 'ClassDec(...) node
            <folded color="Teal"> .K </folded>

          </clsFolding>

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

      <globalPhase  color="YellowGreen"> ProcTypeNamesPhase  </globalPhase>

      <br/>

      <phStart color="Yellow">

        //required in ProcCompUnitsPhase
        <program color="LightSteelBlue"> $PGM:K </program>

        //Main class, passed as krun argument. We need it from the outside, just like JDK Java.
        <mainClass color="LightSteelBlue"> $MainClass:ListItem </mainClass>

      </phStart>

      <br/>

      <phTN color="Yellow">

        //cell type: Map[PackageId->Map[Id->ClassType]], Id = simple name, ClassType = full name
        //Computed during ProcTypeNamesPhase. Used in all the elaboration phases.
        <namesToClasses color="OrangeRed"> .Map </namesToClasses>

      </phTN>

      <br/>

      <phCU color="Yellow">

        //Types imported by the current compilation unit. Created in module PROCESS-IMPORTS, part of
        //ProcCompUnitsPhase. Used in ProcCompUnitsPhase when imports for a compilation unit are computed,
        //and in ProcClassDecsPhase, when they are used to lookup extends/implements clauses.
        //Type: Map[Id -> ClassType]
        <compUnitImports color="LightCoral"> .Map </compUnitImports>

      </phCU>

      <br/>

      <phElab color="Yellow">

        //The local variable environment, created and used during elaboration phase.
        //Represents a stack. Each ListItem contains a Map[Id -> Type]
        <elabEnv color="Orange"> ListItem(mapWrap(.Map)) </elabEnv>

        //The global registry of all local classes
        //When a local class is first encountered in the elaboration phase, a global class name is generated for it
        //and the class is registered in this map.
        //Type: Map[Id->ClassType] - map from simple local names to global names.
        //Used in elaboration phase.
        <localTypes color="Orange"> ListItem(mapWrap(.Map)) </localTypes>

        //Counter used to generate unique package names for local classes. Elaboration phase only.
        <nextLocalId color="Orange"> 1 </nextLocalId>

        //A list of terms that are collected during elaboration phase by a call to appendToElabBuffer()
        //and are restored back to K by a call to loadElabBuffer()
        <elabBuffer> [.KList] </elabBuffer>

      </phElab>

      <br/>

      <phFolding color="Yellow">

        /*Folded representation of the whole program. */
        <foldedProgram color="Cyan"> [.KList] </foldedProgram>
      </phFolding>

      <br/>

      <phExec color="Yellow">

        //Execution memory. Map[Location:Int->Value:TypedVal]. Both local vars and heap vars are stored here.
        <store color="Cyan"> .Map </store>

        //Represents the storage of objects. Since objects have a complex inner structure,
        //we need to hold them separately if we want to represent that structure as a cell tree.
        <objectStore color="Cyan">
          <object color="Cyan" multiplicity="*">

            //The id of this object. Same as store location for the newly created object reference.
            <objectId> .K </objectId>

            //The actual object class
            <objectType> .K </objectType>

            //One layer for each class in the inheritance chain of this object
            <layer multiplicity="*">

              //The class corresponding to the given chain
              <layerClass> .K </layerClass>

              //Map[Id |-> Loc] -> fields defined in this layer
              <layerEnv> .Map </layerEnv>

              //objectRef() ::_ - a reference to the directly enclosing object, or noValue if none.
              <layerEnclosingObject> noValue </layerEnclosingObject>
            </layer>
          </object>
        </objectStore>

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

        //Set[ThreadId:Int] The set of terminated threads.
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
