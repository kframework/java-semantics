module METHOD-INVOKE
    imports CORE-SORTS
    imports CORE-FUNCTIONS
    imports SYNTAX-CONVERSIONS
    imports STATIC-INIT //for staticInit()

/*@
\subsection{Background}

In this section we present the fragment of configuration used by runtime method
  invocation. The figure below contains the cells and their sorts\footnote{$AM^{***}$ = \sortName{AccessMode}, $CT^{***}$ = \sortName{ContextType}}.

\vspace{3ex}

\kwrap{
\kall{T}{\manualBRBlock{
  \kall[GreenYellow]{threads}{
    \kall[GreenYellow]{thread*}{
      \kall[Green]{k}{K}
      \cellSep
      \kall[Green]{stack}{ List \allowbreak {[} \allowbreak (K, Bag) \allowbreak {]} }
      \cellSep
      \kall[Orange]{methodContext}{
        \kall[Crimson]{env}{ Map \left[Id \mapsto Int \right] }
        \cellSep
        \kall[DarkOrange]{crntClass}{ ClassType }
        \cellSep
        \kall[DarkOrange]{location}{ Int }
      }
    }
  }
  \cellBR
  \cellBR
  \kall[Red]{classes}{
    \kall[Red]{class*}{\manualBRBlock{
      \kall[Red]{classType}{ ClassType }
      \cellSep
      \kall[Maroon]{classMetaType}{ ClassMetaType }
      \cellSep
      \kall[Blue]{methods}{ Map \left[Signature \mapsto ClassType \right] }
      \cellBR
      \cellBR
      \kall[Blue]{methodDecs}{
        \kall[Blue]{methodDec*}{
          \kall[Blue]{methodSignature}{ Signature }
          \cellSep
          \kall[Blue]{methodParams}{ List }
          \cellSep
          \kall[Blue]{methodBody}{ K }
          \cellSep
          \kall[Blue]{methodAccessMode}{ AM^{***} }
          \cellSep
          \kall[Blue]{methodContextType}{ CT^{***} }
        }
      }
    }}
  }
}}
}

\vspace{3ex}

The cell \cellref[]{k} stores the current computation. The cell \cellref[]{stack} is a list of pairs of the
  form (K, Bag), and represents the standard method call stack. The first element
  represents the remaining computation at the moment the method was called. The second
  element of sort Bag represents the content of cell \cellref[]{methodContext} at the moment
  of method call.

The cell \cellref[]{class} contains various sub-cells holding the content of that class. The
  first cell in \cellref[]{classType} of sort ClassType that holds the fully qualified class name.
  This cell serves as a key in all rules that match a fragment of a \cellref[]{class}. The value
  in the cell \cellref[]{classMetaType} is either "class" or "interface". From now on we will
  refer to both meta types as classes, referring to metatype value when distinction
  is necessary. The next cell is \cellref[]{methods}. This is a map from method signatures to
  classes where the respective signatures are declared. It contains not only the methods
  declared in this class, but also those inherited from the base class, but not from the
  base interfaces. By "inherited" here we mean all the methods contained in the cell
  \cellref[]{methods} of the base class that were not overridden by a method declaration with
  the same signature in the current class. This definition is different from the
  inheritance rules in JLS \S8.4.6, although the difference is only relevant at the
  elaboration time.

The cell \cellref[]{methodDec} represents a method declared inside the current class. The subcell
  \cellref[]{methodSignature} is the key for accessing other cells for this declaration. The other
  cells are the parameters, the body, the access mode (private, public etc.) and the
  context type (either instance or static).

In order for strictness and context rules to work we have to define some K productions
  as KResult. The most common forms of KResult in Java are the following:

\vspace{3ex}

\begin{syntaxBlock}{\nonTerminal{\sort{KResult}}}
\syntax{{\nonTerminal{\sort{ClassType}}}}{}
\syntaxCont{{\nonTerminal{\sort{TypedVal}}}}{}
\end{syntaxBlock}

The first represents a class. Second is a typed value, the result of evaluation of any
  expression. The forms of typed values relevant for method invocation are object reference and null:

\vspace{3ex}

\begin{syntaxBlock}{\nonTerminal{\sort{TypedVal}}}\syntax{{}\terminal{objectRef}
  ({{\nonTerminal{\sort{Int}}}},{{\nonTerminal{\sort{ClassType}}}}){}
  \terminal{::}{{\nonTerminal{\sort{ClassType}}}}}{}\syntaxCont{{}\terminal{null}
  {}\terminal{::}{{\nonTerminal{\sort{ClassType}}}}}{}
\end{syntaxBlock}

The type after four dots (::) separator is the static type associated with that value. The values inside
  objectRef() are the address inside the store and the runtime type of the object.

For the sake of simplicity we we will also
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
    expression still has to be evaluated and might produce side effects. We cannot replace it with
    o; class.f(args); either, because o; might be invalid. Not all expressions
    valid as qualifiers are valid as expression statements (JLS \S14.8). We wanted the elaboration
    result to be a valid Java program, thus we could not afford such a transformation.

  - An invocation of an instance method qualified by a class reference: o.f(args)
  - An invocation of an instance method qualified by an interface reference: i.f(args)

The evaluation of the method invocation expression consists from 5 steps outlined below.
  Those steps, unless otherwise specified, are common to all the method call forms
  enumerated above.

  1. Evaluation of the qualifier expression
  2. Evaluation of method arguments
  3. Computation of static method information
  4. Locating the actual method declaration to be invoked
  5. Actual method invocation.

In JLS runtime semantics of method invocation is described in \S15.2.4. Although there
  is some correspondence between the steps in our semantics and the steps in JLS, it is
  generally not one-to-one. JLS description of method invocation consists of the
  following 5 steps. For each step we give the relevant chapter of the JLS and the step
  in our semantics.

  1. Compute the target reference (\S15.12.4.1), semantics step 1
  2. Evaluate arguments (\S15.12.4.2), semantics step 1
  3. Check the accessibility of the method to be invoked (\S15.12.4.3), no semantics
  4. Locate the actual method code to invoke (\S15.12.4.4), semantics step 3
  5. Actual method invocation, semantics step 4.

Generally the rules of K-Java do not follow directly the wording of JLS. The reasons
  for this will choice will be given at the end of the section.
  The details related to each step are described in the semantics below, above each
  rule and auxiliary construct. For each rule we will also refer to the respective
  JLS page, if there is a correspondence.
\end{markdown}
*/

/*@
\subsection{Evaluation of the qualifier and the arguments}

The first two parts of method invocation logic are evaluation of the qualifier expression and evaluation of the
  arguments. JLS enforces the following conditions on the order of subexpressions evaluation:
   - Arguments have to be evaluated after the qualifier was evaluated. This is ensured
     by checking that the qualifier is of sort KResult at the moment when arguments are
     heated.
   - Arguments are evaluated left to right. To ensure this we add a side condition that
     checks that all the arguments before the one being heated (if any) are already of the
     sort KResult.

While there are two sections dedicated to this logic (\S15.12.4.1, \S15.12.4.2), we don't need any K rules
  for it. Instead, subexpressions evaluation ensured by strictness annotations
  that accompany the following syntax definitions:

\vspace{3ex}

\begin{syntaxBlock}{
  \nonTerminal{\sort{Exp}}}\syntax{{{\nonTerminal{\sort{K}}}}\terminal{.}{{\nonTerminal{\sort{MethodName}}}}
  ({{\nonTerminal{\sort{Exps}}}})}{\kattribute{seqstrict}(1,3)}
\end{syntaxBlock}

\begin{syntaxBlock}{
	\nonTerminal{\sort{MethodName}}}\syntax{{\nonTerminal{\sort{Id}}}}{}
\end{syntaxBlock}

\begin{syntaxBlock}{
  \nonTerminal{\sort{Exps}}}\syntax{List\{{\nonTerminal{\sort{Exp}}}, \mbox{``},\mbox{''}\}}{\kattribute{seqstrict}}
\end{syntaxBlock}

The annotation {\kattribute{seqstrict}(1,3)} on the first definition ensures that arguments are evaluated after the
  qualifier is evaluated. The qualifier term might be either an expression or a Class. If it is expression,
  it will be heated and evaluated. If it is a class (for certain static methods), then it is already a KResult
  strictness rule will have no effect on it.
Note that arguments have to be evaluated even in the case when the qualifier evaluated to null. At the same time
  that if evaluation of the qualifier or any of the arguments
  completes abruptly, the whole method invocation expression completes abruptly for the
  same reason. K-Java does not need any special rules to cover those cases. The semantics has a fixed number of rules
  for throw statement that ensure the correct propagation of exceptions from any context.
*/

/*@
\subsection{Loading method information}

\begin{markdown}
During the second step of the method invocation the second argument of the production is replaced with the
  auxiliary data
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
  this information computed, but it is stored in various cells inside \cellref[]{class} and \cellref[]{classDec}.
  The rules from step 3 simply load the relevant information from configuration
  cells to methodInfo() arguments.
\end{markdown} */
syntax MethodName ::= methodInfo(
                        Signature,    //Sig - method signature
                        RefType,      //QualC - qualifier type, not necessarily class
                        ClassMetaType,//MetaT - The either classCMT or interfaceCMT for the qualifier type
                        RefType,      //DecC - method declaration class - the class referred by the signature
                                        // in <methods>. For arrays - it remains noClass.
                                        // this argument is mostly used to compute the context type
                        ContextType,  //ContextT - method context type - instance or static
                                        //for arrays - instanceCT
                        AccessMode    //Acc - The access mode of the method as seen by the qualifying type
                      )

/*@
The first rule from this step rewrites the method name into a methodInfo() term whose first argument is the method
signature.
  The auxiliary function getTypes() computes the list of types from the list of parameter declarations. The second
  argument of methodInfo() is also computed at this step - it is the type of the qualifier. The rest of the arguments
  are filled in with default values. They will be rewritten into actual values by the following rules.
*/
rule [Invoke-compute-methodInfo-Signature]:
    Qual:KResult
      .(Name:Id => methodInfo(sig(Name, getTypes(Args)), typeOf(Qual), .K,.K,.K,.K))
      (Args:TypedVals)

/*@
Note that in this rule variable Args is defined of type TypedVals instead of Exps. This restriction ensures that
  arguments (and consequently the qualifier) are already evaluated at the moment when this rule is invoked.
  The sort TypedVals represents a list of typed values, the evaluation result of Exps. It is defined as following:

\vspace{3ex}

\begin{syntaxBlock}{
	\nonTerminal{\sort{TypedVals}}}\syntax{List\{{\nonTerminal{\sort{TypedVal}}}, \mbox{``},\mbox{''}\}}{}
\end{syntaxBlock}

\begin{syntaxBlock}{
  \nonTerminal{\sort{Exps}}}\syntax{{\nonTerminal{\sort{TypedVals}}}}{}
\end{syntaxBlock}

Because TypedVal is subsorted to KResult, TypedVals being a list of KResult is implicitly subsorted to KResult.
*/

/* Impl: We could combine this rule with the previous one by using getLookupTargetType(), but we'll keep it this way
    to keep the core part of method invocation separate from the non object-related part. */

/*@
The second rule for method invocation loads MetaT and DecC. It requires Sig and QualC computed by the previous rule.

*/
rule [Invoke-compute-methodInfo-DecC]:
    <k>
      _. methodInfo(Sig:Signature, QualC:ClassType, .K => MetaT, .K => DecC, _,_) (_)
      ...
    </k>
    <classType> QualC </classType>
    <classMetaType> MetaT:ClassMetaType </classMetaType>
    <methods>... Sig |-> DecC:ClassType ...</methods>

/*@ \begin{markdown}
There is one case that is not covered by the previous rule - the case when the cell \cellref[]{methods} does not have a key
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
      _. methodInfo(Sig:Signature, QualC:ClassType, .K => MetaT, _, .K => instanceCT, .K => public) (_)
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
      _. methodInfo(Sig:Signature, _,_, DecC:ClassType, .K => ContextT, .K => Acc) (_)
      ...
    </k>
    <classType> DecC </classType>
    <methodSignature> Sig </methodSignature>
    <methodContextType> ContextT:ContextType </methodContextType>
    <methodAccessMode> Acc:AccessMode </methodAccessMode>

/*@
\subsection{Lookup method declaration}

In the third step of the method invocation algorithm, the actual method declaration is chosen. This step starts once all
  the fields of methodInfo() were filled in (where possible). The rules of this step rewrite methodInfo() into
  methodRef() - another auxiliary data structure.
The production methodRef() is a reference to a method declaration. It contains two fields - Sig and DecC - the
  signature and the declaration class. The implementation class is the class that contains the actual method
  declaration to be invoked.

\vspace{3ex}

\begin{syntaxBlock}{
  \nonTerminal{\sort{MethodName}}}\syntax{{}\terminal{methodRef}({{\nonTerminal{\sort{Signature}}}},{{\nonTerminal{\sort{RefType}}}})}{}
\end{syntaxBlock}

\begin{markdown}
Since we already know the signature, this phase amounts to computing DecC. This step contains different rules for the following cases:

  - Static method (JLS \S15.12.4.4 paragraph 2)
  - Instance method with target being null (JLS \S15.12.4.4 paragraph 3)
  - Instance method with non-null target, private method (JLS \S15.12.4.4 paragraph 4)
  - Instance method with non-null target, access mode is protected or public. This also includes qualifying type
    being interface. (JLS \S15.12.4.4 paragraph 6 and point 1)
  - Instance method with non-null target, access mode is package (no dedicated mention in JLS \S15.12.4.4)

<!--- - Target value is array or string. -->

The method below is for the first case. If the method is static, then the declaring type DecC is the qualifying type.
  The qualifier is discarded by rewriting it into \dotCt{K} .
\end{markdown}
*/
rule [Invoke-methodInfo-static]:
    (_ => noValue)
      . ( methodInfo(Sig:Signature, _, classCMT, DecC:ClassType, staticCT, _) => methodRef(Sig, DecC) )
      (_)

/*@
If the qualifier value is null and ContextT is instance, then NullPointerException is thrown and method invocation
  expression is discarded. It is only at this point that we should check the qualifier whether it is null or not.
  If ContextT is static, then the previous rule will match, and no exception will be thrown.
*/
rule [Invoke-methodInfo-instance-on-null]:
/*  [Impl] Qualifier type could be either object or array.
    We cannot move method invocation on null logic to invokeImpl, because
    invokeImpl needs an actual methodRef, and we cannot produce a methodRef if our qualifier object is null.
*/
    null::_ . methodInfo(_,_,_,_, instanceCT, _) (_)
    => throw new classNullPointerException(null::classString);

/*@
The logic for private instance methods is the same as for static methods, with the difference that the qualifier is not discarded.
*/
rule [Invoke-methodInfo-instance-private]:
    (objectRef(_,_)::_)
      . ( methodInfo(Sig:Signature, _, classCMT, DecC:ClassType, instanceCT, private) => methodRef(Sig, DecC) )
      (_)

/*@
If the method is protected or public, then we should call the version of the method visible to the runtime type of
  the qualifying object (ObjC). Recall that the runtime type of an object is stored in the second argument of
  objectRef().
  This case also covers qualifying type interface, since interface methods are always public.
  The right method will always be the one referred by the signature Sig in the cell \cellref[]{methods} associated with the
  actual object class. This is because the unfolding phase populates \cellref[]{methods} with the union of methods inherited
  from the base class and methods declared in the current class, the latter overriding the former.
  The variable DecC is the class where the right method version is declared.
*/
rule [Invoke-methodInfo-instance-protected-or-public]:
    <k>
      (objectRef( _, ObjC:ClassType )::_)
        . ( methodInfo(Sig:Signature, _, _,_, instanceCT, Acc:AccessMode) => methodRef(Sig, DecC) )
        (_)
      ...
    </k>
    <classType> ObjC </classType>
    <methods>... Sig |-> DecC:ClassType ...</methods>
when
    Acc ==K protected orBool Acc ==K public

/*@
\begin{markdown}
The most complex case is for instance methods with package access mode. The precise semantics of overriding for all
  access modes is defined in JLS \S8.4.6.1:

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

((A) new C()).f();
\end{lstlisting}
\end{minipage}

\medskip

The method in class C overrides the method in class A transitively through the method in B. There is no direct
  overriding between A and C, because the method is declared with default (package) access mode in A, and class C is
  in a different package. Note that if the access mode in B would have been package instead of protected,
  there would be no overriding.

\begin{markdown}
In order to correctly handle such cases we have to analyse all the classes in the inheritance chain between the
  qualifying type and the qualifier runtime type.

The algorithm employed in K-Java is significantly different from the one in JLS, but it is much simpler to implement.
  Yet it yields the correct behaviour and was extensively tested by our test suite. The JLS algorithm involves starting
  the search from the runtime type of the qualifier and moving upwards in the inheritance tree until we find the FIRST
  method that overrides the originally called method (or is the originally called method itself). This apparently
  simple algorithm leads to multiple particular cases when we consider the transitive rule (2b above) for overriding.

In contrast, the K-Java algorithm starts the search with the qualifying type (e.g. static type of the qualifier
  expression) and moves downwards in the inheritance chain until it reaches the runtime type of the qualifier.
  When all classes in the chain were traversed the algorithm returns the LAST found method (e.g. defined in the most
  derived class) that overrides the original one.

The rule for package access mode delegates searching for the right method declaration to the auxiliary function
  lookupPackageMethod(). The function takes 3 arguments:

  - method signature Sig
  - the list of classes in the inheritance chain between the qualifying class QualC and the actual object class ObjC.
    This list is produced by classChain()
  - the third argument represents the declaring class of the best method found so far.
    It is initialized with \dotCt{K}.
\end{markdown}
*/
rule [Invoke-methodInfo-instance-package]:
    <k>
      (objectRef( _, ObjC:ClassType )::QualC:ClassType)
        . ( methodInfo(Sig:Signature, QualC, classCMT, _, instanceCT, package)
            => lookupPackageMethod( Sig, getClassChain(QualC, ObjC), noClass)
          )
        (_)
      ...
    </k>
    <classType> QualC </classType>
    <methods>... Sig |-> _ ...</methods>

/*@
Before the evaluation of lookupPackageMethod() may begin, the term lookupPackageMethod() has to be heated to the top
  of computation. The side condition in the context rule below ensured that the second argument of method call
  expression is heated only if it contains a term lookupPackageMethod(). If it has other forms,
  such as the method name or methodInfo(), it won't be heated.
*/
context _:K . HOLE (_)
when
    getKLabel(HOLE) ==KLabel 'lookupPackageMethod

/*
Returns the list of classes representing the layer of the given object (by OId),
  located between MostBaseClass (exclusively) and MostDerivedClass (inclusively).
*/
syntax KItem ::=  getClassChain( ClassType, //MostBaseClass
                             ClassTypes    //MostDerivedClass at beginning, gradually accumulates
                                          //the list of classes
              )

/* [Skip] The right signature is already found.
Search for the right implementation is performed from the compile-time type of the target
to more derived types, up to the object type of the target.
This is required in order to respect the rules of inheritance in the presence of access modes.
Evaluates into typed method closure.*/
syntax KItem ::=  lookupPackageMethod (
                Signature,  //sig(Name, SigTL) - Method signature
                ClassTypes,    //computes Class,... , list of elements of type ClassType,
                              // from base to derived.
                              // To be processed from base to derived until while the chain is not empty
                K           //ClassType - The class with the best method declaration with signature Sig found so far,
                              //initialized with noClass
                              //The sort is K because it is rewritten into "if" during computation.
              )
              [strict(2,3)]

/*@
\begin{markdown}
The rules for lookupPackageMethod() are based on the following two properties of the configuration:

  - if the cell \cellref[]{methods} for a particular class contains a key Sig, then \cellref[]{methods} for all classes derived from it
    will contain the key Sig.
  - if a particular class contain a method declaration with signature Sig access mode Acc, then all declarations
    of Sig in derived classes (that are not necessarily overriding!) will have the access mode equal to either Acc or a
    value wider than Acc.

The first property is ensured by the unfolding algorithm. Because \cellref[]{methods} of a derived class inherit all the \cellref[]{methods}
  of the direct base class, the map \cellref[]{methods} may only grow from base classes to derived. The second property is ensured
  by restrictions on overriding specified in JLS \S8.4.8.3: "The access modifier (\S6.6) of an overriding or hiding
  method must provide at least as much access as the overridden or hidden method".

The search for the right package method declaration is performed from the base-most class in the chain (the left-most
  one) to the most derived one. Every rule matches and deletes the leftmost class in the class chain (CurrentC),
  and possibly rewrites the third argument into the current class.
The first rule matches when there is no declaring class yet (third argument is \dotCt{K}, the initial case).
\end{markdown}
*/
rule [lookupPackageMethod-layer-first-dec-found]:
    <k>
      lookupPackageMethod(
        Sig:Signature,
        (CurrentC:ClassType, Cs:ClassTypes => Cs),
        noClass => DecC
      )
      ...
    </k>
    <classType> CurrentC </classType>
    <methods>... Sig |-> DecC:ClassType ...</methods>

/*@
The second rule matches when we already found a declaring class (OldDecC) and the current class CurrentC has another
  method declaration with the right signature. The presence of a declaration with signature  Sig inside CurrentC is identified by the
  match $\mathrel{}\kall{class}{\kall{classType}{ CurrentC } \mathrel{}\kall{methods}{... Sig \mapsto CurrentC ...} }$,
  according to the definition of \cellref[]{methods}.

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
        (CurrentC:ClassType, Cs:ClassTypes => Cs),
        OldDecC:ClassType => ifAux (isOverridden( OldDecC, Acc, CurrentC ),CurrentC,OldDecC )
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
  - Acc is package and BaseC and SubC are declared in the same package (JLS \S6.6)
*/
syntax KItem ::=  isOverridden (
                ClassType,  //BaseC
                AccessMode, //BaseAcc
                ClassType   //SubC
              )

rule isOverridden(_, public,    _) => true
rule isOverridden(_, protected, _) => true

// Object class cannot match this rule since it has public access mode
rule isOverridden(BaseC:ClassType, package, SubC:ClassType)
    => eqAux(getPackage(getTopLevel(BaseC)) , getPackage(getTopLevel(SubC)))

rule isOverridden(_, private, _) => false

/*@
The third rule represents the case when CurrentC chain does not contain method declarations with signature
  Sig. This case is identified by the side condition CurrentC =/=K DecC. Indeed, the two classes are different only
  when the entry Sig $\mapsto$ DecC in \cellref[]{methods} was inherited rather than produced by a method in CurrentC.
*/
rule [lookupPackageMethod-no-new-method]:
    <k>
      lookupPackageMethod(
        Sig:Signature,
        (CurrentC:ClassType, Cs:ClassTypes => Cs),
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
  lookupPackageMethod() into a reference to the method that has to be invoked.
*/
rule [lookupPackageMethod-end]:
    lookupPackageMethod( Sig:Signature, .ClassTypes, DecC:ClassType ) => methodRef(Sig, DecC)

/*@
For the code example above, the term lookupPackageMethod() will pass through the following forms during evaluation:

\begin{tabular}{ | l | l | }
  \hline
  $\mathrel{}\kall{k}{ lookupPackageMethod(f(), (a.A, a.B, b.C), \dotCt{K}) ...}$ &\\
  $\mathrel{}\kall{classType}{ A }$ &\\
  $\mathrel{}\kall{methods}{... f() \mapsto A ...}$
  & rule 1\\

  \hline
  $\mathrel{}\kall{k}{ lookupPackageMethod(f(), (a.B, b.C), a.A) ...}$ & \\
  $\mathrel{}\kall{class}{
    \mathrel{}\kall{classType}{ a.A }
    \mathrel{}\kall{methodSignature}{ f() }
    \mathrel{}\kall{methodAccessMode}{ package }
    ...
  }$ & \\
  $\mathrel{}\kall{class}{
    \mathrel{}\kall{classType}{ a.B }
    \mathrel{}\kall{methods}{... f() \mapsto a.B ...}
    ...
  }$
  & rule 2, if returns true\\

  \hline
  $\mathrel{}\kall{k}{ lookupPackageMethod(f(), (b.C), a.B) ...}$ & \\
  $\mathrel{}\kall{class}{
    \mathrel{}\kall{classType}{ a.B }
    \mathrel{}\kall{methodSignature}{ f() }
    \mathrel{}\kall{methodAccessMode}{ protected }
    ...
  }$ & \\
  $\mathrel{}\kall{class}{
    \mathrel{}\kall{classType}{ b.C }
    \mathrel{}\kall{methods}{... f() \mapsto b.C ...}
    ...
  }$
  & rule 2, if returns true\\

  \hline
  $\mathrel{}\kall{k}{ lookupPackageMethod(f(), \dotCt{ClassTypes}, b.C) ...}$ & rule 3\\
  \hline
  $\mathrel{}\kall{k}{ methodRef(f(), b.C) ...}$ & \\
  \hline
\end{tabular}

\vspace{3ex}

When the term lookupPackageMethod() is first produced it takes as arguments the method signature (rendered here as f()
 for convenience), the chain of classes from the qualifying class A to the runtime class C,
 and \dotCt{K} as the third argument. Since the third argument is \dotCt{K} only the third rule can match. This rule deletes A
 from the class chain and updates the third argument to the class that defines the version of f() accessible to A.
 That class is A. For classes B and C the second rule for lookupMethodM() matches. In both cases the method f()
 defined in B and C overrides the previously found one. In the first case classes the method B.f() overrides A.f()
 because the access mode is package and both A and B are in the same package. In the second case C.f()
 overrides B.f() because B.f() has protected access mode, and is thus always overridden. The final result of
 method lookup procedure is the version of method f() declared in the class C.
*/

/*@
\subsection{Actual method invocation}

\begin{markdown}
The central rule of method invocation is matched when the second argument of method call expression reaches the form
  methodRef(). This rule performs the following operations:

  - saves the rest of computation (RestK) and the content of \cellref[]{methodContext} as a new entry of the cell \cellref[]{stack}
    This data is restored back by the rules for return statement.
  - Initializes the new method context.
    - The local variable environment \cellref[]{env} is emptied
    - current class \cellref[]{crntClass} is initialized to the class declaring the method
    - object location \cellref[]{location} is initialized to the location of the qualifier object for instance methods,
      or \dotCt{K} for static methods. The extraction of the location from the qualifier value is performed by the
      function getOId().
  - Rewrites the method call expression into a sequence of four terms:
    - static initialization of the qualifying class
    - parameters initialization
    - actual method body
    - a return statement with no arguments after the method body.

The function staticInit() triggers static initialization of the qualifying class, if this class was not initialized yet.
  Repeated calls of this function have no effect. Is required just for static methods and is described in JLS \S12.4.
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
      Qual:KResult . methodRef(Sig:Signature, DecC:ClassType) (Args:TypedVals) ~> RestK:K
      => staticInit(DecC) ~> initParams(Params, Args) ~> Body ~> return ('Some(nothing :: void)) ;
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
    <methodParams> Params:Params </methodParams>
    <methodBody> Body:K </methodBody>
when getKLabel(Body) =/=KLabel 'NoMethodBody

syntax KItem ::= getOId( K )              [function]
rule getOId( objectRef(OId:Int,_)::_ ) => OId
rule getOId( noValue ) => noValue

/* Binds a list of formal parameters to their values. Used by method calls and try-catch.
*/
syntax KItem ::= initParams ( Params,   // {T:Type X:Id},... - parameter declarations
                          TypedVals // values
                        )

rule [initParams]:
    initParams(_ T:Type X:Id, RestP:Params, (TV:TypedVal, RestV:TypedVals))
      => (T X;)<:LocalVarDecStmt
      ~> (X = ((T) TV:TypedVal));
      ~> initParams(RestP, RestV)

rule [initParams-end]:
    initParams(.Params, .TypedVals) => .K
        [structural]

/*@
\subsection{Conclusion}
\begin{markdown}
While maintaining a close correspondence between JLS and K-Java would be an interesting
  quest on its own, there are a number of reasons why such a goal would not be practical.
  Some of the reasons are:

  - JLS specification describes not only the execution of correct Java programs, but also
    runtime checks that have to be performed to ensure the consistency of the bytecode,
    and errors that have to be thrown once this consistency is violated. Such bytecode
    inconsistencies may arise when someone compiles a program with one version of a library
    and tries to execute it with another version. Since in K-Java we perform the logic
    corresponding to compilation and execution at the same time, we cannot encounter such
    inconsistencies. This is why sections like \S15.12.4.3, does not have a correspondent in K-Java.
  - Because K-Java operates directly over the source code of Java, with no other
    preprocessing than the unfolding phase, it carries less static information than
    the bytecode. For this reason some static information needs to be computed in K-Java
    each time a method is invoked. This is why semantics step 3 is needed. As we will
    see below, rules for this step are straightforward and consist of loading the right
    data from the right cells into an auxiliary data structure.
  - Although JLS avoids references to bytecode as much as possible, sometimes it contains
    references to features specific to bytecode. For example a method call in JLS has an
    invocation mode associated with it, that might be static, nonvirtual, virtual, interface or others.
    Since this invocation mode is computed at compile-time, JLS runtime semantics is
    described separately for each such invocation mode. In K, since we don't have such a
    classification by invocation modes, we often have fewer cases.
  - The logic of exception propagation is repeated in JLS in every context an where an exception
    might interrupt the usual execution flow. At the same time K abstractions allow us to cover
    all those cases by a fixed set of rules.
  - Most complex parts of JLS prose have the form if ... otherwise if .. otherwise.
    While matching the condition under an if can be done by a single rule in K, matching the
    negation of a condition is more complex and may involve many rules. This difficulty arises
    from the fact that K does not offer built-in support to express lack of a match of a particular
    rule as a side condition of another rule.
  - The powerful mechanism of strictness in K allows us to seamlessly define many language
    features that have many corresponding lines of text of JLS. This is especially true
    for order of evaluation and exception propagation.

On overall, we believe that the lack of direct correspondence between JLS and K rules is not a
  disadvantage. By relaxing this correspondence we were able to produce a semantics that is
  more concise than JLS. While K-Java cannot achieve the same level of ease of reading as JLS,
  it might serve as a complementary reference. A formal semantics definition might be useful
  to clarify the most ambiguous and technically complex parts of the semantics, such as
  rules of package method overriding that were presented above.
\end{markdown}
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
    QualRV:RawVal :: (arrayOf T:Type => classArrayImpl)
      . methodInfo(Sig:Signature, arrayOf T => classArrayImpl, _,_,_,_)
      (_)

rule [Invoke-methodInfo-on-array-or-string]:
    QualRV:RawVal::QualC:ClassType
       . methodInfo(Sig:Signature, QualC, classCMT, DecC:ClassType, instanceCT, _)
      (Args:TypedVals)
    => invokeImpl( methodRef(Sig, DecC), QualRV::QualC, toKListWrap(Args) )
when
    isArrayRef(QualRV) ==K true orBool isString(QualRV) ==K true

// 'QSuperMethod(Class:ClassType,, _:K,, Name:Id)
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
          // should be discarded in order to implement super.m() functionality.
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
      getClassChain(MostBaseClass:ClassType,
                    (MostDerivedClass:ClassType, Cs:ClassTypes => BaseClass, MostDerivedClass, Cs))
      ...
    </k>
    <classType> MostDerivedClass </classType>
    <extends> BaseClass:ClassType </extends>
when
    MostDerivedClass =/=K MostBaseClass

// Eliminate the most base class before returning the result, because it is exclusive.
rule [getClassChain-end]:
    getClassChain(Class:ClassType, (Class, MoreDerivedClasses:ClassTypes)) => (Class, MoreDerivedClasses)<:ClassTypes

rule [Invoke-methodRef-native]:
    <k>
      Qual:KResult . methodRef(sig(Name:Id, Ts:Types), DecC:ClassType) (Args:TypedVals)
      => invokeImpl(methodRef(sig(Name, Ts), DecC), Qual, toKListWrap(Args))
      ...
    </k>
    <classType> DecC </classType>
    <methodSignature> sig(Name, Ts) </methodSignature>
    <methodBody> 'NoMethodBody(_) </methodBody>
when
    notBool ((DecC ==K classObject) andBool
             (Name ==K String2Id("wait") orBool Name ==K String2Id("notify") orBool Name ==K String2Id("notifyAll")))

/* [Skip] Auxiliary function for methods that need implementation in the semantics. The implementation
  of this production is given in api-core.k and api-threads.k.
*/
syntax KItem ::=  invokeImpl (
                MethodRef,  //the method reference
                K,          //KResult - method call target
                              //either objectRef(OL:Int,_)::_ ,
                              //typed string or array, or noValue for static methods
                KListWrap   //[Args:List{KResult}]
              )
              [strict(1)]

endmodule
