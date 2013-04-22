loadClasses :: ({Class},Rule ()) -> Rule ()
loadClasses(cs,m) =                 
  chooseIfNone c <-: cs `difference` dom(ldEnv) do
    callLoad(c)
  ifnone
    chooseIfNone c <-: cs, classState(liftClass(c))==Loaded do
      loadSuperClasses(liftClass(c))
    ifnone m

loadSuperClasses :: Class -> Rule ()
loadSuperClasses(c) =                      
  loadClasses({just( super(c) )  } `union` implements(c),setSupersLoaded(c))

loadReferences :: Class -> Rule ()
loadReferences(c) =                    
  loadClasses(directReferences(c),loadIndirectReferences(c))

setSupersLoaded(c) = do                     
  classState(c) := SupersLoaded
  setDefiningLoadersForSupers(c)

loadIndirectReferences(c) = do                            
  loadClasses(indirectReferences(c),setReferenced(c))

setReferenced(c) = do                   
  classState(c) := Referenced
  setDefiningLoaders(c)

execClassLoader (m) = do                     
   if m == findLoadedClass  then
         let c = (conv(reg#(0)), stringOf(conv(reg#(1)))) in 
         if ( c ) `notInDom`   ldEnv    then
           switch := Result([setReferenceType(0 )])
         else 
           switch := Result([setReferenceType(ldEnv(c))])
    else skip 
   if m == findSystemClass  then do
          let c = (sysLd, stringOf(conv(reg#(1))))
          if ( c ) `notInDom`  ldEnv   then
            loadClass(classPath,c)
           else if  classState(c) < Referenced then
              referenceClass(c)
           else if  classState(c) == Referenced then
              linkClass(c)
           else
              switch := Result([setReferenceType(ldEnv(c))])
     else skip 
   if m == defineClassMethod  then do
          let c = (conv(reg#(0)),stringOf(conv(reg#(1))))
          if ( c ) `notInDom`  ldEnv   then do
            let content = fileContent(heap(conv(reg#(2))),reg#(3),reg#(4))
            defineClass(content,c,True)
           else
             raise("ClassFormatError")
    else skip 
   if m == resolveClass  then do
          let r = conv(reg#(1))
          if r == 0  then
            raise("NullPointerException")
           else
            let c = cOf(r) in 
            if classState(c) < Referenced then
              referenceClass(c)
            else if  classState(c) == Referenced then
              linkClass(c)
            else
              switch := Result([])
     else skip 

   if m == getSystemClassLoader then do
     switch := Result([setReferenceType(sysLd)])
    else skip 

loadClass :: (ClassPath, Class) -> Rule ()
loadClass(classPath, c) = do               

   path <- locateClassfile(classPath,cNm(c))
   case path of
    Nothing -> raiseString("ClassNotFoundException",cNm(c))
    Just(path) -> do
     defineClass(path++cNm(c)++".j",c,False)

defineClass :: (String, Class, Bool) -> Rule ()
defineClass(content, c, returnClass) = do                 

   rlet cf ::= load(c,content)
   if (cf == Nothing || cNm(just( cf ) ) /= cNm(c)) then
      raise("ClassFormatError")
    else do
     newClassLoaded := True
     create r do

         classState(c)    := Loaded
         heap(r)      := JVMObject(cclass ,(Set []) )
         cOf(r)       := c
         cEnv(c)      := just( cf ) 
         cReferences(c) := ctxReferences c (just( cf ) )
         ldEnv(c)     := r 
         if returnClass then switch := Result([setReferenceType(r)]) else skip 

initializeDynamicLoading(classes) =                              
  forall c <- classes do
    create r do
     heap(r)    := JVMObject(cclass , (Set []) )
     cOf(r)     := c
     ldEnv(c)   := r 

referenceClass :: Class -> Rule ()
referenceClass (c) =                    
  if c == object  then
    classState(c) := Referenced
  else if  classState(c) == SupersLoaded then    
    let supers = { just( super(c) )  } `union` implements(c) in 
    chooseIfNone c' <-: supers, classState(c')<Referenced do
      referenceClass(c')
    ifnone
      loadReferences(c)
  else loadSuperClasses(c)
execVM__D = do               
  execVM__N
  if c == classLoader  then 
    execClassLoader(m)
   else if  meth == cclass  :/ newInstance  then
    meth := cOf(conv(reg#(0))):/ builtinNewInstance 
   else skip 
 where c:/m = meth

indirectReferences :: Class -> {Class}
indirectReferences(c) = 
   { (cLd(liftClass(ctx)),cNm(c')) | (ctx,c') <- cReferences(c), ctx /= c }

setDefiningLoadersForSupers :: Class -> Rule ()
setDefiningLoadersForSupers(c) = do
  cEnv(c) := f(cEnv(c))
 where g (_,c) = liftClass(c)
       f (CFile(c,b,ms, super, sigs,ifaces, fields, methods)) =
          CFile(c,b,ms,setDefLd g c super, sigs,
                setDefLd g c ifaces,fields,methods)

setDefiningLoaders :: Class -> Rule ()
setDefiningLoaders(c) = do
  let mapping = ctxSubstMapping(c)
  if null(mapping) then 
    cEnv(c) := insertSupSigs(c,cEnv(c))
   else
    cEnv(c) := setDefLd (ctxSubstFunction mapping) c (cEnv(c))

ctxSubstMapping :: Class -> [((Class,Class), Class)]
ctxSubstMapping(c) = 
  let refs_direct   = { (c',liftClass(c')) | c' <-: directReferences(c) }
      subst         = { (p,f p) | p <-: cReferences(c) }
      f (ctx,c')    = if ctx == c then refs_direct#(c')
                      else liftClass(cLd(refs_direct#(ctx)),cNm(c'))
  in [ p | p@((ctx,c1),c2) <-: subst, c1 /= c2 ]

ctxSubstFunction :: [((Class,Class), Class)] -> ((Class,Class) -> Class)
ctxSubstFunction mapping p =
   case [ c | (x,c) <- mapping, p==x ] of
     [c] -> c
     _   -> snd p

class SetDefLd a where
  setDefLd :: ((Class,Class) -> Class) -> Class -> a -> a

instance SetDefLd JavaType where
  setDefLd f ctx (TJRef(c))   = TJRef(setDefLd f ctx c)
  setDefLd f ctx (TJArray(t)) = TJArray(setDefLd f ctx t)
  setDefLd f ctx x            = x

instance SetDefLd a => SetDefLd [a] where
  setDefLd f ctx = map (setDefLd f ctx)

instance SetDefLd Class where
  setDefLd f ctx c = f (ctx,c)

instance SetDefLd a => SetDefLd (Maybe a) where
  setDefLd f ctx Nothing  = Nothing
  setDefLd f ctx (Just c) = Just (setDefLd f ctx c)

instance (SetDefLd a, Ord a) => SetDefLd {a} where
  setDefLd f ctx xs = { setDefLd f ctx x | x <-: xs }

instance SetDefLd (MSig,MDec) where
  setDefLd f ctx ((m,sig),mdec) = ((m,setDefLd f ctx sig),setDefLd f ctx mdec)

instance SetDefLd MDec where
  setDefLd f ctx (MDec(ms,rt,code,excs,limits)) =
      MDec(ms,setDefLd f ctx rt,setDefLd f ctx code, 
           setDefLd f ctx excs,limits)

instance SetDefLd Exc where
  setDefLd f ctx (Exc(f',t,h,c)) = Exc(f',t,h,setDefLd f ctx c)

instance SetDefLd Instr where
  setDefLd f ctx instr = case instr of
    MGetStatic(t,c:/f',ms) -> MGetStatic(setDefLd f c t, setDefLd f ctx c:/f',ms)
    MPutStatic(t,c:/f',ms) -> MPutStatic(setDefLd f c t, setDefLd f ctx c:/f',ms)
    MInvokeStatic(rt,c:/(m,sig),ms) -> MInvokeStatic(setDefLd f c rt,
                                                   setDefLd f ctx c:/
                                                   (m,setDefLd f c sig),ms)
    MInvokeSpecial(rt,c:/(m,sig),ms) -> MInvokeSpecial(setDefLd f c rt,
                                                     setDefLd f ctx c:/
                                                     (m,setDefLd f c sig),ms)
    MInvokeVirtual(rt,c:/(m,sig),ms) -> MInvokeVirtual(setDefLd f c rt,
                                                     setDefLd f ctx c:/
                                                     (m,setDefLd f c sig),ms)
    New(c)               -> New(setDefLd f ctx c)
    MGetField(t,c:/f',ms) -> MGetField(setDefLd f c t, setDefLd f ctx c:/f',ms)
    MPutField(t,c:/f',ms) -> MPutField(setDefLd f c t, setDefLd f ctx c:/f',ms)
    InstanceOf(t)        -> InstanceOf(setDefLd f ctx t)
    Checkcast(t)         -> Checkcast(setDefLd f ctx t)
    x -> x

instance SetDefLd (FNm,FDec) where
  setDefLd f ctx (n,FDec(ms,t)) = (n,FDec(ms,setDefLd f ctx t))

instance SetDefLd ClassFile where
  setDefLd f ctx (CFile(c,b,ms, super, (simpleSigs,_),ifaces, fields, methods)) =
      CFile(c,b,ms,setDefLd f ctx super,
            (simpleSigs,visibleSupSigs(ctx,methods',super',ifaces')),
            ifaces',setDefLd f ctx fields,methods')
    where methods' = setDefLd f ctx methods
          ifaces'  = setDefLd f ctx ifaces
          super'   = setDefLd f ctx super

visibleSupSigs(ctx,methods,super,ifaces) = (supSigs,cMethods ++ visible)
   where cMethods = [ (ctx:/msig,(rt,mods)) 
                    | (msig,MDec(mods,rt,_,_,_)) <-: methods ]
         cSigs    = [ msig | (_:/msig,_) <- cMethods ]
         supSigs  = [ x
                    | s <- maybe2list(super) ++ expr2list(ifaces)
                    , x@(c:/_,(_,mods)) <- visibleSigs(cEnv(s))
                    , accessible(ctx,(c,mods)) ]
         visible  = [ x | x@(c:/msig,_) <- supSigs
                        , msig `notElem` cSigs ]

insertSupSigs(c,CFile(c',b,mods,super,(sig,_),ifaces,fields,methods)) =
  CFile(c',b,mods,super,
       (sig,visibleSupSigs(c',methods,super,ifaces)),
       ifaces,fields,methods)
