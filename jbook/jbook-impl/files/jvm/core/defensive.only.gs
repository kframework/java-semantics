typeOfWord :: Word -> VerifyType
typeOfWord(r,WTReference) = conv(typeOf(r))           
typeOfWord(_,t)           = typeWTVT(t)

pushFrame :: (MRef, Args) -> Rule ()
pushFrame(c:/m, args) = do               
  stack    := stack ++ [(pc,reg,opd,meth)]
  meth     := c:/m
  pc       := 0
  opd      := []
  reg      := makeRegs(args) 
  if mNm(m) == "<init>" then do
    let  r  :  _   = args
    if c == object  then
      initState(conv(r)) := Complete
     else
      initState(conv(r)) := InInit
   else skip 

typeOf :: Ref -> VerifyType
typeOf(r) = 
   if (r== 0 ) then conv(VTNull)
   else case heap(r) of            
         String(str)         -> conv(VTClass(string ))

         Array(t,vs)         -> conv(VTArray(typeTJVT(t)))

         JVMObject(c,fields) -> case initState(r) of
                                 InitNew(pc)   -> VTNew(c,pc)
                                 InInit        -> VTInit
                                 Complete      -> conv(VTClass(c))  

isTrustful  = False
isDefensive = True
isDiligent  = False

localTypes :: Register(Word) -> Register(VerifyType)
localTypes = setmap f
   where f (i,w) = (i,typeOfWord(w))

