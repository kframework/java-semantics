module JAVA-SYNTAX

/*@ \section{Syntax}
The syntax of typed SIMPLE extends that of untyped SIMPLE with support
for declaring types to variables and functions.  The syntax below is identical
to that of the static semantics of typed SIMPLE.  However, the \K
strictness attributes are like those of the untyped SIMPLE, to capture
the desired evaluation strategies of the various language constructs .  */

  syntax #Id ::= "main"

//@ \subsection{Types}

  syntax Type ::= "int"
                | "bool"
                | "rtString"
                | "void"
                | "arrayOf" Type
                    [:prec(1) latex "{#1}\texttt{\char91\char93}":]
                | "function" "from" List{KResult} "to" Type
                    [:prec(1) latex "({#1}\ \texttt{->}\ {#2})":]
  syntax Types ::= List{Type,","}

//@ \subsection{Declarations}

  syntax Decl ::= "var" Exps ";"

//@ \subsection{Expressions}

  syntax Exp ::= #Int | #Bool | #String | #Id
               | "++" Exp              [:prec(0):]
               | Exp "+" Exp           [:strict prec(33) gather(E e):]
               | Exp "-" Exp           [:strict prec(33) gather(E e):]
               | Exp "*" Exp           [:strict prec(31) gather(E e):]
               | Exp "/" Exp           [:strict prec(31) gather(E e):]
               | Exp "%" Exp           [:strict prec(31) gather(E e):]
               | "-" Exp               [:strict:]
               | Exp "<" Exp           [:strict prec(37):]
               | Exp "<=" Exp          [:strict prec(37):]
               | Exp ">" Exp           [:strict prec(37):]
               | Exp ">=" Exp          [:strict prec(37):]
               | Exp "==" Exp          [:strict prec(37):]
               | Exp "!=" Exp          [:strict prec(37):]
               | Exp "and" Exp         [:strict prec(55) gather(E e):]
               | Exp "or" Exp          [:strict prec(59) gather(E e):]
               | "not" Exp             [:strict prec(53):]
               | Exp "[" Exps "]"      [:strict prec(1):]
               | "sizeOf" "(" Exp ")"  [:strict:]
               | "read" "(" ")"
               | Exp "=" Exp           [:strict(2) prec(40) gather (e E):]
               | Exp ":" Type          [:prec(10):]
                                       // allowed only for declarations
  syntax Exps ::= List{Exp,","}

//@ \subsection{Statements}

  syntax Stmt ::= "{" "}"
                | "{" Stmts "}"
                | Exp ";"                               [:strict prec(45):]
                | "if" Exp "then" Stmt "else" Stmt      [:strict(1) prec(90):]
                | "if" Exp "then" Stmt                  [:prec(89):]
                | "while" Exp "do" Stmt                 [:prec(90):]
                | "for" #Id "=" Exp "to" Exp "do" Stmt  [:prec(90):]
                | "return" Exp ";"                      [:strict:]
                | "return" ";"
                | "print" "(" Exps ")" ";"              [:strict:]
                | "throw" Exp ";"                       [:strict:]
                | "spawn" Stmt                          [:prec(90):]
                | "acquire" Exp ";"                     [:strict:]
                | "release" Exp ";"                     [:strict:]
                | "rendezvous" Exp ";"                  [:strict:]

  syntax Stmts ::= Decl | Stmt
                 | Stmts Stmts                      [:prec(100) gather(e E):]

/*@ \subsection{KOOL Additional Syntax}
The KOOL syntactic extensions below are almost identical to their
untyped variants in untyped KOOL.  The only difference is that we add
a new type construct for class types and that now methods take typed
arguments (we achieved this the same way as in typed SIMPLE) and can
also have an explicit return type.  As a convenience to the
programmer, a macro adds an explicit type \texttt{void} whenever a
return type is not provided (e.g., one may not want to write a return
type for constructors in KOOL typed programs).  The syntax of typed
exceptions differs from that of typed SIMPLE in that the variable
bound by \texttt{catch} is now expected to be typed (we use
\textit{Exp}, but we only give semantics for the case when it has the
form \textit{\#Id:Type}. */

  syntax #Id ::= "object"

  syntax Type ::= "class" #Id [prec 1]

  syntax Decl ::= "method" #Id "(" Exps ")" ":" Type Stmt
                | "method" #Id "(" Exps ")" Stmt
  macro method X:#Id (Es:Exps) S:Stmt = method X(Es) : void S

  syntax Decl ::= "class" #Id "{" Stmts "}"
                | "class" #Id "extends" #Id "{" Stmts "}"

  syntax Exp ::= Exp "(" Exps ")"      [:strict(2) prec(2):]

  syntax Exp ::= "new" #Id "(" Exps ")" [:strict(2) prec(1):]
               | "this"
               | "super"
               | Exp "." #Id            [:prec(1):]
               | Exp "instanceOf" #Id   [:prec(0) strict(1):]
               | "cast" Exp "to" #Id    [:prec(0) strict(1):]

  syntax Stmt ::= "try" Stmt "catch" "(" Exp ")" Stmt   [:prec(90):]

end module

module JAVA
  imports JAVA-SYNTAX

//@ \section{Unused labels}

  syntax KLabel ::= 'ClassDecHead | 'Public | 'Static

//@ \section{Semantics}

//@ We use the same desugaring macros like in untyped SIMPLE

  macro 'If(E:K,,S1:K) = 'If(E:K,,S1:K,,'Block('ListWrap(.List{K})))

//@ \subsection{For statement}

  syntax K ::= "stm" "(" K ")"
  rule stm('ListWrap(.List{K})) => . [structural]
  rule stm('ListWrap(E:K,, Es:List{K})) => 'ExprStm(E) ~> stm('ListWrap(Es))
    [structural]
  rule <k> stm('LocalVarDec(Ks)) => 'LocalVarDecStm('LocalVarDec(Ks)) ...</k>
    [structural]

  rule [forFirstArgV1Red]: 'For(('ListWrap(InitExps:List{K}) => stm('ListWrap(InitExps))),,_:List{K})
    [structural]
  rule [forFirstArgV2Red]: 'For(('LocalVarDec(Ks:List{K}) => stm('LocalVarDec(Ks))),,_:List{K})
    [structural]
  rule [forSecondArgRed]: 'For(_:K,,('None(.List{K}) => 'Some(true)),,_:List{K})
    [structural]
  rule [forThirdArgRed]: 'For(_:K,,_:K,,('ListWrap(UpdExps:List{K}) => stm('ListWrap(UpdExps))),,_:K)
    [structural]

  rule [for]: 'For(stm(K1:K),, 'Some(TestExp:K),, stm(K2:K),, S:K) => 'Block('ListWrap(stm(K1),, 'While(TestExp,,(S ~> stm(K2)))))
    [structural]

//@ \subsection{Variable declarations}

  //local var decs and field decs are reduced to a single case
  rule 'LocalVarDecStm('LocalVarDec(_,, TypeK:K,, 'ListWrap(Ks)))
    => 'LocalVarDec(TypeK,, 'ListWrap(Ks))
    [structural]

  rule 'FieldDec(_,, TypeK:K,, 'ListWrap(Ks))
    => 'LocalVarDec(TypeK,, 'ListWrap(Ks))
    [structural]

  rule 'LocalVarDec(TypeK,, 'ListWrap(Var1:K,, Var2:K,, VarDecs:List{K} ))
    => 'LocalVarDec(TypeK,, 'ListWrap(Var1))
    ~> 'LocalVarDec(TypeK,, 'ListWrap(Var2,, VarDecs))
    [structural]

  rule 'LocalVarDec(TypeK,, 'ListWrap('VarDec(X1:#Id,,K3:K)))
    => 'LocalVarDec(TypeK,, 'ListWrap('VarDec(X1:#Id)))
    ~> 'ExprStm('Assign('ExprName(X1),, K3))
    [structural]

/*@ \subsection{Values and results}
These are similar to those of untyped SIMPLE, except that the array
references and the function abstrations now also hold their types.
These types are needed in order to easily compute the type of any
value inthe language (see the auxiliary \texttt{typeOf} operation at
the end of this module).  Note that our more-generous-than-needed
syntax here allows function abstractions to take a list of expressions
as parameters; in fact, the semantics will be given in a way that
those expressions can only be typed identifiers.  Recall that the
purpose of syntax in a \K definition is not to parse programs in order
to reject those not satisfying the expected syntactic/typing
conventions (this is what a static semantics does---see the statically
typed SIMPLE), but only to parse programs ``enough'' to give them
semantics.  In other words, the \K syntax is the ``syntax of the
semantics''.  */

  syntax Val ::= #Int | #Bool | #String
               | "arrayRef" "(" Type "," #Int "," #Int ")"
               | "printMethodVal"
               | "readMethodVal"

  syntax Vals ::= List{Val,","}
  syntax Exp ::= Val
  syntax KResult ::= Val | Type

  syntax #Id ::= "object"

/*@ \subsection{Object and method closures}
The only change to untyped KOOL's values is that closures are now typed
(their last argument holds their type). */

syntax Val ::= "objectClosure" "(" Bag ")"
              | "methodClosure" "(" #Id "," #Int "," K "," K "," Type ")"

/*@ \subsection{Configuration}
The configuration is almost identical to that of untyped SIMPLE,
except for a \textsf{return} cell inside the \textsf{control} cell.
This \textsf{return} cell will hold, like in the static semantics of
typed SIMPLE, the expected type of the value returned by the function
being executed.  The contents of this cell will be set whenever a
function is invoked and will be checked whenever the evaluation of the
function body encounters an explicit \texttt{return} statement. */

  configuration <T color="red">
                  <threads color="orange">
                    <thread multiplicity="*" color="yellow">
                      <k color="green"> ($PGM:K ~> execute) </k>
                      <env color="violet"> .Map </env>
                      <holds color="black"> .Map </holds>
                      <br/>
                      <control color="cyan">
                        <stack color="blue"> .List </stack>
                        //todo this cell contained originally .K
                        //why it worked?
                        <return color="LimeGreen"> void </return>
                          // holds return type
                        <br/>
                        <crntObj color="Fuchsia">
                          <crntClass> object </crntClass>
                          <envStack> .List </envStack>
                          <location multiplicity="?"> .K </location>
                        </crntObj>
                       </control>
                    </thread>
                  </threads>
                  <br/>
                  <store color="white"> .Map </store>
                  <busy color="cyan">.Set</busy>
                  <in color="magenta" stream="stdin"> .List </in>
                  <out color="brown" stream="stdout"> .List </out>
                  <nextLoc color="gray"> 0 </nextLoc>
                  <br/>
                  <classes color="Fuchsia">
                     <class multiplicity="*" color="Fuchsia">
                        <className color="Fuchsia"> main </className>
                        <extends color="Fuchsia"> object </extends>
                        <declarations color="purple"> .K </declarations>
						<metatype color="Fuchsia"> "concrete class" </metatype>
                     </class>
                  </classes>
                </T>

//@ \subsection{Types}
//@Here we rewrite java type ast into simple types

  //workaround to declare String of type #Id.
  //don't work.
  //op String : -> #Id
  //eq String =  #id ("String")

  syntax #Id ::= "string"

  rule 'Int(_) => int [structural]
  rule 'Boolean(_) => bool [structural]
  rule 'Void(_) => void [structural]
  rule 'ClassOrInterfaceType('TypeName(K),,_) => 'TypeName(K) [structural]
  rule 'TypeName(X) => class X  [structural]
  rule class string => rtString  [structural]

  context 'ArrayType(HOLE)
  rule 'ArrayType(T) => arrayOf T [structural]

/*@ \subsection{Unchanged Semantics from SIMPLE}
The semantics below is taken over from dynamically typed SIMPLE
unchanged.  Like for untyped KOOL, the semantics of function/method
declaration and invocation, and of program initialization needs to
change.  Moreover, due to subtyping, the semantics of several imported
SIMPLE constructs can be made more general, such as that of the
return statement and of the the assignment.  Finally, since the
exceptions are now typed, they also need a different semantics.  We
removed all these from the imported semantics of SIMPLE below and gave
their typed KOOL semantics right after, together with the extended
semantics of thread spawning (which is identical to that of untyped
KOOL).  */

//@ \subsection{Declarations and Initializations}

/*@ The ``undefined'' construct is now parameterized by a type.
A main difference between untyped SIMPLE and dynamically typed SIMPLE
is that the latter assigns a type to each of its locations and that
type cannot be changed during the execution of the program.  We do not
do any memory management in our semantic definitions here, so
locations cannot be reclaimed, garbage collected and/or reused.  Each
location corresponds precisely to an allocated variable or array
element, whose type was explicitly or implicitly declared in the
program and does not change.  It is therefore safe to type each
location and then never allow that type to change.  The typed
undefined values effectively assign both a type and an undefined value
to a location.

In Java-Simple we'll support only int and boolean types for variables*/

  syntax Val ::= "undefined" "(" Type ")" [:latex("\bot_{#1}"):]

  context 'LocalVarDec(HOLE,,_)
  rule <k> 'LocalVarDec(T:Type,,'ListWrap('VarDec(X:#Id))) => . ...</k>
       <env> Env:Map => Env[L:#Int/X] </env>
       <store>... . => L |-> undefined(T) ...</store>
       <nextLoc> L => L +Int 1 </nextLoc>

/*@ The dynamic semantics of typed array declarations is
similar to that in untyped SIMPLE, but we have to enforce that the
type of an array declaration be of the form \texttt{arrayOf $T$}
and assign the right type ($T$) to the allocated array locations. */

//@ Array semantics

  context 'NewArray(HOLE,, _:List{K})
  rule [arrayEmptyDims]: 'NewArray((T => arrayOf T),,_,,'ListWrap(('Dim(.List{K}) => .List{K}) ,,_:List{K})) [structural]

  rule 'NewArray(T,, K,, 'ListWrap(.List{K}))
          => newArrayImpl(T, K, undefined(T)) [structural]

  syntax K ::= "newArrayImpl" "(" Type "," K "," K ")"
  rule [multiDimArrayAlloc]: newArrayImpl(T, 'ListWrap(Dims:List{K},,Dim1K:K,,Dim2K:K), InitExp) => newArrayImpl(arrayOf T, 'ListWrap(Dims,,Dim1K), newArrayImpl(T, 'ListWrap(Dim2K), InitExp)) [structural]

  context newArrayImpl(_:KResult, 'ListWrap('Dim(HOLE)), _)
  rule [arrayAlloc]: <k> newArrayImpl(T, 'ListWrap('Dim(NI:#Int)), InitExp:K)
          => evalAndStore((LI .. LI +Int _-Int_(NI,1)),InitExp) ~> arrayRef( arrayOf T, LI, NI) ...</k>
       <store>... . => LI .. LI +Int _-Int_(NI,1) |-> undefined(void) ...</store>
       <nextLoc> LI:#Int => LI +Int NI </nextLoc>

  syntax K ::= "evalAndStore" "(" List{K}  "," K ")"
  rule evalAndStore((I1,,I2,,Ks),InitExp) => evalAndStore(I1,InitExp) ~> evalAndStore((I2,,Ks),InitExp)
    [structural]
  context evalAndStore(_:KResult, HOLE)
  rule <k> evalAndStore(I,V) =>. ...</k>
       <store>... I |->(_=>V) ...</store>
  rule evalAndStore(.List{K}, _) => . [structural]

/*@ \subsection{Method declaration}
Methods are now typed and we need to store their types in their
closures, so that their type contract can be checked at invocation
time.  The rule below is conceptually similar to that of untyped KOOL;
the only difference is the addition of the types.  */

  context 'MethodDec('MethodDecHead(_:K,, _:K,, HOLE,, _:List{K}),, _)
  rule [methodDec]: <k> 'MethodDec('MethodDecHead(_,, _,, ReturnType:Type,,
         Name:#Id,, 'ListWrap(Params:List{K}),, _),, S:K)
         => storeMethod(Name, 'ListWrap(Params), S, function from Params to ReturnType) ...</k>
    [structural]

  syntax K ::= "storeMethod" "(" #Id "," K "," K "," Type ")"
  rule [storeMethod]: <k> storeMethod(Name, 'ListWrap(Params), S, MethodType:Type) =>. ...</k>
       <crntClass> Class:#Id </crntClass>
       <location> OL:#Int </location>
       <env> Env => Env[L/Name] </env>
       <store>...
         .  => L |-> methodClosure(Class, OL, 'ListWrap(Params), S, MethodType)
       ...</store>
       <nextLoc> L => L +Int 1 </nextLoc>

  context storeMethod(_, _, _, function from (_:List{K},, (HOLE => typeOf(HOLE)),, _:List{K}) to _)

/*@ \subsection{Program initialization}
When done with the first pass, call \texttt{main()}. */

  rule [firstPass]: <k> 'CompilationUnit(_,,_,,K:K) => K ...</k>

  syntax K ::= "execute"
  rule [execution]: <k> execute =>
        //k-ast for new main();
        'ExprStm(
          'NewInstance(
            'None(.List{K}),,
            'ClassOrInterfaceType(
              'TypeName(main),,
              'None(.List{K})
            ),,
            'ListWrap('NewArray(
                'TypeName(string),,
                'ListWrap('Dim(0)),,
                'ListWrap(.List{K}))),,
            'None(.List{K})
          )
        )
       </k>
       <env> . </env>  [:structural:]

//@ \subsection{Expressions and statements}

  rule 'ExprName(X) => X

  rule <k> 'Method('MethodName(X)) => X ...</k>
       <env> Env </env>
    when X in keys(Env)
      orBool X ==Bool read orBool X ==Bool print [structural]

  //todo maybe this rule should generate something like the rule below
  rule <k>
    'Method('MethodName(X)) =>
    'Method(
      'This(.List{K}),,
      'None(.List{K}),,
      X
    )
    ...</k>
       <env> Env </env>
    when notBool(X in keys(Env))
      andBool notBool (X ==Bool read orBool X ==Bool print) [structural]

    context 'Method('MethodName(HOLE,,_:K))
    context 'ExprName(HOLE,,_:K)
    rule 'AmbName(X) => X

  rule [lookup]: <k> X => V:Val ...</k>
       <env>...X|->L...</env>
       <store>...L|->V...</store> [:transition:]

  context 'PreIncr(HOLE => lvalue(HOLE))

  rule <k> 'PreIncr(loc(L)) => I:#Int +Int 1 ...</k>
       <store>... L |-> (I => I +Int 1) ...</store> [:transition:]

  context 'Plus(HOLE,,_)
  context 'Plus(_:KResult,,HOLE)
  rule 'Plus(I1:#Int,,I2:#Int) => I1 +Int I2
  rule 'Plus(Str1:#String,,Str2:#String) => Str1 +String Str2
  rule 'Plus(Str1,,I) => Str1 +String Int2String(I)

  context 'Minus(HOLE,,_)
  context 'Minus(_:KResult,,HOLE)
  rule 'Minus(I1,,I2) => _-Int_(I1,I2)

  context 'Mul(HOLE,,_)
  context 'Mul(_:KResult,,HOLE)
  rule 'Mul(I1,,I2) => I1 *Int I2

  context 'Div(HOLE,,_)
  context 'Div(_:KResult,,HOLE)
  rule 'Div(I1,,I2) => I1 /Int I2 when I2 =/=Bool 0

  context 'Remain(HOLE,,_)
  context 'Remain(_:KResult,,HOLE)
  rule 'Remain(I1,,I2) => I1 %Int I2 when I2 =/=Bool 0

  context 'Minus(HOLE)
  rule 'Minus(I) => -Int I

  context 'Lt(HOLE,,_)
  context 'Lt(_:KResult,,HOLE)
  rule 'Lt(I1,,I2) => I1 <Int I2

  context 'LtEq(HOLE,,_)
  context 'LtEq(_:KResult,,HOLE)
  rule 'LtEq(I1,,I2) => I1 <=Int I2

  context 'Gt(HOLE,,_)
  context 'Gt(_:KResult,,HOLE)
  rule 'Gt(I1,,I2) => I1 >Int I2

  context 'GtEq(HOLE,,_)
  context 'GtEq(_:KResult,,HOLE)
  rule 'GtEq(I1,,I2) => I1 >=Int I2

  context 'Eq(HOLE,,_)
  context 'Eq(_:KResult,,HOLE)
  rule 'Eq(V1:Val,,V2:Val) => V1 ==Bool V2

  context 'NotEq(HOLE,,_)
  context 'NotEq(_:KResult,,HOLE)
  rule 'NotEq(V1,,V2) => V1 =/=Bool V2

  context 'LazyAnd(HOLE,,_)
  rule 'LazyAnd(true,,K) => K
  rule 'LazyAnd(false,,_) => false

  context 'LazyOr(HOLE,,_)
  rule 'LazyOr(true,,_) => true
  rule 'LazyOr(false,,K) => K

  context 'Not(HOLE)
  rule 'Not(B:#Bool) => notBool(B)

//@ Check array bounds, as part of the dynamic typing policy.

  context 'ArrayAccess(HOLE,,_)
  context 'ArrayAccess(_:KResult,,HOLE)

  rule [arrayLookup]:
      'ArrayAccess(arrayRef(_,L,M:#Int),, N:#Int) => lookup(L +Int N)
    when N >=Int 0 andBool N <Int M   [structural anywhere]

  rule sizeOf(arrayRef(_,_:#Int,N)) => N

/*@\subsection{Method invocation}
The method lookup is the same as in untyped KOOL.
The method closure application and return are slightly different,
since we need to check that the type of the returned value is an
instance of the claimed return type of the method.  The first group of
rules below are identical to those in untyped KOOL. */

  //context HOLE._(_)
  context 'Method(HOLE,, _:K,, _:#Id)

  //todo investigate which of two rules is really needed
  //objClos.X(_) => lookupMember(objClos,X)(_)
  rule <k> 'Method(
    objectClosure(Obj <envStack> EStack </envStack>),, _:K,, X) =>
    lookupMember(<envStack> EStack </envStack>, X)
    ...</k> [structural]

  //objClos.X(_) => lookupMember(objClos,X)(_)
  rule <k> 'Method('MethodName(
    objectClosure(Obj <envStack> EStack </envStack>),, X)) =>
    lookupMember(<envStack> EStack </envStack>, X)
    ...</k> [structural]

  // super.X(_) => lookupMember(... , )(_)
  rule <k> 'SuperMethod(_,, X)
        => lookupMember(<envStack> EStack </envStack>, X) ...</k>
       <crntClass> Class:#Id </crntClass>
       <envStack>... ListItem(Class :: _) EStack </envStack>
    [structural]

/*@ Closure application needs to also set a new return type in the
\textsf{return} cell, in order for the values returned by its body to
be checked against the return type of the method.  To do this correctly,
we also need to stack the current status of the \textsf{return} cell
and then pop it when the method returns. */

  context 'Invoke(HOLE,,  _)
  context 'Invoke(_,,'ListWrap(_:List{K},,HOLE,,_:List{K}))

  rule [methodInvocation]: <k>
  'Invoke(methodClosure(Class, OL:#Int, 'ListWrap(Params), S, function from _ to T),,
          'ListWrap(ParamValues:List{KResult})) ~> K
         => bindto Params, ParamValues ~> S ~> 'Return('None(.List{K}))
       </k>
       <control> C:Bag
         <stack> . => ListItem(("return",0,0,K, Env,
            C <crntObj> Obj2 </crntObj>
              <return> T2 </return>)) ...</stack>
         <crntObj> Obj2:Bag => <crntClass>Class</crntClass> Obj </crntObj>
         <return> T2:Type => T </return>
       </control>
       <env> Env => . </env>
       <store>... OL |-> objectClosure(<crntClass>_:#Id</crntClass>Obj:Bag)
       ...</store>

/*@ At method return, we have to check that the type of the returned
value is a subtype of the expected return type.  Moreover, if that is
the case, then we also upcast the returned value to one of the
expected type. */

  context 'Return('Some(HOLE))

  syntax Val ::= "nothing"
  rule 'Return('None(.List{K}) => 'Some(nothing)) [structural]

  rule <k> 'Return('Some(V)) ~> _
  => subtype typeOf(V), T ~> true? ~> unsafeCast(V, T) ~> K </k>
       <control>
         <stack> ListItem(("return",_,_,K,Env,C)) => . ...</stack>
         (<return> T </return> _ => C)
       </control>
       <env> _ => Env </env>

   rule <k> (. => FinallyS) ~> 'Return('Some(V)) ...</k>
       <control>
         <stack> ListItem(("finally",_,FinallyS,_,Env,C)) => . ...</stack>
         (_ => C)
       </control>
       <env> _ => Env </env>

   rule <k> 'Return('Some(V)) ...</k>
        <stack> ListItem((LayerType,_,_,_,_,_:Bag)) => . ...</stack>
	 when LayerType =/=Bool "return" andBool LayerType =/=Bool "finally"

  syntax #Id ::= "read"

  rule <k> read => readMethodVal ...</k>
  rule <k> 'Invoke(readMethodVal,, 'ListWrap(.List{K})) => I ...</k>
       <in> ListItem(I) => . ...</in> [:transition:]

  rule 'Block('ListWrap(.List{K})) => . [:structural:]

  rule <k> 'Block('ListWrap(Ss:List{K})) => 'ListWrap(Ss)~>env(Env) ...</k>
       <env> Env </env> [:structural:]

  rule 'ListWrap(S1:K) => S1                          [:structural:]
  rule [sequenceOfStatements]: 'ListWrap(S1,,Ss) => S1 ~> 'ListWrap(Ss)            [:structural:]

  context 'ExprStm(HOLE)
  rule 'ExprStm(V) => .

  context 'If(HOLE,, _,, _)
  rule 'If(true,, S,, _) => S
  rule 'If(false,, _,, S) => S

  rule <k> 'While(E:K,,S:K) => 'If(E,,
             'Block('ListWrap(S,,'While(E,,S))),,
             'Block('ListWrap(.List{K}))) ...</k> [:structural:]

//@ We only allow printing integers and strings
  syntax #Id ::= "print"

  rule <k> print => printMethodVal ...</k>

  rule <k> 'Invoke(printMethodVal,, 'ListWrap(V,,Vals:List{KResult} => Vals)) ...</k>
       <out>... .=>ListItem(V)</out>
    when typeOf(V) ==Bool int orBool typeOf(V) ==Bool rtString  [:transition:]

  rule <k> 'Invoke(printMethodVal,, 'ListWrap((V => typeOf(V)),,Vals:List{KResult})) ...</k>
    when typeOf(V) =/=Bool int andBool typeOf(V) =/=Bool rtString  [:transition:]

  rule <k> 'Invoke(printMethodVal,, 'ListWrap((class Class => Id2String(Class)),,
      Vals:List{KResult})) ...</k>
    [:transition:]

  rule 'Invoke(printMethodVal,,'ListWrap(.List{K})) => nothing  [:structural:]

/*@ \subsubsection{Typed exceptions}
Exceptions are propagated now until a catch that can bind them is
encountered. */

  rule [tryCatchFinallyDesugar]: 'Try(TryS:K,, 'ListWrap( K,,Ks),,FinallyS:K)
    => 'Try('Try(TryS,,'ListWrap( K,,Ks)),,'ListWrap(.List{K}),,FinallyS)

  rule [tryCatchCatchDesugar]: 'Try(TryS,, 'ListWrap( Ks,,K1,,K2))
    => 'Try('Try(TryS,, 'ListWrap( Ks,,K1)),, 'ListWrap(K2))

  syntax K ::= "(" #String "," K "," K "," K "," Map "," Bag ")"
  syntax K ::= "popx"

  //eval the type of catch argument
  context 'Try(_:K,,'ListWrap('Catch('Param(_:K,, HOLE,, _),, _)))

  rule <k> (
        'Try(TryS:K,, 'ListWrap(
          'Catch(CatchParam:K,, CatchS:K)))
          => TryS ~> popx ) ~> K
       </k>
       <control> <stack> . => ListItem(("catch",CatchParam,CatchS,K,Env,C)) ...</stack> C:Bag </control>
       <env> Env </env>
  rule <k> popx => . ...</k> <stack> _:ListItem => . ...</stack>

/*@ \subsubsection{Typed exceptions - finally clause}
Now stack may hold two types of layers specific to exceptions - a catch layer or a finally layer.
Both should be threated separately when a throw statement is encountered.*/

  rule [tryFinally]: <k> ('Try(TryS:K ,,'ListWrap(.List{K}),,FinallyS:K) => TryS ~> popx ~> FinallyS) ~> K </k>
       <control> <stack> . => ListItem(("finally",0,FinallyS,.K,Env,C)) ...</stack> C:Bag </control>
       <env> Env </env>

/*@ \subsubsection{throw statement}*/

  context 'Throw(HOLE)
  rule <k> 'Throw(V) ~> _:K
          =>  'If( (subtype typeOf(V), T),, 'Block('ListWrap('LocalVarDecStm('LocalVarDec( 'ListWrap(.List{K}) ,,
              T,, 'ListWrap('VarDec(X ,, V)))),, CatchS)),, 'Throw(V)) ~> K
       </k>
       <control> <stack> ListItem(("catch", 'Param(_:K,, T,, X:#Id) ,CatchS,K,Env,C)) => . ...</stack> (_ => C) </control>
       <env> _ => Env </env>

  rule [throwReachesFinallyBlock]: <k> (. => FinallyS) ~> 'Throw(_:Val) ...</k>
       <control>
         <stack> ListItem(("finally",_,FinallyS,_,Env,C)) => . ...</stack>
         (_ => C)
       </control>
       <env> _ => Env </env>

  rule <k> 'Throw(_:Val) ...</k>
       <stack> ListItem((LayerType:#String,_,_,_,_,_:Bag)) => . ...</stack>
    when LayerType =/=Bool "catch" andBool LayerType =/=Bool "finally"


/*@ \subsubsection{Thread termination}*/
//todo strange bug in print - the last argument is not printed
//activated only by this rule
//todo bug 2 - sometimes this is not printed. Even with the next rule present.

  rule <k> 'Throw(V) ~> _:K =>
       'ExprStm('Invoke(printMethodVal,, 'ListWrap("Thread terminated with exception: ",,V,,"\n")))
       </k>
       <stack> .List </stack>

   rule (<thread>... <k>.K</k> <holds> H:Map </holds> ...</thread> => .)
        <busy> Busy:Set => Busy -Set keys(H) </busy>

//@ \subsection{Auxiliary operations}

//@ \texttt{lvalue}
  syntax Exp ::= "lvalue" "(" K ")"
  syntax Val ::= "loc" "(" #Int ")"
  rule <k> lvalue('ExprName(X)) => loc(L) ...</k>
       <env>... X|->L ...</env>  [:structural:]

  context lvalue('ArrayAccess(HOLE,,_))
  context lvalue('ArrayAccess(_:KResult,,HOLE))
  rule <k> lvalue(lookup(L)) => loc(L) ...</k>  [:structural:]

//@ \texttt{lookup}
  syntax K ::= "lookup" "(" #Int ")"
  rule <k> lookup(L) => V ...</k> <store>... L |-> V ...</store> [:transition:]

//@ \texttt{bindto} also checks the well-formedness of the function parameters

  syntax K ::= "bindto" List{K} "," List{KResult}

  context bindto('Param(_:K,,HOLE,,_),, _:List{K}), _:List{K}

  rule <k> (. => 'ExprStm('Assign('ExprName(X),,V))) ~> bindto('Param(_,,T,,X),, Params => Params),
        (V,,ParamValues => ParamValues) ...</k>
       <env> Env => Env[L/X] </env>
       <store>... . => L |-> undefined(T) ...</store>
       <nextLoc> L => L +Int 1 </nextLoc>
  rule <k> bindto .List{K},.List{K} => . ...</k>  [:structural:]

//@ \texttt{env}
  syntax K ::= "env" "(" Map ")"
  rule <k> env(Env) => . ...</k> <env> _ => Env </env> [:structural:]
  rule (env(_) => .) ~> env(_) [:structural:]

//@ \texttt{typeOf}
  declare typeOf :  K -> Type
  define typeOf(I) => int
  define typeOf(B) => bool
  define typeOf(_:#String) => rtString

  define typeOf(arrayRef(T,_:#Int,_:#Int)) => T

  define typeOf(undefined(T)) => T
  define typeOf(nothing) => void

  define typeOf(objectClosure(_ <envStack> ListItem(Class::_) ...</envStack>))
    => class Class
  define typeOf(methodClosure(_:#Id,_:#Int,_,_,T)) => T

  define typeOf('Param(_:K,,K,,_)) => K

  declare types : Exps ->  Types
  define types(.Exps) => void,.Types
  define types(X : T,.Exps) => T,.Types
  define types(X : T, EE:Exp, EEs:Exps) => T, types(EE,EEs)

/*@ Recall that lists of the form "a,b,c" are a syntactic convenience,
which eventually are translated into cons-lists "(a,(b,(c,.)))".
Unfortunately, the current K tool is not able to cons-listify
the RHSes of the rules below, so we have to do it manually.  */

//@ Sequences of locations

  syntax List{K} ::= #Int ".." #Int
  define N1:#Int..N2:#Int => .List{K}              when N1  >Int N2 [:structural:]
  define N1:#Int..N2:#Int => N1 ,, (N1 +Int 1)..N2 when N1 <=Int N2 [:structural:]

/*@ \subsection{Changes to SIMPLE Semantics}
We extend/change the semantics of several SIMPLE constructs in order
to take advantage of the richer KOOL semantic infrastructure and thus
get more from the existing SIMPLE constructs. */

/*@ \subsubsection{Subtyping constraints}
The subclass relation introduces a subtyping relation. */

  syntax K ::= "subtype" List{KResult} "," List{KResult}

  rule subtype T,T => true  [structural]
  rule subtype(T1:Type,,T2:Type,,Ts:List{KResult}), (Tp1:Type,,Tp2:Type,,Tps:List{KResult})
    => subtype T1,Tp1 ~> true? ~> subtype (T2,,Ts),(Tp2,,Tps)  [structural]

  rule <k> subtype class Class1, class Class
        => subtype class Class2, class Class ...</k>
       <className> Class1 </className> <extends> Class2 </extends>
    when Class1 =/=Bool Class  [structural]

  rule subtype class object, class Class => false
    when Class =/=Bool object

  rule subtype .List{K}, .List{K} => true  [structural]

/*@ \subsubsection{Unsafe Casting}
Performs unsafe casting.  One should only use it in combination with
the subtype relation above.  */

  declare unsafeCast : Val Type -> Val
  define unsafeCast(V,T) => V when typeOf(V) ==Bool T

  define unsafeCast(objectClosure(<crntClass>_:K </crntClass> Obj), class Class)
    => objectClosure(<crntClass> Class </crntClass> Obj)

/*@ \subsubsection{Generic guard}
A generic computational guard (should be builtin): it allows the
computation to continue only if a prefix guard evaluates to true.  */

  syntax K ::= "true?"
  rule true ~> true? => .  [structural]

/*@ \subsubsection{Assignment}
Typed KOOL allows to assign subtype instance values to supertype lvalues. */

  //assignment is seqstrict according to JLS
  context 'Assign((HOLE => lvalue(HOLE)),,_)
  context 'Assign(_:KResult,,HOLE)

  rule <k> 'Assign(loc(L),,V) => subtype typeOf(V), typeOf(K) ~> true?
           ~> unsafeCast(V,typeOf(K:K)) ...</k>
       <store>... L |-> (K => unsafeCast(V, typeOf(K))) ...</store> [:transition:]

/*@ \subsection{Class declaration}
Like in untyped KOOL. */

  rule [classWithoutExtendsDesugar]:
    'ClassDec('ClassDecHead(_:K,, ClassName:#Id,,
        _:K,,
        ('None(_) => 'Some('SuperDec('ClassType('TypeName(
                object ),, 'None(.List{K}))))  ),,
        _:K),, _:K
    ) [structural]

  rule <k>
    'ClassDec('ClassDecHead(_:K,, ClassName:#Id,,
        _:K,,
        'Some('SuperDec('ClassType('TypeName(
                BaseClassName:#Id
              ),, _:K))),, _:K),,
      'ClassBody( S )
    ) => .
    ...</k>
     <classes>... (. => <class>
                          <className> ClassName </className>
                          <extends> BaseClassName </extends>
                          <declarations> S </declarations>
                      </class>)
     ...</classes>  [structural]

/*@ \subsection{New}
The semantics of \texttt{new} in dynamically typed KOOL is also
similar to that in untyped KOOL, the main difference being the
management of the return types.  Indeed, when a new object is created
we also have to stack the current type in the \textsf{return} cell in
order to be recovered after the creation of the new object.  Only the
first rule below needs to be changed; the others are identical to
those in untyped KOOL. */

  context 'NewInstance(_:K,,_:K,, 'ListWrap(_,,HOLE,,_),, _)

  rule <k>
    'NewInstance(
      _:K,,
      'ClassOrInterfaceType('TypeName(
        ClassName
      ),, _:K),,
      'ListWrap(
        Vals
      ),,
      _:K
    ) ~> K
       => create(ClassName) ~>
          storeObj ~>
          'ExprStm('Invoke(
              'Method('MethodName(
                ClassName
              )),,
              'ListWrap(
                Vals
              )
          )) ~>
          'Return('Some('This( .List{K} )))
       </k>

       <env> Env => . </env>
       <control> C:Bag
         <crntObj> Obj:Bag
                => <crntClass> object </crntClass>
                   <envStack> ListItem(object::<env>.Map</env>) </envStack>
                   <location> L </location>
         </crntObj>
         <return> T => class ClassName </return>
         <stack> . => ListItem(("return",0,0, K, Env, C <return> T </return>
         <crntObj> Obj </crntObj>)) ...</stack>
       </control>
       <nextLoc> L => L +Int 1 </nextLoc>

  syntax K ::= "create" "(" K ")"
  rule <k> create(Class:#Id)
        => create(BaseClass:#Id) ~> setCrntClass(Class) ~> S ~> addEnvLayer ...</k>
       <className> Class </className>
       <extends> BaseClass </extends>
       <declarations> S </declarations>  [:structural:]
  rule <k> create(object) => . ...</k>    [:structural:]

  syntax K ::= "setCrntClass" "(" #Id ")"
  rule <k> setCrntClass(Class) => . ...</k>
       <crntClass> _ => Class </crntClass>  [:structural:]

  syntax K ::= "addEnvLayer"
  rule <k> addEnvLayer => . ...</k>
       <env> Env => . </env>
       <crntClass> Class </crntClass>
       <envStack> . => ListItem(Class::<env>Env</env>) ...</envStack>
    [:structural:]

  syntax K ::= storeObj
  rule <k> storeObj => . ...</k>
       <crntObj> Obj (<location> L </location> => .) </crntObj>
       <store>... . => L |-> objectClosure(Obj) ...</store>

/*@ \subsection{Self reference}
Like in untyped KOOL. */

  rule <k> 'This(.List{K}) => objectClosure(Obj) ...</k>
       <crntObj> Obj </crntObj>

/*@ \subsection{Object member access}
Like in untyped KOOL. */

  rule <k> X => 'Field('This(.List{K}),, X)
    ...</k> <env> Env </env>
    when notBool(X in keys(Env))  [:structural:]

  //kast for HOLE._
  context 'Field(HOLE,, _)

  //todo check which of two rules below is really needed
  //o.x
  rule <k> 'Field(objectClosure(<crntClass> Class </crntClass>
                   <envStack>... ListItem(Class :: EnvC:BagItem) EStack:List </envStack>),,X)
        => lookupMember(<envStack>ListItem(Class :: EnvC) EStack</envStack>, X)
       ...</k>  [:structural:]

  //o.x
  rule <k> 'ExprName(objectClosure(<crntClass> Class </crntClass>
                   <envStack>... ListItem(Class :: EnvC:BagItem) EStack:List </envStack>),,X)
        => lookupMember(<envStack>ListItem(Class :: EnvC) EStack</envStack>, X)
       ...</k>  [:structural:]

  rule <k>'SuperField(X) => lookupMember(<envStack>EStack</envStack>, X) ...</k>
       <crntClass> Class:#Id </crntClass>
       <envStack>... ListItem(Class :: EnvC) EStack </envStack>
    [:structural:]

/*@ \subsection{Instance Of}
Like in untyped KOOL. */

  context 'InstanceOf(HOLE,,_)
  context 'InstanceOf(_:KResult,,HOLE)

  rule 'InstanceOf( objectClosure((_ <envStack>ListItem(Class::_)...</envStack>)),, class Class) => true

  rule 'InstanceOf( objectClosure((_ <envStack> ListItem(Class1:#Id::_)
                       => . ...</envStack>)),, class Class2:#Id)
    when Class1 =/=Bool Class2  [:structural:]

  rule 'InstanceOf( objectClosure((_ <envStack> .List </envStack>)),, class Class)
    => false

/*@ \subsection{Cast}
Unlike in untyped KOOL, in typed KOOL we actually check that the object
can indeed be cast to the claimed type. */

  context 'CastRef(HOLE,,_)
  context 'CastRef(_:KResult,,HOLE)

  rule <k> 'CastRef(class Class,, objectClosure((<crntClass> _:K </crntClass> Obj)) )
        => 'InstanceOf( objectClosure(Obj),, class Class) ~> true?
             ~> objectClosure(<crntClass> Class </crntClass> Obj) ...</k>
    [structural]

/*@ \subsection{Objects as lvalues}
Like in untyped KOOL. */

  rule <k> lvalue('ExprName(X) => 'Field('This(.List{K}),, X) )
    ...</k> <env> Env </env>
    when notBool(X in keys(Env))  [:structural:]

  context lvalue('Field(HOLE,,_:#Id) )

  rule <k> lvalue('Field(objectClosure(<crntClass> Class </crntClass>
                           <envStack>...
                             ListItem(Class :: EnvC) EStack
                           </envStack>),, X)
        => lookupMember(<envStack>ListItem(Class :: EnvC:BagItem) EStack:List
                        </envStack>, X))
       ...</k>  [:structural:]

/*@ \subsection{Lookup member}
Like in untyped KOOL. */

  syntax K ::= #Id "::" Bag
  declare lookupMember : BagItem #Id -> K
  define lookupMember(<envStack> ListItem(_:#Id :: <env>...X|->L...</env>)
                    ...</envStack>,X) => lookup(L)
  define lookupMember(<envStack> ListItem(_:#Id :: <env> Env </env>)
                            => . ...</envStack>, X)
    when notBool(X in keys(Env))

end module
