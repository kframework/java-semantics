//@ \section{Module CORE}

module CORE

//@ \subsection{Identifiers}

syntax ComputationPhase ::=
    /* The content of <typeNamesMap> is computed, of type
      Map[PackageName -> Map[SimpleName -> FullyQualifiedName]]
    */
    "ProcessTypeNamesPhase"

    /* Primary processing of type declarations, including nested.
      For each 'ClassDec a <class> is saved, with the following cells:
        <classType>
        <enclosingClass>
        <rawExtends>
        <rawImplements>
        <declarations>
        <metaType>
        <cuImports> - imports of the enclosing CU, for top-level classes only.
      A class first registered in a <class> cell is in the state CreatedCPP.
    */
  | "ProcessCompUnitsPhase"

  /* Resolve the fully qualified names of base classes an interfaces. Fills the content of:
        <extends> - the base class
        <implements> - the set of directly implemented interfaces
        <imports> - the map from simple names to full names for use within this class.
  */
  | "ProcessClassDecsPhase"

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
  | "ProcessClassesPhase"

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
  | "ElaborateBlocksPhase"

  /* When all preprocessing / elaboration phases are finished, the actual execution begins.
  */
  | "ExecutionPhase"

syntax ClassPreprocessingPhase ::= "CreatedCPP"
                                 | "BasesResolvedCPP"
                                 | "DecsProcessedCPP"
                                 | "MembersProcessedCPP"

//static initialization of a class. See static-init.k for more details.
syntax StaticInitStatus ::= "StaticUninitialized"
                          | "StaticInitializing" "(" Int ")"
                          | "StaticInitialized"

rule 'Id(Str:String) => String2Id(Str)                [structural, anywhere]

//@ \subsection{Types}

syntax IntOrLongType ::= "int" | "long"
syntax NumericType ::= IntType | FloatType
syntax IntType ::= "byte" | "short" | IntOrLongType | "char"
syntax FloatType ::= "float" | "double"
syntax PrimitiveType ::= NumericType | "bool"
syntax RefType ::= "rtString" | "nullType"

syntax Type ::= PrimitiveType
              | RefType
              | "void"
              | "rtType"
              | MethodType

syntax RawVal ::= Int | Float | Bool | String
                | "null"
                | "nothing"
                | "undefined" [latex(\bot)]

syntax ProtoMethodType ::= "methodType" "(" K ","             // to be processed into Types
                                            Type              // return type
                                        ")"
                          | MethodType

syntax MethodType ::= "methodType" "(" Signature "," // Method signature
                                       Type          // return type
                                   ")"

//A method signature
//KResult is required in java-method-invoke module
syntax Signature ::= "sig" "(" Id "," Types ")"
syntax KResult ::= Signature

syntax ClassType ::= "class" Id
                   | "noClass"

syntax RefType ::= ClassType
                 | "arrayOf" Type

syntax ContextType ::= "staticCT" | "instanceCT"
syntax KResult ::= ContextType

syntax Types ::= "types" "(" KList // list of Type elements, when processed
                         ")"
syntax KResult ::= Types

//@ \subsection{Values}

syntax RawVal ::= "objectClosure" "(" Int //OL - object location

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
                                    For local classes only */
                                  "," Map
                                  ")"

                | "methodClosure" "("
                    ClassType ","   // Class - class defining the method
                    K ","           // 'ListWrap(Params) - params
                    ContextType "," // Either staticCT, instanceCT
                    AccessMode ","  // The access mode
                    RoutineType "," // Either methodRT or constructorRT
                    K ","           // first line, constructors only. Either of:
                                    //   'SuperInv - superclass constructor invocation
                                    //   'AltConstrInv - alternate this class consturctor invocation
                                    //   .K - none, if this class is Object
                                    //   For methods it is noValue
                    K               // S - method body
                  ")"
                | "arrayRef" "("
                    Type ","  // Type of array
                    Int ","   // Location of the first element
                    Int       // Length
                  ")"

syntax TypedVal ::= RawVal "::" Type
syntax KResult ::= TypedVal | Type | Id

syntax TypedExp ::= K "::" Type
                  | TypedVal

syntax ProtoTypedExp ::= K "::" K       [strict(2)]
                       | TypedExp

syntax AccessMode ::= "public" | "protected" | "package" | "private"
syntax RoutineType ::= "methodRT" | "constructorRT"
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

/*@ \subsection{auxiliary constructs} */


/*toString - Converts various result types to string type, mainly for printing.*/

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

//@ \texttt{typeOf definition}

syntax K ::= "typeOf" "(" K ")"                           [function]
rule typeOf(_ :: T:Type) => T
rule typeOf(T:Type) => T

//default value of all types
syntax K ::= "default" "(" Type ")"                       [function]
rule default(IntT:IntType) => 0 :: IntT
rule default(FloatT:FloatType) => 0.0 :: FloatT
rule default(bool) => false :: bool
rule default(RT:RefType) => null :: RT

//@ \subsubsection{Default types for raw values}

//Converts a RawVal into a TypedVal, adding a default type for the given value.
//Greatly simplifies many rules, because now we can use raw vals in the RHS, instead of typed vals.
syntax K ::= "defaultTyped" "(" RawVal ")"

rule Val:RawVal => defaultTyped(Val)                                                  [structural]
rule defaultTyped(I:Int) => I :: int                                                  [structural]
rule defaultTyped(B:Bool) => B :: bool                                                [structural]
rule defaultTyped(Str:String) => Str :: rtString                                      [structural]
rule defaultTyped(null) => null :: nullType                                           [structural]
rule defaultTyped( objectClosure(
      OL:Int,
      ListItem(el(Class:ClassType, BI:BagItem, Encloser:KResult, LocalEnv:Map)) Rest:List,
      ObjLocalClassesEnv:Map
    ))
    => objectClosure(
      OL,
      ListItem(el(Class, BI, Encloser, LocalEnv)) Rest,
      ObjLocalClassesEnv
    ) :: Class
                                                                                      [structural]
rule defaultTyped(arrayRef(T:Type, L:Int, M:Int)) => arrayRef(T, L, M) :: T           [structural]

//@ \subsubsection{Auxiliary constructs for other modules}

syntax PackageId ::= "packageId" "(" Id ")"
syntax KResult ::= PackageId

//Converts a term of type ClassType into a term of type PackageId
//Used to represent a class as a package for its inner classes
syntax K ::= "toPackage"  "(" ClassType ")"   [function]
rule toPackage(class Class:Id) => packageId(Class)

//Returns the package of the given class
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

//Auxiliary construct - generalized equality suitable to compare not only TypedVal-s but any K terms.
syntax K ::= "eqAux" "(" K "," K ")"                  [seqstrict]
rule eqAux(KR1:KResult, KR2:KResult) => KR1 ==K KR2

//restore the content of cells <envGroup>, <crntObj>, <contextType>
syntax K ::= "restoreEnvObjContext" "(" Bag         //The content of <envGroup>
                                    "," Bag         //The content of <crntObj>
                                    "," ContextType //The content of <contextType>
                                    ")"

rule [restoreEnvObjContext]:
    <k> restoreEnvObjContext(EnvGroup:Bag, Obj:Bag, CT:ContextType) => . ...</k>
    <envGroup> _ => EnvGroup </envGroup>
    <crntObj> _ => Obj </crntObj>
    <contextType> _ => CT </contextType>

//The content of an ListItem() representing the old <envStack>
syntax K ::= "el" "(" ClassType //The class corresponding to the current layer
                  "," BagItem   //<env> instance fields </env>
                  "," K         //objectClosure(...)::_ - the enclosing object, or noValue for top-level classes
                  "," Map       //Map[Id ->Loc], enclosingLocalEnv, local classes only.
                  ")"

//A wrapper for maps. Allows the usage of multy-level maps.
//Also used as part of mapUnion operation in java-process-classes
syntax KResult ::= "mapWrap" "(" Map ")"
                 | "setWrap" "(" Set ")"

syntax KResult ::= "noValue"

syntax K ::= "objectClass"                              [function]
rule objectClass => class String2Id("java.lang.Object")

//Subsection mapUnion, union of maps. Remove when +Map will be implemented.
//In this operation, elements of the second map overwrite elements of the first map
//if they collide.
syntax K ::= "mapUnion" "(" K //mapWrap(Map)
                        "," K //mapWrap(Map)
                        ")"                   [strict]

rule mapUnion(mapWrap( M1:Map => M1[K2/K1] ), mapWrap( _:Map (K1:K |-> K2:K => .Map) ))
rule mapUnion(mapWrap(M1:Map), mapWrap(.Map)) => mapWrap(M1)

//Subsection setUnion, union of sets. Remove when +Set will be implemented.
syntax K ::= "setUnion" "(" K //setWrap(Set)
                        "," K //setWrap(Set)
                        ")"                   [strict]

rule setUnion(setWrap( S1:Set (. => SetItem(K)) ), setWrap( S2:Set (SetItem(K:K) => .) ))
when
    notBool(K in S1)
rule setUnion(setWrap( S1:Set SetItem(K) ), setWrap( S2:Set (SetItem(K:K) => .) ))
rule setUnion(setWrap(S1:Set), setWrap(.Set)) => setWrap(S1)

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

//Returns a setWrap(Set[ClassType]), containing all top level classes in the program.
//Uses <typeNamesMap> to compute the result.
syntax K ::= "getTopLevelClasses"
           | "getTopLevelClasses" "(" Map "," Set ")"

rule [getTopLevelClasses-start]:
    <k> getTopLevelClasses => getTopLevelClasses(NamesMap, .Set) ...</k>
    <typeNamesMap> NamesMap:Map </typeNamesMap>

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

//Returns a setWrap(Set[ClassType]), containing all direct inner classes of the given class.
//Uses <typeNamesMap> to compute the result.
syntax K ::= "getInnerClasses" "(" ClassType ")"
           | "getInnerClasses" "(" Map "," Set ")"

rule [getInnerClasses-start-have-inner]:
    <k> getInnerClasses(Class:ClassType) => getInnerClasses(InnerClassesMap, .Set) ...</k>
    <typeNamesMap>... Pack:PackageId |-> mapWrap(InnerClassesMap:Map) ...</typeNamesMap>
when
    Pack ==K toPackage(Class)

rule getInnerClasses( (_ |-> Class:ClassType => .Map) _, (.Set => SetItem(Class)) _)
rule getInnerClasses(.Map, ClassesSet:Set) => setWrap(ClassesSet)

rule [getInnerClasses-no-inners]:
    <k> getInnerClasses(Class:ClassType) => setWrap(.Set) ...</k>
    <typeNamesMap> TypeNamesMap:Map </typeNamesMap>
when
    notBool toPackage(Class) in keys(TypeNamesMap)

// Auxiliary constructs for elaboration.

//Custom hole used for custom heating/cooling rules across the semantics.
syntax K ::= "CHOLE"

syntax KResult ::= "stEnv" "(" Map ")"  //A layer of the static environment
                                        //Map[name -> Type]
                  | "classEnv" "(" Map ")"  //The declaration environment of a class
                                            //Map[name -> fieldEntry(...)]
                  | "fieldEntry" "(" ClassType   // target class
                                 "," Id          // X - field name
                                 "," Type        // Field type
                                 "," ContextType // staticCT | instanceCT
                                 ")"

//size of a KList
syntax K ::= "klsize" "(" KList ")"               [function]
rule klsize(.KList) => 0                          [anywhere]
rule klsize(_:K,, Ks:KList) => klsize(Ks) +Int 1  [anywhere]

endmodule
