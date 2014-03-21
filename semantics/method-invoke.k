require "core-sorts.k"
require "elaboration-expressions.k"
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
  'ListWrap('Param(),, ...) - arguments
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
context 'Invoke('Method('MethodName(_:KResult,, Name:Id )),, 'ListWrap(_,,HOLE,,_) )

rule [Invoke-Method-Instance-On-Class]:
    <k>
      'Invoke('Method('MethodName(
        objectClosure(
          OL:Int,
          (Rest:KList/*ObjLayers*/,, layer(Class:ClassType, BI:BagItem, EnclosingObj:KResult, LocalEnv:Map),, _),
          _
        )::Class:ClassType,,
        Name:Id
        )),, 'ListWrap(ParamVals:KList)
      )
      => invokeImpl(
        lookupOverloadedMethod(
          sig(Name, getTypes(ParamVals)), getClassList(Rest,, layer(Class, BI, EnclosingObj, LocalEnv)),
          mapWrap(.Map), noValue
        ),
        loc(OL)::Class, 'ListWrap(ParamVals)
      )
      ...
    </k>
    <classType> Class </classType>
    <metaType> classMetaT </metaType>
when
    isKResult(ParamVals)

rule [Invoke-Method-Static-On-Class]:
    'Invoke('Method('MethodName(Class:ClassType,, Name:Id )),, 'ListWrap(ParamVals:KList) )
    => invokeImpl(
      lookupOverloadedMethod(sig(Name, getTypes(ParamVals)), Class, mapWrap(.Map), noValue),
      noValue, 'ListWrap(ParamVals)
    )
when
    isKResult(ParamVals)

rule [Invoke-Method-Instance-On-Interface]:
    <k>
      'Invoke('Method('MethodName(
          objectClosure(
            OL:Int,
            (layer(ActualClass:ClassType, _,_,_),, _),
            _
          )::Class:ClassType,,
          Name:Id
        )),,
        'ListWrap(ParamVals:KList)
      )
      => invokeImpl(
        lookupOverloadedMethod(sig(Name, getTypes(ParamVals)), ActualClass, mapWrap(.Map), noValue),
        loc(OL)::Class, 'ListWrap(ParamVals)
      )      ...
    </k>
    <classType> Class </classType>
    <metaType> interfaceMetaT </metaType>
when
    isKResult(ParamVals)

rule [Invoke-Method-On-other]:
    'Invoke('Method('MethodName(
        QualRV:RawVal::QualT:RefType,,
        Name:Id
      )),,
      'ListWrap(ParamVals:KList)
    )
    => invokeImpl(
      lookupOverloadedMethod(sig(Name, getTypes(ParamVals)), getLookupTargetType(QualT), mapWrap(.Map), noValue),
      QualRV::QualT, 'ListWrap(ParamVals)
    )
when
    getKLabel(QualRV) =/=KLabel 'objectClosure andBool QualRV =/=K null andBool isKResult(ParamVals)

rule [Invoke-Method-On-Null]:
    'Invoke( 'Method('MethodName( null::_,, _:Id )),, 'ListWrap(ParamVals:KList) )
    =>  'Throw('NewInstance(
          'None(.KList),,
          class String2Id("java.lang.NullPointerException"),,
          'ListWrap( null::stringClass ),,
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
      objectClosure(
        OL:Int,
        //The layers above the layer where method should be searched
        // should be discarded in order to implement syper.m() functionality.
        (_:KList/*ObjLayers*/,, layer(BaseClass, BI:BagItem, EnclosingObj:KResult, LocalEnv:Map),, Rest:KList/*ObjLayers*/),
        ObjLocalClassesEnv:Map
      )::BaseClass:ClassType  //due to the way term superMethod() is first constructed, this is the upper search layer
    )
    => objectClosure(
      OL,
      (layer(BaseClass, BI, EnclosingObj, LocalEnv),, Rest),
      ObjLocalClassesEnv
    )::BaseClass

//@ Converts a list of ListItem(layer(Class, BI, EnclosingObj, _)) into KList with elements of sort ClassType
syntax K ::= getClassList ( KList )
rule (.KList => Class),, getClassList((layer(Class:ClassType, _,_,_) => .KList),, _)
        [structural, anywhere]
rule getClassList(.KList) => .KList
        [structural, anywhere]

/*@ The right signature is already found.
Search for the right implementation is performed from the compile-time type of the target
to more derived types, up to the object type of the target.
This is required in order to respect the rules of inheritance in the presence of access modes.
Evaluates into typed method closure.*/
syntax K ::=  lookupOverloadedMethod (
                Signature,  //sig(Name, SigTL) - Method signature
                KList,   //Class list, elements of type ClassType,
                         // from derived to base.
                         // To be processed from base to derived when methods map will be exhausted.
                K,       //mapWrap(Map) - methods map of current LayerClass
                TypedVal //method closure of the most specific method found so far
                         // or noValue if no applicable method was found yet
              )
              [strict(1,3,4)]

//K bug - [strict] and KList arguments don't work together. Tested with K version of 23/02/2014.
context lookupOverloadedMethod(HOLE,_,_,_)
context lookupOverloadedMethod(_,_,HOLE,_)
context lookupOverloadedMethod(_,_,_,HOLE)

rule [lookupOverloadedMethod-SigKnownFirstCandidate]:
    lookupOverloadedMethod(
      Sig:Signature,
      _,
      mapWrap( (Sig |-> DecClass:ClassType _:Map) => .Map ),
      noValue => getMethodDec(Sig, DecClass)
    )

rule [lookupOverloadedMethod-SigKnownOtherCandidates]:
    <k>
      lookupOverloadedMethod(
        Sig:Signature,
        _,
        mapWrap( (Sig |-> NewDecClass:ClassType => .) _:Map ),
        OldMethTV:TypedVal
        => 'If(
              'LazyAnd(
                (eqAux(getMethodContextType(OldMethTV), instanceCT)),,
                isAccessibleForOverwriting(
                  getMethConsClosureClass(OldMethTV),
                  getMethodAccessMode(OldMethTV),
                  getMethConsClosureClass(NewMethTV)
                )
              ),,
              NewMethTV,,
              OldMethTV
            )
      )
      ...
    </k>
    <classType> NewDecClass </classType>
    <methodDecs>...Sig |-> NewMethTV:TypedVal ...</methodDecs>

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
      (_,, (NewLayerType:ClassType => .KList)),
      mapWrap(.Map) => getMethods(NewLayerType),
      _
    )

rule [lookupOverloadedMethod-SigKnownEnd]:
    lookupOverloadedMethod(
      _,
      .KList,
      mapWrap(.Map),
     MethTV:TypedVal
    ) => MethTV

//@ Retrieve the content of <methods> for the given class
syntax K ::=  getMethods ( ClassType )
rule [getMethods-ClassType]:
    <k> getMethods(Class:ClassType) => mapWrap(Methods) ...</k>
    <classType> Class </classType>
    <methods> Methods:Map </methods>

/*@ Returns the method declaration (stored in <methodDecs>) based on provided signature and declaring type*/
syntax K ::=  getMethodDec (
                Signature,  // The signature of the method
                ClassType   // The declaring class.
              )

rule [getMethodDec-ClassType]:
    <k> getMethodDec(Sig:Signature, DeclClass:ClassType) => NewMethTV ...</k>
    <classType> DeclClass </classType>
    <methodDecs>... Sig |-> NewMethTV:TypedVal ...</methodDecs>

//@ Returns the defining class of the given method TypedVal.
syntax K ::= getMethConsClosureClass ( TypedVal )                 [strict]
rule getMethConsClosureClass( methodClosure(Class:ClassType, _,_,_,_,_,_) ::_ ) => Class
        [structural]

syntax K ::=  invokeImpl (
                K,  //lookupOverloadedMethod statement, evaluates to typed methodClosure
                K,  //KResult - method call target
                    //  loc(OL)::_ - object location, target type for methods on non-object refs,
                    //  typed string or array, or noValue for static methods
                K   //evaluates to 'ListWrap(ParamValues:List{KResult})
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
        methodClosure(Class:ClassType, 'ListWrap(Params:KList), instanceCT, _,methodRT, noValue, Body:K)
            :: methodType(_, T:Type),
        loc(OL:Int)::_,
        'ListWrap(ParamValues:KList)
      ) ~> K:K
       => setRuntimeEnclosingLocalEnv(OL) ~> bindTo(Params, ParamValues) ~> Body ~> 'Return('None(.KList))
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
        => <env> .Map </env> //will be populated later by setRuntimeEnclosingLocalEnv()
           <localClassesEnv> ObjLocalClassesEnv </localClassesEnv>
      </envGroup>
      <return> OldT:Type => T </return>
      <contextType> OldCT:ContextType => instanceCT </contextType>
      <crntObj>
        OldObj:Bag
        => <crntClass> Class </crntClass>
           <location> NewOL </location>
      </crntObj>
      RestMethContext:Bag
    </methodContext>
    <store>
      ...
      OL |-> objectClosure(NewOL:Int, Obj:KList/*ObjLayers*/, ObjLocalClassesEnv:Map) :: _
      ...
    </store>
when getKLabel(Body) =/=KLabel 'NoMethodBody

rule [invokeImpl-Static]:
    <k>
      invokeImpl(
        methodClosure(Class:ClassType, 'ListWrap(Params:KList), staticCT, _,methodRT, _, Body:K)
            :: methodType(_, T:Type),
        noValue,
        'ListWrap(ParamValues:KList)
      ) ~> K:K
       => staticInit(Class) ~> bindTo(Params, ParamValues) ~> Body ~> 'Return('None(.KList))
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
        => <env> .Map </env> <localClassesEnv> .Map </localClassesEnv>
      </envGroup>
      <return> OldT:Type => T </return>
      <contextType> OldCT:ContextType => staticCT </contextType>
      <crntObj>
        OldObj:Bag
        => <crntClass> Class </crntClass>
           <location> noValue </location>
      </crntObj>
      RestMethContext:Bag
    </methodContext>

syntax K ::= setRuntimeEnclosingLocalEnv ( Int )
rule <k> setRuntimeEnclosingLocalEnv(OL:Int) => . ...</k>
     <crntClass> Class:ClassType </crntClass>
     <env> _ => OuterLocalEnv </env>
     <store>
      ...
      OL |-> objectClosure(_, (_:KList/*ObjLayers*/,, layer(Class,_,_,OuterLocalEnv:Map),, _:KList/*ObjLayers*/), _) :: _
      ...
     </store>

//@ 'Param(_:K,, T:Type,, X:Id)
syntax KLabel ::= "'Param"

/*@ Binds a list of formal parameters to their values. Used by method calls and try-catch.
*/
syntax K ::= bindTo ( KList, // List{'Param(...)} - parameter declarations
                      KList  // List{KResult} - values
                    )

rule [bindTo]:
    bindTo('Param(_:K,, T:Type,, X:Id),, RestP:KList, TV:TypedVal,, RestV:KList)
    => 'LocalVarDec(.K,, T:Type,,'ListWrap('VarDec(X)))
      ~> 'ExprStm('Assign('ExprName(X),, cast(T, TV:TypedVal)))
      ~> bindTo(RestP, RestV)

rule [bindTo-empty]:
    bindTo(.KList,.KList) => .K
        [structural]

endmodule
