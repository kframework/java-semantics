pushFrame(newMeth, args) = do               
  stack    := stack ++ [(pc,reg,opd,meth)]
  meth     := newMeth
  pc       := 0
  opd      := []
  reg      := makeRegs(args) 

vmeth :: MRef
vmeth = top(verifyMeths)           

addOffset :: [a] -> [(Nat,a)]
addOffset xs = zip [0..] xs

isTrustful  = False
isDefensive = False
isDiligent  = True

typeOf :: Ref -> VerifyType
typeOf(r) = 
   if (r== 0 ) then conv(VTNull)
   else case heap(r) of            
          String(str)         -> conv(VTClass(string ))
          Array(t,vs)         -> conv(VTArray(typeTJVT(t)))
          JVMObject(c,fields) -> conv(VTClass(c))

typeOfWord :: Word -> VerifyType
typeOfWord(0,WTReference) = conv(VTNull)
typeOfWord(_,t) = typeWTVT(t)

localTypes :: Register(Word) -> Register(VerifyType)
localTypes = error "unexpected call to localTypes"

