infixr 2 |||, &&&


(|||) :: (Bool,a) -> (Bool,a) -> (Bool,a)
x@(True,_) ||| _          = x
_          ||| x@(True,_) = x
x ||| _                   = x

(&&&) :: (Bool,a) -> (Bool,a) -> (Bool,a)
(True,_) &&& x = x
x &&& _        = x


anyS :: Expr2List c => (a -> (Bool,String)) -> c a -> (Bool,String)
anyS p = foldr (|||) (False,"") . map p . expr2list

allS :: Expr2List c => (a -> (Bool,String)) -> c a -> (Bool,String)
allS p = foldr (&&&) (True,"") . map p . expr2list

tjBoolean, tjInt, tjString, tjArray, tjClass,tjObject :: JavaType
tjBoolean= TJBoolean
tjInt    = TJInt
tjString = TJRef(string)
tjArray  = TJRef(carray)
tjClass  = TJRef(cclass)
tjObject = TJRef(object)

vtString, vtClass, vtObject, vtInt, vtFloat :: [VerifyType]
vtByte, vtShort, vtChar  :: [VerifyType]
vtLong, vtDouble, vtAddr :: [VerifyType]
vtString     = typeTJVT(tjString)
vtClass      = typeTJVT(tjClass)
vtObject     = typeTJVT(tjObject)
vtInt        = [VTInt]
vtFloat      = [VTFloat]
vtLong       = [VTLowLong,VTHighLong]
vtDouble     = [VTLowDouble, VTHighDouble]
vtAddr       = [VTReference(VTAddr)]
vtByte       = [VTInt]
vtShort      = [VTInt]
vtChar       = [VTInt]

w2Double, w2Int, w2Float, w2Long, w2Reference :: ValType
w2Double    = [WTLowDouble, WTHighDouble]
w2Int       = [WTInt]
w2Float     = [WTFloat]
w2Long      = [WTLowLong,WTHighLong]
w2Reference = [WTReference]

sysLd :: Ld
sysLd = 1

object               = (sysLd, "java/lang/Object")
classLoader          = (sysLd, "java/lang/ClassLoader")
cloneable            = (sysLd, "java/lang/Cloneable")
cclass               = (sysLd, "java/lang/Class")
cerror               = (sysLd, "java/lang/Error")
string               = (sysLd, "java/lang/String")
carray               = (sysLd, "java/lang/Array")
printStream          = (sysLd, "java/io/PrintStream")
stringBuffer         = (sysLd, "java/lang/StringBuffer")
throwable            = (sysLd, "java/lang/Throwable")
arithmeticException  = (sysLd, "java/lang/ArithmeticException")
nullPointerException = (sysLd, "java/lang/NullPointerException")
classCastException   = (sysLd, "java/lang/ClassCastException")
negativeArraySizeException = (sysLd, "java/lang/NegativeArraySizeException")
arrayIndexException  = (sysLd, "java/lang/ArrayIndexOutOfBoundsException")
arrayStoreException  = (sysLd, "java/lang/ArrayStoreException")
abstractMethodError  = (sysLd, "java/lang/AbstractMethodError")
fileInputStream      = (sysLd, "java/io/FileInputStream")

findLoadedClass, findSystemClass, resolveClass, defineClassMethod :: MSig
getSystemClassLoader, fileInputRead :: MSig
findLoadedClass = ("findLoadedClass",[tjString])
findSystemClass = ("findSystemClass", [tjString])
resolveClass    = ("resolveClass", [tjClass])
defineClassMethod  = ("defineClass", [tjString, TJArray(TJByte), tjInt, tjInt])
getSystemClassLoader = ("getSystemClassLoader",[])
fileInputRead   = ("readFile",[TJArray(TJByte)])

printLn, printI, printStr, appendStr, stringConcat, stringStartsWith :: MSig
valueOfI, valueOfObject, stringLength, equals, toString :: MSig
printLn     = ("println", [])
printI      = ("print",   [tjInt])
printStr    = ("print",   [tjString])
appendStr   = ("nappend", [tjString, tjString])
valueOfI    = ("valueOf", [tjInt])
equals      = ("equals",  [tjObject])
toString    = ("toString",[]) 
clone       = ("clone",[])
valueOfObject = ("valueOf",[tjObject])
stringLength     = ("length",[])
stringConcat     = ("concat",[tjString])
stringStartsWith = ("startsWith",[tjString])

cload :: MRef
cload = (classLoader :/ ("<cload>",[tjString]))


isReturn :: Instr -> Bool
isReturn(Return(_)) = True
isReturn(_)         = False

notIsNew :: VerifyType -> Bool
notIsNew (VTNew(_,_)) = False
notIsNew (_)          = True

