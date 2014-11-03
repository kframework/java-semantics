//@ \section{Module CORE-SORTS}
module TYPE-SYNTAX
     //@ \subsection{Types}
        syntax Type ::= PrimitiveType
                      | RefType
                      | "void" [klabel('Void)]

        syntax IntOrLongType ::= "int" [klabel('Int)] | "long" [klabel('Long)]
        syntax IntType ::= "byte" [klabel('Byte)]| "short" [klabel('Short)]| IntOrLongType | "char" [klabel('Char)]
        syntax FloatType ::= "float" [klabel('Float)] | "double" [klabel('Double)]
        syntax NumericType ::= IntType | FloatType
        syntax PrimitiveType ::= NumericType | "bool" [klabel('Boolean)]


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

endmodule

module CORE-SORTS
    imports TYPE-SYNTAX

//@ \subsection{Computation phases}

/*@ The computation Global Phase. See configuration documentation for details.
*/
syntax GlobalPhase ::=
    /* The content of <namesToClasses> is computed, of type
      Map[PackageName -> Map[SimpleName -> FullyQualifiedName]]
    */
    "ProcTypeNamesPhase"

    /* Primary processing of type declarations, including nested.
      For each 'ClassDec a <class> is saved, with the following cells:
        <classType>
        <enclosingClass>
        <rawExtends>
        <rawImplements>
        <rawDeclarations>
        <classMetaType>
        <cuImports> - imports of the enclosing CU, for top-level classes only.
      A class first registered in a <class> cell is in the state StoredCPhase.
    */
  | "ProcCompUnitsPhase"

  /* Resolve the fully qualified names of base classes an interfaces. Fills the content of:
        <extends> - the base class
        <implements> - the set of directly implemented interfaces
        <imports> - the map from simple names to full names for use within this class.
  */
  | "ProcClassDecsPhase"

  /* Saves into appropriate cells the list of transitively implemented interfaces, and all the
    content about this class members. Computes the following cells:
        <implTrans>
        <instanceFields>
        <methods>
        <methodDecs>
        <instanceInit> - temporary cell, deleted after class body is processed.
        <staticEnv>
        <staticInit>
  */
  | "ProcClassMembersPhase"

  /* Elaborates the content of each code block. Specifically the content of the following cells:
        <methodDecs>
        <staticInit>
    The following transformations over expressions are performed:
      - each name is resolved to its specific meaning - fully qualified class name, local variable name, static/instance
      field of a specific class, etc.
      - for each method call the precise signature is resolved.
      - each unqualified method/constructor call is converted into a qualified one with the appropriate qualifier
      (that might be empty)
      - each expression is elaborated into a typed expression.
  */
  | "ElaborationPhase"

  /* Folds the <class> cells into a preprocessed Java program. The last step of elaboration semantics.
  */
  | "FoldingPhase"

  /* Unfolds each class from its preprocessed 'ClassDec or 'InterfaceDec form back into a <class> cell.
  */
  | "UnfoldingPhase"

  /* When all preprocessing / elaboration phases are finished, the actual execution begins.
  */
  | "ExecutionPhase"

/*@ the class phase. See configuration documentation for details.*/
syntax ClassPhase ::=
    "DiscoveredCPhase"
  | "StoredCPhase"
  | "BasesResolvedCPhase"
  | "DecsProcessedCPhase"
  | "MembersProcessedCPhase"
  | "FoldedCPhase"
  | "UnfoldingStartedCPhase"
  | "UnfoldedCPhase"

/*@
  The state of a class in relation to static initialization. See static-init.k for more details.
*/
syntax StaticInitStatus ::= "StaticUninitialized"
                          | StaticInitializing ( Int )
                          | "StaticInitialized"


/*@ A method signature. Required to be KResult by rules in METHOD-INVOKE.*/
syntax Signature ::= sig ( Id, Types )
syntax KResult ::= Signature


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

/*@ The arrayRef have the following structure:
\begin{itemize}
\item Type -- type of the array
\item Int -- location of the first element
\item Int -- array length
\end{itemize}
*/
syntax ArrayRef ::=   arrayRef (
                        Type,  // Type of the array
                        Int,   // Location of the first element
                        Int    // Length
                      )

syntax RawRefVal ::= ObjectRef | ArrayRef | String | "null"

/*@ A typed value is a pair of of a raw value and a type. Anywhere during execution we will evaluated typed expressions
    into typed values, never into raw values alone.
*/
syntax TypedVal ::= RawVal "::" Type

/*@ The three most common forms of computation result are Typed value or Type. Those are most common results
    we will encounter during elaboration. Other result types are more context-specific.
*/
syntax KResult ::= TypedVal | Type

/*@ Member access modes*/
syntax AccessMode ::= //"public" | "protected"  | "private"
Modifier | "package"
syntax KResult ::= AccessMode

syntax Modifier ::= "public"  [klabel('Public)]
                  | "private"  [klabel('Private)]
                  | "protected" [klabel('Protected)]
                  | "abstract"  [klabel('Abstract)]
                  | "final" [klabel('Final)]
                  | "static" [klabel('Static)]
                  | "native" [klabel('Native)]
                  | "transient" [klabel('Transient)]
                  | "volatile" [klabel('Volatile)]
                  | "strictfp" [klabel('StrictFP)]

/*@ Types of routines represented by a method closure*/
syntax MethodMetaType ::= "methodMMT" | "constructorMMT"

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

//Location type of each store location - either local variable or field
syntax LocMetadata ::= "LocalLocMetadata"   [latex(\terminal{Local})]
                     | "FieldLocMetadata"   [latex(\terminal{Field})]

//todo: why does this pure syntax definition affect krun?
//PackageName, AmbName and PackageorTypeName syntax doesn't cause problems
//                    syntax PackageName ::= List{Id,"."} [seqstrict, klabel('PackageName)]
//                     syntax ExprName::= Id  [strict, klabel('ExprName)]
//                                         |AmbName "." Id [strict, klabel('ExprName)]
//breaks if any other syntax is added
//                     syntax TypeName ::= Id [strict, klabel('TypeName)]
//                                         |PackageOrTypeName "." Id [strict, klabel('TypeName)]
//                     syntax AmbName ::= Id [strict, klabel('AmbName)]
//                                         |AmbName "." Id [strict, klabel('AmbName)]
//                     syntax MethodName ::= Id [strict,klabel('MethodName)]
//                                            |AmbName "." Id [strict,klabel('MethodName)]
//                     syntax PackageOrTypeName ::= Id [strict,klabel('PackageOrTypeName)]
//                                                   |PackageOrTypeName "." Id [strict,klabel('PackageOrTypeName)]
endmodule
