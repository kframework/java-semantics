module JAVA-API-CORE
    imports JAVA-CORE
    imports JAVA-CLASSES
    imports JAVA-METHOD-INVOKE

// This module contains the minimal part of java API required to perform
// console read/write operations.

syntax KResult ::=  "rtSystem"
                  | "rtSystemOut"
                  | "rtSystemOutPrint"
                  | "rtSystemOutPrintln"
                  | "rtSystemConsole"
                  | "rtSystemConsoleReadLine"
                  | "rtInteger"
                  | "rtIntegerParseInt"
                  | "rtSystemIn"
                  | "rtScannerNextInt"
                  | "methodGetClass" "(" K ")"
                  | "methodHashCode" "(" K ")"
                  | "classObject" "(" K ")"         //KResult
                  | "methodClassGetName" "(" K ")"
                  | "methodArrayClone" "(" K ")"

syntax RawVal ::= "rtSymbolicConsoleLine"
                | "rtScanner"

rule [NameSystem]:
    'ExprName(X:Id) => rtSystem
when
    Id2String(X) ==String "System"

rule [NameSystemConsole]:
    methodNameImpl(rtSystem, X:Id, _) => rtSystemConsole
when
    Id2String(X) ==String "console"

rule [InvokeSystemConsole]:
    'Invoke(rtSystemConsole,, 'ListWrap(.List{K})) => rtSystemConsole

rule [NameSystemConsoleReadLine]:
    methodNameImpl(rtSystemConsole, X:Id, _) => rtSystemConsoleReadLine
when
    Id2String(X) ==String "readLine"

rule [InvokeSystemConsoleReadLine]:
    'Invoke(rtSystemConsoleReadLine,, 'ListWrap(.List{K}))
    => rtSymbolicConsoleLine :: rtString

rule [NameInteger]:
    'ExprName(X:Id) => rtInteger
when
    Id2String(X) ==String "Integer"

rule [NameIntegerParseInt]:
    methodNameImpl(rtInteger, X:Id, _) => rtIntegerParseInt
when
    Id2String(X) ==String "parseInt"

rule [consoleReadInt]:
    <k>
      'Invoke(rtIntegerParseInt,, 'ListWrap(rtSymbolicConsoleLine :: rtString))
      => I:Int :: int
      ...
    </k>
    <in> ListItem(I) => . ...</in>

//@ For integers and strings, print their value. For classes, print class type.

rule [NameSystemOut]:
    'ExprName(rtSystem,, X:Id) => rtSystemOut
when
    Id2String(X) ==String "out"

rule [NameSystemOutPrint]:
    methodNameImpl(rtSystemOut, X:Id, _) => rtSystemOutPrint
when
    Id2String(X) ==String "print"

rule [NameSystemOutPrintln]:
    methodNameImpl(rtSystemOut, X:Id, _) => rtSystemOutPrintln
when
    Id2String(X) ==String "println"

rule [printlnDesugar]:
    'Invoke(rtSystemOutPrintln,, 'ListWrap(KR:KResult))
    => 'Invoke(rtSystemOutPrint,, 'ListWrap('Plus(KR:KResult,,"\n"::rtString)))

rule [printlnEmptyDesugar]:
    'Invoke(rtSystemOutPrintln,, 'ListWrap(.List{K}))
    => 'Invoke(rtSystemOutPrint,, 'ListWrap("\n"::rtString))

rule [consolePrintArgConvert]:
    'Invoke(rtSystemOutPrint,, 'ListWrap(KR:KResult => toString(KR)))
when
           (typeOf(KR) =/=K rtString)
    orBool (KR ==K (null::rtString))

rule [consolePrint]:
    <k>
      'Invoke(rtSystemOutPrint,, 'ListWrap(Str:String :: rtString))
      => nothing::void
      ...
    </k>
    <out>... .=> ListItem(Str) </out>

rule [NameSystemIn]:
    'ExprName(rtSystem,, X:Id) => rtSystemIn
when
    Id2String(X) ==String "in"

rule [NewInstanceScanner]:
    'NewInstance('None(.List{K}),,
      class X:Id,,
      'ListWrap(rtSystemIn),,
      'None(.List{K})
    )
    => rtScanner :: class X
when
    Id2String(X) ==String "Scanner"

rule [ScannerNextInt]:
    methodNameImpl(rtScanner::_, X:Id, _) => rtScannerNextInt
when
    Id2String(X) ==String "nextInt"

rule [InvokeScannerNextInt]:
    <k>
      'Invoke(rtScannerNextInt,, 'ListWrap(.List{K}))
      => I:Int :: int
      ...
    </k>
    <in> ListItem(I) => . ...</in>

rule [NameGetClass]:
    methodNameImpl(KR:KResult, X:Id, _) => methodGetClass(KR)
when
    Id2String(X) ==String "getClass"

rule [InvokeGetClass]:
    'Invoke(
      methodGetClass(KR:KResult),,
      'ListWrap(.List{K})
    ) => classObject(KR)

rule [NameClassGetName]:
    methodNameImpl(classObject(KR:KResult), X:Id, _) => methodClassGetName(KR)
when
    Id2String(X) ==String "getName"

rule [InvokeClassGetNameObject]:
    'Invoke(
      methodClassGetName(objectClosure(_, _ <envStack>ListItem((Class:ClassType, _))...</envStack>)::_),,
      'ListWrap(.List{K})
    ) => fullyQualifiedClassName(Class)

rule [InvokeClassGetNameString]:
    'Invoke(
      methodClassGetName(Str:String::_),,
      'ListWrap(.List{K})
    ) => toString(rtString)

rule [InvokeClassGetNameArray]:
    'Invoke(
      methodClassGetName(arrayRef(T:Type,_,_)::_),,
      'ListWrap(.List{K})
    ) => toString(T)

rule toString(Class:ClassType) => fullyQualifiedClassName(Class) [anywhere]

//todo this function will be obsolete once Class itself will be fully qualified
syntax K ::= "fullyQualifiedClassName" "(" ClassType ")"

rule [ClassNamePackage]:
    <k>
      fullyQualifiedClassName(Class:ClassType)
      => (PackStr +String "." +String Id2String(SimpleName)) :: rtString
      ...
    </k>
    <classType> Class </classType>
    <package> packageId(PackStr:String) </package>
    <classSimpleName> SimpleName:Id </classSimpleName>
when
    PackStr =/=String ""

rule [ClassNameClass]:
    <k>
      fullyQualifiedClassName(Class:ClassType) => Id2String(SimpleName) :: rtString
      ...
    </k>
    <classType> Class </classType>
    <package> packageId("") </package>
    <classSimpleName> SimpleName:Id </classSimpleName>

rule [NameHashCode]:
    methodNameImpl(KR:KResult, X:Id, _) => methodHashCode(KR)
when
    Id2String(X) ==String "hashCode"

//hashCode will always return 0 for now
rule [InvokeHashCode]:
    'Invoke(
      methodHashCode(
        objectClosure(I:Int, _ <envStack>ListItem((Class:ClassType, _))...</envStack>)::_
      ),,
      'ListWrap(.List{K})
    ) => I :: int

rule [NameArrayClone]:
    methodNameImpl(arrayRef(T:Type, L1:Int, Len:Int)::CompileT:Type, X:Id, _)
    => methodArrayClone(arrayRef(T,L1,Len)::CompileT)
when
    Id2String(X) ==String "clone"

//hashCode will always return 0 for now
rule [InvokeArrayClone]:
    'Invoke(
      methodArrayClone(
        arrayRef(arrayOf ElemT:Type, Loc:Int, Len:Int)::CompileT:Type
      ),,
      'ListWrap(.List{K})
    )
    => arrayCopy(
      arrayRef(arrayOf ElemT:Type, Loc:Int, Len:Int)::CompileT,
      newArrayAlloc(ElemT, 'ListWrap(Len::int), undefined :: ElemT)
    )

//construct to copy content of an array to another
//after copy, the term is rewritten into the destination array
syntax K ::=  "arrayCopy" "("
                              TypedVal "," // source array
                              K            // destination array
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
