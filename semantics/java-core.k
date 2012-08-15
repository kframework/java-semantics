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
                   </class>
                </classes>
                <mainClass> .K </mainClass>
                //current compilation unit package
                <cuPackage> .K </cuPackage>
                <executionPhase> "ProcessDeclarations" </executionPhase>

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

syntax TypedVal ::= RawVal "::" Type

syntax KResult ::= TypedVal | Type

/*@ \subsubsection{Generic guard}
A generic computational guard (should be builtin): it allows the
computation to continue only if a prefix guard evaluates to true.  */

syntax K ::= "true?"
rule true::bool ~> true? => .  [structural]

//Converts a Bool::bool result into Bool, to be used with #if
declare isTrue : K -> Bool
context isTrue(HOLE)
define isTrue(B:Bool :: bool) => B

/*@ \section{auxiliary constructs} */


/*toString - Converts various result types to string type, mainly for printing.*/

// declare toString :  KResult -> TypedVal
declare toString :  K -> TypedVal
context toString(HOLE)

define toString(Str:String :: _) => Str :: rtString
define toString(I:Int :: char) => charString(I) :: rtString
define toString(I :: T:Type) => Int2String(I) :: rtString
    when T =/=K char
define toString(true::_) => "true" :: rtString
define toString(false::_) => "false" :: rtString
define toString(null::_) => "null" :: rtString

define toString(rtString) => "java.lang.String"::rtString

//@ \texttt{typeOf definition}

declare typeOf : K -> Type
define typeOf(_ :: T:Type) => T

//@ \texttt{subtype definition}
syntax K ::= "subtype" List{KResult} "," List{KResult}

rule [subtypeRefTrue]:
    subtype T, T => true :: bool
        [structural]

//Bug. Attempt to write a single rule instead of two below, using side conditions,
//leads to SUBSORT-TO-WRAPPERS
rule [subtypeListLeft]:
    subtype(T1:Type,,T2:Type,,Ts:List{KResult}), (Tp1:Type,,Tps:List{KResult})
    => 'LazyAnd( (subtype T1,Tp1),, (subtype (T2,,Ts),(Tps)) )
        [structural]

rule [subtypeListRight]:
    subtype(T1:Type,,Ts:List{KResult}), (Tp1:Type,,Tp2:Type,,Tps:List{KResult})
    => 'LazyAnd( (subtype T1,Tp1),, (subtype (Ts),(Tp2,,Tps)) )
        [structural]

rule [subtypeEmptyLeft]:
    subtype .List{K}, T,,_ => false :: bool
        [structural]

rule [subtypeEmptyRight]:
    subtype T,,_ , .List{K} => false :: bool
        [structural]

rule [subtypeEmpty]:
    subtype .List{K}, .List{K} => true :: bool
        [structural]

//todo this rule, if used, leads to the error "failed to load IOWrapper".
declare isNumericType2 : Type -> Bool
define isNumericType2(T)
=>  #if         T ==K byte
        orBool  T ==K short
        orBool  T ==K int
        orBool  T ==K long
        orBool  T ==K char
      #then true
      #else false
    #fi  [structural]

//this is actually a hack, since we should not access k-labels 'arrayOf_ and 'class_ .
//maybe this isSort methods will be provided by K later on.
declare isRefType2 : Type -> Bool
define isRefType2(T)
=>  #if         T ==K rtString
        orBool  T ==K nullType
        orBool  getKLabel(T) ==KLabel 'arrayOf_
        orBool  getKLabel(T) ==KLabel 'class_
      #then true
      #else false
    #fi  [structural]

//default value of all types
declare default : Type -> TypedVal
define default(NT:NumericType) => 0 :: NT
define default(bool) => false :: bool
define default(RT:RefType) => null :: RT

//@ \subsubsection{Debug aids}
syntax K ::= K "++" K [seqstrict gather(E e)]
rule K1:K ++ K2:K => toString(K1) +String toString(K2) [structural anywhere]

syntax K ::= "print" "(" K ")" [strict]
rule [print]:
    <k> print(Str:String) => . ...</k>
    <out>... .=> ListItem(Str) </out>

end module
