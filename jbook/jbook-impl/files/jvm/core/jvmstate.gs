language :: AsmVar Int
language = initVal "language" 4

cEnv = initAssocs "cEnv" initcEnv
cReferences :: Class -> [(Class,Class)]
cReferences = initAssocs "cReferences" initReferences

initcEnv :: [(Class, ClassFile)]
initcEnv = [ ((ld,cn), cf) | (ld,(cn, cf)) <- loadedClasses ]

initClassState :: Bool ->  [(Class,JVMClassState)]
initClassState(b) = [ (c, f c) 
                    | c <-: dom(cEnv) ]
  where f c = if basicInitializedClass(c) then 
                 Initialized
              else Loaded

basicInitializedClass :: Class -> Bool
basicInitializedClass(ld,cn) = ld == sysLd &&
   cn `elem` [ "java/lang/Object"
             , "java/lang/ClassLoader"            
             , "java/lang/Class"
             , "java/lang/String"
             , "java/lang/Array" ]

basicPredefinedClass :: Class -> Bool
basicPredefinedClass(c) = c `elem` map f loadedClasses
   where f(ld,(cn,_)) = (ld,cn)

loadedClasses = [ (sysLd,javaLangObject([])),
                  (sysLd,javaLangClassLoader),
                  (sysLd,javaLangComparable),
                  (sysLd,javaLangClassNotFoundException),
                  (sysLd,javaLangClass),
                  (sysLd,javaLangString),
                  (sysLd,javaLangArray) ] 

initReferences :: [(Class,[(Class,Class)])]
initReferences = [ ((ld,cn),ctxReferences (ld,cn) cf)
                 | (ld,(cn,cf)) <- loadedClasses ]

super  :: Class -> Maybe(Class)
super(c) = superEnv(cEnv(c))           

heap = initAssocs "heap" initHeap

initHeap :: [(Ref,JVMHeap)]
initHeap = [ (sysLd,JVMObject((sysLd,"java/lang/ClassLoader"), (Set []) )) ]

-- Loader Environment 
ldEnv = initAssocs "ldEnv" initldEnv  

-- initialization array for ldEnv
initldEnv :: [(Class,Ref)]
initldEnv =  []

-- real class name
cOf = initAssocs "cOf" initcOf 

-- initialization array for cOf
initcOf :: [(Ref, Class)]
initcOf = []

-- Dynamic functions for bytecode verification

halt :: AsmVar (Bool)
halt = initVal "halt" False                             

searchFixpoint :: (Eq a, Ord a, Ord {a}) => ({a}, a -> {a}) -> {a}
searchFixpoint (initSet, f) = iterate((Set []) , initSet)                    
  where iterate (old, (Set []) )   = old
        iterate (old, add)      = iterate (old', add') 
            where old'   = old `union` add
                  add'   = bigUnion({f(x) | x <-: add })  
                             `difference` old' 

-- Dynamic functions used in the GUI

mainClass :: AsmVar Class
mainClass = initVal "mainClass" (sysLd,"")                   

newClassLoaded :: AsmVar (Bool)
newClassLoaded = initVal "newClassLoaded" False

classPath :: AsmVar (ClassPath)
classPath = initVal "classPath" {"predefined.jvm/"}                 

implicitCall :: MRef -> Bool
implicitCall(m) = mNm(m) `elem` { "<clinit>", "<cload>" }                  

top :: [a] -> a
top(xs) = last(xs)                             

splitTop :: [a] -> ([a], a)
splitTop xs = (init(xs), top(xs))                   

class Modifiers c where
  modifiers  :: c -> {Modifier}
  isAbstract, isPublic, isPrivate, isStatic, isNative :: c -> Bool
  isAbstract (c) = Abstract `elem` modifiers(c)
  isPublic   (c) = Public   `elem` modifiers(c)
  isPrivate  (c) = Private  `elem` modifiers(c)
  isStatic   (c) = Static   `elem` modifiers(c)
  isNative   (c) = Native   `elem` modifiers(c)

instance Modifiers Class where
  modifiers(c) = ms
   where CFile(_, _, ms, _, _, _, _, _) = cEnv(c)

instance Modifiers MRef where
  modifiers(c:/m) = ms
   where MDec(ms, _, _, _, _) = methods(cEnv(c))#(m)

instance Modifiers FRef where
  modifiers(c:/f) = ms
   where FDec(ms, _) = fields(cEnv(c))#(f)

instance Modifiers (Combine Class a,(String,b)) where
  modifiers (c:/_,(msig,_)) =
     case maplookup (simpleSigs(cEnv(c))) msig of
       Nothing     -> error "modifiers: cannot find entry"
       Just (t,ms) -> ms

instance Modifiers (MRef,(JavaType,{Modifier})) where
  modifiers (_,(_,mods)) = mods

methodDefined :: MRef -> Bool
methodDefined (c:/m) = m `elem` mdomain( methods(cEnv(c)) )   

checkCType, checkCReturnType :: (Combine Class a, (String,String), JavaType) -> Bool
checkCType (c:/_,(n,tname),_) = 
     case maplookup (simpleSigs(cEnv(c))) n of
       Nothing -> False
       Just (t,_) -> t == tname

checkCReturnType = checkCType

definedIn :: (Class, Class) -> Bool
definedIn (c,c') = 
   cLd(c) == cLd(c') && 
   (c == c' || cNm(c)++"$" `isPrefix` cNm(c'))

-- the static fields of a (single) class
staticFields :: Class -> {FNm}
staticFields c = { f | (f,FDec(ar, _)) <-: fields, Static `elem` ar }
  where CFile(_, _, _, _, _, _, fields, _) = cEnv(c)                  

-- all instance fields of the class and of any superclass
instanceFields :: Class -> { FRef }
instanceFields c =  { c' :/ f | c' <- supers(c), f <-: ifields'(c') }
  where ifields'(c) = { f | (f,FDec(ar, _)) <-: fields, Static `notElem` ar }
              where CFile(_, _, _, _, _, _, fields, _) = cEnv(c)  

sigInfo :: ClassFile -> SigInfo
sigInfo (CFile(_, _, _, _, inf, _, _, _)) = inf

simpleSigs :: ClassFile -> SimpleSigs
simpleSigs = fst . sigInfo

superSigs :: ClassFile -> SuperSigs
superSigs = fst . snd . sigInfo

visibleSigs :: ClassFile -> SuperSigs
visibleSigs = snd . snd . sigInfo

superSigReturnType :: (MRef,(JavaType,{Modifier})) -> JavaType
superSigReturnType(_,(t,_)) = t

isInterface :: Class -> Bool
isInterface(c) = iface
  where CFile(_, iface, _, _, _, _, _, _) = cEnv(c)                 

-- exceptions of a method
excs :: MRef -> [Exc]
excs(c :/ m) = es          
  where MDec(_, _, _, es, _) = methods(cEnv(c))#(m)

-- code of a method
code :: MRef -> [Instr]
code(c :/ m) = is          
  where MDec(_, _, is, _, _) = methods(cEnv(c))#(m)

implements :: Class -> {Class}
implements c = implementsEnv(cEnv(c))                 

implementsEnv :: ClassFile -> {Class}
implementsEnv (CFile(_, _, _, _, _, ifs, _, _)) = ifs

-- maximum size of operand stack
maxOpd :: MRef -> Nat
maxOpd (c :/ m) = max            
  where MDec(_, _, _, _, (max,_)) = methods(cEnv(c))#(m)

-- maximum number of local variables
maxReg :: MRef -> Nat
maxReg (c :/ m) = max            
  where MDec(_, _, _, _, (_,max)) = methods(cEnv(c))#(m)

superEnv :: ClassFile -> Maybe Class
superEnv (CFile(_, _, _, c', _, _, _, _)) = c'

supers :: Class -> [Class]
supers(c) = case super(c) of            
             Just(c') -> [c] ++ supers(c')
             Nothing -> [c] 

cyclicInheritance :: Class -> Bool
cyclicInheritance(c) = cyclic(c,[])                       
 where cyclic(c,cs) = c `elem` cs || c `elem` dom(cEnv) &&
                                     (isJust( super(c) ))  &&
                                     cyclic(just( super(c) ) ,c:cs) 

stringRef :: String -> Maybe(Ref)
stringRef(s)  =                
   case [ r | (r, String(s')) <- assocs(heap), s == s' ] of
     [r]   -> Just(r)
     _     -> Nothing 

enterJsr :: Dynamic (Pc -> {Pc})
enterJsr = initAssocs' "enterJsr" {} asmLt (==) []

leaveJsr :: Dynamic (Pc -> {(Pc,RegNo)})
leaveJsr = initAssocs' "leaveJsr" {} asmLt (==) []

classOf :: Ref -> Class
classOf(r) = case heap(r) of             
              String(s)      -> string 
              Array(_)       -> carray 
              JVMObject(c,_) -> c

mGetInstanceField :: (Ref, FRef) -> Val
mGetInstanceField (r, f) = vs#(f)                                   
  where JVMObject(_, vs) = heap(r)

lookup :: (Class, MRef) -> MRef
lookup (c,_ :/ m) = meth            
  where  meth  :  _   = 
           [ c' :/ m | c' <- supers(c),
                       ( m  `elem`   mdomain( methods(cEnv(c')) )  )  ]

lookupString :: String -> Rule(Ref)
lookupString (str) =
   let r = stringRef(str) in 
   if (isJust( r ))  then
     result(just( r ) )
    else
     create r do
       heap(r) := String(str)
       result(r)

mSetInstanceField :: (Ref, FRef, Val) -> Rule ()
mSetInstanceField (r,f,v) = (heap(r) := JVMObject(c,fields +<< {(f,v)}))  

  where JVMObject(c,fields) = heap(r)

handle :: Exc -> Offset
handle (Exc(f, u, h, t)) = h            

arraySize :: Ref -> Word
arraySize(r) = conv(length(elems))               
   where Array(t, elems) = heap(r)

setElement (r,i,v) = Array(t, (take (conv(i)) (arr) ++ [v] ++  
                      drop (conv(i)+1) (arr)))                 
  where Array(t, arr) = heap(r)

getElement :: (Ref, Word) -> Val
getElement (r, i) = arr!!(conv(i))                  
  where Array(_, arr) = heap(r)

typeAMTVT :: ArrayMoveType -> [VerifyType]
typeAMTVT(AMTByte)     = [VTInt]
typeAMTVT(AMTChar)     = [VTInt]
typeAMTVT(AMTShort)    = [VTInt]
typeAMTVT(AMTInt)      = [VTInt]
typeAMTVT(AMTFloat)    = [VTFloat]
typeAMTVT(AMTLong)     = [VTLowLong,VTHighLong]
typeAMTVT(AMTDouble)   = [VTLowDouble,VTHighDouble]
typeAMTVT(AMTObject)   = [VTReference(VTClass(object ))] 
typeAMTVT(_) = error "typeAMTVT"

isRetAddr :: VerifyType -> Bool
isRetAddr(VTRetAddr(_))   = True                   
isRetAddr(_)              = False 

regV   :: Nat -> Map ( RegNo ) (  VerifyType )           
opdV   :: Nat -> [ VerifyType ]           
visited   :: Nat -> Bool             
changed   :: Nat -> Bool              
opdV = initAssocs "opdV" []                   
regV = initAssocs "regV" []                   
changed = initAssocs "changed" []       
visited = initAssocs "visited" []       

pc         = initVal  "pc"   0                      
reg        = initVal  "reg"    (Set [])                 
opd        = initVal  "opd"    []             

meth     :: MRef                       
stack    :: [ JvmFrame  ]             
meth     = initVal  "meth"    (object  :/ ("<entrypoint>",[])  )  
stack    = initVal  "stack"    []   

switch :: Switch            
switch = initVal  "switch"    Noswitch   

globals :: FRef -> Val             
globals  = initAssocs "globals" []

initState :: Ref -> InitState                
initState = initAssocs "initState" []
verifyClass :: Class                 
verifyClass = initVal "verifyClass" asmDefault
verifyMeths :: [ MRef ]                  
verifyMeths = initVal "verifyMeths" []                  
ldEnv   :: Class -> Ref              
cOf     :: Ref -> Class          
pc         :: Pc                      
reg        :: Map ( RegNo ) ( Word )          
opd        :: [ Word ]                
cEnv :: Class -> ClassFile          
heap :: Ref -> JVMHeap           

