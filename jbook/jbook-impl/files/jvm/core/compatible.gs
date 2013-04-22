infix 4 `runCompatible`
infix 4 `typeMerge`

VTNull        `runCompatibleRefTypeRefType` VTNull       = True
VTNull        `runCompatibleRefTypeRefType` VTClass(c)   = True  

VTNull        `runCompatibleRefTypeRefType` VTArray(_)    = True
VTArray(xs)   `runCompatibleRefTypeRefType` VTArray(ys)   
                = (isVTReference(xs) && isVTReference(ys) &&
                                              xs `listCompatible` ys) ||
                   xs == ys
VTArray(_)    `runCompatibleRefTypeRefType` VTClass(c)     
                                              = (c == object )
VTArray(_)    `runCompatibleRefTypeRefType` VTClass(c)     
                                              = (c == cloneable )
VTClass(c) `runCompatibleRefTypeRefType` VTClass(d)  
                                              = c `runCompatible` d
_ `runCompatibleRefTypeRefType` VTAddr = True
_ `runCompatibleRefTypeRefType` _      = False
VTInit        `runCompatibleVerifyTypeVerifyType` VTInit        = True
_        `runCompatibleVerifyTypeVerifyType` VTUnusable   = True
t1   `runCompatibleVerifyTypeVerifyType` t2   = t1 == t2

isVTReference :: [VerifyType] -> Bool
isVTReference([VTReference(_)])    = True
isVTReference([VTReferenceSet(_)]) = True
isVTReference(_)                   = False

[VTReference(c)]   `runCompatibleVerifyTypeMTAddr` MTAddr   = True
[VTNew(_,_)]       `runCompatibleVerifyTypeMTAddr` MTAddr   = True
[VTInit]           `runCompatibleVerifyTypeMTAddr` MTAddr   = True  

[VTReferenceSet(_)] `runCompatibleVerifyTypeMTAddr` MTAddr = True
_ `runCompatibleVerifyTypeMTAddr` _ = False

regCompatible    :: (Compatible a a, Ord a, UndefValue a) => 
                           Register(a) -> Register(a) -> Bool 
regS `regCompatible` regT =  
     (all (\( x ) ->  regS#(x) `runCompatible` regT#(x) ) ( mdomain( regT )  ))   

listCompatible    :: Compatible a b => [a] -> [b] -> Bool
xs `listCompatible` ys = (length(xs) == length(ys)) &&  
                           (all (\( (x,y) ) ->   x `runCompatible` y ) ( (zip ( xs ) ( ys ))  ))   

t1 `typeMergePrimitive` t2 = if t1 == t2 then t1 else VTUnusable  

opdMerge  :: [VerifyType] -> [VerifyType] -> [VerifyType]
opdS `opdMerge` opdV = [ s `typeMerge` v | (s,v) <- (zip ( opdS ) ( opdV ))  ]  

regMerge  :: Register(VerifyType) -> Register(VerifyType)
            -> Register(VerifyType) 
regS `regMerge` regT = { (x,t) | (x,t) <-: regs, t /= VTUnusable }             
  where regs = { (x,regS#(x) `typeMerge` regT#(x)) |  
                           x <-: mdomain( regS )  `intersect` mdomain( regT )  }

typeMerge :: VerifyType -> VerifyType -> VerifyType
VTReferenceSet(rs1) `typeMerge` VTReferenceSet(rs2) =                  
            removeRefSet(VTReferenceSet(rs1 `union` rs2))

VTReference(l) `typeMerge` VTReference(r) =  
            removeRefSet(VTReferenceSet({l,r}))
VTReference(l) `typeMerge` VTReferenceSet(rs) =  
            removeRefSet(VTReferenceSet({l} `union` rs))
VTReferenceSet(ls) `typeMerge` VTReference(r) =  
            removeRefSet(VTReferenceSet(ls `union` {r}))
t1 `typeMerge` t2 = t1 `typeMergePrimitive` t2

handler :: (MRef, Pc, Class) -> Exc                    
handler(m, pc, c)  = e             
   where  e  :  _   = [ e | e <- excs(m), match(m, pc, c, e) ]
escapes :: (MRef, Pc, Class) -> Bool
escapes(m, pc, c)  = (not (any (\ e  ->   match(m, pc, c, e) ) (  excs(m) )))   

match :: (MRef, Pc, Class, Exc) -> Bool
match(m, pc, c, Exc(f, u, h, t)) = f <= pc && pc < u &&  
                                   c `runCompatibleClassClass` t  

validTypeSeq :: [VerifyType] -> Bool
validTypeSeq([])       = True                   
validTypeSeq([t])      = not( isHigh(t) ) 
validTypeSeq([t,_])    = not( isHigh(t) )   
validTypeSeq(_) = False

isHigh(t) = (t == VTHighLong || t == VTHighDouble)            
    || t == VTUnusable

[] `runCompatibleVerifyTypeMoveType` MTvoid = True  

[VTInt]            `runCompatibleVerifyTypeMoveType` MTInt   = True  

[VTFloat]          `runCompatibleVerifyTypeMoveType` MTFloat    = True
[VTLowLong, VTHighLong]       `runCompatibleVerifyTypeMoveType` MTLong  
                                      = True
[VTLowDouble, VTHighDouble]   `runCompatibleVerifyTypeMoveType` MTDouble  
                                      = True 
t `runCompatibleVerifyTypeMoveType` MTAddr =  
                       t `runCompatibleVerifyTypeMTAddr` MTAddr
_ `runCompatibleVerifyTypeMoveType` _  = False

class Compatible a b where
  runCompatible    :: a -> b -> Bool

instance Compatible WordType VerifyType where
  runCompatible t1 t2 = runCompatible (typeWTVT(t1)) t2

instance Compatible VerifyType VerifyType where
  runCompatible (VTReference(_))     (VTReference(VTAddr)) = True
  runCompatible (VTNew(_,_))         (VTReference(VTAddr)) = True
  runCompatible (VTInit)             (VTReference(VTAddr)) = True
  runCompatible (VTReferenceSet(_))  (VTReference(VTAddr)) = True
  runCompatible (VTReference(r1)) (VTReference(r2))     = 
      runCompatible r1 r2
  runCompatible (VTReferenceSet(ls)) (VTReference(r)) =
     (all (\( l ) ->   l `runCompatible` r ) ( ls )) 
  runCompatible (VTReference(l)) (VTReferenceSet(rs)) =
     (any (\ r  ->  l `runCompatible` r ) ( rs )) 
  runCompatible (VTReferenceSet(ls)) (VTReferenceSet(rs)) =
     (all (\( l ) ->   (any (\ r  ->  l `runCompatible` r ) ( rs ))  ) ( ls )) 
  runCompatible t1 t2 = runCompatibleVerifyTypeVerifyType t1 t2

instance Compatible VTRefType VTRefType where
  runCompatible = runCompatibleRefTypeRefType

instance Compatible Class Class where
  runCompatible = runCompatibleClassClass

instance Compatible Class VerifyType where
   c `runCompatible` w = VTReference(VTClass(c)) `runCompatible` w

instance Compatible [VerifyType] MoveType where
  runCompatible = runCompatibleVerifyTypeMoveType

instance HasSuffix a [VerifyType] => HasSuffix a JavaType where
  a `hasSuffix` jt = a `hasSuffix` typeTJVT(jt)

instance Compatible [a] MoveType => HasSuffix [a] MoveType where
 hasSuffix = hasSuffixLaMoveType

instance Compatible a b => HasSuffix [a] [b] where
 hasSuffix = hasSuffixLaLb

runCompatibleClassClass :: Class -> Class -> Bool
c `runCompatibleClassClass` d = 
    c /= object  && just( super(c) )  `runCompatibleClassClass` d ||
    c == d || (any (\ i  ->  i `runCompatibleClassClass` d ) ( implements(c) )) 

as `hasSuffixLaMoveType` t = length(as) >= size(t) &&  
                             takeTop(as,size(t)) `runCompatible` t

as `hasSuffixLaLb` bs =  
         bs__l <= as__l &&                  
            (all (\( (a,b) ) ->   a `runCompatible` b ) (  (zip ( takeTop(as,bs__l) ) (  bs ))  )) 
         where as__l = length(as)
               bs__l = length(bs) 

overrideMethods :: MRef -> SuperSigs
overrideMethods(c:/msig) = [ x | x@(c':/sig,(_,mods)) <- superSigs(cEnv(c))
                                , (sig == msig) && accessible(c,(c',mods)) ]

class Accessible c where
  accessible :: (Class, c) -> Bool                

instance Accessible Class where
  accessible (c,c') = accessible(c,(c',modifiers(c')))

instance Accessible JavaType where
  accessible(ctx,TJRef(c))   = accessible(ctx,c)
  accessible(ctx,TJArray(t)) = accessible(ctx,t)
  accessible(ctx,_)          = True

instance Accessible (Combine Class a,(String,b)) where
  accessible (c,(c':/_,(msig,_))) = accessible(c,c') && 
     case maplookup (simpleSigs(cEnv(c'))) msig of
       Nothing      -> False
       Just (rt,ms) -> accessible(c,(c',ms))

instance Accessible (Class,{Modifier}) where
  accessible (c,(c',mods)) =
     definedIn(c',c) ||
     Public `elem` mods ||
     Private `notElem` mods && (cLd(c) == cLd(c')) ||
     Private `elem` mods && (c == c') ||
     Protected `elem` mods && c `runCompatible` c'

