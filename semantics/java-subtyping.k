module JAVA-SUBTYPING
    imports JAVA-CORE

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
      <className> Class1 </className>
      <extends> Class2 </extends>
      ...
    </class>
    <class>
      <className> Class </className>
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
      <className> Class1 </className>
      <metaType> interfaceMetaT </metaType>
      ...
    </class>
    <class>
      <className> Class </className>
      <metaType> classMetaT </metaType>
      ...
    </class>
when
    Id2String(Class) =/=K "Object"
        [structural]
/*
K Limitation: This way don't seem to work:
    <className> Class1 </className>
    <metaType> interfaceMetaT </metaType>
    <className> Class </className>
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
      <className> Class1 </className>
      <implTrans> ISet:Set </implTrans>
      ...
    </class>
    <class>
      <className> Class </className>
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
rule [subtypeListLeft]:
    subtype(T1:Type,,T2:Type,,Ts:List{K}, Tp1:Type,,Tps:List{K})
    => 'LazyAnd( subtype(T1,Tp1),, subtype(T2,,Ts, Tps) )
when isKResult(Ts) andBool isKResult(Tps)
        [structural]

rule [subtypeListRight]:
    subtype(T1:Type,,Ts:List{K}, Tp1:Type,,Tp2:Type,,Tps:List{K})
    => 'LazyAnd( subtype(T1,Tp1),, subtype(Ts, Tp2,,Tps) )
when isKResult(Ts) andBool isKResult(Tps)
        [structural]

rule [subtypeEmptyLeft]:
    subtype(.List{K}, T:Type,,_) => false :: bool
        [structural]

rule [subtypeEmptyRight]:
    subtype(T:Type,,_ , .List{K}) => false :: bool
        [structural]

rule [subtypeEmpty]:
    subtype(.List{K}, .List{K}) => true :: bool
        [structural]

endmodule
