require "core-sorts.k"
require "process-class-members.k"
require "elaboration-expressions.k"
require "subtyping.k"

//@ \section{Module ELABORATION-METHOD-INVOKE}

module ELABORATION-METHOD-INVOKE
    imports CORE-SORTS
    imports PROCESS-CLASS-MEMBERS
    imports ELABORATION-EXPRESSIONS
    imports SUBTYPING

/*@ 'Method(Qual:K,, _:K,, Name:Id)
    'Method('MethodName(Qual:K,, Name:Id))
*/
syntax KLabel ::= "'Method"
                | "'MethodName"

rule 'Method(Qual:K,, _:K,, Name:Id => 'MethodName(Qual,, Name))  [structural, anywhere]

rule isExtKResult('Method('MethodName(Qual:K,, Name:Id))) => true

rule [Method-MethodName-Unq-InstanceCT]:
    <k>
      'Method('MethodName(Name:Id) => 'MethodName(cast(Class, 'QThis(Class)),, Name))
      ...
    </k>
    <crntClass> Class:ClassType </crntClass>                 [structural]

//@ 'SuperMethod(_:K,, Name:Id)
syntax KLabel ::= "'SuperMethod"

// super.X(_)
rule [SuperMethod-desugar]:
    <k>
      'SuperMethod(K:K,, Name:Id) => 'QSuperMethod(Class,, K:K,, Name:Id)
      ...
    </k>
    <crntClass> Class:ClassType </crntClass>  [structural]

//@ 'QSuperMethod(Class:ClassType,, _:K,, Name:Id)
syntax KLabel ::= "'QSuperMethod"

rule [QSuperMethod]:
    <k>
      'QSuperMethod(Class:ClassType,, _:K,, Name:Id)
      => 'Method('MethodName(cast(BaseClass, superMethod(cast(BaseClass, 'QThis(Class)))),, Name))
      ...
    </k>
    <classType> Class </classType>
    <extends> BaseClass:ClassType </extends>  [structural]

//First argument is reduced up to lookupMethodData.
context elabEnd('Invoke(HOLE,, _))                      [result(ExtKResult)]

rule [elabEnd-Invoke-to-lookupMethod-qualified]:
    elabEnd('Invoke(
      'Method('MethodName(Qual:K,, Name:Id)),,
      'ListWrap(ParamExps:KList)
    )) => lookupMethod(
      getLookupTargetType(typeOf(Qual)),
      Name,
      noValue,
      false,
      Qual,
      ParamExps
    )
when notBool isCastOfQThis(Qual) ==K true

rule [elabEnd-Invoke-to-lookupMethod-unqualified]:
    <k>
      elabEnd('Invoke(
        'Method('MethodName(cast(Class, 'QThis(Class:ClassType)),, Name:Id)),,
        'ListWrap(ParamExps:KList))
      ) => lookupMethod(
        Class,
        Name,
        noValue,
        false,
        cast(Class, 'QThis(Class)),
        ParamExps
      )
      ?? elabEnd('Invoke(
        'Method('MethodName(cast(EnclosingClass, 'QThis(EnclosingClass)),, Name:Id)),,
        'ListWrap(ParamExps)
      ))
      ...
    </k>
    <classType> Class </classType>
    <enclosingClass> EnclosingClass:ClassType </enclosingClass>

//K bug: latex workaround - manual character escape.
//@ True for cast(T,'QThis(\_)), false otherwise
syntax K ::= isCastOfQThis ( K )                                      [function]
rule isCastOfQThis(cast(_, 'QThis(_))) => true

syntax K ::= isThisOrSuper( K )                                       [function]
rule isThisOrSuper(cast(_, 'QThis(_))) => true
rule isThisOrSuper(cast(_, 'superMethod(_))) => true

/*@ Lookup the right methodClosure based on supplied parameters.
If the method is not found in the supplied class list, we should search for it in the
class list corresponding to the enclosing class of the caller class.
First we search for the signature - lookupSignature construct.
Afterwards we search for the right implementation in the hierarchy, once the signature is known
- lookupMethodSigKnown.*/
syntax K ::=  lookupMethod (
                ClassType,//target class, even for arrays.
                Id,       //method name
                K,        //Evaluates to the signature to be called, or noValue if no signature was found yet
                          // Sig format: mapWrap(Sig |-> MethodTV)
                Bool,     //SigSearched: true if Sig was already searched for the current class, false otherwise.
                          // Starts with false.
                K,        //Qual - either Cast - typed qualifier expression, or Class for class qualifiers.
                KList     //ParamExps - parameter expressions of type Cast
              )
              [strict(4)]

//K bug - [strict] and KList arguments don't work together. Tested with K version of 23/02/2014.
context lookupMethod(_,_,HOLE,_,_,_)

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
      noValue => lookupSignature(MethodName, getTypes(ParamExps), getMethods(QualClass),
                                 notBool isThisOrSuper(Qual) ==K true, noValue, QualClass),
      false => true,
      Qual:K,
      ParamExps:KList
    )

/*If resolved method is static, we cannot insert in the construct the actual method body,
because this body might not be elaborated.*/
rule [lookupMethod-SigFound]:
    lookupMethod(
      QualClass:ClassType,
      _,
      methodClosure(_,_, CT:ContextType, _,_,_,_) :: methodType(sig( Name:Id, ArgTypes:Types ), RetT:Type),
      true, QualK:K, ParamExps:KList
    ) => methodProcessArguments(RetT, QualClass, QualK, Name, ArgTypes, ParamExps, .KList, CT)

rule [lookupMethod-Sig-NotFound]:
    lookupMethod(_,_, noValue, true, _,_) => noValue

syntax K ::=  methodProcessArguments (
                Type,       //RetT - method return type
                ClassType,  //QualClass - target class
                K,          //QualK - method qualifier
                Id,         //Name - method name
                Types,      //ArgTypes - argument types
                KList,      //ParamExps - actual parameters
                KList,      //will be used later as parameters casted to expected parameter types
                ContextType // CT - context type of the found method (not of the caller context!), instance or static
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
    <k>
      (methodProcessArguments(RetT:Type, QualClass:ClassType, QualK:K, Name:Id, types(.KList), .KList,
                              ExpectedParamExps:KList, CT:ContextType)
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
                      #else QualClass
                    #fi,,
                    Name:Id
                  )
                ),,
                'ListWrap(ExpectedParamExps)
              )
            )
          ))
      )
      ~> KI:KItem
      ...
    </k>
when getKLabel(KI) =/=KLabel 'elabEnd //if it is elabEnd, then it is elabEnd('QNewInstance(...)),
                                      //and we have a different rule for that.

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

endmodule
