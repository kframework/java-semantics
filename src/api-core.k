require "core-sorts.k"
require "classes.k"
require "method-invoke.k"

//@ \section{Module API-CORE}
/*@ All the methods defined in this module through invokeImpl are native, their body is 'NoMethodBody(_), thus
  they cannot be matched by rules in METHOD-INVOKE.
*/

module API-CORE
    imports CORE-SORTS
    imports CLASSES
    imports METHOD-INVOKE //for invokeImpl, arrayImplClass
    imports VAR-LOOKUP
    imports LITERALS      //for string-related functions

/*@ This module contains the minimal part of java API required to perform console read/write operations, as well as a few other API functions mentioned in JLS.*/

//@system-out-print-convert heat argument
context
    invokeImpl(
      methodRef(sig(MethodName:Id, _), Class:ClassType), _,
      [HOLE]
    )
when
    Class ==K class String2Id("java.io.PrintWriter") andBool Id2String(MethodName) ==String "print"

//@ System.out.print(). For integers and strings, print their value. For classes, print class type.

rule [system-out-print-string]:
    <k>
      invokeImpl(
        methodRef(sig(MethodName:Id, _), Class:ClassType), _,
        [Str:String :: _]
      ) => nothing::void
      ...
    </k>
    <out>... . => ListItem(Str) </out>
when
    Class ==K class String2Id("java.io.PrintWriter") andBool Id2String(MethodName) ==String "print"

  //With [transition-threading], the time to produce 2 solutions for the test threads_11_two_th_msg is 14s.
  //But with [transition-strictness], the same test takes 3m52s, with java heap = 16GB.
        [transition-threading]

//@Is only used for primitive type arguments. Object arguments are converted by java code inside the class PrintWriter.
rule [system-out-print-convert]:
    invokeImpl(
      methodRef(sig(MethodName:Id, _), Class:ClassType), _,
      [RV:RawVal :: T:Type => toString(RV::T)]
    )
when
            Class ==K class String2Id("java.io.PrintWriter")
    andBool (Id2String(MethodName) ==String "print")
    andBool notBool (isString(RV) ==K true)

/*@Scanner.nextInt(), used to read from the console.*/
rule [scanner-nextInt]:
    invokeImpl(
      methodRef(sig(MethodName:Id, _), Class:ClassType), _,
      [.KList]
    ) => readInt
when
    Class ==K class String2Id("java.util.Scanner") andBool Id2String(MethodName) ==String "nextInt"

rule [scanner-nextLine]:
    invokeImpl(
      methodRef(sig(MethodName:Id, _), Class:ClassType), _,
      [.KList]
    ) => readString
when
    Class ==K class String2Id("java.util.Scanner") andBool Id2String(MethodName) ==String "nextLine"

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
        methodRef(sig(MethodName:Id, _), Class:ClassType), loc(OL:Int)::_,
        [.KList]
      ) => 'Lit('Class(BottomClass))
      ...
    </k>
    <store>
      ...
      OL |-> objectRef(OId:Int, _) :: _
      ...
    </store>
    <objectId> OId </objectId>
    <objectType> BottomClass:ClassType </objectType>
when
    Class ==K objectClass andBool Id2String(MethodName) ==String "getClass"

rule [object-getClass-on-String]:
    invokeImpl(
      methodRef(sig(MethodName:Id, _), Class:ClassType), Str:String::_,
      [.KList]
    ) => 'Lit('Class(stringClass))
when
    Class ==K objectClass andBool Id2String(MethodName) ==String "getClass"

rule [object-getClass-on-array]:
    invokeImpl(
      methodRef(sig(MethodName:Id, _), Class:ClassType), arrayRef(ArrT:Type,_,_)::_,
      [.KList]
    ) => 'Lit('Class(ArrT))
when
    Class ==K objectClass andBool Id2String(MethodName) ==String "getClass"

/*@ String.toString(). For Object.toString() the implementation is in the library java code.*/
rule [object-toString-on-String]:
    invokeImpl(
      methodRef(sig(MethodName:Id, _), Class:ClassType), Str:String::_,
      [.KList]
    ) => Str::stringClass
when
    Class ==K objectClass andBool Id2String(MethodName) ==String "toString"

/*@Object.hashCode(). Returns the canonical memory location of the objectClosure. */
rule [object-hashCode]:
    <k>
      invokeImpl(
        methodRef(sig(MethodName:Id, _), Class:ClassType), loc(OL:Int)::_,
        [.KList]
      ) => OId :: int
      ...
    </k>
    <store>
      ...
      OL |-> objectRef(OId:Int, _) :: _
      ...
    </store>
when
    Class ==K objectClass andBool Id2String(MethodName) ==String "hashCode"

//@\subsection{String methods}

//@ int String.length()
rule [String-length]:
    invokeImpl(
      methodRef(sig(MethodName:Id, _), Class:ClassType),
      Str:String::Class,
      [.KList]
    )
    => lengthString(Str)
when
    Class ==K stringClass andBool Id2String(MethodName) ==String "length"

rule [String-charAt]:
    invokeImpl(
      methodRef(sig(MethodName:Id, _), Class:ClassType),
      Str:String::Class,
      [I:Int :: int]
    )
    => ordChar(substrString(Str, I, I +Int 1)) :: char
when
    Class ==K stringClass andBool Id2String(MethodName) ==String "charAt"

//@static native String String.valueOf(int i);
rule [String-valueOf]:
    invokeImpl(
      methodRef(sig(MethodName:Id, _), Class:ClassType),
      Str:String::Class,
      [I:Int :: int]
    )
    => Int2String(I)
when
    Class ==K stringClass andBool Id2String(MethodName) ==String "valueOf"

//@boolean String.equals(Object)
rule [String-equals]:
    invokeImpl(
      methodRef(sig(MethodName:Id, _), Class:ClassType),
      Str:String::Class,
      [ParamStr:String::_]
    )
    => 'Eq(Str,, ParamStr)
when
    Class ==K stringClass andBool Id2String(MethodName) ==String "equals"

//@String.toString()
rule [String-toString]:
    invokeImpl(
      methodRef(sig(MethodName:Id, _), Class:ClassType),
      Str:String::Class,
      [.KList]
    )
    => Str
when
    Class ==K stringClass andBool Id2String(MethodName) ==String "toString"

//@ int String.compareTo(Object another)
rule [String-compareTo]:
    invokeImpl(
      methodRef(sig(MethodName:Id, _), Class:ClassType),
      Str:String::Class,
      [ParamStr:String::_]
    )
    => 'If(Str <String ParamStr,, -1,, 'If(Str ==String ParamStr,, 0,, 1))
when
    Class ==K stringClass andBool Id2String(MethodName) ==String "compareTo"

//@\subsection{Array clone}

rule [array-clone]:
    invokeImpl(
      methodRef(sig(MethodName:Id, _), Class:ClassType),
      arrayRef(arrayOf ElemT, Loc:Int, Len:Int)::CompileT:RefType,
      [.KList]
    )
    => arrayCopy(
        arrayRef(arrayOf ElemT:Type, Loc:Int, Len:Int)::CompileT,
        allocAndInitArray(ElemT, [Len::int], undefined :: ElemT)
      )
when
    Class ==K arrayImplClass andBool Id2String(MethodName) ==String "clone"

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
                [toString(T)],,
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
