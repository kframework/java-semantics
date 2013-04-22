-- =====================================================================
-- AN ASM FOR JAVA
-- Part I: javaData.gs
-- 9/10/99 3:09PM


-- --------------------------------------------------------------------
-- Types and Values



isPrimType t = t `elem` [TJInt, TJBoolean, TJShort, TJFloat, TJDouble, 
                         TJChar, TJLong, TJByte, TJVoid ]

lapply :: JavaVal -> JavaVal			-- primitive operation
lapply = id				-- only needed for latex

intVal :: JavaVal -> Int
intVal (TI i) = i
intVal (IS i) = i
intVal (IB i) = i
intVal (IL i) = i
intVal (TC c)  = ord(c)
intVal _      = error "intVal"

boolVal :: JavaVal -> Bool
boolVal(TB b) = b
boolVal _ = error "boolVal"

refVal :: JavaVal -> Ref
refVal (TR r) = r
refVal _     = error "refVal"

intFun :: JavaVal -> (Int -> JavaVal)
intFun (TI  _) = TI
intFun (IS _)  = IS
intFun (IB _)  = IB
intFun (IL _)  = IL

floatVal :: JavaVal -> Float
floatVal (TF f)  = f
floatVal (FD f) = f
floatVal _      = error "floatVal"

floatFun :: JavaVal -> (Float -> JavaVal)
floatFun (TF _)  = TF
floatFun (FD _) = FD


charVal :: JavaVal -> Char
charVal(TC c) = c
charVal _    = error "charVal"


divMod = ["%", "/"]		-- primitive operations that can fail

defaultVal :: JavaType -> JavaVal
defaultVal TJInt        = TI 0			-- default values
defaultVal TJLong       = IL 0			-- default values
defaultVal TJByte       = IB 0			-- default values
defaultVal TJShort      = IS 0			-- default values
defaultVal TJChar       = TC ' '			-- default values
defaultVal TJFloat      = TF 0.0			-- default values
defaultVal TJDouble     = FD 0.0			-- default values
defaultVal TJBoolean    = TB False
defaultVal (TJRef(_))   = TR 0
defaultVal (TJArray(_)) = TR 0
defaultVal x = error ("defaultVal: " ++ primPrint 0 x "")

objectCode :: (TypeDec,Stm) -> TypeDec
objectCode(ClassDec(ms,n,_,ifaces,mdecs),body) =
   ClassDec(ms,n,Nothing,ifaces,
            MethDec([Public,Static],TJVoid, "<entrypoint>",[],body,{},False) :
            [ m | m <- mdecs, methNm(m) /= "<entrypoint>" ])

startMain :: MethRef -> Stm
startMain(mref) = Term (Block,TJVoid) [try, Term (JavaReturn "",TJVoid) []]
  where try = Term (Try,TJVoid)
                       [block(stm(Term (ClassInv mref,TJVoid) [Term(ArgList,TJVoid)[Term (Lit (TR 0),TJNull) []]])),
                        Term (Catch (throwableClass,"x"),TJVoid) [Term (Block,TJVoid) []]
                       ]
        block(t) = Term (Block,TJVoid) [t]
        stm(t)   = Term (ExpStm,TJVoid) [t]

predefined = case parse "predefined.java" of
                Ok(td)   -> td
                Error(s) -> error s

nullPointerException           = "NullPointerException"
arithmeticException            = "ArithmeticException"
classCastException             = "ClassCastException"
indexOutOfBoundsException      = "IndexOutOfBoundsException"
arrayIndexOutOfBoundsException = "ArrayIndexOutOfBoundsException"
arrayStoreException            = "ArrayStoreException"
cloneNotSupportedException     = "CloneNotSupportedException"
illegalThreadStateException    = "IllegalThreadStateException"
illegalMonitorStateException   = "IllegalMonitorStateException"
threadDeath                    = "ThreadDeath"
interruptedException           = "InterruptedException"
exceptionInInitializerError    = "ExceptionInInitializerError"
errorException                 = "Error"
noClassDefFoundErr             = "NoClassDefFoundError"
negativeArraySizeException     = "NegativeArraySizeException"

systemThread = 1

-- --------------------------------------------------------------------
-- Classifiers on Term lists
idx p xs 	= head[i | (i,x) <- zip [0..] xs, p x]

anyIsStm ss     = any isStm ss
fstStmIdx ss    = idx isStm ss

anyIsExp ss     = any isExp ss
fstExpIdx ss  	= idx isExp ss

anyIsAbr ss     = any isAbr ss            
fstAbr ss       = head[s | s <- ss, isAbr s]

allIsVal ss     = all isVal ss
allIsNrm ss    = all isNorm ss

allIsValExp ss  = all (\e -> isVal(e) || isExp(e)) ss &&
                  anyIsExp ss
allIsStmNorm ss = all (\s -> isStm(s) || isNorm(s)) ss &&
                  anyIsStm ss

methods(td) = [m | m <- members(td), isMethod(m)]
fields(td) = [m | m <- members(td), isField(m)]


objectType :: JavaType
objectType = TJRef(objectClass)

throwableType :: JavaType
throwableType = TJRef(throwableClass)

stringType :: JavaType
stringType = TJRef(stringClass)

numeric :: JavaType -> Bool
numeric(t) = integral(t) ||
             t == TJFloat || t == TJDouble

string :: JavaType -> Bool
string(t) = t == TJRef(stringClass)

integral :: JavaType -> Bool
integral(t) = t == TJInt || t == TJShort ||
              t == TJByte || t == TJLong || t == TJChar

refType :: JavaType -> Bool
refType(TJRef(_))   = True
refType(TJNull)     = True
refType(TJArray(_)) = True
refType(_)          = False

boolean :: JavaType -> Bool
boolean(t) = t == TJBoolean

entrypoint :: MethRef
entrypoint  = objectClass :/ ("<entrypoint>", [])



containsUnlabeledJump :: Stm -> Bool
containsUnlabeledJump(Term (Break l,_) [])    = l == ""
containsUnlabeledJump(Term (Continue l,_) []) = l == ""
containsUnlabeledJump(Term (IfStm,_) [c,t,e]) = containsUnlabeledJump(t) ||
                                                containsUnlabeledJump(e)
containsUnlabeledJump(Term op ss)
   | testAll(op) = any containsUnlabeledJump ss
 where testAll (LabStm _,_)   = True
       testAll (Block,_)      = True
       testAll (Catch(_),_)   = True
       testAll (Try,_)        = True
       testAll (Finally _,_)  = True
       testAll (SynBlock,_)   = True
       testAll _              = False
containsUnlabeledJump(_) = False


assignments :: Stm -> { Loc }
assignments(Term(op,_)ss) = case (op,ss) of
   (LabStm _,[s])         -> assignments(s)
   (SynBlock,[s])         -> assignments(s)
   (Finally locs,[s1,s2]) -> assignments(s1) `union` locs
   (Catch _,[s])          -> assignments(s)
   (LocAss loc,_)         -> { loc }
   (LocInc loc,_)         -> { loc }
   _                      -> { x | s <- ss, x <-: assignments(s) }


genLab :: [Lab] -> Lab
genLab(labs) = "<l" ++ show (length(labs)) ++ ">"


primCompatible :: Mapping (JavaType,JavaType) (Exp -> Exp)
primCompatible = mapping $ transitive(fst,combine)
   [ ((TJByte,  TJShort),  \e -> Term(Una "b2s",TJShort )[e]),
     ((TJShort, TJInt),    \e -> Term(Una "s2i",TJInt   )[e]),
     ((TJInt,   TJLong),   \e -> Term(Una "i2l",TJLong  )[e]),
     ((TJLong,  TJFloat),  \e -> Term(Una "l2f",TJFloat )[e]),
     ((TJFloat, TJDouble), \e -> Term(Una "f2d",TJDouble)[e]),
     ((TJChar,  TJInt),    \e -> Term(Una "c2i",TJInt   )[e])
   ]
 where combine ((a,_),fa) ((_,b),fb) = ((a,b),fb . fa)

primCastable :: Mapping (JavaType,JavaType) (Exp -> Exp)
primCastable = mapping $ transitive(fst,combine)
   [ ((TJShort,  TJByte),   \e -> Term(Una "s2b",TJByte  )[e]),
     ((TJInt,    TJShort),  \e -> Term(Una "i2s",TJShort )[e]),
     ((TJLong,   TJInt),    \e -> Term(Una "l2i",TJInt   )[e]),
     ((TJFloat,  TJLong),   \e -> Term(Una "f2l",TJLong  )[e]),
     ((TJDouble, TJFloat),  \e -> Term(Una "d2f",TJFloat )[e]),
     ((TJInt,    TJChar),   \e -> Term(Una "i2c",TJChar  )[e])
   ]
 where combine ((a,_),fa) ((_,b),fb) = ((a,b),fb . fa)


stringLength :: MethRef
stringLength = stringClass :/ ("length", [])

stringValueOfI :: MethRef
stringValueOfI = stringClass :/ ("valueOf", [TJInt])

stringValueOfC :: MethRef
stringValueOfC = stringClass :/ ("valueOf", [TJChar])

printStreamPrintS :: MethRef
printStreamPrintS = printStreamClass :/ ("print",[stringType])

printStreamPrintlnS :: MethRef
printStreamPrintlnS = printStreamClass :/ ("println",[stringType])

printStreamPrintI :: MethRef
printStreamPrintI = printStreamClass :/ ("print",[TJInt])

printStreamPrintlnI :: MethRef
printStreamPrintlnI = printStreamClass :/ ("println",[TJInt])

objectToString :: MethRef
objectToString = objectClass :/ ("toString",[])

objectClone :: MethRef
objectClone = objectClass :/ ("clone",[])

objectEquals :: MethRef
objectEquals = objectClass :/ ("equals", [objectType])

threadStart, threadInterrupted, threadIsInterrupted, threadInterrupt :: MethRef
threadStart         = threadClass :/ ("start", [])
threadInterrupt     = threadClass :/ ("interrupt", [])
threadInterrupted   = threadClass :/ ("interrupted", [])
threadIsInterrupted = threadClass :/ ("isInterrupted", [])

objectWait, objectNotify, objectNotifyAll :: MethRef
objectWait      = objectClass :/ ("wait", [])
objectNotify    = objectClass :/ ("notify", [])
objectNotifyAll = objectClass :/ ("notifyAll", [])


threadRun :: MethSig
threadRun = ("run", [])
