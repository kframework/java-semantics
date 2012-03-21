module JAVA-SIMPLE-SYNTAX

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
                | "function" #Id "(" Exps ")" ":" Type Stmt

//@ \subsection{Expressions}

  syntax Exp ::= #Int | #Bool | #String | #Id
               | "++" Exp              [:prec 0:]
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
               | Exp "(" Exps ")"      [:strict prec(2):]
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
                | "try" Stmt "catch" "(" #Id ")" Stmt   [:prec(90):]
                | "throw" Exp ";"                       [:strict:]
                | "spawn" Stmt                          [:prec(90):]
                | "acquire" Exp ";"                     [:strict:]
                | "release" Exp ";"                     [:strict:]
                | "rendezvous" Exp ";"                  [:strict:]

  syntax Stmts ::= Decl | Stmt
                 | Stmts Stmts                      [:prec(100) gather(e E):]

end module


module JAVA-SIMPLE
  imports JAVA-SIMPLE-SYNTAX

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
               | "lambda" "(" K "," K "," Type ")"
                     [:latex("(\lambda{#1}\,.\,{#2}):{#3}"):]
               | "printMethodVal"
               | "readMethodVal"
  syntax Vals ::= List{Val,","}
  syntax Exp ::= Val
  syntax KResult ::= Val | Type

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
                      <control color="cyan">
                        <fstack color="blue"> .List </fstack>
                        <xstack color="purple"> .List </xstack>
                        //todo this cell contained originally .K
                        //why it worked?
                        <return color="LimeGreen"> void </return>
                          // holds return type
                       </control>
                      <env color="violet"> .Map </env>
                      <holds color="black"> .Map </holds>
                    </thread>
                  </threads>
                  <br/>
                  <genv color="pink"> .Map </genv>
                  <store color="white"> .Map </store>
                  <busy color="cyan">.Set</busy>
                  <in color="magenta" stream="stdin"> .List </in>
                  <out color="brown" stream="stdout"> .List </out>
                  <nextLoc color="gray"> 0 </nextLoc>
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
  rule 'TypeName(string) => rtString  [structural]

  context 'ArrayType(HOLE)
  rule 'ArrayType(T) => arrayOf T [structural]

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

  syntax Val ::= "undefined" "(" K ")" [:latex("\bot_{#1}"):]

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

/*@ Store all function parameters, as well as the return type, as part
of the lambda abstraction.  In the spirit of dynamic typing, we will
make sure that parameters are well typed when the function is invoked. */

  context 'MethodDec('MethodDecHead(_:K,, _:K,, HOLE,, _:List{K}),, _)
  rule [functionDecl]: <k> 'MethodDec('MethodDecHead(_,, _,, T,,
         F:#Id,, 'ListWrap(Params:List{K}),, _),, S:K)
         => store(F, lambda('ListWrap(Params), S, function from Params to T)) ...</k>
    [structural]

  syntax K ::= "store" "(" #Id "," Val ")"
  rule [store]: <k> store(X,V) =>. ...</k>
       <env> Env => Env[L/X] </env>
       <store>... . => L |-> V ...</store>
       <nextLoc> L => L +Int 1 </nextLoc>

  context store(_, lambda(_, _,
    function from (_:List{K},, (HOLE => typeOf(HOLE)),, _:List{K}) to _))

/*@ \subsection{Calling \texttt{main()}}
When done with the first pass, call \texttt{main()}. */

  syntax K ::= "execute"
  rule <k> execute =>
        //k-ast for main(new String[0]);
        'ExprStm('Invoke(
            'Method('MethodName(main)),,
            'ListWrap('NewArray(
                'TypeName(string),,
                'ListWrap('Dim(0)),,
                'ListWrap(.List{K}))
            )
          ))
       </k>
       <env> Env </env> <genv> . => Env </genv>  [:structural:]

  rule [runMain]: <k> 'CompilationUnit(_,,_,,'ListWrap('ClassDec(_,,'ClassBody(
        K:K)),,_)) => K ...</k>

//@ \subsection{Expressions and statements}

  rule 'ExprName(X) => X
  rule 'Method('MethodName(X)) => X

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

  rule sizeOf(arrayRef(_,_,N)) => N

//@ Define function call and return together, to see their relationship.

  syntax K ::=  "(" Map "," K "," Bag ")"

  context 'Invoke(HOLE,,  _)
  context 'Invoke(_,,'ListWrap(_:List{K},,HOLE,,_:List{K}))

  rule <k> 'Invoke(lambda('ListWrap(Params), S, function from _ to T),,
          'ListWrap(ParamValues:List{KResult})) ~> K
         => bindto Params, ParamValues ~> S ~> 'Return('None(.List{K}))
       </k>
       <control>
         <fstack> . => ListItem((Env, K, <return> T' </return> C)) ...</fstack>
         <return> T':Type => T </return>
         C:Bag
       </control>
       <env> Env => GEnv </env>
       <genv> GEnv:Map </genv>

  context 'Return('Some(HOLE))

  syntax Val ::= "nothing"
  rule 'Return('None(.List{K}) => 'Some(nothing)) [structural]

  rule <k> 'Return('Some(V)) ~> _ => V ~> K </k>
       <control>
         <fstack> ListItem((Env,K,C)) => . ...</fstack>
         (<return> T </return> _ => C)
       </control>
       <env> _ => Env </env>
    when typeOf(V) ==Bool T

  syntax #Id ::= "read"

  rule <k> read => readMethodVal ...</k>
  rule <k> 'Invoke(readMethodVal,, 'ListWrap(.List{K})) => I ...</k>
       <in> ListItem(I) => . ...</in> [:transition:]

  //assignment is seqstrict according to JLS
  context 'Assign((HOLE => lvalue(HOLE)),,_)
  context 'Assign(_:KResult,,HOLE)

  rule <k> 'Assign(loc(L),,V) => V ...</k>
       <store>... L |-> (K => V) ...</store>
    when typeOf(V) ==Bool typeOf(K:K)   [:transition:]

  rule 'Block('ListWrap(.List{K})) => . [:structural:]

  rule <k> 'Block('ListWrap(Ss:List{K})) => 'ListWrap(Ss)~>env(Env) ...</k>
       <env> Env </env> [:structural:]

  rule 'ListWrap(S1:K) => S1                          [:structural:]
  rule 'ListWrap(S1,,Ss) => S1 ~> 'ListWrap(Ss)            [:structural:]

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
  rule 'Invoke(printMethodVal,,'ListWrap(.List{K})) => nothing  [:structural:]

  syntax K ::= "(" Exp "," Stmt "," K "," Map "," Bag ")"
  syntax K ::= "popx"

  rule <k> (
        'Try(TryS:K ,,'ListWrap(
          'Catch('Param(_:K,, 'Int(_),, X:#Id),, CatchS:K)))
          => TryS ~> popx ) ~> K
       </k>
       <control> <xstack> . => ListItem((X,CatchS,K,Env,C)) ...</xstack> C:Bag </control>
       <env> Env </env>
  rule <k> popx => . ...</k> <xstack> _:ListItem => . ...</xstack>

  context 'Throw(HOLE)
  rule <k> 'Throw(I) ~> _:K
          => 'Block('ListWrap('LocalVarDecStm('LocalVarDec('ListWrap(.List{K}) ,,
              'Int(.List{K}),, 'ListWrap('VarDec(X ,, I)))),, CatchS)) ~> K
       </k>
       <control> <xstack> ListItem((X,CatchS,K,Env,C)) => . ...</xstack> (_ => C) </control>
       <env> _ => Env </env>

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

  //bug: if we put _ instead of _:K below, as we should,
  //_ would match .List{K}, thus not a K value.
  context bindto('Param(_:K,,HOLE,,_),, _:List{K}), _:List{K}

  rule <k> bindto('Param(_,,T,,X),, Params => Params),
        (V,,ParamValues => ParamValues) ...</k>
       <env> Env => Env[L/X] </env>
       <store>... . => L |-> V ...</store>
       <nextLoc> L => L +Int 1 </nextLoc>
    when typeOf(V) ==Bool T
  rule <k> bindto .List{K},.List{K} => . ...</k>  [:structural:]

//@ \texttt{env}
  syntax K ::= "env" "(" Map ")"
  rule <k> env(Env) => . ...</k> <env> _ => Env </env> [:structural:]
  rule (env(_) => .) ~> env(_) [:structural:]

//@ \texttt{typeOf}
  syntax K ::= "typeOf" "(" K ")"
  rule typeOf(I) => int              [:structural anywhere:]
  rule typeOf(B) => bool             [:structural anywhere:]
  rule typeOf(_:#String) => rtString [:structural anywhere:]

  rule typeOf(arrayRef(T,_,_)) => T  [:structural anywhere:]
  rule typeOf(lambda(_,_,T)) => T    [:structural anywhere:]

  rule typeOf(undefined(T)) => T     [:structural anywhere:]
  rule typeOf(nothing) => void       [:structural anywhere:]

  rule typeOf('Param(_:K,,K,,_)) => K [structural]

/*@ Recall that lists of the form "a,b,c" are a syntactic convenience,
which eventually are translated into cons-lists "(a,(b,(c,.)))".
Unfortunately, the current K tool is not able to cons-listify
the RHSes of the rules below, so we have to do it manually.  */

//section types was deleted

//@ Sequences of locations

  syntax List{K} ::= #Int ".." #Int
  define N1:#Int..N2:#Int => .List{K}              when N1  >Int N2 [:structural:]
  define N1:#Int..N2:#Int => N1 ,, (N1 +Int 1)..N2 when N1 <=Int N2 [:structural:]

end module
