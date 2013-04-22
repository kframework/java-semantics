liftClass :: Class -> Class
liftClass(c) = cOf(ldEnv(c))               

callLoad :: Class -> Rule ()
callLoad(ld,cn) = do              
  rlet n ::= lookupString(cn)
  switch := Call(cload , [setReferenceType(ld),setReferenceType( n  )])

