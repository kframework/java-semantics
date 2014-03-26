require "core-sorts.k"
require "core-classes.k"
require "process-type-names.k"
require "subtyping.k"
require "elaboration-core.k"
require "elaboration-method-invoke.k"
require "process-local-classes.k"

module ELABORATION-NEW-INSTANCE
    imports CORE-SORTS
    imports CORE-CLASSES
    imports PROCESS-TYPE-NAMES     //for toPackage()
    imports SUBTYPING
    imports ELABORATION-CORE
    imports ELABORATION-METHOD-INVOKE   // for lookupMethod, methodLookupResult
    imports PROCESS-LOCAL-CLASSES //for generateLocalEnvClassType, generateLocalEnvVarName

/*@ \subsubsection{Elaboration of 'NewInstance and 'QNewInstance} */

/*@ elab('NewInstance()) is strict in arguments 2 and 3 - class name and constrctor arguments.
    Constrctor arguments have to be heated if this class is anonymous.
    //todo conflict: local classes require constructor arguments to be heated by a custom rule
*/
rule customElabHeating('NewInstance, Ks:KList) => length(Ks) in (SetItem(2) SetItem(3))

rule [elab-NewInstance]:
    <k>
      elab(
        'NewInstance(Arg1:K,, Class:ClassType,, ActualArgsList:K,, 'None(.KList))
        =>  'QNewInstance(
              #if CT ==K staticCT
                #then noValue
                #else findQualifierOfType(CrntClass, EnclosingClass)
              #fi,,
              Arg1,, Class,, 'None(.KList),, ActualArgsList,, 'None(.KList)
            )
      )
      ...
    </k>
    <crntClass> CrntClass:ClassType </crntClass>
    <classType> Class </classType>
    <enclosingClass> EnclosingClass:ClassType </enclosingClass>
    <classContextType> CT:ContextType </classContextType>

/*@ elab('QNewInstance()) is strict in all its arguments except the class name (3) and anonymous body(6).
  - Argument (3) is heated if it is not a simple name but a precusros to a type
  - Argument (5) - consturctor arguments - is heated by a custom rule
  - Argument (6) is heated if it is 'None() - an empty body.
*/
rule customElabHeating('QNewInstance, Ks:KList,,KHole:K)
     => length(Ks,,KHole) in (SetItem(1) SetItem(2) SetItem(4))
        orBool (length(Ks,,KHole) ==K 3 andBool notBool isId(KHole) ==K true) //isId(KHole) => class not resolved yet
        orBool (length(Ks,,KHole) ==K 6 andBool KHole ==K 'None(.KList))      // KHole =/= 'None(_) => anon. class

//Resolve the class name with the help of qualifier type
rule [elab-QNewInstance-resolve-class]:
    elab('QNewInstance(elabRes(cast(QualClass:ClassType, _)),, _:K,,
      (Name:Id => resolveInnerClass(QualClass, Name)),,
    _))

/*@ Resolve the simple name of an inner class to a fully qualified class name in
    a qualified new like: o.new A(...);
*/
syntax K ::=  resolveInnerClass (
                ClassType,  //QualClass - the type of the qualifier
                Id          //Name - instantiated class simple name
              )

rule isElabNaked(resolveInnerClass(_,_)) => true

rule [resolveInnerClass]:
    <k>
      resolveInnerClass(QualClass:ClassType, Name:Id)
      => getClassIfExists(toPackage(QualClass), Name) ?? resolveInnerClass(BaseQualClass, Name)
      ...
    </k>
    <classType> QualClass </classType>
    <extends> BaseQualClass:ClassType </extends>

//@ If with the fiven package and name exists, return this class. Otherwise return noValue
syntax K ::= getClassIfExists ( PackageId, Id )

rule [getClassIfExists]:
    <k>
      getClassIfExists(Pack:PackageId, Name:Id)
      =>  #if Name in keys(NamesToClasses)
            #then getClassType(Pack:PackageId, Name:Id)
            #else noValue
          #fi
      ...
    </k>
    <namesToClasses>... Pack:PackageId |-> mapWrap(NamesToClasses:Map) ...</namesToClasses>

/*@ When <enclosingLocalEnv> is not empty (only possible for certain local classes),
  we add one more argument to the consturctor call - the local environment object. */
rule [elab-QNewInstance-local-augment-arguments]:
    <k>
      elab('QNewInstance(Qual:K,, Arg2:K,, Class:ClassType,, Arg4:K,,
          'ListWrap(Args:KList,, ( .KList => 'ExprName(generateLocalEnvVarName(generateLocalEnvClassType(Class))) ) ),,
          'None(.KList)
      ))
      ...
    </k>
    <classType> Class </classType>
    <enclosingLocalEnv> EnclosingLocalEnv:Map </enclosingLocalEnv>
when
    notBool isEmpty(EnclosingLocalEnv) ==K true
    andBool notBool getLastKListElement(Args) ==K 'ExprName(generateLocalEnvVarName(generateLocalEnvClassType(Class)))

rule [elab-QNewInstance-heat-arguments]:
    <k>
      (. => elab('ListWrap(Args:KList)))
      ~> elab('QNewInstance(Qual:K,, Arg2:K,, Class:ClassType,, Arg4:K,,
                         ('ListWrap(Args:KList) => CHOLE),,
                         'None(.KList)
         ))
      ...
    </k>
    <classType> Class </classType>
    <enclosingLocalEnv> EnclosingLocalEnv:Map </enclosingLocalEnv>
when
    isEmpty(EnclosingLocalEnv) ==K true
    orBool getLastKListElement(Args) ==K 'ExprName(generateLocalEnvVarName(generateLocalEnvClassType(Class)))

/*@ When <enclosingLocalEnv> is empty we lookup for the constructor signature the usual way*/
rule [elabEnd-QNewInstance-to-lookupMethod]:
    (. => lookupMethod(Class, false, getConsName(Class), resultListWrap(Args)))
    ~> elabEnd('QNewInstance(Qual:K,, Arg2:K,, Class:ClassType,, Arg4:K,, 'ListWrap(Args:KList),, 'None(.KList)))

/*@ All new instance creation expressions are converted into qualified ones - 'QNewInstance, during elaboration phase.
  For instance inner classes, the qualifier will be a valid expression for the qualifier. For other classes qualifier
  will be noValue. At this stage 'QNewInstance is wrapped in elabEnd.
*/
rule [elabEnd-QNewInstance-methodLookupResult-qualified-end]:
    <k>
      methodLookupResult(_, ExpectedParamExps:KList, instanceCT)
      ~> elabEnd('QNewInstance( cast(_, QualExp:K),, Arg2:K,, Class:ClassType,, Arg4:K,,
                                _:K,, 'None(.KList) ))
      => elabRes(cast(Class, 'QNewInstance( cast(EnclosingClass, QualExp:K),, Arg2,, getSimpleName(Class),,
                                            Arg4,, 'ListWrap(ExpectedParamExps),, 'None(.KList))))
      ...
    </k>
    <classType> Class </classType>
    <enclosingClass> EnclosingClass:ClassType </enclosingClass>

/*@ A 'QNewInstance with target noValue should be packed back into a NewInstance, for compatibility with Java.
    It will be desugared again into 'NewInstance at execution phase.
*/
rule [elabEnd-QNewInstance-methodLookupResult-to-NewInstance]:
    methodLookupResult(_, ExpectedParamExps:KList, instanceCT)
    ~> elabEnd('QNewInstance(noValue,, Arg2:K,, Class:ClassType,, Arg4:K,, _:K,, 'None(.KList)))
    => elabRes(cast(Class, 'NewInstance(Arg2,, Class,, 'ListWrap(ExpectedParamExps),, 'None(.KList))))

endmodule
