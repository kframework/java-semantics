//@ \section{Module ELABORATION-METHOD-INVOKE}

module ELABORATION-METHOD-INVOKE
    imports CORE-SORTS
    imports CORE-CLASSES
    imports SUBTYPING
    imports ELABORATION-CORE

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
being the innermost class that have a method with name = the second argument.
Or noValue if no suitable result is found.

This algorithm is correct even when both inner and outer class have methods with the same name.
Java don't support method overloading in the context of nesting. In other words, inner class methods
don't overload but rather hide methods with the same name from outer classes. See program
inner_in_81_inner_overl_outer as example.
*/
syntax KItem ::=  findQualifierForName (
                ClassType,  //The context class in which qualifier is searched for.
                Id          //Qualifier should contain a method with this name
              )

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

syntax KItem ::= containsName ( Map , Id )        [function]
//todo mapItem
//rule containsName((sig(Name, _) |-> _) _:Map, Name:Id) => true

//@Happens for 'NewInstance expressions for static inner classes.
rule [elabEnd-findQualifierForName-static]:
    findQualifierForName(noClass, K:K) => noValue

//@ 'SuperMethod(_:K,, Name:Id)

rule customElabEnd('SuperMethod) => true

// super.X(_)
rule [SuperMethod-desugar]:
    <k>
      elabEnd('SuperMethod(K:K,, Name:Id)) => elabEnd('QSuperMethod(Class,, K:K,, Name:Id))
      ...
    </k>
    <crntClass> Class:ClassType </crntClass>  [structural]

rule [elabEnd-Invoke-QSuperMethod-to-lookupMethod]:
    <k>
      ( . => lookupMethod(BaseClass, true, Name, [ArgExps]) )
      ~> elabEnd('Invoke( 'QSuperMethod(Class:ClassType,, _:K,, Name:Id),, [ArgExps:KList] ))
      ...
    </k>
    <classType> Class </classType>
    <extends> BaseClass:ClassType </extends>

rule [methodLookupResult-Invoke-QSuperMethod-static-end]:
    <k>
      methodLookupResult(RetT:Type, [ExpectedArgExps:KList], staticCT)
      ~>  elabEnd('Invoke( 'QSuperMethod(Class:ClassType,, _:K,, Name:Id),, _ ))
      =>  elabEnd(cast(RetT,
                  'Invoke( 'Method( 'MethodName( BaseClass,, Name:Id ) ),, [ExpectedArgExps] )
          ))
      ...
    </k>
    <classType> Class </classType>
    <extends> BaseClass:ClassType </extends>

rule [methodLookupResult-Invoke-QSuperMethod-instance-end]:
    methodLookupResult(RetT:Type, [ExpectedArgExps:KList], instanceCT)
    ~>  elabEnd('Invoke( 'QSuperMethod(Class:ClassType,, K2:K,, Name:Id),, _ ))
    =>  elabEnd(cast(RetT,
            'Invoke(
              'QSuperMethod(Class:ClassType,, K2:K,, Name:Id),,
              [ExpectedArgExps]
            )
          )
        )

rule [elabEnd-Invoke-to-lookupMethod]:
    ( . => lookupMethod(getLookupTargetType(typeOf(Qual)),
                        isCastOfQThis(Qual) ==K true, Name, [ArgExps]) )
    ~> elabEnd('Invoke( 'Method('MethodName(Qual:K,, Name:Id)),, [ArgExps:KList] ))

//@ Returnts the same type for classes, arrayImplClass for arrays.
syntax KItem ::= getLookupTargetType ( RefType )    [function]
rule getLookupTargetType(Class:ClassType) => Class
rule getLookupTargetType(arrayOf _) => classArrayImpl

//@ True for cast(T,'QThis(\_)), false otherwise
syntax KItem ::= isCastOfQThis ( K )                                      [function]
rule isCastOfQThis(cast(_, 'QThis(_))) => true

/*@ Lookup the right methodRef() based on supplied parameters.
If the method is not found in the supplied class list, we should search for it in the
class list corresponding to the enclosing class of the caller class.
First we search for the signature - lookupSignature construct.
Afterwards we cast the actual arguments to the types expected by the found method signature.*/
syntax KItem ::=  lookupMethod (
                ClassType,//target class, even for arrays.
                Bool,     //QualIsThis - true if qualifier is cast(_, 'QThis(_)) or cast(_, superMethod(_))
                Id,       //method name
                KListWrap //[ArgExps] - parameter expressions of type Cast
              )

syntax KItem ::=  lookupMethod (
                ClassType,//target class, even for arrays.
                Bool,     //QualIsThis - true if qualifier is cast(_, 'QThis(_)) or cast(_, superMethod(_))
                Id,       //method name
                KListWrap,//[ArgExps] - parameter expressions of type Cast
                MethodRef,//Evaluates to the signature to be called, or noMethodRef if no signature was found yet
                            // Sig format: mapWrap(Sig |-> MethodTV)
                            // Initialized with noMethodRef
                K         //Evaluates to the method arguments casted to expected argument types
                          // Initialized with tempKResult
              )
              [strict(5, 6)]

rule lookupMethod(QualClass:ClassType, QualIsThis:Bool, MethodName:Id, [ArgExps:KList])
     => lookupMethod(QualClass:ClassType, QualIsThis:Bool, MethodName:Id, [ArgExps], noMethodRef, tempKResult)

/*@ A Temporary KResult that prevents this term to be heated before it is transformed by another rule int a proper
  term to be heated. This is not a final KResult in its surrounding context. Basically, this term is used to cheat
  K heating rules.
*/
syntax KResult ::= "tempKResult"

//All cases
rule [lookupMethod-to-lookupSignature]:
    <k>
      lookupMethod(
        QualClass:ClassType,
        QualIsThis:Bool,
        MethodName:Id,
        [ArgExps:KList],
        noMethodRef => lookupSignature(MethodName, getTypes([ArgExps]), Methods,
                                    notBool QualIsThis, noMethodRef, QualClass),
        tempKResult
      )
      ...
    </k>
    <classType> QualClass </classType>
    <methods> Methods:Map </methods>

/*If resolved method is static, we cannot insert in the construct the actual method body,
because this body might not be elaborated.*/
rule [lookupMethod-SigFound]:
    lookupMethod(
      _,_,_,
      [ArgExps:KList],
      methodRef(sig( Name:Id, ArgTypes:Types ), _),
      tempKResult => methodCastArguments(ArgTypes, [ArgExps], [.KList])
    )

syntax KItem ::=  methodCastArguments (
                Types,      //ArgTypes - argument types
                KListWrap,  //ArgExps - actual parameters
                KListWrap   //Result of parameter casting. Initialized with .KList
              )

rule [methodCastArguments-process]:
    methodCastArguments(
      types(((ArgType:Type) => .KList),, _),
      [(ParamExp:K => .KList),, _],
      [_,, (.KList => cast(ArgType, ParamExp))]
    )

rule [methodCastArguments-end]:
    methodCastArguments(types(.KList), [.KList], [ExpectedArgExps:KList]) => kr[ExpectedArgExps]

rule [lookupMethod-end]:
    <k>
      lookupMethod(
        _,_,_,_,
         methodRef(Sig:Signature, Class:ClassType),
        kr[ExpectedArgExps:KList]
      )
      => methodLookupResult(RetT, [ExpectedArgExps], CT)
      ...
    </k>
    <classType> Class </classType>
    <methodSignature> Sig </methodSignature>
    <methodReturnType> RetT:Type </methodReturnType>
    <methodContextType> CT:ContextType </methodContextType>

/*@ Marker indicating that arguments of the following 'Invoke, 'QNewInstance, 'QSuperConstrInv, 'AltConstrInv
  have been elaborated.
*/
syntax KItem ::=  methodLookupResult (
                Type ,      // Return type
                KListWrap , // ExpectedArgExps
                ContextType // Called method context type
              )

/*@ In the past implementation, the non-empty qualifier of a static method call
    was moved to a separate statement in front of a method call using stmtAndExp().
    But since stmtAndExp() is incompatible with java intermediate form, we keep the non-empty qualifier
    as is even for static methods.
*/
rule [methodProcessArguments-Invoke-end]:
    methodLookupResult(RetT:Type, [ExpectedArgExps:KList], CT:ContextType)
    ~>  elabEnd('Invoke( 'Method('MethodName(QualK:K,, Name:Id)),, _ ))
    =>  elabEnd(
          cast(RetT,
            'Invoke(
              'Method(
                'MethodName(
                  #if CT ==K staticCT andBool isCastOfQThis(QualK) ==K true
                    #then typeOf(QualK)
                    #else QualK
                  #fi,,
                  Name:Id
                )
              ),,
              [ExpectedArgExps]
            )
          )
        )

/*Search for the correct method signature to use
when calling a given MethodName with the given argument types.
computes mapWrap(Sig -> MethodTV)*/
syntax KItem ::=  lookupSignature (
                Id,       // MethodName
                K,        // Computes into Types - argument types
                Map,        // methods environment - Map[sig -> Class]
                Bool,     // IsQ - whether the original method call was qualified
                MethodRef, // The best signature found so far
                              // or noValue if none found
                ClassType // QualClass - target type.
              )
              [strict(2,5)]

rule [lookupSignature-Main]:
    <k>
      lookupSignature(
        MethodName:Id,
        CallTs:Types,
        (sig(MethodName, SigTs:Types) |-> NewDecClass:ClassType => .Map) _:Map,
        IsQ:Bool,
        OldMethodRef:MethodRef
        => ifAux(
            andAux(
              andAux(
                subtypeList(CallTs, SigTs),
                #if OldMethodRef ==K noMethodRef
                  #then true

                  //An aux function here is required because OldMethodRef could be noMethodRef as well,
                  //for which there are no arg types
                  #else subtypeList(SigTs, getMethodRefArgTypes(OldMethodRef))
                #fi
              ),
              isAccessible( NewAccMode, NewCT, NewDecClass, IsQ, QualClass )
            ),
            methodRef(sig(MethodName, SigTs), NewDecClass),
            OldMethodRef
          ),
        QualClass:ClassType
      )
      ...
    </k>
    <classType> NewDecClass </classType>
    <methodSignature> sig(MethodName, SigTs) </methodSignature>
    <methodAccessMode> NewAccMode:AccessMode </methodAccessMode>
    <methodContextType> NewCT:ContextType </methodContextType>

syntax KItem ::= getMethodRefArgTypes ( MethodRef )   [function]
rule getMethodRefArgTypes( methodRef(sig(_, Ts:Types), _) ) => Ts
//todo mapItem
//rule [lookupSignature-SigDiscard]:
//    lookupSignature(
//      MethodName:Id,
//      _,
//      (sig(Name:Id, _) |-> _ => .) _:Map,
//      _,_,_
//    )
//when
//    Name =/=K MethodName

rule [lookupSignature-End]:
    lookupSignature(_,_, .Map,_, MethodRef:MethodRef, _) => MethodRef

/*@ Tests whether a method from a given class with a given AccessMode and ContextType
may be called from the current object environment*/
syntax KItem ::=  isAccessible (
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
      => orAux(
            andAux(
              orAux(CT ==K staticCT, IsQ ==K false::bool),
              subtype(
                ifAux(IsQ, CurrentClass, TargetClass),
                DeclaringClass
              )
            ),
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
