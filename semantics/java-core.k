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
                    <k color="green"> ($PGM:K ~> execute) </k>
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
                        <crntClass> object </crntClass>
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
                      <className color="Fuchsia"> main </className>
                      <extends color="Fuchsia"> object </extends>
                      <declarations color="purple"> .K </declarations>
                      <metatype color="Fuchsia"> "concrete class" </metatype>
                   </class>
                </classes>
              </T>

//constructs encountered in configuration
syntax #Id ::= "main" | "object"
syntax K ::= "execute"

//@ \section{Types}

syntax Type ::= "int"
              | "bool"
              | "rtString"
              | "rtType"
              | "void"

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

syntax Val ::= #Int | #Bool | #String
             | "printMethodVal"
             | "readMethodVal"
             | "undefined" "(" Type ")" [latex("\bot_{#1}")]
             | "nothing"

syntax KResult ::= Val | Type

/*@ \subsubsection{Generic guard}
A generic computational guard (should be builtin): it allows the
computation to continue only if a prefix guard evaluates to true.  */

syntax K ::= "true?"
rule true ~> true? => .  [structural]

/*@ \subsubsection{toString}
Converts various result types to string type, mainly for printing.*/

declare toString :  KResult -> #String
define toString(Str:#String) => Str
define toString(I:#Int) => Int2String(I)
define toString(true) => "true"
define toString(false) => "false"

//@ \texttt{typeOf definition}

declare typeOf :  K -> Type
define typeOf(_:#Int) => int
define typeOf(_:#Bool) => bool
define typeOf(_:#String) => rtString
define typeOf(_:Type)  => rtType

define typeOf(undefined(T:Type)) => T
define typeOf(nothing) => void

syntax K ::= "subtype" List{KResult} "," List{KResult}
declare unsafeCast : Val Type -> Val

//@ \subsection{Type labels}
//@Here we rewrite java type ast into simple types

rule 'Int(_) => int [structural]
rule 'Boolean(_) => bool [structural]
rule 'Void(_) => void [structural]

end module
