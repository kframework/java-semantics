require "core.k"
require "classes.k"
require "method-invoke.k"

//@ \section{Module API-CORE}

module API-CORE
    imports CORE
    imports CLASSES
    imports METHOD-INVOKE
    imports VAR-LOOKUP
    imports LITERALS  //for string-related functions

// This module contains the minimal part of java API required to perform
// console read/write operations, as well as a few other API functions mentioned in JLS.

//@ For integers and strings, print their value. For classes, print class type.

rule [system-out-print-string]:
    <k>
      invokeImpl(
        methodClosure(_,_,_,_,_,_, 'NoMethodBody(_))::methodType(sig(MethodName:Id, _),_), _,
        'ListWrap(Str:String :: _)
      ) => nothing::void
      ...
    </k>
    <out>... . => ListItem(Str) </out>
when
    Id2String(MethodName) ==String "print"

  //With [transition-threading], the time to produce 2 solutions for the test threads_11_two_th_msg is 14s.
  //But with [transition-strictness], the same test takes 3m52s, with java heap = 16GB.
        [transition-threading]

//Is only used for primitive type arguments. Object arguments are converted by java code inside the class PrintWriter.
rule [system-out-print-convert]:
    invokeImpl(
      methodClosure(_,_,_,_,_,_, 'NoMethodBody(_))::methodType(sig(MethodName:Id, _),_), _,
      'ListWrap(RV:RawVal :: T:Type => toString(RV::T))
    )
when
    (Id2String(MethodName) ==String "print") andBool notBool (isString(RV) ==K true)

//system-out-print-convert heat argument
context
    invokeImpl(
      methodClosure(_,_,_,_,_,_, 'NoMethodBody(_))::methodType(sig(MethodName:Id, _),_), _,
      'ListWrap(HOLE)
    )
when
    Id2String(MethodName) ==String "print"

rule [scanner-nextInt]:
    invokeImpl(
      methodClosure(_,_,_,_,_,_, 'NoMethodBody(_))::methodType(sig(MethodName:Id, _),_), _,
      'ListWrap(.KList)
    ) => readInt
when
    Id2String(MethodName) ==String "nextInt"

//An intermediate construct for reading from console, meant mostly to simplify debugging.
syntax K ::= "readInt"

rule [readInt]:
    <k> readInt => I :: int ...</k>
    <in> ListItem(I:Int) => . ...</in>

rule [object-getClass-on-object]:
    <k>
      invokeImpl(
        methodClosure(_,_,_,_,_,_, 'NoMethodBody(_))::methodType(sig(MethodName:Id, _),_), OL:Int,
        'ListWrap(.KList)
      ) => 'Lit('Class(T))
      ...
    </k>
    <store>
      ...
      OL |-> objectClosure(_, ListItem(el(T:ClassType, _,_,_)) _:List, _) :: _
      ...
    </store>
when
    Id2String(MethodName) ==String "getClass"

rule [object-getClass-on-String]:
    invokeImpl(
      methodClosure(_,_,_,_,_,_, 'NoMethodBody(_))::methodType(sig(MethodName:Id, _),_), Str:String::rtString,
      'ListWrap(.KList)
    ) => 'Lit('Class(rtString))
when
    Id2String(MethodName) ==String "getClass"

rule [object-getClass-on-array]:
    invokeImpl(
      methodClosure(_,_,_,_,_,_, 'NoMethodBody(_))::methodType(sig(MethodName:Id, _),_), arrayRef(_,_,_)::ArrT:Type,
      'ListWrap(.KList)
    ) => 'Lit('Class(ArrT))
when
    Id2String(MethodName) ==String "getClass"

rule [object-toString-on-String]:
    invokeImpl(
      methodClosure(_,_,_,_,_,_, 'NoMethodBody(_))::methodType(sig(MethodName:Id, _),_), Str:String::rtString,
      'ListWrap(.KList)
    ) => Str::rtString
when
    Id2String(MethodName) ==String "toString"

//hashCode will always return 0 for now
rule [object-hashCode]:
    <k>
      invokeImpl(
        methodClosure(_,_,_,_,_,_, 'NoMethodBody(_))::methodType(sig(MethodName:Id, _),_), OL:Int,
        'ListWrap(.KList)
      ) => NewOL :: int
      ...
    </k>
    <store>
      ...
      OL |-> objectClosure(NewOL:Int, _,_) :: _
      ...
    </store>
when
    Id2String(MethodName) ==String "hashCode"

//\subsection{String methods}

rule [elab-String-length]:
    lookupMethod( rtString, MethodName:Id,
      _, noValue, false, QualTE:TypedExp, .KList
    ) => elabRes(methodInvokeRuntime(rtString, sig(MethodName, types(.KList)), QualTE, .KList, instanceCT) :: objectClass)
when
    Id2String(MethodName) ==String "length"

rule [methodInvokeRuntime-String-length]:
    methodInvokeRuntime(rtString, sig(MethodName:Id, _), Str:String::rtString, _,_ )::_
    => lengthString(Str) :: int
when Id2String(MethodName) ==String "length"

//static native String valueOf(int i);
rule [elab-String-valueOf]:
    lookupMethod( rtString, MethodName:Id,
      _, noValue, false, QualK:K, ParamExp:TypedExp
    ) => elabRes(methodInvokeRuntime(rtString, sig(MethodName, types(.KList)), QualK, ParamExp, instanceCT) :: objectClass)
when
    Id2String(MethodName) ==String "valueOf"

rule [methodInvokeRuntime-String-valueOf]:
    methodInvokeRuntime(rtString, sig(MethodName:Id, _), _, I:Int :: int,_ )::_
    => Int2String(I) :: rtString
when Id2String(MethodName) ==String "valueOf"

//\subsection{Array clone}

rule [elab-array-clone]:
    lookupMethod( arrayOf T:Type, MethodName:Id,
      _, noValue, false, QualTE:TypedExp, .KList
    ) => elabRes(methodInvokeRuntime(arrayOf T:Type, sig(MethodName, types(.KList)), QualTE, .KList, instanceCT) :: objectClass)
when
    Id2String(MethodName) ==String "clone"

rule [methodInvokeRuntime-array-clone]:
    methodInvokeRuntime(_, sig(MethodName:Id, _),
        arrayRef(arrayOf ElemT:Type, Loc:Int, Len:Int)::CompileT:Type, _,_
    )::_
    => arrayCopy(
        arrayRef(arrayOf ElemT:Type, Loc:Int, Len:Int)::CompileT,
        newArrayAlloc(ElemT, 'ListWrap(Len::int), undefined :: ElemT)
      )
when Id2String(MethodName) ==String "clone"

//construct to copy content of an array to another
//after copy, the term is rewritten into the destination array
syntax K ::=  "arrayCopy" "("
                              TypedVal "," // source array
                              K            // destination array, computes to TypedVal
              ")"
        [strict(2)]

rule arrayCopy(arrayRef(T:Type, L1:Int, Len:Int)::_, arrayRef(T, L2:Int, Len)::_)
    => storeCopy(L1, L2, Len) ~> arrayRef(T,L2:Int,Len)::T

//copy a sequence of store values from one place to another
syntax K ::=  "storeCopy" "("
                              Int "," //source address in store
                              Int "," //destination address in store
                              Int     //amount of elements to copy
              ")"

rule [storeCopy]:
    <k>
      storeCopy(L1:Int, L2:Int, Len:Int) => storeCopy(L1 +Int 1, L2 +Int 1, Len -Int 1)
      ...
    </k>
    <store>
      ...
      L1 |-> K:K
      //...
      L2 |-> (_ => K)
      ...
    </store>
when
    Len >Int 0

rule [storeCopyDiscard]:
    storeCopy(_, _, 0) => .

//\subsection{Class literal}

//we need to synchronize access to class literals to avoid instantiation of the came .class by multiple threads.
//this is done by the term temp in <classLiteralsMap>
//We cannot use 'Synchronized because it required an objectClousre as argument, and we might not have any
//objects instantiated at the moment.
rule [ClassLiteralInstantiate]:
    <k>
        (. => saveClassLiteral(T, 'NewInstance(
                'None(.KList),,
                class String2Id("java.lang.Class"),,
                'ListWrap(toString(T)),,
                'None(.KList)
              ))
        )
        ~> 'Lit('Class(T:Type))::_
      ...
    </k>
    <classLiteralsMap> CLMap:Map (. => T |-> temp) </classLiteralsMap>
when notBool T in keys(CLMap)
        [transition-threading]

// wraps a newly created java.lang.Class object
syntax K ::= "saveClassLiteral" "(" Type  // The type for this class literal is being instantiated
                                "," K     // The class literal instantiation expression
                                ")"         [strict(2)]

rule [saveClassLiteral]:
    <k> saveClassLiteral(T:Type, TV:TypedVal) => . ...</k>
    <classLiteralsMap>... T |-> (temp => TV) ...</classLiteralsMap>

rule [ClassLiteral]:
    <k> 'Lit('Class(T:Type))::_ => TV ...</k>
    <classLiteralsMap>... T |-> TV:TypedVal ...</classLiteralsMap>

syntax K ::= "temp" //Used inside <classLiteralsMap> only for synchronization purposes

rule [ClassNameTopLevelWithPackage]:
    <k>
      toString(class ClassId:Id) => Id2String(ClassId)
      ...
    </k>
    <classType> class ClassId </classType>
    <enclosingClass> noClass </enclosingClass>
when
    retainHead(Id2String(ClassId), 1) =/=String "."

rule [ClassNameTopLevelWithDefaultPackage]:
    <k>
      toString(class ClassId:Id) => trimHead(Id2String(ClassId), 1)
      ...
    </k>
    <classType> class ClassId </classType>
    <enclosingClass> noClass </enclosingClass>
when
    retainHead(Id2String(ClassId), 1) ==String "."

rule [ClassNameInner]:
    <k>
      toString(class ClassId:Id)
      => 'Plus(
            toString(class OuterClassId),,
            ("$" +String Id2String(SimpleName))::rtString
         ) :: rtString
      ...
    </k>
    <classType> class ClassId </classType>
    <enclosingClass> class OuterClassId:Id </enclosingClass>
    <typeNamesMap>... _ |-> mapWrap(SimpleName:Id |-> class ClassId _:Map) ...</typeNamesMap>

endmodule
