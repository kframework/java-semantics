constraintViolation :: Class -> (Bool, String)
constraintViolation (c) =                         
   if isInterface(c) then notErr( validInterface(c) ) 
   else notErr( validClass(c) ) 
 where notErr(b,s) = (not b,s)

validInterface :: Class -> (Bool,String)
validInterface(c) =                    
   ( isAbstract(c) , "interface must be abstract" )  &&&  
   ( (isJust( super(c) ) && just( super(c) )==  object  )  , itext ++ "super class of interface must be Object" )  &&&
   ( (all (\( c' ) ->  accessible(c,c') && isInterface(c') ) ( implements(c) ))  , itext ++ "interface can only implement accessible interfaces" )  &&&
   (allS (\( m ) ->  validIMeth(c:/m,code(c:/m)) ) ( mdomain( methods(cEnv(c)) )  ))  &&&
   checkEqualVisibleSigs(c)
 where itext = "class " ++ cNm(c) ++ ": "

validClass :: Class -> (Bool,String)
validClass(c) =                
   ( (c == object  || (isJust( super(c) ))  && accessible(c,just( super(c) ) )) , itext ++ "unknown super class" )  &&&
   ( (all (\( c' ) ->  accessible(c,c') && isInterface(c') ) ( implements(c) ))  , itext ++ "class can only implement accessible interfaces" )  &&&
   (allS (\( m ) ->  validCMeth(c:/m,code(c:/m)) ) ( mdomain( methods(cEnv(c)) )  ))  &&&
   checkEqualVisibleSigs(c)
 where itext = "class " ++ cNm(c) ++ ": "

validIMeth :: (MRef,Code) -> (Bool,String)
validIMeth(c:/m,code) =                
 let mods   = modifiers(c:/m) in 
 let len    = length(code) in  
 if mNm(m) == "<clinit>" then
   ( Abstract `notElem` mods , itext ++ "class initialization method must not be abstract" )  &&&
   (allS (\( instr ) ->  validInstr(c:/m,maxReg(c:/m),instr,len) ) ( code )) 
  else
   ( Abstract `elem` mods , itext ++ "interface method must be abstract" )  &&&  
   ( null(code) , itext ++ "interface body must be empty" )  &&&  
   ( Private `notElem` mods , itext ++ "interface method must not be private" )  &&&
   (allS (\( m' ) ->  checkOverride(c:/m,m') ) ( overrideMethods(c:/m) )) 
 where itext    = "method " ++ cNm(c) ++ "/" ++ mNm(m) ++ ": "

validCMeth :: (MRef,Code) -> (Bool,String)
validCMeth(c:/m, code) =                
   let mods    = modifiers(c:/m) in 
   let len     = length(code) in  
   ( null(code) == (Native `elem` mods || Abstract `elem` mods) , itext ++ "method must be native or abstract if body is empty" )  &&&
   ( not( (Abstract `elem` mods && Private `elem` mods) )  , itext ++ "method cannot be abstract and private" )  &&&
   (allS (\( instr ) ->  validInstr(c:/m,maxReg(c:/m),instr,len) ) ( code ))  &&&
   (allS (\( m' ) ->  checkOverride(c:/m,m') ) ( overrideMethods(c:/m) )) 
 where itext    = "method " ++ cNm(c) ++ "/" ++ mNm(m) ++ ": "

checkOverride :: (MRef,(MRef,(JavaType,{Modifier}))) -> (Bool, String)
checkOverride(m,m') =                   
 if mNm(m) == "<clinit>" || mNm(m) == "<init>" then
   ( True , "" ) 
  else
   let mods  = modifiers(m) in 
   let mods' = modifiers(m') in 
   ( javaReturnType(m)==superSigReturnType(m') , itext ++ "invalid return type" )  &&&  
   ( Final `notElem` mods' , itext ++ "method overrides final method" )  &&&
   ( (Static `elem` mods') == (Static `elem` mods) , itext ++ "one method is static" )  &&&  
   ( Private `notElem` mods , itext ++ "method cannot be private" )  &&&
   ( (Public `elem` mods') `implies` (Public `elem` mods) , itext ++ "method must be public" )  &&&
   ( (Protected `elem` mods') `implies` (Public `elem` mods || Protected `elem` mods) , itext ++ "method must be public or protected" ) 
 where itext    = "method " ++ cNm(m) ++ "/" ++ mNm(m) ++ ": "

checkEqualVisibleSigs :: Class -> (Bool, String)
checkEqualVisibleSigs(c) =
  checkVisibleSig(visibleSigs(cEnv(c)))

checkVisibleSig :: SuperSigs -> (Bool, String)
checkVisibleSig([]) = ( True , "" ) 
checkVisibleSig((c1:/msig,(t1,mods1)):ms) =
   (case filter f ms of
     [] -> ( True , "" ) 
     (c2:/_,(t2,mods2)) : _ ->
        ( t1 == t2 ,  itext ++
               "method must have same return type as in class " ++ cNm(c2) )  &&&
        ( (Public `elem` mods1) == (Public `elem` mods2) , itext ++
               "method must have same public modifier as in class " ++ cNm(c2) )  &&&
        ( (Static `elem` mods1) == (Static `elem` mods2) ,  itext ++
               "method must have same static modifier as in class " ++ cNm(c2) ) 
    ) &&&
   checkVisibleSig(ms)
 where f (_:/msig',_) = msig == msig'
       itext = "method " ++ cNm(c1) ++ "/" ++ mNm(msig) ++ ": "

validInstr :: (MRef,Nat,Instr,Int) -> (Bool, String)
validInstr(ctx:/m,maxReg,instr,len) =                
  validAccess(ctx,instr) &&&
  case instr of
    Goto(pc)    ->                           
     ( pc >= 0 && pc < len ,  itext ++ "invalid goto offset" ) 
    Cond(p,pc)   ->                           
     ( pc >= 0 && pc < len ,  itext ++ "invalid cond offset" ) 
    Load(t, x)   ->                           
     ( x >= 0 && x <= maxReg - size(t) ,  itext ++ "invalid register number" ) 
    Store(t, x)   -> ( x >= 0 && x <= maxReg - size(t) &&
                     (x/=0 || mNm(m)/="<init>") ,   
                       itext ++ "invalid register number" )   

    MGetStatic(t,c:/f,sig)   ->                                
     ( isStatic(mSigInfo(c:/f,sig)) ,  itext ++ "field is not static" )  &&&  
     ( checkCType(c:/f,sig,t) ,  itext ++ "invalid field type" ) 
    MPutStatic(t,c:/f,sig)   ->                                
     ( isStatic(mSigInfo(c:/f,sig)) , itext ++ "field is not static" )  &&&  
     ( checkCType(c:/f,sig,t) , itext ++ "invalid field type" )  
    MInvokeStatic(t,c:/m,sig) ->                                 
      ( head(mNm(m)) /= '<' , itext ++ "invalid method name" )  &&&  
      ( isStatic(mSigInfo(c:/m,sig)) , itext ++ "method is not static" )  &&&  
      ( not( isInterface(c) )  , itext ++ "static call to interface method" )   &&&
      ( checkCReturnType(c:/m,sig,t) ,  itext ++ "invalid return type" ) 
    MGetField(t,c:/f,sig) ->                               
      ( not( isStatic(mSigInfo(c:/f,sig)) )  ,  itext ++ "field must not be static" )  &&&  
      ( checkCType(c:/f,sig,t) ,  itext ++ "invalid field type" ) 
    MPutField(t,c:/f,sig) ->                               
      ( not( isStatic(mSigInfo(c:/f,sig)) )  ,  itext ++ "field must not be static" )  &&&  
      ( checkCType(c:/f,sig,t) ,  itext ++ "invalid field type" ) 
    MInvokeSpecial(t,c:/m,sig) ->                                   
      ( mNm(m) == "<init>" || c `elem` supers(ctx) ,  itext ++ "invalid method call" )  &&&
      ( checkCReturnType(c:/m,sig,t) , itext ++ "invalid return type" )  &&&  
      ( not( isStatic(mSigInfo(c:/m,sig)) )  , itext ++ "call to static method" )  &&&  
      ( not( isInterface(c) )  , itext ++ "call to interface method" ) 
    MInvokeVirtual(t,c:/m,sig) ->                                   
      ( mNm(m) /= "<init>" ,  itext ++ "invalid method call to <init>" )   &&&  
      ( not( isStatic(mSigInfo(c:/m,sig)) )  , itext ++ "virtual call to static method" )  &&&  
      ( checkCReturnType(c:/m,sig,t) , itext ++ "invalid return type" ) 
    NewArray(t,d)   ->                               
      ( d <= arrayDim(t) && d <= 255 , itext ++ "invalid dimension" ) 
    New(c)   ->                          
      ( not( isAbstract(c) )  , itext ++ "new of abstract class" ) 
    Jsr(o)   -> ( o >= 0 && o < len , itext ++ "invalid offset for jsr" )   

    Ret(x)   ->                          
      ( x >= 0 && x < maxReg , itext ++ "invalid register for ret" )  
    _  -> ( True ,  "" ) 
 where itext    = "method " ++ cNm(ctx) ++ "/" ++ mNm(m) ++
                  "(instruction " ++ showInstr(instr) "" ++ "): "

validAccess :: (Class, Instr) -> (Bool, String)
validAccess(ctx,instr) =                  
  case instr of
    MGetStatic(t,c:/f,sig)   ->                                     
     ( accessible(ctx,mSigInfo(c:/f,sig)) , itext ++ "static field not accessible" )  &&&  
     ( accessible(ctx,t) , itext ++ "return type not accessible" ) 
    MPutStatic(t,c:/f,sig)   ->                                     
     ( accessible(ctx,mSigInfo(c:/f,sig)) , itext ++ "static field not accessible" )  &&&  
     ( accessible(ctx,t) , itext ++ "return type not accessible" ) 
    MInvokeStatic(t,c:/m,sig)   ->                                        
     ( accessible(ctx,mSigInfo(c:/m,sig)) , itext ++ "static method not accessible" )  &&&  
     ( accessible(ctx,t) , itext ++ "return type not accessible" ) 
    MGetField(t,c:/f,sig)   ->                                    
     ( accessible(ctx,mSigInfo(c:/f,sig)) , itext ++ "instance field not accessible" )  &&&  
     ( accessible(ctx,t) , itext ++ "return type not accessible" ) 
    MPutField(t,c:/f,sig)   ->                                    
     ( accessible(ctx,mSigInfo(c:/f,sig)) , itext ++ "instance field not accessible" )  &&&  
     ( accessible(ctx,t) , itext ++ "return type not accessible" ) 
    MInvokeSpecial(t,c:/m,sig)   ->                                          
     ( accessible(ctx,mSigInfo(c:/m,sig)) ,  itext ++ "instance method not accessible" )  &&&  
     ( accessible(ctx,t) , itext ++ "return type not accessible" ) 
    MInvokeVirtual(t,c:/m,sig)   ->                                          
     ( accessible(ctx,mSigInfo(c:/m,sig)) ,  itext ++ "instance method not accessible" )  &&&  
     ( accessible(ctx,t) , itext ++ "return type not accessible" ) 
    New(c)   ->                               
     ( accessible(ctx,c) ,  itext ++ "new: class not accessible" )  
    _  -> ( True , "" ) 
 where itext    = "class " ++ cNm(ctx) ++ " (instruction " ++
                  showInstr(instr) "" ++ "): "

arrayDim :: JavaType -> Dimension
arrayDim (TJArray(t))   = 1 + arrayDim(t)              
arrayDim (_)            = 1 

violationMsg(cn) =                  
    "Constraint Violation: class " ++ cn
