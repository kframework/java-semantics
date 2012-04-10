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

//@ \subsection{Switch statement}

syntax K ::= "switchImpl" Val "," List{K}

context 'Switch(HOLE,,_)

rule [SwitchToSwitchImpl]:
    'Switch(V,, 'SwitchBlock('ListWrap(Ks),,_)) => switchImpl V, Ks

context switchImpl _, ( 'SwitchGroup('ListWrap('Case(HOLE)),,_),, _:List{K} )

rule [SwitchCaseNotMatch]:
    switchImpl V, (( 'SwitchGroup('ListWrap('Case(V2:Val)),,_) => .List{K} ),,_)
when V =/=Bool V2

rule [SwitchEmptyDiscard]:
    switchImpl _, .List{K} => .

/*@Once case of first switch group matches, the whole switch is replaced
by it's block. The execution rules for switch will discard switch-related
constructs and will execute the statements. */

rule [SwitchCaseMatch]:
    ( switchImpl V, ('SwitchGroup('ListWrap('Case(V)),,S),,Ks) )
    =>   'ListWrap( 'SwitchGroup('ListWrap('Case(V)),,S),,Ks )

rule [SwitchGroupExec]:
    'SwitchGroup(_:K,, S) => S

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
