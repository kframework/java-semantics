require "java-core.k"
require "java-subtyping.k"
require "java-process-classes.k"
require "java-classes.k"
require "java-statements.k"
require "java-static-init.k"

module JAVA-METHOD-INVOKE
    imports JAVA-CORE
    imports JAVA-SUBTYPING
    imports JAVA-PROCESS-CLASSES
    imports JAVA-CLASSES
    imports JAVA-STATEMENTS
    imports JAVA-STATIC-INIT

/*@\subsection{Method invocation}
The method lookup is the same as in untyped KOOL.
The method closure application and return are slightly different,
since we need to check that the type of the returned value is an
instance of the claimed return type of the method.  The first group of
rules below are identical to those in untyped KOOL. */

rule 'Method('MethodName(Ks:List{K})) => 'MethodName(Ks)    [structural, anywhere]
rule 'Method(K:K,, _:K,, Name:Id) => 'MethodName(K,, Name)  [structural, anywhere]

rule [MethodNameUnqInstanceCT]:
    <k>
      'MethodName(Name:Id) => 'MethodName('This(.List{K}),, Name)
      ...
    </k>
    <location> _:Int </location>
        [structural]

rule [MethodNameUnqStaticCT]:
    <k>
      'MethodName(Name:Id) => 'MethodName(Class,, Name)
      ...
    </k>
    <crntClass> Class:ClassType </crntClass>
    <location> noValue </location>
        [structural]

rule 'MethodName(K:K,, Name:Id) => methodNameImpl(K, Name, getKLabel(K) =/=KLabel 'This)

syntax K ::= "methodNameImpl" "("
                                  K ","   //qualifier exp
                                  Id ","  //method name
                                  Bool    //IsQ - isQualified
                              ")"

//resolving the qualifier of a qualified method call: either an object or a class reference
context methodNameImpl(HOLE, _, _)

//objClos.X(_)
rule [MethodNameQualified]:
    <k>
      methodNameImpl(objectClosure(OL:Int, <envStack> EStack:List </envStack>)::Class:ClassType,
          Name:Id, IsQ:Bool)
      => lookupMethodData(OL, Class, Name, <envStack> EStack </envStack>, IsQ)
      ...
    </k>
when
    Id2String(Name) =/=String "getClass"
        [structural]

//Class.X(_)
rule [MethodNameStatic]:
    <k>
      methodNameImpl(Class:ClassType, Name:Id, IsQ:Bool)
      => lookupMethodData(noValue, Class, Name,
          <envStack> ListItem((Class, <env> . </env>)) </envStack>, IsQ)
      ...
    </k>
when
    Id2String(Name) =/=String "getClass"
        [structural]

rule [MethodNameQualifiedNull]:
    <k>
      methodNameImpl(null::_ , _,_)
      =>  'Throw('NewInstance(
            'None(.List{K}),,
            class String2Id("java.lang.NullPointerException"),,
            'ListWrap( null :: nullType ),,
            'None(.List{K})
          ))
      ...
    </k>
        [structural]

// super.X(_)
rule [SuperMethod]:
    <k>
      'SuperMethod(_:K,, Name:Id)
      => lookupMethodData(OL, BaseClass, Name, <envStack> EStack </envStack>, false)
      ...
    </k>
    <crntClass> Class:ClassType </crntClass>
    <location> OL:Int </location>
    <envStack>... ListItem((Class, _)) EStack:List </envStack>
    <classType> Class </classType>
    <extends> BaseClass:ClassType </extends>
        [structural]

syntax KResult ::= "lookupMethodData" "(" K         //OL - object location, or noValue
                                      "," ClassType //target ref class name
                                      "," Id        //method name
                                      "," BagItem   //target <envLayer> content
                                      "," Bool      //IsQ - isQualified
                    ")"

/*@ Closure application needs to also set a new return type in the
\textsf{return} cell, in order for the values returned by its body to
be checked against the return type of the method.  To do this correctly,
we also need to stack the current status of the \textsf{return} cell
and then pop it when the method returns. */

//todo test order of params evaluation - here it should get wrong
context 'Invoke(HOLE,, _)
context 'Invoke(_:KResult ,,'ListWrap(_:List{K},,HOLE,,_:List{K}))

rule [InitSignatureSearchInClassRef]:
    <k>
      'Invoke(lookupMethodData(
        OLK:K,
        Class:ClassType,
        MethodName:Id,
        <envStack>
          Rest:List
          ListItem((Class:ClassType, BI:BagItem))
          ...
        </envStack>,
        IsQ:Bool
      ),,
        'ListWrap(ParamValues:List{K})
      ) => invokeImpl(
        lookupMethod(
          lookupSignature(
            MethodName,
            getTypesFromValues(ParamValues),
            Env,
            IsQ,
            noValue
          ),
          getClassList(Rest ListItem((Class, BI))),
          Env,
          noValue
        ),
        OLK,
        'ListWrap(ParamValues)
      )
      ...
    </k>
    <classType> Class </classType>
    <methods> Env:Map </methods>
    <metaType> classMetaT </metaType>
when isKResult(ParamValues)

rule [InitSignatureSearchInInterfaceRef]:
    <k>
      'Invoke(lookupMethodData(
        OLK:Int,
        Class:ClassType,
        MethodName:Id,
        <envStack>
          ListItem((ActualClass:ClassType, _))
          ...
        </envStack>,
        IsQ:Bool
      ),,
        'ListWrap(ParamValues:List{K})
      ) => invokeImpl(
        lookupMethod(
          lookupSignature(
            MethodName,
            getTypesFromValues(ParamValues),
            Env,
            IsQ,
            noValue
          ),
          ActualClass,
          ActualClassEnv,
          noValue
        ),
        OLK,
        'ListWrap(ParamValues)
      )
      ...
    </k>
    <class>
      <classType> Class </classType>
      <methods> Env:Map </methods>
      <metaType> interfaceMetaT </metaType>
      ...
    </class>
    <class>
      <classType> ActualClass </classType>
      <methods> ActualClassEnv:Map </methods>
      ...
    </class>
when isKResult(ParamValues)

syntax K ::= "getClassList" "(" List ")"
rule (.List{K} => Class),, getClassList((ListItem((Class:ClassType, _)) => .List) _)
        [structural, anywhere]
rule getClassList(.) => .List{K}
        [structural, anywhere]

syntax K ::= "invokeImpl" "(" K   //lookupMethod statement, later methodClosure
                          "," K   //OL - object location, or noValue for static methods
                          "," K   //'ListWrap(ParamValues:List{KResult})
                          ")"
        [strict(1)]

//converts a List{TypedVal} to Types.
syntax K ::= "getTypesFromValues" "("
                            List{K}     //List{KResult} a list of values
                        ")"
           | "getTypesFromValues" "("
                            List{K} "," //List{KResult} a list of types
                            List{K}     //List{KResult} a list of values
                        ")"

rule getTypesFromValues(VKs:List{K}) => getTypesFromValues(.List{K}, VKs)
rule getTypesFromValues(TKs:List{K}, _::T:Type,, VKs:List{K})
     => getTypesFromValues(TKs,,T, VKs)
rule getTypesFromValues(TKs:List{K}, .List{K}) => types(TKs)

//searches for the correct method signature to use
//when calling a given MethodName with the given argument types
//computes into a signature
syntax K ::= "lookupSignature" "("  Id    // MethodName
                               ","  Types // Argument types
                               ","  Map   // Env - methods environment
                               ","  Bool  // IsQ - whether the original method call was qualified
                               ","  K     // The best signature found so far, or .K if none found
                               ")"
        [strict(2)]

rule [lookupSignatureNoAlternatives]:
    (. => isPreferableSig(
            'LazyAnd(
              isAccessible(getMethodAccessMode(TV), getMethodContextType(TV),
                  getMethodDeclaringClass(TV), IsQ),,
              subtypeList(CallTs, SigTs)
            ),
            sig(MethodName, SigTs)
          ) )
     ~> lookupSignature(
          MethodName:Id,
          CallTs:Types,
          (sig(MethodName, SigTs:Types) |-> TV:TypedVal => .) _:Map,
          IsQ:Bool,
          noValue
        )

rule [lookupSignatureWithAlternative]:
    (. => isPreferableSig(
            'LazyAnd(
              isAccessible(getMethodAccessMode(TV), getMethodContextType(TV),
                  getMethodDeclaringClass(TV), IsQ),,
              'LazyAnd(subtypeList(CallTs, SigTs),, subtypeList(SigTs, AltTs))
            ),
            sig(MethodName, SigTs)
          ) )
     ~> lookupSignature(
          MethodName:Id,
          CallTs:Types,
          (sig(MethodName, SigTs:Types) |-> TV:TypedVal => .) _:Map,
          IsQ:Bool,
          sig(MethodName, AltTs:Types)
        )

rule [lookupSignatureSigDiscard]:
    lookupSignature(
      MethodName:Id,
      _,
      (sig(Name:Id, _) |-> _ => .) _:Map,
      _,
      _
    )
when
    Name =/=K MethodName

rule [lookupSignatureEnd]:
    lookupSignature(_,_,.Map,_,K:K) => K
when K =/=K noValue

syntax K ::= "isPreferableSig" "(" K "," K ")"  [strict(1)]

rule (isPreferableSig(true::bool, K:K) => .) ~> lookupSignature(_,_,_,_, _ => K )
rule isPreferableSig(false::bool, _) => .

//The right signature is already found.
//Search for the right implementation is performed from the compile-time type of the target
//to more derived types, up to the object type of the target.
syntax K ::= "lookupMethod" "(" K ","      // sig(Name, SigTL) - Method signature
                                List{K} "," //class list, elems of type ClassType,
                                            //from derived to base
                                            //The last one is always the current one.
                                Map ","     //methods map of current LayerClass to search
                                TypedVal    //method closure of the most specific method found so far
                                            //or noValue if no applicable method
                                            //was found yet
                            ")"           [strict(1)]

context lookupMethod(_,_,_,HOLE)    //replacement for strict(4)

rule [lookupMethodFirstCandidate]:
    lookupMethod(
      sig(Name:Id, SigTs:Types),
      _,
      (sig(Name, SigTs) |-> TV:TypedVal _:Map) => .Map,
      noValue => TV
    )

rule [lookupMethodOtherCandidates]:
    lookupMethod(
      sig(Name:Id, SigTs:Types),
      (_,, LayerClass:ClassType),
      (sig(Name, SigTs) |-> TV:TypedVal => .) _:Map,
      MCClosure:RawVal :: methodType(Acc:AccessMode, DeclClass:ClassType, SigTs, T:Type)
      => 'If(
            'LazyAnd(
              ( getMethodContextType(MCClosure :: methodType(Acc, DeclClass, SigTs, T))
                ==K instanceCT
              )::bool,,
              isAccessibleForOverwriting(
                getMethConsClosureClass(MCClosure), Acc, LayerClass, getMethodAccessMode(TV)
              )
            ),,
            TV,,
            MCClosure :: methodType(Acc, DeclClass, SigTs, T)
          )
    )

rule [lookupMethodEntryDiscard]:
    lookupMethod(
      sig(Name:Id, ChosenSigTs:Types),
      _,
      (sig(X:Id, SigTs:Types) |-> _ => .) _:Map,
      _:K
    )
when
    sig(X, SigTs) =/=K sig(Name, ChosenSigTs)

rule [lookupMethodLayerDiscard]:
    <k>
      lookupMethod(
        _,
        (_,, NewLayerClass:ClassType,, (_:ClassType => .List{K})),
        .Map => NewEnv,
        _:K
      )
      ...
    </k>
    <class>
      <classType> NewLayerClass </classType>
      <methods> NewEnv:Map </methods>
      ...
    </class>

rule [lookupMethodEnd]:
    lookupMethod(
      _,
      (_:ClassType),
      .Map,
     TV:TypedVal
    ) => TV

syntax K ::= "getMethConsClosureClass" "(" RawVal ")"
rule getMethConsClosureClass( (_:KLabel)(Class:ClassType,, _:List{K}) ) => Class
        [structural, anywhere]

//Tests whether a method from a given class with a given AccessMode and ContextType
//may be called from the current object environment
syntax K ::= "isAccessible" "(" AccessMode ","  //the method access mode
                                K ","           //evaluates to ContextType - staticCT or instanceCT
                                K ","           //evaluates to ClassType - the method declaring class
                                Bool            //IsQ - whether the initial method call expression was qualified
                            ")"
        [strict(2)]

rule [isAccessiblePublic]:
    isAccessible(public, _,_,_) => true::bool

rule [isAccessibleProtected]:
    <k>
      isAccessible(protected, CT:ContextType, DeclaringClass:ClassType, IsQ:Bool)
      => 'LazyOr(
            'LazyAnd(
              'LazyOr((CT ==K staticCT)::bool,, 'Not(IsQ :: bool)),,
              subtype(CurrentClass, DeclaringClass)
            ),,
            isAccessible(package, CT, DeclaringClass, IsQ)
      )
      ...
    </k>
    <crntClass> CurrentClass:ClassType </crntClass>

rule [isAccessiblePackage]:
    <k>
      isAccessible(package, _, DeclaringClass:ClassType, _)
      => kEq(getPackage(getTopLevel(DeclaringClass)), getPackage(getTopLevel(CurrentClass)))
      ...
    </k>
    <crntClass> CurrentClass:ClassType </crntClass>

//A private method is accessible if the class where it is declared lies
//in the same top-level class as the class that accesses the method
rule [isAccessiblePrivate]:
    <k>
      isAccessible(private, _, DeclaringClass:ClassType, _)
      => kEq(getTopLevel(DeclaringClass), getTopLevel(CurrentClass))
      ...
    </k>
    <crntClass> CurrentClass:ClassType </crntClass>

//tests whether a new method in an overwriting chain is accessible to the old method
syntax K ::= "isAccessibleForOverwriting" "("
                                              Id ","          //OldMethodClass
                                              AccessMode ","  //OldMethodAccessMode
                                              Id ","          //NewMethodClass
                                              AccessMode      //NewMethodAccessMode
                                          ")"
        [strict(4)] //strict(2) also makes sense ut is not used by the construct creation rule

rule isAccessibleForOverwriting(_, private, _, _) => false::bool

rule isAccessibleForOverwriting(OldClass:ClassType, package, NewClass:ClassType, NewAcc:AccessMode)
    => kEq(getPackage(getTopLevel(OldClass)), getPackage(getTopLevel(NewClass)))

rule isAccessibleForOverwriting(_, protected, _, _) => true::bool
rule isAccessibleForOverwriting(_, public,    _, _) => true::bool

syntax K ::= "getArgTypes" "(" TypedVal ")" [function]
rule getArgTypes(_ :: methodType(_,_, Ts:Types, _)) => Ts [anywhere]

rule [invokeImplInstance]:
    <k>
      invokeImpl(
        methodClosure(Class:ClassType, 'ListWrap(Params:List{K}), instanceCT, Body:K)
            :: methodType(_,_,_, T:Type),
        OL:Int,
        'ListWrap(ParamValues:List{K})
      ) ~> K:K
       => bindto Params, ParamValues ~> Body ~> 'Return('None(.List{K}))
    </k>
    <control>
      <stack>
        . =>  ListItem((methodSL,.K,.K,K, Env,
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
        => <crntClass> Class </crntClass>
           <location> NewOL </location>
           Obj
      </crntObj>
      <return> OldT:Type => T </return>
      C:Bag
    </control>
    <env> Env:Map => . </env>
    <store>
      ...
      OL |-> objectClosure(NewOL:Int, Obj:Bag) :: _
      ...
    </store>
when isKResult(ParamValues)

//todo report bug: if we remove parentheses around (bindto Params, ParamValues)
//we'll get compile-time error
//test with the latest version of K
//the problem is present in v8518. v8620 compiles but cannot execute the definition.
rule [invokeImplStatic]:
    <k>
      invokeImpl(
        methodClosure(Class:ClassType, 'ListWrap(Params:List{K}), staticCT, Body:K)
            :: methodType(_,_,_, T:Type),
        _,
        'ListWrap(ParamValues:List{K})
      ) ~> K:K
       => staticInit(Class) ~> (bindto Params, ParamValues) ~> Body ~> 'Return('None(.List{K}))
    </k>
    <control>
      <stack>
        . =>  ListItem((methodSL,.K,.K,K, Env,
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
        => <crntClass> Class </crntClass>
           <envStack> .List </envStack>
           <location> noValue </location>
      </crntObj>
      <return> OldT:Type => T </return>
      C:Bag
    </control>
    <env> Env:Map => . </env>
when isKResult(ParamValues)

rule [invokeConstrClosure]:
    <k>
      invokeImpl( constrClosure(Class:ClassType, 'ListWrap(Params:List{K}), FirstLine:K, Body:K)
          :: T:Type, OL:Int, K:K
      )
      => invokeImpl(
            methodClosure(Class, 'ListWrap(Params), instanceCT,
              FirstLine
              ~>  #if getKLabel(FirstLine) ==KLabel 'AltConstrInv
                    #then .K
                    #else freshEnv(IInit)
                  #fi
              ~> Body
            ) :: T, OL, K
         )
      ...
    </k>
    <classType> Class </classType>
    <instanceInit> IInit:K </instanceInit>

//executes the given computation in a fresh environment, then restores the original environment.
syntax K ::= "freshEnv" "(" K ")"
rule [freshEnv]:
    <k>
      freshEnv(K:K) => K ~> env(Env)
      ...
    </k>
    <env> Env:Map => . </env>

context 'SuperConstrInv(_,, 'ListWrap(KRs:List{K},, HOLE,, _) )
when isKResult(KRs)

rule [SuperConstrInv]:
    <k>
      'SuperConstrInv(_,, 'ListWrap( Vals:List{K} ))
      => 'ExprStm('Invoke(
                'SuperMethod('None(.List{K}),, getConsName(BaseClass) ),,
                'ListWrap(Vals)
          ))
      ...
    </k>
    <crntClass> Class:ClassType </crntClass>
    <classType> Class </classType>
    <extends> BaseClass:ClassType </extends>
when isKResult(Vals)

context 'AltConstrInv(_,, 'ListWrap(KRs:List{K},, HOLE,, _) )
when isKResult(KRs)

rule [AltConstrInv]:
    <k>
      'AltConstrInv(_,, 'ListWrap( Vals:List{K} ))
      => 'ExprStm('Invoke(
                'Method('MethodName( getConsName(Class) )),,
                'ListWrap(Vals)
          ))
      ...
    </k>
    <crntClass> Class:ClassType </crntClass>
when isKResult(Vals)

endmodule
