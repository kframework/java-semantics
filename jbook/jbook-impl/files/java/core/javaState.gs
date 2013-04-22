infix  5 `compatible`
pos :: Pos         
type Locals = Map ( Loc ) (  JavaVal )             
locals :: Locals            
data ClassState = ClassLinked                                       
                | InProgress                            
                | ClassInitialized                       
                | ClassUnusable                     
                | NotLoaded
classState :: JavaClass -> ClassState                   
globals :: FieldRef -> JavaVal                  
meth :: MethRef          
type JavaFrame  = (MethRef, Phrase, Pos, Locals)            
frames :: [ JavaFrame  ]             
instanceFields   ::   JavaClass -> [ FieldRef ]                     
lookup           ::   (JavaClass, MethRef) -> JavaClass             
heap      ::   Ref -> JavaHeap                   
classOf   ::   Ref -> JavaClass             
cont :: Thread -> ([ JavaFrame  ] , JavaFrame )           
sync    ::   Thread -> [ Ref ]              
locks   ::   Ref -> Nat           
waitSet :: Ref -> { Thread }                
exec :: Thread -> ThreadState            
data ThreadState = NotStarted | Active | Synchronizing 
                 | Waiting | Notified | Dead  

interruptedFlag :: Thread -> Bool                       
initThread   ::   JavaClass -> Thread                           
initWait     ::   JavaClass -> { Thread }               

data JavaHeap = HeapObject(JavaClass, Map ( FieldRef ) ( JavaVal ) )  

              | HeapString String
              | HeapArray(JavaType, [JavaVal]) 

classOf(ref) = case heap(ref) of             

                HeapArray(t,elems)      -> "Array"

                HeapString(_)         -> stringClass
                HeapObject(c, fields)   -> c  
initialized(c) =                                          

  classState(c) == ClassInitialized || 
  classState(c) == InProgress && initThread(c) == thread

initPgm :: [(Name,TypeDec)]
initPgm = [f (typeNm(td),td) | td <- predefined ]
  where f c@(name,td) = 
           if name == "Object" then 
             (name,objectCode(td,Term (Block,TJVoid) [Term (JavaReturn "",TJVoid) []]))
           else c

predefinedClasses :: [JavaClass]
predefinedClasses = map typeNm predefined

--Javai --

type Phrase = Term (JavaOp, JavaType)
instance AsmTerm Phrase

restbody :: Dynamic Phrase
restbody  = initVal "restbody"  (body(entrypoint))

pos   = initVal "pos" (firstPos)

locals  = initVal "Locals" {}

--Javac --
--Meth
meth = initVal "meth" entrypoint

pgm :: Dynamic (Name -> TypeDec)
pgm = initAssocs "pgm" initPgm

instance MemberInterface MethRef where
  memberDecl(n :/ r) = methDec(members(n),r)
  classNm(n :/ _)    = n

instance MemberInterface FieldRef where
  memberDecl(n :/ f) = fieldDec(members(n),f)
  classNm(n :/ _)    = n

instance ModifierInterface MethRef where
  javaModifiers = javaModifiers . memberDecl

instance ModifierInterface FieldRef where
  javaModifiers = javaModifiers . memberDecl

instance TypeInterface JavaClass where
  typeNm      = typeNm     . pgm 
  super       = super      . pgm
  implements  = implements . pgm
  members     = members    . pgm
  isClass     = isClass    . pgm
  isIface     = isIface    . pgm

instance MethodInterface MethRef where
  methNm(c :/ (m,r)) = m
  argumentTypes      = snd . signature
  argNames           = argNames . memberDecl
  javaReturnType     = javaReturnType . memberDecl
  signature(c :/ sig)= sig
  body               = body . memberDecl

instance FieldInterface FieldRef where
  fieldNm (c :/ f) = f
  fieldType  = fieldType    . memberDecl
  initialExp = initialExp   . memberDecl

instance AsmTerm ClassState where
  asmDefault = NotLoaded

--State  
classState = initAssocs "classState" 
             [f (typeNm(td), ClassLinked) | td <- predefined ]
  where f (c,s) = if c == objectClass || c == stringClass
                     then (c,ClassInitialized)
                     else (c,s)

-- Threads
type Thread = Ref

cont = initAssocs "cont" []

instance AsmTerm ThreadState

exec = initAssocs "exec" [(systemThread,Active)]

interruptedFlag = initAssocs "interruptedFlag" []

sync = initAssocs "sync" [(systemThread,[])]

thread :: Dynamic Thread
thread = initVal "thread" systemThread

initThread = initAssocs "initThread" []

-- The following dynamic functions are used for objects
locks = initAssocs' "locks" 0 asmLt (==) []

waitSet = initAssocs "waitSet" [(systemThread,{})]

initWait = initAssocs "initWait" []

-- derived functions

-- Frames
type Frames = [JavaFrame ]
instance AsmTerm JavaFrame 

frames = initVal "frames" []

-- BSS
globals  = initAssocs "globals" []

--Javao --
-- Heap

stringVal :: JavaVal -> String
stringVal(TS s) = s
stringVal(TR r) = case heap(r) of
                   HeapString(s)        -> s
                   HeapObject(_,fields) -> stringVal(val)
                     where val = fields#("String":/"s")

stringVal x    = error ("stringVal: " ++ show' x)

stringNull :: JavaVal -> Bool
stringNull(TS s) = False
stringNull(TR r) = r == 0
stringNull _     = error "stringNull"

instance AsmTerm JavaHeap

heap = initAssocs "heap" [(systemThread,HeapObject(threadClass,{}))]

typeOfRef :: Ref -> JavaType
typeOfRef(ref) = case heap(ref) of
                 HeapObject(c, fields) -> TJRef(c)
                 HeapString(_)         -> stringType
                 HeapArray(t,_)        -> TJArray(t)

supers :: JavaClass -> [JavaClass]
supers(c) = case super(c) of 
             Nothing -> [c]
             Just(m) -> c : supers(m)

class Compatible c where
  compatible :: c -> c -> Bool

maxType :: Compatible c => [c] -> c
maxType([c]) = c
maxType(c1:c2:cs) 
   | c1 `compatible` c2 = maxType(c2:cs)
   | otherwise          = maxType(c1:cs)

isJTReference :: JavaType -> Bool
isJTReference(TJNull)     = True
isJTReference(TJArray(_)) = True
isJTReference(TJRef(_))   = True
isJTReference(_)          = False

notCompatible :: Compatible c => c -> c -> Bool
a `notCompatible` b = not(a `compatible` b)

instance Compatible JavaType where
  TJNull `compatible` TJRef(_)       = True
  TJNull `compatible` TJArray(_)     = True
  TJArray(n) `compatible` TJArray(m) = (isJTReference(n) && isJTReference(m) &&
                                       n `compatible` m) ||
                                       n == m
  TJArray(_) `compatible` TJRef(c)   = c == objectClass ||
                                       c == "Cloneable"
  TJRef(n) `compatible` TJRef(m)     = n `compatible` m
  a `compatible` b = a==b || isJust(maplookup primCompatible (a,b))

classCompatible :: JavaClass -> JavaClass -> Bool
n `classCompatible` m = m `elem` supers(n) ||
                        m `elem` implementsStar(n)

notClassCompatible :: JavaClass -> JavaClass -> Bool
n `notClassCompatible` m = not(n `classCompatible` m)

instance Compatible JavaClass where
  compatible = classCompatible

implementsStar :: JavaClass -> [JavaClass]
implementsStar(c) = let is = concat([implements(c') | c' <- supers(c)]) in
                    nub(is ++ concat([implementsStar(i) | i <- is ]))

instanceFields(n) =
  [(c :/ fieldNm(fd)) | c <- supers(n), 
           fd@(FieldDec(_)) <- members(c), 
           Static `notElem` javaModifiers(fd)]

staticFields(n) =
  [(c :/ fieldNm(fd)) | c <- supers(n), 
           fd@(FieldDec(_)) <- members(c), 
           Static `elem` javaModifiers(fd)]

lookup(a, msig@(b:/(n,ts))) =
 let mths_a  = [ (n, map fst as) 
               | m@(MethDec(_, _, n', as, _, _,_)) <- members(a),
                 Abstract `notElem` javaModifiers(m),
                 n == n' && ts == map fst as 
               ]
     _ `overrides` _ = True
     defined = not (null mths_a) in
 if defined && (isIface(b) || (a:/msig) `overrides` (b:/msig))
   then a
   else case super(a) of
         Just(c) -> lookup(c,msig)
         _       -> error "method not implemented"

--aux
fieldDec([],n) = error("Field "++show'(n)++" not in term.")
fieldDec(m@(MethDec(_))  : ms, n) = fieldDec(ms,n)
fieldDec(f@(FieldDec(_)) : ms, n)
    | fieldNm(f) == n = f
    | otherwise    = fieldDec(ms,n)

methDec([],n) = error("Method "++show'(n)++" not in term.")
methDec(f@(FieldDec(_)) : ms, msig) = methDec(ms,msig)
methDec(m@(MethDec(_)) : ms, msig)
    | signature(m) == msig = m 
    | otherwise       = methDec(ms,msig)

-- Exception handling (derived because of the use of compatible)
matches(r,ss) 		= [ i | (i,Term(Catch(c, x),TJVoid)[s]) 
                                   <- zip [0..] ss, caught(r,c) ]
fstCatchIdx(r,ss) 	= head (matches(r,ss))
caught(ref,c) = classOf(ref) `classCompatible` c

enclosingLab :: Pos -> Lab
enclosingLab(pos) =
  case subterm(restbody,up(pos)) of
    Term(LabStm l,_)_ -> l
    _                 -> ""

