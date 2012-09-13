module JAVA-METHOD-INVOKE
    imports JAVA-CLASSES
    imports JAVA-METHOD-DEC

/*@\subsection{Method invocation}
The method lookup is the same as in untyped KOOL.
The method closure application and return are slightly different,
since we need to check that the type of the returned value is an
instance of the claimed return type of the method.  The first group of
rules below are identical to those in untyped KOOL. */

rule 'Method('MethodName(Ks:List{K})) => 'MethodName(Ks)  [structural anywhere]
rule 'Method(K:K,, _:K,, Name:Id) => 'MethodName(K,, Name)  [structural anywhere]

rule [MethodNameUnqualified]:
    'MethodName(Name) => 'MethodName('This(.List{K}),, Name)
        [structural]

rule <k> 'MethodName(K,, Name) => methodNameImpl(K, Name, getKLabel(K) =/=KLabel 'This) ...</k>

syntax K ::= "methodNameImpl" "("
                                  K ","   //qualifier exp
                                  Id ","  //method name
                                  Bool    //IsQ - isQualified
                              ")"

context methodNameImpl(HOLE, _, _)

//objClos.X(_)
rule [MethodNameQualified]:
    <k>
      methodNameImpl(objectClosure(OL:Int, <envStack> EStack:List </envStack>)::class Class,
          Name, IsQ:Bool)
      => lookupMethodData(OL, Class, Name, <envStack> EStack </envStack>, IsQ)
      ...
    </k>
    <isQualified> _ => IsQ </isQualified>
when
    Id2String(Name) =/=String "getClass"
        [structural]

rule [MethodNameQualifiedNull]:
    <k>
      methodNameImpl(null::_ , _,_)
      =>  'Throw('NewInstance(
            'None(.List{K}),,
            'class_(String2Id("NullPointerException")),,
            'ListWrap( null :: nullType ),,
            'None(.List{K})
          ))
      ...
    </k>
        [structural]

// super.X(_)
rule [SuperMethod]:
    <k>
      'SuperMethod(_,, Name)
      => lookupMethodData(OL, BaseClass, Name, <envStack> EStack </envStack>, true)
      ...
    </k>
    <crntClass> Class </crntClass>
    <location> OL </location>
    <envStack>... ListItem((Class, _)) EStack </envStack>
    <className> Class:Id </className>
    <extends> BaseClass:Id </extends>
        [structural]

syntax KResult ::= "lookupMethodData" "(" Int     //OL - object location
                                      "," Id      //target ref class name
                                      "," Id      //method name
                                      "," BagItem //target <envLayer> content
                                      "," Bool    //IsQ - isQualified
                    ")"

/*@ Closure application needs to also set a new return type in the
\textsf{return} cell, in order for the values returned by its body to
be checked against the return type of the method.  To do this correctly,
we also need to stack the current status of the \textsf{return} cell
and then pop it when the method returns. */

//todo test order of params evaluation - here it should get wrong
context 'Invoke(HOLE,, _)
context 'Invoke(_:KResult ,,'ListWrap(_:List{K},,HOLE,,_:List{K}))

rule [InitSignatureSearch]:
    <k>
      'Invoke(lookupMethodData(
        OL,
        Class,
        Name,
        <envStack>
          Rest:List
          ListItem((ObjectClass:Id, BI:BagItem))
        </envStack>,
        IsQ
      ),,
        'ListWrap(ParamValues)
      ) => invokeImpl(
        lookupMethod(
          Class,
          <envStack>
            Rest
            ListItem((ObjectClass, BI))
          </envStack>,
          Name, getTypes(ParamValues), Env
        ),
        OL,
        'ListWrap(ParamValues)
      )
      ...
    </k>
    <isQualified> _ => IsQ </isQualified>
    <className> ObjectClass </className>
    <methods> Env:Map </methods>

syntax K ::= "invokeImpl" "(" K   //lookupMethod statement, later protoMethodClosure
                          "," Int //OL - object location
                          "," K   //'ListWrap(ParamValues)
                          ")"
        [strict(1)]

//converts a List{TypedVal} to Types.
syntax K ::= "getTypes" "("
                            List{KResult} //a list of values
                        ")"
           | "getTypes" "("
                            List{KResult} "," //a list of types
                            List{KResult}     //a list of values
                        ")"

rule getTypes(Ks) => getTypes(.List{K}, Ks)
rule getTypes(_,, (.List{K} => T), (_::T:Type => .List{K}),, _)
rule getTypes(Ks, .List{K}) => types(Ks)

syntax K ::= "lookupMethod" "(" K ","       //Class name of the reference used to call the method
                                            //or .K if we cannot search for more specific signature
                                BagItem "," //<envStack> - class hierarchy
                                Id ","      //Method name
                                Types ","   //Method param types
                                Map         //methods map of the ObjectClass to search
                            ")"           [strict(4)]
           | "lookupMethod" "(" K ","       //Class name of the reference used to call the method
                                            //or .K if we cannot search for more specific signature
                                BagItem "," //<envStack> - class hierarchy
                                Id ","      //Method name
                                Types ","   //Method param types
                                Map ","     //methods map of the ObjectClass to search
                                K           //method closure of the most specific method so far
                                            //or undefined::nullType if no method was found yet
                            ")"           [strict(6)]

rule lookupMethod(Class, BI, Name, Ts:Types, Env)
  => lookupMethod(Class, BI, Name, Ts, Env, undefined::nullType)

// all lookupMethod rules traverse the class hierarchy from Object to the concrete class itself.
rule [lookupMethodNoAlternatives]:
    (. => isPreferableSig(
            'LazyAnd(
              isAccessible(ObjectClass, getMethodAccessMode(typedLookup(L))),,
              subtype(CallTL, SigTL)
            ),
            L:Int
          ) )
     ~> lookupMethod(
          _:Id,
          <envStack>
            ...
            ListItem((ObjectClass, _))
          </envStack>,
          Name,
          types(CallTL:List{K}),
          (sig(Name, types(SigTL:List{K})) |-> L => .) _:Map,
          undefined::_
        )

rule [lookupMethodWithAlternative]:
    (. => isPreferableSig(
            'LazyAnd(
              isAccessible(ObjectClass, getMethodAccessMode(typedLookup(L))),,
              'LazyAnd(subtype(CallTL, SigTL),, subtype(SigTL, AltTL))
            ),
            L
          ) )
     ~> lookupMethod(
          _:Id,
          <envStack>
            ...
            ListItem((ObjectClass, _))
          </envStack>,
          Name,
          types(CallTL),
          (sig(Name, types(SigTL)) |-> L => .) _:Map,
          _ :: methodType(_, AltTL:List{K}, _)
        )

rule [lookupMethodSignatureFixed]:
    lookupMethod(
      .K,
      <envStack>
        ...
        ListItem((ObjectClass, _))
      </envStack>,
      Name,
      _,
      (sig(Name, types(SigTL)) |-> L => .) _:Map,
      protoMethodClosure(OldMethodClass:Id, ParamsK:K, Body) :: methodType(Acc, SigTL, T)
      => 'If(
            isAccessibleForOverwriting(
              OldMethodClass, Acc, ObjectClass, getMethodAccessMode(typedLookup(L))
            ),,
            typedLookup(L),,
            protoMethodClosure(OldMethodClass, ParamsK, Body) :: methodType(Acc, SigTL, T)
          )
    )

rule [lookupMethodSignatureFixedEntryDiscard]:
    lookupMethod(
      .K,
      _,
      Name,
      _,
      (sig(X, types(SigTL)) |-> _ => .) _:Map,
      _ :: methodType(_, ChosenSigTL:List{K}, _)
    )
when
    sig(X, types(SigTL)) =/=K sig(Name, types(ChosenSigTL))

syntax K ::= "isPreferableSig" "(" K "," Int ")"  [strict(1)]

rule (isPreferableSig(true::bool, L:Int) => .) ~> lookupMethod(_,_,_,_,_, _ => typedLookup(L) )
rule isPreferableSig(false::bool, _) => .

rule [lookupMethodOtherNameEntryDiscard]:
    lookupMethod(
      _,
      _,
      Name,
      _,
      (sig(X:Id, _) |-> _ => .) _:Map,
      _:K
    )
when
    X =/=K Name

rule [lookupMethodLayerDiscard]:
    <k>
      lookupMethod(
        K,
        <envStack>
          ...
          ListItem((SubClass:Id, _))
          (ListItem((ObjectClass, _)) => .)
        </envStack>,
        _,
        _,
        .Map => NewEnv,
        _:K
      )
      ...
    </k>
    <class>
      <className> SubClass </className>
      <methods> NewEnv:Map </methods>
      ...
    </class>
when
    K =/=K ObjectClass

rule [lookupMethodLayerDiscard2]:
    <k>
      lookupMethod(
        ObjectClass => .K,
        <envStack>
          ...
          ListItem((SubClass:Id, _))
          (ListItem((ObjectClass, _)) => .)
        </envStack>,
        _,
        _,
        .Map => NewEnv,
        _:K
      )
    ...
    </k>
    <class>
      <className> SubClass </className>
      <methods> NewEnv:Map </methods>
      ...
    </class>

rule [lookupMethodEnd]:
    lookupMethod(
      _,
      <envStack>
        ListItem(_)
      </envStack>,
      _,
      _,
      .Map,
     TV:TypedVal
    ) => TV

//Tests whether a method from a given class with a given access mode may be called from
//the current object environment
syntax K ::= "isAccessible" "(" Id ","      //the method class
                                AccessMode  //the method access mode
                            ")"
        [strict(2)]

rule [isAccessiblePublic]:
    isAccessible(_, public) => true::bool

rule [isAccessibleProtected]:
    <k>
      isAccessible(Class, protected)
      => 'LazyOr(
            'LazyAnd('Not(isQualifiedMethodCall),, subtype(class CurrentClass, class Class)),,
            isAccessible(Class, package)
      )
      ...
    </k>
    <crntClass> CurrentClass:Id </crntClass>

rule [isAccessiblePackage]:
    <k> isAccessible(Class, package) => kEq(getPackage(Class), getPackage(CurrentClass)) ...</k>
    <crntClass> CurrentClass:Id </crntClass>

rule [isAccessiblePrivate]:
    <k> isAccessible(Class, private) => (Class ==K CurrentClass)::bool ...</k>
    <crntClass> CurrentClass </crntClass>

syntax K ::= "isQualifiedMethodCall"
rule <k> isQualifiedMethodCall => B :: bool  ...</k>
     <isQualified> B:Bool </isQualified>

//tests whether a new method in an overwriting chain is accessible to the old method
syntax K ::= "isAccessibleForOverwriting" "("
                                              Id ","          //OldMethodClass
                                              AccessMode ","  //OldMethodAccessMode
                                              Id ","          //NewMethodClass
                                              AccessMode      //NewMethodAccessMode
                                          ")"
        [strict(4)] //strict(2) also makes sense ut is not used by the construct creation rule

rule isAccessibleForOverwriting(_, private, _, _) => false::bool

rule isAccessibleForOverwriting(OldClass:Id, package, NewClass:Id, NewAcc:AccessMode)
    => kEq(getPackage(OldClass), getPackage(NewClass))

rule isAccessibleForOverwriting(_, protected, _, _) => true::bool
rule isAccessibleForOverwriting(_, public,    _, _) => true::bool

//returns the access mode of a method in the location L given as argument
declare getMethodAccessMode : TypedVal -> AccessMode  [strict(1)]
define getMethodAccessMode( _ :: methodType(Acc:AccessMode,_,_) ) => Acc

declare getArgTypes : TypedVal -> Types
define getArgTypes(_ :: methodType(_,Ks,_)) => types(Ks)

rule [invokeImpl]:
    <k>
      invokeImpl(
        protoMethodClosure(Class, 'ListWrap(Params:List{K}), Body:K)
            :: methodType(_, _, T),
        OL,
        'ListWrap(ParamValues:List{KResult})
      ) ~> K
       => bindto Params, ParamValues ~> Body ~> 'Return('None(.List{K}))
    </k>
    <control>
      <stack>
        . =>  ListItem((return,.K,.K,K, Env,
                  (
                    <crntObj> OldObj </crntObj>
                    <return> OldT </return>
                    C
                  )
              ))
        ...
      </stack>
      <crntObj>
        OldObj:Bag
        => <crntClass>Class</crntClass>
           <location> NewOL </location>
           Obj
      </crntObj>
      <return> OldT:Type => T </return>
      C:Bag
    </control>
    <env> Env => . </env>
    <store>
      ...
      OL |-> objectClosure(NewOL:Int, Obj:Bag) :: _
      ...
    </store>

end module
