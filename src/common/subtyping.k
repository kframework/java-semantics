module SUBTYPING
    imports CORE-CLASSES

//@ Checks whether first type is a subtype of the second
syntax Exp ::=  subtype (
                Type,
                Type
              )
              [strict]

/*@ Checks whether the each type in the first list of types is a subtype
of the type at the same position in the second list.
If lists have different size, the function will evaluate to false.
Used in method call overloading resolution.
*/
syntax KItem ::=  subtypeList ( Types, Types )

rule [subtype-same-type-True]:
    subtype( T:Type, T ) => true
        [structural]

/*@ \subsection{Subtyping among primitive types} */

rule subtype( byte, T:Type ) => (T ==K short) orBool (T ==K int) orBool (T ==K long) orBool (isFloatType(T) ==K true)
when T =/=K byte [structural]

rule subtype( short, T:Type ) => (T ==K int) orBool (T ==K long) orBool (isFloatType(T) ==K true)

when T =/=K short [structural]

rule subtype( int, T:Type ) => (T ==K long orBool isFloatType(T) ==K true)
when T =/=K int [structural]

rule subtype( long, T:Type ) => isFloatType(T) ==K true
when T =/=K long [structural]

rule subtype( char, T:Type ) => (T ==K int) orBool (T ==K long) orBool (isFloatType(T) ==K true)
when T =/=K char [structural]

rule subtype( float, T:Type ) => (T ==K double)
when T =/=K float [structural]

rule subtype( double, T:Type ) => false
when T =/=K double [structural]

rule subtype( bool, T:Type ) => false
when T =/=K bool [structural]

/*@ \subsection{Subtyping among reference types}
The subclass relation introduces a subtyping relation. */

rule [subtype-ClassOfClassRed]:
    <k> subtype( Class1:ClassType, Class:ClassType )
      => subtype( Class2:ClassType, Class ) ...</k>
    <class>
      <classType> Class1 </classType>
      <extends> Class2 </extends>
      <classMetaType> classCMT </classMetaType>
      ...
    </class>
    <class>
      <classType> Class </classType>
      <classMetaType> classCMT </classMetaType>
      ...
    </class>
when
    Class1 =/=K Class
        [structural]

rule [subtype-NoClassOfAnyFalse]:
    subtype( noClass, _ ) => false

//The case subtype (noClass, noClass) should never be encountered
//used by the rule [findQualifierOfType]
rule [subtype-AnyOfNoClassFalse]:
    subtype( _, noClass ) => true

rule [subtype-IInterfaceOfClass]:
    <k> subtype( Class1:ClassType, Class:ClassType ) => Class ==K classObject ...</k>
    <class>
      <classType> Class1 </classType>
      <classMetaType> interfaceCMT </classMetaType>
      ...
    </class>
    <class>
      <classType> Class </classType>
      <classMetaType> classCMT </classMetaType>
      ...
    </class>
/*
K Limitation: This way don't seem to work:
    <classType> Class1 </classType>
    <classMetaType> interfaceMetaT </classMetaType>
    <classType> Class </classType>
    <classMetaType> classMetaT </classMetaType>
*/

rule [subtype-OfInterface]:
    <k> subtype( Class1:ClassType, Class2:ClassType ) => Class2 in ISet ...</k>
    <class>
      <classType> Class1 </classType>
      <implTrans> ISet:Set </implTrans>
      ...
    </class>
    <class>
      <classType> Class2 </classType>
      <classMetaType> interfaceCMT </classMetaType>
      ...
    </class>

rule [subType-ClassOfOtherFalse]:
    subtype( _:ClassType, T:Type ) => false
when
    notBool (isClassType(T) ==K true)

rule [subtype-ArrayOfClass]:
    subtype( arrayOf _, Class:ClassType ) => Class ==K classObject

rule [subtype-ArrayOfOtherFalse]:
    subtype( arrayOf _, T:Type ) => false
when
            (getKLabel(T) =/=KLabel 'arrayOf_)
    andBool notBool (isClassType(T) ==K true)

rule [subtype-Null]:
    subtype( nullType, T:Type ) => (isRefType(T) ==K true)
        [structural]

//@ Subtype
rule [subtype-ArrayOfArrayPrimitive]:
    subtype( arrayOf T1:Type, arrayOf T2:Type ) => (T1 ==K T2)
when
    notBool (isRefType(T1) ==K true) orBool notBool (isRefType(T2) ==K true)

rule [subtype-ArrayOfArrayRef]:
    subtype( arrayOf RefT1:RefType, arrayOf RefT2:RefType ) => subtype( RefT1, RefT2 )

//used by lookupQThis, when QThis is an inferred qualifier for unqualified new instance creation.
rule [subtype-OfNoClass]:
    subtype( _, noClass ) => false

/*@ \subsection{Subtyping lists of types}*/

rule [subtypeList]:
    subtypeList(types(T1:Type,,Ts:KList), types(Tp1:Type,,Tps:KList))
    => andAux( subtype(T1,Tp1), subtypeList(types(Ts), types(Tps)) )
        [structural]

rule [subtypeList-EmptyLeft]:
    subtypeList(types(.KList), types(_:Type,,_)) => false
        [structural]

rule [subtypeList-EmptyRight]:
    subtypeList(types(_:Type,,_) , types(.KList)) => false
        [structural]

rule [subtypeList-EmptyBoth]:
    subtypeList(types(.KList), types(.KList)) => true
        [structural]

endmodule
