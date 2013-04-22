javaFieldType :: FRef -> JavaType
javaFieldType (c :/ f) = 
    case [ t | CFile(_, _, _, _, _, _, fields, _) = cEnv(c)
             , (f',FDec(_, t)) <-: fields
             , f' == f
         ] of
     [ t ] -> t
     _     -> error ("no field " ++ showFRef (c:/f) "")

instance Types FRef where
   types = typeTJVT . javaFieldType

-- size of a field
        
-- default value of a field
instance Dflt (FRef) where
  dflt(c :/ f) = dflt(t)
    where CFile(_, _, _, _, _, _, fields, _) = cEnv(c)
          FDec(_, t)  = fields # f


-- argument sizes of a method
instance Argsize (Combine a MSig) where
  argSizes(c :/ (m,ts)) = [size t | t <- ts]


instance ArgTypes (Combine CNm MSig) where
  argTypes(_ :/ (m, ts)) = concat (map typeTJVT ts)



instance RetType Fun where
  returnType = snd . funSig

instance RetType PrimOp where
  returnType (PrimFun(f)) = returnType(f)
  returnType (PrimLdc(v)) = types(v)

javaReturnType :: MRef -> JavaType
javaReturnType(c:/m) = let mths = methods(cEnv(c))
                           ok   = m `elem` mdomain(mths)
                           MDec(_, t, _, _, _) = mths  # m
                       in if ok then t
                           else error ("no method " ++
                                shows (c:/m) "")


instance RetType (MRef) where
  returnType = typeTJVT . javaReturnType

-- --------------------------------------------------------------------
-- Determine all referenced classes


references :: Class -> {Class}
references (c) = 
   mkSet (map snd (cReferences(c)))

directReferences :: Class -> {Class}
directReferences(c) = 
   mkSet [ c' | (ctx,c') <- cReferences(c), ctx == c]

-- -----------------------------------------------------------------------
-- Loading Classes

locateClassfile :: (ClassPath,CNm) -> Rule (Maybe PathName)
locateClassfile (classPath,cn) = do
     es <- binds [ classfileExists (p ++ cn ++ ".j") 
                 | p <-: classPath ]
     if or(es) then
       result . Just . snd . head . dropWhile ((==False) . fst) 
          $ zip es (expr2list(classPath))
      else
       result Nothing

locateFile :: (ClassPath,String) -> Rule (Maybe PathName)
locateFile (classPath,cn) = do
     es <- binds [ classfileExists (p ++ cn) 
                 | p <-: classPath ]
     if or(es) then
       result . Just . snd . head . dropWhile ((==False) . fst) 
          $ zip es (expr2list(classPath))
      else
       result Nothing

classfileExists :: String -> Rule Bool
classfileExists filename = Rule $
     do res <- primExecuteTcl ("file exists " ++ tk_secure filename)
        result (res == "1")

load :: (Class,String) -> Rule (Maybe ClassFile)
load ((ld,_),filename) =
  case parse' (ld, filename, openfile filename) of
   Error s -> do Rule (putStrLn ("file " ++ filename ++ ": " ++ s))
                 result(Nothing)
   Ok a    -> result(Just(a))

getFilepath :: PathName -> PathName
getFilepath (xs) = 
   let r = foldl (\xs c -> if c=='/' then "" else c:xs) [] xs
       l = take (max 0 $ length xs - length r) xs
   in l


-- ------------------------------------------------------------------------
-- Substitution

class Substitute a b where
   substitute :: Eq b => (a,b,b) -> a


instance (Substitute b a, Ord b) => Substitute {b} a where
   substitute (ts,x,s) = { substitute(t,x,s) | t <-: ts }

instance Substitute b c => Substitute (a,b) c where
   substitute ((l,r),x,s) = (l,substitute(r,x,s))

instance Substitute VerifyType VerifyType where
   substitute (t,x,s) = if t == x then s else t

instance Substitute b a => Substitute [b] a where
   substitute (ts,x,s) = [ substitute(t,x,s) | t <- ts ]


-- -----------------------------------------------------------------------
-- Exception Handling

allhandlers :: (Instr,MRef, Pc, Register(VerifyType))
                  -> {(Pc, Register(VerifyType), Opd(VerifyType))}
allhandlers(Jsr(_),_,_,_)    = {}
allhandlers(Goto(_),_,_,_)   = {}
allhandlers(Return(_),_,_,_) = {}
allhandlers(Load(_,_),_,_,_) = {}
allhandlers (_, m, pc, tr) = mkSet
                          ( map merge
                          . groupBy (\x1 x2 -> fst x1 == fst x2)
                          $ handlers)
 where handlers  = [ (h, VTClass(t))
                   | Exc(f, u, h, t) <- excs(m), f <= pc && pc < u 
                   ]
       merge([x]) = (fst x, tr, [VTReference(snd x)])
       merge(xs)  = (fst(head(xs)), tr, 
                     [VTReferenceSet({ x | (_,x) <- xs})])


removeUnitializedInOpd :: Opd(VerifyType) -> Opd(VerifyType)
removeUnitializedInOpd(opd) = map f opd
 where f VTInit       = VTUnusable
       f (VTNew(_,_)) = VTUnusable
       f t            = t

removeUnitializedInReg :: Register(VerifyType) -> Register(VerifyType)
removeUnitializedInReg(regs) = 
   { x | x@(_,t) <-: regs, f t }
 where f VTInit       = False
       f (VTNew(_,_)) = False
       f _            = True

removeRefSet :: VerifyType -> VerifyType
removeRefSet(VTReferenceSet(Set [x])) = VTReference(x)
removeRefSet(x)                       = x


mSigInfo = id

pcsMods :: ([(Pc,{Int})],{Pc}) -> {Int}
pcsMods(imods,pcs) = pcsMods'(imods,expr2list pcs)
  where pcsMods'((i,mods):imods,pcs@(j:pcs'))
                      | i==j      = mods `union` pcsMods'(imods,pcs')
                      | otherwise = pcsMods'(imods,pcs)
        pcsMods'([],_) = {}
        pcsMods'(_,[]) = {}

containedIn :: Map Pc {Pc} -> Pc -> [Pc]
containedIn(belongsTo) =
 mapToListFun ({ (i,s) | (s,pcs) <-: belongsTo, i <-: pcs })

mapToListFun :: (Eq a, Ord a) => {(a,a)} -> a -> [a]
mapToListFun(ls) = 
  let m = mapping (f (expr2list ls))
      f []             = []
      f (is@((i,s):_)) = let (ls,rs) = break ((/=i).fst) is
                         in (i,nub(map snd ls)) : f rs
  in \a -> case maplookup m a of
              Just xs -> xs
              Nothing -> []
