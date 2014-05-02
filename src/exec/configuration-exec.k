require "../common/core-sorts.k"
require "../common/core-functions.k"

module CONFIGURATION-EXEC
    imports CORE-SORTS
    imports CORE-FUNCTIONS

configuration
    <T>
      <threads color="GreenYellow">
        <thread multiplicity="*" color="GreenYellow">
          <k color="Green"> $COMMAND:K </k>

          <stack color="Green"> .List </stack>

          //! \smallskip
          <br/>

          /*The execution context of the current method - local names environment, return type,
            context type and current object.*/
          <methodContext color="Orange">

            //The map from local vars to their location in the store. Also includes outer local vars, for local classes.
            <env color="Crimson"> .Map </env>

            //current class during all phases, including early preprocessing
            <crntClass color="DarkOrange"> noClass </crntClass>

            <location color="DarkOrange"> .K </location>
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

            //The major phase of <class> lifecycle. See ClassPhase definition.
            <classPhase color="Maroon"> .K </classPhase>

          </cphDiscovered>

          <br/>

          <cphCreated color="Yellow">

            //Used by object instantiation
            //noClass if this is a top-level class,
            //ClassType of the enclosing class otherwise
            <enclosingClass color="DarkGoldenrod"> noClass </enclosingClass>

          </cphCreated>

          <cphDecs color="Yellow">

            //The base class, or noClass for interfaces and Object.
            <extends color="SpringGreen"> .K </extends>

          </cphDecs>

          <br/>

          <cphMembers color="Yellow">

            //Transitively implemented interfaces. Used by subtyping rules.
            <implTrans color="DeepPink"> .Set </implTrans>

            /*Signatures of methods accessible to this class (both declared and inherited)
              Map[Sig -> Class]
              Used in elaboration of method calls.*/
            <methods color="Blue"> .Map </methods>
            <br/>

            /*All methods declared in this class.
              Used in elaboration of method calls.*/
            <methodDecs color="Blue">

              <methodDec multiplicity="*" color="Blue">

                //Method signature, of type Signature
                <methodSignature color="Blue"> .K </methodSignature>

                //Method params
                <methodParams color="Blue"> [.KList] </methodParams>
                <br/>

                //Method body
                <methodBody color="Blue"> .K </methodBody>

                <methodAccessMode color="Blue"> .K </methodAccessMode>
                <br/>

                //Either staticCT or instanceCT
                <methodContextType color="Blue"> .K </methodContextType>

              </methodDec>
            </methodDecs>

            <br/>

            //[...,, 'LocalVarDec(_),, ...] - Instance field declarations. Used during object instantiation.
            <instanceFields color="Indigo"> [.KList] </instanceFields>

            //[...,, 'FieldDec('Static(_),,T,,_),, ...] - Static field declarations. Used during class instantiation.
            <staticFields color="DarkSlateGray"> [.KList] </staticFields>

            //The sequence of static initializers (that also includes field initializers)
            //see static-init.k for more details.
            <staticInit color="DarkSlateGray"> [.KList] </staticInit>

          </cphMembers>

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

            /*The map of static fields declared in this class only, and NOT in superclasses or superinterfaces.
              Map[Id -> Location] Used during static variable lookup.*/
            <staticEnv color="DarkSlateGray"> .Map </staticEnv>

          </clsExec>

        </class>
      </classes>

      <br/>
      <br/>

      <globalPhase color="YellowGreen"> $STARTPHASE:GlobalPhase </globalPhase>
      <lastGlobalPhase color="YellowGreen"> $ENDPHASE:GlobalPhase </lastGlobalPhase>

      <br/>

      <phStart color="Yellow">

        //The initial program loaded by krun. For full mode and preprocessing this is
        //the initial java program, for execution mode it is the folded java program.
        <program color="LightSteelBlue"> $PGM:K </program>

        //Main class, passed as krun argument. We need it from the outside, just like JDK Java.
        <mainClass color="LightSteelBlue"> $MainClass:ListItem </mainClass>

      </phStart>

      <br/>

      <phExec color="Yellow">

        //Execution memory. Map[Location:Int->Value:TypedVal]. Both local vars and heap vars are stored here.
        <store color="Cyan"> .Map </store>

        <br/>

        //Represents the storage of objects. Since objects have a complex inner structure,
        //we need to hold them separately if we want to represent that structure as a cell tree.
        <objectStore color="Cyan">
          <object color="Cyan" multiplicity="*">

            //The id of this object. Same as store location for the newly created object reference.
            <objectId> .K </objectId>

            //The actual object class
            <objectType> .K </objectType>

            <br/>

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

        <br/>

        //Counter for next location to be used in the cell <store>.
        <nextLoc color="Cyan"> 0 </nextLoc>

        //Standard input. Each token is a ListItem.
        <in color="LightPink" stream="stdin"> .List </in>

        //Standard output. Each token is a ListItem.
        <out color="LightPink" stream="stdout"> .List </out>

        //A map from types to objectRef() terms that represent their T.class value
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
