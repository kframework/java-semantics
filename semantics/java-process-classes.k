module JAVA-PROCESS-CLASSES
    imports JAVA-CORE

//no semantics for 'Abstract and 'NoMethodBody required
//existing semantics for methods covers them too
syntax KLabel ::= 'Final | 'ThrowsDec | 'Abstract | 'NoMethodBody

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

//@ \section{Process type list}
syntax K ::= "processTypeList" "("
                                    Bag // the collection of <class> tags
                                ")"
           | "processTypeSet" "("
                                  Set   // the set of Ids - implemented interface names
                              ")"
           | "processTypeWithDepends" "("
                                K  //the class to be processed, or .K if no processing is required
                            ")"
           | "processType" "("
                                Id  //the class to be processed
                            ")"

rule [StartProcessClassesPhase]:
    <k> . => processTypeList(Classes) </k>
    <classes> Classes:Bag </classes>
    <computationPhase> ProcessCompUnitsPhase => ProcessClassesPhase </computationPhase>

rule [processTypeList]:
    (. => processTypeWithDepends(Class))
    ~>  processTypeList(
          (<class>
            ...
            <className> Class:Id </className>
            ...
          </class> => .Bag)
          _:Bag
        )

rule [ProcessTypeListDiscard]:
    processTypeList(.) => .

rule [processTypeSet]:
    (. => processTypeWithDepends(Class)) ~> processTypeSet((SetItem(Class) => .) _)

rule [processTypeSetDiscard]:
    processTypeSet(.) => .

rule [processTypeWithDepends]:
    <k>
      processTypeWithDepends(Class)
      => processTypeWithDepends(BaseClassK) ~> processTypeSet(ISet) ~> processType(Class)
      ...
    </k>
    <class>
      <className> Class </className>
      <extends> BaseClassK:K </extends>
      <implements> ISet:Set </implements>
      <declarations> Decls:K </declarations>
      ...
    </class>
when
    Decls =/=K .K

rule [processTypeWithDependsDiscard]:
    <k> processTypeWithDepends(Class) => . ...</k>
    <class>
      <className> Class </className>
      <declarations> .K </declarations>
      ...
    </class>

rule [processTypeWithDependsDiscard2]:
    processTypeWithDepends(.K) => .K

rule [ProcessType]:
    <k>
      processType(Class) => computeImplTrans(SetItem(BaseClassK) ISet)
          ~> tryInheritSet(ISet)

          //interfaces should also contain Object members
          ~> 'If((MetaT ==K interfaceMetaT)::bool,, tryInherit(String2Id("Object")))

          ~> tryInherit(BaseClassK) ~> Decls
      ...
    </k>
    <class>
      <className> Class </className>
      <extends> BaseClassK </extends>
      <implements> ISet </implements>
      <implTrans> . => ISet </implTrans>
      <declarations> Decls:K => . </declarations>
      <metaType> MetaT:MetaType </metaType>
      ...
    </class>
    <cuClass> _ => Class </cuClass>

//compute <implTrans> cell - interfaces transitively implemented
syntax K ::= "computeImplTrans" "(" Set ")"

rule [computeImplTrans]:
    <k>
      (. => implTransUnion(ITrans, BaseItfITrans))
      ~> computeImplTrans( (SetItem(BaseItf:Id) => .) _)
      ...
    </k>
    <cuClass> Class </cuClass>
    <className> Class </className>
    <implTrans> ITrans:Set </implTrans>
    <className> BaseItf </className>
    <implTrans> BaseItfITrans:Set </implTrans>

rule [computeImplTransElemDiscard]: computeImplTrans( (SetItem(.K) => .) _)

rule [computeImplTransDiscard]: computeImplTrans(.) => .

//subsection implTransUnion, union of sets. Remove when +Set will be implemented
syntax K ::= "implTransUnion" "(" Set "," Set ")"

rule implTransUnion(S1:Set, SetItem(K:K) S2:Set) => implTransUnion(S1 SetItem(K), S2)
when notBool(K in S1)

rule implTransUnion(S1, SetItem(K) S2) => implTransUnion(S1, S2)
when K in S1

rule <k> implTransUnion(S1, .Set) => . ...</k>
     <cuClass> Class </cuClass>
     <className> Class </className>
     <implTrans> _ => S1 </implTrans>

//inherits the methods of the base class, based on rules in JLS $8.4.8 paragraph 1
syntax K ::= "tryInheritSet" "(" Set ")"
           | "tryInherit" "(" K ")"
           | "tryInheritImpl" "(" Map ")"
           | "inherit" "(" Map ")"  //when checks are made, we are inheriting the method

rule [tryInheritSet]:
    (. => tryInherit(Class)) ~> tryInheritSet( (SetItem(Class) => .) _)

rule [tryInheritSetDiscard]: tryInheritSet(.) => .

rule [tryInherit]:
    <k>
      tryInherit(Class) => tryInheritImpl(Env)
      ...
    </k>
    <className> Class </className>
    <methods> Env:Map </methods>

rule [tryInheritDiscard]:
    tryInherit(.K) => .K

rule [tryInheritImplUnfold]:
    <k> (. => tryInheritImpl(MI)) ~> tryInheritImpl( (MI:MapItem => .) _:MapItem _) ...</k>

rule [tryInheritImpl]:
    tryInheritImpl(Sig:K |-> TV:TypedVal)
    => 'If(
          isInheritable(getMethodAccessMode(TV)),,
          inherit(Sig |-> TV),,
          .K
        )

rule [tryInheritImplDiscard]: tryInheritImpl(.) => .

syntax K ::= "isInheritable" "(" K ")" [strict]
rule isInheritable(public) => true::bool
rule isInheritable(protected) => true::bool

//Object class cannot match this rule since it have public access mode
rule [isInheritablePackage]:
    <k> isInheritable(package) => (P1 ==K P2)::bool ...</k>
    <cuClass> Class </cuClass>
    <class>
      <className> Class </className>
      <extends> BaseClass:Id </extends>
      <package> P1:K </package>
      ...
    </class>
    <class>
      <className> BaseClass </className>
      <package> P2:K </package>
      ...
    </class>

rule isInheritable(private) => false::bool

//todo if the same method is inherited say from base class ant interface,
//we're in trouble
rule [inherit]:
    <k> inherit(Sig |-> TV) => . ...</k>
    <cuClass> Class </cuClass>
    <class>
      <className> Class </className>
      <methods> Env => Env[TV/Sig] </methods>
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

rule [AbstractMethodDec]:
    'AbstractMethodDec(_:K,, Ks:List{K})
    =>  'MethodDec(
          'MethodDecHead('ListWrap('Public(.List{K}),,'Abstract(.List{K})),, Ks),,
          'NoMethodBody(.List{K})
        )

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
//KResult is required in java-method-invoke module
syntax KResult ::= "sig" "(" Id "," Types ")"

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
    <k>
      storeConstructor(Name, 'ListWrap(Params), FirstLine, S, MethodType) => .
      ...
    </k>
    <cuClass> Class:Id </cuClass>
    <className> Class </className>
    <methods>
      Env:Map => Env[
        constrClosure(Class, 'ListWrap(Params), FirstLine, S) :: MethodType
          / sig(getConsName(Name), typesFromParams(Params))
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
