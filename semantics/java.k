module JAVA-CORE

  syntax #Id ::= "main" | "object"
  syntax K ::= "execute"

/*@ \section{Configuration}
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
                  <dissolveEmptyK> true </dissolveEmptyK>
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

//@ \section{Types}

  syntax Type ::= "int"
                | "bool"
                | "rtString"
                | "rtType"
                | "void"
                | "arrayOf" Type
                    [prec(1) latex "{#1}\texttt{\char91\char93}"]
                | "function" "from" List{KResult} "to" Type
                    [prec(1) latex "({#1}\ \texttt{->}\ {#2})"]
                | "class" #Id

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
  syntax Val ::= "undefined" "(" Type ")" [latex("\bot_{#1}")]
  syntax Val ::= "nothing"

  syntax KResult ::= Val | Type

/*@ \subsubsection{Generic guard}
A generic computational guard (should be builtin): it allows the
computation to continue only if a prefix guard evaluates to true.  */

  syntax K ::= "true?"
  rule true ~> true? => .  [structural]

/*@ \subsubsection{toString}
Converts various result types to string type, mainly for printing.*/

  declare toString :  KResult -> #String
  define toString(Str:#String) => Str
  define toString(I:#Int) => Int2String(I)
  define toString(true) => "true"
  define toString(false) => "false"
  define toString(class Class:#Id) => Id2String(Class)

end module

module JAVA-EXPRESSIONS
    imports JAVA-CORE

  syntax K ::= "lvalue" "(" K ")"
  syntax Val ::= "loc" "(" #Int ")"
  declare typeOf :  K -> Type
  syntax K ::= "subtype" List{KResult} "," List{KResult}
  declare unsafeCast : Val Type -> Val

//@ \section{Operators}

  syntax KLabel ::=
                  //Infix operators
                    /* ||  */ 'LazyOr      [strict(1)]
                  | /* &&  */ 'LazyAnd     [strict(1)]
                  | /* |   */ 'Or          [seqstrict]
                  | /* ^   */ 'ExcOr       [seqstrict]
                  | /* &   */ 'And         [seqstrict]
                  | /* ==  */ 'Eq          [seqstrict]
                  | /* !=  */ 'NotEq       [seqstrict]
                  | /* <   */ 'Lt          [seqstrict]
                  | /* >   */ 'Gt          [seqstrict]
                  | /* <=  */ 'LtEq        [seqstrict]
                  | /* >=  */ 'GtEq        [seqstrict]
                  | /* <<  */ 'LeftShift   [seqstrict]
                  | /* >>  */ 'RightShift  [seqstrict]
                  | /* >>> */ 'URightShift [seqstrict]
                  | /* +   */ 'Plus        [seqstrict]
                  | /* -   */ 'Minus       [seqstrict]
                  | /* *   */ 'Mul         [seqstrict]
                  | /* /   */ 'Div         [seqstrict]
                  | /* %   */ 'Remain      [seqstrict]

                  //Prefix operators
                  | /* ++  */ 'PreIncr
                  | /* --  */ 'PreDecr
                  | /* !   */ 'Not         [strict]
                  | /* ~   */ 'Complement  [strict]
                  | /* +   */ 'Plus        [strict]
                  | /* -   */ 'Minus       [strict]

                  //Postfix operators
                  | /* ++  */ 'PostIncr
                  | /* --  */ 'PostDecr

                  //Ternary operators
                  | /* ? : */ 'Cond

  rule /* true  || _ */ 'LazyOr(true,,_) => true
  rule /* false || K */ 'LazyOr(false,,K) => K
  rule /* true  && K */ 'LazyAnd(true,,K) => K
  rule /* false && _ */ 'LazyAnd(false,,_) => false

  rule /* I1 | I2 */ 'Or(I1,,I2) => I1 |Int I2
  rule /* B1 | B2 */ 'Or(B1:#Bool,,B2:#Bool) => B1 orBool B2
  rule /* I1 ^ I2 */ 'ExcOr(I1,,I2) => I1 xorInt I2
  rule /* B1 ^ B2 */ 'ExcOr(B1,,B2) => B1 xorBool B2
  rule /* I1 & I2 */ 'And(I1,,I2) => I1 &Int I2
  rule /* B1 & B2 */ 'And(B1,,B2) => B1 andBool B2

  rule /* V1 == V2 */ 'Eq(V1:Val,,V2:Val) => V1 ==Bool V2
  rule /* V1 != V2 */ 'NotEq(V1,,V2) => V1 =/=Bool V2
  rule /* I1 <  I2 */ 'Lt(I1,,I2) => I1 <Int I2
  rule /* I1 >  I2 */ 'Gt(I1,,I2) => I1 >Int I2
  rule /* I1 <= I2 */ 'LtEq(I1,,I2) => I1 <=Int I2
  rule /* I1 >= I2 */ 'GtEq(I1,,I2) => I1 >=Int I2

  rule /* I1 <<  I2 */ 'LeftShift(I1,,I2) => I1 <<Int (I2 &Int 31) //JLS 15.19
  rule /* I1 >>  I2 */ 'RightShift(I1,,I2) => I1 >>Int (I2 &Int 31)
  rule /* I1 >>> I2 */ 'URightShift(I1,,I2) => 'Cond(I2 >=Int 0,, 'RightShift(I1,,I2),,
      'Plus('RightShift(I1,,I2),, 'LeftShift(2,,'Complement(I2))))

  rule /* I1 + I2     */ 'Plus(I1:#Int,,I2:#Int) => I1 +Int I2
  rule /* Str + KR    */ 'Plus(Str:#String,,KR:KResult) => Str +String toString(KR)
  rule /* KR + Str    */ 'Plus(KR,,Str) => toString(KR) +String Str
      when typeOf(KR) =/=Bool rtString

  rule /* I1 - I2    */ 'Minus(I1,,I2) => _-Int_(I1,I2)
  rule /* I1 * I2    */ 'Mul(I1,,I2) => I1 *Int I2
  rule /* I1 / I2    */ 'Div(I1,,I2) => I1 /Int I2 when I2 =/=Bool 0 //todo ArithmeticException
  rule /* I1 % I2    */ 'Remain(I1,,I2) => I1 %Int I2 when I2 =/=Bool 0 //todo ArithmeticException

  // ++E
  context 'PreIncr(HOLE => lvalue(HOLE))
  rule /* ++loc(L) => loc(L) = lookup(L) + 1 */
    'PreIncr(loc(L)) => 'Assign(loc(L:#Int),, 'Plus(lookup(L),,1))

  // --E
  context 'PreDecr(HOLE => lvalue(HOLE))
  rule /* --loc(L) => loc(L) = lookup(L) - 1 */
    'PreDecr(loc(L)) => 'Assign(loc(L),, 'Minus(lookup(L),,1))

  rule /* ! B    */ 'Not(B:#Bool) => notBool(B)
  rule /* ~ I    */ 'Complement(I:#Int) => ~Int I
  rule /* + I    */ 'Plus(I) => I
  rule /* - I    */ 'Minus(I) => 0 -Int I

  // E++
  context 'PostIncr(HOLE => lvalue(HOLE))
  rule /* loc(L)++ => (loc(L) = lookup(L) + 1) - 1 */
    'PostIncr(loc(L)) => 'Minus( 'Assign(loc(L),, 'Plus(lookup(L),,1)),, 1)

  // E--
  context 'PostDecr(HOLE => lvalue(HOLE))
  rule /* loc(L)-- => (loc(L) = lookup(L) - 1) + 1 */
    'PostDecr(loc(L)) => 'Plus( 'Assign(loc(L),, 'Minus(lookup(L),,1)),, 1)

  //semantically if and ?: are equivalent
  rule 'Cond(Ks:List{K}) => 'If(Ks)

/*@ \subsubsection{Assignment operators}
Typed KOOL allows to assign subtype instance values to supertype lvalues.
Assignment operators are seqstrict according to JLS. */

  syntax KLabel ::=
                  | /* =    */ 'Assign
                  | /* +=   */ 'AssignPlus
                  | /* -=   */ 'AssignMinus
                  | /* *=   */ 'AssignMul
                  | /* /=   */ 'AssignDiv
                  | /* &=   */ 'AssignAnd
                  | /* |=   */ 'AssignOr
                  | /* ^=   */ 'AssignExcOr
                  | /* %=   */ 'AssignRemain
                  | /* <<=  */ 'AssignLeftShift
                  | /* >>=  */ 'AssignRightShift
                  | /* >>>= */ 'AssignURightShift

  context 'Assign((HOLE => lvalue(HOLE)),,_)
  context 'Assign(_:KResult,,HOLE)

  rule <k> 'Assign(loc(L),,V) => subtype typeOf(V), typeOf(K) ~> true?
           ~> unsafeCast(V,typeOf(K:K)) ...</k>
       <store>... L |-> (K => unsafeCast(V, typeOf(K))) ...</store> [transition]

  /* loc(L) += E => loc(L) = lookup(L) + E */
  context 'AssignPlus((HOLE => lvalue(HOLE)),,_)
  rule 'AssignPlus(loc(L),,E:K) => 'Assign(loc(L),, 'Plus(lookup(L),, E))

  /* loc(L) -= E => loc(L) = lookup(L) - E */
  context 'AssignMinus((HOLE => lvalue(HOLE)),,_)
  rule 'AssignMinus(loc(L),,E) => 'Assign(loc(L),, 'Minus(lookup(L),, E))

  /* loc(L) *= E => loc(L) = lookup(L) * E */
  context 'AssignMul((HOLE => lvalue(HOLE)),,_)
  rule 'AssignMul(loc(L),,E) => 'Assign(loc(L),, 'Mul(lookup(L),, E))

  /* loc(L) /= E => loc(L) = lookup(L) / E */
  context 'AssignDiv((HOLE => lvalue(HOLE)),,_)
  rule 'AssignDiv(loc(L),,E) => 'Assign(loc(L),, 'Div(lookup(L),, E))

  /* loc(L) &= E => loc(L) = lookup(L) & E */
  context 'AssignAnd((HOLE => lvalue(HOLE)),,_)
  rule 'AssignAnd(loc(L),,E) => 'Assign(loc(L),, 'And(lookup(L),, E))

  /* loc(L) |= E => loc(L) = lookup(L) | E */
  context 'AssignOr((HOLE => lvalue(HOLE)),,_)
  rule 'AssignOr(loc(L),,E) => 'Assign(loc(L),, 'Or(lookup(L),, E))

  /* loc(L) ^= E => loc(L) = lookup(L) ^ E */
  context 'AssignExcOr((HOLE => lvalue(HOLE)),,_)
  rule 'AssignExcOr(loc(L),,E) => 'Assign(loc(L),, 'ExcOr(lookup(L),, E))

  /* loc(L) %= E => loc(L) = lookup(L) % E */
  context 'AssignRemain((HOLE => lvalue(HOLE)),,_)
  rule 'AssignRemain(loc(L),,E) => 'Assign(loc(L),, 'Remain(lookup(L),, E))

  /* loc(L) <<= E => loc(L) = lookup(L) << E */
  context 'AssignLeftShift((HOLE => lvalue(HOLE)),,_)
  rule 'AssignLeftShift(loc(L),,E) => 'Assign(loc(L),, 'LeftShift(lookup(L),, E))

  /* loc(L) >>= E => loc(L) = lookup(L) >> E */
  context 'AssignRightShift((HOLE => lvalue(HOLE)),,_)
  rule 'AssignRightShift(loc(L),,E) => 'Assign(loc(L),, 'RightShift(lookup(L),, E))

  /* loc(L) >>>= E => loc(L) = lookup(L) >>> E */
  context 'AssignURightShift((HOLE => lvalue(HOLE)),,_)
  rule 'AssignURightShift(loc(L),,E) => 'Assign(loc(L),, 'URightShift(lookup(L),, E))

/*@ \subsubsection{lookup} */
  syntax K ::= "lookup" "(" #Int ")"
  rule <k> lookup(L) => V:Val ...</k> <store>... L |-> V ...</store> [transition]

/*@ \subsubsection{Array access}
Check array bounds, as part of the dynamic typing policy. */

  syntax KLabel ::= 'ArrayAccess [seqstrict]
  rule [arrayLookup]:
      'ArrayAccess(arrayRef(_,L,M:#Int),, N:#Int) => lookup(L +Int N)
    when N >=Int 0 andBool N <Int M   [structural anywhere]

//Array length, as defined in JDK
  syntax #Id ::= "length"
  rule 'ExprName(arrayRef(_,_:#Int,N),, length) => N

end module

module JAVA-STATEMENTS
    imports JAVA-CORE
    imports JAVA-EXPRESSIONS

//@ \subsection{Block statement}

  rule <k> 'Block(S) => S ~> env(Env) ...</k>
       <env> Env </env> [structural]
  rule [sequenceOfStatements]: 'ListWrap(S1,,Ss:List{K}) => S1 ~> 'ListWrap(Ss)            [structural]
  rule <k> 'ListWrap(.List{K}) => . ...</k> [structural]

//@ \subsection{Expression statement}

  syntax KLabel ::= 'ExprStm [strict]
  rule 'ExprStm(V:Val) => .

//@ \subsection{If statement}

  syntax KLabel ::= 'If [strict(1)]
  rule 'If(true,, S,, _) => S
  rule 'If(false,, _,, S) => S
  macro 'If(E:K,,S1:K) = 'If(E:K,,S1:K,,'Block('ListWrap(.List{K})))

//@ \subsection{While statement}

  rule <k> ( 'While(E:K,,S:K) => saveLoop(loopImpl(E, S, .K),K)
        ~> loopImpl(E, S, .K) ~> popx )
      ~> K </k> [structural]

  //loopImpl arguments:
  //1. E - test expression
  //2. S - loop body
  //3. UpdClause
  syntax K ::= "loopImpl" "(" K "," K "," K ")"
  rule <k> loopImpl(E, S, UpdClause) => 'If(
          E,,
          'Block(S ~> UpdClause ~> loopImpl(E, S, UpdClause)),,
          .K) ...</k> [structural]

//@ \subsection{Do statement}
  rule <k> ( 'DoWhile(S,,E) => saveLoop(loopImpl(E, S, .K), K)
        ~> S ~> loopImpl(E, S, .K) ~> popx )
      ~> K </k> [structural]

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

  //this form of resulting while is required for compatibility with continue statement
  rule [for]:
      <k> ( 'For(stm(InitClause:K),, 'Some(TestExp:K),, stm(UpdClause:K),, S:K)
          => saveLoop(loopImpl(TestExp, S, stm(UpdClause)), K) ~> 'Block(stm(InitClause)
          ~> saveForBody ~> loopImpl(TestExp, S, stm(UpdClause))) ~> popx ) ~> K
      </k>
    [structural]

//@ \subsection{Break statement}

  rule <k> 'Break('None(_)) ~> _:K => K </k>
       <control> <stack> ListItem((loop, _, _, K, Env, C)) => . ...</stack> (_ => C) </control>
       <env> _ => Env </env>

  //works for both break with and without label
  rule [breakReachesFinallyBlock]: <k> (. => FinallyS) ~> 'Break(_) ...</k>
       <control>
         <stack> ListItem((finally,_,FinallyS,_,Env,C)) => . ...</stack>
         (_ => C)
       </control>
       <env> _ => Env </env>

  rule <k> 'Break('None(_)) ...</k>
       <stack> ListItem((LayerType:#Id,_,_,_,_,_:Bag)) => . ...</stack>
    when LayerType =/=Bool loop andBool LayerType =/=Bool finally

  //break with label
  rule <k> 'Break('Some(X)) ~> _:K => K </k>
       <control> <stack> ListItem((label, X, _, K, Env, C)) => . ...</stack> (_ => C) </control>
       <env> _ => Env </env>

  rule [BreakWithLabelPropagation]:
      <k> 'Break('Some(X)) ...</k>
      <stack> ListItem((LayerType:#Id, StackArg2:K, _,_,_,_:Bag)) => . ...</stack>
  when
      (
                LayerType =/=Bool label
        andBool LayerType =/=Bool finally
      )
      orBool (
                LayerType ==Bool label
        andBool X =/=Bool StackArg2
      )

//@ \subsection{Continue statement}

  rule [ContinueSimple]:
      <k> 'Continue('None(_)) ~> _:K => UpdClause ~> loopImpl(E, S, UpdClause) ~> popx ~> K </k>
      <control>
        <stack>
          ListItem((LayerType, _, loopImpl(E, S, UpdClause), K, Env, C))
          ...
        </stack>
        (_ => C)
      </control>
      <env> _ => Env </env>
  when
      LayerType ==Bool loop orBool LayerType ==Bool forBody

  rule [ContinueSimplePropagation]:
      <k> 'Continue('None(_)) ...</k>
      <stack>
        ListItem((LayerType:#Id,_,_,_,_,_:Bag)) => .
        ...
      </stack>
  when
              LayerType =/=Bool loop
      andBool LayerType =/=Bool forBody
      andBool LayerType =/=Bool finally

  rule [ContinueWithLabel]:
      <k> 'Continue('Some(X)) ~> _:K => UpdClause ~> loopImpl(E, S, UpdClause) ~> popx ~> K </k>
      <control>
        <stack>
          ListItem((LayerType, X, loopImpl(E, S, UpdClause), K, Env, C))
          ...
        </stack>
        (_ => C)
      </control>
      <env> _ => Env </env>
  when
             LayerType ==Bool loop
      orBool LayerType ==Bool forBody

  rule [ContinueWithLabelPropagation]:
      <k> 'Continue('Some(X)) ...</k>
      <stack>
        ListItem((LayerType:#Id, StackArg2:K, _,_,_,_:Bag)) => .
        ...
      </stack>
  when
      (
                LayerType =/=Bool loop
        andBool LayerType =/=Bool forBody
        andBool LayerType =/=Bool finally
      )
      orBool (
        (
                 LayerType ==Bool loop
          orBool LayerType ==Bool forBody
        )
        andBool (
          X =/=Bool StackArg2
        )
      )

  //works for both break with and without label
  rule [ContinueInsideFinally]:
      <k> (. => FinallyS) ~> 'Continue(_) ...</k>
      <control>
        <stack>
          ListItem((finally,_,FinallyS,_,Env,C)) => .
          ...
        </stack>
        (_ => C)
      </control>
      <env> _ => Env </env>

//@ \subsection{Variable declaration}
//@ Not only local byt fields also

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

/*In Java-Simple we'll support only int and boolean primitive types*/

  context 'LocalVarDec(HOLE,,_)
  rule <k> 'LocalVarDec(T:Type,,'ListWrap('VarDec(X:#Id))) => . ...</k>
       <env> Env:Map => Env[L:#Int/X] </env>
       <store>... . => L |-> undefined(T) ...</store>
       <nextLoc> L => L +Int 1 </nextLoc>

/*@\subsection{Return} At method return, we have to check that the type
of the returned
value is a subtype of the expected return type.  Moreover, if that is
the case, then we also upcast the returned value to one of the
expected type. */

  context 'Return('Some(HOLE))

  rule 'Return('None(.List{K}) => 'Some(nothing)) [structural]

  rule <k> 'Return('Some(V)) ~> _
  => subtype typeOf(V), T ~> true? ~> unsafeCast(V, T) ~> K:K </k>
       <control>
         <stack> ListItem((return,_,_,K,Env,C)) => . ...</stack>
         (<return> T </return> _ => C)
       </control>
       <env> _ => Env </env>

   rule <k> (. => FinallyS) ~> 'Return('Some(V)) ...</k>
       <control>
         <stack> ListItem((finally,_,FinallyS,_,Env,C)) => . ...</stack>
         (_ => C)
       </control>
       <env> _ => Env </env>

   rule <k> 'Return('Some(V)) ...</k>
        <stack> ListItem((LayerType,_,_,_,_,_:Bag)) => . ...</stack>
	 when LayerType =/=Bool return andBool LayerType =/=Bool finally

/*@ \subsubsection{Typed exceptions}
Exceptions are propagated now until a catch that can bind them is
encountered. */

  rule [tryCatchFinallyDesugar]: 'Try(TryS:K,, 'ListWrap( K,,Ks),,FinallyS:K)
    => 'Try('Try(TryS,,'ListWrap( K,,Ks)),,'ListWrap(.List{K}),,FinallyS)

  rule [tryCatchCatchDesugar]: 'Try(TryS,, 'ListWrap(Ks,, K1:K,, K2:K))
    => 'Try('Try(TryS,, 'ListWrap( Ks,,K1)),, 'ListWrap(K2))

  //ListItem arguments:
  //1. stack entry type (return, finally, etc.)
  //2. CatchParam
  //3. CatchStm, FinallyStm
  //4. K - rest of computation
  //5. Env
  //6. C - rest of control
  syntax K ::= "(" #Id "," K "," K "," K "," Map "," Bag ")"
  syntax K ::= "popx"

  //stack layer types
  syntax #Id ::= "return" | "catch" | "finally" | "loop" | "forBody" | "label"

  //eval the type of catch argument
  context 'Try(_:K,,'ListWrap('Catch('Param(_:K,, HOLE,, _),, _)))

  rule <k> (
        'Try(TryS:K,, 'ListWrap(
          'Catch(CatchParam:K,, CatchS:K)))
          => TryS ~> popx ) ~> K
       </k>
       <control> <stack> . => ListItem((return,CatchParam,CatchS,K,Env,C)) ...</stack> C:Bag </control>
       <env> Env </env>
  rule <k> popx => . ...</k> <stack> _:ListItem => . ...</stack>

/*@ \subsubsection{Typed exceptions - finally clause}
Now stack may hold two types of layers specific to exceptions - a catch layer or a finally layer.
Both should be threated separately when a throw statement is encountered.*/

  rule [tryFinally]: <k> ('Try(TryS:K ,,'ListWrap(.List{K}),,FinallyS:K) => TryS ~> popx ~> FinallyS) ~> K </k>
       <control> <stack> . => ListItem((finally,.K,FinallyS,.K,Env,C)) ...</stack> C:Bag </control>
       <env> Env </env>

/*@ \subsubsection{throw statement}*/

  syntax KLabel ::= 'Throw [strict]
  rule <k> 'Throw(V) ~> _:K
          =>  'If( (subtype typeOf(V), T),, 'Block('ListWrap('LocalVarDecStm('LocalVarDec( 'ListWrap(.List{K}) ,,
              T,, 'ListWrap('VarDec(X ,, V)))),, CatchS)),, 'Throw(V)) ~> K
       </k>
       <control> <stack> ListItem((return, 'Param(_:K,, T,, X:#Id) ,CatchS,K,Env,C)) => . ...</stack> (_ => C) </control>
       <env> _ => Env </env>

  rule [throwReachesFinallyBlock]: <k> (. => FinallyS) ~> 'Throw(_:Val) ...</k>
       <control>
         <stack> ListItem((finally,_,FinallyS,_,Env,C)) => . ...</stack>
         (_ => C)
       </control>
       <env> _ => Env </env>

  rule <k> 'Throw(_:Val) ...</k>
       <stack> ListItem((LayerType:#Id,_,_,_,_,_:Bag)) => . ...</stack>
    when LayerType =/=Bool catch andBool LayerType =/=Bool finally

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
        <dissolveEmptyK> true </dissolveEmptyK>

/*@ \subsubsection{Labeled statement}*/

  rule <k> ('Labeled(X,,S) => S ~> popx) ~> K </k>
       <control> <stack> . => ListItem((label, X, S, K, Env, C))
       ...</stack> C:Bag </control>
       <env> Env </env>

//@ \subsection{Auxiliary operations}

//@ \texttt{env}
  syntax K ::= "env" "(" Map ")"
  rule <k> env(Env) => . ...</k> <env> _ => Env </env> [structural]
  rule (env(_) => .) ~> env(_) [structural]

/*@ \texttt{Label propagation} through stack layers, used by
continue statement with label.*/

  declare getLoopLabel : K -> K
  define getLoopLabel((label, X, S, _,_,_:Bag)) => X
      when     getKLabel(S) ==Bool 'While
        orBool getKLabel(S) ==Bool 'DoWhile
        orBool getKLabel(S) ==Bool 'For

  define getLoopLabel((LayerType, _, S, _,_,_:Bag)) => .K
      when LayerType =/=Bool label orBool
           notBool ( getKLabel(S) ==Bool 'While
              orBool getKLabel(S) ==Bool 'DoWhile
              orBool getKLabel(S) ==Bool 'For )

  declare getForBodyLabel : K -> K

  //the parent layer of forBody is always loop
  define getForBodyLabel((loop, K, _,_,_,_:Bag)) => K

  syntax K ::= "saveLoop" "(" K "," K ")"
  rule  <k> (saveLoop(LoopStm:K, K) => .) ...</k>
        <control>
          <stack>
            ( . => ListItem((loop, getLoopLabel(ParentLayer), LoopStm, K, Env, C)) )
            ListItem(ParentLayer:K)
            ...
          </stack>
          C:Bag
        </control>
        <env> Env </env>

  syntax K ::= "saveForBody"
  rule  <k> (saveForBody => .) ~> loopImpl(E, S, UpdClause) ~> (. => popx) ~> K </k>
        <control>
          <stack>
            ( . =>  ListItem( (forBody, getForBodyLabel(ParentLayer),
                             loopImpl(E, S, UpdClause), K, Env, C) ) )
            ListItem(ParentLayer:K)
            ...
          </stack>
          C:Bag
        </control>
        <env> Env </env>

end module

module JAVA
    imports JAVA-CORE
    imports JAVA-EXPRESSIONS
    imports JAVA-STATEMENTS

 syntax #Id ::= "string"

//@ \subsection{Unused Labels}
  syntax KLabel ::= 'Public | 'Static | 'AssertStm

/*@ \subsection{Object and method closures}
The only change to untyped KOOL's values is that closures are now typed
(their last argument holds their type). */

syntax Val ::= "objectClosure" "(" Bag ")"
              | "methodClosure" "(" #Id "," #Int "," K "," K "," Type ")"

//@ \subsection{Type labels}
//@Here we rewrite java type ast into simple types

  rule 'Int(_) => int [structural]
  rule 'Boolean(_) => bool [structural]
  rule 'Void(_) => void [structural]
  rule 'ClassOrInterfaceType('TypeName(K),,_) => 'TypeName(K) [structural]
  rule 'TypeName(X:#Id) => class X  [structural]
  rule class string => rtString  [structural]

  context 'ArrayType(HOLE)
  rule 'ArrayType(T:Type) => arrayOf T [structural]

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

//@ \subsection{New array allocation}
/*@ The dynamic semantics of typed array declarations is
similar to that in untyped SIMPLE, but we have to enforce that the
type of an array declaration be of the form \texttt{arrayOf $T$}
and assign the right type ($T$) to the allocated array locations. */

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
  rule evalAndStore((I1:#Int,,I2:#Int,,Ks:List{K}),InitExp) => evalAndStore(I1,InitExp) ~> evalAndStore((I2,,Ks),InitExp)
    [structural]
  context evalAndStore(_:KResult, HOLE)
  rule <k> evalAndStore(L:#Int,V) =>. ...</k>
       <store>... L |->(_=>V) ...</store>
  rule evalAndStore(.List{K}, _) => . [structural]

/*@ \subsection{Method declaration}
Methods are now typed and we need to store their types in their
closures, so that their type contract can be checked at invocation
time.  The rule below is conceptually similar to that of untyped KOOL;
the only difference is the addition of the types.  */

  context 'MethodDec('MethodDecHead(_:K,, _:K,, HOLE,, _:List{K}),, _)
  rule [methodDec]: 'MethodDec('MethodDecHead(_,, _,, ReturnType:Type,,
         Name:#Id,, 'ListWrap(Params:List{K}),, _),, S:K)
         => storeMethod(Name, 'ListWrap(Params), S, function from Params to ReturnType)
    [structural]

//contructors are reduced to methods with return type void
  rule 'ConstrDec('ConstrDecHead(K1:K,, K2:K,, Ks),, 'ConstrBody(_,,S))
        => 'MethodDec('MethodDecHead(K1,,K2,,void,,Ks),, S)

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
       <env> . </env>  [structural]

  syntax #Id ::= "read"

  rule <k> read => readMethodVal ...</k>
  rule <k> 'Invoke(readMethodVal,, 'ListWrap(.List{K})) => I:#Int ...</k>
       <in> ListItem(I) => . ...</in> [transition]

//@ For integers and strings, print their value. For classes, print class type.
  syntax #Id ::= "print"

  rule <k> print => printMethodVal ...</k>

  rule <k> 'Invoke(printMethodVal,, 'ListWrap(KR:KResult,,KRs:List{KResult} => KRs)) ...</k>
       <out>... .=>ListItem(toString(KR))</out> [transition]

  rule 'Invoke(printMethodVal,,'ListWrap(.List{K})) => nothing  [structural]

//@ \subsection{Auxiliary operations}

//@ \texttt{bindto} also checks the well-formedness of the function parameters

  syntax K ::= "bindto" List{K} "," List{KResult}

  context bindto('Param(_:K,,HOLE,,_),, _:List{K}), _:List{K}

  rule <k> (. => 'ExprStm('Assign('ExprName(X),,V))) ~> bindto('Param(_,,T,,X),, Params => Params),
        (V,,ParamValues => ParamValues) ...</k>
       <env> Env:Map => Env[L/X] </env>
       <store>... . => L |-> undefined(T) ...</store>
       <nextLoc> L => L +Int 1 </nextLoc>
  rule <k> bindto .List{K},.List{K} => . ...</k>  [structural]

//@ \texttt{typeOf definition}
  define typeOf(_:#Int) => int
  define typeOf(_:#Bool) => bool
  define typeOf(_:#String) => rtString
  define typeOf(_:Type)  => rtType

  define typeOf(arrayRef(T,_:#Int,_:#Int)) => T

  define typeOf(undefined(T)) => T
  define typeOf(nothing) => void

  define typeOf(objectClosure(_ <envStack> ListItem((Class,_)) ...</envStack>))
    => class Class
  define typeOf(methodClosure(_:#Id,_:#Int,_,_,T)) => T

  define typeOf('Param(_:K,,K,,_)) => K

/*@ Recall that lists of the form "a,b,c" are a syntactic convenience,
which eventually are translated into cons-lists "(a,(b,(c,.)))".
Unfortunately, the current K tool is not able to cons-listify
the RHSes of the rules below, so we have to do it manually.  */

//@ Sequences of locations

  syntax List{K} ::= #Int ".." #Int
  define N1:#Int..N2:#Int => .List{K}              when N1  >Int N2
  define N1:#Int..N2:#Int => N1 ,, (N1 +Int 1)..N2 when N1 <=Int N2

/*@ \subsection{Changes to SIMPLE Semantics}
We extend/change the semantics of several SIMPLE constructs in order
to take advantage of the richer KOOL semantic infrastructure and thus
get more from the existing SIMPLE constructs. */

/*@ \subsubsection{Subtyping constraints}
The subclass relation introduces a subtyping relation. */

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

  define unsafeCast(V,T) => V when typeOf(V) ==Bool T
  define unsafeCast(objectClosure(<crntClass>_:K </crntClass> Obj), class Class)
    => objectClosure(<crntClass> Class </crntClass> Obj)

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
        Vals:List{KResult}
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
                   <envStack> ListItem((object, <env>.Map</env>)) </envStack>
                   <location> L </location>
         </crntObj>
         <return> T => class ClassName </return>
         <stack> . => ListItem((return,.K,.K, K, Env, C <return> T </return>
         <crntObj> Obj </crntObj>)) ...</stack>
       </control>
       <nextLoc> L => L +Int 1 </nextLoc>

  syntax K ::= "create" "(" K ")"
  rule <k> create(Class:#Id)
        => create(BaseClass:#Id) ~> setCrntClass(Class) ~> S ~> addEnvLayer ...</k>
       <className> Class </className>
       <extends> BaseClass </extends>
       <declarations> S </declarations>  [structural]
  rule <k> create(object) => . ...</k>    [structural]

  syntax K ::= "setCrntClass" "(" #Id ")"
  rule <k> setCrntClass(Class) => . ...</k>
       <crntClass> _ => Class </crntClass>  [structural]

  syntax K ::= "addEnvLayer"
  rule <k> addEnvLayer => . ...</k>
       <env> Env => . </env>
       <crntClass> Class </crntClass>
       <envStack> . => ListItem((Class, <env>Env</env>)) ...</envStack>
    [structural]

  syntax K ::= storeObj
  rule <k> storeObj => . ...</k>
       <crntObj> Obj (<location> L </location> => .) </crntObj>
       <store>... . => L |-> objectClosure(Obj) ...</store>

/*@ \subsection{Instance Of}
Like in untyped KOOL. */

  syntax KLabel ::= 'InstanceOf [seqstrict]

  rule 'InstanceOf( objectClosure((_ <envStack>ListItem((Class, _))...</envStack>)),, class Class) => true

  rule 'InstanceOf( objectClosure((_ <envStack> ListItem((Class1:#Id, _))
                       => . ...</envStack>)),, class Class2:#Id)
    when Class1 =/=Bool Class2  [structural]

  rule 'InstanceOf( objectClosure((_ <envStack> .List </envStack>)),, class Class)
    => false

/*@ \subsection{Cast}
Unlike in untyped KOOL, in typed KOOL we actually check that the object
can indeed be cast to the claimed type. */

  syntax KLabel ::= 'CastRef [seqstrict]

  rule <k> 'CastRef(class Class,, objectClosure((<crntClass> _:K </crntClass> Obj)) )
        => 'InstanceOf( objectClosure(Obj),, class Class) ~> true?
             ~> objectClosure(<crntClass> Class </crntClass> Obj) ...</k>
    [structural]

//@ \subsection{Names}

  rule 'AmbName(Ks) => 'ExprName(Ks) [structural anywhere]
  rule 'Field(Ks) => 'ExprName(Ks)   [structural anywhere]

  rule <k> 'ExprName(X) => X ...</k>
       <env> Env </env>
    when X in keys(Env) [structural]

  rule <k>  'ExprName(X) =>
            'ExprName(
              'This(.List{K}),,
              X
            )
       ...</k>
       <env> Env </env>
    when notBool(X in keys(Env)) [structural]

  rule [lookup]: <k> X => V:Val ...</k>
       <env>... X|->L ...</env>
       <store>... L|->V ...</store> [transition]

  context 'ExprName(HOLE,,_:K)

/*@ \subsection{Self reference}
Like in untyped KOOL. */

  rule <k> 'This(.List{K}) => objectClosure(Obj) ...</k>
       <crntObj> Obj </crntObj>

/*@ \subsection{Object member access} */

  //o.x
  rule <k> 'ExprName(objectClosure(<crntClass> Class </crntClass>
                   <envStack>... ListItem((Class, EnvC:BagItem)) EStack:List </envStack>),,X)
        => lookupMember(<envStack>ListItem((Class, EnvC)) EStack</envStack>, X)
       ...</k>  [structural]

  rule <k>'SuperField(X) => lookupMember(<envStack>EStack</envStack>, X) ...</k>
       <crntClass> Class:#Id </crntClass>
       <envStack>... ListItem((Class, EnvC)) EStack </envStack>
    [structural]

/*@\subsection{Method invocation}
The method lookup is the same as in untyped KOOL.
The method closure application and return are slightly different,
since we need to check that the type of the returned value is an
instance of the claimed return type of the method.  The first group of
rules below are identical to those in untyped KOOL. */

  rule 'Method('MethodName(Ks)) => 'MethodName(Ks)
  rule 'Method(K,, _:K,, X) => 'MethodName(K,, X)

  rule <k> 'MethodName(X) => 'MethodName('This(.List{K}),, X) ...</k>
       <env> Env </env>
    when notBool (X ==Bool read orBool X ==Bool print) [structural]

  rule <k> 'MethodName(X) => X ...</k>
       <env> Env </env>
    when X ==Bool read orBool X ==Bool print [structural]

  context 'MethodName(HOLE,,_:K)

  //objClos.X(_) => lookupMember(objClos,X)(_)
  rule <k> 'MethodName(
    objectClosure(Obj <envStack> EStack </envStack>),, X) =>
    lookupMember(<envStack> EStack </envStack>, X)
    ...</k> [structural]

  // super.X(_) => lookupMember(... , )(_)
  rule <k> 'SuperMethod(_,, X)
        => lookupMember(<envStack> EStack </envStack>, X) ...</k>
       <crntClass> Class:#Id </crntClass>
       <envStack>... ListItem((Class, _)) EStack </envStack>
    [structural]

/*@ Closure application needs to also set a new return type in the
\textsf{return} cell, in order for the values returned by its body to
be checked against the return type of the method.  To do this correctly,
we also need to stack the current status of the \textsf{return} cell
and then pop it when the method returns. */

  context 'Invoke(HOLE,, _)
  context 'Invoke(_:KResult ,,'ListWrap(_:List{K},,HOLE,,_:List{K}))

  rule [methodInvocation]: <k>
  'Invoke(methodClosure(Class, OL:#Int, 'ListWrap(Params), S, function from _ to T),,
          'ListWrap(ParamValues:List{KResult})) ~> K
         => bindto Params, ParamValues ~> S ~> 'Return('None(.List{K}))
       </k>
       <control> C:Bag
         <stack> . => ListItem((return,.K,.K,K, Env,
            C <crntObj> Obj2 </crntObj>
              <return> T2 </return>)) ...</stack>
         <crntObj> Obj2:Bag => <crntClass>Class</crntClass> Obj </crntObj>
         <return> T2:Type => T </return>
       </control>
       <env> Env => . </env>
       <store>... OL |-> objectClosure(<crntClass>_:#Id</crntClass>Obj:Bag)
       ...</store>

/*@ \subsection{Lookup member}
Like in untyped KOOL. */

  syntax K ::= "(" #Id "," Bag ")"
  declare lookupMember : BagItem #Id -> K
  define lookupMember(<envStack> ListItem((_:#Id, <env>...X|->L...</env>))
                    ...</envStack>, X) => lookup(L)
  define lookupMember(<envStack> ListItem((_:#Id, <env> Env </env>))
                            => . ...</envStack>, X)
    when notBool(X in keys(Env))

//@ \texttt{lvalue}

  context lvalue('ArrayAccess(HOLE,,_))
  context lvalue('ArrayAccess(_:KResult,,HOLE))
  rule <k> lvalue(lookup(L)) => loc(L) ...</k>  [structural]

  rule <k> lvalue('ExprName(X)) => loc(L) ...</k>
       <env>... X|->L ...</env>  [structural]

  rule <k> lvalue('ExprName(X) => 'ExprName('This(.List{K}),, X) )
    ...</k> <env> Env </env>
    when notBool(X in keys(Env))  [structural]

  context lvalue('ExprName(HOLE,, _:#Id) )

  rule <k> lvalue('ExprName(objectClosure(<crntClass> Class </crntClass>
                           <envStack>...
                             ListItem((Class, EnvC)) EStack
                           </envStack>),, X)
        => lookupMember(<envStack>ListItem((Class, EnvC:BagItem)) EStack:List
                        </envStack>, X))
       ...</k>  [structural]

  rule <k> lvalue('SuperField(X) => lookupMember(<envStack>EStack</envStack>, X)) ...</k>
       <crntClass> Class:#Id </crntClass>
       <envStack>... ListItem((Class, EnvC)) EStack </envStack>
    [structural]

end module
