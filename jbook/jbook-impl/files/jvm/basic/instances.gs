instance AsmTerm MoveType
instance AsmTerm ArrayMoveType
instance AsmTerm WordType
instance AsmTerm VerifyType
instance AsmTerm Class
instance AsmTerm VTRefType
instance AsmTerm ClassFile 
instance AsmTerm MDec
instance AsmTerm FDec
instance AsmTerm Instr
instance AsmTerm JVMHeap
instance AsmTerm JVMClassState
instance AsmTerm JvmFrame
instance AsmTerm MRef
instance AsmTerm FRef
instance AsmTerm Switch
instance AsmTerm InitState where
  asmDefault = Complete

instance Eq ClassFile where
  CFile(c1,b1,mods1,super1,_,ifaces1,fields1,meths1) == 
   CFile(c2,b2,mods2,super2,_,ifaces2,fields2,meths2) =
    (c1 == c2) &&
    (b1 == b2) &&
    (mods1 == mods2) &&
    (super1 `genericEq` super2) &&
    (ifaces1 `genericEq` ifaces2) &&
    (fields1 `genericEq` fields2) &&
    (meths1  `genericEq` meths2)

--------------------------------------------------------------------------

instance Conv (Class, Pc) Class where
  conv(c,_) = c

instance Conv VTRefType VerifyType where
  conv = VTReference

instance Conv Word Int where
  conv(i,_) = i

instance Conv Word Bool where
  conv(0,WTInt) = False
  conv(_,WTInt) = True
  conv(_,_)     = error "conv Word Bool: not a bool"

instance Conv Word Char where
  conv(i,WTInt) = chr(i)
  conv(_,_)     = error "conv Word Char: not a char"

instance Conv Word Float where
  conv(i,WTFloat) = i2f(i)
  conv(i,WTLowDouble) = i2f(i)
  conv(i,_) = error "conv Word Float: not a float"

instance Conv WordType ValType where
  conv(x) = [x]

instance Conv Word Val where
  conv(x) = [x]


instance Conv Bool Word where
  conv(True)  = (1,WTInt)
  conv(False) = (0,WTInt)

instance Conv Bool Val where
  conv(b) = [conv(b)]

instance Conv Int Word where
  conv(i) = (i, WTInt)

instance Conv Int Val where
  conv(i) = [conv(i)]

instance Conv Long Val where
  conv(Long(l)) = [ (l,WTLowLong), (0,WTHighLong) ]
  conv(_)       = error "conv"

instance Conv Double Val where
  conv(Double(d)) = [ (f2i(d),WTLowDouble), (0,WTHighDouble) ]
  conv(_)       = error "conv"

instance Conv Float Word where
  conv(f) = (f2i(f), WTFloat)

instance Conv Float Int where
  conv(f) = f2i(f)

instance Conv (Int,a) Int where
  conv(x) = fst(x)

instance Conv Val Int where
  conv([x]) = fst(x)
  conv(x)   = error "conv: Val Int"

instance Conv Val Bool where
  conv(x) = conv(x) /= 0

instance Conv PrimOp String where
  conv(PrimFun(s)) = s
  conv(PrimLdc(v)) = "Ldc"
  conv(_)          = error "Conv Prim String"


---------------------------------------------------------------------------


instance UndefValue MDec where
  undefValue = error "select (#) failed: Type MDec"

instance UndefValue FDec where
  undefValue = error "select (#) failed: Type FDec"

instance UndefValue Word where
  undefValue = error "undefValue: Word"

instance UndefValue VerifyType where
  undefValue = VTUnusable

instance UndefValue String where
  undefValue = error "select (#) failed: Type String"

instance UndefValue Class where
  undefValue = error "select (#) failed: Type Class"

instance UndefValue Int where
  undefValue = error "select (#) failed: Type Int"

instance UndefValue [RegNo] where
  undefValue = []

instance UndefValue {RegNo} where
  undefValue = error "undefValue {LNum}"

instance UndefValue [a] where
  undefValue = error "undefValue [a]"

---------------------------------------------------------------------------


instance Dflt JavaType where
  dflt (TJRef(_)) = [(0,WTReference)]
  dflt (TJDouble) = [(0,WTLowDouble),(0,WTHighDouble)]
  dflt (TJLong)   = [(0,WTLowLong),(0,WTHighLong)]
  dflt (_)        = [(0,WTInt)]

---------------------------------------------------------------------------

instance SizeOf MoveType where
  size(MTInt)    = 1
  size(MTFloat)  = 1
  size(MTAddr)   = 1
  size(MTLong)   = 2
  size(MTDouble) = 2
  size(MTvoid)   = 0
  size(x)  = error ("unknown type " ++ show x)

instance SizeOf ArrayMoveType where
  size(AMTLong)   = 2
  size(AMTDouble) = 2
  size(_)         = 1

instance SizeOf JavaType where
  size(TJVoid)   = 0
  size(TJDouble) = 2
  size(TJLong)   = 2
  size(_)        = 1

instance SizeOf WordType where
  size(_)  = 1

instance SizeOf Word where
  size(_) = 1

instance SizeOf a => SizeOf (Maybe a) where
  size(Nothing)  = 0
  size(Just( a)) = size(a)

instance SizeOf a => SizeOf [a] where
  size(xs) = sum(map size xs)

---------------------------------------------------------------------------

javaMethTypes :: MRef -> [JavaType]
javaMethTypes (_ :/ (m, ts)) = ts

instance ArgTypes MRef where
  argTypes = concat . map typeTJVT . javaMethTypes


---------------------------------------------------------------------------

instance CMeth (Combine a MSig) where
  mSig (_ :/ sig) = sig

instance CMeth (MSig, MDec) where
  mSig (sig,_) = sig

instance CMeth MSig where
  mSig = id

--------------------------------------------------------------------------

instance ClassName CNm where
  cNm = id

instance ClassName Class where
  cNm (_,n) = n

instance ClassName a => ClassName (Combine a FNm) where
  cNm (n :/ _) = cNm(n)


instance ClassName a => ClassName (Combine a MSig) where
  cNm (n :/ _) = cNm(n)

instance ClassName ClassFile where
  cNm (CFile(n, _, _, _, _, _, _,_)) = cNm(n)

instance ClassName (Ld, ClassFile) where
  cNm (_,cf) = cNm(cf)

clName :: Combine Class a -> Class
clName (c:/_) = c

---------------------------------------------------------------------------

instance ClassLoader Class where
  cLd = fst

instance ClassLoader MRef where
  cLd (c :/ m) = cLd (c)

--------------------------------------------------------------------------

instance Text Modifier where
  showsPrec _ Public       = showString "public"
  showsPrec _ Private      = showString "private"
  showsPrec _ Protected    = showString "protected"
  showsPrec _ Static       = showString "static"
  showsPrec _ Final        = showString "final"
  showsPrec _ Synchronized = showString "synchronized"
  showsPrec _ Volatile     = showString "volatile"
  showsPrec _ Transient    = showString "transient"
  showsPrec _ Native       = showString "native"
  showsPrec _ Abstract     = showString "abstract"

instance Text MoveType where
  showsPrec _ MTInt        = showString "i"
  showsPrec _ MTFloat      = showString "f"
  showsPrec _ MTAddr       = showString "a"
  showsPrec _ MTDouble     = showString "d"
  showsPrec _ MTLong       = showString "l"
  showsPrec _ MTvoid       = id
  showsPrec _ e = error "instance Text MoveType"

instance Text ArrayMoveType where
  showsPrec _ AMTByte       = showString "b"
  showsPrec _ AMTShort      = showString "s"
  showsPrec _ AMTChar       = showString "c"
  showsPrec _ AMTInt        = showString "i"
  showsPrec _ AMTFloat      = showString "f"
  showsPrec _ AMTObject     = showString "a"
  showsPrec _ AMTDouble     = showString "d"
  showsPrec _ AMTLong       = showString "l"
  showsPrec _ e = error "instance Text ArrayMoveType"

instance Text WordType where
  showsPrec _ WTInt      = showString "I"
  showsPrec _ WTFloat    = showString "F"
  showsPrec _ WTLowDouble    = showString "low double"
  showsPrec _ WTHighDouble   = showString "high double"
  showsPrec _ WTLowLong      = showString "low long"
  showsPrec _ WTHighLong     = showString "high long"
  showsPrec _ WTReference    = showString "reference"
  showsPrec _ (WTRetAddr(pc)) = showString "retAddr("
                              . shows pc . showString ")"
  showsPrec _ x         = error ("Text WordType: " ++ primPrint 0 x "")

instance Text ValType where
  showsPrec _ [x]                         = shows x
  showsPrec _ [WTLowLong, WTHighLong]     = showString "long"
  showsPrec _ [WTLowDouble, WTHighDouble] = showString "double"
  showsPrec _ []                        = showString "void"
  showsPrec _ e = error ("showsPrec: ValType (" ++ primPrint 0 e ")")

instance Text [VerifyType] where
  showsPrec _ [x]                         = shows x
  showsPrec _ [VTLowLong, VTHighLong]     = showString "long"
  showsPrec _ [VTLowDouble, VTHighDouble] = showString "double"
  showsPrec _ []                          = showString "void"
  showsPrec _ e = error ("showsPrec: [VerifyType] (" ++ primPrint 0 e ")")

instance Text VTRefType where
  showsPrec _ VTNull        = showString "null"
  showsPrec _ (VTClass(c))  = showString (snd(c)) 
  showsPrec _ (VTArray(ts)) = shows ts . showString "[]"
  showsPrec _ (VTAddr)      = showString "addr"
  showsPrec _ x             = error ("Text RefType: " ++ primPrint 0 x "")

instance Text VerifyType where
  showsPrec _ VTInt            = showString "int"
  showsPrec _ VTFloat          = showString "float"
  showsPrec _ VTLowDouble      = showString "low double"
  showsPrec _ VTHighDouble     = showString "high double"
  showsPrec _ VTLowLong        = showString "low long"
  showsPrec _ VTHighLong       = showString "high long"
  showsPrec _ (VTReference(r)) = shows r
  showsPrec _ (VTReferenceSet(rs)) = shows rs
  showsPrec _ (VTRetAddr(pc))  = showString "retAddr "
                               . shows pc
  showsPrec _ (VTNew(c,pc))    = showString "New(" . shows c 
                               . showString ", " . shows pc
                               . showString ")"
  showsPrec _ VTInit           = showString "InInit"
  showsPrec _ VTUnusable       = showString "unusable"
  showsPrec _ x         = error ("Text VerifyType: " ++ primPrint 0 x "")



instance Text (Map FNm FDec) where
  showsPrec _ es =  showString (concat[cnl : show e | e <-: es])

instance Text (FNm, FDec) where
  showsPrec _ (fn, FDec(ar,t)) =
    showString ".field " .
    showString (if Static `elem` ar then "static " else "") .
    showString fn . showString " " .
    shows t . showString "\n"

instance Text Exc where
  showsPrec _ (Exc(from, upto, handle, t)) =  
      showsPrec 0 (from,upto,handle,t)

instance Text [Exc] where
  showsPrec _ es =  showString (concat[cnl : show e | e <- es])

instance Text [Instr] where
  showsPrec _ es =  showString (concat[cnl : show e | e <- es])

instance Text (Map MNm MDec) where
  showsPrec _ es =  showString (concat [cnl : show e | e <-: es])

showFRef :: FRef -> ShowS
showFRef (c :/ fn) = showClassName c . showString "." . showString fn


instance Text MRef  where
  showsPrec _ (c :/ (mn,sig))  
      = showClassName c . showString "." . showString mn
      . showString "(" . showSepBy' ", " (map shows sig)
      . showString ")"

showSepBy' :: String -> [ShowS] -> ShowS
showSepBy' _ []       = id
showSepBy' _ [x]      = x
showSepBy' sep (x:xs) = x . showString sep . showSepBy' sep xs

instance Text Val where
  showsPrec _ [(i,WTInt)]       = shows i
  showsPrec _ [w@(i,WTFloat)]   = shows (i2f(i))
  showsPrec _ [(i,WTLowLong),(0,WTHighLong)]
                                = shows i
  showsPrec _ [(i,WTLowDouble),(0,WTHighDouble)]
                                = shows (i2f(i))
  showsPrec _ [(0,WTReference)] = showString "null"
  showsPrec _ [(r,WTReference)] = showString "heap(" . shows r . showString ")"
  showsPrec _ []             = id
  showsPrec _ x              = error ("Text Val: " ++ primPrint 0 x "")

-------------------------------------------------------------------------

instance Ord JVMClassState where
  Loaded       < Loaded       = False
  Loaded       < _            = True
  SupersLoaded < Loaded       = False
  SupersLoaded < SupersLoaded = False
  SupersLoaded < _            = True
  Referenced < Linked      = True
  Referenced < Initialized = True
  Referenced < Unusable    = True
  Linked < Initialized     = True
  Linked < Unusable        = True
  _ < _                    = False
  a <= b                   = a < b || a == b

instance Ord WordType where
  a <  b = genericCmp a b <  0
  a <= b = genericCmp a b <= 0
  a >  b = genericCmp a b >  0
  a >= b = genericCmp a b >= 0

instance Ord VerifyType where
  a <  b = genericCmp a b <  0
  a <= b = genericCmp a b <= 0
  a >  b = genericCmp a b >  0
  a >= b = genericCmp a b >= 0

instance Ord VTRefType where
  a <  b = genericCmp a b <  0
  a <= b = genericCmp a b <= 0
  a >  b = genericCmp a b >  0
  a >= b = genericCmp a b >= 0


instance Ord Modifier where
  a <  b = genericCmp a b <  0
  a <= b = genericCmp a b <= 0
  a >  b = genericCmp a b >  0
  a >= b = genericCmp a b >= 0

instance Ord FDec where
  a <  b = genericCmp a b <  0
  a <= b = genericCmp a b <= 0
  a >  b = genericCmp a b >  0
  a >= b = genericCmp a b >= 0

instance Ord MDec where
  a <  b = genericCmp a b <  0
  a <= b = genericCmp a b <= 0
  a >  b = genericCmp a b >  0
  a >= b = genericCmp a b >= 0

instance Ord Instr where
  a <  b = genericCmp a b <  0
  a <= b = genericCmp a b <= 0
  a >  b = genericCmp a b >  0
  a >= b = genericCmp a b >= 0

instance Ord (a,b,c,d) where
  a <  b = genericCmp a b <  0
  a <= b = genericCmp a b <= 0
  a >  b = genericCmp a b >  0
  a >= b = genericCmp a b >= 0
  


--------------------------------------------------------------------------

instance (Eq a, Eq b) => Eq (Combine a b) where
  (a1 :/ b1) == (a2 :/ b2) = a1 == a2 && b1 == b2

instance Eq Instr where
  (==) =  genericEq

instance Eq (Maybe ClassFile) where
  (==) = genericEq

instance Eq (FNm,FDec) where
  (==) = genericEq

--------------------------------------------------------------------------

instance Num Word where
   (i,WTInt)       + (j,WTInt)       = (i+j,WTInt)
   (i,WTFloat)     + (j,WTFloat)     = (f2i(i2f(i)+i2f(j)),WTFloat)
   (i,WTLowDouble) + (j,WTLowDouble) = (f2i(i2f(i)+i2f(j)),WTLowDouble)
   (i,WTLowLong)   + (j,WTLowLong)   = (i+j,WTLowLong)

   (i,WTInt)       * (j,WTInt)       = (i*j,WTInt)
   (i,WTFloat)     * (j,WTFloat)     = (f2i(i2f(i)*i2f(j)),WTFloat)
   (i,WTLowDouble) * (j,WTLowDouble) = (f2i(i2f(i)*i2f(j)),WTLowDouble)
   (i,WTLowLong)   * (j,WTLowLong)   = (i*j,WTLowLong)

   (i,WTInt)       - (j,WTInt)       = (i-j,WTInt)
   (i,WTFloat)     - (j,WTFloat)     = (f2i(i2f(i)-i2f(j)),WTFloat)
   (i,WTLowDouble) - (j,WTLowDouble) = (f2i(i2f(i)-i2f(j)),WTLowDouble)
   (i,WTLowLong)   - (j,WTLowLong)   = (i-j,WTLowLong)

   (i,WTInt)       / (j,WTInt)       = (i/j,WTInt)
   (i,WTFloat)     / (j,WTFloat)     = (f2i(i2f(i)/i2f(j)),WTFloat)
   (i,WTLowDouble) / (j,WTLowDouble) = (f2i(i2f(i)/i2f(j)),WTLowDouble)
   (i,WTLowLong)   / (j,WTLowLong)   = (i/j,WTLowLong)

   negate (i,WTInt)       = (negate i,WTInt)
   negate (i,WTFloat)     = (f2i(negate(i2f(i))),WTFloat)
   negate (i,WTLowDouble) = (f2i(negate(i2f(i))),WTLowDouble)
   negate (i,WTLowLong)   = (negate i,WTLowLong)

   fromInteger _ = error "fromInteger not defined (Word(w))"

-------------------------------------------------------------------------


i2f :: Int -> Float
i2f(i) = typeCast (i) :: Float

f2i :: Float -> Int
f2i(f) = typeCast (f) :: Int


       
