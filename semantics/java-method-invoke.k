module JAVA-METHOD-INVOKE
    imports JAVA-PROCESS-CLASSES
    imports JAVA-CLASSES

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
          ListItem((Class:Id, BI:BagItem))
          ...
        </envStack>,
        IsQ
      ),,
        'ListWrap(ParamValues)
      ) => invokeImpl(
        lookupMethod(
          Class,
          getClassList(Rest ListItem((Class, BI))),
          Name, getTypes(ParamValues), Env
        ),
        OL,
        'ListWrap(ParamValues)
      )
      ...
    </k>
    <isQualified> _ => IsQ </isQualified>
    <className> Class </className>
    <methods> Env:Map </methods>

syntax K ::= "getClassList" "(" List ")"
rule (.List{K} => Class),, getClassList((ListItem(Class, _) => .) _)
        [structural anywhere]
rule getClassList(.) => .List{K}
        [structural anywhere]

syntax K ::= "invokeImpl" "(" K   //lookupMethod statement, later methodClosure
                          "," Int //OL - object location
                          "," K   //'ListWrap(ParamValues:KResult)
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
                                List{K} "," //class list, from derived to base one
                                Id ","      //Method name
                                Types ","   //Method param types
                                Map         //methods map of the ObjectClass to search
                            ")"           [strict(4)]
           | "lookupMethod" "(" K ","       //Class name of the reference used to call the method
                                            //or .K if we cannot search for more specific signature
                                List{K} "," //class list, from derived to base one
                                Id ","      //Method name
                                Types ","   //Method param types
                                Map ","     //methods map of the ObjectClass to search
                                K           //method closure of the most specific method so far
                                            //or undefined::nullType if no method was found yet
                            ")"           [strict(6)]

rule lookupMethod(Class, Ks, Name, Ts:Types, Env)
  => lookupMethod(Class, Ks, Name, Ts, Env, undefined::nullType)

// all lookupMethod rules traverse the class hierarchy from Object to the concrete class itself.
rule [lookupMethodNoAlternatives]:
    (. => isPreferableSig(
            'LazyAnd(
              isAccessible(ObjectClass:Id, getMethodAccessMode(TV)),,
              subtype(CallTL, SigTL)
            ),
            TV
          ) )
     ~> lookupMethod(
          _:Id,
          (_,, ObjectClass),
          Name,
          types(CallTL:List{K}),
          (sig(Name, types(SigTL:List{K})) |-> TV => .) _:Map,
          undefined::_
        )

rule [lookupMethodWithAlternative]:
    (. => isPreferableSig(
            'LazyAnd(
              isAccessible(ObjectClass, getMethodAccessMode(TV)),,
              'LazyAnd(subtype(CallTL, SigTL),, subtype(SigTL, AltTL))
            ),
            TV
          ) )
     ~> lookupMethod(
          _:Id,
          (_,, ObjectClass),
          Name,
          types(CallTL),
          (sig(Name, types(SigTL)) |-> TV => .) _:Map,
          _ :: methodType(_, AltTL:List{K}, _)
        )

rule [lookupMethodSignatureFixed]:
    lookupMethod(
      .K,
      (_,, ObjectClass),
      Name,
      _,
      (sig(Name, types(SigTL)) |-> TV => .) _:Map,
      MCClosure:RawVal :: methodType(Acc:AccessMode, SigTL, T)
      => 'If(
            isAccessibleForOverwriting(
              getMethConsClosureClass(MCClosure), Acc, ObjectClass, getMethodAccessMode(TV)
            ),,
            TV,,
            MCClosure :: methodType(Acc, SigTL, T)
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

rule (isPreferableSig(true::bool, TV) => .) ~> lookupMethod(_,_,_,_,_, _ => TV )
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
        (_,, SubClass:Id,, (ObjectClass => .List{K})),
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
        (_,, SubClass,, (ObjectClass => .List{K})),
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
      (_:Id),
      _,
      _,
      .Map,
     TV:TypedVal
    ) => TV

syntax K ::= "getMethConsClosureClass" "(" RawVal ")"
rule getMethConsClosureClass( (_:KLabel)(Class,, _:List{K}) ) => Class
        [structural anywhere]

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

syntax K ::= "getArgTypes" "(" TypedVal ")" [function]
rule getArgTypes(_ :: methodType(_,Ks,_)) => types(Ks) [anywhere]

rule [invokeImpl]:
    <k>
      invokeImpl(
        methodClosure(Class, 'ListWrap(Params:List{K}), Body:K)
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

rule [invokeConstrClosure]:
    <k>
      invokeImpl( constrClosure(Class, 'ListWrap(Params), FirstLine:K, Body) :: T, OL, K )
      => invokeImpl(
            methodClosure(Class, 'ListWrap(Params), FirstLine ~> IInit ~> Body) :: T, OL, K
         )
      ...
    </k>
    <className> Class </className>
    <instanceInit> IInit:K </instanceInit>

context 'SuperConstrInv(_,, 'ListWrap(_:List{KResult},, HOLE,, _) )

rule [SuperConstrInv]:
    <k>
      'SuperConstrInv(_,, 'ListWrap( Vals:List{KResult} ))
      => 'ExprStm('Invoke(
                'Method('MethodName( BaseClass )),,
                'ListWrap(Vals)
          ))
      ...
    </k>
    <crntClass> Class </crntClass>
    <className> Class </className>
    <extends> BaseClass </extends>

end module
