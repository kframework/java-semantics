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

context 'MethodName(HOLE,,_:K)

//objClos.X(_)
rule [MethodNameQualified]:
    <k>
      'MethodName(objectClosure(<envStack> EStack:List </envStack>)::class Class,, Name)
      => lookupMethodData(Class, Name, <envStack> EStack </envStack>)
      ...
    </k>
when
    Id2String(Name) =/=String "getClass"
        [structural]

rule [MethodNameQualifiedNull]:
    <k>
      'MethodName(null::_ ,, X)
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
      'SuperMethod(_,, Name) => lookupMethodData(BaseClass, Name, <envStack> EStack </envStack>)
      ...
    </k>
    <crntClass> Class </crntClass>
    <envStack>... ListItem((Class, _)) EStack </envStack>
    <className> Class:Id </className>
    <extends> BaseClass:Id </extends>
        [structural]

syntax KResult ::= "lookupMethodData" "(" Id      //target ref class name
                                      "," Id      //method name
                                      "," BagItem //target <envLayer> content
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
    'Invoke(
      ( lookupMethodData(Class,Name, BI:BagItem)
        => lookupMethod(Class,Name, getTypes(ParamValues), BI)
      ),,
      'ListWrap(ParamValues)
    )

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
                                Id ","      //Method name
                                Types ","   //Method param types
                                BagItem     //<envStack> to search
                            ")"           [strict(3)]
           | "lookupMethod" "(" K ","       //Class name of the reference used to call the method
                                            //or .K if we cannot search for more specific signature
                                Id ","      //Method name
                                Types ","   //Method param types
                                BagItem "," //<envStack> to search
                                K           //method closure of the most specific method so far
                                            //or undefined::nullType if no method was found yet
                            ")"           [strict(5)]

rule lookupMethod(Class, Name, Ts:Types, BI)
  => lookupMethod(Class, Name, Ts, BI, undefined::nullType)

rule [lookupMethodNoAlternatives]:
    (. => isPreferableSig(subtype(CallTL, SigTL), L:Int) )
     ~> lookupMethod(
          _:Id,
          Name,
          types(CallTL:List{K}),
          <envStack>
            ...
            ListItem((_, <env>... sig(Name, types(SigTL:List{K})) |-> L =>. ...</env>))
          </envStack>,
          undefined::_
        )

rule [lookupMethodWithAlternative]:
    (. => isPreferableSig( 'LazyAnd(subtype(CallTL, SigTL),, subtype(SigTL, AltTL)), L ) )
     ~> lookupMethod(
          _:Id,
          Name,
          types(CallTL),
          <envStack>
            ...
            ListItem((_, <env>... sig(Name, types(SigTL)) |-> L =>. ...</env>))
          </envStack>,
          _ :: methodType(_, AltTL:List{K}, _)
        )

rule [lookupMethodSignatureFixed]:
    lookupMethod(
      .K,
      Name,
      _,
      <envStack>
        ...
        ListItem((_, <env>... sig(Name, types(AltTL)) |-> L =>. ...</env>))
      </envStack>,
      _ :: methodType(_, AltTL, _) => typedLookup(L)
    )

rule [lookupMethodSignatureFixedLayerDiscard]:
    lookupMethod(
      .K,
      Name,
      _,
      <envStack>
        ...
        ListItem((_, <env> Env:Map </env>)) => .
      </envStack>,
      _ :: methodType(_, AltTL, _)
    )
when
    notBool sig(Name, types(AltTL)) in keys(Env)

syntax K ::= "isPreferableSig" "(" K "," Int ")"  [strict(1)]

rule (isPreferableSig(true::bool, L) => .) ~> lookupMethod(_,_,_,_, _ => typedLookup(L) )
rule isPreferableSig(false::bool, _) => .

rule [lookupMethodOtherNameDiscard]:
    lookupMethod(
      _,
      Name,
      _,
      <envStack>
        ...
        ListItem((_, <env>... sig(X:Id, _) |-> _ => . ...</env>))
      </envStack>,
      _:K
    )
when
    X =/=K Name

rule [lookupMethodOtherDiscard]:
    lookupMethod(
      _,
      _,
      _,
      <envStack>
        ...
        ListItem((_, <env>... X |-> _ => . ...</env>))
      </envStack>,
      _:K
    )

rule [lookupMethodLayerDiscard]:
    lookupMethod(
      Class1:Id,
      _,
      _,
      <envStack>
        ...
        ListItem((Class2:Id, <env> . </env>)) => .
      </envStack>,
      _:K
    )
when
    Class1 =/=K Class2

rule [lookupMethodLayerDiscard]:
    lookupMethod(
      Class => .K,
      _,
      _,
      <envStack>
        ...
        ListItem((Class, <env> . </env>)) => .
      </envStack>,
      _:K
    )

rule [lookupMethodEnd]:
    lookupMethod(
      _,
      _,
      _,
      <envStack> . </envStack>,
      TV:TypedVal
    ) => TV

rule [Invoke]:
    <k>
      'Invoke(
        methodClosure(Class, OL:Int, 'ListWrap(Params:List{K}), Body:K)
            :: methodType(_, _, T),,
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
      <crntObj> OldObj:Bag => <crntClass>Class</crntClass> Obj </crntObj>
      <return> OldT:Type => T </return>
      C:Bag
    </control>
    <env> Env => . </env>
    <store>
      ...
      OL |-> objectClosure(Obj:Bag) :: _
      ...
    </store>

end module
