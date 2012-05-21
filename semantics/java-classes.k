module JAVA-CLASSES
    imports JAVA-CORE
    imports JAVA-EXPRESSIONS
    imports JAVA-STATEMENTS
    imports JAVA-ARRAYS
    imports CLASS-DEC-RuntimeException
    imports CLASS-DEC-AssertionError

syntax Type ::= "function" "from" List{KResult} "to" Type
                  [prec(1) latex "({#1}\ \texttt{->}\ {#2})"]
              | "class" Id

syntax RawVal ::= "objectClosure" "(" Bag ")"
                | "methodClosure" "("
                    Id ","   // F - method name
                    Int ","  // OL - object location
                    K ","     // 'ListWrap(Params) - params
                    K ","     // S - method body
                    Type      // MethodType
                  ")"

//@ \subsection{Unused Labels}
syntax KLabel ::= 'Static | 'TypeImportOnDemandDec | 'PackageName

/*@ \subsection{Object and method closures}
The only change to untyped KOOL's values is that closures are now typed
(their last argument holds their type). */

//@ \subsection{Type labels}
//@Here we rewrite java type ast into simple types

rule 'ClassOrInterfaceType('TypeName(K),,_) => 'TypeName(K) [structural]
rule 'TypeName(X:Id) => class X  [structural]

rule
    class X => rtString
when
    Id2String(X) ==String "String"
        [structural]

/*@ \subsection{Method declaration}
Methods are now typed and we need to store their types in their
closures, so that their type contract can be checked at invocation
time.  The rule below is conceptually similar to that of untyped KOOL;
the only difference is the addition of the types.  */

context 'MethodDec('MethodDecHead(_:K,, _:K,, HOLE,, _:List{K}),, _)

rule [MethodDec]:
    'MethodDec(
      'MethodDecHead(_,, _,, ReturnType:Type,, Name:Id,, 'ListWrap(Params:List{K}),, _),,
      S:K
    )
    => storeMethod(Name, 'ListWrap(Params), S, function from Params to ReturnType)
        [structural]

syntax K ::= "storeMethod" "(" Id "," K "," K "," Type ")"

context storeMethod(_, _, _, function from (_:List{K},, (HOLE => typeOf(HOLE)),, _:List{K}) to _)

rule [storeMethod]:
    <k> storeMethod(Name, 'ListWrap(Params), S, MethodType:Type) =>. ...</k>
    <crntClass> Class:Id </crntClass>
    <location> OL:Int </location>
    <env> Env => Env[L:Int/Name] </env>
    <store>
      ...
      . => L |-> methodClosure(Class, OL, 'ListWrap(Params), S, MethodType) :: MethodType
      ...
    </store>
    <nextLoc> L => L +Int 1 </nextLoc>

rule [ConstrDecSuperCallDesugar]:
    'ConstrDec(
      _:K,,
      'ConstrBody(
        (
          'None(_)
          => 'Some('SuperConstrInv( 'None(.List{K}),, 'ListWrap(.List{K}) ))
        ),,
        _:K
      )
    )

rule [ConstrDec]:
    'ConstrDec('ConstrDecHead(_,, _,, Name,, 'ListWrap(Params),, _),,
        'ConstrBody(
      'Some('SuperConstrInv( _,, SuperParamsList:K )) ,,S))
    => storeConstructor(Name, 'ListWrap(Params), SuperParamsList,
        S, function from Params to void)

syntax K ::= "storeConstructor" "(" Id "," K "," K "," K "," Type ")"

context storeConstructor(_, _, _, _, function from (_:List{K},, (HOLE => typeOf(HOLE)),, _:List{K}) to _)

rule [storeConstructor]:
    <k>
        storeConstructor(Name, 'ListWrap(Params), SuperParamsList, S, MethodType)
        => storeMethod(
          Name,
          'ListWrap(Params),
          'ExprStm(
            'Invoke( 'Method('MethodName( BaseClass )),, SuperParamsList )
          ) ~> S,
          MethodType
        )
      ...
    </k>
    <crntClass> Class:Id </crntClass>
    <className> Class </className>
    <extends> BaseClass </extends>
when
    Id2String(BaseClass) =/=String "Object"

rule [storeConstructorSubclassOfObject]:
    <k>
        storeConstructor(Name, 'ListWrap(Params), _, S, MethodType)
        => storeMethod(
          Name,
          'ListWrap(Params),
          S,
          MethodType
        )
      ...
    </k>
    <crntClass> Class:Id </crntClass>
    <className> Class </className>
    <extends> BaseClass </extends>
when
    Id2String(BaseClass) ==String "Object"

/*@ \subsection{Program initialization}
When done with the first pass, call \texttt{main()}. */

rule [CompilationUnit]:
    <k>
      'CompilationUnit(_,,_,,K:K)
      => K ~> classDecRuntimeException ~> classDecAssertionError ~> execute
    </k>

syntax K ::= "execute"

rule [execute]:
    <k> execute =>
      //k-ast for new <MainClass>().main(new String[0]);
      'ExprStm(
        'Invoke(
          'Method(
            'NewInstance(
              'None(.List{K}),,
              'ClassOrInterfaceType(
                'TypeName(MainClass),,
                'None(.List{K})
              ),,
              'ListWrap(.List{K}),,
              'None(.List{K})
            ),,
            'None(.List{K}),,
            String2Id("main")
          ),,
          'ListWrap('NewArray(
              'TypeName( String2Id("String") ),,
              'ListWrap('Dim(0 :: int)),,
              'ListWrap(.List{K})))
        )
      )
    </k>
    <env> . </env>
    <mainClass> MainClass:Id </mainClass>

//@ \subsection{Auxiliary operations}

//@ \texttt{bindto} also checks the well-formedness of the function parameters

syntax K ::= "bindto" List{K} "," List{KResult}

context bindto('Param(_:K,,HOLE,,_),, _:List{K}), _:List{K}

rule [bindto]:
    <k>
      (. => 'ExprStm('Assign('ExprName(X),,TV:TypedVal)))
      ~> bindto( ('Param(_,,T:Type,,X) => .List{K}),, _:List{K} ),
          ( (TV => .List{K}),, _:List{K} )
      ...
    </k>
    <env> Env:Map => Env[L/X] </env>
    <store>... . => L |-> undefined(T) :: T ...</store>
    <nextLoc> L => L +Int 1 </nextLoc>

rule [bindtoEmpty]:
    <k> bindto .List{K},.List{K} => . ...</k>
        [structural]

//@ \texttt{typeOf and toString}

define typeOf('Param(_:K,,K,,_)) => K

define
    toString(class Class) => Id2String(Class) :: rtString
when
            Id2String(Class) =/=String "RuntimeException"
    andBool Id2String(Class) =/=String "AssertionError"

define
    toString(class Class) => "java.lang." +String Id2String(Class) :: rtString
when
            Id2String(Class) ==String "RuntimeException"
     orBool Id2String(Class) ==String "AssertionError"

define toString(objectClosure(Bag:Bag) :: T) => toString(typeOf(objectClosure(Bag) :: T))

/*@ Recall that lists of the form "a,b,c" are a syntactic convenience,
which eventually are translated into cons-lists "(a,(b,(c,.)))".
Unfortunately, the current K tool is not able to cons-listify
the RHSes of the rules below, so we have to do it manually.  */

/*@ \subsection{Changes to SIMPLE Semantics}
We extend/change the semantics of several SIMPLE constructs in order
to take advantage of the richer KOOL semantic infrastructure and thus
get more from the existing SIMPLE constructs. */

/*@ \subsubsection{Subtyping constraints}
The subclass relation introduces a subtyping relation. */

rule [subtypeRed]:
    <k> subtype class Class1, class Class
      => subtype class Class2, class Class ...</k>
    <className> Class1 </className> <extends> Class2 </extends>
when Class1 =/=K Class
        [structural]

rule [subtypeFalse]:
    subtype class X, class Class => false :: bool
when
            Id2String(X) ==String "Object"
    andBool X =/=K Class

rule [subtypeNull]:
    subtype nullType, class _ => true :: bool
        [structural]

rule [subtypeNullAndString]:
    subtype nullType, rtString => true :: bool
        [structural]

/*@ \subsubsection{Unsafe Casting}
Performs unsafe casting.  One should only use it in combination with
the subtype relation above.  */

define unsafeCast(objectClosure(<crntClass>_:K </crntClass> Obj) :: _, class Class)
  => objectClosure(<crntClass> Class </crntClass> Obj) :: class Class

define unsafeCast(null :: nullType, rtString) => null :: rtString

/*@ \subsection{Class declaration}
Like in untyped KOOL. */

rule [ClassDecWithoutExtendsDesugar]:
    'ClassDec('ClassDecHead(_:K,, ClassName:Id,,
        _:K,,
        ( 'None(_)
          => 'Some('SuperDec('ClassType('TypeName( String2Id("Object") ),, 'None(.List{K}))))
        ),,
        _:K),, _:K
    )
        [structural]

rule [ClassDec]:
      'ClassDec('ClassDecHead('ListWrap(ClassModifiers:List{K}),, ClassName:Id,, _:K,,
          'Some('SuperDec('ClassType('TypeName( BaseClassName:Id ),, _:K))),,
          _:K),,
        'ClassBody( S )
      )  => classDecImpl(ClassModifiers, ClassName, BaseClassName,
              //public empty constructor
              //will be overwritten by any other constructor in S
              'ConstrDec(
                'ConstrDecHead(
                  'ListWrap('Public(.List{K})),,
                  'None(.List{K}),,
                  ClassName,,
                  'ListWrap(.List{K}),,
                  'None(.List{K})
                ),,
                'ConstrBody('None(.List{K}),, 'ListWrap(.List{K}))
              )
              ~> S
            )
        [structural]

syntax K ::= "classDecImpl" "(" List{K} "," Id "," Id "," K ")"

rule [classDecImplModPublic]:
    <k> classDecImpl( ('Public(_) => .List{K}),, _:List{K}, ClassName, _, _ ) ...</k>
    <mainClass> . => ClassName </mainClass>

rule [classDecImplModDiscard]:
    classDecImpl( (K => .List{K}),, _:List{K}, ClassName, _, _ )
when
  K =/=K 'Public(.List{K})

rule [classDecImpl]:
    <k> classDecImpl(.List{K}, ClassName, BaseClassName, S) => . ...</k>
    <classes>
      ...
      ( . =>  <class>
                <className> ClassName </className>
                <extends> BaseClassName </extends>
                <declarations> S </declarations>
              </class> )
      ...
    </classes>

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
        'ClassOrInterfaceType('TypeName( ClassName ),, _:K),,
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
        Obj:Bag
        =>  <crntClass> String2Id("Object") </crntClass>
            <envStack> ListItem((String2Id("object"), <env>.Map</env>)) </envStack>
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
      => create(BaseClass:Id) ~> setCrntClass(Class) ~> S ~> addEnvLayer
      ...
    </k>
    <className> Class </className>
    <extends> BaseClass </extends>
    <declarations> S </declarations>
        [structural]

rule [createObjectDiscard]:
    <k> create( X ) => . ...</k>
when
    Id2String(X) ==String "Object"
        [structural]

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
      (<location> L </location> => .)
    </crntObj>
    <store>
      ...
      . => L |-> objectClosure(Obj <crntClass> Class </crntClass>) :: class Class
      ...
    </store>

/*@ \subsection{Instance Of}
Like in untyped KOOL. */

syntax KLabel ::= 'InstanceOf [seqstrict]

rule [InstanceOfTrue]:
    'InstanceOf(
      objectClosure((_ <envStack>ListItem((Class, _))...</envStack>))::_,,
      class Class
    ) => true :: bool

rule [InstanceOfRed]:
    'InstanceOf(
      objectClosure(
        ( _ <envStack> ListItem((Class1:Id, _)) => . ...</envStack> )
      )::_,,
      class Class2:Id
    )
when Class1 =/=K Class2  [structural]

rule [InstanceOfFalse]:
    'InstanceOf(
      objectClosure((_ <envStack> .List </envStack>))::_,,
      class Class
    ) => false :: bool

/*@ \subsection{Cast}
Unlike in untyped KOOL, in typed KOOL we actually check that the object
can indeed be cast to the claimed type. */

syntax KLabel ::= 'CastRef [seqstrict]

rule [CastRef]:
    <k>
      'CastRef(class Class,, objectClosure((<crntClass> _:K </crntClass> Obj))::T )
      => 'InstanceOf( objectClosure(Obj)::T,, class Class) ~> true?
          ~> objectClosure(<crntClass> Class </crntClass> Obj):: class Class
      ...
    </k>
        [structural]

//@ \subsection{Names}

rule 'AmbName(Ks) => 'ExprName(Ks) [structural anywhere]
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
      => objectClosure(Obj <crntClass> Class </crntClass>) :: class Class
      ...
    </k>
    <crntObj> Obj <crntClass> Class </crntClass> </crntObj>

/*@ \subsection{Object member access} */

//o.x
rule [ExprNameQualified]:
    <k>
      'ExprName(objectClosure(<crntClass> Class </crntClass>
          <envStack>... ListItem((Class, EnvC:BagItem)) EStack:List </envStack>)::_ ,,X)
      => lookupMember(<envStack>ListItem((Class, EnvC)) EStack</envStack>, X)
      ...
    </k>
        [structural]

rule [SuperField]:
    <k>'SuperField(X) => lookupMember(<envStack>EStack</envStack>, X) ...</k>
    <crntClass> Class </crntClass>
    <envStack>... ListItem((Class, EnvC)) EStack </envStack>
      [structural]

/*@\subsection{Method invocation}
The method lookup is the same as in untyped KOOL.
The method closure application and return are slightly different,
since we need to check that the type of the returned value is an
instance of the claimed return type of the method.  The first group of
rules below are identical to those in untyped KOOL. */

rule 'Method('MethodName(Ks:List{K})) => 'MethodName(Ks)
rule 'Method(K,, _:K,, X) => 'MethodName(K,, X)

rule [MethodNameUnqualified]:
    'MethodName(X) => 'MethodName('This(.List{K}),, X)
        [structural]

context 'MethodName(HOLE,,_:K)

//objClos.X(_) => lookupMember(objClos,X)(_)
rule [MethodNameQualified]:
    <k>
      'MethodName(objectClosure(Obj <envStack> EStack </envStack>)::_,, X)
      => lookupMember(<envStack> EStack </envStack>, X)
      ...
    </k>
when
    Id2String(X) =/=String "getClass"
        [structural]

// super.X(_) => lookupMember(... , )(_)
rule [SuperMethod]:
    <k>
      'SuperMethod(_,, X) => lookupMember(<envStack> EStack </envStack>, X)
      ...
    </k>
    <crntClass> Class </crntClass>
    <envStack>... ListItem((Class, _)) EStack </envStack>
        [structural]

/*@ Closure application needs to also set a new return type in the
\textsf{return} cell, in order for the values returned by its body to
be checked against the return type of the method.  To do this correctly,
we also need to stack the current status of the \textsf{return} cell
and then pop it when the method returns. */

context 'Invoke(HOLE,, _)
context 'Invoke(_:KResult ,,'ListWrap(_:List{K},,HOLE,,_:List{K}))

rule [Invoke]:
    <k>
      'Invoke(methodClosure(Class, OL:Int, 'ListWrap(Params), S, function from _ to T)::_,,
          'ListWrap(ParamValues:List{KResult})) ~> K
       => bindto Params, ParamValues ~> S ~> 'Return('None(.List{K}))
    </k>
    <control> C:Bag
      <stack>
        . =>  ListItem((return,.K,.K,K, Env,
                  C <crntObj> Obj2 </crntObj>
                  <return> T2 </return>))
        ...
      </stack>
      <crntObj> Obj2:Bag => <crntClass>Class</crntClass> Obj </crntObj>
      <return> T2:Type => T </return>
    </control>
    <env> Env => . </env>
    <store>
      ...
      OL |-> objectClosure(<crntClass>_:Id</crntClass>Obj:Bag) :: _
      ...
    </store>

/*@ \subsection{Lookup member}
Like in untyped KOOL. */

//typed version of lookup
syntax K ::= "typedLookup" "(" Int ")"

rule [typedLookup]:
    <k> typedLookup(L) => lookup(L)::T ...</k>
    <store>... L |-> _::T ...</store>

rule [lvalueTypedLookup]:
    <k> lvalue( typedLookup(L) => lookup(L)::T ) ...</k>
    <store>... L |-> _::T ...</store>

syntax K ::= "(" Id "," Bag ")"

//lookup member result is always typed
declare lookupMember : BagItem Id -> K

//todo this definition should fail the test sketched in log.txt
define lookupMember(
    <envStack>
      ListItem((_:Id, <env>... X|->L ...</env>))
      ...
    </envStack>,
    X
  ) => typedLookup(L)

define lookupMember(
    <envStack>
      ListItem((_:Id, <env> Env </env>)) => .
      ...
    </envStack>,
    X
  )
when notBool(X in keys(Env))

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
          objectClosure(
            <crntClass> Class </crntClass>
            <envStack>... ListItem((Class, EnvC:BagItem)) EStack </envStack>
          ) :: class Class,,
          X
        )
        => lookupMember(
            <envStack> ListItem((Class, EnvC)) EStack:List </envStack>,
            X
          )
      )
      ...
    </k>
        [structural]

rule [lvalueSuperField]:
    <k> lvalue('SuperField(X) => lookupMember(<envStack>EStack</envStack>, X)) ...</k>
    <crntClass> Class </crntClass>
    <envStack>... ListItem((Class, EnvC)) EStack </envStack>
        [structural]

end module
