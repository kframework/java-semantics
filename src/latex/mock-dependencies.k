/*@ \section{Other Dependencies} */

module CORE-SORTS

syntax IntOrLongType ::= "int" | "long"
syntax NumericType ::= IntType | FloatType
syntax IntType ::= "byte" | "short" | IntOrLongType | "char"
syntax FloatType ::= "float" | "double"
syntax PrimitiveType ::= NumericType | "bool"

syntax Type ::= PrimitiveType
              | RefType
              | "void"

/*@ A method signature. Required to be KResult by rules in METHOD-INVOKE.*/
syntax Signature ::= sig ( Id, Types )
syntax KResult ::= Signature

/*@ A fully qualified class name, or noClass where no valid class could be computed.*/
syntax ClassType ::= "class" Id
                   | "noClass"        [latex({\dotCt{K}})]

/* A reference type is either a class type, an array type, the null type or a String type. The null type is specified
    by the JLS although inaccessible to the programmer. String objects and types are not threated as regular objects
    in the present semantics for performance reasons.
*/
syntax RefType ::= ClassType
                 | "arrayOf" Type
                 | "nullType"

/*@ The member accessibility context of the current method - either static or instance.*/
syntax ContextType ::=  "staticCT"    [latex(\terminal{static})]
                      | "instanceCT"  [latex(\terminal{instance})]
syntax KResult ::= ContextType

//@ \subsection{Values}

/*  Represents a java value. May be either primitive - int, float, bool, of reference. The values nothing and undefined
    are special cases required by the semantics. The value nothing is associated with the return type void. The value
    undefined is the initial value of uninitialized local variables, before the first assignment.
*/
syntax RawVal ::= Int | Float | Bool | RawRefVal
                | "nothing"
                | "undefined" [latex(\bot)]

/*@ A reference value, in its four forms - as regular object, array, null or String. As mentioned previously
    String values have special treatment in this semantics and are implemented as regular strings.

The object closure have the following structure:
\begin{itemize}
\item OL:Int -- the object location
\item List -- the object content, of the form
\begin{verbatim}
  ListItem(layer(
    Class,
    <env>Env</env>,
    enclosingObjClosure::T
  ))
  ...
\end{verbatim}
\end{itemize}
*/
syntax ObjectRef ::=  objectRef (
                        Int,      //OL - object location
                        ClassType //LowestClass - the lowest class where we are allowed to search for method
                                  // implementation, or actual object class if there are no restrictions.
                      )

syntax RawRefVal ::= ObjectRef | String | "null"

/*@ A typed value is a pair of of a raw value and a type. Anywhere during execution we will evaluated typed expressions
    into typed values, never into raw values alone.
*/
syntax TypedVal ::= RawVal "::" Type

/*@ The three most common forms of computation result are Typed value or Type. Those are most common results
    we will encounter during elaboration. Other result types are more context-specific.
*/
syntax KResult ::= TypedVal | Type

/*@ Member access modes*/
syntax AccessMode ::= "public" | "protected" | "package" | "private"
syntax KResult ::= AccessMode

/*@ The two possibilities for a type represented by an objectRef: class or interface.*/
syntax ClassMetaType ::=  "classCMT"      [latex(\terminal{class})]
                        | "interfaceCMT"  [latex(\terminal{interface})]

syntax KResult ::= "noValue"  [latex({\dotCt{K}})]

/*@ Represents a reference to a method or constructor. */
syntax MethodRef ::=   methodRef(
                            Signature,  //Method signature
                            RefType     //Usually Class - class defining the method
                                        //  Could also be array type, because we may invoke methods over arrays.
                          )
                        | "noMethodRef"   [latex({\dotCt{K}})]
syntax KResult ::= MethodRef

/*@ A list of types. Elements are of sort Type. Used especially to denote argument types of a method.*/
syntax Types ::=  types (
                    KList // List of Type elements, when processed
                  )
syntax KResult ::= Types

syntax GlobalPhase ::= "dymmyGlobalPhase"

syntax StaticInitStatus ::= "StaticUninitialized"
                          | StaticInitializing ( Int )
                          | "StaticInitialized"

endmodule

module CORE-FUNCTIONS

//@ Sequence of terms and of any other statements. The first term is moved to the top of computation.
syntax KListWrap ::= "[" KList "]" [klabel('KListWrap)]

//@ A wrapper over an arbitrary KList, wrapper being of type KResult.
syntax KRListWrap ::= "kr" "[" KList "]"

syntax K ::= typeOf ( K )                           [function]

syntax K ::=  getTypes (
                KListWrap     //[...,, KResult,, ...] - a list of source expressions
              )
              [function]

syntax K ::= eqAux ( K, K )                  [seqstrict]

endmodule

module STATIC-INIT

syntax K ::=  staticInit (
                ClassType // Class - the ClassType to be initialized,
                          // or noClass if this term should be discarded.
              )

endmodule

module CORE-CLASSES
    imports CORE-SORTS

syntax K ::= getPackage ( K )               [strict]

syntax K ::= getTopLevel ( ClassType )

syntax Exp ::= cast ( Type, K ) [strict] //strictness on 1-st arcument - for runtime produced terms

syntax K ::= "stringClass"
    [function, latex(\terminal{String})]
rule stringClass => class String2Id("java.lang.String")

syntax K ::= "nullPEClass"
    [function, latex(\terminal{NullPointerException})]
rule nullPEClass => class String2Id("java.lang.NullPointerException")

//Just for the sake of rendering
syntax KResult ::= ClassType
                 | KListWrap

syntax Blah ::= "objectRef" "("
                            Int ","      //OL - object location
                            ClassType //LowestClass - the lowest class where we are allowed to search for method
                                      // implementation, or actual object class if there are no restrictions.
                          ")" ":::" ClassType
                | "null" ":::" ClassType


endmodule

module CORE-EXEC

//@ ListItem content as a stack layer
syntax K ::=  sl (
                K,  //K - rest of computation
                Bag //MethContext - the content of <methodContext>
              )

syntax K ::= lvalue ( K )

endmodule
