module JAVA-CORE

/*@ \section{Configuration}
The configuration is almost identical to that of typed KOOL.*/

configuration
    <T color="red">
      <threads color="orange">
        <thread multiplicity="*" color="yellow">
          <k color="green"> $PGM:K </k>
          <env color="violet"> .Map </env>
          <holds color="black"> .Map </holds>
          <br/>
          <control color="cyan">
            <stack color="blue"> .List </stack>
            //todo this cell contained originally .K
            //why it worked?
            <return color="LimeGreen"> void </return> // holds method return type
            <br/>
            <crntObj color="Fuchsia">
              <crntClass> .K </crntClass>
              <envStack> .List </envStack>
              <location multiplicity="?"> .K </location>
            </crntObj>
          </control>
        </thread>
      </threads>
      <br/>
      <store color="white"> .Map </store>
      <busy color="cyan">.Set</busy>
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

          //for Object this is noClass
          <extends color="Fuchsia"> .K </extends>
          <implements> .Set </implements>
          <implTrans> .Set </implTrans>
          <br/>
          <rawExtends> .K </rawExtends>
          <rawImplements> .K </rawImplements>
          <unprocessedBases> .K </unprocessedBases>//base classes that didn't
                                                   //reached the state DecsProcessedCPP yet.
          <declarations color="purple"> .K </declarations>
          <metaType> .K </metaType>

          //'LocalVarDec for each field
          <fieldDecs color="purple"> 'ListWrap(.List{K}) </fieldDecs>

          <methods color="purple"> .Map </methods>
          <br/>
          <instanceInit> 'ListWrap(.List{K}) </instanceInit>

          //The map of static fields declared in this class and superinterfaces, but not in superclasses.
          //Map[Id -> Location]
          <staticEnv> .Map </staticEnv>

          //The sequence of static initializers (that also includes field initializers)
          <staticInit> 'ListWrap(.List{K}) </staticInit>
          <br/>

          //Static fields declared in this class, not inherited. Used by static initialization.
          <staticInitLocations> .Set </staticInitLocations>
          <staticInitDone> false </staticInitDone>
          <cuImports> .Map </cuImports> //imports of the enclosing CU, for top-level classes only.
          <imports> .Map </imports>
          <enclosingClass> noClass </enclosingClass> //noClass if this is a top-level class,
                                                     //ClassType of the enclosing class otherwise
          <preprocessingPhase> .K </preprocessingPhase> //The major phase of <class> lifetime.
                                                        //see ClassPreprocessingPhase definition
        </class>
      </classes>
      <br/>
      <mainClass> $MainClass:ListItem </mainClass>
      //current compilation unit package
      <cuPackage> .K </cuPackage>
      <cuClass> .K </cuClass>
      <compUnitImports> .Map </compUnitImports>

      //A map from types to objectClosure() terms that represent their T.class value
      <classLiteralsMap> .Map </classLiteralsMap>
      <br/>

      //The local variables environment during elaboration
      //Represents a stack
      <elabEnv> ListItem(stEnv(.Map)) </elabEnv>

      //The context type - staticCT or instanceCT of the current code block.
      <elabContextType> .K </elabContextType>

      <computationPhase> ProcessTypeNamesPhase </computationPhase>
      //required in ProcessCompUnitsPhase
      <programBackup> $PGM:K </programBackup>

      <dissolveEmptyK> true </dissolveEmptyK>
      <dissolveClasses> true </dissolveClasses>
    </T>

//@ \section{Identifiers}

syntax ComputationPhase ::= "ProcessTypeNamesPhase"
                          | "ProcessCompUnitsPhase"
                          | "ProcessClassDecsPhase"
                          | "ProcessClassesPhase"
                          | "ElaborateBlocksPhase"
                          | "ExecutionPhase"

syntax ClassPreprocessingPhase ::= "CreatedCPP"
                                 | "BasesResolvedCPP"
                                 | "DecsProcessedCPP"
                                 | "MembersProcessedCPP"

rule 'Id(Str:String) => String2Id(Str)     [anywhere]

//@ \section{Types}

syntax IntOrLongType ::= "int" | "long"
syntax NumericType ::= "byte" | "short" | IntOrLongType | "char"
syntax PrimitiveType ::= NumericType | "bool"
syntax RefType ::= "rtString" | "nullType"

syntax Type ::= PrimitiveType
              | RefType
              | "void"
              | "rtType"

syntax RawVal ::= Int | Bool | String
                | "null"
                | "nothing"
                | "undefined" [latex(\bot_{#1})]

syntax Type ::= "methodType" "(" AccessMode ","    // the access mode
                                 ClassType ","     // the declaring class
                                 K ","             // to be processed into Types
                                 Type              // return type
                             ")"

syntax ClassType ::= "class" Id
                   | "noClass"

syntax RefType ::= ClassType
                 | "arrayOf" Type       [latex({#1}\texttt{\char91\char93})]

syntax ContextType ::= "staticCT" | "instanceCT"
syntax KResult ::= ContextType

syntax RawVal ::= "objectClosure" "(" Int //OL - object location
                                  "," Bag //<envStack> - the object content
                                  ")"

                | "methodClosure" "("
                    ClassType ","   // Class - class defining the method
                    K ","    // 'ListWrap(Params) - params
                    ContextType "," //either staticCT or instanceCT
                    K        // S - method body
                  ")"
                | "constrClosure" "("
                    ClassType ","   // Class - class defining the method
                    K ","    // 'ListWrap(Params) - params
                    K ","    // first line - either:
                             //   'SuperInv - superclass constructor invocation
                             //   'AltConstrInv - alternate this class consturctor invocation
                             //   .K - none, if this class is Object
                    K        // S - method body
                  ")"
                | "arrayRef" "("
                    Type ","  // Type of array
                    Int ","   // Location of first element
                    Int       // Length
                  ")"

syntax TypedVal ::= RawVal "::" Type
syntax KResult ::= TypedVal | Type

//If we try to use "::" we get ambiguities
syntax TypedExp ::= K ":::" Type
syntax KResult ::= TypedExp

syntax AccessMode ::= "public" | "protected" | "package" | "private"
syntax KResult ::= AccessMode

//bug cannot call this construct ClassType:
//collision between sort ClassType and KLabel 'ClassType
//causes infinite loop on any program
syntax MetaType ::= "classMetaT" | "interfaceMetaT"

/*@ \subsubsection{Generic guard}
A generic computational guard (should be builtin): it allows the
computation to continue only if a prefix guard evaluates to true.  */

syntax K ::= "true?"
rule true::bool ~> true? => .  [structural]

//Converts a Bool::bool result into Bool, to be used with #if
syntax K ::= "isTrue" "(" K ")" [function]
context isTrue(HOLE)
rule isTrue(B:Bool :: bool) => B [anywhere]

/*@ \section{auxiliary constructs} */


/*toString - Converts various result types to string type, mainly for printing.*/

// syntax K ::= "toString" "(" KResult ")" [function]
syntax K ::= "toString" "(" K ")" [function]
context toString(HOLE)

rule toString(Str:String :: _) => Str :: rtString [anywhere]
rule toString(I:Int :: char) => charString(I) :: rtString [anywhere]
rule toString(I:Int :: T:Type) => Int2String(I) :: rtString
    when T =/=K char [anywhere]
rule toString(true::_) => "true" :: rtString [anywhere]
rule toString(false::_) => "false" :: rtString [anywhere]
rule toString(null::_) => "null" :: rtString [anywhere]

rule toString(rtString) => "java.lang.String"::rtString [anywhere]

//@ \texttt{typeOf definition}

syntax K ::= "typeOf" "(" K ")" [function]
rule typeOf(_ :: T:Type) => T   [anywhere]

//todo this rule, if used, leads to the error "failed to load IOWrapper".
syntax K ::= "isNumericType2" "(" Type ")" [function]
rule isNumericType2(T:Type)
=>  #if         (T ==K byte)
        orBool  (T ==K short)
        orBool  (T ==K int)
        orBool  (T ==K long)
        orBool  (T ==K char)
      #then true
      #else false
    #fi  [structural, anywhere]

//this is actually a hack, since we should not access k-labels 'arrayOf_ and 'class_ .
//maybe this isSort methods will be provided by K later on.
syntax K ::= "isRefType2" "(" Type ")"  [function]
rule isRefType2(T:Type)
=>          (T ==K rtString)
    orBool  (T ==K nullType)
    orBool  (getKLabel(T) ==KLabel 'arrayOf_)
    orBool  (getKLabel(T) ==KLabel 'class_)
                                        [structural, anywhere]

//default value of all types
syntax K ::= "default" "(" Type ")"     [function]
rule default(NT:NumericType) => 0 :: NT [anywhere]
rule default(bool) => false :: bool     [anywhere]
rule default(RT:RefType) => null :: RT  [anywhere]

//@ \subsubsection{Auxiliary constructs for other modules}

syntax PackageId ::= "packageId" "(" String ")"
syntax KResult ::= PackageId

//The argument should evaluatge to ClassType
syntax K ::= "getPackage" "(" K ")"               [strict]
rule [getPackage]:
    <k> getPackage(Class:ClassType) => Pack ...</k>
    <typeNamesMap>... Pack:PackageId |-> mapWrap(_ |-> Class _) ...</typeNamesMap>

//Returns the top-level class enclosing this class
syntax K ::= "getTopLevel" "(" ClassType ")"

rule [getTopLevelReduce]:
    <k>
      getTopLevel(Class:ClassType) => getTopLevel(EnclosingClass)
      ...
    </k>
    <classType> Class </classType>
    <enclosingClass> EnclosingClass:ClassType </enclosingClass>
when EnclosingClass =/=K noClass

rule [getTopLevel]:
    <k>
      getTopLevel(Class:ClassType) => Class
      ...
    </k>
    <classType> Class </classType>
    <enclosingClass> noClass </enclosingClass>

syntax K ::= "kEq" "(" K "," K ")" [seqstrict]
rule kEq(KR1:KResult, KR2:KResult) => (KR1 ==K KR2)::bool

syntax KResult ::= "noValue"

syntax K ::= K "??" K [strict(1), right]

rule [chainOfResponsibility1]:
    KR:KResult ?? _ => KR
when KR =/=K noValue

rule [chainOfResponsibility2]:
    noValue ?? K => K

syntax K ::= "restoreEnvAndObj" "(" Map "," Bag ")"

rule [restoreEnvAndObj]:
    <k> restoreEnvAndObj(Env:Map, Obj:Bag) => . ...</k>
    <env> _ => Env </env>
    <crntObj> _ => Obj </crntObj>

//The content of an <envStack> ListItem() </envStack>
syntax K ::= "(" ClassType "," BagItem ")"

//A wrapper for maps. Allows the usage of multy-level maps.
//Also used as part of mapUnion operation in java-process-classes
syntax KResult ::= "mapWrap" "(" Map ")"
                 | "setWrap" "(" Set ")"

syntax K ::= "objectClass"                              [function]
rule objectClass => class String2Id("java.lang.Object") [structural, anywhere]

//Subsection mapUnion, union of maps. Remove when +Map will be implemented.
//In this operation, elements of the second map overwrite elements of the first map
//if they collide. This is not really important for the only application of this function
//in our definition.
syntax K ::= "mapUnion" "(" Map "," Map ")"
rule mapUnion(M1:Map, M2:Map K1:K |-> K2:K) => mapUnion(M1[K2/K1], M2)
rule mapUnion(M1:Map, .Map) => mapWrap(M1)

//subsection setUnion, union of sets. Remove when +Set will be implemented.
syntax K ::= "setUnion" "(" Set "," Set ")"
rule setUnion(S1:Set, S2:Set SetItem(K:K)) => setUnion(S1 SetItem(K), S2)
    when notBool(K in S1)
rule setUnion(S1:Set SetItem(K), S2:Set SetItem(K:K)) => setUnion(S1 SetItem(K), S2)
rule setUnion(S1:Set, .Set) => setWrap(S1)

syntax K ::= "getAccessMode" "(" K //'ListWrap(...) - the list of class/method attributes
                             ")"                              [function]

rule getAccessMode('ListWrap('Public(_),,_))    => public     [structural, anywhere]
rule getAccessMode('ListWrap('Protected(_),,_)) => protected  [structural, anywhere]
rule getAccessMode('ListWrap('Private(_),,_))   => private    [structural, anywhere]

rule getAccessMode('ListWrap((KL:KLabel(_) => .List{K}),, _))
when        (KL =/=KLabel 'Public)
    andBool (KL =/=KLabel 'Protected)
    andBool (KL =/=KLabel 'Private)                           [structural, anywhere]

rule getAccessMode('ListWrap(.List{K})) => package            [structural, anywhere]

//evaluates into a setWrap(S), containing all the classes in the program.
//uses <typeNamesMap> to compute the result
syntax K ::= "getAllClasses"
           | "getAllClasses" "(" Map "," Set ")"

rule [getAllClassesStart]:
    <k> getAllClasses => getAllClasses(NamesMap, .Set) ...</k>
    <typeNamesMap> NamesMap:Map </typeNamesMap>

rule getAllClasses(_ _ |-> mapWrap(_ (_ |-> Class:ClassType => .Map)), _ (.Set => SetItem(Class)))
rule getAllClasses(_ (_ |-> mapWrap(.Map) => .Map), _)
rule getAllClasses(.Map, ClassesSet:Set) => setWrap(ClassesSet)

// Auxiliary constructs for elaboration.

//Custom hole used for custom heating/cooling rules across the semantics.
syntax K ::= "CHOLE"

syntax KResult ::= "stEnv" "(" Map ")"  //A layer of the static environment
                                        //Map[name -> Type]

//size of a KList
syntax K ::= "klsize" "(" List{K} ")"               [function]
rule klsize(.List{K}) => 0                          [anywhere]
rule klsize(_:K,, Ks:List{K}) => klsize(Ks) +Int 1  [anywhere]

endmodule
