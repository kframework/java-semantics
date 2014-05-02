require "../common/java-doc.k"
require "../common/core-sorts.k"

//@ \section{Module METHOD-INVOKE-DEPENDENCIES}

module METHOD-INVOKE-DEPENDENCIES
    imports CORE-SORTS

syntax Cast ::= cast ( Type, K ) [strict] //strictness on 1-st arcument - for runtime produced terms

/*@Returns the top-level class enclosing this class*/
syntax K ::= getTopLevel ( ClassType )

syntax K ::=  staticInit (
                ClassType // Class - the ClassType to be initialized,
                          // or noClass if this term should be discarded.
              )

syntax K ::=  restoreMethContext (
                Bag                 //The content of <methodContext>
              )

syntax K ::= "arrayImplClass"                   [function]

syntax K ::=  getTypes (
                KListWrap     //[...,, KResult,, ...] - a list of source expressions
              )
              [function]

syntax K ::= typeOf ( K )                           [function]

syntax K ::= "stringClass"                              [function]

syntax K ::=  sl (
                K,  //K - rest of computation
                Bag //MethContext - the content of <methodContext>
              )

syntax K ::= eqAux ( K, K )                  [seqstrict]

syntax KRListWrap ::= "kr" "[" KList "]"

syntax K ::= getPackage ( K )               [strict]

configuration
    <T>
      <threads color="GreenYellow">
        <thread multiplicity="*" color="GreenYellow">
          <k color="Green"> $COMMAND:K </k>

          <stack color="Green"> .List </stack>

          //! \smallskip
          <br/>

          /*The execution context of the current method - local names environment, return type,
            context type and current object.*/
          <methodContext color="Orange">

            //The map from local vars to their location in the store. Also includes outer local vars, for local classes.
            <env color="Crimson"> .Map </env>

            //current class during all phases, including early preprocessing
            <crntClass color="DarkOrange"> noClass </crntClass>

            <location color="DarkOrange"> .K </location>
          </methodContext>

        </thread>
      </threads>

      <br/>
      <br/>

      <classes color="Red">
        <class multiplicity="*" color="Red">

          <cphDiscovered color="Yellow">
            //sort ClassType. Contains the fully qualified class name.
            <classType color="Red"> .K </classType>

            //Either classMetaT or interfaceMetaT. Used in many semantics phases, including execution.
            <classMetaType color="Maroon"> .K </classMetaType>

            //The major phase of <class> lifecycle. See ClassPhase definition.
            <classPhase color="Maroon"> .K </classPhase>

          </cphDiscovered>

          <br/>

          //Used by object instantiation
          //noClass if this is a top-level class,
          //ClassType of the enclosing class otherwise
          <enclosingClass color="DarkGoldenrod"> noClass </enclosingClass>

          <cphDecs color="Yellow">

            //The base class, or noClass for interfaces and Object.
            <extends color="SpringGreen"> .K </extends>

          </cphDecs>

          <br/>

          /*Signatures of methods accessible to this class (both declared and inherited)
            Map[Sig -> Class]
            Used in elaboration of method calls.*/
          <methods color="Blue"> .Map </methods>

          <br/>

          /*All methods declared in this class.
            Used in elaboration of method calls.*/
          <methodDecs color="Blue">

            <methodDec multiplicity="*" color="Blue">

              //Method signature, of type Signature
              <methodSignature color="Blue"> .K </methodSignature>

              //Method params
              <methodParams color="Blue"> [.KList] </methodParams>

              //Method body
              <methodBody color="Blue"> .K </methodBody>

              <br/>
              <methodAccessMode color="Blue"> .K </methodAccessMode>

              //Either staticCT or instanceCT
              <methodContextType color="Blue"> .K </methodContextType>

            </methodDec>
          </methodDecs>

        </class>
      </classes>
    </T>

endmodule

module JAVA-SYNTAX
// No syntax needed, we are using an external parser.
endmodule

//@ \section{Module METHOD-INVOKE-LATEX}

module METHOD-INVOKE-LATEX
    imports CORE-SORTS
    imports METHOD-INVOKE-DEPENDENCIES
    imports JAVA-SYNTAX

syntax KLabel ::= "'Invoke"

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

/*@ \begin{markdown}
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
\end{markdown} */
context 'Invoke('Method('MethodName(_:KResult,, Name:Id )),, [Ks:KList,, HOLE,,_] )
when
    isKResult(Ks)

/*@ \begin{markdown}
During the third step of method invocation the second argument of the production is replaced with the auxiliary data
  structure methodInfo(). This data structure contains the information required to choose the right method lookup
  strategy at the next step. The production methodInfo() contains the following arguments:

  - Method signature Sig
  - Qualifying class QualC of the method invocation, e.g. the compile-time type of the qualifier.
  - The meta type of QualC - MetaT. It may have one of the two values - class or interface.
  - DecC - declaring class, the class where the method was actually declared, as observed by QualT.
    E.g. the most derived class in QualC hierarchy where there is a declaration of a method with signature Sig.
  - ContextT - the context type of the method. Either static, for static methods, or instance for non-static methods.
  - Acc - access modifier (private, package, protected or public). For the purpose of uniformiti we use the modifier
    package when no access modifier is provided.

All the information stored in methodInfo() is static. In K-Java we already have
  this information computed, but it is stored in various cells inside <class> and <classDec>.
  The rules from step 3 simply load the relevant informaton from configuration
  cells to methodInfo() arguments.
\end{markdown} */
syntax K ::=  methodInfo(
                Signature,    //Sig - method signature
                RefType,      //QualC - qualifier type, not necessarily class
                ClassMetaType,//MetaT - The either classCMT or interfaceCMT for the qualifier type
                RefType,      //DecC - method declaration class - the class referred by the signature in <methods>
                                // for arrays - it remains noClass
                                // this argument is mostly used to compute the context type
                ContextType,  //ContextT - method context type - instance or static
                                //for arrays - instanceCT
                AccessMode    //Acc - The access mode of the method as seen by the qualifying type
              )

/*@
The first rule from step 3 rewrites the method name into a methodInfo() whose first argument is the method signature.
  The auxiliary function getTypes() computes the list of types from the list of parameter declarations. The second
  argument of methodInfo is also computed at this step - it is the type of the qualifier. The rest of the arguments
  are filled in with default values. They will be rewritten into actual values by the following rules.

This rule also have a side condition that checks whether parameters were evaluated to final values. The side
  condition ensures that this rule is executed only when the first two steps of method invocation were completed.
  Because the following rules may match only after this rule was matched, we have to make this check only once - in
  this rule.
*/
rule [Invoke-compute-methodInfo-Signature]:
    'Invoke('Method('MethodName(
      Qual:KResult,,
      (Name:Id => methodInfo(sig(Name, getTypes([Args])), typeOf(Qual), .K,.K,.K,.K))
      )),, [Args:KList]
    )
when
    isKResult(Args)

/*@
The second rule for method invocation loads MetaT and DecC. It requires Sig and QualC computed by the previous rule.
*/
rule [Invoke-compute-methodInfo-DecC]:
    <k>
      'Invoke('Method('MethodName(
        Qual:KResult,,
        methodInfo(Sig:Signature, QualC:ClassType, .K => MetaT, .K => DecC, _,_)
      )),, _)
      ...
    </k>
    <classType> QualC </classType>
    <classMetaType> MetaT:ClassMetaType </classMetaType>
    <methods>... Sig |-> DecC:ClassType ...</methods>

/*@ \begin{markdown}
There is one case that is not covered by the previous rule - the case when the cell <methods> does not have a key
  equal to Sig. This is possible in one of the following situations:

  - Qualifying type is an interface.
  - Qualifying type is an abstract class. The called method is inherited from an interface but is not declared neither
    in this class nor in its base classes.

In both cases the method is an abstract method in the class QualT. For this case DecC cannot be computed, but we know
  for sure that ContextT for an abstract method is instance. Also, because the method was declared in an interface,
  it is certainly public.
\end{markdown} */
rule [Invoke-compute-methodInfo-unmapped-method-ContextType]:
    <k>
      'Invoke('Method('MethodName(
        Qual:KResult,,
        methodInfo(Sig:Signature, QualC:ClassType, .K => MetaT, _, .K => instanceCT, .K => public)
        )),, _)
      ...
    </k>
    <classType> QualC </classType>
    <classMetaType> MetaT:ClassMetaType </classMetaType>
    <methods> Methods:Map </methods>
when
    notBool Sig in keys(Methods)

/*@
The last rule of step 3 loads ContextT and Acc. It requires DecC, so this rule may only match after
  the second rule for methodInfo().
*/
rule [Invoke-compute-methodInfo-ContextType]:
    <k>
      'Invoke('Method('MethodName(
        Qual:KResult,,
        methodInfo(Sig:Signature, QualC:ClassType, _, DecC:ClassType, .K => ContextT, .K => Acc)
      )),, _)
      ...
    </k>
    <classType> DecC </classType>
    <methodSignature> Sig </methodSignature>
    <methodContextType> ContextT:ContextType </methodContextType>
    <methodAccessMode> Acc:AccessMode </methodAccessMode>

/*@ \begin{markdown}
In the fourth step of method invocation algorithm the actual method declaration is chosen. This step starts once all
  the fields of methodInfo() were filled in (where possible). The rules of this step rewrite methodInfo() into
  methodRef() - another auxiliary data structure.
The production methodRef() is a reference to a method declaration. It contains two fields - Sig and DecC - the
  signature and the declaration class. The implementation class is the class that contains the actual method
  declaration to be invoked. Since we already know the signature, this phase amounts to computing DecC.

  This step contains different rules for the following cases:

  - Static method (JLS \$15.12.4.4 paragraph 2)
  - Instnace method with target being null (JLS \$15.12.4.4 paragraph 3)
  - Instance method with non-null target, private method (JLS \$15.12.4.4 paragraph 4)
  - Instance method with non-null target, access mode is protected or public. This also includes qualifying type
    being interface. (JLS \$15.12.4.4 paragraph 6 and point 1)
  - Instance method with non-null target, access mode is package (no dedicated mention in JLS \$15.12.4.4)
  - [Skip] Target value is array or string.

The method below is for the first case. If the method is static, then the declaring type DecC is the qualifying type.
  The qualifier is discarded by rewritting it into noValue.
\end{markdown} */
rule [Invoke-methodInfo-static]:
    'Invoke(
      'Method('MethodName(
        (_:KResult => noValue),,
        ( methodInfo(Sig:Signature, QualC:ClassType, classCMT, DecC:ClassType, staticCT, _)
          => methodRef(Sig, DecC) )
      )),,
      [Args:KList]
    )

/*@
If the qualifier value is null and ContextT is instance, then NullPointerException is thrown and method invocation
  expression is discarded. It is only at this point that we should check the qualifier whether it is null or not.
  If ContextT is static, then the previous rule will match, and no exception will be thrown.
*/
rule [Invoke-methodInfo-instance-on-null]:
/*  [Impl] Qualifier type could be either object or array.
    We cannot move method invocation on null logic to invokeImpl, because
    invokeImpl needs an actual methodRef, and we cannot produce a methidRef if our qualifier object is null.
*/
    'Invoke( 'Method('MethodName( null::_,, methodInfo(_,_,_,_, instanceCT, _) )),, [_] )
    =>  'Throw('NewInstance(
          'None(.KList),,
          class String2Id("java.lang.NullPointerException"),,
          [ null::stringClass ],,
          'None(.KList)
        ))

/*@
The logic for private instance methods is the same as for static methods, with the difference that the qualifier is
  not discarded.
*/
rule [Invoke-methodInfo-instance-private]:
    'Invoke(
      'Method('MethodName(
        _:ObjectRef::_,,
        ( methodInfo(Sig:Signature, _, classCMT, DecC:ClassType, instanceCT, private)
          => methodRef(Sig, DecC) )
      )),,
      [Args:KList]
    )

/*@
If the method is protected or public, then we should call the version of the method visible to the runtime type of
  the qualifying object (ObjC).
  This case also covers qualifying type interface, since interface methods are always public.
  The right method will always be the one referred by the signature Sig in the cell <methods> associated with the
  actual object class. This is because the unfolding phase populates <methods> with the union of methods inherited
  from the base class and methods declared in the current class, the latter overriding the former.
  The variable DecC is the class where the right method version is declared.
*/
rule [Invoke-methodInfo-instance-protected-or-public]:
    <k>
      'Invoke('Method('MethodName(
          objectRef( _, ObjC:ClassType )::_,,
          ( methodInfo(Sig:Signature, _, _,_, instanceCT, Acc:AccessMode)
            => methodRef(Sig, DecC) )
        )),,
        [Args:KList]
      )
      ...
    </k>
    <classType> ObjC </classType>
    <methods>... Sig |-> DecC:ClassType ...</methods>
when
    Acc ==K protected orBool Acc ==K public

/*@ \begin{markdown}
The most complex case is for instance methods with package access mode. The precise semantics of overriding for all
  access modes is defined in JLS \$8.4.6.1:

An instance method derivedM declared in a class Derived overrides another method with the
  same signature, baseM, declared in class Base iff both:

  1. Derived is a subclass of Base.
  2. Either
     a. baseM is non-private and accessible from Derived, or
     b. derivedM overrides a method middleM, middleM distinct from baseM and derivedM,
      such that middleM overrides baseM

In the case 2b the overriding relationship cannot be inferred based on the content of classes Base and Derived alone.
  Instead, we have to analyze the content of each class in between in the inheritance chain. This case is specifically
  needed for package access mode.

The rule for package access mode delegates searching for the right method declaration to the auxiliary function
  lookupPackageMethod. The function takes 3 arguments:

  - method signature Sig
  - the list of classes in the inheritance chain between the qualifying class QualC and the actual object class ObjC.
    This list is produced by getClassChain()
  - the third argument represents the declaring class of the best method found so far.
    It is initialized with .K.

\end{markdown} */
rule [Invoke-methodInfo-instance-package]:
    <k>
      'Invoke('Method('MethodName(
          objectRef( _, ObjC:ClassType )::QualC:ClassType,,
          ( methodInfo(Sig:Signature, QualC:ClassType, classCMT, _, instanceCT, package)
            => lookupPackageMethod( Sig, getClassChain(QualC, [ObjC]), noClass)
          )
        )),, [Args:KList]
      )
      ...
    </k>
    <classType> QualC </classType>
    <methods>... Sig |-> DecC:ClassType ...</methods>

/*@
Before the evaluation of lookupPackageMethod may begin, the term lookupPackageMethod() have to be heated to the top
  of computation. The side condition in the context rule below ensured that the second argument of method call
  expression is heated ony if it contains a term lookupPackageMethod(). If it have other forms,
  such as the method name or methodInfo(), it won't be heated.
*/
context 'Invoke('Method( 'MethodName( _:K,, HOLE ) ),, _)
when
    getKLabel(HOLE) ==KLabel 'lookupPackageMethod

syntax K ::=  getClassChain( ClassType,  //MostBaseClass
                                        KListWrap   //[MostDerivedClass] at beginning, gradually accumulates
                                                      //the list of classes
              )

syntax K ::=  lookupPackageMethod (
                Signature,  //sig(Name, SigTL) - Method signature
                KRListWrap, //computes into kr[...,, Class,, ...], elements of type ClassType,
                              // from base to derived.
                              // To be processed from base to derived until while the chain is not empty
                ClassType   //The class with the best method declaration with signature Sig found so far,
                              //initialized with noClass
              )
              [strict(2,3)]

/*@
The rules for lookupPackageMethod() are based on the following two properties of the configuration:

\begin{itemize}
  \item if the cell <methods> for a particular class contains a key Sig, then <methods> for all classes derived from it
    will contain the key Sig.
  \item if a particular class contain a method declaration with signature Sig acces mode Acc, then all declarations
    of Sig in derived classes (that are not necessarily overriding!) will have the access mode either Acc or a value
    wider than Acc.
\end{itemize}

The first property is ensured by the unfolding algorithm. Because <methods> of a derived class inherit all the <methods>
  of the direct base class, the map <methods> may only grow from base classes to derived. The second property is ensured
  by restrictions on overriding specified in JLS \$8.4.8.3: "The access modifier (\$6.6) of an overriding or hiding
  method must provide at leastas much access as the overridden or hidden method".

The search for the right package method declaration is performed from the base-most class in the chain (the left-most
  one) to the most derived one. Every rule matches and deletes the leftmost class in the class chain (CurrentC),
  and possibly rewrites the third argument into the current class.
The first rule matches when there is no declaring class yet (third argument is .K, the initial case).
*/
rule [lookupPackageMethod-layer-first-dec-found]:
    <k>
      lookupPackageMethod(
        Sig:Signature,
        kr[ (CurrentC:ClassType => .KList),, _ ],
        noClass => DecC
      )
      ...
    </k>
    <classType> CurrentC </classType>
    <methods>... Sig |-> DecC:ClassType ...</methods>

/*@
The second rule matches when we already found a declaring class (OldDecC) and the current class CurrentC have another
  method declaration with the right signature. The presence of a Sig declaration inside CurrentC is identified by the
  match <class><classType> CurrentC </classType> <methods>... Sig |-> CurrentC ...</methods> </class>,
  according to the definition of <methods>.
In this case the declaring class is updated to CurrentC only if the method in CurrentC overrides the previously found
  method from OldDecC. The rules for overriding depend on three arguments: The base class OldDecC,
  the derived class CurrentC, both containing a method declaration with the same signature Sig,
  and the access mode Acc of the method from OldDecC. access mode Acc of the method Sig declared in OldDecC. These rules
  are implemented by function isOverridden().
*/
rule [lookupPackageMethod-new-method]:
    <k>
      lookupPackageMethod(
        Sig:Signature,
        kr[ (CurrentC:ClassType => .KList),, _ ],
        OldDecC:ClassType
        =>  'If(
              isOverridden( OldDecC, Acc, CurrentC ),,
              CurrentC,,
              OldDecC
            )
      )
      ...
    </k>
    <class>
      <classType> OldDecC </classType>
      <methodSignature> Sig </methodSignature>
      <methodAccessMode> Acc:AccessMode </methodAccessMode>
      ...
    </class>
    <class>
      <classType> CurrentC </classType>
      <methods>... Sig |-> CurrentC:ClassType ...</methods>
      ...
    </class>

/*@
The third rule represents the case when CurrnetC chain don't contain method declarations with signature
  Sig. This case is identified by the side condition CurrentC =/=K DecC. Indeed, the two classes are different only
  when the entry Sig |-> DecC in <methods> was inherited rather than produced by a method in CurrnetC.
*/
rule [lookupPackageMethod-no-new-method]:
    <k>
      lookupPackageMethod(
        Sig:Signature,
        kr[ (CurrentC:ClassType => .KList),, _ ],
        _
      )
      ...
    </k>
    <classType> CurrentC </classType>
    <methods>... Sig |-> DecC:ClassType ...</methods>
when
    CurrentC =/=K DecC

/*@
The last rule matches when the chain of classes stored in the first argument remains empty. It rewrites the whole
  lookupPackageMethod() into a reference to the method that have to be invoked.
*/
rule [lookupPackageMethod-end]:
    lookupPackageMethod(Sig:Signature, kr[.KList], DecC:ClassType ) => methodRef(Sig, DecC)

/*@
The method is overridden if either:

\begin{itemize}
  \item Acc is protected or public
  \item Acc is package and BaseC and SubC are declared in the same package (JLS \$6.6)
\end{itemize}
*/
syntax K ::=  isOverridden (
                ClassType,  //BaseC
                AccessMode, //BaseAcc
                ClassType   //SubC
              )
              [strict]

rule isOverridden(_, public,    _) => true
rule isOverridden(_, protected, _) => true

rule isOverridden(BaseC:ClassType, package, SubC:ClassType)
    => eqAux(getPackage(getTopLevel(BaseC)), getPackage(getTopLevel(SubC)))

rule isOverridden(_, private, _) => false

/*@
The central rule of method invocation is matched when the second argument of method call expression reaches the form
  methodRef(). This rule performs the following operations:

\begin{itemize}
  \item saves the rest of computation (RestK) and the content of <methodContext> as a new entry of the cell <stack>
    This data is restored back by the rules for return statement.
  \item Initializes the new method context.

  \begin{itemize}
    \item The local variable environment <env> is emptied
    \item current class <crntClass> is initialized to the class declaring the method
    \item object location <location> is initialized to the location of the qualifier object for instance methods,
      or .K for static methods. The extraction of the location from the qualifier value is performed by the
      function getOId().
  \end{itemize}

  \item rewrites the method call expression into a sequence of four terms:

  \begin{itemize}
    \item static initialization of the qualifying class
    \item parameters initialization
    \item actual method body
    \item a return statement with no arguments after the method body.
  \end{itemize}

\end{itemize}

The function staticInit() triggers static initialization of the qualifying class, if this class was not initialized yet.
  Repeated calls of this function have no effect. Is required just for static methods and is described in JLS \$12.4.
  For an instance method call, the qualifying class will always be initialized already,
  so staticInit() will have no effect.

The function initParams() rewrites each parameter declaration into two statements. First is a local variable
  declaration with that parameter name. The second is an assignment to that variable of the actual argument value.

The return statement at the end ensures that there is a return statement on every execution path of the method. The
  statement will only be useful for methods with return type void, as methods returning a value are required by JLS
  to have an appropriate return statement on every return path.
*/
rule [Invoke-methodRef]:
    <k>
      'Invoke('Method('MethodName(
          Qual:KResult,,
          methodRef(Sig:Signature, DecC:ClassType)
        )),,
        [Args:KList]
      ) ~> RestK:K
      => staticInit(DecC) ~> initParams([Params], [Args]) ~> Body ~> 'Return('None(.KList))
    </k>
    <stack>
      . => ListItem(sl(RestK, MethodContext))
      ...
    </stack>
    <methodContext>
      MethodContext:Bag
      =>  <env> .Map </env>
          <crntClass> DecC </crntClass>
          <location> getOId(Qual) </location>
    </methodContext>

    <classType> DecC </classType>
    <methodSignature> Sig </methodSignature>
    <methodParams> [Params:KList] </methodParams>
    <methodBody> Body:K </methodBody>
when getKLabel(Body) =/=KLabel 'NoMethodBody

syntax K ::= getOId( K )              [function]
rule getOId( objectRef(OId:Int,_)::_ ) => OId
rule getOId( noValue ) => noValue

/*@ [Skip] Binds a list of formal parameters to their values. Used by method calls and try-catch.
*/
syntax K ::= initParams ( KListWrap, // [...,, 'Param(...),, ...] - parameter declarations
                          KListWrap  // [...,, KResult,, ...] - values
                        )

rule [initParams]:
    initParams(['Param(_:K,, T:Type,, X:Id),, RestP:KList], [TV:TypedVal,, RestV:KList])
    => 'LocalVarDec(.K,, T:Type,,['VarDec(X)])
      ~> 'ExprStm('Assign('ExprName(X),, cast(T, TV:TypedVal)))
      ~> initParams([RestP], [RestV])

rule [initParams-end]:
    initParams([.KList], [.KList]) => .K
        [structural]

syntax KLabel ::= "'Param"

endmodule
