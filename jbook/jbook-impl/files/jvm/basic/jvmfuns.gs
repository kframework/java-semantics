infix 5 `restrictElem`
infix 5 `restrictNElem`

izero :: Word
izero = conv(0)

isZero :: Val -> Bool
isZero = all ((==0) . valueOf)

sndArgIsZero :: [Word] -> Bool
sndArgIsZero [_,x] = valueOf(x) == 0
sndArgIsZero [_,_,x1,x2] = valueOf(x1) == 0 && valueOf(x2) == 0

sndArgIsNotZero :: [Word] -> Bool
sndArgIsNotZero(ws) = not(sndArgIsZero(ws))


--Arithmetic
arithmetic  =
    ["iadd","isub","idiv","imul","ineg","irem",
     "ladd","lsub","ldiv","lmul","lneg","lrem",
     "dadd","dsub","ddiv","dmul","dneg","drem",
     "fadd","fsub","fdiv","fmul","fneg","frem"]

divMod =["idiv","irem", "ldiv","lrem", "ddiv","drem", "fdiv","frem"]

--Conversions
conversion =
    ["i2b","i2s","i2c","i2l","i2f","i2d", 
     "l2i","l2f","l2d",
     "f2l","f2d","f2i",
     "d2i","d2l","d2f"]

--Logical
logical =
    ["ishl","ishr","iushr","iand","ior","ixor",
     "lshl","lshr","lushr","land","lor","lxor"]
      

-- Comparison
comparison =
    ["lcmp", "fcmpl", "fcmpg", "dcmpl", "dcmpg"]

-- Conditionals
conditionals =
    ["ifeq", "ifnull", "iflt", "ifle", "ifne",
     "ifnonnull", "ifgt", "ifge",
     "if_acmpeq", "if_acmpne",
     "if_icmpeq", "if_icmpne","if_icmplt","if_icmpgt","if_icmple","if_icmpge"]

appl :: (PrimOp, [Word]) -> Val
appl (PrimFun(f), args) = fappl(f, args)
appl (PrimLdc(v), args) = v
    
-- Braucht bessere Strukturierung!
fappl :: (FNm, [Word]) -> Val
fappl ("d2f",[d,_])         = [(valueOf(d),WTFloat)]
fappl ("d2i",[d,_])         = [conv(truncate(w2f(d)))]
fappl ("d2l",[d,_])         = [(truncate(w2f(d)),WTLowLong),(0,WTHighLong)]
fappl ("dadd",[d1,_,d2,_])  = [d1+d2,(0,WTHighDouble)]
fappl ("dcmpl",[d1,_,d2,_]) | w2f(d1) == w2f(d2) = [conv(0)]
                            | w2f(d1) >  w2f(d2) = [conv(1)]
                            | True               = [conv(-1)]
fappl ("dcmpg",[d1,_,d2,_]) | w2f(d1) == w2f(d2) = [conv(0)]
                            | w2f(d1) >  w2f(d2) = [conv(1)]
                            | True               = [conv(-1)]
fappl ("ddiv",[d1,_,d2,_])  = [d1/d2,(0,WTHighDouble)]
fappl ("dmul",[d1,_,d2,_])  = [d1*d2,(0,WTHighDouble)]
fappl ("drem",[d1,_,d2,_])  = [error "drem: not defined",(0,WTHighDouble)]
fappl ("dneg",[d,_])        = [-d,(0,WTHighDouble)]
fappl ("dsub",[d1,_,d2,_])  = [d1-d2,(0,WTHighDouble)]
fappl ("iand",[i, j])       = [error "iand: not defined"]
fappl ("ior",[i, j])        = [error "ior: not defined"]
fappl ("ixor",[i, j])       = [error "ixor: not defined"]
fappl ("ishl",[i, j])       = [error "ishl: not defined"]
fappl ("ishr",[i, j])       = [error "ishr: not defined"]
fappl ("iushr",[i, j])      = [error "iushr: not defined"]
fappl ("iadd",[i, j])       = [i +  j]
fappl ("isub",[i, j])       = [i -  j]
fappl ("idiv",[i, j])       = [i /  j]
fappl ("imul",[i, j])       = [i *  j]
fappl ("ineg",[i])          = [-i]
fappl ("ifeq",[i])          = [conv (conv(i) == 0)]
fappl ("ifle",[i])          = [conv (conv(i) <= 0)]
fappl ("iflt",[i])          = [conv (conv(i) <  0)]
fappl ("ifge",[i])          = [conv (conv(i) >= 0)]
fappl ("ifgt",[i])          = [conv (conv(i) >  0)]
fappl ("ifne",[i])          = [conv (conv(i) /= 0)]
fappl ("if_acmpeq", [i, j]) = [conv (i == j)]
fappl ("if_acmpne", [i, j]) = [conv (i /= j)]
fappl ("if_icmpeq", [i, j]) = [conv (i == j)]
fappl ("if_icmpge", [i, j]) = [conv (i >= j)]
fappl ("if_icmpgt", [i, j]) = [conv (i >  j)]
fappl ("if_icmple", [i, j]) = [conv (i <= j)]
fappl ("if_icmplt", [i, j]) = [conv (i <  j)]
fappl ("if_icmpne", [i, j]) = [conv (i /= j)]
fappl ("ifnonnull", [i])    = [conv (not(conv(i) == 0))]
fappl ("ifnull",    [i])    = [conv (conv(i) == 0)]
fappl ("i2b",   [i])        = [i]
fappl ("i2c",   [i])        = [i]
fappl ("i2s",   [i])        = [i]
fappl ("i2f",   [i])        = [conv (fromInteger(conv(i)) :: Float)]
fappl ("i2d",   [i])        = [(conv (fromInteger(conv(i)) :: Float), WTLowDouble), 
                               (0,WTHighDouble)]
fappl ("i2l",   [i])        = [(valueOf(i),WTLowLong),(0,WTHighLong)]
fappl ("ineg",  [i])        = [-i]
fappl ("irem",  [i, j])     = [conv (conv(i) `mod` conv(j))]
fappl ("f2i",   [f])        = [conv (truncate (w2f(f)))]
fappl ("f2l",   [f])        = [(truncate (w2f(f)), WTLowLong), (0,WTHighLong)]
fappl ("f2d",   [f])        = [(valueOf(f),WTLowDouble),(0,WTHighDouble)]
fappl ("fadd",  [f, g])     = [conv (w2f(f) + w2f(g))]
fappl ("fcmpg", [f, g])     | w2f(f) == w2f(g) = [conv(0)]
                            | w2f(f) >  w2f(g) = [conv(1)]
                            | True   = [conv(-1)]
fappl ("fcmpl", [f, g])     | w2f(f) == w2f(g) = [conv(0)]
                            | w2f(f) >  w2f(g) = [conv(1)]
                            | True   = [conv(-1)]
fappl ("fdiv",  [f, g])     = [conv (w2f(f) / w2f(g))]
fappl ("fmul",  [f, g])     = [conv (w2f(f) * w2f(g))]
fappl ("fneg",  [f])        = [conv (-w2f(f))]
fappl ("frem",  [f, g])     = [error "frem: not defined"]
fappl ("fsub",  [f, g])     = [conv (w2f(f) - w2f(g))]
fappl ("l2d", 	[l1,_])     = [(conv(fromInteger(valueOf(l1)) :: Float),
                                       WTLowDouble),
                               (0,WTHighDouble)]
fappl ("l2f", 	[l1,_])     = [conv(fromInteger(valueOf(l1)) :: Float)]
fappl ("l2i", 	[l1,_])     = [(valueOf(l1),WTInt)]
fappl ("ladd", [i, _,j,_])  = [i +  j,(0,WTHighLong)]
fappl ("land", [i, _,j,_])  = [error "land: not defined",(0,WTHighLong)]
fappl ("lor",  [i, _,j,_])  = [error "lor: not defined",(0,WTHighLong)]
fappl ("lcmp", [i, _,j,_])  | i == j = [conv(0)]
                            | j >  i = [conv(1)]
                            | True   = [conv(-1)]
fappl ("ldiv", [i, _,j,_])  = [i /  j,(0,WTHighLong)]
fappl ("lmul", [i, _,j,_])  = [i *  j,(0,WTHighLong)]
fappl ("lneg", [i, _])      = [-i,(0,WTHighLong)]
fappl ("lrem", [i, _,j,_])  = [error "lrem: not defined",(0,WTHighLong)]
fappl ("lshl", [i, _,j])    = [error "lshl: not defined",(0,WTHighLong)]
fappl ("lshr", [i, _,j])    = [error "lshr: not defined",(0,WTHighLong)]
fappl ("lsub", [i, _,j,_])  = [i -  j,(0,WTHighLong)]
fappl ("lushr",[i, _,j])    = [error "lushr: not defined",(0,WTHighLong)]
fappl ("lxor", [i, _,j,_])  = [error "lxor: not defined",(0,WTHighLong)]
fappl (x,_)  = error("Missing fappl  of " ++  x)


funSig :: Fun -> ([[VerifyType]],[VerifyType])
funSig("d2f")       = ([vtDouble], vtFloat)
funSig("d2i")       = ([vtDouble], vtInt)
funSig("d2l")       = ([vtDouble], vtLong)
funSig("dadd")      = ([vtDouble, vtDouble], vtDouble)
funSig("dcmpg")     = ([vtDouble, vtDouble], vtInt)
funSig("dcmpl")     = ([vtDouble, vtDouble], vtInt)
funSig("ddiv")      = ([vtDouble, vtDouble], vtDouble)
funSig("dmul")      = ([vtDouble, vtDouble], vtDouble)
funSig("dneg")      = ([vtDouble], vtDouble)
funSig("drem")      = ([vtDouble, vtDouble], vtDouble)
funSig("dsub")      = ([vtDouble, vtDouble], vtDouble)
funSig("iand")      = ([vtInt,vtInt],vtInt)
funSig("ior")       = ([vtInt,vtInt],vtInt)
funSig("ixor")      = ([vtInt,vtInt],vtInt)
funSig("ishl")      = ([vtInt,vtInt],vtInt)
funSig("ishr")      = ([vtInt,vtInt],vtInt)
funSig("iushr")     = ([vtInt,vtInt],vtInt)
funSig("iadd")      = ([vtInt,vtInt],vtInt)
funSig("isub")      = ([vtInt,vtInt],vtInt)
funSig("idiv")      = ([vtInt,vtInt],vtInt)
funSig("imul")      = ([vtInt,vtInt],vtInt)
funSig("ineg")      = ([vtInt], vtInt)
funSig("ifgt")      = ([vtInt],vtInt)
funSig("ifne")      = ([vtInt],vtInt)
funSig("ifeq")      = ([vtInt],vtInt)
funSig("ifge")      = ([vtInt],vtInt)
funSig("ifle")      = ([vtInt],vtInt)
funSig("iflt")      = ([vtInt],vtInt)
funSig("if_acmpeq") = ([vtAddr,vtAddr],vtInt)
funSig("if_acmpne") = ([vtAddr,vtAddr],vtInt)
funSig("if_icmpeq") = ([vtInt,vtInt],vtInt)
funSig("if_icmpge") = ([vtInt,vtInt],vtInt)
funSig("if_icmpgt") = ([vtInt,vtInt],vtInt)
funSig("if_icmple") = ([vtInt,vtInt],vtInt)
funSig("if_icmplt") = ([vtInt,vtInt],vtInt)
funSig("if_icmpne") = ([vtInt,vtInt],vtInt)
funSig("ifnull")    = ([vtAddr],vtInt)
funSig("ifnonnull") = ([vtAddr],vtInt)
funSig("i2b")       = ([vtInt],vtByte)
funSig("i2c")       = ([vtInt],vtChar)
funSig("i2s")       = ([vtInt],vtShort)
funSig("i2f")       = ([vtInt],vtFloat)
funSig("i2d")       = ([vtInt],vtDouble)
funSig("i2l")       = ([vtInt],vtLong)
funSig("irem")      = ([vtInt,vtInt],vtInt)
funSig("f2i")       = ([vtFloat],vtInt)
funSig("f2l")       = ([vtFloat],vtLong)
funSig("f2d")       = ([vtFloat],vtDouble)
funSig("fadd")      = ([vtFloat,vtFloat],vtFloat)
funSig("fcmpg")     = ([vtFloat,vtFloat],vtInt)
funSig("fcmpl")     = ([vtFloat,vtFloat],vtInt)
funSig("fdiv")      = ([vtFloat,vtFloat],vtFloat)
funSig("fmul")      = ([vtFloat,vtFloat],vtFloat)
funSig("fneg")      = ([vtFloat],vtFloat)
funSig("frem")      = ([vtFloat,vtFloat],vtFloat)
funSig("fsub")      = ([vtFloat,vtFloat],vtFloat)
funSig("l2d")       = ([vtLong],vtDouble)
funSig("l2f")       = ([vtLong],vtFloat)
funSig("l2i")       = ([vtLong],vtInt)
funSig("ladd")      = ([vtLong, vtLong], vtLong)
funSig("land")      = ([vtLong, vtLong], vtLong)
funSig("lor")       = ([vtLong, vtLong], vtLong)
funSig("lcmp")      = ([vtLong, vtLong], vtInt)
funSig("ldiv")      = ([vtLong, vtLong], vtLong)
funSig("lmul")      = ([vtLong, vtLong], vtLong)
funSig("lneg")      = ([vtLong], vtLong)
funSig("lrem")      = ([vtLong, vtLong], vtLong)
funSig("lshl")      = ([vtLong, vtInt], vtLong)
funSig("lshr")      = ([vtLong, vtInt], vtLong)
funSig("lsub")      = ([vtLong, vtLong], vtLong)
funSig("lushr")     = ([vtLong, vtInt], vtLong)
funSig("lxor")      = ([vtLong, vtLong], vtLong)
funSig("monitorenter") = ([[VTReference(VTClass(object))]],[])
funSig("monitorexit")  = ([[VTReference(VTClass(object))]],[])
funSig(x) = error("Missing funSig of" ++  x)


{-
isJavaLangBasic :: CNm -> Bool
isJavaLangBasic cn = cn `elem` [ "java/lang/Object"
                               , "java/lang/ClassLoader"
                               , "java/lang/String"
                               , "java/lang/Class"
                               , "java/lang/Array"
                               ]

isJavaBasic :: CNm -> Bool
isJavaBasic cn = all (uncurry (==)) (zip cn "java/")
-}

startMain :: MRef -> [Instr]
startMain (c:/m) = 
    [ Prim(PrimLdc [(0,WTReference)])
    , MInvokeStatic(TJVoid,c :/ (mNm(m), [TJArray(tjString)]),
                    (mNm(m) ++ "([Ljava/lang/String;)","V"))
    ]



-- -----------------------------------------------------------------------
-- Restrict

restrictElem :: (Eq a, Ord (a,b)) => {a} -> Map a b -> Map a b
restrictElem xs f = { (i,v) | (i,v) <-: f, i `elem` xs }

restrictNElem :: (Eq a, Ord (a,b)) => {a} -> Map a b -> Map a b
restrictNElem xs f = { (i,v) | (i,v) <-: f, i `notElem` xs }


---------------------------------------------------------------------------

instance ArgTypes Fun where
  argTypes = concat . fst . funSig

instance ArgTypes PrimOp where
  argTypes (PrimFun(f)) = argTypes(f)
  argTypes (PrimLdc(_)) = []

instance Argsize FNm where
  argSizes = map length . fst . funSig

instance Argsize PrimOp where
  argSizes (PrimFun(f)) = argSizes(f)
  argSizes (PrimLdc(v)) = []

setReferenceType :: Ref -> Word
setReferenceType(r) = (r,WTReference)


---------------------------------------------------------------------------

class CtxReferences a where
  ctxReferences :: Class -> a -> [(Class,Class)]

instance CtxReferences JavaType where
  ctxReferences ctx (TJRef(c))   = ctxReferences ctx c
  ctxReferences ctx (TJArray(t)) = ctxReferences ctx t
  ctxReferences ctx _            = []

instance CtxReferences a => CtxReferences [a] where
  ctxReferences ctx = nub . concat . map (ctxReferences ctx)

instance CtxReferences Class where
  ctxReferences ctx c = [(ctx,c)]

instance CtxReferences (Maybe Class) where
  ctxReferences ctx Nothing  = []
  ctxReferences ctx (Just c) = ctxReferences ctx c

instance CtxReferences {Class} where
  ctxReferences ctx xs = [ (ctx,c) | c <-: xs ]

instance CtxReferences MethTab where
  ctxReferences ctx ms =
    nub (concat (concat [ [ ctxReferences ctx mdec 
                          , ctxReferences ctx sig ]
                        | ((_,sig),mdec) <-: ms ]))

instance CtxReferences MDec where
  ctxReferences ctx (MDec(_,rt,code,excs,_)) =
      nub (concat (concat (
      [ [ ctxReferences ctx rt ]
      , map (ctxReferences ctx) excs
      , map (ctxReferences ctx) code ])))

instance CtxReferences Exc where
  ctxReferences ctx (Exc(_,_,_,c)) = ctxReferences ctx c
{-
       excs | False && cLd(c) == sysLd && isJavaBasic(cNm(c)) = []
-}

instance CtxReferences Instr where
  ctxReferences ctx instr = case instr of
    Prim(p) | conv(p) `elem` divMod -> ctxReferences ctx arithmeticException
            | otherwise             -> []
    MGetStatic(t,c:/f,_) -> concat [ ctxReferences ctx c
                                   , ctxReferences c t ]
    MPutStatic(t,c:/f,_) -> concat [ ctxReferences ctx c
                                   , ctxReferences c t ]
    
    MInvokeStatic(rt,c:/(_,sig),_) -> concat [ ctxReferences ctx c
                                             , ctxReferences c rt
                                             , ctxReferences c sig ]
    New(c)             -> ctxReferences ctx c
    MGetField(t,c:/f,_) -> concat [ ctxReferences ctx c
                                  , ctxReferences c t ]
    MPutField(t,c:/f,_)  -> concat [ ctxReferences ctx c
                                   , ctxReferences c t ]
    MInvokeSpecial(rt,c:/(_,sig),_) -> concat [ ctxReferences ctx c
                                              , ctxReferences c rt
                                              , ctxReferences c sig ]
    MInvokeVirtual(rt,x@(c:/(m,sig)),_) -> 
       if x ==  object :/ ("clone",[]) then
         concat [ ctxReferences ctx c
                , ctxReferences c rt
                , ctxReferences c sig
                , ctxReferences ctx (sysLd,"java/lang/Cloneable") ]
        else
         concat [ ctxReferences ctx c
                , ctxReferences c rt
                , ctxReferences c sig ]
    InstanceOf(t)     -> ctxReferences ctx t
    Checkcast(t)      -> concat [ ctxReferences ctx classCastException
                                , ctxReferences ctx t ]
    AStore(_)         ->
     ctxReferences ctx (sysLd,"java/lang/ArrayIndexOutOfBoundsException") ++
     ctxReferences ctx arrayStoreException
    ALoad(_)          ->
     ctxReferences ctx (sysLd,"java/lang/ArrayIndexOutOfBoundsException")
    NewArray(t,d)     -> concat [ ctxReferences ctx t
                                , ctxReferences ctx negativeArraySizeException
                                ]
    _ -> []

instance CtxReferences FieldTab where
  ctxReferences ctx fs = 
    nub (concat [ ctxReferences ctx t | (n,FDec(_,t)) <-: fs ])

instance CtxReferences ClassFile where
  ctxReferences ctx (CFile(_,_,_, super, _, ifaces, fields, methods)) =
      nub (concat [ctxReferences ctx super,
                   ctxReferences ctx ifaces,
                   ctxReferences ctx fields,
                   ctxReferences ctx methods,
                   ctxReferences ctx (sysLd,"java/lang/NoClassDefFoundError"),
                   ctxReferences ctx (sysLd,"java/lang/ClassFormatError"),
                   ctxReferences ctx (sysLd,"java/lang/ClassNotFoundException"),
                   ctxReferences ctx (sysLd,"java/lang/CloneNotSupportedException"),
                   ctxReferences ctx nullPointerException,
                   ctxReferences ctx abstractMethodError,
                   ctxReferences ctx (sysLd,"java/lang/ExceptionInInitializerError")])


fileContent :: (JVMHeap,a,b) -> String
fileContent (Array(_,[[(_,WTInternal s)]]),_,_) = s
fileContext (_,_,_) = ""