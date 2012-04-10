module JAVA-CLASSES
    imports JAVA-CORE
    imports JAVA-EXPRESSIONS
    imports JAVA-STATEMENTS

syntax #Id ::= "string"

syntax Type ::= "function" "from" List{KResult} "to" Type
                  [prec(1) latex "({#1}\ \texttt{->}\ {#2})"]
              | "class" #Id

syntax Val ::= "objectClosure" "(" Bag ")"
              | "methodClosure" "(" #Id "," #Int "," K "," K "," Type ")"

//@ \subsection{Unused Labels}
  syntax KLabel ::= 'Public | 'Static | 'AssertStm

/*@ \subsection{Object and method closures}
The only change to untyped KOOL's values is that closures are now typed
(their last argument holds their type). */

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

  define toString(class Class:#Id) => Id2String(Class)
  define toString(objectClosure(Bag:Bag)) => toString(typeOf(objectClosure(Bag)))

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
