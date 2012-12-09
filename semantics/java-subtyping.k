require "java-core.k"
require "java-process-classes.k"

module JAVA-SUBTYPING
    imports JAVA-CORE
    imports JAVA-PROCESS-CLASSES

//Checks whether first type is a subtype of the second
syntax K ::= "subtype" "("
                          Type ","
                          Type
                       ")"

//Checks whether the each type in the first list of types is a subtype
//of the type at the same position inthe second list.
//If lists have different size, the function will evaluate to false.
//Used in method call overloading resolution.
            | "subtypeList" "(" Types ","
                                Types
                            ")"

rule [subtypeRefTrue]:
    subtype( T:Type, T ) => true :: bool
        [structural]

/*@ \subsubsection{Subtyping among primitive types} */

rule subtype( byte, T:Type )
=>  #if         (T ==K short)
        orBool  (T ==K int)
        orBool  (T ==K long)
      #then true :: bool
      #else false :: bool
    #fi
when T =/=K byte [structural]

rule subtype( short, T:Type )
=>  #if         (T ==K int)
        orBool  (T ==K long)
      #then true :: bool
      #else false :: bool
    #fi
when T =/=K short [structural]

rule subtype( int, T:Type )
=>  #if         T ==K long
      #then true :: bool
      #else false :: bool
    #fi
when T =/=K int [structural]

rule subtype( long, T:Type ) =>  false :: bool
when T =/=K long [structural]

rule subtype( char, T:Type )
=>  #if         (T ==K int)
        orBool  (T ==K long)
      #then true :: bool
      #else false :: bool
    #fi
when T =/=K char [structural]

rule subtype( bool, T:Type ) => false::bool
when T =/=K bool [structural]

/*@ \subsubsection{Subtyping among reference types}
The subclass relation introduces a subtyping relation. */

rule [subtypeClassOfClassRed]:
    <k> subtype( Class1:ClassType, Class:ClassType )
      => subtype( Class2:ClassType, Class ) ...</k>
    <class>
      <classType> Class1 </classType>
      <extends> Class2 </extends>
      ...
    </class>
    <class>
      <classType> Class </classType>
      <metaType> classMetaT </metaType>
      ...
    </class>
when
    (Class1 =/=K Class) andBool (Class =/=K class String2Id("Object"))
        [structural]

rule [subtypeClassOfClassFalse]:
    subtype( Class1:ClassType, Class2:ClassType ) => false :: bool
when
            (Class1 ==K class String2Id("Object"))
    andBool (Class1 =/=K Class2)

rule [subtypeInterfaceOfClass]:
    <k> subtype( Class1:ClassType, Class:ClassType ) => false::bool ...</k>
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
when
    Class =/=K class String2Id("Object")
        [structural]
/*
K Limitation: This way don't seem to work:
    <classType> Class1 </classType>
    <metaType> interfaceMetaT </metaType>
    <classType> Class </classType>
    <metaType> classMetaT </metaType>
*/

rule [subtypeOfObject]:
    subtype( _:ClassType, Class:ClassType ) => true::bool
when
    Class ==K class String2Id("Object")
        [structural]

rule [subtypeOfInterface]:
    <k> subtype( Class1:ClassType, Class:ClassType ) => (Class in ISet)::bool ...</k>
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
    subtype( _:ClassType, T:Type ) => false :: bool
when
    getKLabel(T) =/=KLabel 'class_

rule [subtypeStringOfClass]:
    subtype( rtString, Class:ClassType ) =>
    #if Class ==K class String2Id("Object")
      #then true::bool
      #else false::bool
    #fi

rule [subtypeStringOfOtherFalse]:
    subtype( rtString, T:Type ) => false::bool
when
            getKLabel(T) =/=KLabel 'rtString
    andBool getKLabel(T) =/=KLabel 'class_

rule [subtypeArrayOfClass]:
    subtype( arrayOf _, Class:ClassType ) =>
    #if Class ==K class String2Id("Object")
      #then true::bool
      #else false::bool
    #fi

rule [subtypeArrayOfOtherFalse]:
    subtype( arrayOf _, T:Type ) => false::bool
when
            (getKLabel(T) =/=KLabel 'arrayOf_)
    andBool (getKLabel(T) =/=KLabel 'class_)

rule [subtypeNull]:
    subtype( nullType, T:Type ) => isRefType2(T) :: bool
        [structural]

//@ Subtype
rule [subtypeArrayOfArrayPrimitive]:
    subtype( arrayOf T1:Type, arrayOf T2:Type ) => (T1 ==K T2)::bool
when
    notBool isRefType2(T1) orBool notBool isRefType2(T2)

rule [subtypeArrayOfArrayRef]:
    subtype( arrayOf RefT1:RefType, arrayOf RefT2:RefType ) => subtype( RefT1, RefT2 )

/*@ \subsubsection{Subtyping lists of types}*/

//Bug. Attempt to write a single rule instead of two below, using side conditions,
//leads to SUBSORT-TO-WRAPPERS
rule [subtypeList]:
    subtypeList(types(T1:Type,,Ts:List{K}), types(Tp1:Type,,Tps:List{K}))
    => 'LazyAnd( subtype(T1,Tp1),, subtypeList(types(Ts), types(Tps)) )
        [structural]

rule [subtypeListEmptyLeft]:
    subtypeList(types(.List{K}), types(_:Type,,_)) => false :: bool
        [structural]

rule [subtypeListEmptyRight]:
    subtypeList(types(_:Type,,_) , types(.List{K})) => false :: bool
        [structural]

rule [subtypeEmptyBoth]:
    subtypeList(types(.List{K}), types(.List{K})) => true :: bool
        [structural]

endmodule
