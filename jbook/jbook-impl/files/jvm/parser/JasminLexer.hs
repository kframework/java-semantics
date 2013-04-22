



ctx_acts :: [(String,Posn -> String -> Token)]

type Token       = (Posn, JasminToken)
data JasminToken = JTSep
                 | JTDCatch
                 | JTDClass
                 | JTDEnd
                 | JTDField
                 | JTDImplements
                 | JTDInterface
                 | JTDLimit
                 | JTDLine
                 | JTDMethod
                 | JTDSet
                 | JTDSource
                 | JTDSuper
                 | JTDThrows
                 | JTDVar
-- reserved_words used in Jasmin directives
                 | JTFrom
                 | JTMethod
                 | JTTo
                 | JTIs
                 | JTUsing
-- Special-case instructions
                 | JTTableSwitch
                 | JTLookupSwitch
                 | JTDefault
-- Access flags
                 | JTPublic
                 | JTPrivate
                 | JTProtected
                 | JTStatic
                 | JTFinal
                 | JTSynchronized
                 | JTVolatile
                 | JTTransient
                 | JTNative
                 | JTInterface
                 | JTAbstract
-- other tokens
                 | JTNotSupported String
                 | JTInstrLdc
                 | JTInstrLdc2
                 | JTInstr0 Instr
                 | JTInstr1w (String -> Parser Instr)
                 | JTInstr1bt (JavaType -> Parser Instr)
                 | JTInstr1at (JavaType -> Parser Instr)
                 | JTInstr1i (Int -> Parser Instr)
                 | JTInstr2ww (String -> String -> Parser Instr)
                 | JTInstr2ii (Int -> Int -> Parser Instr)
                 | JTInstr2wi (String -> Int -> Parser Instr)
                 | JTInstr2ti (JavaType -> Int -> Parser Instr)
                 | JTColon
                 | JTEq
                 | JTString String
                 | JTQuote  String
                 | JTValI   Int
                 | JTValF   Float
                 | JTError  String
                 

str2float :: [Char] -> Float
str2float xs = let (l,_:r) = break (=='.') xs
               in  fromInteger (str2int l) 
                   + foldr (\a b -> (fromInteger (ord a - ord '0')
                                     + b) / 10.0) 0.0 r

strOfTok :: Token -> String
strOfTok (_,JTString s) = s
strOfTok (_,JTQuote s)  = init (tail s)
strOfTok x              = error ("strOfTok: " ++ show x)

valueOfTok :: Token -> Val
valueOfTok (_,JTValI i) = [conv(i)]
valueOfTok (_,JTValF f) = [conv(f)]
valueOfTok x           = error ("valueOfTok: " ++ show x)

value2OfTok :: Token -> Val
value2OfTok (_,JTValI i) = [(i,WTLowLong),(0,WTHighLong)]
value2OfTok (_,JTValF f) = [(conv(f),WTLowDouble),(0,WTHighDouble)]
value2OfTok x           = error ("valueOfTok: " ++ show x)

str2atyp :: String -> Parser(JavaType)
str2atyp ('[':xs) = do t <- str2typ xs; result (TJArray(t))
str2atyp xs       = do ld <- getClassLoader
                       result (TJRef(ld,xs))
                       

str2typ' :: String -> Parser (JavaType, String)
str2typ' ('I':xs) = result (TJInt,xs)
str2typ' ('J':xs) = result (TJLong,xs)
str2typ' ('B':xs) = result (TJByte,xs)
str2typ' ('S':xs) = result (TJShort,xs)
str2typ' ('C':xs) = result (TJChar,xs)
str2typ' ('F':xs) = result (TJFloat,xs)
str2typ' ('D':xs) = result (TJDouble,xs)
str2typ' ('Z':xs) = result (TJBoolean,xs)
str2typ' ('V':xs) = result (TJVoid,xs)
str2typ' ('L':xs) = do ld <- getClassLoader
                       let (l,r) = break (==';') xs
                       result (null r) ==> raiseErrorInLine "; expected"
                       result (TJRef(ld,l), tail r)
str2typ' ('[':xs) = do (t,xs') <- str2typ' xs
                       result (TJArray(t),xs')
str2typ' xs       = raiseErrorInLine ("unexpected type: " ++ xs)

str2typ :: String -> Parser JavaType
str2typ xs = do (t,xs) <- str2typ' xs
                case xs of
                 [] -> result t
                 _  -> raiseErrorInLine ("unexpected type " ++ xs)

str2typs :: String -> Parser [JavaType]
str2typs [] = result []
str2typs xs = do (t,xs') <- str2typ' xs
                 ts <- str2typs xs'
                 result (t : ts)

splitAtLastSlash :: Bool -> String -> Parser (Combine String String)
splitAtLastSlash empty xs = do
       let r = foldl (\xs c -> if c=='/' || c == '.' then "" else c:xs) [] xs
       let l = take (max 0 $ length xs - length r - 1) xs
       case (map f l) of
        [] -> if empty then result ([] :/ reverse r)
                else raiseErrorInLine "invalid name"
        c  -> result (c :/ reverse r)
  where f '.' = '/'
        f x   = x


str2mref :: Bool -> String -> Parser (MRef,JavaType,MRefSig)
str2mref empty xs = do 
    (mn, argtypes, rtyp) <- splitmref xs
    (cname :/ mname) <- splitAtLastSlash empty mn
    as <- str2typs argtypes
    r  <- str2typ  rtyp
    l  <- getClassLoader
    result (((l,cname) :/ (mname, as)),r,
             (mname++"("++argtypes++")",rtyp))

str2fref :: String -> Parser (FRef, String)
str2fref s = do (c:/f) <- splitAtLastSlash False s
                l <- getClassLoader
                result ((l,c):/f,f)

--splitmref mref = (classname ++ '/' ++ methodname, argtypes, rtyp)
splitmref :: String -> Parser (String,String,String)
splitmref xs = case break (=='(') xs of
                (_,[])  -> raiseErrorInLine "'(' expected"
                ([],_)  -> raiseErrorInLine "method name is empty"
                (l,_:r) -> case break (==')') r of
                            (_,[]) -> raiseErrorInLine "')' expected"
                            (args,_:rtyp) -> result (l,args,rtyp)

insertOffset :: String -> (Offset -> Instr) -> Parser Instr
insertOffset s f = do o <- getLabelOffset s
                      result (f o)

jlColon p s     = (p, JTColon)
jlSep p s       = (p, JTSep)
jlEq p s        = (p, JTEq)
jlQuote p s     = (p, JTQuote (substNewline(s)))
jlDirective p s = let t = case maplookup jasminReservedWords s of
                            Just t  -> t
                            Nothing -> JTError (s ++ 
                                                " is not a directive!")
                  in  (p, t)
jlInt p s       = (p, JTValI (str2int s))
jlFloat p s     = (p, JTValF (str2float s))
jlString p s    = let t = case maplookup jasminReservedWords s of
                            Just t  -> t
                            Nothing -> JTString s
                  in (p, t)


jasminReservedWords :: Mapping String JasminToken
jasminReservedWords = mapping
      [ 
-- Directives
        (".catch",      JTDCatch),
        (".class",      JTDClass),
        (".end",        JTDEnd),
        (".field",      JTDField),
        (".implements", JTDImplements),
        (".interface",  JTDInterface),
        (".limit",      JTDLimit),
        (".line",       JTDLine),
        (".method",     JTDMethod),
        (".set",        JTDSet),
        (".source",     JTDSource),
        (".super",      JTDSuper),
        (".throws",     JTDThrows),
        (".var",        JTDVar),
-- reserved_words used in Jasmin directives
        ("from",        JTFrom),
        ("method",      JTMethod),
        ("to",          JTTo),
        ("is",          JTIs),
        ("using",       JTUsing),
-- Special-case instructions
        ("tableswitch", JTTableSwitch),
        ("lookupswitch",JTLookupSwitch ),
        ("default",     JTDefault),
-- Access flags
        ("public",      JTPublic),
        ("private",     JTPrivate),
        ("protected",   JTProtected),
        ("static",      JTStatic),
        ("final",       JTFinal),
        ("synchronized",JTSynchronized),
        ("volatile",    JTVolatile),
        ("transient",   JTTransient),
        ("native",      JTNative),
        ("interface",   JTInterface),
        ("abstract",    JTAbstract),
-- Instructions
        ("aaload",      JTInstr0 (ALoad(AMTObject))),
        ("aastore",     JTInstr0 (AStore(AMTObject))),
        ("aconst_null", JTInstr0 (Prim (PrimLdc [(0,WTReference)]))),
        ("aload",       JTInstr1i (\i -> result (Load (MTAddr,i)))),
        ("aload_0", 	JTInstr0 (Load (MTAddr,0))),
        ("aload_1", 	JTInstr0 (Load (MTAddr,1))),
        ("aload_2", 	JTInstr0 (Load (MTAddr,2))),
        ("aload_3", 	JTInstr0 (Load (MTAddr,3))),
        ("anewarray", 	JTInstr1at (\t -> result (NewArray(t,1)))),
        ("areturn", 	JTInstr0 (Return(MTAddr))),
        ("arraylength", JTInstr0 (ArrayLength)),
        ("astore",   	JTInstr1i (\i -> result (Store (MTAddr,i)))),
        ("astore_0", 	JTInstr0 (Store (MTAddr,0))),
        ("astore_1", 	JTInstr0 (Store (MTAddr,1))),
        ("astore_2", 	JTInstr0 (Store (MTAddr,2))),
        ("astore_3", 	JTInstr0 (Store (MTAddr,3))),
        ("athrow", 	JTInstr0 Athrow),
        ("baload", 	JTInstr0 (ALoad(AMTByte))),
        ("bastore", 	JTInstr0 (AStore(AMTByte))),
        ("bipush", 	JTInstr1i (\v -> result (Prim (PrimLdc ([conv(v)]))))),
        ("breakpoint", 	JTNotSupported "breakpoint"),
        ("caload", 	JTInstr0 (ALoad(AMTChar))),
        ("castore", 	JTInstr0 (AStore(AMTChar))),
        ("checkcast", 	JTInstr1at (\t -> result (Checkcast t))),
        ("d2f", 	JTInstr0 (Prim (PrimFun("d2f")))),
        ("d2i", 	JTInstr0 (Prim (PrimFun("d2i")))),
        ("d2l", 	JTInstr0 (Prim (PrimFun("d2l")))),
        ("dadd",        JTInstr0 (Prim (PrimFun("dadd")))),
        ("daload", 	JTInstr0 (ALoad(AMTDouble))),
        ("dastore", 	JTInstr0 (AStore(AMTDouble))),
        ("dcmpg", 	JTInstr0 (Prim (PrimFun("dcmpg")))),
        ("dcmpl",       JTInstr0 (Prim (PrimFun("dcmpl")))),
        ("dconst_0", 	JTInstr0 (Prim (PrimLdc (conv(Double(0.0)))))),
        ("dconst_1", 	JTInstr0 (Prim (PrimLdc (conv(Double(1.0)))))),
        ("ddiv", 	JTInstr0 (Prim (PrimFun("ddiv")))),
        ("dload",       JTInstr1i (\i -> result (Load( MTDouble,i)))),
        ("dload_0",     JTInstr0 (Load(MTDouble,0))),
        ("dload_1",     JTInstr0 (Load(MTDouble,1))),
        ("dload_2",     JTInstr0 (Load(MTDouble,2))),
        ("dload_3",     JTInstr0 (Load(MTDouble,3))),
        ("dmul", 	JTInstr0 (Prim (PrimFun("dmul")))),
        ("dneg", 	JTInstr0 (Prim (PrimFun("dneg")))),
        ("drem",        JTInstr0 (Prim (PrimFun("drem")))),
        ("dreturn", 	JTInstr0 (Return (MTDouble))),
        ("dstore", 	JTInstr1i (\i -> result (Store (MTDouble,i)))),
        ("dstore_0",    JTInstr0 (Store (MTDouble,0))),
        ("dstore_1",    JTInstr0 (Store (MTDouble,1))),
        ("dstore_2",    JTInstr0 (Store (MTDouble,2))),
        ("dstore_3",    JTInstr0 (Store (MTDouble,3))),
        ("dsub", 	JTInstr0 (Prim (PrimFun("dsub")))),
        ("dup", 	JTInstr0 (Dupx(0,1))),
        ("dup2", 	JTInstr0 (Dupx(0,2))),
        ("dup2_x1", 	JTInstr0 (Dupx(1,2))),
        ("dup2_x2", 	JTInstr0 (Dupx(2,2))),
        ("dup_x1", 	JTInstr0 (Dupx(1,1))),
        ("dup_x2", 	JTInstr0 (Dupx(2,1))),
        ("f2d", 	JTInstr0 (Prim (PrimFun("f2d")))),
        ("f2i", 	JTInstr0 (Prim (PrimFun("f2i")))),
        ("f2l", 	JTInstr0 (Prim (PrimFun("f2l")))),
        ("fadd", 	JTInstr0 (Prim (PrimFun("fadd")))),
        ("faload", 	JTInstr0 (ALoad(AMTFloat))),
        ("fastore", 	JTInstr0 (AStore(AMTFloat))),
        ("fcmpg", 	JTInstr0 (Prim (PrimFun("fcmpl")))),
        ("fcmpl", 	JTInstr0 (Prim (PrimFun("fcmpg")))),
        ("fconst_0", 	JTInstr0 (Prim (PrimLdc ([conv(0.0)])))),
        ("fconst_1", 	JTInstr0 (Prim (PrimLdc ([conv(1.0)])))),
        ("fconst_2", 	JTInstr0 (Prim (PrimLdc ([conv(2.0)])))),
        ("fdiv", 	JTInstr0 (Prim (PrimFun("fdiv")))),
        ("fload", 	JTInstr1i (\i -> result (Load (MTFloat, i)))),
        ("fload_0",     JTInstr0 (Load (MTFloat,0))),
        ("fload_1",     JTInstr0 (Load (MTFloat,1))),
        ("fload_2",     JTInstr0 (Load (MTFloat,2))),
        ("fload_3",     JTInstr0 (Load (MTFloat,3))),
        ("fmul", 	JTInstr0 (Prim (PrimFun("fmul")))),
        ("fneg", 	JTInstr0 (Prim (PrimFun("fneg")))),
        ("frem", 	JTInstr0 (Prim (PrimFun("frem")))),
        ("freturn", 	JTInstr0 (Return (MTFloat))),
        ("fstore", 	JTInstr1i (\i -> result (Store (MTFloat,i)))),
        ("fstore_0",    JTInstr0 (Store (MTFloat, 0))),
        ("fstore_1",    JTInstr0 (Store (MTFloat, 1))),
        ("fstore_2",    JTInstr0 (Store (MTFloat, 2))),
        ("fstore_3",    JTInstr0 (Store (MTFloat, 3))),
        ("fsub",        JTInstr0 (Prim (PrimFun("fsub")))),
        ("getfield", 	JTInstr2ww (\xs te -> do
                                     (fref,fn) <- str2fref xs
                                     t    <- str2typ te 
                                     result (MGetField(t,fref,(fn,te))))),
        ("getstatic", 	JTInstr2ww (\xs te -> do
                                     (fref,fn) <- str2fref xs
                                     t    <- str2typ  te
                                     result (MGetStatic(t,fref,(fn,te))))),
        ("goto",        JTInstr1w (\s -> insertOffset s (\o -> Goto(o)))),
        ("goto_w", 	JTInstr1w (\s -> insertOffset s (\o -> Goto(o)))),
        ("i2b", 	JTInstr0 (Prim (PrimFun("i2b")))),
        ("i2c", 	JTInstr0 (Prim (PrimFun("i2c")))),
        ("i2d", 	JTInstr0 (Prim (PrimFun("i2d")))),
        ("i2f", 	JTInstr0 (Prim (PrimFun("i2f")))),
        ("i2l",         JTInstr0 (Prim (PrimFun("i2l")))),
        ("i2s",         JTInstr0 (Prim (PrimFun("i2s")))),
        ("iadd",        JTInstr0 (Prim (PrimFun("iadd")))),
        ("iaload",      JTInstr0 (ALoad(AMTInt))),
        ("iand", 	JTInstr0 (Prim (PrimFun("iand")))),
        ("iastore", 	JTInstr0 (AStore(AMTInt))),
        ("iconst_0", 	JTInstr0 (Prim (PrimLdc ([conv(0)])))),
        ("iconst_1", 	JTInstr0 (Prim (PrimLdc ([conv(1)])))),
        ("iconst_2", 	JTInstr0 (Prim (PrimLdc ([conv(2)])))),
        ("iconst_3", 	JTInstr0 (Prim (PrimLdc ([conv(3)])))),
        ("iconst_4", 	JTInstr0 (Prim (PrimLdc ([conv(4)])))),
        ("iconst_5", 	JTInstr0 (Prim (PrimLdc ([conv(5)])))),
        ("iconst_m1", 	JTInstr0 (Prim (PrimLdc ([conv((-1))])))),
        ("idiv", 	JTInstr0 (Prim (PrimFun("idiv")))),
        ("if_acmpeq", 	JTInstr1w (\s -> insertOffset s (\o -> 
                                          Cond ("if_acmpeq", o)))),
        ("if_acmpne", 	JTInstr1w (\s -> insertOffset s (\o -> 
                                          Cond ("if_acmpne", o)))),
        ("if_icmpeq", 	JTInstr1w (\s -> insertOffset s (\o -> 
                                          Cond ("if_icmpeq", o)))),
        ("if_icmpge", 	JTInstr1w (\s -> insertOffset s (\o -> 
                                          Cond ("if_icmpge", o)))),
        ("if_icmpgt", 	JTInstr1w (\s -> insertOffset s (\o -> 
                                          Cond ("if_icmpgt", o)))),
        ("if_icmple", 	JTInstr1w (\s -> insertOffset s (\o -> 
                                          Cond ("if_icmple", o)))),
        ("if_icmplt", 	JTInstr1w (\s -> insertOffset s (\o -> 
                                          Cond ("if_icmplt", o)))),
        ("if_icmpne",  	JTInstr1w (\s -> insertOffset s (\o -> 
                                          Cond ("if_icmpne", o)))),
        ("ifeq", 	JTInstr1w (\s -> insertOffset s (\o -> 
                                          Cond ("ifeq", o)))),
        ("ifge", 	JTInstr1w (\s -> insertOffset s (\o -> 
                                          Cond ("ifge", o)))),
        ("ifgt", 	JTInstr1w (\s -> insertOffset s (\o -> 
                                          Cond ("ifgt", o)))),
        ("ifle", 	JTInstr1w (\s -> insertOffset s (\o -> 
                                          Cond ("ifle", o)))),
        ("iflt", 	JTInstr1w (\s -> insertOffset s (\o -> 
                                          Cond ("iflt", o)))),
        ("ifne", 	JTInstr1w (\s -> insertOffset s (\o -> 
                                          Cond ("ifne",o)))),
        ("ifnonnull", 	JTInstr1w (\s -> insertOffset s (\o ->
                                          Cond ("ifnonnull",o)))),
        ("ifnull", 	JTInstr1w (\s -> insertOffset s (\o ->
                                          Cond ("ifnull",o)))),
        ("iinc", 	JTInstr2ii (\v i -> result $
                             Iinc(v, conv(i)))),
        ("iload",   	JTInstr1i (\i -> result $ Load (MTInt,i))),
        ("iload_0", 	JTInstr0 (Load (MTInt, 0))),
        ("iload_1", 	JTInstr0 (Load (MTInt, 1))),
        ("iload_2", 	JTInstr0 (Load (MTInt, 2))),
        ("iload_3", 	JTInstr0 (Load (MTInt, 3))),
        ("imul", 	JTInstr0 (Prim (PrimFun("imul")))),
        ("ineg", 	JTInstr0 (Prim (PrimFun("ineg")))),
        ("instanceof", 	JTInstr1at (\s -> result $ InstanceOf s)),
        ("int2byte", 	JTInstr0 (Prim (PrimFun("i2b")))),
        ("int2char", 	JTInstr0 (Prim (PrimFun("i2c")))),
        ("int2short", 	JTInstr0 (Prim (PrimFun("i2s")))),
        ("i2b",         JTInstr0 (Prim (PrimFun("i2b")))),
        ("i2c",         JTInstr0 (Prim (PrimFun("i2c")))),
        ("i2s",         JTInstr0 (Prim (PrimFun("i2s")))),
        ("invokeinterface", JTInstr2wi (\s _ -> do 
                                         (mr,rt,msig) <- str2mref False s
                                         result (MInvokeVirtual(rt,mr,msig)))),
        ("invokenonvirtual", JTInstr1w (\s -> do 
                                         (mr,rt,msig) <- str2mref False s
                                         result (MInvokeSpecial(rt,mr,msig)))),
        ("invokespecial", JTInstr1w (\s -> do 
                                         (mr,rt,msig) <- str2mref False s
                                         result (MInvokeSpecial(rt,mr,msig)))),
        ("invokestatic",  JTInstr1w (\s -> do
                                      (mr,rt,msig) <- str2mref False s
                                      result (MInvokeStatic(rt,mr,msig)))),
        ("invokevirtual", JTInstr1w (\s -> do 
                                      (mr,rt,msig) <- str2mref False s
                                      result (MInvokeVirtual(rt,mr,msig)))),
        ("ior",         JTInstr0 (Prim (PrimFun("ior")))),
        ("irem", 	JTInstr0 (Prim (PrimFun("irem")))),
        ("ireturn", 	JTInstr0 (Return MTInt)),
        ("ishl", 	JTInstr0 (Prim (PrimFun("ishl")))),
        ("ishr", 	JTInstr0 (Prim (PrimFun("ishr")))),
        ("istore",   	JTInstr1i (\i -> result $ Store (MTInt,i))),
        ("istore_0", 	JTInstr0 (Store (MTInt,0))),
        ("istore_1", 	JTInstr0 (Store (MTInt,1))),
        ("istore_2", 	JTInstr0 (Store (MTInt,2))),
        ("istore_3", 	JTInstr0 (Store (MTInt,3))),
        ("isub", 	JTInstr0 (Prim(PrimFun("isub")))),
        ("iushr", 	JTInstr0 (Prim (PrimFun("iushr")))),
        ("ixor", 	JTInstr0 (Prim (PrimFun("ixor")))),
        ("jsr", 	JTInstr1w (\s -> insertOffset s Jsr)),
        ("jsr_w", 	JTInstr1w (\s -> insertOffset s Jsr)),
        ("l2d", 	JTInstr0 (Prim (PrimFun("l2d")))),
        ("l2f", 	JTInstr0 (Prim (PrimFun("l2f")))),
        ("l2i", 	JTInstr0 (Prim (PrimFun("l2i")))),
        ("ladd", 	JTInstr0 (Prim (PrimFun("ladd")))),
        ("laload", 	JTInstr0 (ALoad(AMTLong))),
        ("land", 	JTInstr0 (Prim (PrimFun("land")))),
        ("lastore", 	JTInstr0 (AStore(AMTLong))),
        ("lcmp", 	JTInstr0 (Prim (PrimFun("lcmp")))),
        ("lconst_0", 	JTInstr0 (Prim (PrimLdc (conv(Long(0)))))),
        ("lconst_1", 	JTInstr0 (Prim (PrimLdc (conv(Long(1)))))),
        ("ldc",         JTInstrLdc),
        ("ldc_w", 	JTInstrLdc),
        ("ldc2_w", 	JTInstrLdc2),
        ("ldiv", 	JTInstr0 (Prim (PrimFun("ldiv")))),
        ("lload", 	JTInstr1i (\i -> result $ Load (MTLong,i))),
        ("lload_0",     JTInstr0 (Load (MTLong,0))),
        ("lload_1",     JTInstr0 (Load (MTLong,1))),
        ("lload_2",     JTInstr0 (Load (MTLong,2))),
        ("lload_3",     JTInstr0 (Load (MTLong,3))),
        ("lmul",        JTInstr0 (Prim (PrimFun("lmul")))),
        ("lneg",        JTInstr0 (Prim (PrimFun("lneg")))),
        ("lookupswitch",JTLookupSwitch),
        ("lor",         JTInstr0 (Prim (PrimFun("lor")))),
        ("lrem", 	JTInstr0 (Prim (PrimFun("lrem")))),
        ("lreturn", 	JTInstr0 (Return MTLong)),
        ("lshl",        JTInstr0 (Prim (PrimFun("lshl")))),
        ("lshr", 	JTInstr0 (Prim (PrimFun("lshr")))),
        ("lstore",      JTInstr1i (\i -> result $ Store (MTLong, i))),
        ("lstore_0",    JTInstr0 (Store (MTLong, 0))),
        ("lstore_1",    JTInstr0 (Store (MTLong, 1))),
        ("lstore_2",    JTInstr0 (Store (MTLong, 2))),
        ("lstore_3",    JTInstr0 (Store (MTLong, 3))),
        ("lsub", 	JTInstr0 (Prim (PrimFun("lsub")))),
        ("lushr", 	JTInstr0 (Prim (PrimFun("lushr")))),
        ("lxor", 	JTInstr0 (Prim (PrimFun("lxor")))),
        ("monitorenter",JTInstr0 (Prim (PrimFun("monitorenter")))),
        ("monitorexit", JTInstr0 (Prim (PrimFun("monitorexit")))),
        ("multianewarray", JTInstr2ti (\ts n -> result(NewArray(ts,n)))),
        ("new",         JTInstr1w (\s -> do l <- getClassLoader; result $ New (l,s))),
        ("newarray",    JTInstr1bt (\ts -> result(NewArray(ts,1)))),
        ("nop", 	JTInstr0 (Nop)),
        ("pop", 	JTInstr0 (Pop(1))),
        ("pop2", 	JTInstr0 (Pop(2))),
        ("putfield", 	JTInstr2ww (\xs te -> do
                                     (fref,fn) <- str2fref xs
                                     t    <- str2typ  te
                                     result (MPutField(t,fref,(fn,te))))),
        ("putstatic", 	JTInstr2ww (\xs te -> do
                                     (fref,fn) <- str2fref xs
                                     t    <- str2typ te
                                     result (MPutStatic(t,fref,(fn,te))))),
        ("ret",         JTInstr1i (\i -> result $ Ret (i))),
        ("ret_w", 	JTInstr1i (\i -> result $ Ret (i))),
        ("return", 	JTInstr0 (Return MTvoid)),
        ("saload", 	JTInstr0 (ALoad(AMTShort))),
        ("sastore", 	JTInstr0 (AStore(AMTShort))),
        ("sipush", 	JTInstr1i (\v -> result (Prim (PrimLdc ([conv(v)]))))),
        ("swap", 	JTInstr0 (Swap)),
        ("tableswitch", JTTableSwitch),

        ("wide",        JTNotSupported "wide")
      ]

instance Text JasminToken where
  showsPrec _ JTSep    = showString "\\n"
  showsPrec _ JTDCatch = showString ".catch"
  showsPrec _ JTDClass = showString ".class"
  showsPrec _ JTDEnd   = showString ".end"
  showsPrec _ JTDField = showString ".field"
  showsPrec _ JTDImplements = showString ".implements"
  showsPrec _ JTDInterface  = showString ".interface"
  showsPrec _ JTDLimit      = showString ".limit"
  showsPrec _ JTDLine       = showString ".line"
  showsPrec _ JTDMethod     = showString ".method"
  showsPrec _ JTDSet        = showString ".set"
  showsPrec _ JTDSource     = showString ".source"
  showsPrec _ JTDSuper      = showString ".super"
  showsPrec _ JTDThrows     = showString ".throws"
  showsPrec _ JTDVar        = showString ".var"
  showsPrec _ JTFrom        = showString "from"
  showsPrec _ JTMethod      = showString "method"
  showsPrec _ JTTo          = showString "to"
  showsPrec _ JTIs          = showString "is"
  showsPrec _ JTUsing       = showString "using"
  showsPrec _ JTTableSwitch = showString "tableswitch"
  showsPrec _ JTLookupSwitch= showString "lookupswitch"
  showsPrec _ JTDefault     = showString "default"
  showsPrec _ JTPublic      = showString "public"
  showsPrec _ JTPrivate     = showString "private"
  showsPrec _ JTProtected   = showString "protected"
  showsPrec _ JTStatic      = showString "static"
  showsPrec _ JTFinal       = showString "final"
  showsPrec _ JTSynchronized= showString "synchronized"
  showsPrec _ JTVolatile    = showString "volatile"
  showsPrec _ JTTransient   = showString "transient"
  showsPrec _ JTNative      = showString "native"
  showsPrec _ JTInterface   = showString "interface"
  showsPrec _ JTAbstract    = showString "abstract"
  showsPrec _ (JTNotSupported s) = showString s
  showsPrec _ JTInstrLdc    = showString "ldc"
  showsPrec _ JTInstrLdc2   = showString "ldc2"
  showsPrec _ (JTInstr0 _)  = showString "<instruction>"
  showsPrec _ (JTInstr1w _) = showString "<instruction>"
  showsPrec _ (JTInstr1bt _)= showString "<instruction>"
  showsPrec _ (JTInstr1at _)= showString "<instruction>"
  showsPrec _ (JTInstr1i _) = showString "<instruction>"
  showsPrec _ (JTInstr2ww _)= showString "<instruction>"
  showsPrec _ (JTInstr2ii _)= showString "<instruction>"
  showsPrec _ (JTInstr2wi _)= showString "<instruction>"
  showsPrec _ (JTInstr2ti _)= showString "<instruction>"
  showsPrec _ JTColon       = showString ":"
  showsPrec _ JTEq          = showString "="
  showsPrec _ (JTString s)  = showString s
  showsPrec _ (JTQuote  s)  = shows s
  showsPrec _ (JTValI  i)   = shows i
  showsPrec _ (JTValF  f)   = shows f
  showsPrec _ (JTError s)   = showString "error: " . showString s
  showsPrec i e = showString (primPrint i e [])

instance Text Posn where
  showsPrec i e = showString (primPrint i e [])

jasminLexer :: String -> [Token]
jasminLexer = normalize . scan ctx_scan
  where normalize (x@(p,JTSep) : (_,JTSep) : xs)
          = normalize (x:xs)
        normalize [x@(p,JTSep)] = [x]
        normalize [x@(p,_)]     = [x, (p,JTSep)]
        normalize (x : xs)  = x : normalize xs
        normalize [] = []

ctx_scan :: Scan Token
ctx_scan = load_scan (ctx_acts, stop_act) ctx_lx
   where
    stop_act p ""  = []
    stop_act p inp = [(p,JTError $ "unexpected end: (" ++ take 20 inp ++")")]


ctx_acts = [("jlColon",jlColon),("jlDirective",jlDirective),("jlEq",jlEq),("jlFloat",jlFloat),("jlInt",jlInt),("jlQuote",jlQuote),("jlSep",jlSep),("jlString",jlString)]

ctx_lx :: [(Bool, [(Int,String,[Int],Maybe((Char,Char),[(Char,Bool)]),Maybe Int)], Int, ((Char,Char),[(Char,Int)]))]
ctx_lx = [lx__0_0,lx__1_0,lx__2_0,lx__3_0,lx__4_0,lx__5_0,lx__6_0,lx__7_0,lx__8_0,lx__9_0,lx__10_0,lx__11_0,lx__12_0,lx__13_0,lx__14_0,lx__15_0,lx__16_0,lx__17_0,lx__18_0,lx__19_0]
lx__0_0 :: (Bool, [(Int,String,[Int],Maybe((Char,Char),[(Char,Bool)]),Maybe Int)], Int, ((Char,Char),[(Char,Int)]))
lx__0_0 = (False,[],19,(('\t','='),[('\t',2),('\n',3),('\v',-1),('\f',-1),('\r',2),(' ',2),('"',7),('-',13),('.',16),('0',12),('1',12),('2',12),('3',12),('4',12),('5',12),('6',12),('7',12),('8',12),('9',12),(':',5),(';',1),('=',4)]))
lx__1_0 :: (Bool, [(Int,String,[Int],Maybe((Char,Char),[(Char,Bool)]),Maybe Int)], Int, ((Char,Char),[(Char,Int)]))
lx__1_0 = (True,[(0,"",[],Nothing,Nothing)],1,(('\n','\n'),[('\n',-1)]))
lx__2_0 :: (Bool, [(Int,String,[Int],Maybe((Char,Char),[(Char,Bool)]),Maybe Int)], Int, ((Char,Char),[(Char,Int)]))
lx__2_0 = (True,[(1,"",[],Nothing,Nothing)],-1,(('\t',' '),[('\t',2),('\r',2),(' ',2)]))
lx__3_0 :: (Bool, [(Int,String,[Int],Maybe((Char,Char),[(Char,Bool)]),Maybe Int)], Int, ((Char,Char),[(Char,Int)]))
lx__3_0 = (True,[(2,"jlSep",[],Nothing,Nothing)],-1,(('0','0'),[]))
lx__4_0 :: (Bool, [(Int,String,[Int],Maybe((Char,Char),[(Char,Bool)]),Maybe Int)], Int, ((Char,Char),[(Char,Int)]))
lx__4_0 = (True,[(3,"jlEq",[],Nothing,Nothing)],-1,(('0','0'),[]))
lx__5_0 :: (Bool, [(Int,String,[Int],Maybe((Char,Char),[(Char,Bool)]),Maybe Int)], Int, ((Char,Char),[(Char,Int)]))
lx__5_0 = (True,[(4,"jlColon",[],Nothing,Nothing)],-1,(('0','0'),[]))
lx__6_0 :: (Bool, [(Int,String,[Int],Maybe((Char,Char),[(Char,Bool)]),Maybe Int)], Int, ((Char,Char),[(Char,Int)]))
lx__6_0 = (False,[],6,(('"','\\'),[('"',11),('\\',8)]))
lx__7_0 :: (Bool, [(Int,String,[Int],Maybe((Char,Char),[(Char,Bool)]),Maybe Int)], Int, ((Char,Char),[(Char,Int)]))
lx__7_0 = (True,[(9,"jlString",[],Nothing,Nothing)],7,(('\t','\\'),[('\t',6),('\n',6),('\v',6),('\f',6),('\r',6),(' ',6),('"',10),(':',6),('=',6),('\\',9)]))
lx__8_0 :: (Bool, [(Int,String,[Int],Maybe((Char,Char),[(Char,Bool)]),Maybe Int)], Int, ((Char,Char),[(Char,Int)]))
lx__8_0 = (False,[],6,(('\n','\n'),[('\n',-1)]))
lx__9_0 :: (Bool, [(Int,String,[Int],Maybe((Char,Char),[(Char,Bool)]),Maybe Int)], Int, ((Char,Char),[(Char,Int)]))
lx__9_0 = (True,[(9,"jlString",[],Nothing,Nothing)],7,(('\t','='),[('\t',6),('\n',-1),('\v',6),('\f',6),('\r',6),(' ',6),(':',6),('=',6)]))
lx__10_0 :: (Bool, [(Int,String,[Int],Maybe((Char,Char),[(Char,Bool)]),Maybe Int)], Int, ((Char,Char),[(Char,Int)]))
lx__10_0 = (True,[(5,"jlQuote",[],Nothing,Nothing)],19,(('\t','='),[('\t',-1),('\n',-1),('\v',-1),('\f',-1),('\r',-1),(' ',-1),(':',-1),('=',-1)]))
lx__11_0 :: (Bool, [(Int,String,[Int],Maybe((Char,Char),[(Char,Bool)]),Maybe Int)], Int, ((Char,Char),[(Char,Int)]))
lx__11_0 = (True,[(5,"jlQuote",[],Nothing,Nothing)],-1,(('0','0'),[]))
lx__12_0 :: (Bool, [(Int,String,[Int],Maybe((Char,Char),[(Char,Bool)]),Maybe Int)], Int, ((Char,Char),[(Char,Int)]))
lx__12_0 = (True,[(6,"jlInt",[],Nothing,Nothing)],19,(('\t','='),[('\t',-1),('\n',-1),('\v',-1),('\f',-1),('\r',-1),(' ',-1),('.',17),('0',12),('1',12),('2',12),('3',12),('4',12),('5',12),('6',12),('7',12),('8',12),('9',12),(':',-1),('=',-1)]))
lx__13_0 :: (Bool, [(Int,String,[Int],Maybe((Char,Char),[(Char,Bool)]),Maybe Int)], Int, ((Char,Char),[(Char,Int)]))
lx__13_0 = (True,[(9,"jlString",[],Nothing,Nothing)],19,(('\t','='),[('\t',-1),('\n',-1),('\v',-1),('\f',-1),('\r',-1),(' ',-1),('.',17),('0',12),('1',12),('2',12),('3',12),('4',12),('5',12),('6',12),('7',12),('8',12),('9',12),(':',-1),('=',-1)]))
lx__14_0 :: (Bool, [(Int,String,[Int],Maybe((Char,Char),[(Char,Bool)]),Maybe Int)], Int, ((Char,Char),[(Char,Int)]))
lx__14_0 = (True,[(7,"jlFloat",[],Nothing,Nothing)],18,(('\t','='),[('\t',-1),('\n',-1),('\v',-1),('\f',-1),('\r',-1),(' ',-1),('.',-1),('0',14),('1',14),('2',14),('3',14),('4',14),('5',14),('6',14),('7',14),('8',14),('9',14),(':',-1),('=',-1)]))
lx__15_0 :: (Bool, [(Int,String,[Int],Maybe((Char,Char),[(Char,Bool)]),Maybe Int)], Int, ((Char,Char),[(Char,Int)]))
lx__15_0 = (True,[(7,"jlFloat",[],Nothing,Nothing)],19,(('\t','='),[('\t',-1),('\n',-1),('\v',-1),('\f',-1),('\r',-1),(' ',-1),('0',15),('1',15),('2',15),('3',15),('4',15),('5',15),('6',15),('7',15),('8',15),('9',15),(':',-1),('=',-1)]))
lx__16_0 :: (Bool, [(Int,String,[Int],Maybe((Char,Char),[(Char,Bool)]),Maybe Int)], Int, ((Char,Char),[(Char,Int)]))
lx__16_0 = (False,[],18,(('\t','='),[('\t',-1),('\n',-1),('\v',-1),('\f',-1),('\r',-1),(' ',-1),('.',-1),('0',14),('1',14),('2',14),('3',14),('4',14),('5',14),('6',14),('7',14),('8',14),('9',14),(':',-1),('=',-1)]))
lx__17_0 :: (Bool, [(Int,String,[Int],Maybe((Char,Char),[(Char,Bool)]),Maybe Int)], Int, ((Char,Char),[(Char,Int)]))
lx__17_0 = (True,[(9,"jlString",[],Nothing,Nothing)],19,(('\t','='),[('\t',-1),('\n',-1),('\v',-1),('\f',-1),('\r',-1),(' ',-1),('0',15),('1',15),('2',15),('3',15),('4',15),('5',15),('6',15),('7',15),('8',15),('9',15),(':',-1),('=',-1)]))
lx__18_0 :: (Bool, [(Int,String,[Int],Maybe((Char,Char),[(Char,Bool)]),Maybe Int)], Int, ((Char,Char),[(Char,Int)]))
lx__18_0 = (True,[(8,"jlDirective",[],Nothing,Nothing)],18,(('\t','='),[('\t',-1),('\n',-1),('\v',-1),('\f',-1),('\r',-1),(' ',-1),('.',-1),(':',-1),('=',-1)]))
lx__19_0 :: (Bool, [(Int,String,[Int],Maybe((Char,Char),[(Char,Bool)]),Maybe Int)], Int, ((Char,Char),[(Char,Int)]))
lx__19_0 = (True,[(9,"jlString",[],Nothing,Nothing)],19,(('\t','='),[('\t',-1),('\n',-1),('\v',-1),('\f',-1),('\r',-1),(' ',-1),(':',-1),('=',-1)]))

