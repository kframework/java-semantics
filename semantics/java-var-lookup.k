require "java-core.k"
require "java-subtyping.k"
require "java-process-classes.k"
require "java-static-init.k"
require "java-expressions.k"

module JAVA-VAR-LOOKUP
    imports JAVA-CORE
    imports JAVA-SUBTYPING
    imports JAVA-PROCESS-CLASSES
    imports JAVA-STATIC-INIT
    imports JAVA-EXPRESSIONS

//@ \subsection{Names}

rule [AmbName]:
    'AmbName(Ks:List{K}) => 'ExprName(Ks) ?? 'TypeName(Ks)
        [structural]

rule 'Field(Ks:List{K}) => 'ExprName(Ks)   [structural, anywhere]

rule [ExprNameLocalVar]:
    <k> 'ExprName(X:Id) => typedLookup(L) ...</k>
    <env>... X |-> L ...</env>
        [structural]

rule [ExprNameMember]:
    <k>
      'ExprName(X:Id) => 'ExprName( 'This(.List{K}),, X ) ?? 'ExprName( Class,, X )
      ...
    </k>
    <env> Env:Map </env>
    <crntClass> Class:ClassType </crntClass>
when
    notBool( (X in keys(Env)) orBool (Id2String(X) ==String "System") )
        [structural]

//resolving the qualifier of a qualified expression: either an object or a class reference
context 'ExprName(HOLE,, _:K)

/*@ \subsection{Self reference}
Like in untyped KOOL. */

rule [This]:
    <k>
      'This(.List{K})
      => objectClosure(OL, Obj) :: Class
      ...
    </k>
    <crntObj>
      Obj:Bag
      <crntClass> Class:ClassType </crntClass>
      <location> OL:Int </location>
    </crntObj>

rule [ThisNoValue]:
    <k>
      'This(.List{K}) => noValue
      ...
    </k>
    <location> noValue </location>

/*@ \subsection{Object member access} */

//Expressions of type o.x, where o is a reference of type class
rule [ExprNameClassRefQualified]:
    <k>
      'ExprName(
        objectClosure(_,
          <envStack>... ListItem((Class:ClassType, EnvC:BagItem)) EStack:List </envStack>
        ) :: Class,, X:Id
      )
      => lookupField(<envStack>ListItem((Class, EnvC)) EStack</envStack>, X)
      ...
    </k>
        [structural]

//Expressions of type o.x, where o is a reference of type interface
rule [ExprNameInterfaceRefQualified]:
    <k>
      'ExprName(objectClosure(_, _) :: Intf:ClassType,, X:Id)
      => 'ExprName(Intf,, X)
      ...
    </k>
    <classType> Intf </classType>
    <metaType> interfaceMetaT </metaType>
        [structural]

rule [ExprNameNoValue]:
    'ExprName( noValue,, X:Id ) => noValue    [structural]

rule [ExprNameQualifiedNull]:
    <k>
      'ExprName(null::_ ,, X:Id)
      =>  'Throw('NewInstance(
            'None(.List{K}),,
            class String2Id("java.lang.NullPointerException"),,
            'ListWrap( null :: nullType ),,
            'None(.List{K})
          ))
      ...
    </k>
        [structural]

rule [SuperField]:
    <k>'SuperField(X:Id) => lookupField(<envStack>EStack</envStack>, X) ...</k>
    <crntClass> Class:ClassType </crntClass>
    <envStack>... ListItem((Class, EnvC:BagItem)) EStack:List </envStack>
      [structural]

/*@ \subsection{Lookup member}
Like in untyped KOOL. */

//lookup field result is always typed
syntax K ::= "lookupField" "(" BagItem "," Id ")" [function]

rule lookupField(
    <envStack>
      ListItem((_, <env>... X |-> L:Int ...</env>))
      ...
    </envStack>,
    X:Id
  ) => typedLookup(L)
        [anywhere]

rule lookupField(
    <envStack>
      ListItem((_, <env> Env:Map </env>)) => .
      ...
    </envStack>,
    X:Id
  )
when notBool(X in keys(Env))
        [anywhere]

rule lookupField(<envStack> . </envStack>, _) => noValue
        [anywhere]

//@ \texttt{lvalue}

rule [lvalueExprNameMember]:
    <k>
      lvalue(
        'ExprName(X:Id) => 'ExprName( ('This(.List{K}) ?? Class),, X )
      )
      ...
    </k>
    <env> Env:Map </env>
    <crntClass> Class:ClassType </crntClass>
when notBool(X in keys(Env))  [structural]

//resolving the qualifier of a lvalue qualified expression: either an object or a class reference
context lvalue('ExprName(HOLE,, _:Id) )

rule [lvalueExprNameQualified]:
    <k>
      lvalue(
        'ExprName(
          objectClosure(_,
            <envStack>... ListItem((Class:ClassType, EnvC:BagItem)) EStack:List </envStack>
          ) :: Class,,
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
    <crntClass> Class:ClassType </crntClass>
    <envStack>... ListItem((Class, EnvC:BagItem)) EStack:List </envStack>
        [structural]

//@Section{lookup static field}

syntax K ::= "lookupStaticField" "("
                                    K "," // Class - ClassType to search, or .K
                                    Id    // X - field name
                                  ")"

rule [ExprNameStaticField]:
    'ExprName(Class:ClassType,, X:Id) => lookupStaticField(Class, X)

rule [lookupStaticField]:
    <k>
      lookupStaticField(Class:ClassType, X:Id) => typedLookup(L)
      ...
    </k>
    <classType> Class </classType>
    <staticEnv>... X |-> L ...</staticEnv>

rule [lookupStaticFieldContinue]:
    <k>
      lookupStaticField((Class:ClassType => BaseClassK), X:Id)
      ...
    </k>
    <classType> Class </classType>
    <extends> BaseClassK:K </extends>
    <staticEnv> Env:Map </staticEnv>
when
    notBool X in keys(Env)

rule [lookupStaticFieldEmpty]:
    lookupStaticField(.K, _) => noValue

rule [lvalueExprNameStaticField]:
    lvalue('ExprName(Class:ClassType,, X:Id) => lookupStaticField(Class, X))

rule [lvalueLookupStaticField]:
    <k>
      lvalue(lookupStaticField(Class:ClassType, X:Id)) => lvalue(typedLookup(L))
      ...
    </k>
    <classType> Class </classType>
    <staticEnv>... X |-> L ...</staticEnv>

rule [lvalueLookupStaticFieldContinue]:
    <k>
      lvalue(lookupStaticField((Class:ClassType => BaseClassK), X:Id))
      ...
    </k>
    <classType> Class </classType>
    <extends> BaseClassK:K </extends>
    <staticEnv> Env:Map </staticEnv>
when
    notBool X in keys(Env)

/*@ \subsection{lvalue and loc} */

//@Typed version of lookup
syntax K ::= "typedLookup" "(" Int ")"

rule [typedLookup]:
    <k> typedLookup(L:Int) => lookup(L)::T ...</k>
    <store>... L |-> _::T:Type ...</store>

rule [lvalueTypedLookup]:
    <k> lvalue( typedLookup(L:Int) => lookup(L)::T ) ...</k>
    <store>... L |-> _::T:Type ...</store>

rule [typedLookupUninitialized]:
    <k> (. => staticInit(Class)) ~> typedLookup(L:Int) ...</k>
    <store>... L |-> uninitialized(Class:ClassType, T:Type) ...</store>

rule [lvalueTypedLookupUninitialized]:
    <k> (. => staticInit(Class)) ~> lvalue(typedLookup(L:Int)) ...</k>
    <store>... L |-> uninitialized(Class:ClassType, T:Type) ...</store>

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

rule [lookupLocation]:
    <k>
      lookup(L:Int) :: T1:Type
      => subtype(T2, T1) ~> true? ~> V::T1
      ...
    </k>
    <store>... L |-> V:RawVal :: T2:Type ...</store>

endmodule
