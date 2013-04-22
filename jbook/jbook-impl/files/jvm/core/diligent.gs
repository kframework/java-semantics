verifyScheme__I(code,maxOpd,propagateVM, succ,check) = do                    

    let pc = head(expr2list(dom(changed))) in do

      if check(code!!(pc), maxOpd, pc, regV( pc ) , opdV( pc ) ) then do
        changed(pc) := asmDefault
        propagateVM(code,succ,pc)
       else do
          stdout := "Verification failed"
          halt   := True

propagateVM__I(code,succ,pc) = do                   
  forall(s,regS,opdS) <-: succ(code!!(pc),pc,regV( pc ) ,opdV( pc ) ) do
     propagateSucc(code, s, regS, opdS)

validReg(VTRetAddr(l),pc)      = pc `elem` belongsTo#(l)               
validReg(t,pc)                 = True 

validOpd(VTRetAddr(l),pc)      = (l == pc)              
validOpd(t,pc)                 = True 

propagateSucc :: (Code, Nat, Register(VerifyType), Opd(VerifyType))  
                          -> Rule ()
propagateSucc (code, s, regS, opdS) =                   
  if ( s ) `notInDom`   visited   then do
    if validCodeIndex(code,s) then do

      regV( s )        := { reg | reg@(_,t) <-: regS, validReg(t,s) }
      opdV( s )        := [ if validOpd(t,s) then t else VTUnusable | t <- opdS ]
      visited(s)     := True
      changed(s)     := True 

     else do
       stdout := "Verification failed (invalid code index)"
       halt   := True
  else if  regS `regCompatible` regV( s )  &&  
          opdS `listCompatible` opdV( s )  then
    skip
  else if  length(opdS) == length(opdV( s ) ) then do
    regV( s )        := regV( s )  `regMerge` regS 
    opdV( s )        := opdV( s )  `opdMerge` opdS
    changed(s)     := True 
  else do
    stdout := "Propagate failed"
    halt   := True

diligentScheme(verifyVM, execVM) =                    
   if not( isChecked )  then
     verifyVM
    else do
     execVM

isChecked = (null(verifyMeths) && emptyDom(changed))               

verifyScheme__C(propagateVM,succ,check) = do                    
  if notEmptyDom(changed) then
    verifyScheme__I(code(vmeth),maxOpd(vmeth),propagateVM,
                    succ(vmeth), check(vmeth)) 
   else do
    let verifyMeths' = dropTop(verifyMeths,1)
    verifyMeths := verifyMeths'
    if length(verifyMeths') > 0 then 
       initVerify(top(verifyMeths'))
     else
       classState(verifyClass) := Linked

initVerify :: MRef -> Rule ()
initVerify (meth) = do                
    visited(0)    := True
    changed(0)    := True

    regV( 0 )         := { (l,r) | (l,r) <-: formals(meth) }

    opdV( 0 )         := [] 
    forall i <-: dom(visited), i /= 0 do
     visited(i)     := asmDefault
     changed(i)     := asmDefault
     regV( i )        := asmDefault
     opdV( i )        := asmDefault 

    let belongsTo' = belongsOf(code(meth),excs(meth))
    belongsTo       := belongsTo'
    jsrMod          := modOf(code(meth), belongsTo') 

    forall s <-: dom(enterJsr) do
      enterJsr(s) := (Set []) 
    forall s <-: dom(leaveJsr) do
      leaveJsr(s) := (Set []) 

linkClass(c) = do               
   let classes = {just( super(c) ) } `union` implements(c)
   if c == object  || (all (\( c' ) ->  classState(c')>=Linked ) ( classes ))  then
     prepareVerify(c)
    else if  not( cyclicInheritance(c) )  then
      choose c' <-: classes, classState(c')==Referenced do
        linkClass(c')
     else do
      stdout := "Cyclic Inheritance: " ++ cNm(c)
      halt   := True

prepareVerify :: Class -> Rule ()
prepareVerify (c) = do                   
   if (fst( constraintViolation(c) ))  then do

      stdout := violationMsg(cNm(c)) ++ newline ++
                snd(constraintViolation(c))
      halt   := True

    else do
     let verifyMeths' = [ (c :/ m) | m <-: mdomain( methods(cEnv(c)) ) ,
                                     not( null(code(c:/m)) )  ] 
     verifyMeths   := verifyMeths'
     verifyClass   := c  
     initVerify(top(verifyMeths'))
     prepareClass(c)

formals :: MRef -> Register(VerifyType)
formals (c:/m) = 
  if isStatic(c:/m) then               
    makeRegs(argTypes(c:/m))
  else if  mNm(m) == "<init>" && c /= object  then
    makeRegs([conv(VTInit)]  ++ argTypes(c:/m))
   else
    makeRegs([conv(VTClass(c))] ++ argTypes(c:/m))

propagateVM__E(code,succ,pc) = do                   
  propagateVM__I(code,succ,pc)
  case code!!(pc) of
    Jsr(s)   -> do enterJsr(s) := {pc} `union` enterJsr(s) 
                   forall (i,x) <-: leaveJsr(s),  
                          ( i ) `notInDom`  changed   do
                      if regV( i ) #(x) == VTRetAddr(s) then
                        propagateJsr(code,pc,s,i) else skip   

    Ret(x)   -> do let VTRetAddr(s) = regV( pc ) #(x)
                   leaveJsr(s) := {(pc,x)} `union` leaveJsr(s)
                   forall j <-: enterJsr(s), ( j ) `notInDom`  changed   do
                      propagateJsr(code,j,s,pc)  

    _ -> skip

propagateJsr(code,j,s,i) =                  
  propagateSucc(code, j+1, regJ +<< jsrMod#(s) `restrictElem` regV( i ) , opdV( i ) ) where
   regJ   = { (x,t) | (x,t) <-: jsrMod#(s) `restrictNElem` regV( j ) ,
                      validJump(t,s) &&  
                      notIsNew(t) && t /= VTInit } 

validJump(VTRetAddr(l),s)   = belongsTo#(s) `subseteq` belongsTo#(l)  

validJump(t,s)              = True 

verifyScheme__N(check) = do                    
  if changed(0) && isNative(vmeth) then
    if check(vmeth) then
      changed(0) := asmDefault
     else do
      stdout := "Verification failed"
      halt   := True
   else
    verifyScheme__C(propagateVM__E,succ__E, check__E)

belongsTo      :: Map ( Pc ) (  { Pc }  )                    
jsrMod         :: Map ( Pc ) (  { RegNo }  )           
jsrMod   = initVal "jsrMod" (Set [])               
belongsTo = initVal "belongsTo" (Set [])            

modOf :: (Code, Map Pc {Pc}) -> {(Pc,{RegNo})}
modOf(code, belongsTo) = 
    { (s, pcsMods(imods,pcs)) | (s,pcs) <-: belongsTo }
  where            
   imods = [(i,mods(instr)) | (i,instr) <- (zip ( [0..] ) ( code ))  ]

mods (Store(t,x))   = if size(t) == 1 then {x} else {x,x+1}          
mods (_)            = (Set [])  

succ__I :: TypeInstr -> {Succ}
succ__I (instr,pc, regT, opdT) =             
  case instr of
   Prim(p)     ->                                
     {(pc+1, regT, dropTop(opdT,argSize(p)) +++ returnType(p))}
   Dupx(s1,s2) ->                              
     {(pc+1, regT, dropTop(opdT, s1+s2) ++
                        takeTop(opdT,s2) ++ takeTop(opdT,s1+s2))} 
   Iinc(x,i)   -> {(pc+1, regT, opdT)}
   Swap        -> let (opdT',[w1,w2]) = split(opdT,2) in 
                  {(pc+1, regT, opdT' ++ [w2,w1])}
   Nop         -> {(pc+1, regT, opdT)}
   Pop(s)      ->                               
     {(pc+1, regT, dropTop(opdT, s))}
   Load(t, x)  ->                              
     if size(t) == 1 then
       {(pc+1, regT, opdT ++ [ regT#(x) ])}
      else 
       {(pc+1, regT, opdT ++ [ regT#(x), regT#(x+1) ])}
   Store(t, x) ->                               
     if size(t) == 1 then
       {(pc+1, regT +<< {(x, top(opdT))}, dropTop(opdT, 1))}
      else
       {(pc+1, regT +<< {(x, t0), (x+1,t1)},dropTop(opdT, 2)) }
     where [t0,t1] = takeTop(opdT,2)
   Goto(o)       -> {(o, regT, opdT)}                              
   Cond(p,o)     -> { (pc+1, regT, dropTop(opdT, argSize(p))),
                      (o,    regT, dropTop(opdT, argSize(p))) }  

   _    -> (Set []) 

succ__C :: MRef -> TypeInstr -> {Succ}
succ__C (meth)(instr, pc, regT, opdT) =            
  succ__I(instr, pc, regT, opdT) `union`
  case instr of
    MGetStatic(t,c:/f,_)   ->                                     
          {(pc+1, regT, opdT +++ typeTJVT(t))}
    MPutStatic(t,c:/f,_)   ->                                     
          {(pc+1, regT, dropTop(opdT, size(t)))}
    MInvokeStatic(t,c:/m,_)   -> {(pc+1, regT, dropTop(opdT, argSize(c:/m)) +++ typeTJVT(t))}  

    Return(mt)   -> (Set [])                                   
    _   -> (Set []) 

succ__E :: MRef -> TypeInstr -> {Succ}
succ__E (meth)(instr, pc, regT, opdT) =            
  succ__O (meth)(instr, pc, regT, opdT) `union`  
   allhandlers(instr,meth,pc,regT) `union`
  case instr of
    Athrow   -> (Set [])                                 
    Jsr(s)   -> { (s, regT, opdT +++ [VTRetAddr(s)]) }  

    Ret(x)   -> (Set [])                               
    _  -> (Set []) 

succ__O :: MRef -> TypeInstr -> {Succ}
succ__O (meth)(instr, pc, regT, opdT) =            
  succ__C(meth)(instr, pc, regT, opdT) `union`
  case instr of
    New(c) ->                               
      {(pc+1, regS, opdS +++ [VTNew(c,pc)])}
      where regS   = {(x,t) | (x,t) <-: regT, t /= VTNew(c,pc) }
            opdS   = [ if t == VTNew(c,pc) then VTUnusable else t | t <- opdT ] 
    MGetField(t,c:/f,_) ->                                    
      {(pc+1, regT, dropTop(opdT, 1) +++ typeTJVT(t))}
    MPutField(t,c:/f,_) ->                                    
      {(pc+1, regT, dropTop(opdT, 1+size(t)))}
    MInvokeSpecial(t,c:/m,_) ->                                       
      let opdT'  = dropTop(opdT, 1 + argSize(c:/m)) +++ typeTJVT(t) in 
      if mNm(m) == "<init>" then
       case top(dropTop(opdT, argSize(c:/m))) of
         VTNew(c,o)   -> {(pc+1, substitute (regT,VTNew(c,o),VTReference(VTClass(c))),  
                                             substitute (opdT',VTNew(c,o),VTReference(VTClass(c)))) } 
         VTInit    -> let c :/ _ = meth in  
                      {(pc+1, substitute (regT,VTInit,VTReference(VTClass(c))), 
                              substitute (opdT',VTInit,VTReference(VTClass(c)))) } 
       else
         { (pc+1, regT, opdT') }
    MInvokeVirtual(t,c:/m,_) ->                                       
      let opdT'  = dropTop(opdT, 1 + argSize(c:/m)) +++ typeTJVT(t) in 
      { (pc+1, regT, opdT') }
    InstanceOf (c) ->                                      
      {(pc+1, regT, dropTop(opdT, 1) +++ [VTInt])}
    Checkcast(t) ->                                       
      {(pc+1, regT, dropTop(opdT, 1) +++ typeTJVT(t))}
    LoadString(str) ->                                    
      {(pc+1, regT, opdT +++ mTypeClass(string ))}
    NewArray(t,d) ->                          
      {(pc+1, regT, dropTop(opdT,d) ++ [conv(VTArray(typeTJVT(t)))])}
    ArrayLength ->                 
      {(pc+1, regT, dropTop(opdT,1) +++ [VTInt]) }
    ALoad(AMTObject) ->            
       let [arr,i] = takeTop(opdT,2) in 
       {(pc+1, regT, dropTop(opdT,2) ++ [arrayElemType(conv(arr))]) }
    ALoad(t) ->              
       {(pc+1, regT, dropTop(opdT,2) ++ typeAMTVT(t)) }
    AStore(t) ->              
       {(pc+1, regT, dropTop(opdT,2+size(t)))}

    TableSwitch (low,high) dflt  tab ->
       {(pc, regT, dropTop(opdT,1)) | pc <- dflt:tab}
    LookupSwitch dflt tab ->
       {(pc, regT, dropTop(opdT,1)) | pc <- dflt:map snd tab}

    _  -> (Set []) 

typeAssignment :: String
typeAssignment = 
  if null verifyMeths then "" else
  (showString "method " . shows vmeth .
   showString newline .
   showString "mod: " . shows jsrMod . showString newline .
   showString "belongs: " . shows belongsTo . showString newline .
   prettyPrintTypeAssignment(code vmeth,assocs opdV,assocs regV) .
   showString newline . showString "END" . showString newline) ""

succ__x (x, (pc, Store(t,y)),exs) = (if x == y then {} else {pc+1}) `union`
                                    handlers(exs,pc)
succ__x (x, i@(_,Load(_,_)),_)    = succ(i)
succ__x (x, i@(_,Return(_)),_)    = succ(i)
succ__x (x, i@(_,Jsr(_)),_)       = succ(i)
succ__x (x, i@(_,Goto(_)),_)      = succ(i)
succ__x (_, i@(pc,_), exs)        = succ(i) `union` handlers(exs,pc)

belongsOf :: (Code, [Exc]) -> Map ( Pc ) ( {Pc} ) 
belongsOf(code, exs) =               
  let maxIndex        = length(code)
      sreachable(s,x) = searchFixpoint({s+1},expand(x))
      rets            = [ x | x@(Ret(_),i) <- (zip ( code ) ( [0..] ))  ]
      send(s,x)       = maximum (-1: [ i | (Ret(y),i) <- rets,
                                           y==x && 
                                           i `elem` sreachable(s,x) ])
      expand(x)(pc) = { s | s <-: succ__x(x,(pc, code!!(pc)),exs),
                            s >= 0, s < maxIndex }
      icalls        = [(i,s) | (i,Jsr(s)) <- (zip ( [0..] ) ( code )) ]
      subroutines   = { (s,getVar(code!!(s))) | (_,s) <- icalls }
      belongs       = {(s,{s..send(s,x)}) | (s,x) <-: subroutines }
      getVar(Store(MTAddr,x))  = x
      getVar(_)                = -1
  in belongs

succ (pc, Goto(o))     = { o }          
succ (pc, Cond(p,o))   = { pc + 1, o }
succ (pc, Jsr(o))      = { pc + 1, o }
succ (pc, Halt)        = (Set []) 
succ (pc, Athrow)      = (Set []) 
succ (pc, Return(_))   = (Set []) 
succ (pc, Ret(_))      = (Set []) 
succ (pc, _)           = { pc + 1 } 

handlers :: ([Exc], Pc) -> {Offset}
handlers(excs, pc) = { h | Exc(f, u, h, t) <- excs, f <= pc && pc < u }  

