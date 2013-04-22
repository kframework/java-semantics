type LabelName = String

type JasminEnv = ( Mapping (MNm,LabelName) Offset 
                                               -- mapping from label to offset
                 , (Nat, Nat)                  -- maxReg, maxOpd
                 , [Exc]                       -- Exception table entry
                 , (MNm,Int)                   -- actual method, line number
                 , (Ld,String)                 -- actual class loader, filename
                 )
type Parser a = StateM Error JasminEnv a


setLabelMapping :: Mapping (MNm, LabelName) Offset -> Parser ()
setLabelMapping mapping = void $ update (\(_,b,c,d,e) -> (mapping,b,c,d,e))

setMaxOpd :: Nat -> Parser ()
setMaxOpd n = void $ update (\(a,(_,b),c,d,e) -> (a,(n,b),c,d,e))

setMaxReg :: Nat -> Parser ()
setMaxReg n = void $ update (\(a,(b,_),c,d,e) -> (a,(b,n),c,d,e))

getExcAndMax :: Parser ((Nat,Nat),[Exc])
getExcAndMax = map (\(a,b,c,d,e) -> (b,reverse c)) $ update id

insertExc :: Exc -> Parser ()
insertExc exc = void $ update (\(a,b,es,d,e) -> (a,b,exc:es,d,e))

setMethodName :: MNm -> Parser ()
setMethodName n = void $ update (\(a,_,_,(_,l),e) -> (a,(0,0),[],(n,l),e))

getMethodName :: Parser MNm
getMethodName = map (\(a,b,c,d,e) -> fst d) $ update id

setLineNumber :: Int -> Parser ()
setLineNumber i = void $ update (\(a,b,c,(d,_),e) -> (a,b,c,(d,i),e))

getLineNumber :: Parser Int
getLineNumber = map (\(a,b,c,d,e) -> snd d) $ update id

getFileName :: Parser String
getFileName = map (\(a,b,c,d,e) -> snd e) $ update id

raiseErrorInLine :: String -> Parser a
raiseErrorInLine str = do l <- getLineNumber
                          f <- getFileName
                          mraise (f ++": error in line " ++ 
                                  show l ++ ": " ++ str)
                  
getLabelOffset :: LabelName -> Parser Offset
getLabelOffset l = do (s,_,_,_,_)  <- update id
                      mn <- getMethodName
                      case maplookup s (mn,l) of
                        Just i  -> result i
                        Nothing -> raiseErrorInLine ("cannot find label " ++ l)

getClassLoader :: Parser Ld
getClassLoader = map (\(a,b,c,d,e) -> fst e) $ update id

newInstance :: MSig
newInstance = ("newInstance", [])

builtinNewInstance :: MSig
builtinNewInstance = ("<newInstance>", [])


newInstanceCode :: Class -> (MSig, MDec)
newInstanceCode (c) = 
        ( builtinNewInstance
        , MDec({}, TJRef(sysLd,"java/lang/Object")
              , [ New(c), Dupx(0,1)
                , MInvokeSpecial(TJVoid,c :/ ("<init>",[]),
                                ("<init>()","V"))
                , Return(MTAddr)] 
              , [], (2,0))
        )


