type JavaEnv = ( (String,Int)                  -- Filename, line number
               , ([Lab],Nat,String)            -- visible labs, loop depth,
               )                               --       finally depth

type Parser a = StateM Error JavaEnv a

splitDotName [] = []
splitDotName(xs) = 
   takeWhile (/='.') xs : 
   (splitDotName . dropWhile (=='.') . dropWhile (/='.')) xs

removePackage :: String -> String
removePackage(str) = 
    if take l1 str == pack1 then drop l1 str
    else if take l2 str == pack2 then drop l2 str
    else str
 where
   pack1 = "java.lang."
   l1    = length(pack1)
   pack2 = "java.io."
   l2    = length(pack2)


name2variable :: String -> Parser Exp
name2variable(n) = result (fold(splitDotName(removePackage(n))))
 where fold         = fold' . reverse
       fold' [x]    = Term (AccName x,TJNoType) []
       fold' (x:xs) = Term (QualAcc x,TJNoType) [fold'(xs)]

enterLoop :: Parser ()
enterLoop = void $ update (\(a,(labs,depth,tries)) -> (a,(labs,depth+1,tries)))

leaveLoop :: Parser ()
leaveLoop = void $ update (\(a,(labs,depth,tries)) -> (a,(labs,depth-1,tries)))

enterTry :: Parser ()
enterTry = void $ update (\(a,(labs,depth,tries)) -> (a,(labs,depth,'t':tries)))

enterFin :: Parser ()
enterFin = void $ update (\(a,(labs,depth,tries)) -> (a,(labs,depth,'f':tries)))

leaveTry :: Parser ()
leaveTry = void $ update (\(a,(labs,depth,_:tries)) -> (a,(labs,depth,tries)))

leaveFin :: Parser ()
leaveFin = void $ update (\(a,(labs,depth,_:tries)) -> (a,(labs,depth,tries)))

getTries :: Parser String
getTries = do (_,(_,_,tries)) <- update id
              result tries

removeLab :: Parser ()
removeLab = void $ update (\(a,(_:labs,depth,tries)) -> (a,(labs,depth,tries)))



setLineNumber :: Int -> Parser ()
setLineNumber i = void $ update (\((a,_),b) -> ((a,i),b))

getLineNumber :: Parser Int
getLineNumber = map (\(a,_)-> snd a) $ update id

getFileName :: Parser String
getFileName = map (\(a,_) -> fst a) $ update id

raiseErrorInLine :: String -> Parser a
raiseErrorInLine str = do l <- getLineNumber
                          f <- getFileName
                          mraise (f ++": error in line " ++ 
                                  show l ++ ": " ++ str)

extendInit :: [MemDec] -> [MemDec]
extendInit(decls) =
  let fields  = [ f | f@(FieldDec(_)) <- decls ]
      sfields = [ f | f <- fields, Static `elem` javaModifiers(f),
                      isJust(initialExp(f)) ]
      ifields = [ f | f <- fields, Static `notElem` javaModifiers(f),
                      isJust(initialExp(f)) ]
      mths    = [ m | m@(MethDec(_))  <- decls ]
      mths'   = [ m | m <- mths, methNm(m) /= "<clinit>" &&
                                 methNm(m) /= "<init>" ]
      inits   = [ m | m <- mths, methNm(m) == "<clinit>" || 
                                 methNm(m) == "<init>" ]
      inits'  = [ if extendInitMeth(m) then
                    if methNm(m) == "<clinit>"
                    then extendm(m,fs,sis,True)
                    else extendm(m,fi,iis,False)
                  else m
                | m <- inits ]
      is(fs)  = [ Term (ExpStm,TJNoType)
                       [ Term (AssName (fieldNm(fr)),TJNoType) 
                              [just(initialExp(fr))]] | fr <- fs ]
      iis     = is(ifields)
      sis     = is(sfields)
      fs(is,Term (StaticInit,_)[s])= fs(is,s)
      fs(is,Term (Block,_) ss)     = is ++ ss
      fs(is,s)                     = is ++ [s]
      fi(is,Term (Block,_) (s:ss)) = s : is ++ ss
      fi(_,_)                      = error "INTERNAL ERROR: extendInit"
      extendm(m,f,is,_)
                | null(is) = m
      extendm(m,f,is,True) = case f(is,body(m)) of
                              [s] -> MethDec(javaModifiers(m),
                                             javaReturnType(m),
                                             methNm(m), 
                                             arguments(m),
                                             Term(StaticInit,TJVoid)[s],
                                             throws(m),False)
                              ss  -> MethDec(javaModifiers(m),
                                             javaReturnType(m),
                                             methNm(m), 
                                             arguments(m),
                                             Term(StaticInit,TJVoid)[Term(Block,TJVoid)ss],
                                             throws(m),False)
      extendm(m,f,is,_) = MethDec(javaModifiers(m),
                                  javaReturnType(m),
                                  methNm(m),
                                  arguments(m),
                                  Term (Block,TJVoid) (f(is, body(m))),
                                  throws(m),False)
  in  fields ++ (inits' ++ mths')



handleByteShort :: MemDec -> MemDec
handleByteShort(FieldDec(ms,TJByte,n,Just(Term(Lit(TI(i)),TJInt)ts))) = FieldDec(ms,TJByte,n,Just(Term(Lit(IB(i)),TJByte)ts))
handleByteShort(FieldDec(ms,TJShort,n,Just(Term(Lit(TI(i)),TJInt)ts))) = FieldDec(ms,TJShort,n,Just(Term(Lit(IS(i)),TJShort)ts))
handleByteShort(x) = x


initSuper :: JavaClass -> MemDec
initSuper(name) = 
  if name == "Object" then
  MethDec([Public],TJVoid,"<init>",[],
          Term (Block,TJVoid) [ Term (JavaReturn "",TJVoid) []],{},False)
  else
  MethDec([Public],TJVoid,"<init>",[],
          Term (Block,TJVoid) [ Term (ExpStm,TJVoid) [Term (QualInvoke "<init>",TJVoid) 
                                  [Term (AccName "super",TJRef(name)) []]],
                                Term (JavaReturn "",TJVoid) []],{},True)


insertTrue :: [Exp] -> Exp
insertTrue [e] = e
insertTrue _   = Term (Lit (TB True),TJBoolean) []