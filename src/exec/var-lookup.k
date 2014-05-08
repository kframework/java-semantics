//@ \section{Module VAR-LOOKUP}

module VAR-LOOKUP
    imports CORE-SORTS
    imports SUBTYPING
    imports STATIC-INIT         //for staticInit()
    imports EXPRESSIONS

//@ \subsection{Local variable access}

/*@ Local variable access. At runtime may have one form:
    - 'ExprName(X:Id) - local variable
*/
syntax KLabel ::= "'ExprName"

/*@ At execution phase 'ExprName(X) always represent a local variable.
*/
rule [ExprName-local]:
    <k> 'ExprName(X:Id) => typedLookup(L) ...</k>
    <env>... X |-> L:Int ...</env>

rule [lvalue-ExprName-local]:
    <k> lvalue('ExprName(X:Id)) => typedLoc(L) ...</k>
    <env>... X |-> L:Int ...</env>

/*@ \subsection{QThis - Self reference} */

//@ 'QThis(Class:ClassType)
syntax KLabel ::= "'QThis"

rule [QThis]:
    <k>
      'QThis(Class:ClassType) => lookupQThis(Class, RV::CrntClass)
      ...
    </k>
    <crntClass> CrntClass:ClassType </crntClass>
    <location> OL:Int </location>
    <store>
      ...
      OL |-> RV:RawVal :: _
      ...
    </store>

//@ Search for the right value representing QThis(Class) - an expression of type Class.this
syntax K ::=  lookupQThis (
                ClassType,  //the type of this to look for,
                TypedVal    //the objectRef where the type should be found
              )

rule [lookupQThis-found]:
    lookupQThis(Class:ClassType, RV:RawVal::Class) => RV::Class

/*@ When we have QThis target class Class, and we look for it in a target object with a different
compile-time type ObjClass, we continue our search in the enclosing object of the layer corresponding to ObjClass.
This way we may have O.B < O.A, with layers O.B and O.A having different enclosing instance of O,
and we will be able to pick the correct enclosing object inside both O.A and O.B.
*/
rule [lookupQThis-next]:
    <k>
      lookupQThis(Class:ClassType,
        objectRef(OId:Int, _) :: RefClass:ClassType
      ) => lookupQThis(Class:ClassType, EnclosingObj)
      ...
    </k>
    <objectId> OId </objectId>
    <layerClass> RefClass </layerClass>
    <layerEnclosingObject> EnclosingObj:KResult </layerEnclosingObject>
when
    Class =/=K RefClass

/*@ \subsection{Instance field access} */

/*@ Variable access. May have 2 forms:
    - 'ExprName(Class, X:Id) - static field
    - 'ExprName(Qual, X:Id) - instance field
*/
syntax KLabel ::= "'Field"

context 'Field(HOLE,, _)
context lvalue('Field(HOLE,, _))

rule [Field-instance]:
    <k>
      'Field(
        objectRef(OId:Int, _ ) :: TargetClass:ClassType,,
        X:Id
      ) => typedLookup(L)
      ...
    </k>
    <objectId> OId </objectId>
    <layerClass> TargetClass </layerClass>
    <layerEnv>... X |-> L:Int ...</layerEnv>

rule [lvalue-Field-instance]:
    <k>
      lvalue('Field(
        objectRef(OId:Int, _ ) :: TargetClass:ClassType,,
        X:Id
      )) => lvalue(typedLookup(L))
      ...
    </k>
    <objectId> OId </objectId>
    <layerClass> TargetClass </layerClass>
    <layerEnv>... X |-> L:Int ...</layerEnv>

rule [Field-instance-OfNull]:
    'Field(null::_,, _)
    =>  'Throw('NewInstance(
          'None(.KList),,
          nullPEClass,,
          [ null::stringClass],,
          'None(.KList)
        ))
        [anywhere]

/*@ \subsection{Static field access} */

rule [Field-static]:
    'Field( TargetClass:ClassType,, X:Id )
    => staticInit(TargetClass) ~> staticFieldLookup(TargetClass, X)

rule [lvalue-Field-static]:
    lvalue('Field( TargetClass:ClassType,, X:Id ))
    => staticInit(TargetClass) ~> lvalue(staticFieldLookup(TargetClass, X))

/*@ The actual implementation of static field lookup. The distinction between this function and
    'Field(Class, X) term is that at the moment when this function is called the target clas is
    surely initialized.
*/
syntax K ::= staticFieldLookup ( ClassType , Id )

rule [staticFieldLookup]:
    <k>
      staticFieldLookup(
        TargetClass:ClassType,
        X:Id
      )
      => typedLookup(L)
      ...
    </k>
    <classType> TargetClass </classType>
    <staticEnv>... X |-> L:Int ...</staticEnv>

rule [lvalue-Field-static]:
    <k>
      lvalue(staticFieldLookup(
        TargetClass:ClassType,
        X:Id
      ))
      => lvalue(typedLookup(L))
      ...
    </k>
    <classType> TargetClass </classType>
    <staticEnv>... X |-> L:Int ...</staticEnv>

/*@ \subsection{lvalue and loc} */

//@ Typed version of lookup and loc
syntax K ::= typedLookup ( Int )

rule [typedLookup]:
    <k> typedLookup(L:Int) => lookup(L, T) ...</k>
    <store>... L |-> _::T:Type ...</store>

rule [lvalue-typedLookup]:
    lvalue( typedLookup(L:Int) ) => typedLoc(L)

syntax K ::= typedLoc ( Int )

rule [typedLoc]:
    <k> typedLoc(L:Int) => loc(L)::T ...</k>
    <store>... L |-> _::T:Type ...</store>

rule [lvalue-typedLoc]:
    lvalue(typedLoc(L:Int)) => typedLoc(L)

/*@ \subsection{lookup} */

/*@ Retrieve a value from the store based on its location and the given compile-time type.
  May be wrapped inside lvalue. If lookup is unwrapped, it evaluates to TypedVal - the store value,
  of the type T - the second lookup argument. If lookup is wrapped into lvalue, it evaluates to loc(OL)::T.
*/
syntax Lookup ::= lookup (
                    Int,  //OL - the store location to lookup
                    Type  // T - the compile-time type of the resulting value
                  )

rule [lookup-Location]:
    <k>
      lookup(L:Int, T1:Type) => subtype(T2, T1) ~> true? ~> (V::T1)
      ...
    </k>
    <store>... L |-> V:RawVal :: T2:Type ...</store>
        [transition-threading]

rule lvalue(lookup(L:Int, T:Type)) => loc(L)::T
        [structural]

endmodule
