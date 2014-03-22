require "core-sorts.k"
require "process-class-members.k"
require "subtyping.k"
require "method-invoke.k"

//@ \section{Module ELABORATION-METHOD-INVOKE}

module ELABORATION-METHOD-INVOKE
    imports CORE-SORTS
    imports PROCESS-CLASS-MEMBERS
    imports SUBTYPING
    imports METHOD-INVOKE //for superMethod()

/*@ 'Method(Qual:K,, _:K,, Name:Id)
    'Method('MethodName(Qual:K,, Name:Id))
*/
syntax KLabel ::= "'Method"
                | "'MethodName"

rule customElabEnd('Method) => true

rule elabEnd('Method(Qual:K,, _:K,, Name:Id))  => elabEnd('Method('MethodName(Qual,, Name)))  [structural]

rule [elabEnd-Method-MethodName-Unq-InstanceCT]:
    <k>
      elabEnd('Method('MethodName(Name:Id))) => elab('Method('MethodName(findQualifierForName(Class, Name),, Name)))
      ...
    </k>
    <crntClass> Class:ClassType </crntClass>                 [structural]

rule [elabEnd-Method-MethodName-to-elabRes]:
    ('elabEnd => 'elabRes)('Method('MethodName(_:K,, Name:Id)))

/*@ Computes into an expression of the form elabRes(cast(QualClass, 'QThis(QualClass))),
where QualClass is searched in the enclosing context of the first argument,
being a class that have methods with name = the second argument.
Or noValue if no suitable result is found

The algorithm is slightly different from the previous one with chained lookupMethod. Here we just search for the first
  class with an appropriate name. That one searches for the class with appropriate signature.
  todo assure that either this algorithm is wrong or we need some more tests.
*/
syntax K ::=  findQualifierForName (
                ClassType,  //The context class in which qualifier is searched for.
                Id          //Qualifier should contain a method with this name
              )
              [strict(2)]

rule isElabNaked(findQualifierForName(_,_)) => true

rule [elabEnd-findQualifierForName]:
    <k>
      findQualifierForName(QualClass:ClassType, Name:Id)
      => ifAux(
           containsName(Methods, Name) ==K true,
           elabRes(cast(QualClass,'QThis(QualClass))),
           findQualifierForName(QualEncloserClass, Name)
         )
      ...
    </k>
    <classType> QualClass </classType>
    <enclosingClass> QualEncloserClass:ClassType </enclosingClass>
    <methods> Methods:Map </methods>

syntax K ::= containsName ( Map , Id )        [function]
rule containsName((sig(Name, _) |-> _) _:Map, Name:Id) => true

//@Happens for 'NewInstance expressions for static inner classes.
rule [elabEnd-findQualifierForName-static]:
    findQualifierForName(noClass, K:K) => noValue

//@ 'SuperMethod(_:K,, Name:Id)
syntax KLabel ::= "'SuperMethod"

rule customElabEnd('SuperMethod) => true

// super.X(_)
rule [SuperMethod-desugar]:
    <k>
      elabEnd('SuperMethod(K:K,, Name:Id)) => elabEnd('QSuperMethod(Class,, K:K,, Name:Id))
      ...
    </k>
    <crntClass> Class:ClassType </crntClass>  [structural]

//@ 'QSuperMethod(Class:ClassType,, _:K,, Name:Id)
syntax KLabel ::= "'QSuperMethod"

rule customElabEnd('QSuperMethod) => true

rule [QSuperMethod]:
    <k>
      elabEnd('QSuperMethod(Class:ClassType,, _:K,, Name:Id))
      => elabEnd('Method('MethodName(cast(BaseClass, superMethod(cast(BaseClass, 'QThis(Class)))),, Name)))
      ...
    </k>
    <classType> Class </classType>
    <extends> BaseClass:ClassType </extends>  [structural]

rule [elabEnd-Invoke-to-lookupMethod]:
    ( . => lookupMethod(getLookupTargetType(typeOf(Qual)), isThisOrSuper(Qual) ==K true, Name, ParamExps) )
    ~> elabEnd('Invoke( 'Method('MethodName(Qual:K,, Name:Id)),, 'ListWrap(ParamExps:KList) ))

//@ True for cast(T,'QThis(\_)), false otherwise
syntax K ::= isCastOfQThis ( K )                                      [function]
rule isCastOfQThis(cast(_, 'QThis(_))) => true

syntax K ::= isThisOrSuper( K )                                       [function]
rule isThisOrSuper(cast(_, 'QThis(_))) => true
rule isThisOrSuper(cast(_, superMethod(_))) => true

/*@ Lookup the right methodClosure based on supplied parameters.
If the method is not found in the supplied class list, we should search for it in the
class list corresponding to the enclosing class of the caller class.
First we search for the signature - lookupSignature construct.
Afterwards we cast the actual arguments to the types expected by the found method signature.*/
syntax K ::=  lookupMethod (
                ClassType,//target class, even for arrays.
                Bool,     //QualIsThis - true if qualifier is cast(_, 'QThis(_)) or cast(_, superMethod(_))
                Id,       //method name
                KList     //ParamExps - parameter expressions of type Cast
              )

rule lookupMethod(QualClass:ClassType, QualIsThis:Bool, MethodName:Id, ParamExps:KList)
     => lookupMethod(QualClass:ClassType, QualIsThis:Bool, MethodName:Id, ParamExps:KList, tempKResult, tempKResult)

/*@ Lookup the right methodClosure based on supplied parameters.
If the method is not found in the supplied class list, we should search for it in the
class list corresponding to the enclosing class of the caller class.
First we search for the signature - lookupSignature construct.
Afterwards we cast the actual arguments to the types expected by the found method signature.*/
syntax K ::=  lookupMethod (
                ClassType,//target class, even for arrays.
                Bool,     //QualIsThis - true if qualifier is cast(_, 'QThis(_)) or cast(_, superMethod(_))
                Id,       //method name
                KList,    //ParamExps - parameter expressions of type Cast
                K,        //Evaluates to the signature to be called, or noValue if no signature was found yet
                          // Sig format: mapWrap(Sig |-> MethodTV)
                          // Initialized with tempKResult
                K         //Evaluates to the method arguments casted to expected argument types
                          // Initialized with tempKResult
              )
              [strict(5,6)]

/*@ A Temporary KResult that prevents this term to be heated before it is transformed by another rule int a proper
  term to be heated. This is not a final KResult in its surrounding context. Basically, this term is used to cheat
  K heating rules.
*/
syntax KResult ::= "tempKResult"

//K bug - [strict] and KList arguments don't work together. Tested with K version of 23/02/2014.
context lookupMethod(_,_,_,_, HOLE, _)
context lookupMethod(_,_,_,_,_, HOLE)

syntax K ::= getLookupTargetType ( RefType )    [function]
rule getLookupTargetType(Class:ClassType) => Class
rule getLookupTargetType(arrayOf _) => arrayImplClass

syntax K ::= "arrayImplClass"                   [function]
rule arrayImplClass => class String2Id("java.lang.ArrayImpl")

//All cases
rule [lookupMethod-to-lookupSignature]:
    lookupMethod(
      QualClass:ClassType,
      QualIsThis:Bool,
      MethodName:Id,
      ParamExps:KList,
      tempKResult => lookupSignature(MethodName, getTypes(ParamExps), getMethods(QualClass),
                                 notBool QualIsThis, noValue, QualClass),
      tempKResult
    )

/*If resolved method is static, we cannot insert in the construct the actual method body,
because this body might not be elaborated.*/
rule [lookupMethod-SigFound]:
    lookupMethod(
      _,_,_,
      ParamExps:KList,
      methodClosure(_,_,_,_,_,_,_) :: methodType(sig( Name:Id, ArgTypes:Types ), _),
      tempKResult => methodCastArguments(ArgTypes, ParamExps, .KList)
    )

syntax K ::=  methodCastArguments (
                Types,      //ArgTypes - argument types
                KList,      //ParamExps - actual parameters
                KList       //Result of parameter casting. Initialized with .KList
              )

rule [methodCastArguments-process]:
    methodCastArguments(
      types(((ArgType:Type) => .KList),, _),
      ((ParamExp:K => .KList),, _),
      (_,, (.KList => cast(ArgType, ParamExp)))
    )

rule [methodCastArguments-end]:
    methodCastArguments(types(.KList), .KList, ExpectedParamExps:KList) => resultListWrap(ExpectedParamExps)

rule [lookupMethod-end]:
    lookupMethod(
      _,_,_,_,
      methodClosure(_,_, CT:ContextType, _,_,_,_) :: methodType(sig( Name:Id, ArgTypes:Types ), RetT:Type),
      resultListWrap(ExpectedParamExps:KList)
    )
    => methodLookupResult(RetT, ExpectedParamExps, CT)

/*@ Marker indicating that arguments of the following 'Invoke, 'QNewInstance, 'QSuperConstrInv, 'AltConstrInv
  have been elaborated.
*/
syntax K ::=  methodLookupResult (
                Type ,      // Return type
                KList ,     // ExpectedParamExps
                ContextType // Called method context type
              )

//for now just a workaround implementation
rule [methodProcessArguments-Invoke-end]:
    methodLookupResult(RetT:Type, ExpectedParamExps:KList, CT:ContextType)
    ~>  elabEnd('Invoke( 'Method('MethodName(QualK:K,, Name:Id)),, _ ))
    =>  elabEnd(stmtAndExp(

          //if the context is static but qualifier isa valid expression, we have to evaluate it.
          #if CT ==K staticCT andBool isCast(QualK) ==K true andBool notBool isCastOfQThis(QualK) ==K true
            #then 'ExprStm(QualK)
            #else 'Empty(.KList)
          #fi,

          cast(RetT,
            'Invoke(
              'Method(
                'MethodName(
                  #if CT ==K instanceCT
                    #then QualK
                    #else typeOf(QualK)
                  #fi,,
                  Name:Id
                )
              ),,
              'ListWrap(ExpectedParamExps)
            )
          )
        ))

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
        => ifAux(
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
            ),
            NewMethTV,
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
                Bool,       //IsQ - whether the initial method call expression was qualified, used by protected mode.
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
                ifAux(IsQ, CurrentClass, TargetClass),
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

endmodule
