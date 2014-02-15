//@ \section{Module CORE}

module CORE

//@ \subsection{Computation phases}

/*@
The computation Global Phase. See configuration documentation for details.
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
        <metaType>
        <cuImports> - imports of the enclosing CU, for top-level classes only.
      A class first registered in a <class> cell is in the state CreatedCPhase.
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
        <fieldDecs>
        <methods>
        <methodDecs>
        <instanceInit>
        <staticEnv>
        <staticInit>
  */
  | "ProcClassMembersPhase"

  /* Elaborates the content of each code block. Specifically the content of the following cells:
        <methodDecs>
        <instanceInit>
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

  /* When all preprocessing / elaboration phases are finished, the actual execution begins.
  */
  | "ExecutionPhase"

/*@ the class phase. See configuration documentation for details.*/
syntax ClassPhase ::=
    "CreatedCPhase"
  | "BasesResolvedCPhase"
  | "DecsProcessedCPhase"
  | "MembersProcessedCPhase"

/*@
  The state of a class in relation to static initialization. See static-init.k for more details.
*/
syntax StaticInitStatus ::= "StaticUninitialized"
                          | "StaticInitializing" "(" Int ")"
                          | "StaticInitialized"

//@ \subsection{Types}

syntax IntOrLongType ::= "int" | "long"
syntax NumericType ::= IntType | FloatType
syntax IntType ::= "byte" | "short" | IntOrLongType | "char"
syntax FloatType ::= "float" | "double"
syntax PrimitiveType ::= NumericType | "bool"
syntax RefType ::= "rtString" | "nullType"

syntax Type ::= PrimitiveType
              | RefType
              | MethodType
              | "void"

/*@ The interface of a method - signature and return type.
*/
syntax MethodType ::= "methodType" "(" Signature "," // method signature
                                       Type          // return type
                                   ")"

/*@A method signature. Required to be KResult by rules in METHOD-INVOKE.*/
syntax Signature ::= "sig" "(" Id "," Types ")"
syntax KResult ::= Signature

/*@A fully qualified class name, or noClass where no valid class could be computed.*/
syntax ClassType ::= "class" Id
                   | "noClass"

/*A reference type is either a class type, an array type, the null type or a String type. null type is specified by the JLS although inaccessible to the programmer. String objects and types are not threated as regular objects in the present semantics for performance reasons.*/
syntax RefType ::= ClassType
                 | "arrayOf" Type
                 | "nullType"
                 | "rtString"

/*@ The member accessibility context of the current method - either static or instance.*/
syntax ContextType ::= "staticCT" | "instanceCT"
syntax KResult ::= ContextType

/*@ A list of types. Elements are of sort Type. Used especially to denote argument types of a method.*/
syntax Types ::= "types" "(" KList // list of Type elements, when processed
                         ")"
syntax KResult ::= Types

//@ \subsection{Values}

/*Represents a java value. May be either primitive - int, float, bool, of reference. The values nothing and undefined are special cases required by the semantics. The value nothing is associated with the return type void. The value undefined is the initial value of uninitialized local variables, before the first assignment.*/
syntax RawVal ::= Int | Float | Bool | RawRefVal
                | "nothing"
                | "undefined" [latex(\bot)]

/*@A reference value, in its four forms - as regular object, array, null or String. As mentioned previously String values have special treatment in this semantics and are implemented as regular strings.

The object closure have the following structure:
\begin{itemize}
\item OL:Int -- the object location
\item List -- the object content, of the form
\begin{verbatim}
  ListItem(el(
    Class,
    <env>Env</env>,
    enclosingObjClosure::T,
    enclosingLocalEnv:Map
  ))
  ...
\end{verbatim}
\item Map -- The init content of <localClassesEnv> when methods are invoked. For local classes only.
\end{itemize}
*/
syntax RawRefVal ::=
                   "objectClosure" "(" Int //OL - object location

                                  /*The object content, of the form:
                                    ListItem(el(
                                      Class,
                                      <env>Env</env>,
                                      enclosingObjClosure::T,
                                      enclosingLocalEnv:Map
                                    ))
                                    ...
                                  */
                                  "," List

                                  /*The init content of <localClassesEnv> when methods are invoked.
                                    For local classes only. */
                                  "," Map
                                  ")"

/*@
The arrayRef have the following structure:
\begin{itemize}
\item Type -- type of the array
\item Int -- location of the first element
\item Int -- array length
\end{itemize}
*/
syntax RawRefVal ::=
                  "arrayRef" "("
                    Type ","  // Type of the array
                    Int ","   // Location of the first element
                    Int       // Length
                  ")"

syntax RawRefVal ::= String | "null"

/*@
Represents either a method or a constructor. This record contains all the information stored in the method/constructor definition, except the name, plus other info:
\begin{itemize}
\item Class:ClassType -- class defining the method
\item 'ListWrap(Params):K -- params
\item ContextType -- Either staticCT, instanceCT
\item AccessMode -- The access mode
\item RoutineType -- Either methodRT or constructorRT
\item K -- first line, constructors only. Either of:
  \begin{itemize}
  \item 'SuperInv -- superclass constructor invocation
  \item 'AltConstrInv -- alternate this class constructor invocation
  \item .K -- none, if this class is Object
  \end{itemize}
    For methods this argument is noValue
\item S:K -- method body
\end{itemize}
*/
syntax RawVal ::= "methodClosure" "("
                    ClassType ","   // Class - class defining the method
                    K ","           // 'ListWrap(Params) - params
                    ContextType "," // Either staticCT, instanceCT
                    AccessMode ","  // The access mode
                    RoutineType "," // Either methodRT or constructorRT
                    K ","           // first line, constructors only. Either of:
                                    //   'SuperInv - superclass constructor invocation
                                    //   'AltConstrInv - alternate this class constructor invocation
                                    //   .K - none, if this class is Object
                                    //   For methods this argument is noValue
                    K               // S - method body
                  ")"
/*@
A typed value is a pair of of a raw value and a type. Anywhere during execution we will evaluated typed expressions into typed values, never into raw values alone.
*/
syntax TypedVal ::= RawVal "::" Type

/*@
The three most common forms of computation result are Typed value, Type or Id. Those are most common results we will encounter during elaboration. Other result types are more context-specific.
*/
syntax KResult ::= TypedVal | Type | Id

/*@
A Typed expression is an expression followed by its compile-time type. This, among with Type is the most common form of computation result during elaboration. However, TypedExp is not a result during execution. This is why we cannot subsort it to KResult.
*/
syntax TypedExp ::= K "::" Type
                  | TypedVal

/*@ Member access modes*/
syntax AccessMode ::= "public" | "protected" | "package" | "private"
syntax KResult ::= AccessMode

/*@ Types of routines represented by a method closure*/
syntax RoutineType ::= "methodRT" | "constructorRT"

/*K limitation: this construct cannot be called ClassType. If we do this, any execution will result in an infinite loop.
*/
/*@ The two possibilities for a type represented by an objectClosure: class or interface.*/
syntax MetaType ::= "classMetaT" | "interfaceMetaT"

/*@ \subsection{Identifiers}*/

/*@Convert the AST representation of an Id into an K Id.*/
rule 'Id(Str:String) => String2Id(Str)                [structural, anywhere]

//@ \subsection{Packages}

/*@A Java package.*/
syntax PackageId ::= "packageId" "(" Id ")"
syntax KResult ::= PackageId

/*@
Converts a term of type ClassType into a term of type PackageId representing this class. This is the package for this class' inner classes.
*/
syntax K ::= "toPackage"  "(" ClassType ")"   [function]
rule toPackage(class Class:Id) => packageId(Class)

/*@Returns the package of the given class*/
syntax K ::= "getPackage" "(" K ")"               [strict]
rule [getPackage]:
    <k> getPackage(Class:ClassType) => Pack ...</k>
    <namesToClasses>... Pack:PackageId |-> mapWrap(_ |-> Class _) ...</namesToClasses>

/*@Returns the top-level class enclosing this class*/
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

/*@ \subsection{Auxiliary constructs} */

/*@ \texttt{Generic guard.}
A generic computational guard (should be builtin): it allows the computation to continue only if a prefix guard evaluates to true.
*/
syntax K ::= "true?"
rule true::bool ~> true? => .  [structural]

//todo move toString to a separate file, collect implementation from all other files.
/*@Converts all possible Java values into String. Used mostly for printing and String + operator. Conversion for other value forms is defined in other modules.*/
syntax K ::= "toString" "(" K ")"   [strict]

rule toString(Str:String :: _) => Str
rule toString(I:Int :: char) => chrChar(I)
rule toString(I:Int :: T:Type) => Int2String(I)
    when T =/=K char
rule toString(Fl:Float :: _) => Float2String(Fl)
rule toString(true::_) => "true"
rule toString(false::_) => "false"
rule toString(null::_) => "null"

rule toString(rtString) => "java.lang.String"

//@ \texttt{Type of a value}

/*todo move into separate file*/
/*@For a type - the type itself. for a typed expression - the type component. For some raw values - their most common type.
The semantics uses both typeOf(RawVal) and typeOf(TypedVal). Not sure about typeOf(Type)
*/
syntax K ::= "typeOf" "(" K ")"                           [function]
rule typeOf(_ :: T:Type) => T
rule typeOf(T:Type) => T

/*@The default value for all types. Used for field initializers.*/
syntax K ::= "default" "(" Type ")"                       [function]
rule default(IntT:IntType) => 0 :: IntT
rule default(FloatT:FloatType) => 0.0 :: FloatT
rule default(bool) => false :: bool
rule default(RT:RefType) => null :: RT

/*@
Converts a RawVal into a TypedVal, by adding a default type for the given value.
Greatly simplifies many rules, because now we can use raw values in the RHS, instead of typed values.
*/
syntax K ::= "defaultTyped" "(" RawVal ")"

rule Val:RawVal => defaultTyped(Val)                                                  [structural]
rule defaultTyped(I:Int) => I :: int                                                  [structural]
rule defaultTyped(B:Bool) => B :: bool                                                [structural]
rule defaultTyped(Str:String) => Str :: rtString                                      [structural]
rule defaultTyped(null) => null :: nullType                                           [structural]
rule defaultTyped( objectClosure(
      OL:Int,
      ListItem(el(Class:ClassType, BI:BagItem, EnclosingObj:KResult, LocalEnv:Map)) Rest:List,
      ObjLocalClassesEnv:Map
    ))
    => objectClosure(
      OL,
      ListItem(el(Class, BI, EnclosingObj, LocalEnv)) Rest,
      ObjLocalClassesEnv
    ) :: Class
                                                                                      [structural]
rule defaultTyped(arrayRef(T:Type, L:Int, M:Int)) => arrayRef(T, L, M) :: T           [structural]

//@ \subsubsection{Other auxiliary constructs}

/*@
Generalized equality with strictness, suitable to compare not only TypedVal-s but any K terms.
*/
syntax K ::= "eqAux" "(" K "," K ")"                  [seqstrict]
rule eqAux(KR1:KResult, KR2:KResult) => KR1 ==K KR2

//todo move this somewhere else
/*@
The content of a ListItem() representing the old <envStack>
*/
syntax K ::= "el" "(" ClassType //The class corresponding to the current layer
                  "," BagItem   //<env> instance fields </env>
                  "," K         //objectClosure(...)::_ - the enclosing object, or noValue for top-level classes
                  "," Map       //Map[Id ->Loc], enclosingLocalEnv, local classes only.
                  ")"

/*@A wrapper for maps. Allows holding maps inside an arbitrary expression where a K term is required. Also used as part of mapUnion operation in PROCESS-CLASS-MEMBERS
*/
syntax KResult ::= "mapWrap" "(" Map ")"
                 | "setWrap" "(" Set ")"

syntax KResult ::= "noValue"

syntax K ::= "objectClass"                              [function]
rule objectClass => class String2Id("java.lang.Object")

/*@The union of two maps. Arguments are of the form mapWrap(Map). In this operation, elements of the second map overwrite elements of the first map if they collide.
*/
syntax K ::= "mapUnion" "(" K //mapWrap(Map)
                        "," K //mapWrap(Map)
                        ")"                   [strict]

rule mapUnion(mapWrap( M1:Map => M1[K2/K1] ), mapWrap( _:Map (K1:K |-> K2:K => .Map) ))
rule mapUnion(mapWrap(M1:Map), mapWrap(.Map)) => mapWrap(M1)

/*@A wrapper for sets, similar to the one for maps.*/
syntax KResult ::= "setWrap" "(" Set ")"

/*The union of two sets. Arguments are of the form setWrap(Set).*/
syntax K ::= "setUnion" "(" K //setWrap(Set)
                        "," K //setWrap(Set)
                        ")"                   [strict]

rule setUnion(setWrap( S1:Set (. => SetItem(K)) ), setWrap( S2:Set (SetItem(K:K) => .) ))
when
    notBool(K in S1)
rule setUnion(setWrap( S1:Set SetItem(K) ), setWrap( S2:Set (SetItem(K:K) => .) ))
rule setUnion(setWrap(S1:Set), setWrap(.Set)) => setWrap(S1)

/*@Extracts the access mode from the list of modifiers of some Java entity.*/
syntax K ::= "getAccessMode" "(" K //'ListWrap(...) - the list of class/method attributes
                             ")"                              [function]

rule getAccessMode('ListWrap('Public(_),,_))    => public
rule getAccessMode('ListWrap('Protected(_),,_)) => protected
rule getAccessMode('ListWrap('Private(_),,_))   => private

rule getAccessMode('ListWrap((KL:KLabel(_) => .KList),, _))
when        (KL =/=KLabel 'Public)
    andBool (KL =/=KLabel 'Protected)
    andBool (KL =/=KLabel 'Private)

rule getAccessMode('ListWrap(.KList)) => package

/*@Returns a setWrap(Set[ClassType]), containing all top level classes in the program. Uses <namesToClasses> to compute the result. Used by the starting rule of several preprocessing phases.
*/
syntax K ::= "getTopLevelClasses"
           | "getTopLevelClasses" "(" Map "," Set ")"

rule [getTopLevelClasses-start]:
    <k> getTopLevelClasses => getTopLevelClasses(NamesMap, .Set) ...</k>
    <namesToClasses> NamesMap:Map </namesToClasses>

rule [getTopLevelClasses-top-level]:
    <k>
      getTopLevelClasses(_ _ |-> mapWrap(_ (_ |-> Class:ClassType => .Map)), _ (.Set => SetItem(Class)))
      ...
    </k>
    <classType> Class </classType>
    <enclosingClass> noClass </enclosingClass>

rule [getTopLevelClasses-not-top-level]:
    <k>
      getTopLevelClasses(_ _ |-> mapWrap(_ (_ |-> Class:ClassType => .Map)), _)
      ...
    </k>
    <classType> Class </classType>
    <enclosingClass> class _ </enclosingClass>

rule getTopLevelClasses(_ (_ |-> mapWrap(.Map) => .Map), _)
rule getTopLevelClasses(.Map, ClassesSet:Set) => setWrap(ClassesSet)

/*@Returns a setWrap(Set[ClassType]), containing all direct inner classes of the given class. Uses <namesToClasses> to compute the result.
*/
syntax K ::= "getInnerClasses" "(" ClassType ")"
           | "getInnerClasses" "(" Map "," Set ")"

rule [getInnerClasses-start-have-inner]:
    <k> getInnerClasses(Class:ClassType) => getInnerClasses(InnerClassesMap, .Set) ...</k>
    <namesToClasses>... Pack:PackageId |-> mapWrap(InnerClassesMap:Map) ...</namesToClasses>
when
    Pack ==K toPackage(Class)

rule getInnerClasses( (_ |-> Class:ClassType => .Map) _, (.Set => SetItem(Class)) _)
rule getInnerClasses(.Map, ClassesSet:Set) => setWrap(ClassesSet)

rule [getInnerClasses-no-inners]:
    <k> getInnerClasses(Class:ClassType) => setWrap(.Set) ...</k>
    <namesToClasses> TypeNamesMap:Map </namesToClasses>
when
    notBool toPackage(Class) in keys(TypeNamesMap)

/*@Wrappers for some terms used in multiple preprocessing phases.*/
syntax KResult ::= "stEnv" "(" Map ")"  //A layer of the static environment
                                        //Map[name -> Type]
                  | "fieldEntry" "(" ClassType   // target class
                                 "," Id          // X - field name
                                 "," Type        // Field type
                                 "," ContextType // staticCT | instanceCT
                                 ")"

endmodule
