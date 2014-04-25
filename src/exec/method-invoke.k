require "../common/core-sorts.k"
require "classes.k"
require "statements.k"
require "static-init.k"

//@ \section{Module METHOD-INVOKE}

module METHOD-INVOKE
    imports CORE-SORTS
    imports CLASSES
    imports STATEMENTS
    imports STATIC-INIT

/*
General structure:

'Invoke(
  'Method(
    'MethodName(
      QualifierExp:Expression,,
      Name:Id
    )
  ),,
  ['Param(),, ...] - arguments
)
*/
syntax KLabel ::= "'Invoke"

/*@ 'Method(Qual:K,, _:K,, Name:Id)
    'Method('MethodName(Qual:K,, Name:Id))
*/
syntax KLabel ::= "'Method"
                | "'MethodName"

/*Evaluates the qualifier.
JLS \$15.12.4.1 - Compute Target Reference.*/
context 'Invoke('Method( 'MethodName( HOLE,, Name:Id ) ),, _)

//totest model check - expressions should be evaluated from left to right. A test for this exists, but is unable to
//expose the problem. This rule have to be made "transition" somehow.
//totest - if qualifier evaluates to null, NullPoitnerException should be thrown after the evaluation of the arguments
/* JLS \$15.12.4.2 - Evaluate Arguments. Arguments are evaluated regardless of the evaluation result of the qualifier.
*/
context 'Invoke('Method('MethodName(_:KResult,, Name:Id )),, [_,,HOLE,,_] )

/*@ Information required to decide which method call algorithm to use
    This intermediate construct is required because we cannot refer directly to the method signature from
    rules that initiate method implementation search. This is because method defining clas could be
    both target class or a different class. The two cases cannot be covered by one rule.
*/
syntax K ::=  methodInfo(
                Signature,  //method signature
                RefType,    //qualifier type, not necessarily class
                RefType,    //method definition class type - the class referred by the signature in <methods>
                              // for arrays - it remains noClass
                              // this argument is only used to compute the context type
                ContextType //method context type - instance or static
                              // for arrays - instanceCT
              )

//@ The check that ParamVals are KResult here makes possible to eliminate this check in further rules
rule [Invoke-Method-compute-Signature]:
    'Invoke('Method('MethodName(
      Qual:KResult,,
      (Name:Id => methodInfo(sig(Name, getTypes([ParamVals])), typeOf(Qual), noClass, noValue))
      )),, [ParamVals:KList]
    )
when
    isKResult(ParamVals)

rule [Invoke-Method-load-MethodDefClass]:
    <k>
      'Invoke('Method('MethodName(
        Qual:KResult,,
        methodInfo(Sig:Signature, QualClass:ClassType, noClass => MethodDefClass, noValue)
        )),, _)
      ...
    </k>
    <classType> QualClass </classType>
    <methods>... Sig |-> MethodDefClass:ClassType ...</methods>

/*@ If the called method was not found in <methods> of the target type,
    then it is an interface method, and it is always instanceCT.
    Recall that we do not put into <methods> methods inherited from base interfaces.
*/
rule [Invoke-Method-load-unmapped-method-ContextType]:
    <k>
      'Invoke('Method('MethodName(
        Qual:KResult,,
        methodInfo(Sig:Signature, QualClass:ClassType, noClass, noValue => instanceCT)
        )),, _)
      ...
    </k>
    <classType> QualClass </classType>
    <methods> Methods:Map </methods>
when
    notBool Sig in keys(Methods)

/*@ We cannot combine this rule with [Invoke-Method-On-array]
  because after this rule one of the following might be matched:
    - [Invoke-Method-On-array]
    - [Invoke-Method-instance-On-Null]
*/
rule [Invoke-Method-load-MethodDefClass-arrays]:
    'Invoke('Method('MethodName(
      Qual:KResult,,
      methodInfo(Sig:Signature, arrayOf T:Type, noClass, noValue => instanceCT)
    )),, _)

rule [Invoke-Method-load-ContextType]:
    <k>
      'Invoke('Method('MethodName(
        Qual:KResult,,
        methodInfo(Sig:Signature, QualClass:ClassType, MethodDefClass:ClassType, noValue => CT)
        )),, _)
      ...
    </k>
    <classType> MethodDefClass </classType>
    <methodSignature> Sig </methodSignature>
    <methodContextType> CT:ContextType </methodContextType>

rule [Invoke-Method-Instance-On-Class]:
    <k>
      'Invoke('Method('MethodName(
        objectRef(
          OId:Int, MostDerivedClass:ClassType
        )::QualClass:ClassType,,
        methodInfo(Sig:Signature, QualClass:ClassType, _, instanceCT)
        )),, [ParamVals:KList]
      )
      => invokeImpl(
        lookupOverloadedMethod(
          Sig, getClassesBetween([MostDerivedClass], QualClass),
          mapWrap(.Map), noMethodRef
        ),
        loc(OId)::QualClass, [ParamVals]
      )
      ...
    </k>
    <classType> QualClass </classType>
    <classMetaType> classCMT </classMetaType>

/*Returns the list of classes representing the layer of the given object (by OId),
    located between LowestClass and UpperClass.
*/
syntax K ::=  getClassesBetween(  KListWrap,  //[LowestClass] at beginning, gradually accumulates the list of classes
                                  ClassType   //UpperClass
              )

rule [getClassesBetween-process]:
    <k>
      getClassesBetween([_,, LowestClass:ClassType,, (.KList => BaseClass)], UpperClass:ClassType)
      ...
    </k>
    <classType> LowestClass </classType>
    <extends> BaseClass:ClassType </extends>
when
    LowestClass =/=K UpperClass

rule [getClassesBetween-end]:
    getClassesBetween([LowerClasses:KList,, Class:ClassType], Class) => resultListWrap(LowerClasses,, Class)

rule [Invoke-Method-Instance-On-interface]:
    <k>
      'Invoke('Method('MethodName(
          objectRef(
            OL:Int,
            ActualClass:ClassType
          )::QualClass:ClassType,,
          methodInfo(Sig:Signature, QualClass:ClassType, _, instanceCT)
        )),,
        [ParamVals:KList]
      )
      => invokeImpl(
        lookupOverloadedMethod(Sig, resultListWrap(ActualClass), mapWrap(.Map),
          noMethodRef
        ),
        loc(OL)::QualClass, [ParamVals]
      )
      ...
    </k>
    <classType> QualClass </classType>
    <classMetaType> interfaceCMT </classMetaType>

rule [Invoke-Method-On-array]:
    'Invoke('Method('MethodName(
        QualRV:RawVal::QualT:RefType,,
        methodInfo(Sig:Signature, QualT, _,_)
      )),,
      [ParamVals:KList]
    )
    => invokeImpl(
      lookupOverloadedMethod(Sig, resultListWrap(getLookupTargetType(QualT)),
        mapWrap(.Map), noMethodRef
      ),
      QualRV::QualT, [ParamVals]
    )
when
    getKLabel(QualRV) =/=KLabel 'objectRef andBool QualRV =/=K null

//@ Qualifier type could be either object or array
rule [Invoke-Method-instance-On-Null]:
    'Invoke( 'Method('MethodName( null::_,, methodInfo(_,_,_, instanceCT) )),, [_] )
    =>  'Throw('NewInstance(
          'None(.KList),,
          class String2Id("java.lang.NullPointerException"),,
          [ null::stringClass ],,
          'None(.KList)
        ))

rule [Invoke-Method-Static-On-Class]:
    'Invoke('Method('MethodName(_,, methodInfo(Sig:Signature, QualClass:ClassType, _, staticCT) )),, [ParamVals:KList] )
    => invokeImpl(
      lookupOverloadedMethod(Sig, resultListWrap(QualClass), mapWrap(.Map), noMethodRef),
      noValue, [ParamVals]
    )

//@ 'QSuperMethod(Class:ClassType,, _:K,, Name:Id)
syntax KLabel ::= "'QSuperMethod"

rule [Invoke-QSuperMethod]:
    'Invoke(
      ('QSuperMethod(Class:ClassType,, _:K,, Name:Id)
       => 'Method('MethodName(superMethodImpl('QThis(Class)),, Name))
      ),, _
    )

/*Elaboration result for super keyword in A.super.m() call.
  Have to be a typed expression.
*/
syntax K ::= superMethodImpl ( K ) // is always equal to A.this - used to lookup the right qualifier closure.
        [strict]

rule [superMethodImpl]:
    <k>
      superMethodImpl(
        objectRef(
          OId:Int,
          //The layers above the layer where method should be searched
          // should be discarded in order to implement syper.m() functionality.
          _
        )::Class:ClassType  //due to the way term superMethod() is first constructed, this is the upper search layer
      )
      => objectRef( OId, BaseClass )::BaseClass
      ...
    </k>
    <classType> Class </classType>
    <extends> BaseClass:ClassType </extends>

/*@ The right signature is already found.
Search for the right implementation is performed from the compile-time type of the target
to more derived types, up to the object type of the target.
This is required in order to respect the rules of inheritance in the presence of access modes.
Evaluates into typed method closure.*/
syntax K ::=  lookupOverloadedMethod ( //todo maybe we can simplify this logic, too much overlapping with elaboration
                Signature,  //sig(Name, SigTL) - Method signature
                K,          //computes into resultListWrap(Class list), elements of type ClassType,
                              // from derived to base.
                              // To be processed from base to derived when methods map will be exhausted.
                K,          //mapWrap(Map) - methods map of current LayerClass
                MethodRef   //method closure of the most specific method found so far
                              // or noValue if no applicable method was found yet
              )
              [strict]

rule [lookupOverloadedMethod-SigKnownFirstCandidate]:
    lookupOverloadedMethod(
      Sig:Signature,
      _,
      mapWrap( (Sig |-> DecClass:ClassType _:Map) => .Map ),
      noMethodRef => methodRef(Sig, DecClass)
    )

rule [lookupOverloadedMethod-SigKnownOtherCandidates]:
    lookupOverloadedMethod(
      Sig:Signature,
      _,
      mapWrap( (Sig |-> NewDecClass:ClassType => .) _:Map ),
      OldMethodRef:MethodRef
      => 'If(
            andAux(
              //todo here we make sure that instance methods are never overwritten. Correct, but could be simplified
              (eqAux(getMethodContextType(OldMethodRef), instanceCT)),
              isAccessibleForOverwriting(
                getMethConsClosureClass(OldMethodRef),
                getMethodAccessMode(OldMethodRef),
                NewDecClass
              )
            ),,
            methodRef(Sig, NewDecClass),,
            OldMethodRef
          )
    )

rule [lookupOverloadedMethod-SigKnownEntryDiscard]:
    lookupOverloadedMethod(
      Sig:Signature,
      _,
      mapWrap( (OtherSig:Signature |-> _ => .) _:Map ),
      _
    )
when
    Sig =/=K OtherSig

rule [lookupOverloadedMethod-SigKnownLayerDiscard]:
    lookupOverloadedMethod(
      _,
      resultListWrap(_,, (NewLayerType:ClassType => .KList)),
      mapWrap(.Map) => getMethods(NewLayerType),
      _
    )

rule [lookupOverloadedMethod-SigKnownEnd]:
    lookupOverloadedMethod(_, resultListWrap(.KList), mapWrap(.Map), MethodRef:MethodRef ) => MethodRef
when
    MethodRef =/=K noMethodRef  //for debug purposes only

//@ Returns the defining class of the given method TypedVal.
syntax K ::= getMethConsClosureClass ( MethodRef )                 [strict]
rule [getMethConsClosureClass]:
    getMethConsClosureClass( methodRef(_, Class:ClassType) ) => Class
        [structural]

syntax K ::=  invokeImpl (
                MethodRef,  //lookupOverloadedMethod statement, evaluates to methodRef()
                K,          //KResult - method call target
                              //loc(OL)::_ - object location, target type for methods on non-object refs,
                              //typed string or array, or noValue for static methods
                KListWrap   //[ParamValues:List{KResult}]
              )
              [strict(1)]

/*@ Closure application needs to also set a new return type in the
\textsf{return} cell, in order for the values returned by its body to
be checked against the return type of the method.  To do this correctly,
we also need to stack the current status of the \textsf{return} cell
and then pop it when the method returns. */
rule [invokeImpl-Instance]:
    <k>
      invokeImpl(
        methodRef(Sig:Signature, Class:ClassType),
        loc(OL:Int)::_,
        [ParamValues:KList]
      ) ~> K:K
       => bindTo([Params], [ParamValues]) ~> Body ~> 'Return('None(.KList))
    </k>
    <stack>
      . =>  ListItem(sl(K,
              (
                <envGroup> OldEnvGroup </envGroup>
                <return> OldT </return>
                <crntObj> OldObj </crntObj>
                RestMethContext
              )
            ))
      ...
    </stack>
    <methodContext>
      <envGroup>
        OldEnvGroup:Bag
        => <env> .Map </env>
      </envGroup>
      <return> OldT:Type => ReturnT </return>
      <crntObj>
        OldObj:Bag
        => <crntClass> Class </crntClass>
           <location> OId </location>
      </crntObj>
      RestMethContext:Bag
    </methodContext>
    <store>... OL |-> objectRef(OId:Int, _)::_ ...</store>

    <classType> Class </classType>
    <methodSignature> Sig </methodSignature>
    <methodReturnType> ReturnT:Type </methodReturnType>
    <methodParams> [Params:KList] </methodParams>
    <methodBody> Body:K </methodBody>
    <methodContextType> instanceCT </methodContextType>
when getKLabel(Body) =/=KLabel 'NoMethodBody

rule [invokeImpl-Static]:
    <k>
      invokeImpl(
        methodRef(Sig:Signature, Class:ClassType),
        noValue,
        [ParamValues:KList]
      ) ~> K:K
       => staticInit(Class) ~> bindTo([Params], [ParamValues]) ~> Body ~> 'Return('None(.KList))
    </k>
    <stack>
      . =>  ListItem(sl(K,
              (
                <envGroup> OldEnvGroup </envGroup>
                <return> OldT </return>
                <crntObj> OldObj </crntObj>
                RestMethContext
              )
            ))
      ...
    </stack>
    <methodContext>
      <envGroup>
        OldEnvGroup:Bag
        => <env> .Map </env>
      </envGroup>
      <return> OldT:Type => ReturnT </return>
      <crntObj>
        OldObj:Bag
        => <crntClass> Class </crntClass>
           <location> noValue </location>
      </crntObj>
      RestMethContext:Bag
    </methodContext>

    <classType> Class </classType>
    <methodSignature> Sig </methodSignature>
    <methodReturnType> ReturnT:Type </methodReturnType>
    <methodParams> [Params:KList] </methodParams>
    <methodBody> Body:K </methodBody>
    <methodContextType> staticCT </methodContextType>

//@ 'Param(_:K,, T:Type,, X:Id)
syntax KLabel ::= "'Param"

/*@ Binds a list of formal parameters to their values. Used by method calls and try-catch.
*/
syntax K ::= bindTo ( KListWrap, // [...,, 'Param(...),, ...] - parameter declarations
                      KListWrap  // [...,, KResult,, ...] - values
                    )

rule [bindTo]:
    bindTo(['Param(_:K,, T:Type,, X:Id),, RestP:KList], [TV:TypedVal,, RestV:KList])
    => 'LocalVarDec(.K,, T:Type,,['VarDec(X)])
      ~> 'ExprStm('Assign('ExprName(X),, cast(T, TV:TypedVal)))
      ~> bindTo([RestP], [RestV])

rule [bindTo-empty]:
    bindTo([.KList], [.KList]) => .K
        [structural]

endmodule
