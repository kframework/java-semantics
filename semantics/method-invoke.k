require "core-sorts.k"
require "elaboration-expressions.k"
require "subtyping.k"
require "process-class-members.k"
require "classes.k"
require "statements.k"
require "static-init.k"

//@ \section{Module METHOD-INVOKE}

module METHOD-INVOKE
    imports CORE-SORTS
    imports ELABORATION-EXPRESSIONS
    imports SUBTYPING
    imports PROCESS-CLASS-MEMBERS
    imports CLASSES
    imports STATEMENTS
    imports STATIC-INIT

/*@\subsection{Method invocation}
The method lookup is the same as in untyped KOOL.
The method closure application and return are slightly different,
since we need to check that the type of the returned value is an
instance of the claimed return type of the method.  The first group of
rules below are identical to those in untyped KOOL. */

rule 'Method('MethodName(Ks:KList)) => 'MethodName(Ks)    [structural, anywhere]
rule 'Method(K:K,, _:K,, Name:Id) => 'MethodName(K,, Name)  [structural, anywhere]

rule [MethodName-Unq-InstanceCT]:
    <k>
      'MethodName(Name:Id) => 'MethodName(cast(Class, 'QThis(Class)),, Name)
      ...
    </k>
    <crntClass> Class:ClassType </crntClass>                 [structural]

rule [MethodName]:
    'MethodName(QualK:K,, Name:Id)
    => lookupMethodData(QualK, Name, notBool isTypedQThis(QualK))        [structural]

// super.X(_)
rule [SuperMethod-desugar]:
    <k>
      'SuperMethod(K:K,, Name:Id) => 'QSuperMethod(Class,, K:K,, Name:Id)
      ...
    </k>
    <crntClass> Class:ClassType </crntClass>  [structural]

rule [QSuperMethod]:
    <k>
      'QSuperMethod(Class:ClassType,, _:K,, Name:Id)
      => lookupMethodData(cast(BaseClass, superMethod(cast(BaseClass, 'QThis(Class)))), Name, false)
      ...
    </k>
    <classType> Class </classType>
    <extends> BaseClass:ClassType </extends>  [structural]

syntax KResult ::=  lookupMethodData (
                      K,    //cast(T, Exp) - typed obj closure for instance qualifier
                            //or ClassType - for class qualifier
                      Id,   //method name
                      Bool  //IsQ - isQualified
                    )

/*@ Closure application needs to also set a new return type in the
\textsf{return} cell, in order for the values returned by its body to
be checked against the return type of the method.  To do this correctly,
we also need to stack the current status of the \textsf{return} cell
and then pop it when the method returns. */

//First argument is reduced up to lookupMethodData.
context elabEnd('Invoke(HOLE,, _))

rule [elabEnd-Invoke-to-lookupMethod-qualified]:
    elabEnd('Invoke(lookupMethodData(
        Qual:K,
        MethodName:Id,
        IsQ:Bool
      ),,
      'ListWrap(ParamExps:KList))
    ) => lookupMethod(
      getLookupTargetType(typeOf(Qual)),
      MethodName,
      IsQ,
      noValue,
      false,
      Qual,
      ParamExps
    )
when notBool isTypedQThis(Qual)

rule [elabEnd-Invoke-to-lookupMethod-unqualified]:
    <k>
      elabEnd('Invoke(lookupMethodData(
          cast(Class, 'QThis(Class:ClassType)),
          MethodName:Id,
          IsQ:Bool
        ),,
        'ListWrap(ParamExps:KList))
      ) => lookupMethod(
        Class,
        MethodName,
        IsQ,
        noValue,
        false,
        cast(Class, 'QThis(Class)),
        ParamExps
      )
      ?? elabEnd('Invoke(lookupMethodData(
          cast(EnclosingClass, 'QThis(EnclosingClass)),
          MethodName,
          IsQ
        ),,
        'ListWrap(ParamExps))
      )
      ...
    </k>
    <classType> Class </classType>
    <enclosingClass> EnclosingClass:ClassType </enclosingClass>

/*@ Lookup the right methodClosure based on supplied parameters.
If the method is not found in the supplied class list, we should search for it in the
class list corresponding to the enclosing class of the caller class.
First we search for the signature - lookupSignature construct.
Afterwards we search for the right implementation in the hierarchy, once the signature is known
- lookupMethodSigKnown.*/
syntax K ::=  lookupMethod (
                ClassType,//target class, even for arrays.
                Id,       //method name
                Bool,     //IsQ - isQualified
                K,        //Evaluates to the signature to be called, or noValue if no signature was found yet
                          // Sig format: mapWrap(Sig |-> MethodTV)
                Bool,     //SigSearched: true if Sig was already searched for the current class, false otherwise.
                          // Starts with false.
                K,        //either Cast - typed qualifier expression, or Class for class qualifiers.
                KList     //ParamExps - parameter expressions of type Cast
              )
              [strict(4)]

//K bug - [strict] and KList arguments don't work together. Tested with K version of 23/02/2014.
context lookupMethod(_,_,_,HOLE,_,_,_)

syntax K ::= getLookupTargetType ( RefType )    [function]
rule getLookupTargetType(Class:ClassType) => Class
rule getLookupTargetType(arrayOf _) => arrayImplClass

syntax K ::= "arrayImplClass"                   [function]
rule arrayImplClass => class String2Id("java.lang.ArrayImpl")

//All cases
rule [lookupMethod-to-lookupSignature]:
    lookupMethod(
      QualClass:ClassType,
      MethodName:Id,
      IsQ:Bool,
      noValue => lookupSignature(MethodName, getTypes(ParamExps), getMethods(QualClass), IsQ, noValue, QualClass),
      false => true,
      _,
      ParamExps:KList
    )

/*If resolved method is static, we cannot insert in the construct the actual method body,
because this body might not be elaborated.*/
rule [lookupMethod-SigFound]:
    lookupMethod(
      QualClass:ClassType,
      _,
      _,
      methodClosure(_,_, CT:ContextType, _,_,_,_) :: methodType(sig( Name:Id, ArgTypes:Types ), RetT:Type),
      true, QualK:K, ParamExps:KList
    ) => methodProcessArguments(RetT, QualClass, QualK, Name, ArgTypes, ParamExps, .KList, CT)

rule [lookupMethod-Sig-NotFound]:
    lookupMethod(_,_,_, noValue, true, _,_) => noValue

syntax K ::=  methodProcessArguments (
                Type,       //RetT - method return type
                ClassType,  //QualClass - target class
                K,          //QualK - method qualifier
                Id,         //Name - method name
                Types,      //ArgTypes - argument types
                KList,      //ParamExps - actual parameters
                KList,      //will be used later as parameters casted to expected parameter types
                ContextType // CT - method context type, instance or static
              )

rule [methodProcessArguments-process]:
    methodProcessArguments(
      RetT:Type, QualClass:ClassType, QualK:K, Name:Id,
      types(((ArgType:Type) => .KList),, _),
      ((ParamExp:K => .KList),, _),
      (_,, (.KList => cast(ArgType, ParamExp))),
      CT:ContextType
    )

//for now just a workaround implementation
rule [methodProcessArguments-end]:
    methodProcessArguments(RetT:Type, QualClass:ClassType, QualK:K, Name:Id, types(.KList), .KList, ExpectedParamExps:KList,
        CT:ContextType)
    => elabRes(cast(RetT, methodInvokeRuntime(QualClass, Name, QualK, ExpectedParamExps, CT)))

/*Search for the correct method signature to use
when calling a given MethodName with the given argument types.
computes mapWrap(Sig -> MethodTV)*/
syntax K ::=  lookupSignature (
                Id,       // MethodName
                K,        // Computes into Types - argument types
                K,        // methods environment - mapWrap(Map[sig -> Class])
                Bool,     // IsQ - whether the original method call was qualified
                K,        // The best signature found so far, in the form methodClosure :: methodType
                          // or noValue if none found
                ClassType // QualClass - target type.
              )
              [strict(2,3,5)]

rule [lookupSignature-Main]:
    <k>
      lookupSignature(
        MethodName:Id,
        CallTs:Types,
        mapWrap((sig(MethodName, SigTs:Types) |-> DecClass:ClassType => .) _:Map),
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
              ),,
              isAccessible(
                getMethodAccessMode(NewMethTV),
                getMethodContextType(NewMethTV),
                DecClass, IsQ, QualClass
              )
            ),,
            NewMethTV,,
            OldMethodDecRecord
          ),
        QualClass:ClassType
      )
      ...
    </k>
    <classType> DecClass </classType>
    <methodDecs>... sig(MethodName, SigTs) |-> NewMethTV:TypedVal ...</methodDecs>

syntax K ::= getMethodDecArgTypes ( K )   [function]
rule getMethodDecArgTypes(_ :: methodType(sig(_, Ts:Types), _)) => Ts

rule [lookupSignature-SigDiscard]:
    lookupSignature(
      MethodName:Id,
      _,
      mapWrap((sig(Name:Id, _) |-> _ => .) _:Map),
      _,_,_
    )
when
    Name =/=K MethodName

rule [lookupSignature-End]:
    lookupSignature(_,_,mapWrap(.Map),_, SigWrap:KResult, _) => SigWrap

/*@ Tests whether a method from a given class with a given AccessMode and ContextType
may be called from the current object environment*/
syntax K ::=  isAccessible (
                AccessMode, //the method access mode
                K,          //evaluates to ContextType - staticCT or instanceCT
                ClassType,  //the method declaring class.
                Bool,       //IsQ - whether the initial method call expression was qualified
                ClassType   //QualClass - target class, used by protected mode in inner classes.
              )
              [strict(1, 2)]

rule [isAccessible-public]:
    isAccessible(public, _,_,_,_) => true

rule [isAccessible-protected]:
    <k>
      isAccessible(protected, CT:ContextType, DeclaringClass:ClassType, IsQ:Bool,
          TargetClass:ClassType
      )
      => 'LazyOr(
            'LazyAnd(
              'LazyOr((CT ==K staticCT),, 'Not(IsQ)),,
              subtype(
                'If(IsQ,, CurrentClass,, TargetClass),
                DeclaringClass
              )
            ),,
            isAccessible(package, CT, DeclaringClass, IsQ, TargetClass)
      )
      ...
    </k>
    <crntClass> CurrentClass:ClassType </crntClass>

rule [isAccessible-package]:
    <k>
      isAccessible(package, _, DeclaringClass:ClassType, _,_)
      => eqAux(getPackage(getTopLevel(DeclaringClass)), getPackage(getTopLevel(CurrentClass)))
      ...
    </k>
    <crntClass> CurrentClass:ClassType </crntClass>

/*A private method is accessible if the class where it is declared lies
in the same top-level class as the class that accesses the method*/
rule [isAccessible-private]:
    <k>
      isAccessible(private, _, DeclaringClass:ClassType, _,_)
      => eqAux(getTopLevel(DeclaringClass), getTopLevel(CurrentClass))
      ...
    </k>
    <crntClass> CurrentClass:ClassType </crntClass>

//@ The elaboration result of a method invocation.
syntax K ::=  methodInvokeRuntime (
                ClassType,  //Compile-time target class, always class even for arrays
                Id,         //Method name
                K,          //Qualifier expression, if any, or noValue if it is static invocation
                KList,      //ExpectedParamExps, arguments casted to the type expected by the actual signature
                ContextType //instanceCT or staticCT
              )

/*Evaluates the qualifier.
JLS \$15.12.4.1 - Compute Target Reference.*/
context methodInvokeRuntime(_,_, HOLE, _,_)

//totest model check - expressions should be evaluated from left to right. A test for this exists, but is unable to
//expose the problem. This rule have to be made "transition" somehow.
//totest - if qualifier evaluates to null, NullPoitnerException should be thrown after the evaluation of the arguments
/* JLS \$15.12.4.2 - Evaluate Arguments. Arguments are evaluated regardless of the evaluation result of the qualifier.
*/
context methodInvokeRuntime(_,_,_:KResult, (_,,HOLE,,_), _)

rule [methodInvokeRuntime-Instance-On-Class]:
    <k>
      methodInvokeRuntime(Class:ClassType, Name:Id,
        objectClosure(OL:Int,
          Rest:List
          ListItem(el(Class:ClassType, BI:BagItem, EnclosingObj:KResult, LocalEnv:Map)) _,
        _)::Class,
        ParamVals:KList, instanceCT
      )
      => invokeImpl(
        lookupOverloadedMethod(
          sig(Name, getTypes(ParamVals)), getClassList(Rest ListItem(el(Class, BI, EnclosingObj, LocalEnv))),
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

rule [methodInvokeRuntime-Static-On-Class]:
    methodInvokeRuntime(Class:ClassType, Name:Id, _:KResult, ParamVals:KList, staticCT)
    => invokeImpl(
      lookupOverloadedMethod(sig(Name, getTypes(ParamVals)), Class, mapWrap(.Map), noValue),
      noValue, 'ListWrap(ParamVals)
    )
when
    isKResult(ParamVals)

rule [methodInvokeRuntime-Instance-On-Interface]:
    <k>
      methodInvokeRuntime(Class:ClassType, Name:Id,
        objectClosure(OL:Int,
          ListItem(el(ActualClass:ClassType, _,_,_)) _,
        _)::Class,
        ParamVals:KList, instanceCT
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

rule [methodInvokeRuntime-On-other]:
    methodInvokeRuntime(Class:ClassType, Name:Id,
        QualRV:RawVal::QualT:RefType,
        ParamVals:KList, instanceCT
    )
    => invokeImpl(
      lookupOverloadedMethod(sig(Name, getTypes(ParamVals)), Class, mapWrap(.Map), noValue),
      QualRV::QualT, 'ListWrap(ParamVals)
    )
when
    getKLabel(QualRV) =/=KLabel 'objectClosure andBool QualRV =/=K null andBool isKResult(ParamVals)

rule [methodInvokeRuntime-On-Null]:
    methodInvokeRuntime(_,_, null::_, ParamVals:KList, instanceCT)
    =>  'Throw('NewInstance(
          'None(.KList),,
          class String2Id("java.lang.NullPointerException"),,
          'ListWrap( null ),,
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
        _:List //The layers above the layer where method should be searched.
               //Should be discarded in order to implement syper.m() functionality.
        ListItem(el(BaseClass, BI:BagItem, EnclosingObj:KResult, LocalEnv:Map)) Rest:List,
        ObjLocalClassesEnv:Map
      )::BaseClass:ClassType  //due to the way term superMethod() is first constructed, this is the upper search layer
    )
    => objectClosure(
      OL,
      ListItem(el(BaseClass, BI, EnclosingObj, LocalEnv)) Rest,
      ObjLocalClassesEnv
    )::BaseClass

//@ Converts a list of ListItem(el(Class, BI, EnclosingObj, _)) into KList with elements of sort ClassType
syntax K ::= getClassList ( List )
rule (.KList => Class),, getClassList((ListItem(el(Class:ClassType, _,_,_)) => .List) _)
        [structural, anywhere]
rule getClassList(.) => .KList
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
      OL |-> objectClosure(NewOL:Int, Obj:List, ObjLocalClassesEnv:Map) :: _
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
      OL |-> objectClosure(_, _:List ListItem(el(Class,_,_,OuterLocalEnv:Map)) _:List, _) :: _
      ...
     </store>

/*@ Binds a list of formal parameters to their values. Used by method calls and try-catch.
*/
syntax K ::= bindTo ( KList, // List{'Param(...)} - parameter declarations
                      KList  // List{KResult} - values
                    )

rule [bindTo]:
    bindTo('Param(_:K,, T:Type,, X:Id),, RestP:KList, TV:TypedVal,, RestV:KList)
    => 'LocalVarDec(.K,, T:Type,,'ListWrap('VarDec(X)))
      ~> 'ExprStm('Assign(localVar(X),, cast(T, TV:TypedVal)))
      ~> bindTo(RestP, RestV)

rule [bindTo-empty]:
    bindTo(.KList,.KList) => .K
        [structural]

endmodule
