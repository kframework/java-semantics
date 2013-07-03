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
      'MethodName(Name:Id) => 'MethodName('This(.List{K})::Class,, Name)
      ...
    </k>
    <crntClass> Class:ClassType </crntClass>
    <contextType> instanceCT </contextType>                 [structural]

rule [MethodNameUnqStaticCT]:
    <k>
      'MethodName(Name:Id) => 'MethodName(Class,, Name)
      ...
    </k>
    <crntClass> Class:ClassType </crntClass>
    <contextType> staticCT </contextType>                   [structural]

rule [MethodName]:
    'MethodName(QualK:K,, Name:Id)
    => lookupMethodData(QualK, Name, notBool isTypedThis(QualK))        [structural]

//True for 'This(_)::T, false otherwise
syntax K ::= "isTypedThis" "(" K ")"                                    [function]

rule isTypedThis(K::_) => getKLabel(K) ==KLabel 'This

rule isTypedThis(K) => false
when getKLabel(K) =/=KLabel '_::_

// super.X(_)
rule [SuperMethod]:
    <k>
      'SuperMethod(_:K,, Name:Id)
      => lookupMethodData(superMethod::BaseClass, Name, false)
      ...
    </k>
    <crntClass> Class:ClassType </crntClass>
    <classType> Class </classType>
    <extends> BaseClass:ClassType </extends>  [structural]

syntax KResult ::= "lookupMethodData" "(" K         //TypedVal - typed obj closure for instance qualifier
                                                    //or ClassType - for class qualifier
                                      "," Id        //method name
                                      "," Bool      //IsQ - isQualified
                    ")"
                  | "superMethod"   //Elaboration result super keyword in super.m() call.

/*@ Closure application needs to also set a new return type in the
\textsf{return} cell, in order for the values returned by its body to
be checked against the return type of the method.  To do this correctly,
we also need to stack the current status of the \textsf{return} cell
and then pop it when the method returns. */

//First argument is reduced up to lookupMethodData.
context elabDispose('Invoke(HOLE,, _))

rule [InvokeToInvokeImplInstance]:
    elabDispose('Invoke(lookupMethodData(
        Exp:K :: QualT:RefType,
        MethodName:Id,
        IsQ:Bool
      ),,
      'ListWrap(ParamExps:List{K}))
    ) => lookupMethod(
      QualT,
      MethodName,
      IsQ,
      noValue,
      false,
      Exp::QualT,
      ParamExps
    )

rule [InvokeToInvokeImplStatic]:
    elabDispose('Invoke(lookupMethodData(
        Class:ClassType,
        MethodName:Id,
        IsQ:Bool
      ),,
      'ListWrap(ParamExps:List{K}))
    ) => lookupMethod(
      Class,
      MethodName,
      IsQ,
      noValue,
      false,
      noValue,
      ParamExps
    )

//Lookup the right methodClosure based on supplied parameters.
//If the method is not found in the supplied class list, we should search for it in the
//class list corresponding to the enclosing class of the caller class.
//First we search for the signature - lookupSignature construct.
//Afterwards we search for the right implementation in the hierarchy, once the signature is known
// - lookupMethodSigKnown.
syntax K ::= "lookupMethod" "(" RefType //target ref class
                            "," Id        //method name
                            "," Bool      //IsQ - isQualified
                            "," K         //Evaluates to the signature to be called, or noValue if no signature was found yet
                                          //Sig format: mapWrap(Sig |-> MethodTV)
                            "," Bool      //SigSearched: true if Sig was already searched for the current class, false otherwise.
                                          // Starts with false.
                            "," K         //TypedExp - qualifier expression, or noValue for class qualifiers.
                            "," List{K}   //ParamExps - parameter expressions of type TypedExp
                            ")"
        [strict(4)]

//todo K 10341 it looks like [strict] above don't work
context lookupMethod(_,_,_,HOLE,_,_,_)

rule [lookupMethodLookupSig]:
    <k>
      lookupMethod(
        Class:ClassType,
        MethodName:Id,
        IsQ:Bool,
        noValue => lookupSignature(MethodName, getTypesFromValues(ParamExps), Env, IsQ, noValue, Class),
        false => true,
        _,
        ParamExps:List{K}
      )
      ...
    </k>
    <classType> Class </classType>
    <methods> Env:Map </methods>

//When qualifier is not a class, lookup the method in the class Object
rule [lookupMethodLookupSigGeneralRef]:
    <k>
      lookupMethod(
        QualT:RefType,
        MethodName:Id,
        IsQ:Bool,
        noValue => lookupSignature(MethodName, getTypesFromValues(ParamExps), Env, IsQ, noValue, objectClass),
        false => true,
        _,
        ParamExps:List{K}
      )
      ...
    </k>
    <classType> ObjT:ClassType </classType>
    <methods> Env:Map </methods>
when
    (notBool (isClassType(QualT) ==K true)) andBool (objectClass ==K ObjT)

//If resolved method is static, we cannot insert in the construct the actual method body,
//because this body might not be elaborated.
rule [lookupMethodSigFound]:
    lookupMethod(
      QualT:RefType,
      _,
      _,
      mapWrap(Sig:Signature |-> methodClosure(_,_, CT:ContextType, _,_,_,_) :: methodType(_, RetT:Type)),
      true, QualK:K, ParamExps:List{K}
    ) => elabRes(methodInvokeRuntime(QualT, Sig, QualK, ParamExps, CT) :: RetT)

rule [lookupMethodGotoEnclosing]:
    <k>
      lookupMethod(
        Class:ClassType => EnclosingClass,
        MethodName:Id,
        _ => false,
        noValue,
        true => false,
        _ => noValue,
        _
      )
      ...
    </k>
    <classType> Class </classType>
    <enclosingClass> EnclosingClass:ClassType </enclosingClass>

rule [lookupMethodDiscard]:
    lookupMethod(noClass,_,_,_,_,_,_) => noValue

//converts a List{TypedVal} to Types.
syntax K ::= "getTypesFromValues" "("
                            List{K}     //List{KResult} a list of source expressions
                        ")"
           | "getTypesFromValues" "("
                            List{K} "," //List{KResult} a list of result types
                            List{K}     //List{KResult} a list of source typed expressions
                        ")"

rule getTypesFromValues(VKs:List{K}) => getTypesFromValues(.List{K}, VKs)
rule getTypesFromValues(TKs:List{K}, _::T:Type,, VKs:List{K})
     => getTypesFromValues(TKs,,T, VKs)
rule getTypesFromValues(TKs:List{K}, .List{K}) => types(TKs)

//Search for the correct method signature to use
//when calling a given MethodName with the given argument types.
//computes mapWrap(Sig -> MethodTV)
syntax K ::= "lookupSignature" "("  Id     // MethodName
                               ","  K      // Computes into Types - argument types
                               ","  Map    // Env - methods environment Map[sig -> Class]
                               ","  Bool   // IsQ - whether the original method call was qualified
                               ","  K      // The best signature found so far, in the form mapWrap(Sig -> Type)
                                           // or noValue if none found
                               ","  ClassType //target class
                               ")"  [strict(2,5)]

rule [lookupSignatureMain]:
    <k>
      lookupSignature(
        MethodName:Id,
        CallTs:Types,
        (sig(MethodName, SigTs:Types) |-> DecClass:ClassType => .) _:Map,
        IsQ:Bool,
        OldMethodDecRecord:KResult
        => 'If(
            'LazyAnd(
              'LazyAnd(
                subtypeList(CallTs, SigTs),,
                #if OldMethodDecRecord ==K noValue
                  #then true
                  #else subtypeList(SigTs, getMethodDecArgTypes(OldMethodDecRecord))
                #fi
              ) :: bool,,
              isAccessible(getMethodAccessMode(TV), getMethodContextType(TV),
                  DecClass, IsQ, Class)
            ) :: bool,,
            mapWrap(sig(MethodName, SigTs) |-> TV),,
            OldMethodDecRecord
          ),
        Class:ClassType
      )
      ...
    </k>
    <classType> DecClass </classType>
    <methodDecs>... sig(MethodName, SigTs) |-> TV:TypedVal ...</methodDecs>

syntax K ::= "getMethodDecArgTypes" "(" K ")"
rule getMethodDecArgTypes(mapWrap(sig(_, Ts:Types) |-> _)) => Ts  [structural, anywhere]

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
    lookupSignature(_,_,.Map,_, SigWrap:KResult, _) => SigWrap

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
    isAccessible(public, _,_,_,_) => true

rule [isAccessibleProtected]:
    <k>
      isAccessible(protected, CT:ContextType, DeclaringClass:ClassType, IsQ:Bool,
          TargetClass:ClassType
      )
      => 'LazyOr(
            'LazyAnd(
              'LazyOr((CT ==K staticCT),, 'Not(IsQ)::bool) :: bool,,
              subtype(
                'If(IsQ,, CurrentClass,, TargetClass),
                DeclaringClass
              )
            ) :: bool,,
            isAccessible(package, CT, DeclaringClass, IsQ, TargetClass)
      ) :: bool
      ...
    </k>
    <crntClass> CurrentClass:ClassType </crntClass>

rule [isAccessiblePackage]:
    <k>
      isAccessible(package, _, DeclaringClass:ClassType, _,_)
      => eqAux(getPackage(getTopLevel(DeclaringClass)), getPackage(getTopLevel(CurrentClass)))
      ...
    </k>
    <crntClass> CurrentClass:ClassType </crntClass>

//A private method is accessible if the class where it is declared lies
//in the same top-level class as the class that accesses the method
rule [isAccessiblePrivate]:
    <k>
      isAccessible(private, _, DeclaringClass:ClassType, _,_)
      => eqAux(getTopLevel(DeclaringClass), getTopLevel(CurrentClass))
      ...
    </k>
    <crntClass> CurrentClass:ClassType </crntClass>

//The elaboration result of a method invocation.
syntax K ::= "methodInvokeRuntime" "(" RefType    //Compile-time target class, or more general reference
                                   "," Signature  //Method signature
                                   "," K          //Qualifier expression, if any, or noValue if it is static invocation
                                   "," List{K}    //Arguments, each of type TypedExp
                                   "," ContextType  //instanceCT or staticCT
                                   ")"

//Evaluate the qualifier
//JLS $15.12.4.1 - Compute Target Reference
context methodInvokeRuntime(_,_, HOLE, _,_)::_

//todo a test for expression order exists, but is unable expose the error in this rule.
//Waiting for an alternative from K guys.
//JLS $15.12.4.2 - Evaluate Arguments
context methodInvokeRuntime(_,_,_:KResult, (_,,HOLE,,_), _)::_

rule [methodInvokeRuntimeInstanceOnClass]:
    <k>
      methodInvokeRuntime(Class:ClassType, Sig:Signature,
        objectClosure(OL:Int,
          <envStack>
            Rest:List
            ListItem((Class:ClassType, BI:BagItem))
            ...
          </envStack>)::_,
          ParamVals:List{K}, instanceCT
      )::_
      => invokeImpl(
        lookupOverloadedMethod(Sig, getClassList(Rest ListItem((Class, BI))), mapWrap(.Map), noValue),
        OL, 'ListWrap(ParamVals)
      )      ...
    </k>
    <classType> Class </classType>
    <metaType> classMetaT </metaType>
when
    isKResult(ParamVals)

rule [methodInvokeRuntimeStaticOnClass]:
    methodInvokeRuntime(Class:ClassType, Sig:Signature, _:KResult, ParamVals:List{K}, staticCT)::_
    => invokeImpl(
      lookupOverloadedMethod(Sig, Class, mapWrap(.Map), noValue),
      noValue, 'ListWrap(ParamVals)
    )
when
    isKResult(ParamVals)

rule [methodInvokeRuntimeInstanceOnInterface]:
    <k>
      methodInvokeRuntime(Class:ClassType, Sig:Signature,
        objectClosure(OL:Int,
          <envStack>
            ListItem((ActualClass:ClassType, _))
            ...
          </envStack>)::_,
        ParamVals:List{K}, instanceCT
      )::_
      => invokeImpl(
        lookupOverloadedMethod(Sig, ActualClass, mapWrap(.Map), noValue),
        OL, 'ListWrap(ParamVals)
      )      ...
    </k>
    <classType> Class </classType>
    <metaType> interfaceMetaT </metaType>
when
    isKResult(ParamVals)

rule [methodInvokeRuntimeOnString]:
    methodInvokeRuntime(_, Sig:Signature,
        Str:String::_,
        ParamVals:List{K}, _
    )::_
    => invokeImpl(
      lookupOverloadedMethod(Sig, objectClass, mapWrap(.Map), noValue),
      Str::rtString, 'ListWrap(ParamVals)
    )
when
    isKResult(ParamVals)

rule [methodInvokeRuntimeOnArray]:
    methodInvokeRuntime(_, sig(MethodName:Id, Ts:Types),
        arrayRef(ArrT:RefType, L:Int, M:Int)::_,
        ParamVals:List{K}, _
    )::_
    => invokeImpl(
      lookupOverloadedMethod(sig(MethodName, Ts), objectClass, mapWrap(.Map), noValue),
      arrayRef(ArrT, L, M)::ArrT, 'ListWrap(ParamVals)
    )
when
            (Id2String(MethodName) =/=String "clone")
    andBool isKResult(ParamVals)


rule [methodInvokeRuntimeOnNull]:
    methodInvokeRuntime(_,_, null::_, ParamVals:List{K}, instanceCT)::_
    =>  'Throw('NewInstance(
          'None(.List{K}),,
          class String2Id("java.lang.NullPointerException"),,
          'ListWrap( null ),,
          'None(.List{K})
        ))
when
    isKResult(ParamVals)

rule [superMethodEval]:
    <k>
      superMethod::BaseClass:ClassType
      => objectClosure(OL, <envStack> EStack </envStack>)::BaseClass
      ...
    </k>
    <crntClass> Class:ClassType </crntClass>
    <location> OL:Int </location>
    <contextType> instanceCT </contextType>
    <envStack>... ListItem((Class, _)) EStack:List </envStack>
    <classType> Class </classType>

//Converts a list of ListItem((Class, BI) into List{K} with elements of sort ClassType
syntax K ::= "getClassList" "(" List ")"
rule (.List{K} => Class),, getClassList((ListItem((Class:ClassType, _)) => .List) _)
        [structural, anywhere]
rule getClassList(.) => .List{K}
        [structural, anywhere]

//The right signature is already found.
//Search for the right implementation is performed from the compile-time type of the target
//to more derived types, up to the object type of the target.
//This is required in order to respect the rules of inheritance in the presence of access modes.
//Evaluates into typed method closure.
syntax K ::= "lookupOverloadedMethod" "("
                              K ","       //sig(Name, SigTL) - Method signature
                              List{K} "," //Class list, elems of type ClassType,
                                          // from derived to base.
                                          // To be processed from base to derived when methods map will be exhausted.
                              K ","       //mapWrap(Map) - methods map of current LayerClass
                              TypedVal    //method closure of the most specific method found so far
                                          // or noValue if no applicable method
                                          // was found yet
                            ")"           [strict(1,3,4)]

//todo K 10341 it looks like [strict] above don't work
context lookupOverloadedMethod(HOLE,_,_,_)
context lookupOverloadedMethod(_,_,HOLE,_)
context lookupOverloadedMethod(_,_,_,HOLE)

rule [lookupMethodSigKnownFirstCandidate]:
    <k>
      lookupOverloadedMethod(
        Sig:Signature,
        _,
        mapWrap( (Sig |-> DeclClass:ClassType _:Map) => .Map ),
        noValue => NewMethTV
      )
      ...
    </k>
    <classType> DeclClass </classType>
    <methodDecs>... Sig |-> NewMethTV:TypedVal ...</methodDecs>

rule [lookupMethodSigKnownOtherCandidates]:
    <k>
      lookupOverloadedMethod(
        Sig:Signature,
        _,
        mapWrap( (Sig |-> NewDeclClass:ClassType => .) _:Map ),
        OldMethTV:TypedVal
        => 'If(
              'LazyAnd(
                (getMethodContextType(OldMethTV) ==K instanceCT)::bool,,
                isAccessibleForOverwriting(
                  getMethConsClosureClass(OldMethTV),
                  getMethodAccessMode(OldMethTV),
                  getMethConsClosureClass(NewMethTV)
                )
              )::bool,,
              NewMethTV,,
              OldMethTV
            )
      )
      ...
    </k>
    <classType> NewDeclClass </classType>
    <methodDecs>... Sig |-> NewMethTV:TypedVal ...</methodDecs>

rule [lookupMethodSigKnownEntryDiscard]:
    lookupOverloadedMethod(
      Sig:Signature,
      _,
      mapWrap( (OtherSig:Signature |-> _ => .) _:Map ),
      _
    )
when
    Sig =/=K OtherSig

rule [lookupMethodSigKnownLayerDiscard]:
    <k>
      lookupOverloadedMethod(
        _,
        (_,, (NewLayerClass:ClassType => .List{K})),
        mapWrap( .Map => NewEnv ),
        _
      )
      ...
    </k>
    <classType> NewLayerClass </classType>
    <methods> NewEnv:Map </methods>

rule [lookupMethodSigKnownEnd]:
    lookupOverloadedMethod(
      _,
      .List{K},
      mapWrap(.Map),
     MethTV:TypedVal
    ) => MethTV

//Returns the defining class of the given method TypedVal.
syntax K ::= "getMethConsClosureClass" "(" TypedVal ")"
rule getMethConsClosureClass( methodClosure(Class:ClassType, _,_,_,_,_,_) ::_ ) => Class
        [structural]

syntax K ::= "invokeImpl" "(" K   //lookupOverloadedMethod statement, evaluates to typed methodClosure
                          "," K   //OL - object location, target type for methods on non-object refs,
                                  // or noValue for static methods
                          "," K   //evaluates to 'ListWrap(ParamValues:List{KResult})
                          ")"
        [strict(1)]

rule [invokeImplInstance]:
    <k>
      invokeImpl(
        methodClosure(Class:ClassType, 'ListWrap(Params:List{K}), instanceCT, _,methodRT, noValue, Body:K)
            :: methodType(_, T:Type),
        OL:Int,
        'ListWrap(ParamValues:List{K})
      ) ~> K:K
       => bindto Params, ParamValues ~> Body ~> 'Return('None(.List{K}))
    </k>
    <control>
      <stack>
        . =>  ListItem((K, Env,
                  (
                    <crntObj> OldObj </crntObj>
                    <return> OldT </return>
                    <contextType> OldCT </contextType>
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
      <contextType> OldCT:ContextType => instanceCT </contextType>
      C:Bag
    </control>
    <env> Env:Map => . </env>
    <store>
      ...
      OL |-> objectClosure(NewOL:Int, Obj:Bag) :: _
      ...
    </store>
when getKLabel(Body) =/=KLabel 'NoMethodBody

rule [invokeImplStatic]:
    <k>
      invokeImpl(
        methodClosure(Class:ClassType, 'ListWrap(Params:List{K}), staticCT, _,methodRT, noValue, Body:K)
            :: methodType(_, T:Type),
        _,
        'ListWrap(ParamValues:List{K})
      ) ~> K:K
       => staticInit(Class) ~> bindto Params, ParamValues ~> Body ~> 'Return('None(.List{K}))
    </k>
    <control>
      <stack>
        . =>  ListItem((K, Env,
                  (
                    <crntObj> OldObj </crntObj>
                    <return> OldT </return>
                    <contextType> OldCT </contextType>
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
      <contextType> OldCT:ContextType => staticCT </contextType>
      C:Bag
    </control>
    <env> Env:Map => . </env>

rule [invokeConstructor]:
    <k>
      invokeImpl(
        methodClosure(
          Class:ClassType, _,_,_,
          constructorRT => methodRT,
          FirstLine:K => noValue,
          Body:K => FirstLine
                  ~>  #if getKLabel(FirstLine) ==KLabel 'AltConstrInv
                        #then .K
                        #else freshEnv(IInit)
                      #fi
                  ~> Body
        )::_, _,_
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

//@ \texttt{bindto} also checks the well-formedness of the method parameters

syntax K ::= "bindto" List{K}
                  "," List{K}  //List{KResult}

rule [bindto]:
    <k>
      bindto paramImpl(T:Type, X:Id),, RestP:List{K}, TV:TypedVal,, RestV:List{K}
      => 'ExprStm('Assign(localVar(X)::T,,TV:TypedVal)::T) ~> bindto RestP, RestV
      ...
    </k>
    <env> Env:Map => Env[L/X] </env>
    <store>... . => L |-> undefined :: T ...</store>
    <nextLoc> L:Int => L +Int 1 </nextLoc>

rule [bindtoEmpty]:
    <k> bindto .List{K},.List{K} => . ...</k>
        [structural]

endmodule
