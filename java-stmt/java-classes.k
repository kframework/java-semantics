require "java-core.k"
require "java-expressions.k"
require "java-statements.k"
require "java-arrays.k"
require "class-dec/RuntimeException.k"
require "class-dec/AssertionError.k"

module JAVA-CLASSES
    imports JAVA-CORE
    imports JAVA-EXPRESSIONS
    imports JAVA-STATEMENTS
    imports JAVA-ARRAYS
    imports CLASS-DEC-RuntimeException
    imports CLASS-DEC-AssertionError

syntax Type ::= "function" "from" List{K} "to" Type
                  [latex({#1}\ \texttt{->}\ {#2})]
              | "class" Id

syntax RawVal ::= "objectClosure" "(" Bag ")"
                | "methodClosure" "("
                    Id ","    // Class - method class
                    Int ","   // OL - object location
                    K ","     // 'ListWrap(Params) - params
                    K ","     // S - method body
                    Type      // MethodType
                  ")"

//@ \subsection{Unused Labels}
syntax KLabel ::= "'Static" | "'TypeImportOnDemandDec" | "'PackageName"

/*@ \subsection{Object and method closures}
The only change to untyped KOOL's values is that closures are now typed
(their last argument holds their type). */

//@ \subsection{Type labels}
//@Here we rewrite java type ast into simple types

rule 'ClassOrInterfaceType('TypeName(K:K),,_) => 'TypeName(K) [structural]
rule 'TypeName(X:Id) => class X  [structural]

rule
    class X:Id => rtString
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
    <k> storeMethod(Name:Id, 'ListWrap(Params:List{K}), S:K, MethodType:Type) =>. ...</k>
    <crntClass> Class:Id </crntClass>
    <location> OL:Int </location>
    <env> Env:Map => Env[L/Name] </env>
    <store>
      ...
      .  => L |-> methodClosure(Class, OL, 'ListWrap(Params), S, MethodType) :: MethodType
      ...
    </store>
    <nextLoc> L:Int => L +Int 1 </nextLoc>

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
    'ConstrDec('ConstrDecHead(_,, _,, Name:Id,, 'ListWrap(Params:List{K}),, _),,
        'ConstrBody(
      'Some('SuperConstrInv( _,, SuperParamsList:K )) ,,S:K))
    => storeConstructor(Name, 'ListWrap(Params), SuperParamsList,
        S, function from Params to void)

syntax K ::= "storeConstructor" "(" Id "," K "," K "," K "," Type ")"

context storeConstructor(_, _, _, _, function from (_:List{K},, (HOLE => typeOf(HOLE)),, _:List{K}) to _)

rule [storeConstructor]:
    <k>
        storeConstructor(Name:Id, 'ListWrap(Params:List{K}), SuperParamsList:K, S:K, MethodType:Type)
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
    <extends> BaseClass:Id </extends>
when
    Id2String(BaseClass) =/=String "Object"

rule [storeConstructorSubclassOfObject]:
    <k>
        storeConstructor(Name:Id, 'ListWrap(Params:List{K}), _, S:K, MethodType:Type)
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
    <extends> BaseClass:Id </extends>
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

syntax K ::= "bindto" List{K} "," List{K}

context bindto('Param(_:K,,HOLE,,_),, _:List{K}), _:List{K}

rule [bindto]:
    <k>
      (. => 'ExprStm('Assign('ExprName(X),,TV:TypedVal)))
      ~> bindto( ('Param(_,,T:Type,,X:Id) => .List{K}),, _:List{K} ),
          ( (TV => .List{K}),, _:List{K} )
      ...
    </k>
    <env> Env:Map => Env[L/X] </env>
    <store>... . => L |-> unruled(T) :: T ...</store>
    <nextLoc> L:Int => L +Int 1 </nextLoc>

rule [bindtoEmpty]:
    <k> bindto .List{K},.List{K} => . ...</k>
        [structural]

//@ \texttt{typeOf and toString}

rule typeOf('Param(_:K,,K:K,,_)) => K [anywhere]

rule
    toString(class Class:Id) => Id2String(Class) :: rtString
when
            Id2String(Class) =/=String "RuntimeException"
    andBool Id2String(Class) =/=String "AssertionError"   [anywhere]

rule
    toString(class Class:Id) => "java.lang." +String Id2String(Class) :: rtString
when
            Id2String(Class) ==String "RuntimeException"
     orBool Id2String(Class) ==String "AssertionError"    [anywhere]

rule toString(objectClosure(Obj:Bag) :: T:Type)
    =>  'Invoke(
          'MethodName(objectClosure(Obj) :: T,, String2Id("toString")),,
          'ListWrap(.List{K})
        )
        [anywhere]

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
    <k>
      subtype class Class1:Id, class Class:Id
      => subtype class Class2, class Class
      ...
    </k>
    <className> Class1 </className>
    <extends> Class2:Id </extends>
when Class1 =/=K Class
        [structural]

rule [subtypeFalse]:
    subtype class X:Id, class Class:Id => false :: bool
when
            Id2String(X) ==String "Object"
    andBool X =/=K Class

/*@ \subsubsection{Unsafe Casting}
Performs unsafe casting.  One should only use it in combination with
the subtype relation above.  */

rule unsafeCast(objectClosure(<crntClass>_:K </crntClass> Obj:Bag) :: _, class Class:Id)
  => objectClosure(<crntClass> Class </crntClass> Obj) :: class Class   [anywhere]

/*@ \subsection{Class declaration}
Like in untyped KOOL. */

rule [ClassDecWithoutExtendsDesugar]:
    'ClassDec('ClassDecHead(_:K,, _:Id,, _:K,,
        ( 'None(_)
          => 'Some('SuperDec('ClassType('TypeName( String2Id("Object") ),, 'None(.List{K}))))
        ),,
        _:K),, _:K
    )
        [structural]

rule [ClassDec]:
      'ClassDec('ClassDecHead('ListWrap(ClassModifiers:List{K}),, Class:Id,, _:K,,
          'Some('SuperDec('ClassType('TypeName( BaseClass:Id ),, _:K))),,
          _:K),,
        'ClassBody( S:K )
      )  => classDecImpl(ClassModifiers, Class, BaseClass,
              //public empty constructor
              //will be overwritten by any other constructor in S
              'ConstrDec(
                'ConstrDecHead(
                  'ListWrap('Public(.List{K})),,
                  'None(.List{K}),,
                  Class,,
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
    <k> classDecImpl( ('Public(_) => .List{K}),, _:List{K}, Class:Id, _, _ ) ...</k>
    <mainClass> . => Class </mainClass>

rule [classDecImplModDiscard]:
    classDecImpl( (K:K => .List{K}),, _:List{K}, _,_,_ )
when
  K =/=K 'Public(.List{K})

rule [classDecImpl]:
    <k> classDecImpl(.List{K}, Class:Id, BaseClass:Id, S:K) => . ...</k>
    <classes>
      ...
      ( . =>  <class>
                <className> Class </className>
                <extends> BaseClass </extends>
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
        'ClassOrInterfaceType('TypeName( Class:Id ),, _:K),,
        'ListWrap( Vals:List{K} ),,
        _:K
      ) ~> K:K
      => create(Class) ~> storeObj
         ~> 'ExprStm('Invoke(
              'Method('MethodName( Class )),,
              'ListWrap( Vals )
            ))
         ~> 'Return('Some('This( .List{K} )))
    </k>
    <env> Env:Map => . </env>
    <control>
      C:Bag
      <crntObj>
        Obj:Bag
        =>  <crntClass> String2Id("Object") </crntClass>
            <envStack> ListItem((String2Id("object"), <env>.Map</env>)) </envStack>
            <location> L </location>
      </crntObj>
      <return> T:Type => class Class </return>
      <stack>
        . => ListItem((return, .K, .K, K, Env,
                       C <return> T </return> <crntObj> Obj </crntObj>))
        ...
      </stack>
    </control>
    <nextLoc> L:Int => L +Int 1 </nextLoc>
when isKResult(Vals)

syntax K ::= "create" "(" K ")"

rule [create]:
    <k>
      create(Class:Id)
      => create(BaseClass:Id) ~> setCrntClass(Class) ~> S ~> addEnvLayer
      ...
    </k>
    <className> Class </className>
    <extends> BaseClass </extends>
    <declarations> S:K </declarations>
        [structural]

rule [createObjectDiscard]:
    <k> create( X:Id ) => . ...</k>
when
    Id2String(X) ==String "Object"
        [structural]

syntax K ::= "setCrntClass" "(" Id ")"

rule [setCrntClass]:
    <k> setCrntClass(Class:Id) => . ...</k>
    <crntClass> _ => Class </crntClass>
        [structural]

syntax K ::= "addEnvLayer"

rule [addEnvLayer]:
    <k> addEnvLayer => . ...</k>
    <env> Env:Map => . </env>
    <crntClass> Class:Id </crntClass>
    <envStack> . => ListItem((Class, <env>Env</env>)) ...</envStack>
        [structural]

syntax K ::= "storeObj"

rule [storeObj]:
    <k> storeObj => . ...</k>
    <crntObj>
      Obj:Bag
      <crntClass> Class:Id </crntClass>
      (<location> L:Int </location> => .)
    </crntObj>
    <store>
      ...
      . => L |-> objectClosure(Obj <crntClass> Class </crntClass>) :: class Class
      ...
    </store>

/*@ \subsection{Instance Of}
Like in untyped KOOL. */

syntax KLabel ::= "'InstanceOf" [seqstrict]

rule [InstanceOfTrue]:
    'InstanceOf(
      objectClosure((_ <envStack>ListItem((Class:Id, _))...</envStack>))::_,,
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
      class _:Id
    ) => false :: bool

/*@ \subsection{Cast}
Unlike in untyped KOOL, in typed KOOL we actually check that the object
can indeed be cast to the claimed type. */

syntax KLabel ::= "'CastRef" [seqstrict]

rule [CastRef]:
    <k>
      'CastRef(class Class:Id,, objectClosure((<crntClass> _:K </crntClass> Obj:Bag))::T:Type )
      => 'InstanceOf( objectClosure(Obj)::T,, class Class) ~> true?
          ~> objectClosure(<crntClass> Class </crntClass> Obj):: class Class
      ...
    </k>
        [structural]

//@ \subsection{Names}

rule 'AmbName(Ks:List{K}) => 'ExprName(Ks) [structural, anywhere]
rule 'Field(Ks:List{K}) => 'ExprName(Ks)   [structural, anywhere]

rule [ExprNameLocalVar]:
    <k> 'ExprName(X:Id) => X ...</k>
    <env> Env:Map </env>
when X in keys(Env)
        [structural]

rule [ExprNameMember]:
    <k>
      'ExprName(X:Id) => 'ExprName( 'This(.List{K}),, X )
      ...
    </k>
    <env> Env:Map </env>
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
    <crntObj> Obj:Bag <crntClass> Class:Id </crntClass> </crntObj>

/*@ \subsection{Object member access} */

//o.x
rule [ExprNameQualified]:
    <k>
      'ExprName(objectClosure(<crntClass> Class:Id </crntClass>
          <envStack>... ListItem((Class, EnvC:BagItem)) EStack:List </envStack>)::_ ,,X:Id)
      => lookupMember(<envStack>ListItem((Class, EnvC)) EStack</envStack>, X)
      ...
    </k>
        [structural]

rule [SuperField]:
    <k>'SuperField(X:Id) => lookupMember(<envStack>EStack</envStack>, X) ...</k>
    <crntClass> Class:Id </crntClass>
    <envStack>... ListItem((Class, _)) EStack:List </envStack>
      [structural]

/*@\subsection{Method invocation}
The method lookup is the same as in untyped KOOL.
The method closure application and return are slightly different,
since we need to check that the type of the returned value is an
instance of the claimed return type of the method.  The first group of
rules below are identical to those in untyped KOOL. */

rule 'Method('MethodName(Ks:List{K})) => 'MethodName(Ks)
rule 'Method(K:K,, _:K,, X:Id) => 'MethodName(K,, X)

rule [MethodNameUnqualified]:
    'MethodName(X:Id) => 'MethodName('This(.List{K}),, X)
        [structural]

context 'MethodName(HOLE,,_:K)

//objClos.X(_) => lookupMember(objClos,X)(_)
rule [MethodNameQualified]:
    <k>
      'MethodName(objectClosure(_:Bag <envStack> EStack:List </envStack>)::_,, X:Id)
      => lookupMember(<envStack> EStack </envStack>, X)
      ...
    </k>
when
    Id2String(X) =/=String "getClass"
        [structural]

// super.X(_) => lookupMember(... , )(_)
rule [SuperMethod]:
    <k>
      'SuperMethod(_,, X:Id) => lookupMember(<envStack> EStack </envStack>, X)
      ...
    </k>
    <crntClass> Class:Id </crntClass>
    <envStack>... ListItem((Class, _)) EStack:List </envStack>
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
      'Invoke(methodClosure(Class:Id, OL:Int, 'ListWrap(Params:List{K}), S:K, function from _ to T:Type)::_,,
          'ListWrap(ParamValues:List{K})) ~> K:K
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
    <env> Env:Map => . </env>
    <store>
      ...
      OL |-> objectClosure(<crntClass>_:Id</crntClass>Obj:Bag) :: _
      ...
    </store>
when isKResult(ParamValues)

/*@ \subsection{Lookup member}
Like in untyped KOOL. */

//typed version of lookup
syntax K ::= "typedLookup" "(" Int ")"

rule [typedLookup]:
    <k> typedLookup(L:Int) => lookup(L)::T ...</k>
    <store>... L |-> _::T:Type ...</store>

rule [lvalueTypedLookup]:
    <k> lvalue( typedLookup(L:Int) => lookup(L)::T ) ...</k>
    <store>... L |-> _::T:Type ...</store>

syntax K ::= "(" Id "," Bag ")"

//lookup member result is always typed
syntax K ::= "lookupMember" "(" BagItem "," Id ")"

//todo this definition should fail the test sketched in log.txt
rule lookupMember(
    <envStack>
      ListItem((_:Id, <env>... X:Id |-> L:Int ...</env>))
      ...
    </envStack>,
    X
  ) => typedLookup(L)         [anywhere]

rule lookupMember(
    <envStack>
      ListItem((_:Id, <env> Env:Map </env>)) => .
      ...
    </envStack>,
    X:Id
  )
when notBool(X in keys(Env))  [anywhere]

//@ \texttt{lvalue}

rule [lvalueExprNameMember]:
    <k> lvalue( 'ExprName(X:Id) => 'ExprName('This(.List{K}),, X) ) ...</k>
    <env> Env:Map </env>
when notBool(X in keys(Env))  [structural]

context lvalue('ExprName(HOLE,, _:Id) )

rule [lvalueExprNameQualified]:
    <k>
      lvalue(
        'ExprName(
          objectClosure(
            <crntClass> Class:Id </crntClass>
            <envStack>... ListItem((Class, EnvC:BagItem)) EStack:List </envStack>
          ) :: class Class,,
          X:Id
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
    <k> lvalue('SuperField(X:Id) => lookupMember(<envStack>EStack</envStack>, X)) ...</k>
    <crntClass> Class:Id </crntClass>
    <envStack>... ListItem((Class, _)) EStack:List </envStack>
        [structural]

endmodule
