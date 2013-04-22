infixr 5 +.+

(+.+) = (.)

data LabKind = LFinally | LBreak | LContinue
instance AsmTerm LabKind

type CompileEnv = (JavaType,Map Loc Nat, [(Lab, LabName, LabKind)])


locNum :: (CompileEnv, Loc) -> Nat
locNum((rt,locs,labs), loc) = locs#(loc)

returnLocNum :: (CompileEnv, Loc, String) -> Nat
returnLocNum((rt,locs,labs), loc, tries) = locs#(loc++tries)

labNum :: (CompileEnv, Lab, LabKind) -> LabName
labNum ((rt,locs,(l,o,lKind) : labs), lab, k)
   | l == lab && lKind == k = o
   | otherwise = labNum((rt,locs,labs), lab, k)


finallyCodeToExec :: CompileEnv -> Bool
finallyCodeToExec (rt,locs, []) = False
finallyCodeToExec (rt,locs, (_,_,lKind) : labs)
   | lKind == LFinally = True
   | otherwise         = finallyCodeToExec(rt,locs,labs)

jumpToFinally :: (CompileEnv, Lab) -> ShowI
jumpToFinally ((rt,locs, []), lab)
   = emptyCode
jumpToFinally ((rt, locs, (l,o,lKind) : labs), lab)
   | lKind == LFinally      = outputInstr(LabJsr(o)) +.+
                              jumpToFinally((rt,locs,labs),lab)
   | l == lab   = emptyCode
   | otherwise  = jumpToFinally((rt,locs,labs),lab)

finallyLabs :: CompileEnv -> ShowI
finallyLabs(env) = jumpToFinally(env,"")


maxLocNumUsedInEnv :: CompileEnv -> Nat
maxLocNumUsedInEnv(rt,locs,labs) = 
  maximum ({ n | (_,n) <-: locs } `union` { -1 })

extendCompileEnvVars :: (CompileEnv, [Stm]) -> CompileEnv
extendCompileEnvVars (env, ss) =
   let (rt,locs,labs)= env
       maxLocNum     = maxLocNumUsedInEnv(env)
       vars          = concat [ if size(t) == 2 then [l,l++"'high"] else [l] 
                               | Term(LocDec t l,_) _ <- ss ]
   in  (rt,locs +<< { (l,i) 
                 | (i,l) <- zip [maxLocNum + 1 ..] vars }, labs)


extendCompileFinally :: CompileEnv -> (CompileEnv,CompileEnv)
extendCompileFinally env@(rt,locs,labs) =
     (env, (rt,locs +<< {("<retReg>",l+1),
                         ("<throwReg>",l+2)},labs))
 where l = maxLocNumUsedInEnv(env)


extendCompileVars :: (CompileEnv, Loc) -> CompileEnv
extendCompileVars (env,loc) = extendCompileEnvVars(env,[Term(LocDec TJNoType loc,TJVoid)[]])

extendCompileEnvLab :: (CompileEnv, (Lab, LabName, LabKind)) -> CompileEnv
extendCompileEnvLab ((rt,locs,labs), l) = (rt,locs, l : labs)

getReturns :: Stm -> {String}
getReturns(Term(op,_)ss) = case (op,ss) of
   (Block,_)            -> { r | s <- ss, r <-: getReturns(s) }
   (LabStm _,[s])       -> getReturns(s)
   (IfStm,[c,t,e])      -> getReturns(t) `union` getReturns(e)
   (While,[c,s])        -> getReturns(s)
   (For _ _,[i,c,u,s])  -> getReturns(s)
   (SynBlock,[s])       -> getReturns(s)
   (Try,ss)             -> { r | s <- ss, r <-: getReturns(s) }
   (Finally _,[s1,s2])  -> getReturns(s1) `union` getReturns(s2)
   (Catch _,[s])        -> getReturns(s)
   (JavaReturn tries,_) -> {tries}
   _                    -> {}



convertType :: JavaType -> ValType
convertType(t) = case t of
  TJInt        -> [WTInt]
  TJFloat      -> [WTFloat]
  TJDouble     -> [WTLowDouble, WTHighDouble]
  TJLong       -> [WTLowLong, WTHighLong]
  TJByte       -> [WTInt]
  TJChar       -> [WTInt]
  TJShort      -> [WTInt]
  TJBoolean    -> [WTInt]
  TJRef(c)     -> [WTReference]
  TJArray(t)   -> [WTReference]
  TJNull       -> [WTReference]
  TJVoid       -> []
  _            -> error ("INTERNAL ERROR: modifyType: " ++  show t)


primConstant :: JavaVal -> Instr
primConstant (TB(True))  = Prim(PrimLdc([(1,WTInt)]))
primConstant (TB(False)) = Prim(PrimLdc([(0,WTInt)]))
primConstant (TI(i))     = Prim(PrimLdc([(i,WTInt)]))
primConstant (TR(0))     = Prim(PrimLdc([(0,WTReference)]))
primConstant (TF(f))     = Prim(PrimLdc([(conv(f),WTFloat)]))
primConstant (IB(i))     = Prim(PrimLdc([(i,WTInt)]))
primConstant (IS(i))     = Prim(PrimLdc([(i,WTInt)]))
primConstant (IL(i))     = Prim(PrimLdc([(i,WTLowLong),(0,WTHighLong)]))
primConstant (FD(f))     = Prim(PrimLdc([(conv(f),WTLowDouble),(0,WTHighDouble)]))
primConstant (TC(c))     = Prim(PrimLdc([(ord(c),WTInt)]))
primConstant (TS(s))     = LoadString(resubstNewline(s))
primConstant (x)         = error ("unexpected(constant): " ++ show'(x))


popExp :: ValType -> ShowI
popExp([]) = emptyCode
popExp(ts) = outputInstr(Pop(size(ts)))



checkPgm :: IO ()
checkPgm = do
   let program = [ td | (_, td) <- assocs(pgm) ]
   let StateM f = checkProgram(program)
   case f ("",({},[],[])) of
     Error(s)  -> error s
     Ok(_,p)   -> do fire1 (do
                      forall td <- p do
                        pgm(typeNm(td)) := td)


type ShowI = [Instr] -> [Instr]
type ShowE = [Exc] -> [Exc]


concatInstr :: (Pos -> a -> ShowI, Int, Pos, [a]) -> ShowI
concatInstr (f,i,pos,xs) = foldl (.) id [ f (j:pos) x | (j,x) <- zip [i..] xs]

concatExcs :: (Pos -> a -> ShowE, Int, Pos, [a]) -> ShowE
concatExcs (f,i,pos,xs) = foldl (.) id [ f (j:pos) x | (j,x) <- zip [i..] xs]

emptyCode :: ShowI
emptyCode = id

emptyExcs :: ShowE
emptyExcs = id

outputInstr :: Instr -> ShowI
outputInstr(Pop(0)) = id
outputInstr(i)      = (:) i

outputExc :: Exc -> ShowE
outputExc = (:)

uapplyInstr :: (Una, JavaType) -> ShowI
uapplyInstr("-",t) = 
   outputInstr(Prim(PrimFun(show(toMoveType(t'))++"neg")))
 where t' = convertType(t)
uapplyInstr("!",t) = error "unary operator ! unexpected"
uapplyInstr(op,t) = outputInstr(Prim(PrimFun(op)))

bapplyInstr :: (Bin, Pos, JavaType, JavaType) -> ShowI
bapplyInstr(op,pos,te1,te2)
    | op == "+" && string(te1) && string(te2) =
      outputInstr(MInvokeVirtual(stringType,
                                 (1,stringClass) :/ ("concat",[stringType]),
                                 undefined))
    | op `elem` ["+","-","*","/","%"] =
      outputInstr(Prim(PrimFun(show te1' ++ binOp2Name(op))))
    | te1' `elem` [MTInt, MTAddr] &&
      te2' `elem` [MTInt, MTAddr] =
      outputInstr(LabCond("if_" ++ show(te1') ++ "cmp" ++ binOp2Name(op),
                       binLab(pos,1))) +.+
      outputInstr(primConstant(TB(False))) +.+ 
      outputInstr(LabGoto(binLab(pos,2))) +.+
      outputInstr(LabInstr(binLab(pos,1))) +.+
      outputInstr(primConstant(TB(True))) +.+
      outputInstr(LabInstr(binLab(pos,2)))
    | te1' `elem` [MTFloat, MTLong, MTDouble] &&
      te2' `elem` [MTFloat, MTLong, MTDouble] =
      outputInstr(Prim(PrimFun(show te1' ++ "cmpl"))) +.+
      outputInstr(LabCond("if" ++ binOp2Name(op), binLab(pos,1))) +.+
      outputInstr(primConstant(TB(False))) +.+ 
      outputInstr(LabGoto(binLab(pos,2))) +.+
      outputInstr(LabInstr(binLab(pos,1))) +.+
      outputInstr(primConstant(TB(True))) +.+
      outputInstr(LabInstr(binLab(pos,2)))
 where te1' = toMoveType(convertType(te1))
       te2' = toMoveType(convertType(te2))

bapplyInstrT :: (Bin, Pos, JavaType, JavaType, LabName) -> ShowI
bapplyInstrT(op,pos,te1,te2,lt)
    | te1' `elem` [MTInt, MTAddr] &&
      te2' `elem` [MTInt, MTAddr] =
      outputInstr(LabCond("if_" ++ show(te1') ++ "cmp" ++ binOp2Name(op),
                       lt))
    | te1' `elem` [MTFloat, MTLong, MTDouble] &&
      te2' `elem` [MTFloat, MTLong, MTDouble] =
      outputInstr(Prim(PrimFun(show te1' ++ "cmpl"))) +.+
      outputInstr(LabCond("if" ++ binOp2Name(op), lt))
 where te1' = toMoveType(convertType(te1))
       te2' = toMoveType(convertType(te2))

bapplyInstrF :: (Bin, Pos,JavaType, JavaType, LabName) -> ShowI
bapplyInstrF(op,pos,te1,te2,lf) = bapplyInstrT(negBinOp(op),pos,te1,te2,lf)


binLab(pos,i)       = ("LabBin",i:pos)
unaLab(pos,i)       = ("LabUna",i:pos)
ifLab(pos,i)        = ("LabIf",i:pos)
whileLab(pos,i)     = ("LabWhile",i:pos)
forLab(pos,i)       = ("LabFor",i:pos)
continueLab(pos)    = ("LabContinue",pos)
breakLab(pos)       = ("LabBreak",pos)
tryLab(pos)         = ("LabTry",1:pos)
tryEndLab(pos)      = ("LabTry",2:pos)
tryCatchEndLab(pos) = ("LabTry",3:pos)
finLabStart(pos)    = ("LabFin",1:pos)
finLab(pos)         = ("LabFin",2:pos)
finEndLab(pos)      = ("LabFin",3:pos)
catchAllLab(pos)    = ("LabCatchAll",pos)
catchLab(pos)       = ("LabCatch",pos)
catchEndLab(pos)    = ("LabCatchEnd",pos)

negBinOp ("<")  = ">="
negBinOp (">")  = "<="
negBinOp ("<=") = ">"
negBinOp (">=") = "<" 
negBinOp ("==") = "!="
negBinOp ("!=") = "=="
negBinOp (xs)   = error ("negBinOp: " ++ xs)

binOp2Name ("+")  = "add"
binOp2Name ("-")  = "sub"
binOp2Name ("*")  = "mul"
binOp2Name ("/")  = "div"
binOp2Name ("%")  = "rem"
binOp2Name ("<")  = "lt"
binOp2Name (">")  = "gt"
binOp2Name ("<=") = "le"
binOp2Name (">=") = "ge" 
binOp2Name ("==") = "eq"
binOp2Name ("!=") = "ne"
binOp2Name (xs)   = error ("binOp2Name: " ++ xs)

toMoveType :: ValType -> MoveType
toMoveType ([WTInt])                     = MTInt
toMoveType ([WTLowLong, WTHighLong])     = MTLong
toMoveType ([WTFloat])                   = MTFloat
toMoveType ([WTLowDouble, WTHighDouble]) = MTDouble
toMoveType ([WTReference])               = MTAddr
toMoveType (_)                         = error ("INTERNAL ERROR: toMoveType")

toArrayMoveType :: JavaType -> ArrayMoveType
toArrayMoveType TJInt                   = AMTInt
toArrayMoveType TJByte                  = AMTByte
toArrayMoveType TJChar                  = AMTChar
toArrayMoveType TJShort                 = AMTShort
toArrayMoveType TJLong                  = AMTLong
toArrayMoveType TJFloat                 = AMTFloat
toArrayMoveType TJDouble                = AMTDouble
toArrayMoveType _                       = AMTObject

locNumOfInstr :: Instr -> Nat
locNumOfInstr(Load(t,r))  = r + size(t) - 1
locNumOfInstr(Store(t,r)) = r + size(t) - 1
locNumOfInstr(Ret(r))     = r
locNumOfInstr(_)          = -1


labels :: Instr -> [LabName]
labels(LabGoto(l))   = [l]
labels(LabCond(_,l)) = [l]
labels(LabJsr(l))    = [l]
labels(LabInstr(l))  = [l]
labels(_)            = []

