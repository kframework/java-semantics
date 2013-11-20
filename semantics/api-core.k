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

/*@ This module contains the minimal part of java API required to perform console read/write operations, as well as a few other API functions mentioned in JLS.*/

//@ System.out.print(). For integers and strings, print their value. For classes, print class type.

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

//@Is only used for primitive type arguments. Object arguments are converted by java code inside the class PrintWriter.
rule [system-out-print-convert]:
    invokeImpl(
      methodClosure(_,_,_,_,_,_, 'NoMethodBody(_))::methodType(sig(MethodName:Id, _),_), _,
      'ListWrap(RV:RawVal :: T:Type => toString(RV::T))
    )
when
    (Id2String(MethodName) ==String "print") andBool notBool (isString(RV) ==K true)

//@system-out-print-convert heat argument
context
    invokeImpl(
      methodClosure(_,_,_,_,_,_, 'NoMethodBody(_))::methodType(sig(MethodName:Id, _),_), _,
      'ListWrap(HOLE)
    )
when
    Id2String(MethodName) ==String "print"

/*@Scanner.nextInt(), used to read from the console.*/
rule [scanner-nextInt]:
    invokeImpl(
      methodClosure(_,_,_,_,_,_, 'NoMethodBody(_))::methodType(sig(MethodName:Id, _),_), _,
      'ListWrap(.KList)
    ) => readInt
when
    Id2String(MethodName) ==String "nextInt"

rule [scanner-nextInt]:
    invokeImpl(
      methodClosure(_,_,_,_,_,_, 'NoMethodBody(_))::methodType(sig(MethodName:Id, _),_), _,
      'ListWrap(.KList)
    ) => readString
when
    Id2String(MethodName) ==String "nextLine"

//@An intermediate construct for reading from console, meant mostly to simplify debugging.
syntax K ::= "readInt"
           | "readString"

rule [readInt]:
    <k> readInt => I :: int ...</k>
    <in> ListItem(I:Int) => . ...</in>

rule [readString]:
    <k> readString => Str :: rtString ...</k>
    <in> ListItem(Str:String) => . ...</in>

/*@ object.getClass()*/
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

/*@ String.toString(). For Object.toString() the implementation is in the library java code.*/
rule [object-toString-on-String]:
    invokeImpl(
      methodClosure(_,_,_,_,_,_, 'NoMethodBody(_))::methodType(sig(MethodName:Id, _),_), Str:String::rtString,
      'ListWrap(.KList)
    ) => Str::rtString
when
    Id2String(MethodName) ==String "toString"

/*@Object.hashCode(). Returns the canonical memory location of the objectClosure. */
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

//@\subsection{String methods}

//@int String.length()
rule [elab-String-length]:
    lookupMethod( rtString, MethodName:Id,
      _, noValue, false, QualTE:TypedExp, .KList
    ) => elabRes(methodInvokeRuntime(rtString, sig(MethodName, types(.KList)), QualTE, .KList, instanceCT) :: int)
when
    Id2String(MethodName) ==String "length"

rule [methodInvokeRuntime-String-length]:
    methodInvokeRuntime(rtString, sig(MethodName:Id, _), Str:String::rtString, _,_ )::_
    => lengthString(Str) :: int
when Id2String(MethodName) ==String "length"

rule [elab-String-charAt]:
    lookupMethod( rtString, MethodName:Id,
      _, noValue, false, QualTE:TypedExp, ParamExp:TypedExp
    ) => elabRes(methodInvokeRuntime(rtString, sig(MethodName, types(.KList)), QualTE, ParamExp, instanceCT) :: char)
when
    Id2String(MethodName) ==String "charAt"

rule [methodInvokeRuntime-String-charAt]:
    methodInvokeRuntime(rtString, sig(MethodName:Id, _), Str:String::rtString, I:Int :: int, _ )::_
    => ordChar(substrString(Str, I, I +Int 1)) :: char
when Id2String(MethodName) ==String "charAt"

//@static native String String.valueOf(int i);
rule [elab-String-valueOf]:
    lookupMethod( rtString, MethodName:Id,
      _, noValue, false, QualK:K, ParamExp:TypedExp
    ) => elabRes(methodInvokeRuntime(rtString, sig(MethodName, types(.KList)), QualK, ParamExp, instanceCT) :: rtString)
when
    Id2String(MethodName) ==String "valueOf"

rule [methodInvokeRuntime-String-valueOf]:
    methodInvokeRuntime(rtString, sig(MethodName:Id, _), _, I:Int :: int,_ )::_
    => Int2String(I) :: rtString
when Id2String(MethodName) ==String "valueOf"

//@boolean String.equals(Object)
rule [elab-String-equals]:
    lookupMethod( rtString, MethodName:Id,
      _, noValue, false, QualK:K, ParamExp:TypedExp
    ) => elabRes(methodInvokeRuntime(rtString, sig(MethodName, types(.KList)), QualK, ParamExp, instanceCT) :: bool)
when
    Id2String(MethodName) ==String "equals"

rule [methodInvokeRuntime-String-equals]:
    methodInvokeRuntime(rtString, sig(MethodName:Id, _), ThisStr:String::_, ParamStr:String::_ ,_ )::_
    => 'Eq(ThisStr,, ParamStr)
when Id2String(MethodName) ==String "equals"

//@String.toString()
rule [elab-String-toString]:
    lookupMethod( rtString, MethodName:Id,
      _, noValue, false, QualK:K, .KList
    ) => elabRes(methodInvokeRuntime(rtString, sig(MethodName, types(.KList)), QualK, .KList, instanceCT) :: bool)
when
    Id2String(MethodName) ==String "toString"

rule [methodInvokeRuntime-String-toString]:
    methodInvokeRuntime(rtString, sig(MethodName:Id, _), ThisStr:String::_, _,_ )::_
    => ThisStr
when Id2String(MethodName) ==String "toString"

//@String.compareTo(Object)
rule [elab-String-compareTo]:
    lookupMethod( rtString, MethodName:Id,
      _, noValue, false, QualK:K, ParamExp:TypedExp
    ) => elabRes(methodInvokeRuntime(rtString, sig(MethodName, types(.KList)), QualK, ParamExp, instanceCT) :: bool)
when
    Id2String(MethodName) ==String "compareTo"

rule [methodInvokeRuntime-String-compareTo]:
    methodInvokeRuntime(rtString, sig(MethodName:Id, _), ThisStr:String::_, ParamStr:String::_ ,_ )::_
    => 'If(ThisStr <String ParamStr,, -1,, 'If(ThisStr ==String ParamStr,, 0,, 1))
when Id2String(MethodName) ==String "compareTo"

//@\subsection{Array clone}

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

//@Construct to copy content of an array to another after copy, the term is rewritten into the destination array.
syntax K ::=  "arrayCopy" "("
                              TypedVal "," // source array
                              K            // destination array, computes to TypedVal
              ")"
        [strict(2)]

rule arrayCopy(arrayRef(T:Type, L1:Int, Len:Int)::_, arrayRef(T, L2:Int, Len)::_)
    => storeCopy(L1, L2, Len) ~> arrayRef(T,L2:Int,Len)::T

//@Copy a sequence of store values from one place to another.
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

//@\subsection{Class literal - <Class>.class}

//@We need to synchronize access to class literals to avoid instantiation of the came .class by multiple threads. This is done by the term temp in <classLiteralsMap>. We cannot use 'Synchronized because it required an objectClousre as argument, and we might not have any objects instantiated at the moment.
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

//@ Wraps a newly created java.lang.Class object
syntax K ::= "saveClassLiteral" "(" Type  // The type for this class literal is being instantiated
                                "," K     // The class literal instantiation expression
                                ")"         [strict(2)]

rule [saveClassLiteral]:
    <k> saveClassLiteral(T:Type, TV:TypedVal) => . ...</k>
    <classLiteralsMap>... T |-> (temp => TV) ...</classLiteralsMap>

rule [ClassLiteral]:
    <k> 'Lit('Class(T:Type))::_ => TV ...</k>
    <classLiteralsMap>... T |-> TV:TypedVal ...</classLiteralsMap>

//@Used inside <classLiteralsMap> only for synchronization purposes
syntax K ::= "temp"

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
    <namesToClasses>... _ |-> mapWrap(SimpleName:Id |-> class ClassId _:Map) ...</namesToClasses>

endmodule
