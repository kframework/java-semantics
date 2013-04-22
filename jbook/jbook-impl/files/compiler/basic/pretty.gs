class JShow a where
  jshow :: a -> ShowS

instance JShow JavaType where
  jshow TJInt         = showString "I"
  jshow TJFloat       = showString "F"
  jshow TJDouble      = showString "D"
  jshow TJShort       = showString "S"
  jshow TJByte        = showString "B"
  jshow TJBoolean     = showString "Z"
  jshow TJLong        = showString "J"
  jshow TJChar        = showString "C"
  jshow TJVoid        = showString "V"
  jshow (TJRef(c))    = showString "L" . showClassNameC(c) .
                              showString ";"
  jshow (TJArray(t))  = showString "[" . jshow t
  jshow  x            = error ("JShow JavaType: " ++ show' x)

instance JShow FRef where
  jshow ((_,c):/f) = showClassNameC(c) . showString "." . showString f

instance JShow MRef where
  jshow ((_,c):/(m,types)) = showClassNameC(c) . showString "/" .
                         showString m . showString "(" .
                         showList types .
                         showString ")"
     where showList [] = id
           showList (x:xs) = jshow x . showList xs

showClassNameC :: String -> ShowS
showClassNameC(cn) = showString (convertClassNm(cn))

convertClassNm :: JavaClass -> CNm
convertClassNm(cn)
  | cn `elem` [ 
                "ArithmeticException",
                "Array", 
                "ArrayIndexOutOfBoundsException",
                "ClassCastException",
                "Cloneable",
                "CloneNotSupportedException",
                "Comparable",
                "Error",
                "Exception",
                "ExceptionInInitializerError",
                "Float",
                "IllegalThreadStateException",
                "IndexOutOfBoundsException",
                "Integer",
                "InterruptedException",
                "LinkageError",
                "NegativeArraySizeException",
                "NoClassDefFoundError",
                "NullPointerException",
                "Number",
                "Object", 
                "Runnable", 
                "RuntimeException",
                "String", 
                "StringBuffer",
                "System",
                "Thread", 
                "Throwable"
              ]
    = "java/lang/" ++ cn
  | cn  ==  "PrintStream"
    = "java/io/" ++ cn
  | otherwise
    = cn


showLabName :: LabName -> ShowS
showLabName (l,ns) = showString l . print ns
  where print []     = id
        print [n]    = shows n
        print (n:ns) | n < 10    = shows n . print ns
                     | otherwise = showString "x" . print (n-10:ns)

instance JShow (MSig, MDec) where
  jshow ((mNm,args), MDec(ms,rt,c,excs,(maxOpd,maxReg))) = 
       showString ".method " . showSpaceList (expr2list(ms)) .
       showString mNm .
       showString "(" . foldl (.) id (map jshow args) .
       showString ")" . jshow rt . showString "\n" .
       (if Native `elem` ms || Abstract `elem` ms
         then id
         else showString ".limit stack " . shows maxOpd . showString "\n" .
              showString ".limit locals " . shows maxReg . showString "\n") .
       foldl (.) id (map print c) .
       foldl (.) id (map printExc excs) .
       showString ".end method\n"
   where print(LabInstr(l))    = showLabName l . showString ":\n"
         print(LabGoto(l))     = showString "   goto " . showLabName l . showString "\n"
         print(LabCond(rel,l)) = showString "   " .
                                 showString rel . showString " " . 
                                 showLabName l . showString "\n"
         print(LabJsr(l))      = showString "   jsr " . showLabName l . showString "\n"
         print(i)              = showString "   " . jshow i . showString "\n"
         printExc(ExcL(l1,l2,l3,(_,c))) =
                               showString ".catch " .
                               showClassNameC(c) . showString " from " .
                               showLabName l1 . showString " to " .
                               showLabName l2 . showString " using " .
                               showLabName l3 . showString "\n"

instance JShow ClassFile where
  jshow (CFile((_,cn), i, mods, s, _, is, ft, mt)) =
    showString (";; Java and its Virtual Machine" ++ newline) .
    showString (";; R. Staerk, J. Schmid, E. Boerger"
                ++ newline) .
    showString (if i then  newline ++ newline ++ ".interface " 
                     else newline ++ newline ++ ".class ") .
    showSpaceList (expr2list(mods)) .
    showClassNameC cn . showString "\n" .
    (case s of 
       Nothing    -> showString ""
       Just (_,c) -> showString ".super " . showClassNameC c .
                     showString "\n") .
    foldl (.) id (map f (expr2list(is))) .
    showString "\n" .
    jshowNewLineList (expr2list(ft)) .
    jshowNewLineList (expr2list(mt))
   where f (_,i) = showString ".implements " . 
                   showClassNameC i . 
                   showString "\n"

jshowNewLineList :: JShow a => [a] -> ShowS
jshowNewLineList []     = id
jshowNewLineList (x:xs) = jshow x . showString "\n" . jshowNewLineList xs


instance JShow Instr where
  jshow (Prim(PrimFun(f)))     = showString f
  jshow (Prim(PrimLdc([(0,WTReference)]))) = showString "aconst_null"
  jshow (Prim(PrimLdc([v])))     = showString "ldc " .shows (v : [])
  jshow (Prim(PrimLdc([v1,v2]))) = showString "ldc2_w " .shows [v1,v2]
  jshow (LoadString s) = showString "ldc " . shows s
  jshow (Iinc(r,i)) = showString "iinc " 
                        . shows r . showString " "
                        . shows (i : [])
  jshow (Load(t,r)) = shows t . showString "load " . shows r
  jshow (Store(t,r))= shows t . showString "store " . shows r
  jshow (Nop)       = showString "nop"
  jshow (Pop(0))    = showString "nop"
  jshow (Pop(1))    = showString "pop"
  jshow (Pop(2))    = showString "pop2"
  jshow (Dupx(0,1)) = showString "dup"
  jshow (Dupx(0,2)) = showString "dup2"
  jshow (Dupx(1,1)) = showString "dup_x1"
  jshow (Dupx(1,2)) = showString "dup2_x1"
  jshow (Dupx(2,1)) = showString "dup_x2"
  jshow (Dupx(2,2)) = showString "dup2_x2"
  jshow (Goto(o))   = showString "goto " . shows o
  jshow (Cond(rel,o)) = showString rel . showString " " . shows o
  jshow (Halt)      = showString "halt"
  jshow (MGetStatic(t,f,_)) = showString "getstatic " . jshow f .
                              showString " " . jshow t
  jshow (MPutStatic(t,f,_)) = showString "putstatic " . jshow f .
                              showString " " . jshow t
  jshow (MInvokeStatic(rt,m,_)) = showString "invokestatic " . jshow m .
                                  jshow rt
  jshow (Return(MTvoid)) = showString "return"
  jshow (Return(t))      = shows t . showString "return"
  jshow (NewArray(TJInt,1))    = showString "newarray int"
  jshow (NewArray(TJFloat,1))  = showString "newarray float"
  jshow (NewArray(TJLong,1))   = showString "newarray long"
  jshow (NewArray(TJDouble,1)) = showString "newarray double"
  jshow (NewArray(t,1))        = showString "anewarray "
                               . jshowAddrType t
  jshow (NewArray(t,d))       = showString "multianewarray "
                              . jshow (TJArray(t)) . showString " "
                              . shows d
  jshow (ArrayLength)         = showString "arraylength"
  jshow (ALoad(t))            = shows t . showString "aload"
  jshow (AStore(t))           = shows t . showString "astore"
  jshow (New((_,c)))          = showString "new " . showClassNameC c
  jshow (MGetField(t,f,_))   = showString "getfield " . jshow f .
                               showString " " . jshow t
  jshow (MPutField(t,f,_))   = showString "putfield " . jshow f .
                               showString " " . jshow t
  jshow (InstanceOf(t))  = showString "instanceof " . jshowAddrType t
  jshow (Checkcast(t))   = showString "checkcast " . jshowAddrType t
  jshow (MInvokeSpecial(rt,m,_))   = showString "invokespecial " . jshow m .
                                     jshow rt
  jshow (MInvokeVirtual(rt,m,_)) = showString "invokevirtual "
                                 . jshow m . jshow rt
  jshow (Athrow)               = showString "athrow"
  jshow (Jsr(o))               = showString "jsr " . shows o
  jshow (Ret(r))               = showString "ret " . shows r
  jshow e = error ("instance JShow Instr: " ++ primPrint 0 e "")

jshowAddrType :: JavaType -> ShowS
jshowAddrType(TJRef((c))) = showClassNameC(c)
jshowAddrType(TJArray(t)) = showString "[" . jshow t
jshowAddrType (w)         = error ("jshowAddrType: " ++ show' w)

instance JShow (Map FNm FDec) where
  jshow es =  foldl (.) id [jshow e | e <-: es]

instance JShow (FNm, FDec) where
  jshow (fn, FDec(ar,t)) =
    showString ".field " .
    showSpaceList (expr2list(ar)) .
    showString fn . showString " " .
    jshow t . showString "\n"
