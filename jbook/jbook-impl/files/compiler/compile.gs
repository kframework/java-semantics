compileClass :: JavaClass -> ClassFile
compileClass(cNm) =
   let td   = typeDec(cNm)
       mods = javaModifiers(td)
       is   = implements(td)
       s    = super(td)
       fs   = fields(td)
       ms   = methods(td)
       ftab = { convertField(f) | f <- fs }
       mtab = { convertMeth(m)  | m <- ms }
   in  CFile((1,cNm),
             isIface(td), 
             mkSet(mods),
             map (\c -> (1,c)) (super(cNm)), 
             (mapping [],([],[])),
             { (1,c) | c <- implements(cNm) },
             ftab,
             mtab)


convertField :: MemDec -> (FNm, FDec)
convertField(f) =
  (fieldNm(f), FDec(mkSet(javaModifiers(f)), fieldType(f)))


convertMeth :: MemDec -> (MSig, MDec)
convertMeth(m) =
  let msig   = (methNm(m), argumentTypes(m))
      args   = concat $ g (argNames(m)) (argumentTypes(m))
      g [] _ = []
      g [n] [] = [[n]]
      g (n:ns) (t:ts)
             | n == "this" = [n] : g ns (t:ts)
             | size(t) == 2 = [n,n++"'high"] : g ns ts
             | otherwise    = [n] : g ns ts
      sizeRT = size(javaReturnType(m))
      rets   = expr2list(getReturns(bdy))
      locsReturn = case sizeRT of
                    0 -> {}
                    1 -> { ("<returnReg>"++ i,l+length args) 
                         | (i,l) <- zip rets [0..] }
                    2 -> if null rets then {}
                         else 
                          { ("<returnReg>"++ i,2*l+length args) 
                          | (i,l) <- zip rets [0..] } `union`
                          { ("<dummy>",2*(length rets-1)+length args+1) }
                    _ -> error "INTERNAL ERROR: convetMeth"
      locs   = mkSet(zip args [0..]) `union` locsReturn
      env    = (javaReturnType(m),locs, [])
      bdy    = body(m)
      code   | Abstract `elem` javaModifiers(m) || Native `elem` javaModifiers(m)
               = compileStm(env)[](bdy) []
             | otherwise
               = (compileStm(env)[](bdy) +.+ outputInstr(Prim(PrimFun("nop")))) []
      ls     = mkSet(zip (nub(concat (map labels code))) [1..])
      code'  = map (f(ls)) code
      excs   = [ ExcL(name(ls,l1), name(ls,l2), name(ls,l3), c) 
               | ExcL(l1,l2,l3,c) <- compileExcs[](bdy)[]]
      maxOpd = opdSize(bdy)
      maxReg = maximum ((length args-1): [ locNumOfInstr(i) | i <- code ]) + 1
      mdec   = MDec(mkSet(javaModifiers(m)), 
                    javaReturnType(m),
                    code',
                    excs,
                    (maxOpd, maxReg)
                   )
  in  (msig, mdec)
 where name(ls,l@(n,_))    = (n,[ls#(l)])
       f ls (LabGoto(l))   = LabGoto(name(ls,l))
       f ls (LabJsr(l))    = LabJsr(name(ls,l))
       f ls (LabInstr(l))  = LabInstr(name(ls,l))
       f ls (LabCond(p,l)) = LabCond(p,name(ls,l))
       f ls x              = x
