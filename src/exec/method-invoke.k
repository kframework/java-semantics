require "../common/core-sorts.k"
require "classes.k"
require "statements.k"
require "static-init.k"

/*@ \section{Module METHOD-INVOKE}
An elaborated method invocation expresion may have one of the following forms:
  - An invocation of a static method qualified by its class: Class.f(args)
  - An invocation of a static method qialified by an expression producing an object: o.f(args). Even if the method is
    static we cannot simply replace the qualifier with its compile-time type at elaboration phase, because the qualifier
    expression still have to be evaluated and might produce side effects.
  - An invocation of an instance method qualified by a class reference: o.f(args)
  - An invocation of an instance method qualified by an interface reference: i.f(args)
  - The qualifier of an instance method may also be a string or an array expression,
    and those cases require special rules in the semantics.

The evaluation of the method invocation expression consists from 5 steps outlined below. Those steps,
unless otherwise specified, are common to all the method invocation forms enumerated above.
  - Evaluation of the qualifier expression
  - Evaluation of method arguments
  - Computation of static method information
  - Locating the actual method declaration to be invoked
  - Once we have produced the qualifier, the arguments and the actual method declaration,
    the method execution itself is performed.

In JLS runtime semantics of method invocation is described in $15.2.4. Althouhg there is some correspondence
  between the steps in our semantics and the steps in JLS, it is generally not one-to-one. JLS description of method
  invocation consists of the following 5 steps. For each step we give the relevant chapter of the JLS and the step in
  our semantics.
  - Compute the target reference ($15.12.4.1), semantics step 1
  - Evaluate arguments ($15.12.4.2), semantics step 2
  - Check the accessibility of the method to be invoked ($15.12.4.3), no semantics
  - Locate the actual method code to invoke ($15.12.4.4), semantics step 4
  - Actual method invocation, semantics step 5.

  There are at least the following reasons why there is no close correspondence between JLS and K-Java:
  - JLS semantics describes not only the execution of correct java programs, but also runtime checks that have to be
    performed to ensure the consistency of the bytecode, and errors that have to be thrown once this consistency is
    violated. This is the case for JLS $15.12.4.3, that don't need a correspondent in K-Java.
  - Because K-Java operates directly over the source code of Java with no other preprocessing than the unfolding
    phase, it carries less static information than the bytecode. For this reason some static information needs to be
    computed in K-Java each time a method is invoked. This is why semantics step 3 is needed. As we will see below,
    rules for this step are straghtforward and consist of loading the right data from the right cells int an
    auxiliary data structure.
  - Although JLS avoids references to bytecode as much as possible, sometimes it contains references to features
    specific to bytecode. For a method call in JLS have an invocation mode, that might be static, nonvirtual,
    virtual, interface or others. Since this invocation mode is computed at compile-time, JLS runtime semantics is
    described separately for each invocation mode. In K, since we don't have such a classification by invocation modes,
    we often have less cases.
  - Lastly, K abstractions allow us to have much less particular cases in Java than in JLS. A comparison between the
    number of particular cases for K-Java method invocation and JLS will be given at the end of this section. We will
    also highlight the particular K abstractions that made possible the reduction of the number of cases.

  The details related to each step of are described in the semantics below, above each rule and auxiliary construct.
    For each rule we will also refer to the respective JLS page, if there is a correspondence.
*/
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

The whole semantics for runtime evaluation of a method invocation have ~ 20 rules, including contexts.
  That is a little bit too much.
*/
syntax KLabel ::= "'Invoke"

/*@ 'Method(Qual:K,, _:K,, Name:Id)
    'Method('MethodName(Qual:K,, Name:Id))
*/
syntax KLabel ::= "'Method"
                | "'MethodName"

/*@
Evaluation of the method invocation qualifier (JLS \$15.12.4.1) requires just one context rule. The qualifier is
  the first argument of the method invocation production. It just needs to be heated,
  and after evaluation the actual value will be cooled back in the
  same place. If the qualifier is a class instead of an expression, then this rule will have no effect. A type in
  K-Java is subsorted to KResult, consequently it doesn't need to be heated.
*/
context 'Invoke('Method( 'MethodName( HOLE,, Name:Id ) ),, _)

//totest model check - expressions should be evaluated from left to right. A test for this exists, but is unable to
//expose the problem. This rule have to be made "transition" somehow.
//totest - if qualifier evaluates to null, NullPoitnerException should be thrown after the evaluation of the arguments

/*@
The next step is the evaluation of the arguments (JLS \$15.12.4.2). This also requires just one context rule. The
  whole list of arguments is the third argument of method invocation production, but in order to evaluate the arguments
  we need to heat them one by one. JLS enforces the following conditions on the timing of arguments evaluation:
  - Arguments have to be evaluated after the qualifier was evaluated. This is ensured by checking that the qualifier
  is of sort KResult at the moment when arguments are heated.
  - Arguments are evaluated left to right. To ensure this we add a side condition that checks that all the arguments
    before the one being heated (if any) are already of the sort KResult.

Arguments have to be evaluated even in the case when the qualifier is null. On the other hand,
  JLS states that once the evaluation of the qualifier or any of the arguments completes abruptly,
  the whole method invocation expression completes abruptly for the same reason. K-Java don't need any special rules
  to cover those cases. The small number of rules related to throw statement ensure correct exception propagation
  from any context.
*/
context 'Invoke('Method('MethodName(_:KResult,, Name:Id )),, [Ks:KList,, HOLE,,_] )
when
    isKResult(Ks)

/*@
During the third step of method invocation the second argument of the production is replaced with the auxiliary data
  structure methodInfo(). This data structure contains the information required to choose the right method lookup
  strategy at the next step. The production methodInfo() contains the following arguments:

  - Method signature Sig
  - Qualifying type QualT of the method invocation, e.g. the compile-time type of the qualifier.
  - The meta type of QualT - MetaT. It may have one of the two values - class or interface.
  - DecT - the class where the method was actually declared, as observed by QualT. E.g. the most derived class
    in QualT hierarchy where there is a declaration of a method with signature Sig.
  - ContextT - the context type of the method. Either static, for static methods, or instance for non-static methods.

All the information in methodInfo() should be computed, according to JLS at compile-time. In K-Java we actually have
  this information already computed, but it is stored in various cells inside <class> and <classDec> instead of the
  actual method invocation production. Thus we use methodInfo() as a buffer where information is first loaded from
  cells, before being consumed by the rules of step 4. This allows us to greatly simplify the step 4 rules.
*/
syntax K ::=  methodInfo(
                Signature,  //method signature
                RefType,    //qualifier type, not necessarily class
                ClassMetaType, //The either classCMT or interfaceCMT for the qualifier type
                RefType,    //method definition class type - the class referred by the signature in <methods>
                              // for arrays - it remains noClass
                              // this argument is only used to compute the context type
                ContextType //method context type - instance or static
                              // for arrays - instanceCT
              )

/*@
The first rule from step 3 rewrites the method name into a methodInfo() whose first argument is the method signature.
  The auxiliary function getTypes() computes the list of types from the list of parameter declarations. The second
  argument of methodInfo is also computed at this step - it is the type of the qualifier. The rest of the arguments
  are filled in with default values. They will be rewritten into actual values by the following rules.

This rule alos have a side condition that checks whether parameters were evaluated to final values. this makes sure
  that this rule is executed only when the first two steps of method invocation were completed. Because all the
  following rules cannot match unless this rule have been matched, we only have to make this check once - in this rule.
*/
rule [Invoke-Method-compute-Signature]:
    'Invoke('Method('MethodName(
      Qual:KResult,,
      (Name:Id => methodInfo(sig(Name, getTypes([ParamVals])), typeOf(Qual), noValue, noClass, noValue))
      )),, [ParamVals:KList]
    )
when
    isKResult(ParamVals)

/* Impl: We could combine this rule with the previous one by using getLookupTargetType(), but we'll keep it this way
    to keep the core part of method invocation separate from the non object-related part. */

/*@ [Skip]
The next rule for method invocation is applied when the qualifier type is array. This array type is rewritten
  into the auxiliary class ArrayImpl, that is used in K-Java to simulate method invocations over array objects.
  This rule is required in order to minimize the number of particular cases involving arrays in the rules that follow.
*/
rule [Invoke-Method-load-MethodDefClass-arrays]:
    'Invoke('Method('MethodName(
      QualRV:RawVal :: (arrayOf T:Type => arrayImplClass),,
      methodInfo(Sig:Signature, arrayOf T => arrayImplClass , _,_,_)
    )),, _)

/*@
The second rule for method invocation loads MetaT and DecT. It requires Sig and QualT computed by the previous
  rule.
*/
rule [Invoke-Method-load-MethodDefClass]:
    <k>
      'Invoke('Method('MethodName(
        Qual:KResult,,
        methodInfo(Sig:Signature, QualClass:ClassType, noValue => MetaType, noClass => MethodDefClass, noValue)
      )),, _)
      ...
    </k>
    <classType> QualClass </classType>
    <classMetaType> MetaType:ClassMetaType </classMetaType>
    <methods>... Sig |-> MethodDefClass:ClassType ...</methods>

/*@
There is one case that is not covered by the previous rule - the case when the cell <methods> does not have a key
  equal to Sig. This is possible in one of the following situations:
  - Qualifying type is an interface.
  - Qualifying type is an abstract class. The called method is inherited from an interface but is not defined neither
    in this class nor in its base classes.

In both cases the method is an abstract method in the class QualT. For this case DecT cannot be computed, but we know
  for sure that ContextT for an abstract method is instance.
*/
rule [Invoke-Method-load-unmapped-method-ContextType]:
    <k>
      'Invoke('Method('MethodName(
        Qual:KResult,,
        methodInfo(Sig:Signature, QualClass:ClassType, noValue => MetaType, _, noValue => instanceCT)
        )),, _)
      ...
    </k>
    <classType> QualClass </classType>
    <classMetaType> MetaType:ClassMetaType </classMetaType>
    <methods> Methods:Map </methods>
when
    notBool Sig in keys(Methods)

/*@
The last rule of step 3 loads ContextT for the invoked method. It requires DecT, so this rule may only match after
  the second rule for methodInfo().
*/
rule [Invoke-Method-load-ContextType]:
    <k>
      'Invoke('Method('MethodName(
        Qual:KResult,,
        methodInfo(Sig:Signature, QualClass:ClassType, _, MethodDefClass:ClassType, noValue => CT)
      )),, _)
      ...
    </k>
    <classType> MethodDefClass </classType>
    <methodSignature> Sig </methodSignature>
    <methodContextType> CT:ContextType </methodContextType>

/*@
Once the last field of methodInfo() is filled, the next step of method invocation begins - deciding the actual method
  declaration to be executed. The rules of this step rewrite methodInfo() into methodRef() - another auxiliary data
  structure.
The production methodRef() is a reference to a method declaration. It contains two fields - Sig and ImplT - the
  signature and the implementation class. The implementation class is the class that contains the actual method code
  to be invoked. Since we already know the signature, this phase amounts to computing ImplT.

  This step contains different rules for the following cases:
  - Static method (JLS \$15.12.4.4 paragraph 2)
  - Instnace method with target being null (JLS \$15.12.4.4 paragraph 3)
  - Instance method with non-null target, qualifying type is interface (JLS \$15.12.4.4 point 1.a)
  - Instance method with non-null target, qualifying type is class (JLS \$15.12.4.4 point 1.b)
  - [Skip] Target value is array or string.

The method below is for the first case. If the method is static, then the declaring type DecT is the qualifying type.
  The qualifier is discarded by rewritting it into noValue.
*/
//todo replace invokeImpl with 'Invoke, for consistency with the documentation.
rule [Invoke-Method-Static-On-Class]:
    'Invoke(
      'Method('MethodName(_,,
        methodInfo(Sig:Signature, QualClass:ClassType, classCMT, MethodDecClass:ClassType, staticCT)
      )),,
      [ParamVals:KList]
    )
    => invokeImpl( methodRef(Sig, MethodDecClass), noValue, [ParamVals] )

/*@
If the qualifier value is null and ContextT is instance, then NullPointerException is thrown and method invocation
  expression is discarded. It is only at this point that we should check the qualifier whether it is null or not.
  If ContextT is static, then the rule above will match, and no exception will be thrown.
*/
rule [Invoke-Method-instance-On-Null]:
/*  [Impl] Qualifier type could be either object or array.
    We cannot move method invocation on null logic to invokeImpl, because
    invokeImpl needs an actual methodRef, and we cannot produce a methidRef if our qualifier object is null.
*/
    'Invoke( 'Method('MethodName( null::_,, methodInfo(_,_,_,_, instanceCT) )),, [_] )
    =>  'Throw('NewInstance(
          'None(.KList),,
          class String2Id("java.lang.NullPointerException"),,
          [ null::stringClass ],,
          'None(.KList)
        ))

/*@
If MetaT is interface then the method is always instance and public. We can safely assume that the method was
  inherited by the actual runtime type of the qualifier object during unfolding phase. The class ImplT is the one
  referred by the <methods> map of the qualifier runtime type.
*/
rule [Invoke-Method-Instance-On-interface]:
    <k>
      'Invoke('Method('MethodName(
          objectRef(
            OL:Int,
            ActualClass:ClassType
          )::QualClass:ClassType,,
          methodInfo(Sig:Signature, QualClass:ClassType, interfaceCMT, _, instanceCT)
        )),,
        [ParamVals:KList]
      )
      =>  invokeImpl( methodRef(Sig, MethodDecClass), loc(OL)::QualClass, [ParamVals] )
      ...
    </k>
    <classType> ActualClass </classType>
    <methods>... Sig |-> MethodDecClass:ClassType ...</methods>

/*@
Finally, if the qualifying type is a class, we have a more complex version of a method call. Here the method access
  mode in QualT is not necessarily public, and the lookup strategies for different access modes are different.

  todo avoid using lookupOverloadedMethod() to be better in sync with JLS.
*/
rule [Invoke-Method-Instance-On-Class]:
    'Invoke('Method('MethodName(
        objectRef(
          OId:Int, MostDerivedClass:ClassType
        )::QualClass:ClassType,,
        methodInfo(Sig:Signature, QualClass:ClassType, classCMT, _, instanceCT)
      )),, [ParamVals:KList]
    )
    =>  invokeImpl(
          methodLookupRuntime( Sig, getClassChain([MostDerivedClass], QualClass), noMethodRef ),
          loc(OId)::QualClass, [ParamVals]
        )

rule [Invoke-Method-On-array-or-string]:
    'Invoke('Method('MethodName(
        QualRV:RawVal::QualClass:ClassType,,
        methodInfo(Sig:Signature, QualClass, classCMT, MethodDecClass:ClassType, instanceCT)
      )),,
      [ParamVals:KList]
    )
    => invokeImpl( methodRef(Sig, MethodDecClass), QualRV::QualClass, [ParamVals] )
when
    (getKLabel(QualRV) ==KLabel 'arrayRef) orBool isString(QualRV) ==K true

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

/*Returns the list of classes representing the layer of the given object (by OId),
    located between MostBaseClass and MostDerivedClass.
*/
syntax K ::=  getClassChain(  KListWrap,  //[MostDerivedClass] at beginning, gradually accumulates the list of classes
                              ClassType   //MostBaseClass
              )

rule [getClassesBetween-process]:
    <k>
      getClassChain([(.KList => BaseClass),, MostDerivedClass:ClassType,, _], MostBaseClass:ClassType)
      ...
    </k>
    <classType> MostDerivedClass </classType>
    <extends> BaseClass:ClassType </extends>
when
    MostDerivedClass =/=K MostBaseClass

rule [getClassesBetween-end]:
    getClassChain([Class:ClassType,, MostDerivedClass:KList], Class) => resultListWrap(Class,, MostDerivedClass)

/*@ The right signature is already found.
Search for the right implementation is performed from the compile-time type of the target
to more derived types, up to the object type of the target.
This is required in order to respect the rules of inheritance in the presence of access modes.
Evaluates into typed method closure.*/
syntax K ::=  methodLookupRuntime (
                Signature,  //sig(Name, SigTL) - Method signature
                K,          //computes into resultListWrap(Class list), elements of type ClassType,
                              // from base to derived.
                              // To be processed from base to derived when methods map will be exhausted
                MethodRef   //method closure of the most specific method found so far
                              // or noValue if no applicable method was found yet
              )
              [strict(2,3)]

rule [methodLookupRuntime-layer-first-dec-found]:
    <k>
      methodLookupRuntime(
        Sig:Signature,
        resultListWrap((Class:ClassType => .KList),, _),
        noMethodRef => methodRef(Sig, DecClass)
      )
      ...
    </k>
    <classType> Class </classType>
    <methods>... Sig |-> DecClass:ClassType ...</methods>

rule [methodLookupRuntime-layer-two-decs-choice]:
    <k>
      methodLookupRuntime(
        Sig:Signature,
        resultListWrap((Class:ClassType => .KList),, _),
        methodRef(Sig:Signature, DecClass1:ClassType)
        =>  'If(
              isAccessibleForOverwriting( DecClass1, getMethodAccessMode(methodRef(Sig, DecClass1)), DecClass2 ),,
              methodRef(Sig, DecClass2),,
              methodRef(Sig, DecClass1)
            )
      )
      ...
    </k>
    <classType> Class </classType>
    <methods>... Sig |-> DecClass2:ClassType ...</methods>

rule [methodLookupRuntime-layer-discard]:
    <k>
      methodLookupRuntime( Sig:Signature, resultListWrap((Class:ClassType => .KList),, _), _ )
      ...
    </k>
    <classType> Class </classType>
    <methods> Methods:Map </methods>
when
    notBool Sig in keys(Methods)

rule [methodLookupRuntime-SigKnownEnd]:
    methodLookupRuntime(_, resultListWrap(.KList), MethodRef:MethodRef ) => MethodRef
when
    //Condition for debug purposes only. If no suitable method impl was found so far, cumputation will stuck here
    MethodRef =/=K noMethodRef

syntax K ::=  invokeImpl (
                MethodRef,  //lookupOverloadedMethod statement, evaluates to methodRef()
                K,          //KResult - method call target
                              //loc(OL)::_ - object location, target type for methods on non-object refs,
                              //typed string or array, or noValue for static methods
                KListWrap   //[ParamValues:List{KResult}]
              )
              [strict(1)]

/*@ (kool doc) Closure application needs to also set a new return type in the
    \textsf{return} cell, in order for the values returned by its body to
    be checked against the return type of the method.  To do this correctly,
    we also need to stack the current status of the \textsf{return} cell
    and then pop it when the method returns.

  Calling staticInit() is required for static methods only. Calling it on instance methods have no effect,
    since the qualifier class have been initialized at least when the qualifier object was first created.

  The extra return statement is used to exit at the end of a constructor or a method with no arguments,
    if no other return statements were encountered. We cannot append an extra return statement at the preprocessing
    phase because this would make constructors invalid.
*/
rule [invokeImpl]:
    <k>
      invokeImpl(
        methodRef(Sig:Signature, Class:ClassType),
        Qual:KResult,
        [ParamValues:KList]
      ) ~> RestK:K
       => staticInit(Class) ~> bindTo([Params], [ParamValues]) ~> Body ~> 'Return('None(.KList))
    </k>
    <stack>
      . => ListItem(sl(RestK, MethContext))
      ...
    </stack>
    <methodContext>
      MethContext:Bag
      =>  <env> .Map </env>
          <return> ReturnT </return>
          <crntClass> Class </crntClass>
          <location> getOId(Qual) </location>
    </methodContext>

    <classType> Class </classType>
    <methodSignature> Sig </methodSignature>
    <methodReturnType> ReturnT:Type </methodReturnType>
    <methodParams> [Params:KList] </methodParams>
    <methodBody> Body:K </methodBody>
when getKLabel(Body) =/=KLabel 'NoMethodBody

syntax K ::= getOId( K )              [function]
rule getOId( loc(OId:Int)::_ ) => OId
rule getOId( noValue ) => noValue

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
