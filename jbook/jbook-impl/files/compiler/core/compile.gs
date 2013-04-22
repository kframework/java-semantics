compileExp :: CompileEnv -> Pos -> Exp -> ShowI

compileExp( env )( pos )(  Term(Lit( lit ),_)[]  )         = outputInstr(primConstant(lit))  

compileExp( env )( pos )( Term(LocAcc( loc ), t )[]  )     = outputInstr(Load(toMoveType( convertType(t)  ), 
                                                  locNum(env,loc)))  

compileExp( env )( pos )( Term(LocInc( loc ), t )[]  )     = outputInstr(Load(toMoveType( convertType(t)  ), 
                                                  locNum(env,loc))) +.+  
                                   outputInstr(Iinc(locNum(env,loc),conv(1))) 
compileExp( env )( pos )( Term(LocDecr( loc ), t )[]  )     = outputInstr(Load(toMoveType( convertType(t)  ), 
                                                  locNum(env,loc))) +.+  
                                    outputInstr(Iinc(locNum(env,loc),conv(-1))) 

compileExp( env )( pos )( Term(LocAss( loc ),_)[ exp ]  )     = compileExp( env )( pos )( exp )  +.+  
                                     outputInstr(Dupx(0,size(typeOfExp(exp)))) +.+  
                                     outputInstr(Store(toMoveType(convertType(typeOfExp(exp))), 
                                                   locNum(env,loc)))  

compileExp( env )( pos )(  Term(Una( uop ),_)[ e ]  )  |  uop   `elem` [ "b2s", "s2i","c2i","s2b" ] = compileExp( env )( (0: pos )  )(  e ) 
compileExp( env )( pos )( Term(Una("!"),_)[ exp ]  )       = compileBoolT( env )( (0: pos )  )( exp , unaLab(pos,1) )  +.+  
                                   outputInstr(primConstant(TI(1))) +.+  
                                   outputInstr(LabGoto(unaLab(pos,2))) +.+
                                   outputInstr(LabInstr(unaLab(pos,1))) +.+  
                                   outputInstr(primConstant(TI(0))) +.+  
                                   outputInstr(LabInstr(unaLab(pos,2)))  

compileExp( env )( pos )( Term(Una( uop ),_)[ exp ]  )         = compileExp( env )( (0: pos )  )( exp )  +.+  
                                      uapplyInstr( uop  ,typeOfExp(exp))  

compileExp( env )( pos )( Term(Bin("&&"),_)[ e1 , e2 ]  )     = compileBoolF( env )( (0: pos )  )( e1 , binLab(pos,1) )  +.+  
                                   compileBoolF( env )( (1: pos )  )( e1 , binLab(pos,1) )  +.+  
                                   outputInstr(primConstant(TI(1))) +.+  
                                   outputInstr(LabGoto(binLab(pos,2))) +.+
                                   outputInstr(LabInstr(binLab(pos,1))) +.+  
                                   outputInstr(primConstant(TI(0))) +.+  
                                   outputInstr(LabInstr(binLab(pos,2)))  

compileExp( env )( pos )( Term(Bin("||"),_)[ e1 , e2 ]  )     = compileBoolT( env )( (0: pos )  )( e1 , binLab(pos,1) )  +.+  
                                  compileBoolT( env )( (1: pos )  )( e2 , binLab(pos,1) )  +.+  
                                  outputInstr(primConstant(TI(0))) +.+  
                                  outputInstr(LabGoto(binLab(pos,2))) +.+ 
                                  outputInstr(LabInstr(binLab(pos,1))) +.+  
                                  outputInstr(primConstant(TI(1))) +.+  
                                  outputInstr(LabInstr(binLab(pos,2)))  

compileExp( env )( pos )( Term(Bin( bop ),_)[ exp1 , exp2 ]  )     = compileExp( env )( (0: pos )  )( exp1 )  +.+  
                                        compileExp( env )( (1: pos )  )( exp2 )  +.+  
                                        bapplyInstr( bop  ,pos,typeOfExp(exp1),typeOfExp(exp2))  

compileExp( env )( pos )( Term(IfExp,_)[ exp0 , exp1 , exp2 ]  )      = compileBoolT( env )( (0: pos )  )( exp0 , ifLab(pos,1) )  +.+  
                                            compileExp( env )( (2: pos )  )( exp2 )  +.+  
                                            outputInstr(LabGoto(ifLab(pos,2))) +.+  
                                            outputInstr(LabInstr(ifLab(pos,1))) +.+  
                                            compileExp( env )( (1: pos )  )( exp1 )  +.+  
                                            outputInstr(LabInstr(ifLab(pos,2)))  

compileExp( env )( pos )( Term(ClassAcc( c  :/  f ), t )[]  )      = outputInstr(MGetStatic( t  , (1, c ) :/f,undefined))  

compileExp( env )( pos )( Term(ClassAss( c  :/  f ), t )[ exp ]  )    = compileExp( env )( (0: pos )  )( exp )  +.+  
                                        outputInstr(Dupx(0,size(typeOfExp(exp)))) +.+  
                                        outputInstr(MPutStatic( t  , (1, c ) :/f,undefined))  

compileExp( env )( pos )( Term(ClassInv( c  :/  ms ), t )[ exps ]  )    = compileExp( env )( (0: pos )  )( exps )  +.+  
                                            outputInstr(MInvokeStatic( t  ,  
                                                          (1, c ) :/  ms  ,undefined))  

compileExp( env )( pos )( Term(ArgList,TJVoid) exps   )  = concatInstr( compileExp(env) , 0 , pos , exps ) 

compileExp( env )( pos )( Term(This,_)[]  )                = outputInstr(Load(MTAddr,0))  

compileExp( env )( pos )( Term(NewClass( c ),_)[]  )    = outputInstr(New((1, c ) )) +.+  
                           outputInstr(Dupx(0,1))  

compileExp( env )( pos )( Term(FieldAcc( "Array"  :/  "length" ), t )[ exp ]  )    = compileExp( env )( (0: pos )  )( exp )  +.+  
                                                     outputInstr(ArrayLength)

compileExp( env )( pos )( Term(FieldAcc( c  :/  f ), t )[ exp ]  )     = compileExp( env )( (0: pos )  )( exp )  +.+  
                                         outputInstr(MGetField( t  , (1, c ) :/f,undefined))  

compileExp( env )( pos )( Term(FieldAss( c  :/  f ), t )[ exp1 , exp2 ]  )    = compileExp( env )( (0: pos )  )( exp1 )  +.+  
                                              compileExp( env )( (1: pos )  )( exp2 )  +.+  
                                              outputInstr(Dupx(1,size( t  ))) +.+
                                              outputInstr(MPutField( t  , (1, c ) :/f,undefined))  

compileExp( env )( pos )( Term(InstanceInv( c  :/  ms )  k , t )[ exp , exps ]  )    = compileExp( env )( (0: pos )  )( exp )  +.+  
                                                     compileExp( env )( (1: pos )  )( exps )  +.+
                                                     case  k   of
                                                         Virtual      -> outputInstr(MInvokeVirtual ( t  ,  
                                                                             (1, c )  :/  ms  ,undefined))
                                                         Super       -> outputInstr(MInvokeSpecial ( t  ,  
                                                                               (1, c )  :/  ms  ,undefined))
                                                         Special      -> outputInstr(MInvokeSpecial ( t  ,  
                                                                                    (1, c )  :/  ms  ,undefined))  

compileExp( env )( pos )( Term(Instanceof( c ),_)[ exp ]  )    = compileExp( env )( (0: pos )  )( exp )  +.+  
                                      outputInstr(InstanceOf(c))  

compileExp( env )( pos )( Term(Classcast( c ),_)[ exp ]  )     = compileExp( env )( (0: pos )  )( exp )  +.+  
                                      outputInstr(Checkcast(c))  

compileExp( env )( pos )( Term(ArrayAcc, t )[ exp1 , exp2 ]  )     = compileExp( env )( (0: pos )  )( exp1 )  +.+  
                                           compileExp( env )( (1: pos )  )( exp2 )  +.+  
                                           outputInstr(ALoad(toArrayMoveType( t  )))  

compileExp( env )( pos )( Term(ArrayAss, t )[ exp1 , exp2 , exp3 ]  )    = compileExp( env )( (0: pos )  )( exp1 )  +.+  
                                               compileExp( env )( (1: pos )  )( exp2 )  +.+  
                                               compileExp( env )( (2: pos )  )( exp3 )  +.+
                                               outputInstr(Dupx(2,size( t  ))) +.+  
                                               outputInstr(AStore(toArrayMoveType(typeOfExp(exp3))))  

compileExp( env )( pos )( Term(NewJavaArray, t ) dims   )    = concatInstr( compileExp(env) , 0 , pos , dims )  +.+  
                                         outputInstr(NewArray( arrayType(t)  , 
                                                length(dims)  ))  

compileExp(env)(pos)(exp) = error ("INTERNAL ERROR: unknown expression "
   ++ show'(exp))

compileStm :: CompileEnv -> Pos -> Stm -> ShowI
compileStm( env )( pos )( Term(SSkip,_)[]  )              = emptyCode  

compileStm( env )( pos )( Term(ExpStm,_)[ exp ]  )       = compileExp( env )( (0: pos )  )( exp )  +.+  
                                        outputInstr(Pop(size(convertType(typeOfExp(exp))))) 
compileStm( env )( pos )( Term(Block,_)[]  )            = emptyCode
compileStm( env )( pos )( Term(Block,_) ss   )     =  let env' = extendCompileEnvVars(env,ss) in    
                                          concatInstr( compileStm(env') , 0 , pos , ss )   

compileStm( env )( pos )( Term(IfStm,_)[ exp , stm1 , stm2 ]  )    = compileBoolT( env )( (0: pos )  )( exp , ifLab(pos,1) )  +.+  
                                              compileStm( env )( (2: pos )  )( stm2 )  +.+  
                                              outputInstr(LabGoto(ifLab(pos,2))) +.+
                                              outputInstr(LabInstr(ifLab(pos,1))) +.+  
                                              compileStm( env )( (1: pos )  )( stm1 )  +.+  
                                              outputInstr(LabInstr(ifLab(pos,2)))  

compileStm( env )( pos )( Term(While,_)[ exp ,  stm ]  )    = outputInstr(LabGoto(whileLab(pos,1))) +.+  
                                        outputInstr(LabInstr(whileLab(pos,2))) +.+  
                                        compileStm( env )( (1: pos )  )( stm )  +.+
                                        outputInstr(LabInstr(whileLab(pos,1))) +.+  
                                        compileBoolT( env )( (0: pos )  )( exp , whileLab(pos,2) )   

compileStm( env )( pos )( Term(LabStm( lab ),_)[ Term(For  l   i , t )[ init , c , u , s ]  ]  )     =  let env2 = extendCompileEnvLab(env,(lab,breakLab(pos),LBreak)) in    
                                                       compileStm( env2 )( (0: pos )  )( Term(For  l   i , t )[ init , c , u , s ]  )  +.+  
                                                       outputInstr(LabInstr(breakLab( pos ) ))  

compileStm( env )( pos )( Term(LabStm( lab ),_)[ stm ]  )     =  let env1 = extendCompileEnvLab(env,(lab,continueLab(pos),LContinue)) in    
                                           let env2 = extendCompileEnvLab(env1,(lab,breakLab(pos),LBreak)) in    
                                          outputInstr(LabInstr(continueLab( pos ) )) +.+  
                                          compileStm( env2 )( (0: pos )  )( stm )  +.+  
                                          outputInstr(LabInstr(breakLab( pos ) ))  

compileStm( env )( pos )( Term(LocDec _  loc ,_)[]  )       = emptyCode  

compileStm( env )( pos )( Term(LocDec _  loc ,_)[ e ]  )    = compileExp( env )( (0: pos )  )( e )  +.+  
                                        outputInstr(Store(toMoveType(convertType(typeOfExp(e))),  
                                                   locNum(env,loc)))  

compileStm( env )( pos )( Term(For  lab   i , t )[ init , c , u , s ]  )  =
                 let env1 = extendCompileEnvVars(env,flattenBlock init)   in
                 let env' = extendCompileEnvLab(env1,(lab,forLab(pos,3),LContinue)) in  
                (if i then concatInstr( compileStm(env') , 0 , (0: pos )  , flattenBlock init )  
                      else concatInstr( compileStm(env') , 0 , (0: pos )  , 
                            [Term(ExpStm,TJVoid)[e] | e <- flattenBlock init] ) ) +.+
                outputInstr(LabGoto(forLab(pos,1))) +.+
                outputInstr(LabInstr(forLab(pos,2))) +.+ 
                compileStm( env' )( (3: pos )  )( s )  +.+
                outputInstr(LabInstr(forLab(pos,3))) +.+ 
                concatInstr( compileStm(env') , 0 , (2: pos )  , 
                          [Term(ExpStm,TJVoid)[e] | e <- flattenBlock u] )  +.+
                outputInstr(LabInstr(forLab(pos,1))) +.+ 
                compileBoolT( env' )( (1: pos )  )( c , forLab(pos,2) ) 

compileStm( env )( pos )( Term(Continue( lab ),_)[]  )     = jumpToFinally(env,lab) +.+  
                                        outputInstr(LabGoto( labNum(env,lab,LContinue)  ))  

compileStm( env )( pos )( Term(Break( lab ),_)[]  )        = jumpToFinally(env,lab) +.+  
                                        outputInstr(LabGoto( labNum(env,lab,LBreak)  ))  

compileStm( env )( pos )( Term(StaticInit,_)[ stm ]  )  = compileStm( env )( pos )( stm ) 

compileStm( env )( pos )( Term(JavaReturn _,_)[]  )            = finallyLabs(env) +.+  
                                        outputInstr(Return(MTvoid ))   

compileStm( env )( pos )( Term(JavaReturn tries,_)[ exp ]  )      = 
                                         if finallyCodeToExec(env) then
                                            compileExp( env )( (0: pos )  )( exp )  +.+  
                                            outputInstr(Store(toMoveType(convertType(typeOfExp(exp))),  
                                                        returnLocNum(env,"<returnReg>" ,tries))) +.+
                                            finallyLabs(env) +.+  
                                            outputInstr(Load(toMoveType(convertType(typeOfExp(exp))),  
                                                       returnLocNum(env,"<returnReg>" ,tries))) +.+  
                                            outputInstr(Return(toMoveType(convertType(typeOfExp(exp))))) 
                                           else
                                             compileExp( env )( (0: pos )  )( exp )  +.+  
                                             outputInstr(Return(toMoveType(convertType(typeOfExp(exp))))) 

compileStm( env )( pos )( Term(ThrowExc,_)[ exp ]  )        = compileExp( env )( (0: pos )  )( exp )  +.+  
                                         outputInstr(Athrow)  

compileStm( env )( pos )( Term(Try,_)( stm : ss )  )   =
     outputInstr(LabInstr(tryLab(pos))) +.+  
     compileStm( env )( (0: pos )  )( stm )  +.+  
     outputInstr(LabInstr(tryEndLab(pos))) +.+  
     outputInstr(LabGoto(tryCatchEndLab(pos))) +.+
     concatInstr( compileCatch(env,tryEndLab(pos)) , 1 , pos , ss )  +.+
     outputInstr(LabInstr(tryCatchEndLab(pos)))  

compileStm( env )( pos )( Term(Finally _,TJVoid)[ stm1 , stm2 ]  )   =
      let (envT,envF) = extendCompileFinally(env) in    
      let env' = extendCompileEnvLab(envT,("<FIN>",finLab(pos),LFinally)) in    
     outputInstr(LabInstr(finLabStart(pos))) +.+  
     compileStm( env' )( (0: pos )  )( stm1 )  +.+  
     outputInstr(LabJsr(finLab(pos))) +.+  
     outputInstr(LabGoto(finEndLab(pos))) +.+
     outputInstr(LabInstr(catchAllLab(pos))) +.+  
     outputInstr(Store(MTAddr,locNum(envF,"<throwReg>" ))) +.+  
     outputInstr(LabJsr(finLab(pos))) +.+  
     outputInstr(Load(MTAddr,locNum(envF,"<throwReg>" ))) +.+  
     outputInstr(Athrow) +.+
     outputInstr(LabInstr(finLab(pos))) +.+  
     outputInstr(Store(MTAddr,locNum(envF,"<retReg>" ))) +.+  
     compileStm( envF )(  1:pos   )( stm2 )  +.+  
     outputInstr(Ret(locNum(envF,"<retReg>" ))) +.+
     outputInstr(LabInstr(finEndLab(pos)))  

compileStm(env)(pos)(Term(SynBlock,_)[ exp , stm ] )
  = error "cannot compile synchronized statements"
compileStm(env)(pos)(stm) = error ("INTERNAL ERROR: unknown statement " 
   ++ show'(stm))

compileCatch :: (CompileEnv, LabName) -> Pos -> Stm -> ShowI
compileCatch( env , l )( pos )( Term(Catch(c,loc),_)[s] )  = 
     outputInstr(LabInstr(catchLab(pos))) +.+
     let env' = extendCompileVars(env,loc) in
     outputInstr(Store(MTAddr,locNum(env',loc))) +.+
     compileStm( env' )( pos )( s )  +.+
     outputInstr(LabGoto(l))

compileExcsCatch(l1,l2)(pos)(Term(Catch(c,loc),_)[s]) =
     compileExcs( pos )( s )  +.+
     outputExc(ExcL(l1,l2,catchLab(pos),(1, c ) ))

compileBoolT :: CompileEnv -> Pos -> (Exp, LabName) -> ShowI
compileBoolT( env )( pos )( Term(Lit(TB(True)),_)[]  , lab )           = outputInstr(LabGoto(lab))  

compileBoolT( env )( pos )( Term(Lit(TB(False)),_)[]  , lab )          = emptyCode  

compileBoolT( env )( pos )( Term(Una("!"),_)[ exp ]  , lab )       = compileBoolF( env )( (0: pos )  )( exp , lab )   

compileBoolT( env )( pos )( Term(Bin("&&"),_)[ e1 , e2 ]  , lab )     = compileBoolF( env )( (0: pos )  )( e1 , binLab(pos,1) )  +.+  
                                              compileBoolT( env )( (1: pos )  )( e2 , lab )  +.+  
                                              outputInstr(LabInstr(binLab(pos,1)))  

compileBoolT( env )( pos )( Term(Bin("||"),_)[ e1 , e2 ]  , lab )      = compileBoolT( env )( (0: pos )  )( e1 , lab )  +.+  
                                              compileBoolT( env )( (1: pos )  )( e2 , lab )  

compileBoolT( env )( pos )( Term(IfExp,_)[ exp0 , exp1 , exp2 ]  , lab )    = compileBoolT( env )( (0: pos )  )( exp0 , ifLab(pos,1) )  +.+  
                                                     compileBoolT( env )( (2: pos )  )( exp2 , lab )  +.+  
                                                     outputInstr(LabGoto(ifLab(pos,2))) +.+
                                                     outputInstr(LabInstr(ifLab(pos,1))) +.+  
                                                     compileBoolT( env )( (1: pos )  )( exp1 , lab )  +.+  
                                                     outputInstr(LabInstr(ifLab(pos,2)))  

compileBoolT( env )( pos )( exp , lab )               = compileExp( env )( pos )( exp )  +.+  
                                              outputInstr(LabCond("ifne" ,lab)) 

compileBoolF :: CompileEnv -> Pos -> (Exp, LabName) -> ShowI
compileBoolF( env )( pos )( Term(Lit(TB(True)),_)[]  , lab )            = emptyCode  

compileBoolF( env )( pos )( Term(Lit(TB(False)),_)[]  , lab )           = outputInstr(LabGoto(lab))  

compileBoolF( env )( pos )( Term(Una("!"),_)[ exp ]  , lab )        = compileBoolT( env )( (0: pos )  )( exp , lab )   

compileBoolF( env )( pos )( Term(Bin("&&"),_)[ e1 , e2 ]  , lab )      = compileBoolF( env )( (0: pos )  )( e1 , lab )  +.+  
                                               compileBoolF( env )( (1: pos )  )( e2 , lab )  
compileBoolF( env )( pos )( Term(Bin("||"),_)[ e1 , e2 ]  , lab )       = compileBoolT( env )( (0: pos )  )( e1 , binLab(pos,1) )  +.+  
                                               compileBoolF( env )( (1: pos )  )( e2 , lab )  +.+  
                                               outputInstr(LabInstr(binLab(pos,1))) 

compileBoolF( env )( pos )( Term(IfExp,_)[ exp0 , exp1 , exp2 ]  , lab )       = compileBoolT( env )( (0: pos )  )( exp0 , ifLab(pos,1) )  +.+  
                                                        compileBoolF( env )( (2: pos )  )( exp2 , lab )  +.+  
                                                        outputInstr(LabGoto(ifLab(pos,2))) +.+
                                                        outputInstr(LabInstr(ifLab(pos,1))) +.+  
                                                        compileBoolF( env )( (1: pos )  )( exp1 , lab )  +.+  
                                                        outputInstr(LabInstr(ifLab(pos,2)))  

compileBoolF( env )( pos )( exp , lab )                = compileExp( env )( pos )( exp )  +.+  
                                               outputInstr(LabCond("ifeq" ,lab)) 

opdSize :: Phrase -> Nat
opdSize(phrase) = case phrase of             
  Term(Lit( lit ),_)[]                   -> s
  Term(LocAcc( loc ), _ )[]              -> s

  Term(LocInc( loc ), _ )[]              -> s
  Term(LocDecr( loc ), _ )[]             -> s

  Term(LocAss( loc ),_)[ exp ]            -> mMax(opdSize(exp),2 * s)
  Term(Una( op ),_)[ exp ]                -> mMax(opdSize(exp), s)
  Term(Bin( op ),_)[ exp1 , exp2 ]          -> mMax(opdExps([exp1, exp2]), s)
  Term(IfExp,_)[ exp1 , exp2 , exp3 ]      -> mMax(opdSize(exp1),
                                    mMax(opdSize(exp2),opdSize(exp3))) 
  Term(ExpStm,_)[ exp ]                -> opdSize(exp)
  Term(Block,_) ss             -> opdStms( ss  )
  Term(IfStm,_)[ exp , stm1 , stm2 ]       -> mMax(opdSize(exp),opdStms([stm1,stm2]))
  Term(While,_)[ exp ,  stm ]             -> mMax(opdSize(exp),opdSize(stm))
  Term(LabStm( lab ),_)[ stm ]            -> opdSize(stm)
  Term(ClassAcc( c  :/  f ), t )[]            -> s
  Term(ClassAss( c  :/  f ), _ )[ exp ]        -> mMax(opdSize(exp), 2 * s)
  Term(ClassInv( c  :/  ms ), _ )[ exps ]    -> mMax(opdSize(exps), s)
  Term(ArgList,TJVoid) exps         -> opdExps( exps  )
  Term(StaticInit,_)[ stm ]            -> opdSize(stm)
  Term(JavaReturn tries,_)[ exp ]               -> opdSize(exp)
  Term(This,_)[]                       -> 1
  Term(InstanceInv (_:/("<init>",_)) Special,_)[Term(NewClass( c ),_)[], exps ]          -> 2 + opdSize(exps)
  Term(FieldAcc( c  :/  f ), _ )[ exp ]        -> mMax(opdSize(exp), s)
  Term(FieldAss( c  :/  f ), _ )[ exp1 , exp2 ]    -> mMax(opdExps([exp1, exp2]), 1+2*s)
  Term(InstanceInv( c  :/  ms )  k , _ )[ exp , exps ]    -> mMax(opdExps([exp,exps]), s)
  Term(Instanceof( c ),_)[ exp ]          -> opdSize(exp)
  Term(Classcast( c ),_)[ exp ]           -> opdSize(exp)
  Term(ThrowExc,_)[ exp ]                -> opdSize(exp) 
  Term(Try,_)( stm : ss )   ->
     mMax(opdSize(stm),mMax(1,opdStms( ss  )))
  Term(Finally _,TJVoid)[ stm1 , stm2 ]         -> mMax(opdSize(stm1),mMax(1,opdSize(stm2)))
  Term(ArrayAcc, _ )[ exp1 , exp2 ]          -> mMax(opdExps([exp1,exp2]),s)
  Term(ArrayAss, _ )[ exp1 , exp2 , exp3 ]     -> mMax(opdExps([exp1,exp2,exp3]), 
                                             2+2*s)
  Term(NewJavaArray, t ) dims      -> mMax(1,opdExps( dims  ))

  Term(LocDec _  loc ,_)[ exp ]        -> opdSize(exp)
  Term(Catch(c,loc),_)[stm]   -> opdSize(stm)
  Term(For  l  _, t )[ i , c , u , s ]         -> opdStms([i,c,u,s])

  otherwise               -> 0 
 where s = size(typeOfExp(phrase))

opdExps :: [Exp] -> Nat
opdExps([])                = 0             
opdExps(( exp :( exps )) )   = mMax(opdSize(exp),  
                                   size(typeOfExp(exp)) +  
                                   opdExps(exps)) 

opdStms :: [Stm] -> Nat
opdStms([])                = 0             
opdStms(( stm :( stms )) )   = mMax(opdSize(stm), opdStms(stms)) 

compileExcs :: Pos -> Stm -> ShowE

compileExcs( pos )( Term(Try,_)( t : ss )  )   = 
   compileExcs( (0: pos )  )( t )  +.+
   concatExcs(compileExcsCatch(tryLab(pos),tryEndLab(pos)),
              1,pos,ss) 

compileExcs( pos )( Term(Finally _,TJVoid)[ stm1 , stm2 ]  )  = 
    compileExcs( (0: pos )  )( stm1 )  +.+  
    outputExc(ExcL(finLabStart(pos),catchAllLab(pos),  
    catchAllLab(pos),  
    (1, throwableClass ) )) +.+  
    compileExcs( (1: pos )  )( stm2 )   

compileExcs( pos )( Term(Block,_) ss   )                   = concatExcs( compileExcs , 0 , pos , ss )   

compileExcs( pos )( Term(IfStm,_)[ exp , stm1 , stm2 ]  )              = compileExcs( (1: pos )  )( stm1 )  +.+ compileExcs( (2: pos )  )( stm2 )   

compileExcs( pos )( Term(While,_)[ exp ,  stm ]  )                    = compileExcs( (1: pos )  )( stm )   

compileExcs( pos )( Term(LabStm( lab ),_)[ stm ]  )                   = compileExcs( (0: pos )  )( stm )   

compileExcs( pos )( Term(StaticInit,_)[ stm ]  )                   = compileExcs( (0: pos )  )( stm )   

compileExcs( pos )( _ )                                 = emptyExcs

mMax(a,b) = max(a)(b)

