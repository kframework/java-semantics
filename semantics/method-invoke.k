require "core-sorts.k"
require "elaboration-method-invoke.k"
require "classes.k"
require "statements.k"
require "static-init.k"

//@ \section{Module METHOD-INVOKE}

module METHOD-INVOKE
    imports CORE-SORTS
    imports ELABORATION-METHOD-INVOKE   // for getLookupTargetType
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

/*Evaluates the qualifier.
JLS \$15.12.4.1 - Compute Target Reference.*/
context 'Invoke('Method( 'MethodName( HOLE,, Name:Id ) ),, _)

//totest model check - expressions should be evaluated from left to right. A test for this exists, but is unable to
//expose the problem. This rule have to be made "transition" somehow.
//totest - if qualifier evaluates to null, NullPoitnerException should be thrown after the evaluation of the arguments
/* JLS \$15.12.4.2 - Evaluate Arguments. Arguments are evaluated regardless of the evaluation result of the qualifier.
*/
context 'Invoke('Method('MethodName(_:KResult,, Name:Id )),, [_,,HOLE,,_] )

rule [Invoke-Method-Instance-On-Class]:
    <k>
      'Invoke('Method('MethodName(
        objectRef(
          OId:Int, LowestClass:ClassType
        )::Class:ClassType,,
        Name:Id
        )),, [ParamVals:KList]
      )
      => invokeImpl(
        lookupOverloadedMethod(
          sig(Name, getTypes([ParamVals])), getClassesBetween([LowestClass], Class),
          mapWrap(.Map), noMethodRef
        ),
        loc(OId)::Class, [ParamVals]
      )
      ...
    </k>
    <classType> Class </classType>
    <classMetaType> classCMT </classMetaType>
when
    isKResult(ParamVals)

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

rule [Invoke-Method-Static-On-Class]:
    'Invoke('Method('MethodName(Class:ClassType,, Name:Id )),, [ParamVals:KList] )
    => invokeImpl(
      lookupOverloadedMethod(sig(Name, getTypes([ParamVals])), resultListWrap(Class), mapWrap(.Map), noMethodRef),
      noValue, [ParamVals]
    )
when
    isKResult(ParamVals)

rule [Invoke-Method-Instance-On-Interface]:
    <k>
      'Invoke('Method('MethodName(
          objectRef(
            OL:Int,
            ActualClass:ClassType
          )::Class:ClassType,,
          Name:Id
        )),,
        [ParamVals:KList]
      )
      => invokeImpl(
        lookupOverloadedMethod(sig(Name, getTypes([ParamVals])), resultListWrap(ActualClass), mapWrap(.Map),
          noMethodRef
        ),
        loc(OL)::Class, [ParamVals]
      )      ...
    </k>
    <classType> Class </classType>
    <classMetaType> interfaceCMT </classMetaType>
when
    isKResult(ParamVals)

rule [Invoke-Method-On-other]:
    'Invoke('Method('MethodName(
        QualRV:RawVal::QualT:RefType,,
        Name:Id
      )),,
      [ParamVals:KList]
    )
    => invokeImpl(
      lookupOverloadedMethod(sig(Name, getTypes([ParamVals])), resultListWrap(getLookupTargetType(QualT)),
        mapWrap(.Map), noMethodRef
      ),
      QualRV::QualT, [ParamVals]
    )
when
    getKLabel(QualRV) =/=KLabel 'objectRef andBool QualRV =/=K null andBool isKResult(ParamVals)

rule [Invoke-Method-On-Null]:
    'Invoke( 'Method('MethodName( null::_,, _:Id )),, [ParamVals:KList] )
    =>  'Throw('NewInstance(
          'None(.KList),,
          class String2Id("java.lang.NullPointerException"),,
          [ null::stringClass ],,
          'None(.KList)
        ))
when
    isKResult(ParamVals)

/*Elaboration result for super keyword in A.super.m() call.
  Have to be a typed expression.
*/
syntax K ::= superMethod ( K ) // is always equal to A.this - used to lookup the right qualifier closure.
        [strict]

rule [superMethod]:
    superMethod(
      objectRef(
        OId:Int,
        //The layers above the layer where method should be searched
        // should be discarded in order to implement syper.m() functionality.
        _
      )::BaseClass:ClassType  //due to the way term superMethod() is first constructed, this is the upper search layer
    )
    => objectRef( OId, BaseClass )::BaseClass

/*@ The right signature is already found.
Search for the right implementation is performed from the compile-time type of the target
to more derived types, up to the object type of the target.
This is required in order to respect the rules of inheritance in the presence of access modes.
Evaluates into typed method closure.*/
syntax K ::=  lookupOverloadedMethod (
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
    <k>
      lookupOverloadedMethod(
        Sig:Signature,
        _,
        mapWrap( (Sig |-> NewDecClass:ClassType => .) _:Map ),
        OldMethodRef:MethodRef
        => 'If(
              'LazyAnd(
                (eqAux(getMethodContextType(OldMethodRef), instanceCT)),,
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
      ...
    </k>

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
    MethodRef =/=K noMethodRef

//@ Retrieve the content of <methods> for the given class
syntax K ::=  getMethods ( ClassType )
rule [getMethods-ClassType]:
    <k> getMethods(Class:ClassType) => mapWrap(Methods) ...</k>
    <classType> Class </classType>
    <methods> Methods:Map </methods>

//@ Returns the defining class of the given method TypedVal.
syntax K ::= getMethConsClosureClass ( MethodRef )                 [strict]
rule [getMethConsClosureClass]:
    getMethConsClosureClass( methodRef(_, Class:ClassType) ) => Class
        [structural]

syntax K ::=  invokeImpl (
                MethodRef,  //lookupOverloadedMethod statement, evaluates to methodRef()
                K,  //KResult - method call target
                    //  loc(OL)::_ - object location, target type for methods on non-object refs,
                    //  typed string or array, or noValue for static methods
                K   //evaluates to [ParamValues:List{KResult}]
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
                <contextType> OldCT </contextType>
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
      <contextType> OldCT:ContextType => instanceCT </contextType>
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
                <contextType> OldCT </contextType>
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
      <contextType> OldCT:ContextType => staticCT </contextType>
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
