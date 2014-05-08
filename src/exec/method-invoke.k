module METHOD-INVOKE
    imports CORE-SORTS
    imports CORE-FUNCTIONS
    imports SYNTAX-CONVERSIONS
    imports STATIC-INIT //for staticInit()

/*@
\newpage
\section{Module METHOD-INVOKE}

\subsection{Background}

In this section we present the fragment of configuration used by runtime method
  invocation. The figure below contains the cells and their sort.

\vspace{3ex}

$
\kall{T}{\begin{array}{@{}c@{}}
	\kall[GreenYellow]{threads}{
		\kall[GreenYellow]{thread*}{
		\begin{array}{@{}c@{}}
			\kall[Green]{k}{K}
			\mathrel{}\kall[Green]{stack}{ \ List \left[ \ (K, Bag) \ \right] \ }
			\mathrel{}\\\mathrel{}\kall[Orange]{methodContext}{
				\kall[Crimson]{env}{ Map \left[Id \mapsto Int \right] }
				\mathrel{}\kall[DarkOrange]{crntClass}{ ClassType }
				\mathrel{}\kall[DarkOrange]{location}{ Int }
			}
		\end{array}
		}
	}
	\mathrel{}\\\mathrel{}\\\mathrel{}\
  \kall[Red]{classes}{
		\kall[Red]{class*}{\begin{array}{@{}c@{}}
			\kall[Red]{classType}{ ClassType }
			\mathrel{}\kall[Maroon]{classMetaType}{ ClassMetaType }
			\mathrel{}
				\mathrel{}\\\mathrel{}\
				\kall[Blue]{methods}{ Map \left[Signature \mapsto ClassType \right] }
				\mathrel{}\\\mathrel{}\kall[Blue]{methodDecs}{
					\kall[Blue]{methodDec*}{\begin{array}{@{}c@{}}
						\kall[Blue]{methodSignature}{ Signature }
						\mathrel{}\\\mathrel{}\
						\kall[Blue]{methodParams}{ \ List \left[ \ MethodParam \ \right] \ }
						\mathrel{}\\\mathrel{}\kall[Blue]{methodBody}{ K }
						\mathrel{}\\\mathrel{}\
						\kall[Blue]{methodAccessMode}{ AccessMode }
						\mathrel{}\\\mathrel{}\kall[Blue]{methodContextType}{ ContextType }
					\end{array}
					}
				}
		\end{array}
		}
	}
\end{array}
}
$

\vspace{3ex}

The cell <k> stores the current computation. The cell <stack> is a list of pairs of the
  form (K, Bag), and represents the standard method call stack. The first element
  represents the remaining computation an the moment the method was called. The second
  element of sort Bag represents the content of cell <methodContext> at the moment
  of method call.

The cell <class> contains various sub-cells holding the content of that class. The
  first cell in <classType> of sort ClassType that holds the fully qualified class name.
  This cell serves as a key in all rules that match a fragment of a <class>. The value
  in the cell <classMetaType> is either "class" or "interface". From now on we will
  refer to both meta types as classes, referring to metatype value when distinction
  is necessary. The next cell is <methods>. This is a map from method signatures to
  classes where the respective signatures are declared. It contains not only the methods
  declared in this class, but also those inherited from the base class, but not from the
  base interfaces. By "inherited" here we mean all the methods contained in the cell
  <methods> of the base class that were not overridden by a method declaration with
  the same signature in the current class. This definition is different from the
  inheritance rules in JLS \$8.4.6, although the difference is only relevant at the
  elaboration time.

The cell <methodDec> represents a method declared inside the current class. The subcell
  <methodSignature> is the key for accessing other cells for this declaration. The other
  cells are the parameters, the body, the access mode (private, public etc.) and the
  context type (either instance or static).

In order for strictness and context rules to work we have to define some K productions
  as KResult. The most common form of KResult in Java are the following:

\vspace{3ex}

\begin{syntaxBlock}{\nonTerminal{\sort{KResult}}}
\syntax{{\nonTerminal{\sort{ClassType}}}}{}
\syntaxCont{{\nonTerminal{\sort{TypedVal}}}}{}
\syntaxCont{{\nonTerminal{\sort{KListWrap}}}}{}
\end{syntaxBlock}

The first represents a class. Second is a typed value, the result of evaluation of any
  expression. Typed values that relevant for method invocation may have one of the
  following forms:

\vspace{3ex}

\begin{syntaxBlock}{\nonTerminal{\sort{TypedVal}}}\syntax{{}\terminal{objectRef}
  ({{\nonTerminal{\sort{Int}}}},{{\nonTerminal{\sort{ClassType}}}}){}
  \terminal{::}{{\nonTerminal{\sort{ClassType}}}}}{}\syntaxCont{{}\terminal{null}
  {}\terminal{::}{{\nonTerminal{\sort{ClassType}}}}}{}
\end{syntaxBlock}

Another form of KResult is a list of K elements wrapped into square brackets:

\vspace{3ex}

\begin{syntaxBlock}{\nonTerminal{\sort{KListWrap}}}
  \syntax{[{{\nonTerminal{\sort{KList}}}}]}{}
\end{syntaxBlock}

This production is required whenever we have to store a list of unknown size, for example
  the list of arguments of a method. For the sake of simplicity we we will also
  consider \dotCt{K} - the unit element of K to be KResult. The value \dotCt{K} is often
  used in auxiliary functions as a placeholder until some actual value is computed.


\subsection{Introduction}
\begin{markdown}
An elaborated method invocation expression may have one of the following forms:

  - An invocation of a static method qualified by its class: Class.f(args)
  - An invocation of a static method qualified by an expression producing an object:
    o.f(args). Even if the method is
    static we cannot simply replace the qualifier with its compile-time type at
    elaboration phase, because the qualifier
    expression still have to be evaluated and might produce side effects.
  - An invocation of an instance method qualified by a class reference: o.f(args)
  - An invocation of an instance method qualified by an interface reference: i.f(args)
  - The qualifier of an instance method may also be a string or an array expression,
    and those cases require special rules in the semantics.

The evaluation of the method invocation expression consists from 5 steps outlined below.
  Those steps, unless otherwise specified, are common to all the method call forms
  enumerated above.

  - Evaluation of the qualifier expression
  - Evaluation of method arguments
  - Computation of static method information
  - Locating the actual method declaration to be invoked
  - Actual method invocation.

In JLS runtime semantics of method invocation is described in \$15.2.4. Although there
  is some correspondence between the steps in our semantics and the steps in JLS, it is
  generally not one-to-one. JLS description of method invocation consists of the
  following 5 steps. For each step we give the relevant chapter of the JLS and the step
  in our semantics.

  - Compute the target reference (\$15.12.4.1), semantics step 1
  - Evaluate arguments (\$15.12.4.2), semantics step 2
  - Check the accessibility of the method to be invoked (\$15.12.4.3), no semantics
  - Locate the actual method code to invoke (\$15.12.4.4), semantics step 4
  - Actual method invocation, semantics step 5.

There are at least the following reasons why there is no close correspondence between
  JLS and K-Java:

  - JLS semantics describes not only the execution of correct java programs, but also
    runtime checks that have to be performed to ensure the consistency of the bytecode,
    and errors that have to be thrown once this consistency is violated. This is the case
    for \$15.12.4.3, that don't need a correspondent in K-Java.
  - Because K-Java operates directly over the source code of Java, with no other
    preprocessing than the unfolding phase, it carries less static information than
    the bytecode. For this reason some static information needs to be computed in K-Java
    each time a method is invoked. This is why semantics step 3 is needed. As we will
    see below, rules for this step are straightforward and consist of loading the right
    data from the right cells int an auxiliary data structure.
  - Although JLS avoids references to bytecode as much as possible, sometimes it contains
    references to features specific to bytecode. For a method call in JLS have an
    invocation mode, that might be static, nonvirtual, virtual, interface or others.
    Since this invocation mode is computed at compile-time, JLS runtime semantics is
    described separately for each invocation mode. In K, since we don't have such a
    classification by invocation modes, we often have less cases.
  - Lastly, K abstractions allow us to have much less particular cases in Java than in
    JLS. A comparison between the number of particular cases for K-Java method invocation
    and JLS will be given at the end of this section. We will also highlight the
    particular K abstractions that made possible the reduction of the number of cases.

The details related to each step of are described in the semantics below, above each
  rule and auxiliary construct. For each rule we will also refer to the respective
  JLS page, if there is a correspondence.
\end{markdown}
*/

/*@
\subsection{Evaluation of the qualifier}

Evaluation of the method invocation qualifier (JLS \$15.12.4.1) requires just one
  context rule. The qualifier is the first argument of the method invocation
  production. It just needs to be heated, and after evaluation the actual value
  will be cooled back in the same place. If the qualifier is a class instead of an
  expression, then this rule will have no effect. A type in K-Java is subsorted to
  KResult, consequently it doesn't need to be heated.
*/
context HOLE. Name:Id (_)

//totest model check - expressions should be evaluated from left to right. A test for this
//exists, but is unable to expose the problem. This rule have to be made "transition"
//somehow.
//totest - if qualifier evaluates to null, NullPointerException should be thrown after
//the evaluation of the arguments

/*@
\subsection{Evaluation of the arguments}

\begin{markdown}
The next step is the evaluation of the arguments (JLS \$15.12.4.2). This also requires
  just one context rule. The whole list of arguments is the third argument of method
  invocation production, but in order to evaluate the arguments we need to heat them
  one by one. JLS enforces the following conditions on the timing of arguments evaluation:

  - Arguments have to be evaluated after the qualifier was evaluated. This is ensured
    by checking that the qualifier is of sort KResult at the moment when arguments are
    heated.
  - Arguments are evaluated left to right. To ensure this we add a side condition that
    checks that all the arguments before the one being heated (if any) are already of the
    sort KResult.

Arguments have to be evaluated even in the case when the qualifier is null. On the other
  hand, JLS states that once the evaluation of the qualifier or any of the arguments
  completes abruptly, the whole method invocation expression completes abruptly for the
  same reason. K-Java don't need any special rules to cover those cases. The small number
  of rules related to throw statement ensure correct exception propagation from any
  context.
\end{markdown}
*/
context _:KResult. Name:Id ([Ks:KList,, HOLE,,_])
when
    isKResult(Ks)

/*@
\subsection{Loading method information}

\begin{markdown}
During the third step of method invocation the second argument of the production is replaced with the auxiliary data
  structure methodInfo(). This data structure contains the information required to choose the right method lookup
  strategy at the next step. The production methodInfo() contains the following arguments:

  - Method signature Sig
  - Qualifying class QualC of the method invocation, e.g. the compile-time type of the qualifier.
  - The meta type of QualC - MetaT. It may have one of the two values - class or interface.
  - DecC - declaring class, the class where the method was actually declared, as observed by QualT.
    E.g. the most derived class in QualC hierarchy where there is a declaration of a method with signature Sig.
  - ContextT - the context type of the method. Either static, for static methods, or instance for non-static methods.
  - Acc - access modifier (private, package, protected or public). For the purpose of uniformity we use the modifier
    package when no access modifier is provided.

All the information stored in methodInfo() is static. In K-Java we already have
  this information computed, but it is stored in various cells inside <class> and <classDec>.
  The rules from step 3 simply load the relevant information from configuration
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
    Qual:KResult
      .(Name:Id => methodInfo(sig(Name, getTypes([Args])), typeOf(Qual), .K,.K,.K,.K))
      ([Args:KList])
when
    isKResult(Args)

/* Impl: We could combine this rule with the previous one by using getLookupTargetType(), but we'll keep it this way
    to keep the core part of method invocation separate from the non object-related part. */

/*@
The second rule for method invocation loads MetaT and DecC. It requires Sig and QualC computed by the previous rule.

*/
rule [Invoke-compute-methodInfo-DecC]:
    <k>
      Qual:KResult
        . methodInfo(Sig:Signature, QualC:ClassType, .K => MetaT, .K => DecC, _,_)
        ([Args:KList])
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
      Qual:KResult
        . methodInfo(Sig:Signature, QualC:ClassType, .K => MetaT, _, .K => instanceCT, .K => public)
        ([Args:KList])
      ...
    </k>
    <classType> QualC </classType>
    <classMetaType> MetaT:ClassMetaType </classMetaType>
    <methods> Methods:Map </methods>
when
    notBool Sig in keys(Methods)

/*@
The last rule of step 3 loads ContextT and Acc. It requires DecC, so this rule may only match after the second rule for methodInfo().
*/
rule [Invoke-compute-methodInfo-ContextType]:
    <k>
      Qual:KResult
        . methodInfo(Sig:Signature, QualC:ClassType, _, DecC:ClassType, .K => ContextT, .K => Acc)
        ([Args:KList])
      ...
    </k>
    <classType> DecC </classType>
    <methodSignature> Sig </methodSignature>
    <methodContextType> ContextT:ContextType </methodContextType>
    <methodAccessMode> Acc:AccessMode </methodAccessMode>

/*@
\subsection{Lookup method declaration}

In the fourth step of method invocation algorithm the actual method declaration is chosen. This step starts once all
  the fields of methodInfo() were filled in (where possible). The rules of this step rewrite methodInfo() into
  methodRef() - another auxiliary data structure.
The production methodRef() is a reference to a method declaration. It contains two fields - Sig and DecC - the
  signature and the declaration class. The implementation class is the class that contains the actual method
  declaration to be invoked.

\vspace{3ex}

\begin{syntaxBlock}{\nonTerminal{\sort{KResult}}}\syntax{{}\terminal{methodRef}({{\nonTerminal{\sort{Signature}}}},{{\nonTerminal{\sort{RefType}}}})}{}
\end{syntaxBlock}

\begin{markdown}
Since we already know the signature, this phase amounts to computing DecC. This step contains different rules for the following cases:

  - Static method (JLS \$15.12.4.4 paragraph 2)
  - Instnace method with target being null (JLS \$15.12.4.4 paragraph 3)
  - Instance method with non-null target, private method (JLS \$15.12.4.4 paragraph 4)
  - Instance method with non-null target, access mode is protected or public. This also includes qualifying type
    being interface. (JLS \$15.12.4.4 paragraph 6 and point 1)
  - Instance method with non-null target, access mode is package (no dedicated mention in JLS \$15.12.4.4)

<!--- - Target value is array or string. -->

The method below is for the first case. If the method is static, then the declaring type DecC is the qualifying type.
  The qualifier is discarded by rewriting it into .K .
\end{markdown}
*/
rule [Invoke-methodInfo-static]:
    (_:KResult => noValue)
      . ( methodInfo(Sig:Signature, QualC:ClassType, classCMT, DecC:ClassType, staticCT, _) => methodRef(Sig, DecC) )
      ([Args:KList])

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
    null::_ . methodInfo(_,_,_,_, instanceCT, _) ([Args:KList])
    => throw new nullPEClass([ null::stringClass ]);

/*@
The logic for private instance methods is the same as for static methods, with the difference that the qualifier is not discarded.
*/
rule [Invoke-methodInfo-instance-private]:
    objectRef(_,_)::_
      . ( methodInfo(Sig:Signature, _, classCMT, DecC:ClassType, instanceCT, private) => methodRef(Sig, DecC) )
      ([Args:KList])


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
      objectRef( _, ObjC:ClassType )::_
        . ( methodInfo(Sig:Signature, _, _,_, instanceCT, Acc:AccessMode) => methodRef(Sig, DecC) )
        ([Args:KList])
      ...
    </k>
    <classType> ObjC </classType>
    <methods>... Sig |-> DecC:ClassType ...</methods>
when
    Acc ==K protected orBool Acc ==K public

/*@
\begin{markdown}
The most complex case is for instance methods with package access mode. The precise semantics of overriding for all
  access modes is defined in JLS \$8.4.6.1:

An instance method derivedM declared in a class Derived overrides another method with the
  same signature, baseM, declared in class Base iff both:

  1. Derived is a subclass of Base.
  2. Either
    a. baseM is public, protected, or declared with package access in the same package as derivedM
    b. derivedM overrides a method middleM, middleM distinct from baseM and derivedM,
      such that middleM overrides baseM

The transitive rule for overriding relation (2b) is required specifically for package access mode. Consider the following example:
\end{markdown}

\begin{minipage}{\textwidth}
\begin{lstlisting}
package a;
public class A {
  void f(int a) { ... }
}

package a;
public class B extends A {
  protected void f(int a) { ... }
}

package b;
import a.*;
public class C extends B {
  protected void f(int a) { ... }
}
\end{lstlisting}
\end{minipage}

\medskip

The method in class C overrides the method in class A transitively through the method in B. There is no direct overriding between A and C, because the method is declared with default (package) access mode in A, and class C is in a different package. Note that if the access mode in B would have been package instead of protected, there would be no overriding.

\begin{markdown}
In order to correctly handle such cases we have to analyze all the classes in the inheritance chain between the qualifying type and the qualifier runtime type.

The rule for package access mode delegates searching for the right method declaration to the auxiliary function lookupPackageM(). The function takes 3 arguments:

  - method signature Sig
  - the list of classes in the inheritance chain between the qualifying class QualC and the actual object class ObjC.
    This list is produced by classChain()
  - the third argument represents the declaring class of the best method found so far.
    It is initialized with .K.
\end{markdown}
*/
rule [Invoke-methodInfo-instance-package]:
    <k>
      objectRef( _, ObjC:ClassType )::QualC:ClassType
        . ( methodInfo(Sig:Signature, QualC:ClassType, classCMT, _, instanceCT, package)
            => lookupPackageMethod( Sig, getClassChain(QualC, [ObjC]), noClass)
          )
        ([Args:KList])
      ...
    </k>
    <classType> QualC </classType>
    <methods>... Sig |-> DecC:ClassType ...</methods>

/*@
Before the evaluation of lookupPackageM() may begin, the term lookupPackageM() have to be heated to the top
  of computation. The side condition in the context rule below ensured that the second argument of method call
  expression is heated only if it contains a term lookupPackageM(). If it have other forms,
  such as the method name or methodInfo(), it won't be heated.
*/
context _:K . HOLE (_)
when
    getKLabel(HOLE) ==KLabel 'lookupPackageMethod

/*
Returns the list of classes representing the layer of the given object (by OId),
  located between MostBaseClass (exclusively) and MostDerivedClass (inclusively).
*/
syntax K ::=  getClassChain( ClassType, //MostBaseClass
                             KListWrap  //[MostDerivedClass] at beginning, gradually accumulates
                                          //the list of classes
              )

/* [Skip] The right signature is already found.
Search for the right implementation is performed from the compile-time type of the target
to more derived types, up to the object type of the target.
This is required in order to respect the rules of inheritance in the presence of access modes.
Evaluates into typed method closure.*/
syntax K ::=  lookupPackageMethod (
                Signature,  //sig(Name, SigTL) - Method signature
                KRListWrap, //computes into kr[...,, Class,, ...], elements of type ClassType,
                              // from base to derived.
                              // To be processed from base to derived until while the chain is not empty
                K           //ClassType - The class with the best method declaration with signature Sig found so far,
                              //initialized with noClass
              )
              [strict(2,3)]

/*@
\begin{markdown}
The rules for lookupPackageM() are based on the following two properties of the configuration:

  - if the cell <methods> for a particular class contains a key Sig, then <methods> for all classes derived from it
    will contain the key Sig.
  - if a particular class contain a method declaration with signature Sig access mode Acc, then all declarations
    of Sig in derived classes (that are not necessarily overriding!) will have the access mode either Acc or a value
    wider than Acc.

The first property is ensured by the unfolding algorithm. Because <methods> of a derived class inherit all the <methods>
  of the direct base class, the map <methods> may only grow from base classes to derived. The second property is ensured
  by restrictions on overriding specified in JLS \$8.4.8.3: "The access modifier (\$6.6) of an overriding or hiding
  method must provide at least as much access as the overridden or hidden method".

The search for the right package method declaration is performed from the base-most class in the chain (the left-most
  one) to the most derived one. Every rule matches and deletes the leftmost class in the class chain (CurrentC),
  and possibly rewrites the third argument into the current class.
The first rule matches when there is no declaring class yet (third argument is .K, the initial case).
\end{markdown}
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
  method declaration with the right signature. The presence of a declaration with signature  Sig inside CurrentC is identified by the
  match <class><classType> CurrentC </classType> <methods>... Sig |-> CurrentC ...</methods> </class>,
  according to the definition of <methods>.

If the method in CurrentC directly overrides the method in OldDecC, the declaring class is updated to CurrentC. Otherwise the declaring class stays unchanged. The rules for direct overriding (case 1a above) are defined in the auxiliary function isOverridden(). The function takes three arguments:
\begin{markdown}
  - The base class OldDecC
  - The derived class CurrentC
  - The access mode Acc of the definition of Sig in OldDecC.
\end{markdown}
*/
rule [lookupPackageMethod-new-method]:
    <k>
      lookupPackageMethod(
        Sig:Signature,
        kr[ (CurrentC:ClassType => .KList),, _ ],
        OldDecC:ClassType => if (isOverridden( OldDecC, Acc, CurrentC )) { CurrentC } else { OldDecC }
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

/*
Tests if a method declared in class BaseC with access mode Acc is overridden by a method
  with the same signature declared in a subclass SubC.

The method is overridden if either:
  - Acc is protected or public
  - Acc is package and BaseC and SubC are declared in the same package (JLS \$6.6)
*/
syntax K ::=  isOverridden (
                ClassType,  //BaseC
                AccessMode, //BaseAcc
                ClassType   //SubC
              )
              [strict]

rule isOverridden(_, public,    _) => true
rule isOverridden(_, protected, _) => true

// Object class cannot match this rule since it has public access mode
rule isOverridden(BaseC:ClassType, package, SubC:ClassType)
    => getPackage(getTopLevel(BaseC)) == getPackage(getTopLevel(SubC))

rule isOverridden(_, private, _) => false

/*@
The third rule represents the case when CurrentC chain don't contain method declarations with signature
  Sig. This case is identified by the side condition CurrentC =/=K DecC. Indeed, the two classes are different only
  when the entry Sig |-> DecC in <methods> was inherited rather than produced by a method in CurrentC.
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
The last rule matches when the chain of classes stored in the first argument remains empty. It rewrites the whole lookupPackageM() into a reference to the method that have to be invoked.
*/
rule [lookupPackageMethod-end]:
    lookupPackageMethod(Sig:Signature, kr[.KList], DecC:ClassType ) => methodRef(Sig, DecC)

/*@
\subsection{Actual method invocation}

\begin{markdown}
The central rule of method invocation is matched when the second argument of method call expression reaches the form
  methodRef(). This rule performs the following operations:

  - saves the rest of computation (RestK) and the content of <methodContext> as a new entry of the cell <stack>
    This data is restored back by the rules for return statement.
  - Initializes the new method context.
    - The local variable environment <env> is emptied
    - current class <crntClass> is initialized to the class declaring the method
    - object location <location> is initialized to the location of the qualifier object for instance methods,
      or .K for static methods. The extraction of the location from the qualifier value is performed by the
      function getOId().
  - Rewrites the method call expression into a sequence of four terms:
    - static initialization of the qualifying class
    - parameters initialization
    - actual method body
    - a return statement with no arguments after the method body.

The function staticInit() triggers static initialization of the qualifying class, if this class was not initialized yet.
  Repeated calls of this function have no effect. Is required just for static methods and is described in JLS \$12.4.
  For an instance method call, the qualifying class will always be initialized already,
  so staticInit() will have no effect.

The function initParams() rewrites each parameter declaration into two statements. First is a local variable
  declaration with that parameter name. The second is an assignment to that variable of the actual argument value.

The return statement at the end ensures that there is a return statement on every execution path of the method. The
  statement will only be useful for methods with return type void, as methods returning a value are required by JLS
  to have an appropriate return statement on every return path.
\end{markdown}
*/
rule [Invoke-methodRef]:
    <k>
      Qual:KResult . methodRef(Sig:Signature, DecC:ClassType) ([Args:KList]) ~> RestK:K
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

/* [Skip] Binds a list of formal parameters to their values. Used by method calls and try-catch.
*/
syntax K ::= initParams ( KListWrap, // [...,, 'Param(...),, ...] - parameter declarations
                          KListWrap  // [...,, KResult,, ...] - values
                        )

rule [initParams]:
    initParams([{T:Type X:Id},, RestP:KList], [TV:TypedVal,, RestV:KList])
    =>   T X;
      ~> (X = ((T) TV:TypedVal));
      ~> initParams([RestP], [RestV])

rule [initParams-end]:
    initParams([.KList], [.KList]) => .K
        [structural]

/*@
\newpage
*/
endmodule

module METHOD-INVOKE-REST
    imports CORE-SORTS
    imports CORE-FUNCTIONS
    imports SYNTAX-CONVERSIONS
    imports METHOD-INVOKE

/* [Skip]
The next rule for method invocation is applied when the qualifier type is array. This array type is rewritten
  into the auxiliary class ArrayImpl, that is used in K-Java to simulate method invocations over array objects.
  This rule is required in order to minimize the number of particular cases involving arrays in the rules that follow.
*/
rule [Invoke-compute-methodInfo-arrays]:
    QualRV:RawVal :: (arrayOf T:Type => arrayImplClass)
      . methodInfo(Sig:Signature, arrayOf T => arrayImplClass, _,_,_,_)
      ([Args:KList])

rule [Invoke-methodInfo-on-array-or-string]:
    QualRV:RawVal::QualC:ClassType
       . methodInfo(Sig:Signature, QualC, classCMT, DecC:ClassType, instanceCT, _)
      ([Args:KList])
    => invokeImpl( methodRef(Sig, DecC), QualRV::QualC, [Args] )
when
    isArrayRef(QualRV) ==K true orBool isString(QualRV) ==K true

//@ 'QSuperMethod(Class:ClassType,, \_:K,, Name:Id)
syntax KLabel ::= "'QSuperMethod"

rule [Invoke-QSuperMethod]:
    'Invoke(
      ('QSuperMethod(Class:ClassType,, _:K,, Name:Id)
       => 'Method('MethodName(superMethodImpl('QThis(Class)),, Name))
      ),, _
    )

/* Elaboration result for super keyword in A.super.m() call. Have to be a typed expression.
*/
syntax MethodName ::= superMethodImpl ( K ) // is always equal to A.this - used to lookup the right qualifier closure.
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

rule [getClassChain-process]:
    <k>
      getClassChain(MostBaseClass:ClassType, [(.KList => BaseClass),, MostDerivedClass:ClassType,, _])
      ...
    </k>
    <classType> MostDerivedClass </classType>
    <extends> BaseClass:ClassType </extends>
when
    MostDerivedClass =/=K MostBaseClass

// Eliminate the most base class before returning the result, because it is exclusive.
rule [getClassChain-end]:
    getClassChain(Class:ClassType, [Class,, MoreDerivedClasses:KList]) => kr[Class,, MoreDerivedClasses]

rule [Invoke-methodRef-native]:
    <k>
      Qual:KResult . methodRef(Sig:Signature, DecC:ClassType) ([Args:KList])
      => invokeImpl(methodRef(Sig, DecC), Qual, [Args])
      ...
    </k>
    <classType> DecC </classType>
    <methodSignature> Sig </methodSignature>
    <methodBody> 'NoMethodBody(_) </methodBody>

/* [Skip] Auxiliary function for methods that need implementation in the semantics. The implementation
  of this production is given in api-core.k and api-threads.k.
*/
syntax K ::=  invokeImpl (
                MethodRef,  //the method reference
                K,          //KResult - method call target
                              //either objectRef(OL:Int,_)::_ ,
                              //typed string or array, or noValue for static methods
                KListWrap   //[Args:List{KResult}]
              )
              [strict(1)]

endmodule
