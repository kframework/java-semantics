require "java-core.k"
require "java-process-classes.k"

module JAVA-SUBTYPING
    imports JAVA-CORE
    imports JAVA-PROCESS-CLASSES

//Checks whether first type is a subtype of the second
syntax K ::= "subtype" "("
                          Type ","
                          Type
                       ")"                      [strict]

//Checks whether the each type in the first list of types is a subtype
//of the type at the same position inthe second list.
//If lists have different size, the function will evaluate to false.
//Used in method call overloading resolution.
            | "subtypeList" "(" Types ","
                                Types
                            ")"

rule [subtypeRefTrue]:
    subtype( T:Type, T ) => true
        [structural]

/*@ \subsubsection{Subtyping among primitive types} */

rule subtype( byte, T:Type ) => (T ==K short) orBool (T ==K int) orBool (T ==K long)
when T =/=K byte [structural]

rule subtype( short, T:Type ) => (T ==K int) orBool (T ==K long)

when T =/=K short [structural]

rule subtype( int, T:Type ) => T ==K long
when T =/=K int [structural]

rule subtype( long, T:Type ) => false
when T =/=K long [structural]

rule subtype( char, T:Type ) => (T ==K int) orBool (T ==K long)
when T =/=K char [structural]

rule subtype( bool, T:Type ) => false
when T =/=K bool [structural]

/*@ \subsubsection{Subtyping among reference types}
The subclass relation introduces a subtyping relation. */

rule [subtypeClassOfClassRed]:
    <k> subtype( Class1:ClassType, Class:ClassType )
      => subtype( Class2:ClassType, Class ) ...</k>
    <class>
      <classType> Class1 </classType>
      <extends> Class2 </extends>
      <metaType> classMetaT </metaType>
      ...
    </class>
    <class>
      <classType> Class </classType>
      <metaType> classMetaT </metaType>
      ...
    </class>
when
    Class1 =/=K Class
        [structural]

rule [subtypeClassOfClassFalse]:
    subtype( noClass, _ ) => false

rule [subtypeInterfaceOfClass]:
    <k> subtype( Class1:ClassType, Class:ClassType ) => Class ==K objectClass ...</k>
    <class>
      <classType> Class1 </classType>
      <metaType> interfaceMetaT </metaType>
      ...
    </class>
    <class>
      <classType> Class </classType>
      <metaType> classMetaT </metaType>
      ...
    </class>
/*
K Limitation: This way don't seem to work:
    <classType> Class1 </classType>
    <metaType> interfaceMetaT </metaType>
    <classType> Class </classType>
    <metaType> classMetaT </metaType>
*/

rule [subtypeOfInterface]:
    <k> subtype( Class1:ClassType, Class:ClassType ) => Class in ISet ...</k>
    <class>
      <classType> Class1 </classType>
      <implTrans> ISet:Set </implTrans>
      ...
    </class>
    <class>
      <classType> Class </classType>
      <metaType> interfaceMetaT </metaType>
      ...
    </class>

rule [subTypeClassOfOtherFalse]:
    subtype( _:ClassType, T:Type ) => false
when
    getKLabel(T) =/=KLabel 'class_

rule [subtypeStringOfClass]:
    subtype( rtString, Class:ClassType ) => Class ==K objectClass

rule [subtypeStringOfOtherFalse]:
    subtype( rtString, T:Type ) => false
when
            getKLabel(T) =/=KLabel 'rtString
    andBool getKLabel(T) =/=KLabel 'class_

rule [subtypeArrayOfClass]:
    subtype( arrayOf _, Class:ClassType ) => Class ==K objectClass

rule [subtypeArrayOfOtherFalse]:
    subtype( arrayOf _, T:Type ) => false
when
            (getKLabel(T) =/=KLabel 'arrayOf_)
    andBool (getKLabel(T) =/=KLabel 'class_)

rule [subtypeNull]:
    subtype( nullType, T:Type ) => (isRefType(T) ==K true)
        [structural]

//@ Subtype
rule [subtypeArrayOfArrayPrimitive]:
    subtype( arrayOf T1:Type, arrayOf T2:Type ) => (T1 ==K T2)
when
    notBool (isRefType(T1) ==K true) orBool notBool (isRefType(T2) ==K true)

rule [subtypeArrayOfArrayRef]:
    subtype( arrayOf RefT1:RefType, arrayOf RefT2:RefType ) => subtype( RefT1, RefT2 )

/*@ \subsubsection{Subtyping lists of types}*/

rule [subtypeList]:
    subtypeList(types(T1:Type,,Ts:List{K}), types(Tp1:Type,,Tps:List{K}))
    => 'LazyAnd( subtype(T1,Tp1),, subtypeList(types(Ts), types(Tps)) ) :: bool
        [structural]

rule [subtypeListEmptyLeft]:
    subtypeList(types(.List{K}), types(_:Type,,_)) => false
        [structural]

rule [subtypeListEmptyRight]:
    subtypeList(types(_:Type,,_) , types(.List{K})) => false
        [structural]

rule [subtypeEmptyBoth]:
    subtypeList(types(.List{K}), types(.List{K})) => true
        [structural]

endmodule
