module JAVA-VAR-LOOKUP
    imports JAVA-CLASSES

//@ \subsection{Names}

rule [AmbName]:
    'AmbName(Ks:List{K}) => 'ExprName(Ks) ?? 'TypeName(Ks)
        [structural, anywhere]

rule 'Field(Ks:List{K}) => 'ExprName(Ks)   [structural, anywhere]

rule [ExprNameLocalVar]:
    <k> 'ExprName(X:Id) => X ...</k>
    <env> Env:Map </env>
when X in keys(Env)
        [structural]

rule [ExprNameMember]:
    <k>
      'ExprName(X:Id) => 'ExprName( ('This(.List{K}) ?? class Class),, X )
      ...
    </k>
    <env> Env:Map </env>
    <crntClass> Class:Id </crntClass>
when
    notBool( (X in keys(Env)) orBool (Id2String(X) ==String "System") )
        [structural]

context 'ExprName(HOLE,,_:K)

/*@ \subsection{Self reference}
Like in untyped KOOL. */

rule [This]:
    <k>
      'This(.List{K})
      => objectClosure(OL, Obj) :: class Class
      ...
    </k>
    <crntObj>
      Obj:Bag
      <crntClass> Class:Id </crntClass>
      <location> OL:Int </location>
    </crntObj>

rule [ThisNoValue]:
    <k>
      'This(.List{K}) => noValue
      ...
    </k>
    <location> noValue </location>

/*@ \subsection{Object member access} */

//o.x
rule [ExprNameQualified]:
    <k>
      'ExprName(
        objectClosure(_,
          <envStack>... ListItem((Class:Id, EnvC:BagItem)) EStack:List </envStack>
        ) :: class Class,, X:Id
      )
      => lookupField(<envStack>ListItem((Class, EnvC)) EStack</envStack>, X)
      ...
    </k>
        [structural]

rule [ExprNameNoValue]:
    'ExprName( noValue,, X:Id ) => noValue    [structural]

rule [ExprNameQualifiedNull]:
    <k>
      'ExprName(null::_ ,, X:Id)
      =>  'Throw('NewInstance(
            'None(.List{K}),,
            'class_(String2Id("NullPointerException")),,
            'ListWrap( null :: nullType ),,
            'None(.List{K})
          ))
      ...
    </k>
        [structural]

rule [SuperField]:
    <k>'SuperField(X:Id) => lookupField(<envStack>EStack</envStack>, X) ...</k>
    <crntClass> Class:Id </crntClass>
    <envStack>... ListItem((Class, EnvC:BagItem)) EStack:List </envStack>
      [structural]

/*@ \subsection{Lookup member}
Like in untyped KOOL. */

//lookup field result is always typed
syntax K ::= "lookupField" "(" BagItem "," Id ")" [function]

rule lookupField(
    <envStack>
      ListItem((_:Id, <env>... X:Id |-> L:Int ...</env>))
      ...
    </envStack>,
    X
  ) => typedLookup(L)
        [anywhere]

rule lookupField(
    <envStack>
      ListItem((_:Id, <env> Env:Map </env>)) => .
      ...
    </envStack>,
    X:Id
  )
when notBool(X in keys(Env))
        [anywhere]

rule lookupField(<envStack> . </envStack>, _) => noValue
        [anywhere]

rule [typedLookup]:
    <k> typedLookup(L:Int) => lookup(L)::T ...</k>
    <store>... L |-> _::T:Type ...</store>

rule [lvalueTypedLookup]:
    <k> lvalue( typedLookup(L:Int) => lookup(L)::T ) ...</k>
    <store>... L |-> _::T:Type ...</store>

//@ \texttt{lvalue}

rule [lvalueExprNameMember]:
    <k>
      lvalue(
        'ExprName(X:Id) => 'ExprName( ('This(.List{K}) ?? class Class),, X )
      )
      ...
    </k>
    <env> Env:Map </env>
    <crntClass> Class:Id </crntClass>
when notBool(X in keys(Env))  [structural]

context lvalue('ExprName(HOLE,, _:Id) )

rule [lvalueExprNameQualified]:
    <k>
      lvalue(
        'ExprName(
          objectClosure(_,
            <envStack>... ListItem((Class:Id, EnvC:BagItem)) EStack:List </envStack>
          ) :: class Class,,
          X:Id
        )
        => lookupField(
            <envStack> ListItem((Class, EnvC)) EStack:List </envStack>,
            X
          )
      )
      ...
    </k>
        [structural]

rule [lvalueSuperField]:
    <k> lvalue('SuperField(X:Id) => lookupField(<envStack>EStack</envStack>, X)) ...</k>
    <crntClass> Class:Id </crntClass>
    <envStack>... ListItem((Class, EnvC:BagItem)) EStack:List </envStack>
        [structural]

//@Section{lookup static field}

syntax K ::= "lookupStaticField" "("
                                    K "," // Class - class to search, or .K
                                    Id    // X - field name
                                  ")"

rule [ExprNameStaticField]:
    'ExprName(class Class:Id,, X:Id) => lookupStaticField(Class, X)

rule [lookupStaticField]:
    <k>
      lookupStaticField(Class:Id, X:Id) => typedLookup(L)
      ...
    </k>
    <className> Class </className>
    <staticEnv>... X |-> L ...</staticEnv>

rule [lookupStaticFieldContinue]:
    <k>
      lookupStaticField((Class:Id => BaseClassK), X:Id)
      ...
    </k>
    <className> Class </className>
    <extends> BaseClassK:K </extends>
    <staticEnv> Env:Map </staticEnv>
when
    notBool X in keys(Env)

rule [lookupStaticFieldEmpty]:
    lookupStaticField(.K, _) => noValue

rule [lvalueExprNameStaticField]:
    lvalue('ExprName(class Class:Id,, X:Id) => lookupStaticField(Class, X))

rule [lvalueLookupStaticField]:
    <k>
      lvalue(lookupStaticField(Class:Id, X:Id) => typedLookup(L))
      ...
    </k>
    <className> Class </className>
    <staticEnv>... X |-> L ...</staticEnv>

rule [lvalueLookupStaticFieldContinue]:
    <k>
      lvalue(lookupStaticField((Class:Id => BaseClassK), X:Id))
      ...
    </k>
    <className> Class </className>
    <extends> BaseClassK:K </extends>
    <staticEnv> Env:Map </staticEnv>
when
    notBool X in keys(Env)

/*@ \subsection{lvalue and loc} */

rule <k> lvalue(lookup(L:Int)::T:Type) => loc(L)::T ...</k>  [structural]

rule [lvalueExprNameLocal]:
    <k> lvalue('ExprName(X:Id)) => typedLoc(L) ...</k>
    <env>... X |-> L:Int ...</env>
        [structural]

syntax K ::= "typedLoc" "(" Int ")"

rule [typedLoc]:
    <k> typedLoc(L:Int) => loc(L)::T ...</k>
    <store>... L |-> _::T:Type ...</store>

rule [lvalueTypedLoc]:
    <k> lvalue( typedLoc(L:Int) => loc(L)::T ) ...</k>
    <store>... L |-> _::T:Type ...</store>

/*@ \subsection{lookup} */

rule [lookupVarName]:
    <k> X:Id => TV ...</k>
    <env>... X |-> L:Int ...</env>
    <store>... L |-> TV:TypedVal ...</store>

rule [lookupLocation]:
    <k>
      lookup(L:Int) :: T1:Type
      => subtype(T2, T1) ~> true? ~> V::T1
      ...
    </k>
    <store>... L |-> V:RawVal :: T2:Type ...</store>

endmodule
