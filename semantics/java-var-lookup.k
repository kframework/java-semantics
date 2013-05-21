require "java-core.k"
require "java-subtyping.k"
require "java-process-classes.k"
require "java-static-init.k"
require "java-expressions.k"

//todo remove al rules related to 'Field

module JAVA-VAR-LOOKUP
    imports JAVA-CORE
    imports JAVA-SUBTYPING
    imports JAVA-PROCESS-CLASSES
    imports JAVA-STATIC-INIT
    imports JAVA-EXPRESSIONS

//@ \subsection{Names}

//performance optimization - the qualifier of an AmbName should be always resolved first,
//no matter how are we going to interpret the AmbName,
//so why not resolving it now?
//todo remove after elabration phase will work
context 'AmbName(HOLE,, _:K)

//this rule covers both unqualified and qualified AmbName
//todo remove after elabration phase will work
rule [AmbName]:
    'AmbName(Ks:List{K},, K:K)
    => 'ExprName(Ks,,K) ?? 'TypeName(Ks,,K) ?? 'PackageName('ListWrap(Ks,,K))
when isKResult(Ks)                          [structural]

//todo remove after elabration phase will work
rule [ExprNameSimple]:
  'ExprName(X) => localVar(X) ?? 'Field(X)

//todo remove after elabration phase will work
rule [ExprNameQualified]:
    'ExprName(K1:K,,K2:K) => 'Field(K1,,K2)

//lookup the given local var by name. Return noValue if none found.
syntax K ::= "localVar" "(" Id //the var name
                        ")"

rule [localVarOK]:
    <k> localVar(X:Id) => typedLookup(L) ...</k>
    <env>... X |-> L ...</env>

rule [localVarNoValue]:
    <k> localVar(X:Id) => noValue ...</k>
    <env> Env:Map </env>
when notBool X in keys(Env)

//todo remove after elabration phase will work
rule [FieldUnqualified]:
    <k>
      'Field(X:Id)
      => 'Field( 'This(.List{K}),, X ) ?? 'Field( Class,, X ) ?? outerStaticField(Class, X)
      ...
    </k>
    <crntClass> Class:ClassType </crntClass>

//todo reconsider after elabration phase will work
//resolving the qualifier of a qualified field access: it is either an object or a class reference
context 'Field(HOLE,, _:K)

/*@ \subsection{Self reference}
Like in untyped KOOL. */

//todo reconsider after elabration phase will work
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

//todo remove after elabration phase will work
rule [ThisNoValue]:
    <k>
      'This(.List{K}) => noValue
      ...
    </k>
    <location> noValue </location>

/*@ \subsection{Object member access} */

//new rules

//outside lvalue we have strictness rules

context lvalue(lookupFieldImpl(HOLE,_,_))

rule [lookupFieldImpl]:
    lookupFieldImpl(
      objectClosure(_,
          <envStack>... ListItem((TargetClass, EnvC:BagItem)) ...</envStack>
        ) ::_,
      TargetClass:ClassType,
      X:Id
    ) => lookupField(<envStack>ListItem((TargetClass, EnvC)) </envStack>, X)
        [structural, anywhere]

rule [lookupFieldImplOfNull]:
    <k>
      lookupFieldImpl(null::_, _, _)
      =>  'Throw('NewInstance(
            'None(.List{K}),,
            class String2Id("java.lang.NullPointerException"),,
            'ListWrap( null :: nullType ),,
            'None(.List{K})
          ))
      ...
    </k>
        [structural, anywhere]

rule [lookupStaticFieldImpl]:
    lookupStaticFieldImpl(
      TargetClass:ClassType,
      X:Id
    ) => lookupStaticField(TargetClass, X)
        [structural, anywhere]

//todo bug: this rule and the next one are not mutually exclusive. Expose the problem in a test.
//Expressions of type o.x, where o is a reference of type class
rule [FieldClassRefQualified]:
    <k>
      'Field(
        objectClosure(_,
          <envStack>... ListItem((Class:ClassType, EnvC:BagItem)) EStack:List </envStack>
        ) :: Class,, X:Id
      )
      => lookupField(<envStack>ListItem((Class, EnvC)) EStack</envStack>, X)
      ...
    </k>
        [structural]

//Expressions of type o.x, where o is a reference of type interface
rule [FieldInterfaceRefQualified]:
    <k>
      'Field(objectClosure(_, _) :: Intf:ClassType,, X:Id)
      => 'Field(Intf,, X)
      ...
    </k>
    <classType> Intf </classType>
    <metaType> interfaceMetaT </metaType>
        [structural]

//todo test similar case for lvalue('Field) ?
//moved ot elaborate-blocks
//rule [FieldOfPackage]:
//    'Field( _:PackageId,, _:Id ) => noValue  [structural, anywhere]

//rule [FieldOfNoValue]:
//    'Field( noValue,, _:Id ) => noValue      [structural, anywhere]

rule [FieldOfNull]:
    <k>
      'Field(null::_ ,, X:Id)
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

//@Section{lookup static field}

syntax K ::= "lookupStaticField" "(" ClassType // Class - ClassType to search, or noClass
                                 "," Id        // X - field name
                                 ")"

//todo reconsider after elabration phase will work
rule [FieldStaticField]:
    'Field(Class:ClassType,, X:Id) => lookupStaticField(Class, X)

rule [lookupStaticField]:
    <k>
      lookupStaticField(Class:ClassType, X:Id) => typedLookup(L)
      ...
    </k>
    <classType> Class </classType>
    <staticEnv>... X |-> L ...</staticEnv>

rule [lookupStaticFieldContinue]:
    <k>
      lookupStaticField((Class:ClassType => BaseClass), X:Id)
      ...
    </k>
    <classType> Class </classType>
    <extends> BaseClass:ClassType </extends>
    <staticEnv> Env:Map </staticEnv>
when
    notBool X in keys(Env)

rule [lookupStaticFieldEmpty]:
    lookupStaticField(noClass, _) => noValue

//@ \texttt{lvalue}

rule [lvalueExprNameSimple]:
    lvalue('ExprName(X:Id)) => lvalue(localVar(X)) ?? lvalue('Field(X))

rule [lvalueExprNameQualified]:
    lvalue('ExprName(K1:K,,K2:K)) => lvalue('Field(K1,,K2))

rule [lvalueExprNameLocal]:
    <k> lvalue(localVar(X:Id)) => typedLoc(L) ...</k>
    <env>... X |-> L:Int ...</env>            [structural]

rule [lvalueExprNameDiscard]:
    <k> lvalue(localVar(X:Id)) => noValue ...</k>
    <env> Env:Map </env>
when notBool X in keys(Env)                   [structural]

rule [lvalueExprNameMember]:
    <k>
      lvalue('Field(X:Id))
      => lvalue('Field( 'This(.List{K}),, X )) ?? lvalue('Field( Class,, X ))
         ?? lvalue(outerStaticField(Class, X ))
      ...
    </k>
    <crntClass> Class:ClassType </crntClass>  [structural]

//resolving the qualifier of a lvalue qualified expression: either an object or a class reference
context lvalue('Field(HOLE,, _:Id) )

rule [lvalueExprNameQualified]:
    <k>
      lvalue(
        'Field(
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

rule [lvalueExprNameStaticField]:
    lvalue('Field(Class:ClassType,, X:Id) => lookupStaticField(Class, X))

rule [lvalueOfNoValue]:
    lvalue(noValue) => noValue

rule [lvalueLookupStaticField]:
    <k>
      lvalue(lookupStaticField(Class:ClassType, X:Id)) => lvalue(typedLookup(L))
      ...
    </k>
    <classType> Class </classType>
    <staticEnv>... X |-> L ...</staticEnv>

rule [lvalueLookupStaticFieldContinue]:
    <k>
      lvalue(lookupStaticField((Class:ClassType => BaseClass), X:Id))
      ...
    </k>
    <classType> Class </classType>
    <extends> BaseClass:ClassType </extends>
    <staticEnv> Env:Map </staticEnv>
when
    notBool X in keys(Env)

rule [lvalueLookupStaticFieldEmpty]:
    lvalue(lookupStaticField(noClass, _)) => noValue

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

//Search for fields with this name in the outer classes of the given class, if any.
syntax K ::= "outerStaticField" "(" ClassType //The original class. We will search in
                                              //its outer classes
                                "," Id        //The field name
                                ")"

rule [outerStaticField]:
    <k>
      outerStaticField(Class:ClassType, X:Id)
      => lookupStaticField(EnclosingClass, X) ?? outerStaticField(EnclosingClass, X)
      ...
    </k>
    <classType> Class </classType>
    <enclosingClass> EnclosingClass:ClassType </enclosingClass>

rule [outerStaticFieldDiscard]:
    outerStaticField(noClass, _) => noValue

rule [lvalueOuterStaticField]:
    <k>
      lvalue(outerStaticField(Class:ClassType, X:Id))
      => lvalue(lookupStaticField(EnclosingClass, X)) ?? lvalue(outerStaticField(EnclosingClass, X))
      ...
    </k>
    <classType> Class </classType>
    <enclosingClass> EnclosingClass:ClassType </enclosingClass>

rule [lvalueOuterStaticFieldDiscard]:
    lvalue(outerStaticField(noClass, _)) => noValue

endmodule
