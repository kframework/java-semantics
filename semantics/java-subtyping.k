module JAVA-SUBTYPING
    imports JAVA-CORE

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
    <k> subtype( class Class1:Id, class Class:Id )
      => subtype( class Class2:Id, class Class ) ...</k>
    <class>
      <classSimpleName> Class1 </classSimpleName>
      <extends> Class2 </extends>
      ...
    </class>
    <class>
      <classSimpleName> Class </classSimpleName>
      <metaType> classMetaT </metaType>
      ...
    </class>
when
    (Class1 =/=K Class) andBool (Id2String(Class) =/=K "Object")
        [structural]

rule [subtypeClassOfClassFalse]:
    subtype( class X:Id, class Class:Id ) => false :: bool
when
            (Id2String(X) ==String "Object")
    andBool (X =/=K Class)

rule [subtypeInterfaceOfClass]:
    <k> subtype( class Class1:Id, class Class:Id ) => false::bool ...</k>
    <class>
      <classSimpleName> Class1 </classSimpleName>
      <metaType> interfaceMetaT </metaType>
      ...
    </class>
    <class>
      <classSimpleName> Class </classSimpleName>
      <metaType> classMetaT </metaType>
      ...
    </class>
when
    Id2String(Class) =/=K "Object"
        [structural]
/*
K Limitation: This way don't seem to work:
    <classSimpleName> Class1 </classSimpleName>
    <metaType> interfaceMetaT </metaType>
    <classSimpleName> Class </classSimpleName>
    <metaType> classMetaT </metaType>
*/

rule [subtypeOfObject]:
    subtype( class _, class Class:Id ) => true::bool
when
    Id2String(Class) ==K "Object"
        [structural]

rule [subtypeOfInterface]:
    <k> subtype( class Class1:Id, class Class:Id ) => (Class in ISet)::bool ...</k>
    <class>
      <classSimpleName> Class1 </classSimpleName>
      <implTrans> ISet:Set </implTrans>
      ...
    </class>
    <class>
      <classSimpleName> Class </classSimpleName>
      <metaType> interfaceMetaT </metaType>
      ...
    </class>

rule [subTypeClassOfOtherFalse]:
    subtype( class X:Id, T:Type ) => false :: bool
when
    getKLabel(T) =/=KLabel 'class_

rule [subtypeStringOfClass]:
    subtype( rtString, class Class:Id ) =>
    #if Id2String(Class) ==String "Object"
      #then true::bool
      #else false::bool
    #fi

rule [subtypeStringOfOtherFalse]:
    subtype( rtString, T:Type ) => false::bool
when
            getKLabel(T) =/=KLabel 'rtString
    andBool getKLabel(T) =/=KLabel 'class_

rule [subtypeArrayOfClass]:
    subtype( arrayOf _, class Class:Id ) =>
    #if Id2String(Class) ==String "Object"
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
