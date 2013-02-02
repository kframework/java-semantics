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
                                      "," ClassType //target ref class
                                      "," Id        //method name
                                      "," BagItem   //target <envStack> content
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

rule [InvokeToInvokeImpl]:
    'Invoke(lookupMethodData(
        OLK:K,
        Class:ClassType,
        MethodName:Id,
        EnvStack:BagItem,
        IsQ:Bool
      ),,
      'ListWrap(ParamValues:List{K})
    ) => invokeImpl(
      lookupMethod(
        Class,
        MethodName,
        getTypesFromValues(ParamValues),
        IsQ,
        EnvStack
      ),
      OLK,
      'ListWrap(ParamValues)
    )
when isKResult(ParamValues)

//Lookup the right methodClosure based on supplied parameters.
//If the method is not found in the supplied class list, we should search for it in the
//class list corresponding to the enclosing class of the caller class.
//First we search for the signature - lookupSignature construct.
//Afterwards we search for the right implementation in the hierarchy, once the signature is known
// - lookupMethodSigKnown.
syntax K ::= "lookupMethod" "(" ClassType //target ref class
                            "," Id        //method name
                            "," Types     //List of actual param types
                            "," Bool      //IsQ - isQualified
                            "," BagItem   //target <envStack> content
                            ")"
        [strict(3)]

rule [lookupMethodInClassRef]:
    <k>
      lookupMethod(
        Class:ClassType,
        MethodName:Id,
        CallTs:Types,
        IsQ:Bool,
        <envStack>
          Rest:List
          ListItem((Class:ClassType, BI:BagItem))
          ...
        </envStack>
      ) =>  lookupMethodSigKnown(
              lookupSignature(MethodName, CallTs, Env, IsQ, noValue, Class),
              getClassList(Rest ListItem((Class, BI))),
              mapWrap(Env),
              noValue
            )
            //Lookup for the same method in the enclosing class, if not found in Class.
            ?? lookupMethod(EnclosingClass, MethodName, CallTs, false,
                  <envStack> ListItem((EnclosingClass, <env> . </env>)) </envStack>
               )
      ...
    </k>
    <classType> Class </classType>
    <methods> Env:Map </methods>
    <metaType> classMetaT </metaType>
    <enclosingClass> EnclosingClass:ClassType </enclosingClass>

rule [lookupMethodInInterfaceRef]:
    <k>
      lookupMethod(
        Class:ClassType,
        MethodName:Id,
        CallTs:Types,
        IsQ:Bool,
        <envStack>
          ListItem((ActualClass:ClassType, _))
          ...
        </envStack>
      ) =>  lookupMethodSigKnown(
              lookupSignature(MethodName, CallTs, Env, IsQ, noValue, Class),
              ActualClass,
              getMethods(ActualClass),
              noValue
            )
            //Lookup for the same method in the enclosing class, if not found in Class.
            ?? lookupMethod(EnclosingClass, MethodName, CallTs, false,
                  <envStack> ListItem((EnclosingClass, <env> . </env>)) </envStack>
               )
      ...
    </k>
    <classType> Class </classType>
    <methods> Env:Map </methods>
    <metaType> interfaceMetaT </metaType>
    <enclosingClass> EnclosingClass:ClassType </enclosingClass>

//returns a mapWrap(Env) with <methods> content of the given class
syntax K ::= "getMethods" "(" ClassType ")"

rule [getMethods]:
    <k> getMethods(Class:ClassType) => mapWrap(Env) ...</k>
    <classType> Class </classType>
    <methods> Env:Map </methods>

rule [lookupMethodDiscard]:
    lookupMethod(noClass,_,_,_,_) => noValue

syntax K ::= "getClassList" "(" List ")"
rule (.List{K} => Class),, getClassList((ListItem((Class:ClassType, _)) => .List) _)
        [structural, anywhere]
rule getClassList(.) => .List{K}
        [structural, anywhere]

syntax K ::= "invokeImpl" "(" K   //lookupMethodSigKnown statement, later methodClosure
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
syntax K ::= "lookupSignature" "("  Id     // MethodName
                               ","  Types  // Argument types
                               ","  Map    // Env - methods environment
                               ","  Bool   // IsQ - whether the original method call was qualified
                               ","  K      // The best signature found so far,
                                           // or noValue if none found
                               ","  ClassType //target class
                               ")"

rule [lookupSignatureNoAlternatives]:
    (. => isPreferableSig(
            'LazyAnd(
              subtypeList(CallTs, SigTs),,
              isAccessible(getMethodAccessMode(TV), getMethodContextType(TV),
                  getMethodDeclaringClass(TV), IsQ, Class)
            ),
            sig(MethodName, SigTs)
          ) )
     ~> lookupSignature(
          MethodName:Id,
          CallTs:Types,
          (sig(MethodName, SigTs:Types) |-> TV:TypedVal => .) _:Map,
          IsQ:Bool,
          noValue,
          Class:ClassType
        )

rule [lookupSignatureWithAlternative]:
    (. => isPreferableSig(
            'LazyAnd(
              'LazyAnd(subtypeList(CallTs, SigTs),, subtypeList(SigTs, AltTs)),,
              isAccessible(getMethodAccessMode(TV), getMethodContextType(TV),
                  getMethodDeclaringClass(TV), IsQ, Class)
            ),
            sig(MethodName, SigTs)
          ) )
     ~> lookupSignature(
          MethodName:Id,
          CallTs:Types,
          (sig(MethodName, SigTs:Types) |-> TV:TypedVal => .) _:Map,
          IsQ:Bool,
          sig(MethodName, AltTs:Types),
          Class:ClassType
        )

rule [lookupSignatureSigDiscard]:
    lookupSignature(
      MethodName:Id,
      _,
      (sig(Name:Id, _) |-> _ => .) _:Map,
      _,_,_
    )
when
    Name =/=K MethodName

rule [lookupSignatureEnd]:
    lookupSignature(_,_,.Map,_,K:K,_) => K

syntax K ::= "isPreferableSig" "(" K "," K ")"  [strict(1)]

rule (isPreferableSig(true::bool, K:K) => .) ~> lookupSignature(_,_,_,_, _ => K, _ )
rule isPreferableSig(false::bool, _) => .

//The right signature is already found.
//Search for the right implementation is performed from the compile-time type of the target
//to more derived types, up to the object type of the target.
syntax K ::= "lookupMethodSigKnown" "("
                              K ","       // sig(Name, SigTL) - Method signature
                              List{K} "," //class list, elems of type ClassType,
                                          //from derived to base
                                          //The last one is always the current one.
                              K ","       //mapWrap(Map) - methods map of current LayerClass
                              TypedVal    //method closure of the most specific method found so far
                                          //or noValue if no applicable method
                                          //was found yet
                            ")"           [strict(1,3,4)]

rule [lookupMethodSigKnownFirstCandidate]:
    lookupMethodSigKnown(
      sig(Name:Id, SigTs:Types),
      _,
      mapWrap( (sig(Name, SigTs) |-> TV:TypedVal _:Map) => .Map ),
      noValue => TV
    )

rule [lookupMethodSigKnownOtherCandidates]:
    lookupMethodSigKnown(
      sig(Name:Id, SigTs:Types),
      (_,, LayerClass:ClassType),
      mapWrap( (sig(Name, SigTs) |-> TV:TypedVal => .) _:Map ),
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

rule [lookupMethodSigKnownEntryDiscard]:
    lookupMethodSigKnown(
      sig(Name:Id, ChosenSigTs:Types),
      _,
      mapWrap( (sig(X:Id, SigTs:Types) |-> _ => .) _:Map ),
      _:K
    )
when
    sig(X, SigTs) =/=K sig(Name, ChosenSigTs)

rule [lookupMethodSigKnownLayerDiscard]:
    <k>
      lookupMethodSigKnown(
        _,
        (_,, NewLayerClass:ClassType,, (_:ClassType => .List{K})),
        mapWrap( .Map => NewEnv ),
        _:K
      )
      ...
    </k>
    <class>
      <classType> NewLayerClass </classType>
      <methods> NewEnv:Map </methods>
      ...
    </class>

rule [lookupMethodSigKnownEnd]:
    lookupMethodSigKnown(
      _,
      (_:ClassType),
      mapWrap(.Map),
     TV:TypedVal
    ) => TV

rule [lookupMethodSigKnownNoSig]:
    lookupMethodSigKnown(noValue,_,_,_) => noValue

syntax K ::= "getMethConsClosureClass" "(" RawVal ")"
rule getMethConsClosureClass( (_:KLabel)(Class:ClassType,, _:List{K}) ) => Class
        [structural, anywhere]

//Tests whether a method from a given class with a given AccessMode and ContextType
//may be called from the current object environment
syntax K ::= "isAccessible" "(" AccessMode ","  //the method access mode
                                K ","           //evaluates to ContextType - staticCT or instanceCT
                                K ","           //evaluates to ClassType - the method declaring class
                                Bool ","        //IsQ - whether the initial method call expression was qualified
                                ClassType       //target class, used by protected mode in inner classes
                            ")"
        [strict(2)]

rule [isAccessiblePublic]:
    isAccessible(public, _,_,_,_) => true::bool

rule [isAccessibleProtected]:
    <k>
      isAccessible(protected, CT:ContextType, DeclaringClass:ClassType, IsQ:Bool,
          TargetClass:ClassType
      )
      => 'LazyOr(
            'LazyAnd(
              'LazyOr((CT ==K staticCT)::bool,, 'Not(IsQ :: bool)),,
              subtype(
                'If(IsQ::bool,, CurrentClass,, TargetClass),
                DeclaringClass
              )
            ),,
            isAccessible(package, CT, DeclaringClass, IsQ, TargetClass)
      )
      ...
    </k>
    <crntClass> CurrentClass:ClassType </crntClass>

rule [isAccessiblePackage]:
    <k>
      isAccessible(package, _, DeclaringClass:ClassType, _,_)
      => kEq(getPackage(getTopLevel(DeclaringClass)), getPackage(getTopLevel(CurrentClass)))
      ...
    </k>
    <crntClass> CurrentClass:ClassType </crntClass>

//A private method is accessible if the class where it is declared lies
//in the same top-level class as the class that accesses the method
rule [isAccessiblePrivate]:
    <k>
      isAccessible(private, _, DeclaringClass:ClassType, _,_)
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
        [strict(4)] //strict(2) also makes sense but is not used by the construct creation rule

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
