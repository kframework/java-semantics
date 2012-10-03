module JAVA-CORE

/*@ \section{Configuration}
The configuration is almost identical to that of typed KOOL.*/

configuration <T color="red">
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
                      <return color="LimeGreen"> void </return>
                        // holds return type
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
                <classes color="Fuchsia">
                   <class multiplicity="*" color="Fuchsia">
                      <className color="Fuchsia"> .K </className>
                      <extends color="Fuchsia"> .K </extends>
                      <package> .K </package>
                      <declarations color="purple"> .K </declarations>
                      <fieldDecs color="purple"> 'ListWrap(.List{K}) </fieldDecs>
                      <methods color="purple"> .Map </methods>
                   </class>
                </classes>
                <mainClass> .K </mainClass>
                //current compilation unit package
                <cuPackage> .K </cuPackage>
                <cuClass> .K </cuClass>
                <executionPhase> "ProcessCompUnits" </executionPhase>

                <dissolveEmptyK> true </dissolveEmptyK>
                <dissolveClasses> true </dissolveClasses>
              </T>

//@ \section{Identifiers}

rule 'Id(Str) => String2Id(Str)     [anywhere]

//@ \section{Types}

syntax IntOrLongType ::= "int" | "long"
syntax NumericType ::= "byte" | "short" | IntOrLongType | "char"
syntax PrimitiveType ::= NumericType | "bool"
syntax RefType ::= "rtString" | "nullType"

syntax Type ::= PrimitiveType
              | RefType
              | "void"
              | "rtType"

/*@ \subsection{Values and results}
These are similar to those of untyped SIMPLE, except that the array
references and the function abstrations now also hold their types.
These types are needed in order to easily compute the type of any
value inthe language (see the auxiliary \texttt{typeOf} operation at
the end of this module).  Note that our more-generous-than-needed
syntax here allows function abstractions to take a list of expressions
as parameters; in fact, the semantics will be given in a way that
those expressions can only be typed identifiers.  Recall that the
purpose of syntax in a \K definition is not to parse programs in order
to reject those not satisfying the expected syntactic/typing
conventions (this is what a static semantics does---see the statically
typed SIMPLE), but only to parse programs ``enough'' to give them
semantics.  In other words, the \K syntax is the ``syntax of the
semantics''.  */

syntax RawVal ::= Int | Bool | String
                | "null"
                | "nothing"
                | "undefined" [latex("\bot_{#1}")]

syntax Type ::= "methodType" "(" AccessMode ","    // access mode
                                 List{KResult} "," // argument types
                                 Type              // return type
                             ")"

syntax RefType ::= "class" Id

syntax RawVal ::= "objectClosure" "(" Int //OL - object location
                                  "," Bag //<envStack> - the object content
                                  ")"

                | "methodClosure" "("
                    Id ","   // Class - class defining the method
                    K ","    // 'ListWrap(Params) - params
                    K        // S - method body
                  ")"

syntax RefType ::= "arrayOf" Type
                  [prec(1) latex "{#1}\texttt{\char91\char93}"]

syntax RawVal ::= "arrayRef" "("
                    Type ","  // Type of array
                    Int ","   // Location of first element
                    Int       // Length
                  ")"

syntax TypedVal ::= RawVal "::" Type

syntax KResult ::= TypedVal | Type

syntax AccessMode ::= "public" | "protected" | "package" | "private"
syntax KResult ::= AccessMode

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
rule toString(I :: T:Type) => Int2String(I) :: rtString
    when T =/=K char [anywhere]
rule toString(true::_) => "true" :: rtString [anywhere]
rule toString(false::_) => "false" :: rtString [anywhere]
rule toString(null::_) => "null" :: rtString [anywhere]

rule toString(rtString) => "java.lang.String"::rtString [anywhere]

//@ \texttt{typeOf definition}

syntax K ::= "typeOf" "(" K ")" [function]
rule typeOf(_ :: T:Type) => T [anywhere]

//@ \texttt{subtype definition}
syntax K ::= "subtype" "(" List{KResult} "," List{KResult} ")"

//todo this rule, if used, leads to the error "failed to load IOWrapper".
syntax K ::= "isNumericType2" "(" Type ")" [function]
rule isNumericType2(T)
=>  #if         T ==K byte
        orBool  T ==K short
        orBool  T ==K int
        orBool  T ==K long
        orBool  T ==K char
      #then true
      #else false
    #fi  [structural anywhere]

//this is actually a hack, since we should not access k-labels 'arrayOf_ and 'class_ .
//maybe this isSort methods will be provided by K later on.
syntax K ::= "isRefType2" "(" Type ")" [function]
rule isRefType2(T)
=>          T ==K rtString
    orBool  T ==K nullType
    orBool  getKLabel(T) ==KLabel 'arrayOf_
    orBool  getKLabel(T) ==KLabel 'class_
        [structural anywhere]

//default value of all types
syntax K ::= "default" "(" Type ")" [function]
rule default(NT:NumericType) => 0 :: NT [anywhere]
rule default(bool) => false :: bool [anywhere]
rule default(RT:RefType) => null :: RT [anywhere]

//@ \subsubsection{Auxiliary constructs for other modules}

syntax Package ::= "package" "(" List{K} ")"
syntax KResult ::= Package

syntax K ::= "getPackage" "(" Id ")"
rule [getPackage]:
    <k> getPackage(Class:Id) => Pack ...</k>
    <class>
      <className> Class </className>
      <package> Pack:Package </package>
      ...
    </class>

syntax K ::= "kEq" "(" K "," K ")" [seqstrict]
rule kEq(KR1:KResult, KR2:KResult) => (KR1 ==K KR2)::bool

//@ \subsubsection{Debug aids}
syntax K ::= K "++" K [seqstrict gather(E e)]
rule K1:K ++ K2:K => toString(K1) +String toString(K2) [structural anywhere]

end module
