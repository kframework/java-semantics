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
          <lookupMethod>
            <isQualified> false </isQualified>
          </lookupMethod>
        </thread>
      </threads>
      <br/>
      <store color="white"> .Map </store>
      <busy color="cyan">.Set</busy>
      <in color="magenta" stream="stdin"> .List </in>
      <out color="brown" stream="stdout"> .List </out>
      <nextLoc color="gray"> 0 </nextLoc>
      <br/>
      <topLevelNamesMap> .Map </topLevelNamesMap>
      <classes color="Fuchsia">
        <class multiplicity="*" color="Fuchsia">

          //sort ClassType. Contains the fully qualified class name.
          <classType color="Fuchsia"> .K </classType>

          <extends color="Fuchsia"> .K </extends>
          <implements> .Set </implements>
          <implTrans> .Set </implTrans>
          <declarations color="purple"> .K </declarations>
          <metaType> .K </metaType>
          <fieldDecs color="purple"> 'ListWrap(.List{K}) </fieldDecs>
          <methods color="purple"> .Map </methods>
          <instanceInit> .K </instanceInit>
          <staticEnv> .Map </staticEnv>
          <staticInit> .K </staticInit>

          //Static fields declared in this class, not inherited. Used by static initialization.
          <staticInitLocations> .Set </staticInitLocations>
          <staticInitDone> false </staticInitDone>
        </class>
      </classes>
      <mainClass> $MainClass:ListItem </mainClass>
      //current compilation unit package
      <cuPackage> .K </cuPackage>
      <cuClass> .K </cuClass>
      <computationPhase> ProcessTopLevelNamesPhase </computationPhase>
      //required in ProcessCompUnitsPhase
      <programBackup> $PGM:K </programBackup>

      <dissolveEmptyK> true </dissolveEmptyK>
      <dissolveClasses> true </dissolveClasses>
    </T>

//@ \section{Identifiers}

syntax ComputationPhase ::= "ProcessTopLevelNamesPhase"
                          | "ProcessCompUnitsPhase"
                          | "ProcessClassesPhase"
                          | "ExecutionPhase"

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
                                 K ","             // to be processed into Types
                                 Type              // return type
                             ")"

syntax ClassType ::= "class" Id
syntax RefType ::= ClassType

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

syntax RefType ::= "arrayOf" Type
                  [latex({#1}\texttt{\char91\char93})]

syntax RawVal ::= "arrayRef" "("
                    Type ","  // Type of array
                    Int ","   // Location of first element
                    Int       // Length
                  ")"

syntax TypedVal ::= RawVal "::" Type

syntax KResult ::= TypedVal | Type

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
syntax K ::= "isRefType2" "(" Type ")" [function]
rule isRefType2(T:Type)
=>          (T ==K rtString)
    orBool  (T ==K nullType)
    orBool  (getKLabel(T) ==KLabel 'arrayOf_)
    orBool  (getKLabel(T) ==KLabel 'class_)
        [structural, anywhere]

//default value of all types
syntax K ::= "default" "(" Type ")" [function]
rule default(NT:NumericType) => 0 :: NT [anywhere]
rule default(bool) => false :: bool [anywhere]
rule default(RT:RefType) => null :: RT [anywhere]

//@ \subsubsection{Auxiliary constructs for other modules}

syntax PackageId ::= "packageId" "(" String ")"
syntax KResult ::= PackageId

syntax K ::= "getPackage" "(" ClassType ")"
rule [getPackage]:
    <k> getPackage(Class:ClassType) => Pack ...</k>
    <topLevelNamesMap>... Pack:PackageId |-> mapWrap(_ |-> Class _) ...</topLevelNamesMap>

syntax K ::= "kEq" "(" K "," K ")" [seqstrict]
rule kEq(KR1:KResult, KR2:KResult) => (KR1 ==K KR2)::bool

syntax KResult ::= "noValue"

syntax K ::= K "??" K [strict(1)]

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

syntax K ::= "objectClass"                              [function]
rule objectClass => class String2Id("java.lang.Object") [structural, anywhere]

endmodule
