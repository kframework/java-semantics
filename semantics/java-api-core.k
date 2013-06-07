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

rule [system-out-print-argConvert]:
    invokeImpl(
      methodClosure(_,_,_, 'NoMethodBody(_)) :: _,_,
      'ListWrap(KR:KResult => toString(KR)), sig(MethodName:Id, _)
    )
when
            (Id2String(MethodName) ==String "print")
    andBool (       (typeOf(KR) =/=K rtString)
             orBool (KR ==K (null::rtString)))

rule [system-out-print]:
    <k>
      invokeImpl(
        methodClosure(_,_,_, 'NoMethodBody(_))::_, _,
        'ListWrap(Str:String :: rtString), sig(MethodName:Id, _)
      ) => nothing::void
      ...
    </k>
    <out>... . => ListItem(Str) </out>
when
    Id2String(MethodName) ==String "print"

rule [scanner-nextInt]:
    <k>
      invokeImpl(
        methodClosure(_,_,_, 'NoMethodBody(_))::_, _,
        'ListWrap(.List{K}), sig(MethodName:Id, _)
      ) => I :: int
      ...
    </k>
    <in> ListItem(I:Int) => . ...</in>
when
    Id2String(MethodName) ==String "nextInt"

rule [object-getClass-on-object]:
    <k>
      invokeImpl(
        methodClosure(_,_,_, 'NoMethodBody(_))::_, OL:Int,
        'ListWrap(.List{K}), sig(MethodName:Id, _)
      ) => 'Lit('Class(T)) :: class String2Id("java.lang.Class")
      ...
    </k>
    <store>
      ...
      OL |-> objectClosure(_, <envStack>ListItem((T:ClassType, _)) _</envStack>) :: _
      ...
    </store>
when
    Id2String(MethodName) ==String "getClass"

rule [object-getClass-on-String]:
    invokeImpl(
      methodClosure(_,_,_, 'NoMethodBody(_))::_, rtString,
      'ListWrap(.List{K}), sig(MethodName:Id, _)
    ) => 'Lit('Class(rtString)) :: class String2Id("java.lang.Class")
when
    Id2String(MethodName) ==String "getClass"

rule [object-getClass-on-array]:
    invokeImpl(
      methodClosure(_,_,_, 'NoMethodBody(_))::_, arrayOf T:Type,
      'ListWrap(.List{K}), sig(MethodName:Id, _)
    ) => 'Lit('Class(arrayOf T)) :: class String2Id("java.lang.Class")
when
    Id2String(MethodName) ==String "getClass"

//hashCode will always return 0 for now
rule [object-hashCode]:
    <k>
      invokeImpl(
        methodClosure(_,_,_, 'NoMethodBody(_))::_, OL:Int,
        'ListWrap(.List{K}), sig(MethodName:Id, _)
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

rule [elab-array-clone]:
    lookupMethod( arrayOf T:Type, MethodName:Id,
      _, noValue, true, QualTE:TypedExp, .List{K}
    ) => elabRes(methodInvokeRuntime(arrayOf T:Type, sig(MethodName, types(.List{K})), QualTE, .List{K}) :: objectClass)
when
    Id2String(MethodName) ==String "clone"

rule [methodInvokeRuntime-array-clone]:
    methodInvokeRuntime(_, sig(MethodName:Id, _),
        arrayRef(arrayOf ElemT:Type, Loc:Int, Len:Int)::CompileT:Type, _
    )::_
    => arrayCopy(
        arrayRef(arrayOf ElemT:Type, Loc:Int, Len:Int)::CompileT,
        newArrayAlloc(ElemT, 'ListWrap(Len::int), undefined :: ElemT)
      )
when Id2String(MethodName) ==String "clone"

rule toString(Class:ClassType) => fullyQualifiedClassName(Class) [anywhere]

//todo this function will be obsolete once Class itself will be fully qualified
syntax K ::= "fullyQualifiedClassName" "(" ClassType ")"

rule [ClassNameTopLevelWithPackage]:
    <k>
      fullyQualifiedClassName(class ClassId:Id)
      => Id2String(ClassId) :: rtString
      ...
    </k>
    <classType> class ClassId </classType>
    <enclosingClass> noClass </enclosingClass>
when substrString(Id2String(ClassId), 0, 1) =/=String "."

rule [ClassNameTopLevelWithDefaultPackage]:
    <k>
      fullyQualifiedClassName(class ClassId:Id)
      => substrString(Id2String(ClassId), 1, lengthString(Id2String(ClassId)) -Int 1) :: rtString
      ...
    </k>
    <classType> class ClassId </classType>
    <enclosingClass> noClass </enclosingClass>
when substrString(Id2String(ClassId), 0, 1) ==String "."

rule [ClassNameInner]:
    <k>
      fullyQualifiedClassName(class ClassId:Id)
      => 'Plus(
            fullyQualifiedClassName(class OuterClassId),,
            ("$" +String Id2String(SimpleName))::rtString
         ) :: rtString
      ...
    </k>
    <classType> class ClassId </classType>
    <enclosingClass> class OuterClassId:Id </enclosingClass>
    <typeNamesMap>... _ |-> mapWrap(SimpleName:Id |-> class ClassId _:Map) ...</typeNamesMap>

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

endmodule
