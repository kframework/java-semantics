module JAVA-PROCESS-CLASSES
    imports JAVA-CORE

//no semantics for 'Abstract and 'NoMethodBody required
//existing semantics for methods covers them too
syntax KLabel ::= 'Abstract | 'NoMethodBody

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

//@ \section{Class list analyze}
syntax K ::= "classListAnalyze" "("
                                    Bag // the collection of <class> tags
                                ")"
           | "classAnalyze" "("
                                Id  //the class to be analyzed
                            ")"

rule [classListAnalyze]:
    <k> . => classListAnalyze(Classes) </k>
    <classes> Classes:Bag </classes>
    <executionPhase> "ProcessCompUnits" => "ProcessClasses" </executionPhase>

rule [classAnalyzeInit]:
    (. => classAnalyze(Class))
    ~>  classListAnalyze(
          (<class>
            ...
            <className> Class:Id </className>
            ...
          </class> => .Bag)
          _:Bag
        )

rule [classAnalyzeBaseClass]:
    <k> (. => classAnalyze(BaseClass)) ~> classAnalyze(Class) ...</k>
    <class>
      <className> Class </className>
      <extends> BaseClass:Id </extends>
      ...
    </class>
    <class>
      <className> BaseClass </className>
      <declarations> Decls:K </declarations>
      ...
    </class>
when
    Decls =/=K .K

rule [ClassAnalyze]:
    <k> classAnalyze(Class) => tryInherit(Env) ~> Decls ...</k>
    <class>
      <className> Class </className>
      <extends> BaseClass:Id </extends>
      <declarations> Decls:K => . </declarations>
      ...
    </class>
    <class>
      <className> BaseClass </className>
      <declarations> .K </declarations>
      <methods> Env:Map </methods>
      ...
    </class>
    <cuClass> _ => Class </cuClass>
when
    Decls =/=K .K

rule [ClassAnalyzeObject]:
    <k> classAnalyze(Class) => Decls ...</k>
    <class>
      <className> Class </className>
      <declarations> Decls:K => . </declarations>
      ...
    </class>
    <cuClass> _ => Class </cuClass>
when
    Id2String(Class) ==String "Object"

rule [ClassAnalyzeDiscard]:
    <k> classAnalyze(Class) => . ...</k>
    <class>
      <className> Class </className>
      <declarations> .K </declarations>
      ...
    </class>

rule [classListAnalyzeDiscard]:
    classListAnalyze(.) => .

//inherits the methods of the base class, based on rules in JLS $8.4.8 paragraph 1
syntax K ::= "tryInherit" "(" Map ")"
           | "inherit" "(" Map ")"  //when checks are made, we are inheriting the method

rule [tryInheritUnfold]:
    <k> (. => tryInherit(MI)) ~> tryInherit( (MI:MapItem => .) _:MapItem _) ...</k>

rule [tryInherit]:
    tryInherit(Sig:K |-> TV:TypedVal)
    => 'If(
          isInheritable(getMethodAccessMode(TV)),,
          inherit(Sig |-> TV),,
          .K
        )

syntax K ::= "isInheritable" "(" K ")" [strict]
rule isInheritable(public) => true::bool
rule isInheritable(protected) => true::bool

rule [isInheritablePackage]:
    <k> isInheritable(package) => (P1 ==K P2)::bool ...</k>
    <cuClass> Class </cuClass>
    <class>
      <className> Class </className>
      <extends> BaseClass </extends>
      <package> P1:K </package>
      ...
    </class>
    <class>
      <className> BaseClass </className>
      <package> P2:K </package>
      ...
    </class>

rule isInheritable(private) => false::bool

rule [inherit]:
    <k> inherit(MI) => . ...</k>
    <cuClass> Class </cuClass>
    <class>
      <className> Class </className>
      <methods> (. => MI) _ </methods>
      ...
    </class>

//returns the access mode of a method in the location L given as argument
syntax K ::= "getMethodAccessMode" "(" TypedVal ")" [function strict(1)]
rule getMethodAccessMode( _ :: methodType(Acc:AccessMode,_,_) ) => Acc [anywhere]

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
    => storeMethod(Name, typesFromParams(Params), 'ListWrap(Params), S,
          methodType(Acc, Params, ReturnType))
        [structural]

syntax K ::= "storeMethod" "("
                              Id ","
                              K "," //will evalute to Types - a syntactic list of types
                              K ","
                              K ","
                              Type
                           ")"

syntax K     ::= "typesFromParams" "(" List{K} ")"
syntax Types ::= "types" "(" List{KResult} ")"
syntax KResult ::= Types

rule typesFromParams(_:List{KResult},, ('Param(_:K,,T:Type,,_:K) => T),, _:List{K})
        [structural anywhere]

rule typesFromParams(KRs:List{KResult}) => types(KRs)
        [structural anywhere]

context storeMethod(_, _, _, _,
    methodType(_, _:List{K},, (HOLE => typeOf(HOLE)),, _:List{K}, _))

rule [storeMethod]:
    <k> storeMethod(Name, Ts:Types, 'ListWrap(Params), S, MethodType:Type) =>. ...</k>
    <cuClass> Class:Id </cuClass>
    <className> Class </className>
    <methods>
      Env:Map => Env[ methodClosure(Class, 'ListWrap(Params), S) :: MethodType / sig(Name,Ts) ]
    </methods>

//A method signature
syntax K ::= "sig" "(" Id "," Types ")"

//todo Simplify constructor processing. There are too much indirections right now.

rule [ConstrDecSuperCallDesugar]:
    'ConstrDec(
      'ConstrDecHead(_:K,, _:K,, Name,, _:List{K}),,
      'ConstrBody(
        (
          'None(_)
          => 'Some('SuperConstrInv( 'None(.List{K}),, 'ListWrap(.List{K}) ))
        ),,
        _:K
      )
    )
when
    Id2String(Name) =/=String "Object"

rule [ConstrDecObjectDesugar]:
    'ConstrDec(
      'ConstrDecHead(_:K,, _:K,, Name,, _:List{K}),,
      'ConstrBody(
        (
          'None(_) => 'Some(.K)
        ),,
        _:K
      )
    )
when
    Id2String(Name) ==String "Object"

context 'ConstrDec('ConstrDecHead((HOLE => getAccessMode(HOLE)),, _),, _)

rule [ConstrDec]:
    'ConstrDec('ConstrDecHead(Acc,, _:K,, Name,, 'ListWrap(Params),, _),,
        'ConstrBody(
      'Some(FirstLine:K) ,,S))
    => storeConstructor(Name, 'ListWrap(Params), FirstLine,
        S, methodType(Acc, Params, void))

syntax K ::= "storeConstructor" "(" Id    // Class name
                                "," K     // 'ListWrap(Params) - formal params
                                "," K     // FirstLine - SyperConstrInv()
                                "," K     // S - constructor body
                                "," Type  // MethodType of the constructor
                                ")"

context storeConstructor(_, _, _, _,
    methodType(_, _:List{K},, (HOLE => typeOf(HOLE)),, _:List{K}, _))

rule [storeConstructor]:
    storeConstructor(Name, 'ListWrap(Params), FirstLine, S, MethodType)
    => storeConstrImpl(
      Name,
      typesFromParams(Params),
      'ListWrap(Params),
      FirstLine,
      S,
      MethodType
    )

syntax K ::= "storeConstrImpl" "("
                              Id ","
                              K "," //will evalute to Types - a syntactic list of types
                              K ","
                              K "," // this(), super() of .K - constructor first line
                              K "," // S - constructor body
                              Type
                           ")"

context storeConstrImpl(_, _, _, _, _,
    methodType(_, _:List{K},, (HOLE => typeOf(HOLE)),, _:List{K}, _))

rule [storeConstrImpl]:
    <k>
      storeConstrImpl(Name, Ts:Types, 'ListWrap(Params), FirstLine, S, MethodType:Type) => .
      ...
    </k>
    <cuClass> Class:Id </cuClass>
    <className> Class </className>
    <methods>
      Env:Map => Env[
        constrClosure(Class, 'ListWrap(Params), FirstLine, S) :: MethodType
          / sig(getConsName(Name), Ts)
      ]
    </methods>

rule [FieldDecDesugar]:
    (. => 'FieldDec(SomeK,, TypeK,, 'ListWrap(K1))) ~>
    'FieldDec(SomeK:K,, TypeK:K,, 'ListWrap((K1:K => .List{K}),, K2:K,, Ks:List{K}))

rule [FieldDecInitDesugar]:
    'FieldDec(_:K,, TypeK,, 'ListWrap('VarDec(X:Id,,(InitExp:K => .List{K})) ))
    ~> (. => 'InstanceInit('ExprStm('Assign('ExprName(X),, InitExp))))
when
    getKLabel(InitExp) =/=KLabel 'ArrayInit
      [structural]

rule [FieldDecToLocalVarDec]:
    <k> 'FieldDec(_,, TypeK:K,, 'ListWrap('VarDec(X:Id))) => . ...</k>
    <cuClass> Class </cuClass>
    <className> Class </className>
    <fieldDecs>
      'ListWrap(_,, ( .List{K} => 'LocalVarDec(TypeK,, 'ListWrap('VarDec(X,, default(TypeK)))) ))
    </fieldDecs>
        [structural]

rule [InstanceInitSave]:
    <k> 'InstanceInit(K) => . ...</k>
    <cuClass> Class </cuClass>
    <className> Class </className>
    <instanceInit>... . => K </instanceInit>
        [structural]

//@ \subsection{Interplay of fields and arrays}

//The following three rules are copy-paste adaptations from rules related to local vars,
//from java-statements.

//desugaring of C-style array declarators

rule [ArrayFieldDecIdDesugar]:
    'FieldDec(
      _,,
      (T:Type => arrayOf T),,
      'ListWrap('VarDec('ArrayVarDecId(
          X:Id,,
          'ListWrap(('Dim(.List{K}) => .List{K}) ,,_)
      ),, _ //possible initializer
    )))

rule [ArrayFieldDecIdDiscard]:
    'FieldDec(_,, T,, 'ListWrap('VarDec(
        ( 'ArrayVarDecId( X,, 'ListWrap(.List{K}) ) => X ),,
        _ //possible initializer
    )))

//desugaring fields with ArrayInit
rule [FieldDecWithArrayInitDesugar]:
    'FieldDec(_,, T,, 'ListWrap('VarDec(
      X,,
      ( 'ArrayInit(InitK:K) => 'NewArray(T,, 'ListWrap(.List{K}),, 'ArrayInit(InitK)) )
    )))

//get internal constructor name from a class name
syntax K ::= "getConsName" "(" Id ")" [function]
rule getConsName(X:Id) => String2Id("$cons$" +String Id2String(X)) [structural anywhere]

end module
