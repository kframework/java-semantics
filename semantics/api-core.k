require "core-sorts.k"
require "classes.k"
require "method-invoke.k"

//@ \section{Module API-CORE}

module API-CORE
    imports CORE-SORTS
    imports CLASSES
    imports METHOD-INVOKE //for invokeImpl, arrayImplClass
    imports VAR-LOOKUP
    imports LITERALS      //for string-related functions

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
syntax K ::=  "readInt"
            | "readString"

rule [readInt]:
    <k> readInt => I :: int ...</k>
    <in> ListItem(I:Int) => . ...</in>

rule [readString]:
    <k> readString => Str :: stringClass ...</k>
    <in> ListItem(Str:String) => . ...</in>

syntax KLabel ::= "'Class"        // X.class : the class literal

/*@ object.getClass()*/
rule [object-getClass-on-object]:
    <k>
      invokeImpl(
        methodClosure(_,_,_,_,_,_, 'NoMethodBody(_))::methodType(sig(MethodName:Id, _),_), loc(OL:Int)::_,
        'ListWrap(.KList)
      ) => 'Lit('Class(T))
      ...
    </k>
    <store>
      ...
      OL |-> objectClosure(_, (layer(T:ClassType, _,_),, _:KList/*ObjLayers*/) ) :: _
      ...
    </store>
when
    Id2String(MethodName) ==String "getClass"

rule [object-getClass-on-String]:
    invokeImpl(
      methodClosure(_,_,_,_,_,_, 'NoMethodBody(_))::methodType(sig(MethodName:Id, _),_), Str:String::_,
      'ListWrap(.KList)
    ) => 'Lit('Class(stringClass))
when
    Id2String(MethodName) ==String "getClass"

rule [object-getClass-on-array]:
    invokeImpl(
      methodClosure(_,_,_,_,_,_, 'NoMethodBody(_))::methodType(sig(MethodName:Id, _),_), arrayRef(ArrT:Type,_,_)::_,
      'ListWrap(.KList)
    ) => 'Lit('Class(ArrT))
when
    Id2String(MethodName) ==String "getClass"

/*@ String.toString(). For Object.toString() the implementation is in the library java code.*/
rule [object-toString-on-String]:
    invokeImpl(
      methodClosure(_,_,_,_,_,_, 'NoMethodBody(_))::methodType(sig(MethodName:Id, _),_), Str:String::Class:ClassType,
      'ListWrap(.KList)
    ) => Str::stringClass
when
    Id2String(MethodName) ==String "toString"
    andBool Class ==K stringClass

/*@Object.hashCode(). Returns the canonical memory location of the objectClosure. */
rule [object-hashCode]:
    <k>
      invokeImpl(
        methodClosure(_,_,_,_,_,_, 'NoMethodBody(_))::methodType(sig(MethodName:Id, _),_), loc(OL:Int)::_,
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

//@\subsection{String methods}

//@ int String.length()
rule [String-length]:
    invokeImpl(
      methodClosure(Class:ClassType, 'ListWrap(.KList), instanceCT, _,methodRT, noValue, _)
          :: methodType(sig(MethodName:Id, _), _),
      Str:String::Class,
      'ListWrap(.KList)
    )
    => lengthString(Str)
when Id2String(MethodName) ==String "length"
     andBool Class ==K stringClass

rule [String-charAt]:
    invokeImpl(
      methodClosure(Class:ClassType, _, instanceCT, _,methodRT, noValue, _)
          :: methodType(sig(MethodName:Id, _), _),
      Str:String::Class,
      'ListWrap(I:Int :: int)
    )
    => ordChar(substrString(Str, I, I +Int 1)) :: char
when Id2String(MethodName) ==String "charAt"
     andBool Class ==K stringClass

//@static native String String.valueOf(int i);
rule [String-valueOf]:
    invokeImpl(
      methodClosure(Class:ClassType, _, instanceCT, _,methodRT, noValue, _)
          :: methodType(sig(MethodName:Id, _), _),
      Str:String::Class,
      'ListWrap(I:Int :: int)
    )
    => Int2String(I)
when Id2String(MethodName) ==String "valueOf"
     andBool Class ==K stringClass

//@boolean String.equals(Object)
rule [String-equals]:
    invokeImpl(
      methodClosure(Class:ClassType, _, instanceCT, _,methodRT, noValue, _)
          :: methodType(sig(MethodName:Id, _), _),
      Str:String::Class,
      'ListWrap(ParamStr:String::_)
    )
    => 'Eq(Str,, ParamStr)
when Id2String(MethodName) ==String "equals"
     andBool Class ==K stringClass

//@String.toString()
rule [String-toString]:
    invokeImpl(
      methodClosure(Class:ClassType, _, instanceCT, _,methodRT, noValue, _)
          :: methodType(sig(MethodName:Id, _), _),
      Str:String::Class,
      'ListWrap(.KList)
    )
    => Str
when Id2String(MethodName) ==String "toString"
     andBool Class ==K stringClass

//@ int String.compareTo(Object another)
rule [String-compareTo]:
    invokeImpl(
      methodClosure(Class:ClassType, _, instanceCT, _,methodRT, noValue, _)
          :: methodType(sig(MethodName:Id, _), _),
      Str:String::Class,
      'ListWrap(ParamStr:String::_)
    )
    => 'If(Str <String ParamStr,, -1,, 'If(Str ==String ParamStr,, 0,, 1))
when Id2String(MethodName) ==String "compareTo"
     andBool Class ==K stringClass

//@\subsection{Array clone}

rule [array-clone]:
    invokeImpl(
      methodClosure(TargetClass:ClassType, _, instanceCT, _,methodRT, noValue, _)
          :: methodType(sig(MethodName:Id, _), _),
      arrayRef(arrayOf ElemT, Loc:Int, Len:Int)::CompileT:RefType,
      'ListWrap(.KList)
    )
    => arrayCopy(
        arrayRef(arrayOf ElemT:Type, Loc:Int, Len:Int)::CompileT,
        allocAndInitArray(ElemT, 'ListWrap(Len::int), undefined :: ElemT)
      )
when
    Id2String(MethodName) ==String "clone"
    andBool TargetClass ==K arrayImplClass

//@ Construct to copy content of an array to another after copy, the term is rewritten into the destination array.
syntax K ::=  arrayCopy (
                TypedVal, // source array
                K         // destination array, computes to TypedVal
              )
              [strict(2)]

rule arrayCopy(arrayRef(T:Type, L1:Int, Len:Int)::_, arrayRef(T, L2:Int, Len)::_)
    => storeCopy(L1, L2, Len) ~> arrayRef(T,L2:Int,Len)

//@Copy a sequence of store values from one place to another.
syntax K ::=  storeCopy (
                Int, //source address in store
                Int, //destination address in store
                Int  //amount of elements to copy
              )

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

rule [storeCopy-discard]:
    storeCopy(_, _, 0) => .

//@\subsection{Class literal - <Class>.class}

/*@ We need to synchronize access to class literals to avoid instantiation of the came .class by multiple threads.
  This is done by the term temp in <classLiteralsMap>. We cannot use 'Synchronized because it required an
  objectClousre as argument, and we might not have any objects instantiated at the moment.
*/
rule [Lit-Class-Instantiate]:
    <k>
        (. => saveClassLiteral(T,
          'NewInstance(
                'None(.KList),,
                class String2Id("java.lang.Class"),,
                'ListWrap(toString(T)),,
                'None(.KList)
          ))
        )
        ~> 'Lit('Class(T:Type))
      ...
    </k>
    <classLiteralsMap> CLMap:Map (. => T |-> temp) </classLiteralsMap>
when notBool T in keys(CLMap)
        [transition-threading]

//@ Wraps a newly created java.lang.Class object
syntax K ::=  saveClassLiteral (
                Type, // The type for this class literal is being instantiated
                K     // The class literal instantiation expression
              )
              [strict(2)]

rule [saveClassLiteral]:
    <k> saveClassLiteral(T:Type, TV:TypedVal) => . ...</k>
    <classLiteralsMap>... T |-> (temp => TV) ...</classLiteralsMap>

rule [Lit-Class]:
    <k> 'Lit('Class(T:Type)) => TV ...</k>
    <classLiteralsMap>... T |-> TV:TypedVal ...</classLiteralsMap>

//@Used inside <classLiteralsMap> only for synchronization purposes
syntax K ::=  "temp"

endmodule
