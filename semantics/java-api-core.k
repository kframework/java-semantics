require "java-core.k"
require "java-classes.k"
require "java-method-invoke.k"

module JAVA-API-CORE
    imports JAVA-CORE
    imports JAVA-CLASSES
    imports JAVA-METHOD-INVOKE
    imports JAVA-VAR-LOOKUP

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
    <k>
      invokeImpl(
        methodClosure(_,_,_,_,_,_, 'NoMethodBody(_))::methodType(sig(MethodName:Id, _),_), _,
        'ListWrap(.KList)
      ) => I :: int
      ...
    </k>
    <in> ListItem(I:Int) => . ...</in>
when
    Id2String(MethodName) ==String "nextInt"

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
      OL |-> objectClosure(_, <envStack>ListItem((T:ClassType, _)) _</envStack> _) :: _
      ...
    </store>
when
    Id2String(MethodName) ==String "getClass"

rule [object-getClass-on-String]:
    invokeImpl(
      methodClosure(_,_,_,_,_,_, 'NoMethodBody(_))::methodType(sig(MethodName:Id, _),_), Str::rtString,
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
      methodClosure(_,_,_,_,_,_, 'NoMethodBody(_))::methodType(sig(MethodName:Id, _),_), Str::rtString,
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
      OL |-> objectClosure(NewOL:Int, _) :: _
      ...
    </store>
when
    Id2String(MethodName) ==String "hashCode"

//\subsection{Array clone}

rule [elab-array-clone]:
    lookupMethod( arrayOf T:Type, MethodName:Id,
      _, noValue, true, QualTE:TypedExp, .KList
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
    <classLiteralsMap> CLMap:Map </classLiteralsMap>
when notBool T in keys(CLMap)

// wraps a newly created java.lang.Class object
syntax K ::= "saveClassLiteral" "(" Type  // The type for this class literal is being instantiated
                                "," K     // The class literal instantiation expression
                                ")"         [strict(2)]

rule [saveClassLiteral]:
    <k> saveClassLiteral(T:Type, TV:TypedVal) => . ...</k>
    <classLiteralsMap> CLMap:Map => CLMap[TV/T] </classLiteralsMap>

rule [ClassLiteral]:
    <k> 'Lit('Class(T:Type))::_ => TV ...</k>
    <classLiteralsMap>... T |-> TV:TypedVal ...</classLiteralsMap>

rule [ClassNameTopLevelWithPackage]:
    <k>
      toString(class ClassId:Id)
      => Id2String(ClassId)
      ...
    </k>
    <classType> class ClassId </classType>
    <enclosingClass> noClass </enclosingClass>
when substrString(Id2String(ClassId), 0, 1) =/=String "."

rule [ClassNameTopLevelWithDefaultPackage]:
    <k>
      toString(class ClassId:Id)
      => substrString(Id2String(ClassId), 1, lengthString(Id2String(ClassId)) -Int 1)
      ...
    </k>
    <classType> class ClassId </classType>
    <enclosingClass> noClass </enclosingClass>
when substrString(Id2String(ClassId), 0, 1) ==String "."

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
