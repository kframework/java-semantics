diligentVM__I =                  
   if notEmptyDom(changed) then
     verifyScheme__I(code( vmeth ) ,maxOpd( vmeth ) ,propagateVM__I,succ__I, check__I)
    else
     trustfulVM__I
diligentVM__C = diligentScheme(verifyVM,trustfulVM__C)                  
  where verifyVM = verifyScheme__C(propagateVM__I,succ__C, check__C)
diligentVM__O = diligentScheme(verifyVM, trustfulVM__O)                  
  where verifyVM = verifyScheme__C(propagateVM__I,succ__O, check__O)
diligentVM__E = diligentScheme(verifyVM, trustfulVM__E)                  
  where verifyVM = verifyScheme__C(propagateVM__E,succ__E, check__E)
diligentVM__N = diligentScheme(verifyVM, trustfulVM__N)                  
  where verifyVM = verifyScheme__N(check__N)
diligentVM__D = diligentScheme(verifyVM, trustfulVM__D)                   
 where verifyVM = verifyScheme__N(check__D)
