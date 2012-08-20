module JAVA-METHOD-DEC
    imports JAVA-CORE

//@process access modes
rule 'Public(.List{K}) => public        [structural anywhere]
rule 'Protected(.List{K}) => protected  [structural anywhere]
rule 'Private(.List{K}) => private      [structural anywhere]

syntax K ::= "getAccessMode" "(" K //'ListWrap(...) - the list of method attributes
                             ")"
rule getAccessMode('ListWrap(Acc:AccessMode,,_)) => Acc

rule getAccessMode('ListWrap((K:K => .List{K}),, _))
when        K =/=K public
    andBool K =/=K protected
    andBool K =/=K private

rule getAccessMode('ListWrap(.List{K})) => package

/*@ \subsection{Method declaration}
Methods are now typed and we need to store their types in their
closures, so that their type contract can be checked at invocation
time.  The rule below is conceptually similar to that of untyped KOOL;
the only difference is the addition of the types.  */

context 'MethodDec('MethodDecHead((HOLE => getAccessMode(HOLE)),, _),, _)
context 'MethodDec('MethodDecHead(_:K,, _:K,, HOLE,, _),, _)

rule [MethodDec]:
    'MethodDec(
      'MethodDecHead(Acc,, _,, ReturnType:Type,, Name:Id,, 'ListWrap(Params:List{K}),, _),,
      S:K
    )
    => storeMethod(Name, types(Params), 'ListWrap(Params), S,
          methodType(Acc, Params, ReturnType))
        [structural]

syntax K ::= "storeMethod" "("
                              Id ","
                              K "," //will evalute to Types - a syntactic list of types
                              K ","
                              K ","
                              Type
                           ")"
        [strict(2)]

syntax K       ::= "types" "(" List{K} ")"
syntax Types ::= "types" "(" List{KResult} ")"
syntax KResult ::= Types

rule types(_:List{KResult},, ('Param(_:K,,T:Type,,_:K) => T),, _:List{K})

context storeMethod(_, _, _, _,
    methodType(_, _:List{K},, (HOLE => typeOf(HOLE)),, _:List{K}, _))

rule [storeMethod]:
    <k> storeMethod(Name, Ts:Types, 'ListWrap(Params), S, MethodType:Type) =>. ...</k>
    <crntClass> Class:Id </crntClass>
    <location> OL:Int </location>
    <env> Env:Map => Env[ L:Int/sig(Name,Ts) ] </env>
    <store>
      ...
      . => L |-> methodClosure(Class, OL, 'ListWrap(Params), S) :: MethodType
      ...
    </store>
    <nextLoc> L => L +Int 1 </nextLoc>

//A method signature
syntax K ::= "sig" "(" Id "," Types ")"

rule [ConstrDecSuperCallDesugar]:
    'ConstrDec(
      _:K,,
      'ConstrBody(
        (
          'None(_)
          => 'Some('SuperConstrInv( 'None(.List{K}),, 'ListWrap(.List{K}) ))
        ),,
        _:K
      )
    )

context 'ConstrDec('ConstrDecHead((HOLE => getAccessMode(HOLE)),, _),, _)

rule [ConstrDec]:
    'ConstrDec('ConstrDecHead(Acc,, _,, Name,, 'ListWrap(Params),, _),,
        'ConstrBody(
      'Some('SuperConstrInv( _,, SuperParamsList:K )) ,,S))
    => storeConstructor(Name, 'ListWrap(Params), SuperParamsList,
        S, methodType(Acc, Params, void))

syntax K ::= "storeConstructor" "(" Id "," K "," K "," K "," Type ")"

context storeConstructor(_, _, _, _,
    methodType(_, _:List{K},, (HOLE => typeOf(HOLE)),, _:List{K}, _))

rule [storeConstructor]:
    <k>
        storeConstructor(Name, 'ListWrap(Params), SuperParamsList, S, MethodType)
        => storeMethod(
          Name,
          types(Params),
          'ListWrap(Params),
          'ExprStm(
            'Invoke( 'Method('MethodName( BaseClass:Id )),, SuperParamsList )
          ) ~> S,
          MethodType
        )
      ...
    </k>
    <crntClass> Class:Id </crntClass>
    <className> Class </className>
    <extends> BaseClass </extends>
when
    Id2String(Class) =/=String "Object"

rule [storeConstructorClassObject]:
    <k>
        storeConstructor(Name, 'ListWrap(Params), _, S, MethodType)
        => storeMethod(
          Name,
          types(Params),
          'ListWrap(Params),
          S,
          MethodType
        )
      ...
    </k>
    <crntClass> Class:Id </crntClass>
    <className> Class </className>
when
    Id2String(Class) ==String "Object"

end module
