module JAVA-CLASSES
    imports JAVA-CORE
    imports JAVA-EXPRESSIONS
    imports JAVA-STATEMENTS
    imports JAVA-ARRAYS

syntax Type ::= "function" "from" List{KResult} "to" Type
                  [prec(1) latex "({#1}\ \texttt{->}\ {#2})"]

syntax RefType ::= "class" Id

syntax RawVal ::= "objectClosure" "(" Bag ")"
                | "methodClosure" "("
                    Id ","   // F - method name
                    Int ","  // OL - object location
                    K ","    // 'ListWrap(Params) - params
                    K        // S - method body
                  ")"

//@ \subsection{Unused Labels}
syntax KLabel ::= 'Static | 'TypeImportOnDemandDec | 'PackageName | 'Final | 'Native

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

/*@ \subsection{First pass - processing declarations} */

rule [DefaultPackageDesugar]:
    'CompilationUnit(
      ( 'None(_) => 'Some('PackageDec(.K,, 'PackageName( 'ListWrap(.List{K}) ))) ),,
      _,,_)

rule [CompilationUnit]:
    <k>
      'CompilationUnit('Some('PackageDec(_,, 'PackageName( PN:K ))),,_,,K:K) => K ...
    </k>
    <cuPackage> _ => PN </cuPackage>

/*@ \subsection{Class declaration}
Like in untyped KOOL. */

rule [ClassDecWithoutExtendsDesugar]:
    'ClassDec('ClassDecHead(_:K,, ClassName:Id,,
        _:K,,
        ( 'None(_)
          => 'Some('SuperDec('ClassType(class String2Id("Object"),, 'None(.List{K}))))
        ),,
        _:K),, _:K
    )
        [structural]

rule [ClassDec]:
      'ClassDec('ClassDecHead('ListWrap(ClassModifiers:List{K}),, ClassName:Id,, _:K,,
          'Some('SuperDec('ClassType(class BaseClassName:Id,, _:K))),,
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
    <cuPackage> PN </cuPackage>
    <classes>
      ...
      ( . =>  <class>
                <className> ClassName </className>
                <extends> BaseClassName </extends>
                <package> PN </package>
                <declarations> S </declarations>
              </class> )
      ...
    </classes>

rule [classDecImplObject]:
    <k> classDecImpl(.List{K}, ClassName, BaseClassName, S) => . ...</k>
    <cuPackage> PN </cuPackage>
    <classes>
      ...
      ( . =>  <class>
                <className> ClassName </className>
                <extends> .K </extends>
                <package> PN </package>
                <declarations> S </declarations>
              </class> )
      ...
    </classes>
when Id2String(ClassName) ==String "Object"

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
      . => L |-> methodClosure(Class, OL, 'ListWrap(Params), S) :: MethodType
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
            'Invoke( 'Method('MethodName( BaseClass:Id )),, SuperParamsList )
          ) ~> S,
          MethodType
        )
      ...
    </k>
    <crntClass> Class:Id </crntClass>
    <className> Class </className>
    <extends> BaseClass </extends>
when
    Id2String(Class) =/=String "Object"

rule [storeConstructorClassObject]:
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
when
    Id2String(Class) ==String "Object"

rule [execute]:
    <k> . =>
      //k-ast for new <MainClass>().main(new String[0]);
      'ExprStm(
        'Invoke(
          'Method(
            'NewInstance(
              'None(.List{K}),,
              class MainClass,,
              'ListWrap(.List{K}),,
              'None(.List{K})
            ),,
            'None(.List{K}),,
            String2Id("main")
          ),,
          'ListWrap('NewArray(
              rtString,,
              'ListWrap('Dim(0 :: int)),,
              'ListWrap(.List{K})))
        )
      )
    </k>
    <env> . </env>
    <mainClass> MainClass:Id </mainClass>
    <executionPhase> "ProcessDeclarations" => "Execute" </executionPhase>

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
    <store>... . => L |-> undefined :: T ...</store>
    <nextLoc> L => L +Int 1 </nextLoc>

rule [bindtoEmpty]:
    <k> bindto .List{K},.List{K} => . ...</k>
        [structural]

//@ \texttt{typeOf and toString}

define typeOf('Param(_:K,,K,,_)) => K

define toString(objectClosure(Obj:Bag) :: T)
    =>  'Invoke(
          'MethodName(objectClosure(Obj) :: T,, String2Id("toString")),,
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

/*@ \subsubsection{Subtyping among reference types}
The subclass relation introduces a subtyping relation. */

rule [subtypeClassRed]:
    <k> subtype class Class1:Id, class Class
      => subtype class Class2:Id, class Class ...</k>
    <className> Class1 </className> <extends> Class2 </extends>
when Class1 =/=K Class
        [structural]

rule [subtypeClassOfClassFalse]:
    subtype class X, class Class => false :: bool
when
            Id2String(X) ==String "Object"
    andBool X =/=K Class

rule [subTypeClassOfOtherFalse]:
    subtype class X, RT:RefType => false :: bool
when
    getKLabel(RT) =/=KLabel 'class_

rule [subtypeStringOfClass]:
    subtype rtString, class Class =>
    #if Id2String(Class) ==String "Object"
      #then true::bool
      #else false::bool
    #fi

rule [subtypeStringOfOtherFalse]:
    subtype rtString, RT => false::bool
when
            getKLabel(RT) =/=KLabel 'rtString
    andBool getKLabel(RT) =/=KLabel 'class_

rule [subtypeArrayOfClass]:
    subtype arrayOf _, class Class =>
    #if Id2String(Class) ==String "Object"
      #then true::bool
      #else false::bool
    #fi

rule [subtypeArrayOfOtherFalse]:
    subtype arrayOf _, RT => false::bool
when
            getKLabel(RT) =/=KLabel 'arrayOf_
    andBool getKLabel(RT) =/=KLabel 'class_

rule [subtypeNull]:
    subtype nullType, _:RefType => true :: bool
        [structural]

//@ \texttt{typeOf for raw values of reference type}
define typeOf(Str:String) => rtString
define typeOf(null) => nullType
define typeOf(objectClosure((<envStack>ListItem((Class, _)) _</envStack>))) => class Class
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
        class ClassName,,
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
    <declarations> S </declarations>
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
      (<location> L </location> => .)
    </crntObj>
    <store>
      ...
      . => L |-> objectClosure(Obj) :: class Class
      ...
    </store>

/*@ \subsection{Instance Of}
Like in untyped KOOL. */

syntax KLabel ::= 'InstanceOf [seqstrict]

rule [InstanceOf]:
    'InstanceOf(V::_,, RT2)
    =>  #if V =/=K null
          #then subtype typeOf(V), RT2
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
            (subtype typeOf(V), RT1),,
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
      => objectClosure(Obj) :: class Class
      ...
    </k>
    <crntObj> Obj <crntClass> Class </crntClass> </crntObj>

/*@ \subsection{Object member access} */

//o.x
rule [ExprNameQualified]:
    <k>
      'ExprName(
        objectClosure(
          <envStack>... ListItem((Class, EnvC:BagItem)) EStack:List </envStack>
        ) :: class Class,, X
      )
      => lookupMember(<envStack>ListItem((Class, EnvC)) EStack</envStack>, X)
      ...
    </k>
        [structural]

rule [ExprNameQualifiedNull]:
    <k>
      'ExprName(null :: class Class,, X)
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
      'MethodName(objectClosure(<envStack> EStack </envStack>)::_,, X)
      => lookupMember(<envStack> EStack </envStack>, X)
      ...
    </k>
when
    Id2String(X) =/=String "getClass"
        [structural]

rule [MethodNameQualifiedNull]:
    <k>
      'MethodName(null :: _,, X)
      =>  'Throw('NewInstance(
            'None(.List{K}),,
            'class_(String2Id("NullPointerException")),,
            'ListWrap( null :: nullType ),,
            'None(.List{K})
          ))
      ...
    </k>
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
      'Invoke(methodClosure(Class, OL:Int, 'ListWrap(Params), S) :: function from _ to T,,
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
      OL |-> objectClosure(Obj) :: _
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
