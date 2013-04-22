intOp :: JavaVal -> (Int -> Int) -> JavaVal
intOp v f = intFun(v)(f(intVal(v)))

floatOp :: JavaVal -> (Float -> Float) -> JavaVal
floatOp v f = floatFun(v)(f(floatVal(v)))

 
uapply :: (Una, JavaType, JavaVal) -> JavaVal		-- primitive operations
uapply ("-",t,v)      | integral(t) = intOp v negate
uapply ("-",t,v)      | numeric(t)  = floatOp v negate
uapply ("!",_,TB b)    = TB (not(b))
uapply ("b2s",_,IB i)  = IS(i)
uapply ("s2i",_,IS i)  = TI(i)
uapply ("i2l",_,TI  i) = IL(i)
uapply ("l2f",_,IL i)  = TF(fromInteger(i))
uapply ("f2d",_,TF  f) = FD(f)
uapply ("c2i",_,TC  c) = TI(ord(c))
uapply ("s2b",_,IS i)  = IB(i)
uapply ("i2s",_,TI i)  = IS(i)
uapply ("l2i",_,IL i)  = TI(i)
uapply ("f2l",_,TF f)  = IL(truncate f)
uapply ("d2f",_,FD f)  = TF(f)
uapply ("i2c",_,TI  i) = TC(chr(i))
uapply _ = error "uapply"

bapply :: (Bin,(JavaType, JavaType), JavaVal,JavaVal) -> JavaOp		-- primitive operations
bapply (op,(t1,t2), i, j)
   | op == "%" &&
     integral(t1) && integral(t2)
     = Val(intFun(i)(intVal(i) `mod` intVal(j)))
   | integral(t1) && integral(t2)
     = Val(bapply'(op,intVal(i),intVal(j),intFun(j)))
   | numeric(t1) && numeric(t2)
     = Val(bapply'(op,floatVal(i),floatVal(j),floatFun(j)))
   | op == "+" &&
     (string(t1) || string(t2))
     = if stringNull(i) || stringNull(j) then Lit(NoValue)
       else Lit(TS(stringVal(i) ++ stringVal(j)))
   | op == "=="  && boolean(t1) && boolean(t2)
     = Val(TB (boolVal(i) == boolVal(j)))
   | op == "!="  && boolean(t1) && boolean(t2)
     = Val(TB (boolVal(i) /= boolVal(j)))
   | op `elem` ["==","!="] && refType(t1) && refType(t2)
     = Val(bapply'(op,refVal(i),refVal(j),error "bapply"))
bapply _ = error "bapply"


bapply' :: (Num n, Ord n) => (String, n, n, n -> JavaVal) -> JavaVal
bapply'("==",i, j,f) = TB (i == j)
bapply'("!=",i, j,f) = TB (i /= j)
bapply'("<", i, j,f) = TB (i <  j)
bapply'("<=",i, j,f) = TB (i <= j)
bapply'(">", i, j,f) = TB (i >  j)
bapply'(">=",i, j,f) = TB (i >= j)
bapply'("+", i, j,f) = f (i +  j)
bapply'("-", i, j,f) = f (i -  j)
bapply'("*", i, j,f) = f (i *  j)
bapply'("/", i, j,f) = f (i /  j)
bapply' _            = error "bapply'"


valType :: JavaVal -> JavaType
valType(TR(0)) = TJNull
valType(TR(r)) = typeOfRef(r)
valType(x)    = litType(x)
