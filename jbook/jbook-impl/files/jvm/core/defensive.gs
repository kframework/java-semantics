defensiveScheme__I :: (CheckI, Rule ()) -> Rule ()
defensiveScheme__I(check, trustfulVM) = do                       
  let instr = code( meth ) !!pc
  if not( validCodeIndex(code( meth ) ,pc) )  ||
     not( check(instr, maxOpd( meth ) , pc, localTypes(reg), types (opd)) )  then do
      stdout := "Runtime check failed"
      halt   := True
   else
      trustfulVM

validCodeIndex(code,pc) = (0 <= pc && pc < length(code))                    

check__I :: CheckI
check__I (instr, maxOpd, pc, regT, opdT) =              
  case instr of
   Prim(p) -> opdT `hasSuffix` argTypes(p) &&
              not( overflow(maxOpd, opdT, retSize(p)-argSize(p)) )   

   Iinc(x,i) -> regT#(x) `runCompatible` VTInt
   Swap -> let [ws1,ws2] = tops(opdT,[1,1]) in 
           length(opdT) >= 2 && validTypeSeq(ws1) && validTypeSeq(ws2)
   Nop       -> True
   Dupx(s1, s2) -> let [ts1,ts2] = tops(opdT,[s1,s2]) in 
                   length(opdT) >= s1 + s2 && 
                   not( overflow(maxOpd, opdT,s2) )  &&
                   validTypeSeq(ts1) && validTypeSeq(ts2)  

   Pop(s) ->                                
     length(opdT) >= s
   Load(t, x) ->                               
     if size(t) == 1 then  
       ( regT#(x)  : [])  `runCompatibleVerifyTypeMoveType` t && not( overflow(maxOpd, opdT, 1) ) 
     else  
       [ regT#(x), regT#(x+1)] `runCompatibleVerifyTypeMoveType` t &&  
       not( overflow(maxOpd, opdT, 2) ) 
   Store(t, _)   -> opdT `hasSuffix` t  

   Goto(o)       -> True                                             
   Cond(p, o)    -> opdT `hasSuffix` argTypes(p)  

   Halt          -> True                                 
   _    -> False 

overflow :: (Int,[a], Int) -> Bool
overflow (maxOpd,opdT,s) = length(opdT)+s > maxOpd              

defensiveScheme__C (check, trustfulVM) =                       
  if switch == Noswitch then
    defensiveScheme__I(check(meth), trustfulVM)
   else
    trustfulVM

check__C :: Check
check__C (meth)(instr, maxOpd, pc, regT, opdT) =              
   check__I(instr, maxOpd, pc, regT, opdT) ||
   case instr of
     MGetStatic(t,c:/f,_)   ->                                      
       not( overflow(maxOpd, opdT, size(t)) ) 
     MPutStatic(t,c:/f,_)   ->                                      
       opdT `hasSuffix` t
     MInvokeStatic(t,c:/m,_)   -> opdT `hasSuffix` argTypes(c:/m) &&
                                  not( overflow(maxOpd, opdT, size(t)-
                                                              argSize(c:/m)) )   

     Return(t)   -> opdT `hasSuffix` returnType(meth) &&
                    returnType(meth) `runCompatibleVerifyTypeMoveType` t  

     _  -> False 

check__O :: Check
check__O (meth)(instr, maxOpd, pc, regT, opdT) =               
  check__C(meth)(instr,maxOpd, pc, regT, opdT) && endinit(meth,instr,regT) ||
  case instr of
    New(c) ->                                 
      not( overflow(maxOpd, opdT, 1) ) 
    MGetField(t,c:/f,_) ->                                      
      opdT `hasSuffix` mTypeClass(c) &&  
      not( overflow(maxOpd, opdT, size(t)-1) ) 
    MPutField(t,c:/f,_) ->                                      
      opdT `hasSuffix`  
          ( mTypeClass(c) ++ typeTJVT(t) ) 
    MInvokeSpecial(_,c:/m,_) ->                                        
      let  c'  :  _   = takeTop(opdT,1 + argSize(c:/m)) in 
      length(opdT) > argSize(c:/m) &&
      opdT `hasSuffix` argTypes(c:/m) &&
      not( overflow(maxOpd, opdT, retSize(c:/m)-argSize(c:/m)-1) )  &&
      if mNm(m) == "<init>" then
         initCompatible(meth,conv(c'),conv(VTClass(c)))
       else  
         c' `runCompatible` VTReference(VTClass(c))
    MInvokeVirtual(_, c:/m,_) ->                                        
      opdT `hasSuffix` mTypeClass(c) ++ argTypes(c:/m) &&
      not( overflow(maxOpd, opdT, retSize(c:/m)-argSize(c:/m)-1) ) 

    NewArray(t,d)     ->  opdT `hasSuffix` copy(d)(VTInt)               

    ArrayLength       -> length(opdT) > 0 && isArray(top(opdT))  

    ALoad(t)          -> opdT `hasSuffix`  
                             [ VTReference(VTArray(typeAMTVT(t))), VTInt ]  

    AStore(t)         -> opdT `hasSuffix`  
                             [ VTReference(VTArray(typeAMTVT(t))),  
                               VTInt ] ++ typeAMTVT(t)  

    TableSwitch (low,high) dflt  tab -> length(opdT)>0 && 
                                        top(opdT) `runCompatible` VTInt
    LookupSwitch dflt tab -> length(opdT)>0 && top(opdT) `runCompatible` VTInt

    InstanceOf (c)    ->  opdT `hasSuffix` mTypeClass(object )  

    Checkcast(c)      ->    opdT `hasSuffix` mTypeClass(object )  

    LoadString(str)   -> not( overflow(maxOpd, opdT,1) )   

    _        -> False

initCompatible :: (MRef, VerifyType, VerifyType) -> Bool
initCompatible(_, VTNew(c,_), VTReference(VTClass(c')))   = (conv(c) == c')
initCompatible(c:/m, VTInit, VTReference(VTClass(c')))     =  
            (c == c' || (isJust( super(c) ) && just( super(c) )== c' ) )                    
initCompatible(_,_,_) = False

endinit :: (MRef, Instr, Register(VerifyType)) -> Bool
endinit(c:/m,instr,regT) =             
  if isReturn(instr) && mNm(m) == "<init>" && c /= object  then
    0 `elem` mdomain( regT )  && regT#(0) /= VTInit
  else True

check__E :: Check
check__E (meth)(instr, maxOpd, pc, regT, opdT) =              
  check__O(meth)(instr, maxOpd, pc, regT, opdT) ||
  case instr of
    Store(MTAddr, x)   -> length(opdT) > 0 && isRetAddr(top(opdT))  

    Athrow   -> opdT `hasSuffix` mTypeClass(throwable )  

    Jsr(o)   -> not( overflow(maxOpd, opdT,1) )   

    Ret(x)   -> isRetAddr(regT#(x))                                
    _  -> False

defensiveScheme__N(check, trustfulVM) =                        
  if isNative(meth) then
    if check(meth) then trustfulVM
    else do stdout := "unknown native method"
            halt   := True
  else
    defensiveScheme__C(check__E, trustfulVM)

check__N :: MRef -> Bool
check__N(c:/m) =              

    (c,m) == (stringBuffer , appendStr ) ||
    (c == string  && m `elem` 
               [ valueOfI 
               , valueOfObject
               , stringLength
               , stringConcat
               , stringStartsWith]) ||
    (c == printStream  &&
     m `elem`  [ printI , printStr , printLn ,
                 ("print",[TJBoolean]),
                 ("print",[TJFloat]),
                 ("print",[TJLong]),
                 ("print",[TJChar]),
                 ("print",[TJDouble])]) || 
    c:/m == object  :/ toString  ||
    c:/m == fileInputStream :/ fileInputRead ||

    c:/m == object  :/ equals   ||
    c:/m == object  :/ clone 

