module JAVA-CORE

/*@ \section{Configuration}
The configuration is almost identical to that of untyped SIMPLE,
except for a \textsf{return} cell inside the \textsf{control} cell.
This \textsf{return} cell will hold, like in the static semantics of
typed SIMPLE, the expected type of the value returned by the function
being executed.  The contents of this cell will be set whenever a
function is invoked and will be checked whenever the evaluation of the
function body encounters an explicit \texttt{return} statement. */

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
                <dissolveEmptyK> true </dissolveEmptyK>
                <nextLoc color="gray"> 0 </nextLoc>
                <br/>
                <classes color="Fuchsia">
                   <class multiplicity="*" color="Fuchsia">
                      <className color="Fuchsia"> .K </className>
                      <extends color="Fuchsia"> .K </extends>
                      <declarations color="purple"> .K </declarations>
                      <metatype color="Fuchsia"> "concrete class" </metatype>
                   </class>
                </classes>
                <mainClass> .K </mainClass>
              </T>

//@ \section{Identifiers}

rule 'Id(Str) => String2Id(Str)     [anywhere]

//@ \section{Types}

syntax Type ::= "int"
              | "long"
              | "bool"
              | "char"
              | "rtString"
              | "nullType"
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
                | "undefined" "(" Type ")" [latex("\bot_{#1}")]

syntax TypedVal ::= RawVal "::" Type

syntax KResult ::= TypedVal | Type
                 | rtSystemOutPrintln // used in JAVA-STATEMENTS

/*@ \subsubsection{Generic guard}
A generic computational guard (should be builtin): it allows the
computation to continue only if a prefix guard evaluates to true.  */

syntax K ::= "true?"
rule true::bool ~> true? => .  [structural]

/*@ \section{auxiliaty constructs} */


/*toString - Converts various result types to string type, mainly for printing.*/

// declare toString :  KResult -> TypedVal
declare toString :  K -> TypedVal
context toString(HOLE)

define toString(Str:String :: rtString) => Str :: rtString
define toString(I:Int :: char) => charString(I) :: rtString
define toString(I :: T:Type) => Int2String(I) :: rtString
    when T =/=K char
define toString(true::_) => "true" :: rtString
define toString(false::_) => "false" :: rtString
define toString(null::_) => "null" :: rtString

//@ \texttt{typeOf definition}

declare typeOf :  K -> Type
define typeOf(_ :: T:Type) => T

syntax K ::= "subtype" List{KResult} "," List{KResult}

rule [subtypeTrue]:
    subtype T,T => true :: bool
        [structural]

rule [subtypeList]:
    subtype(T1:Type,,T2:Type,,Ts:List{KResult}), (Tp1:Type,,Tp2:Type,,Tps:List{KResult})
    => subtype T1,Tp1 ~> true? ~> subtype (T2,,Ts),(Tp2,,Tps)
        [structural]

rule [subtypeEmpty]:
    subtype .List{K}, .List{K} => true :: bool
        [structural]

declare unsafeCast : TypedVal Type -> TypedVal
define unsafeCast(V:RawVal :: T, T) => V :: T

//@ \subsection{Type labels}
//@Here we rewrite java type ast into simple types

rule 'Int(_) => int [structural]
rule 'Long(_) => long [structural]
rule 'Boolean(_) => bool [structural]
rule 'Void(_) => void [structural]

//@ \subsection{Integer types normalization}

declare bitCount : Type -> Int
define bitCount(int) => 32
define bitCount(long) => 64

declare normalize : TypedVal -> TypedVal

define normalize(I:Int :: int)
    =>  #if I <=Int 2147483647 andBool I >=Int -2147483648
          #then I :: int
          #else normalizeImpl(I::int)
        #fi

define normalize(I:Int :: long)
    =>  #if I <=Int 9223372036854775807 andBool I >=Int -9223372036854775808
          #then I :: long
          #else normalizeImpl(I::long)
        #fi

declare normalizeImpl : TypedVal -> TypedVal

define normalizeImpl(I:Int :: T)
    => normalizeSign((((I &Int ((1 <<Int bitCount(T)) -Int 1))
        +Int (1 <<Int bitCount(T)))
        &Int ((1 <<Int bitCount(T)) -Int 1)) :: T)

declare normalizeSign : TypedVal -> TypedVal

define normalizeSign(I:Int :: T)
    =>  #if I <=Int ((1 <<Int (bitCount(T) -Int 1)) -Int 1)
          #then I :: T
          #else I -Int (1 <<Int bitCount(T)) :: T
        #fi

end module
