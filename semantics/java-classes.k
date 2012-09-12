module JAVA-CLASSES
    imports JAVA-CORE
    imports JAVA-EXPRESSIONS
    imports JAVA-STATEMENTS
    imports JAVA-ARRAYS

//@ \subsection{Unused Labels}
syntax KLabel ::= 'TypeImportOnDemandDec | 'PackageName | 'Final | 'Native

/*@ \subsection{Object and method closures}
The only change to untyped KOOL's values is that closures are now typed
(their last argument holds their type). */

//@ \subsection{Type labels}
//@Here we rewrite java type ast into simple types

rule 'TypeName(X:Id) => class X  [structural anywhere]

rule
    class X => rtString
when
    Id2String(X) ==String "String"
        [structural anywhere]

rule 'ClassOrInterfaceType(T,,_) => T [structural anywhere]

//@ \subsection{Auxiliary operations}

//@ \texttt{bindto} also checks the well-formedness of the method parameters

syntax K ::= "bindto" List{K} "," List{KResult}

rule [bindto]:
    <k>
      (. => 'ExprStm('Assign('ExprName(X),,TV:TypedVal)))
      ~> bindto( ('Param(_,,T:Type,,X) => .List{K}),, _:List{K} ),
          ( (TV => .List{K}),, _:List{K} )
      ...
    </k>
    <env> Env:Map => Env[L/X] </env>
    <store>... . => L |-> undefined :: T ...</store>
    <nextLoc> L:Int => L +Int 1 </nextLoc>

rule [bindtoEmpty]:
    <k> bindto .List{K},.List{K} => . ...</k>
        [structural]

//@ \texttt{typeOf and toString}

define typeOf('Param(_:K,,K:K,,_)) => K

define toString(objectClosure(I:Int, Obj:Bag) :: T)
    =>  'Invoke(
          'MethodName(objectClosure(I, Obj) :: T,, String2Id("toString")),,
          'ListWrap(.List{K})
        )

/*@ Recall that lists of the form "a,b,c" are a syntactic convenience,
which eventually are translated into cons-lists "(a,(b,(c,.)))".
Unfortunately, the current K tool is not able to cons-listify
the RHSes of the rules below, so we have to do it manually.  */

/*@ \subsection{Changes to SIMPLE Semantics}
We extend/change the semantics of several SIMPLE constructs in order
to take advantage of the richer KOOL semantic infrastructure and thus
get more from the existing SIMPLE constructs. */

//@ \texttt{typeOf for raw values of reference type}
define typeOf(Str:String) => rtString
define typeOf(null) => nullType
define typeOf(objectClosure(_, (<envStack>ListItem((Class:Id, _)) _</envStack>))) => class Class
define typeOf(arrayRef( arrayOf T, _, _)) => arrayOf T

/*@ \subsection{New}
The semantics of \texttt{new} in dynamically typed KOOL is also
similar to that in untyped KOOL, the main difference being the
management of the return types.  Indeed, when a new object is created
we also have to stack the current type in the \textsf{return} cell in
order to be recovered after the creation of the new object.  Only the
first rule below needs to be changed; the others are identical to
those in untyped KOOL. */

context 'NewInstance(_:K,,_:K,, 'ListWrap(_,,HOLE,,_),, _)

rule [NewInstance]:
    <k>
      'NewInstance(
        _:K,,
        class ClassName:Id,,
        'ListWrap( Vals:List{KResult} ),,
        _:K
      ) ~> K
      => create(ClassName) ~> storeObj
         ~> 'ExprStm('Invoke(
              'Method('MethodName( ClassName )),,
              'ListWrap( Vals )
            ))
         ~> 'Return('Some('This( .List{K} )))
    </k>
    <env> Env => . </env>
    <control>
      C:Bag
      <crntObj>
        Obj
        =>  <crntClass> .K </crntClass>
            <envStack> .List </envStack>
            <location> L </location>
      </crntObj>
      <return> T => class ClassName </return>
      <stack>
        . => ListItem((return, .K, .K, K, Env,
                       C <return> T </return> <crntObj> Obj </crntObj>))
        ...
      </stack>
    </control>
    <nextLoc> L => L +Int 1 </nextLoc>

syntax K ::= "create" "(" K ")"

rule [create]:
    <k>
      create(Class)
      => create(BaseClassK:K) ~> setCrntClass(Class) ~> S ~> addEnvLayer
      ...
    </k>
    <className> Class </className>
    <extends> BaseClassK </extends>
    <fieldDecs> S:K </fieldDecs>
        [structural]

rule [createEmptyDiscard]:
    <k> create( .K ) => . ...</k> [structural]

syntax K ::= "setCrntClass" "(" Id ")"

rule [setCrntClass]:
    <k> setCrntClass(Class) => . ...</k>
    <crntClass> _ => Class </crntClass>
        [structural]

syntax K ::= "addEnvLayer"

rule [addEnvLayer]:
    <k> addEnvLayer => . ...</k>
    <env> Env => . </env>
    <crntClass> Class </crntClass>
    <envStack> . => ListItem((Class, <env>Env</env>)) ...</envStack>
        [structural]

syntax K ::= "storeObj"

rule [storeObj]:
    <k> storeObj => . ...</k>
    <crntObj>
      Obj
      <crntClass> Class </crntClass>
      <location> L </location>
    </crntObj>
    <store>
      ...
      . => L |-> objectClosure(L, Obj) :: class Class
      ...
    </store>

syntax K ::= "buildMethodClosures" "(" Map ")"

/*@ \subsection{Instance Of}
Like in untyped KOOL. */

syntax KLabel ::= 'InstanceOf [seqstrict]

rule [InstanceOf]:
    'InstanceOf(V::_,, RT2)
    =>  #if V =/=K null
          #then subtype(typeOf(V), RT2)
          #else false::bool
        #fi

/*@ \subsection{Cast}
Unlike in untyped KOOL, in typed KOOL we actually check that the object
can indeed be cast to the claimed type. */

syntax KLabel ::= 'CastRef
rule 'CastRef(K1:K,, K2:K) => castImpl(K1,K2)   [structural]

rule [CastRef]:
    <k>
      castImpl(RT1:RefType, V:RawVal :: RT2:RefType)
      =>  'If(
            subtype(typeOf(V), RT1),,
            (V::RT1),,
            'Throw('NewInstance(
                    'None(.List{K}),,
                    'class_(String2Id("ClassCastException")),,
                    'ListWrap( 'Plus('Plus(toString(typeOf(V)),, " cannot be cast to "::rtString),,
                        toString(RT1)) ),,
                    'None(.List{K})
                  ))
          )
      ...
    </k>

//@ \subsection{Names}

rule 'AmbName(Ks) => 'ExprName(Ks:List{K}) [structural anywhere]
rule 'Field(Ks) => 'ExprName(Ks)   [structural anywhere]

rule [ExprNameLocalVar]:
    <k> 'ExprName(X) => X ...</k>
    <env> Env </env>
when X in keys(Env)
        [structural]

rule [ExprNameMember]:
    <k>
      'ExprName(X) => 'ExprName( 'This(.List{K}),, X )
      ...
    </k>
    <env> Env </env>
when
    notBool( X in keys(Env) orBool Id2String(X) ==String "System" )
        [structural]

context 'ExprName(HOLE,,_:K)

/*@ \subsection{Self reference}
Like in untyped KOOL. */

rule [This]:
    <k>
      'This(.List{K})
      => objectClosure(OL, Obj) :: class Class
      ...
    </k>
    <crntObj>
      Obj
      <crntClass> Class </crntClass>
      <location> OL:Int </location>
    </crntObj>

/*@ \subsection{Object member access} */

//o.x
rule [ExprNameQualified]:
    <k>
      'ExprName(
        objectClosure(_,
          <envStack>... ListItem((Class, EnvC:BagItem)) EStack:List </envStack>
        ) :: class Class,, X
      )
      => lookupField(<envStack>ListItem((Class, EnvC)) EStack</envStack>, X)
      ...
    </k>
        [structural]

rule [ExprNameQualifiedNull]:
    <k>
      'ExprName(null::_ ,, X)
      =>  'Throw('NewInstance(
            'None(.List{K}),,
            'class_(String2Id("NullPointerException")),,
            'ListWrap( null :: nullType ),,
            'None(.List{K})
          ))
      ...
    </k>
        [structural]

rule [SuperField]:
    <k>'SuperField(X) => lookupField(<envStack>EStack</envStack>, X) ...</k>
    <crntClass> Class </crntClass>
    <envStack>... ListItem((Class, EnvC)) EStack </envStack>
      [structural]

/*@ \subsection{Lookup member}
Like in untyped KOOL. */

syntax K ::= "(" Id "," BagItem ")"

//lookup field result is always typed
declare lookupField : BagItem Id -> K

define lookupField(
    <envStack>
      ListItem((_:Id, <env>... X|->L ...</env>))
      ...
    </envStack>,
    X
  ) => typedLookup(L)

define lookupField(
    <envStack>
      ListItem((_:Id, <env> Env </env>)) => .
      ...
    </envStack>,
    X
  )
when notBool(X in keys(Env))

//typed version of lookup
syntax K ::= "typedLookup" "(" Int ")"

rule [typedLookup]:
    <k> typedLookup(L) => lookup(L)::T ...</k>
    <store>... L |-> _::T ...</store>

rule [lvalueTypedLookup]:
    <k> lvalue( typedLookup(L) => lookup(L)::T ) ...</k>
    <store>... L |-> _::T ...</store>

//@ \texttt{lvalue}

rule [lvalueExprNameMember]:
    <k> lvalue( 'ExprName(X) => 'ExprName('This(.List{K}),, X) ) ...</k>
    <env> Env </env>
when notBool(X in keys(Env))  [structural]

context lvalue('ExprName(HOLE,, _:Id) )

rule [lvalueExprNameQualified]:
    <k>
      lvalue(
        'ExprName(
          objectClosure(_,
            <envStack>... ListItem((Class, EnvC:BagItem)) EStack </envStack>
          ) :: class Class,,
          X
        )
        => lookupField(
            <envStack> ListItem((Class, EnvC)) EStack:List </envStack>,
            X
          )
      )
      ...
    </k>
        [structural]

rule [lvalueSuperField]:
    <k> lvalue('SuperField(X) => lookupField(<envStack>EStack</envStack>, X)) ...</k>
    <crntClass> Class </crntClass>
    <envStack>... ListItem((Class, EnvC)) EStack </envStack>
        [structural]

end module
