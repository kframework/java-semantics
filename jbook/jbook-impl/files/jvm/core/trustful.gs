execVM__I(instr) = do                            
 case instr of
  Prim(p)   -> do  let (opd',ws)= split (opd, argSize(p))
                   if ( conv(p) `elem` divMod )  `implies`  
                            sndArgIsNotZero(ws) then do
                     opd   := opd' ++ appl(p, ws)
                     pc    := pc + 1                              
                       else skip 

  Iinc(x,i) -> do
   reg := reg +<< { (x,reg#(x)+i) }
   pc       := pc + 1
  Nop -> pc := pc + 1
  Swap -> do
   let (opd',[w1,w2]) = split(opd,2)
   opd := opd' ++ [w2,w1]
   pc := pc + 1

  Dupx(s1, s2)   -> do let (opd',[ws1, ws2]) = splits(opd,[s1,s2])
                       opd   := opd' ++  ws2 ++ ws1 ++ ws2
                       pc    := pc + 1  

  Pop(s)   -> do let (opd',ws) = split(opd,s)
                 opd   := opd'
                 pc    := pc + 1                             
  Load(t, x)   -> do if size(t) == 1 then  
                       opd := opd ++ [reg#(x)]
                      else  
                       opd := opd ++ [reg#(x), reg#(x+1)]
                     pc  := pc + 1                              
  Store(t, x)   -> do let (opd',ws) = split(opd, size(t))
                      if size(t) == 1 then  
                        reg := reg +<< {(x,ws!!(0))}
                       else  
                        reg := reg +<< {(x,ws!!(0)),  
                                         (x+1,ws!!(1))}
                      opd   := opd'
                      pc    := pc + 1  

  Goto(o)   -> pc := o                              
  Cond(p, o)   -> do let (opd',ws) = split(opd, argSize(p))
                     opd := opd'
                     if conv(fappl(p, ws)) then pc := o  
                      else pc  := pc + 1  

  Halt   -> do stdout := "Halt"                               
               halt := True
  _ -> skip

classState :: Class -> JVMClassState                
classState = initAssocs "classState" (initClassState isDiligent)

initialized :: Class -> Bool
initialized(c) = (classState(c) == Initialized)                 

trustfulScheme__C(execVM, switchVM) =                      
  if switch == Noswitch then
    execVM(code( meth ) !!(pc))
  else
    switchVM

execVM__C(instr) = do              
 execVM__I(instr)
 case instr of
  MGetStatic(_,c:/f,_)   -> if initialized(c) then do
                             opd   := opd ++ globals(c:/f)
                             pc    := pc + 1 
                            else                                     
                             switch := InitClass(c) 
  MPutStatic(_,c:/f,_)   -> if initialized(c) then do
                              let(opd',ws) =  split(opd, size(c:/f))
                              globals(c:/f) := ws
                              opd      := opd'
                              pc       := pc + 1 
                             else                                     
                              switch := InitClass(c) 
  MInvokeStatic(_, c:/m,_)   -> if initialized(c) then do
                                 let(opd',ws) = split(opd, argSize(c:/m))
                                 opd      := opd'
                                 switch   := Call(c:/m, ws) 
                                else                                         
                                 switch := InitClass(c) 
  Return(t)   -> do let(opd',ws) = split(opd, size(t))
                    switch := Result(ws)  

  _ -> skip

popFrame(offset, result) = do              
  let (stack',[(pc',reg',opd',meth')]) = split(stack,1)
  pc          := pc' + offset
  reg         := reg'
  opd         := opd' ++ result
  meth        := meth'
  stack       := stack' 

execVM__O(instr) = do              
 execVM__C(instr)
 case instr of
  New(c) -> 
      if initialized(c) then create r do
                      heap(r) := JVMObject(c,  
                           { (f,dflt( f ) ) | f <-:  
                                instanceFields(c) })
                      initState(r) := InitNew(pc)
                      opd      := opd ++ [setReferenceType(r)]
                      pc       := pc + 1 
                   else                               
                    switch := InitClass(c)
  MGetField(_,c:/f,_)   -> do let (opd',[r]) = split(opd, 1)
                              if conv(r) /= 0  then do
                                opd   := opd' ++  
                                    mGetInstanceField(conv(r),c:/f)
                                pc    := pc + 1  
                                  else skip                                   
  MPutField(_,c:/f,_)   -> do let (opd', r  :  ws  ) =  
                                   split(opd, 1+size(c:/f))
                              if conv(r) /= 0  then do
                                mSetInstanceField(conv(r), c:/f,ws)
                                pc    := pc + 1
                                opd   := opd'  
                                  else skip                                    
  MInvokeSpecial(_,c:/m,_) -> do 
                              let (opd', r  :  ws  ) =  
                                        split(opd, 1+argSize(c:/m))
                              if conv(r) /= 0  then do
                                opd      := opd'
                                switch   := Call(c:/m, [r]  
                                  ++ ws)  
                                     else skip                                        
  MInvokeVirtual(_, c:/m,_) -> do 
                                 let (opd', r  :  ws  ) =  
                                           split(opd, 1+argSize(c:/m))
                                 if conv(r) /= 0  then do
                                   opd      := opd'
                                   switch   := Call(lookup(classOf( 
                                      conv(r)),c :/ m), [r] ++ ws) 
                                  else skip                                         
  InstanceOf (c)   -> do let (opd',[r]) = split(opd, 1)
                         opd   := opd' ++ (conv(conv(r) /= 0  &&  
                             typeOf( conv(r) )  `runCompatible` head( typeTJVT(c) ) ))
                         pc    := pc + 1  

  Checkcast(c)   -> do let r = top(opd)
                       if conv(r) == 0  || typeOf( conv(r) )   
                             `runCompatible` head( typeTJVT(c) )  then do
                         pc  := pc + 1  
                        else skip                                     

  LoadString(str) -> do rlet r ::= lookupString(str)
                        opd   := opd ++ [setReferenceType(r)]
                        pc    := pc + 1  

  NewArray(t,d) -> do                            
      let (opd',ds) = split(opd,d)
      if (all (\( i ) ->  i >= conv(0) ) ( ds ))  then do
         rlet r ::= createArray(t,d,ds)
         opd      := opd' ++ [r]
         pc       := pc + 1 
       else skip 
  ArrayLength -> do                 
      let (opd',[r]) = split(opd,1)
      if not( (conv(r) == 0 ) )  then do
        opd   := opd' ++ [arraySize(conv(r))]
        pc    := pc + 1 
       else skip 
  ALoad(t) -> do           
      let (opd',[r,i]) = split(opd,2)
      if not( (conv(r) == 0 ) )  && i >= conv(0) && i < arraySize(conv(r)) then do
        opd   := opd' ++ getElement(conv(r), i)
        pc    := pc + 1 
       else skip 
  AStore(t) -> do            
      let (opd',[[r,i],v]) = splits(opd,[2,size(t)])
      if not( (conv(r) == 0 ) )  && i >= conv(0) && i < arraySize(conv(r)) &&
         (t /= AMTObject || conv(v) == 0  || [typeOf( conv(v) ) ]  
               `listCompatible` typeTJVT(arrayType(conv(r)))) then do
           heap(conv(r))   := setElement(conv(r),i,v)
           opd             := opd'
           pc              := pc + 1 
       else skip 
  _ -> skip

createArray :: (JavaType, Dimension, Val) -> Rule(Word)
createArray (t, d,  i  :  is  ) =                 
  create r do
   if d == 1 then do
     heap(r) := Array(t, copy(conv(i))(dflt( t ) ))
     result(setReferenceType(r))
    else do
     let TJArray(elemType) = t
     rlet vs ::= rforall x <- [1..conv(i)] do
        rlet r ::= createArray(elemType,d-1,is)
        result([r])
     heap(r) := Array(t, vs)
     result(setReferenceType(r))

arrayType :: Ref -> JavaType
arrayType(r) = t               
   where Array(t, arr) = heap(r)

isArray :: VerifyType -> Bool
isArray(VTReference(VTArray([VTInt])))                      = True
isArray(VTReference(VTArray([VTLowLong,VTHighLong])))       = True
isArray(VTReference(VTArray([VTFloat])))                    = True
isArray(VTReference(VTArray([VTLowDouble,VTHighDouble])))   = True
isArray(t)    = t `runCompatible`   
      VTReference(VTArray([VTReference(VTClass(object ))]))              

arrayElemType :: VerifyType -> VerifyType
arrayElemType (VTReference(VTArray([t])))   = t                   
arrayElemType (VTReference(VTNull))         = VTReference(VTNull)
arrayElemType (VTReferenceSet(rs))   =  
   bigTypeMerge({ arrayElemType(VTReference(r)) | r <-: rs }) 
    where bigTypeMerge = foldr1 typeMerge . expr2list
arrayElemType (_)                  = error "arrayElemType"

unusable(c) = (classState(c) == Unusable)               

fail(c)    = (object  :/ ("<fail"++c++">", []))          
raise(c)   = (switch := Call(fail(c), []))               

execVM__E(instr) = do              
  execVM__O(instr)
  case instr of

    Athrow -> do let [r] = takeTop(opd, 1)
                 if conv(r) /= 0  then  
                   switch := Throw(conv(r))
                  else                                  
                   raise("NullPointerException") 

    Jsr(s) -> do opd   := opd ++ [(pc+1,WTRetAddr(s))]
                 pc    := s                                            

    Ret(x) -> pc := conv(reg#(x))                             
    Prim(p) -> do let ws = takeTop(opd, argSize(p))
                  if ( conv(p) `elem` divMod )  &&  
                            sndArgIsZero(ws) then do
                    raise("ArithmeticException")  
                   else skip                                
    MGetField(_,c:/f,_) -> do let [r] = takeTop(opd, 1)
                              if conv(r) == 0  then  
                                raise("NullPointerException")  
                               else skip                                    
    MPutField(_,c:/f,_) -> do let  r  :  ws   = takeTop(opd,  
                                                1+size(c:/f))
                              if conv(r) == 0  then  
                                raise("NullPointerException")  
                               else skip                                    
    MInvokeSpecial(_,c:/m,_) -> do 
                                let  r  :  ws   = takeTop(opd,  
                                                   1+argSize(c:/m))
                                if conv(r) == 0  then do  
                                  raise("NullPointerException")  
                                 else skip                                         
    MInvokeVirtual(_, c:/m,_) -> do 
                                 let  r  :  ws   = takeTop(opd,  
                                          1+argSize(c:/m))
                                 if conv(r) == 0  then  
                                   raise("NullPointerException")  
                                  else skip   

    Checkcast(c) -> do let r = conv(top(opd))
                       if r /= 0 && not( (typeOf( r )  `runCompatible`  
                                       head( typeTJVT(c) ) ) )  then
                         raise("ClassCastException")  
                        else skip                                     

    NewArray(t,d) -> do                            
      let ds = takeTop(opd,d)
      if (any (\ i  ->  i<conv(0) ) ( ds ))  then
        raise("NegativeArraySizeException")
       else skip 
    ArrayLength -> do                 
      if conv(top(opd)) == 0  then
        raise("NullPointerException")
       else skip 
    ALoad(t) -> do           
      let [r,i] = takeTop(opd,2)
      if conv(r) == 0  then
         raise("NullPointerException")
       else if  i < conv(0) || i >= arraySize(conv(r)) then
         raise("ArrayIndexOutOfBoundsException")
       else skip 
    AStore(t) -> do            
      let [[r,i],v] = tops(opd,[2,size(t)])
      if conv(r) == 0  then
         raise("NullPointerException")
       else if  i < conv(0) || i >= arraySize(conv(r)) then
         raise("ArrayIndexOutOfBoundsException")
       else if  t == AMTObject && conv(v) /= 0  && 
               not( ([typeOf( conv(v) ) ]  
                       `listCompatible` typeTJVT(arrayType(conv(r)))) )  then 
         raise("ArrayStoreException")
       else skip 

    _ -> skip

trustfulScheme__N(nativeVM, switchVM) =                      
  if switch == Noswitch && isNative(meth) then
    nativeVM
  else
    trustfulScheme__C(execVM__E, switchVM)

execVM__N =              

  let c:/m = meth in 
  if c == printStream  then
   execPrintStream(m)
  else if  c == stringBuffer  then
   execStringBuffer(m)
  else if  c == string  then
   execString(m)
  else

  if meth == object  :/ equals  then
      switch := Result(conv(reg#(0)==reg#(1)))

    else if  meth == object  :/ toString  then do
      n <- lookupString(cNm(classOf(conv(reg#(0)))))
      switch := Result([setReferenceType(n)])
    else if  meth == fileInputStream :/ fileInputRead then do
      let r    = conv(reg#(0))
      let rArr = conv(reg#(1)) :: Int
      let name = stringOf(conv(mGetInstanceField(r,fileInputStream:/"filename")))
      let filename = take (length name-6) name ++ ".j"
      p <- locateFile(classPath,filename)
      case p of
        Just(p) -> do
          switch := Result([conv(1)])
          heap(rArr) := Array(TJByte,[[(0,WTInternal (p++filename))]])
        _ -> do
          switch := Result([conv(0)])

    else if  meth == object  :/ clone  then do
      let r = conv(reg#(0))
      if classOf(r) `runCompatibleClassClass` cloneable  then do
        create r' do
          heap(r')   := heap(r)
          switch     := Result(conv(setReferenceType(r'))) 
       else
       raise("CloneNotSupportedException")
   else skip 

execPrintStream :: MSig -> Rule ()
execPrintStream (m) = do                     
  if m == printLn  then do
         stdout   := newline
         switch   := Result([]) 
   else skip 
  if m == printI  then do
         stdout   := show(conv(reg#(1)) :: Int)
         switch   := Result([]) 
   else skip 
  if m == ("print",   [TJBoolean]) then do
         stdout   := show(conv(reg#(1)) :: Bool)
         switch   := Result([]) 
   else skip 
  if m == ("print",   [TJChar]) then do
         stdout   := show(conv(reg#(1)) :: Char)
         switch   := Result([]) 
   else skip 
  if m == ("print",   [TJFloat]) then do
         stdout   := show(conv(reg#(1)) :: Float)
         switch   := Result([]) 
   else skip 
  if m == ("print",   [TJLong]) then do
         stdout   := show(conv(reg#(1)) :: Int)
         switch   := Result([]) 
   else skip 
  if m == ("print",   [TJDouble]) then do
         stdout   := show(conv(reg#(1)) :: Float)
         switch   := Result([]) 
   else skip 
  if m == printStr  then do
     let r = conv(reg#(1))
     if r == 0 then
       raise("NullPointerException")
      else do
       stdout   := stringOf(r)
       switch   := Result([]) 
   else skip 

execStringBuffer :: MSig -> Rule ()
execStringBuffer (m) =                      
  if m == appendStr  then do
     let r1 = conv(reg#(0)) :: Int
         r2 = conv(reg#(1)) :: Int
     if r1 == 0 || r2 == 0 then
       raise("NullPointerException")
      else do
       let str = stringOf(r1) ++ stringOf(r2)
       n <- lookupString(str)
       switch := Result([setReferenceType(n)])
  else skip 

execString :: MSig -> Rule ()
execString (m) = do                
  if m == valueOfI  then do
    n <- lookupString(show(conv(reg#(0)) :: Int))
    switch := Result([setReferenceType(n)])
   else skip 
  if m == valueOfObject then do
    if (classOf(conv(reg#(0))) `runCompatible` string) then
      switch := Result([reg#(0)])
     else do
      n <- lookupString(cNm(classOf(conv(reg#(0)) :: Int)))
      switch := Result([setReferenceType(n)])
   else skip 
  if m == stringLength then do
    let r = conv(reg#(0))::Int
    switch := Result([conv(length(stringOf(r)))])
   else skip 
  if m == stringConcat then do
     let r = conv(reg#(1))::Int
     if r == 0 then raise("NullPointerException")
      else do
       let str = stringOf(conv(reg#(0))) ++ stringOf(r)
       n <- lookupString(str)
       switch := Result([setReferenceType(n)])
   else skip 
  if m == stringStartsWith then do
     let r = conv(reg#(1))::Int
     if r == 0 then raise("NullPointerException")
      else
       if stringOf(r) `isPrefix` stringOf(conv(reg#(0))) then
         switch := Result([(1,WTInt)])
       else
         switch := Result([(0,WTInt)])
   else skip 

raiseString(c,str) = do
  n <- lookupString(str)
  switch := Call(failString(c), [(n,WTReference)])

failString(c) = (object  :/ ("<fail"++c++">", [TJRef(string)]))

prepareClass :: Class -> Rule ()
prepareClass (c) = do                  
   forall f <-: staticFields(c) do 
    globals(c :/ f) := dflt( javaFieldType(c :/ f) ) 

stringOf :: Ref -> String
stringOf(r) = case heap(r) of              
   String(s) -> s
   JVMObject(c,fields) -> stringOf(conv(fields#(string:/"value")))
