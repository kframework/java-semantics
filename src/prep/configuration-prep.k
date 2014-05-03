module CONFIGURATION-PREP
    imports CORE-SORTS
    imports CORE-FUNCTIONS

configuration
    <T>
      <k color="Green"> $COMMAND:K </k>

      /*Current method/block context type - either staticCT or instanceCT
      Used both during elaboration and execution*/
      <contextType color="DarkOrange"> staticCT </contextType>

      //current class during all phases, including early preprocessing
      <crntClass color="DarkOrange"> noClass </crntClass>

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

            //[...,, 'LocalVarDec(_),, ...] - Instance field declarations. Used during object instantiation.
            <instanceFields color="Indigo"> [.KList] </instanceFields>

            /*Contains concatenated instance initializer blocks and instance field initializers.
              At the end of class processing in the ProcClassMembersPhase the content of this cell is converted into
              the method $instance_init and the cell is deleted. This conversion is required for local classes,
              see test local_cl_955. */
            <instanceInit color="Indigo"> [.KList] </instanceInit>

            <br/>

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
    </T>

endmodule
