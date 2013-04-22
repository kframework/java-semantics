


jllparen p _   = (p, JTLParen)   

jlrparen p _   = (p, JTRParen)   

jlcomma p _    = (p, JTComma)    

jlsemi p _     = (p, JTSemi)     

jllcurly p _   = (p, JTLCurly)   

jlrcurly p _   = (p, JTRCurly)   

jlcolon p _    = (p, JTColon)    

jllbrack p _   = (p, JTLBrack)   

jlrbrack p _   = (p, JTRBrack)   

jldot p _      = (p, JTDot)      

jlquestion p _ = (p, JTQuestion) 


ctx_acts :: [(String,Posn -> String -> Token)]

type Token       = (Posn, JavaToken)
data JavaToken   = JTError(String)
                 | JTModifier(Modifier)
                 | JTIdentifier(String)
                 | JTQuote(String)
                 | JTIntVal(Int)
                 | JTLongVal(Int)
                 | JTFloatVal(Float)
                 | JTDoubleVal(Float)
                 | JTCharVal(Char)
                 | JTType(JavaType)
                 | JTBreak
                 | JTCatch
                 | JTClass
                 | JTContinue
                 | JTDo
                 | JTElse
                 | JTExtends
                 | JTFalse
                 | JTFinally
                 | JTFor
                 | JTIf
                 | JTImplements
                 | JTImport
                 | JTInstanceof
                 | JTInterface
                 | JTNew
                 | JTNull
                 | JTPackage
                 | JTReturn
                 | JTSuper
                 | JTSuperL
                 | JTSwitch
                 | JTThis
                 | JTThisL
                 | JTThrow
                 | JTThrows
                 | JTTrue
                 | JTTry
                 | JTVoid
                 | JTWhile
                 | JTLParen
                 | JTRParen
                 | JTComma
                 | JTSemi
                 | JTLCurly
                 | JTRCurly
                 | JTColon
                 | JTLBrack
                 | JTRBrack
                 | JTBrack
                 | JTDot
                 | JTQuestion
                 | JTAssign
                 | JTAnd
                 | JTOr
                 | JTLessEq
                 | JTGreaterEq
                 | JTEqualEqual
                 | JTNotEqual
                 | JTNot
                 | JTMinus
                 | JTPlus
                 | JTTimes
                 | JTDivide
                 | JTMod
                 | JTLess
                 | JTGreater
                 | JTPlusEqual
                 | JTMinusEqual
                 | JTTimesEqual
                 | JTDivideEqual
                 | JTModEqual
                 | JTIncrement
                 | JTDecrement


str2float :: [Char] -> Float
str2float xs = let (l,_:r) = break (=='.') xs
               in  fromInteger (str2int l) 
                   + foldr (\a b -> (fromInteger (ord a - ord '0')
                                     + b) / 10.0) 0.0 r
                 
jlQuote  p s    = (p, JTQuote(substNewline(init(tail(s)))))
jlInt p s       = (p, JTIntVal(str2int(s)))
jlLong p s      = (p, JTLongVal(str2int(init s)))
jlChar p s      = (p, case tail(init(s)) of
                       [c] -> JTCharVal(c)
                       _   -> JTError ("char: " ++ s))
jlFloat p s     = (p, JTFloatVal(str2float(init s)))
jlDouble p s    = (p, JTDoubleVal(str2float(s)))
jlString p s    = let t = case maplookup javaReservedWords s of
                            Just t  -> t
                            Nothing -> JTIdentifier(s)
                  in (p, t)

jlOperator p s  = let t = case maplookup javaOperators s of
                            Just t  -> t
                            Nothing -> JTError("unknown operator " ++ s)
                  in (p, t)

stringOfTok :: (a, JavaToken) -> String
stringOfTok (_, JTIdentifier(s)) = s
stringOfTok (_, JTQuote(s)) = s
stringOfTok (_,x) = error ("stringOfTok " ++ primPrint 0 x "")

intOfTok :: (a, JavaToken) -> Int
intOfTok (_, JTIntVal(i))  = i
intOfTok (_, JTLongVal(i)) = i
intOfTok (_,x) = error ("intOfTok " ++ primPrint 0 x "")

charOfTok :: (a, JavaToken) -> Char
charOfTok (_, JTCharVal(c)) = c
charOfTok (_,x) = error ("intOfTok " ++ primPrint 0 x "")


floatOfTok :: (a, JavaToken) -> Float
floatOfTok (_, JTFloatVal(f)) = f
floatOfTok (_, JTDoubleVal(f)) = f
floatOfTok (_,x) = error ("floatOfTok " ++ primPrint 0 x "")

javaOperators :: Mapping String JavaToken
javaOperators = mapping
      [
        (">>=",       opNotSupported(">>="))
      , (">>>=",      opNotSupported(">>>="))
      , ("<<=",       opNotSupported("<<="))
      , ("^=",        opNotSupported("^="))
      , (">>",        opNotSupported(">>"))
      , (">>>",       opNotSupported(">>>"))
      , ("<<",        opNotSupported("<<"))
      , ("&=",        opNotSupported("&="))
      , ("|=",        opNotSupported("|="))
      , ("++",        JTIncrement)
      , ("--",        JTDecrement)
      , ("&&",        JTAnd)
      , ("||",        JTOr)
      , ("<=",        JTLessEq)
      , (">=",        JTGreaterEq)
      , ("==",        JTEqualEqual)
      , ("+=",        JTPlusEqual)
      , ("-=",        JTMinusEqual)
      , ("*=",        JTTimesEqual)
      , ("/=",        JTDivideEqual)
      , ("%=",        JTModEqual)
      , ("!=",        JTNotEqual)
      , ("=",         JTAssign)
      , ("&",         opNotSupported("&"))
      , ("!",         JTNot)
      , ("~",         opNotSupported("~"))
      , ("-",         JTMinus)
      , ("+",         JTPlus)
      , ("*",         JTTimes)
      , ("/",         JTDivide)
      , ("%",         JTMod)
      , ("<",         JTLess)
      , (">",         JTGreater)
      , ("^",         opNotSupported("^"))
      , ("|",         opNotSupported("|"))
      ]

opNotSupported(op) = JTError ("operator " ++ op ++ " not supported")

javaReservedWords :: Mapping String JavaToken
javaReservedWords = mapping
      [ 
        ("abstract"              , JTModifier(Abstract))
      , ("boolean"               , JTType(TJBoolean))
      , ("break"                 , JTBreak)
      , ("byte"                  , JTType(TJByte))
      , ("catch"                 , JTCatch)
      , ("char"                  , JTType(TJChar))
      , ("class"                 , JTClass)
      , ("continue"              , JTContinue)
      , ("do"                    , JTDo)
      , ("double"                , JTType(TJDouble))
      , ("else"                  , JTElse)
      , ("extends"               , JTExtends)
      , ("false"                 , JTFalse)
      , ("final"                 , JTModifier(Final))
      , ("finally"               , JTFinally)
      , ("float"                 , JTType(TJFloat))
      , ("for"                   , JTFor)
      , ("if"                    , JTIf)
      , ("implements"            , JTImplements)
      , ("import"                , JTImport)
      , ("instanceof"            , JTInstanceof)
      , ("int"                   , JTType(TJInt))
      , ("interface"             , JTInterface)
      , ("long"                  , JTType(TJLong))
      , ("native"                , JTModifier(Native))
      , ("new"                   , JTNew)
      , ("null"                  , JTNull)
      , ("package"               , JTPackage)
      , ("private"               , JTModifier(Private))
      , ("protected"             , JTModifier(Protected))
      , ("public"                , JTModifier(Public))
      , ("return"                , JTReturn)
      , ("short"                 , JTType(TJShort))
      , ("static"                , JTModifier(Static))
      , ("super"                 , JTSuper)
      , ("switch"                , JTSwitch)
      , ("synchronized"          , JTModifier(Synchronized))
      , ("this"                  , JTThis)
      , ("threadsafe"            , JTError("not supported: threadsafe"))
      , ("throw"                 , JTThrow)
      , ("throws"                , JTThrows)
      , ("transient"             , JTModifier(Transient))
      , ("true"                  , JTTrue)
      , ("try"                   , JTTry)
      , ("void"                  , JTVoid)
      , ("while"                 , JTWhile)
      ]

instance Text JavaToken where
  showsPrec i (JTError(s))         = showString s
  showsPrec i (JTModifier(m))      = shows m
  showsPrec i (JTIdentifier(s))    = showString s
  showsPrec i (JTQuote(s))         = showString s
  showsPrec i (JTIntVal(d))        = shows d
  showsPrec i (JTLongVal(d))       = shows d . showString "l"
  showsPrec i (JTFloatVal(f))      = shows f . showString "f"
  showsPrec i (JTDoubleVal(f))      = shows f
  showsPrec i (JTCharVal(c))       = shows c
  showsPrec i (JTType(t))          = shows t
  showsPrec i JTBreak     = showString "break"
  showsPrec i JTCatch     = showString "catch"
  showsPrec i JTClass     = showString "class"
  showsPrec i JTContinue  = showString "continue"
  showsPrec i JTDo        = showString "do"
  showsPrec i JTElse      = showString "else"
  showsPrec i JTExtends   = showString "extends"
  showsPrec i JTFalse     = showString "false"
  showsPrec i JTFinally   = showString "finally"
  showsPrec i JTFor       = showString "for"
  showsPrec i JTIf        = showString "if"
  showsPrec i JTImplements= showString "implements"
  showsPrec i JTImport    = showString "import"
  showsPrec i JTInstanceof= showString "instanceof"
  showsPrec i JTInterface = showString "interface"
  showsPrec i JTNew       = showString "new"
  showsPrec i JTNull      = showString "null"
  showsPrec i JTPackage   = showString "package"
  showsPrec i JTReturn    = showString "return"
  showsPrec i JTSuper     = showString "super"
  showsPrec i JTSuperL    = showString "superL"
  showsPrec i JTSwitch    = showString "switch"
  showsPrec i JTThis      = showString "this"
  showsPrec i JTThisL     = showString "this("
  showsPrec i JTThrow     = showString "throw"
  showsPrec i JTThrows    = showString "throws"
  showsPrec i JTTrue      = showString "true"
  showsPrec i JTTry       = showString "try"
  showsPrec i JTVoid      = showString "void"
  showsPrec i JTWhile     = showString "while"
  showsPrec i JTLParen    = showString "("
  showsPrec i JTRParen    = showString ")"
  showsPrec i JTComma     = showString ","
  showsPrec i JTSemi      = showString ";"
  showsPrec i JTLCurly    = showString "{"
  showsPrec i JTRCurly    = showString "}"
  showsPrec i JTColon     = showString ":"
  showsPrec i JTLBrack    = showString "["
  showsPrec i JTRBrack    = showString "]"
  showsPrec i JTDot       = showString "."
  showsPrec i JTQuestion  = showString "?"
  showsPrec i JTAssign    = showString "="
  showsPrec i JTAnd       = showString "&&"
  showsPrec i JTOr        = showString "||"
  showsPrec i JTLessEq    = showString "<="
  showsPrec i JTGreaterEq = showString ">="
  showsPrec i JTEqualEqual= showString "=="
  showsPrec i JTNotEqual  = showString "!="
  showsPrec i JTNot       = showString "!"
  showsPrec i JTMinus     = showString "-"
  showsPrec i JTPlus      = showString "+"
  showsPrec i JTTimes     = showString "*"
  showsPrec i JTDivide    = showString "/"
  showsPrec i JTMod       = showString "%"
  showsPrec i JTLess      = showString "<"
  showsPrec i JTGreater   = showString ">"
  showsPrec i JTPlusEqual = showString "+="
  showsPrec i JTMinusEqual = showString "-="
  showsPrec i JTTimesEqual = showString "*="
  showsPrec i JTDivideEqual= showString "/="
  showsPrec i JTModEqual   = showString "%="
  showsPrec i JTIncrement  = showString "++"
  showsPrec i JTDecrement  = showString "--"
  showsPrec i e = showString (primPrint i e [])



instance Text Posn where
  showsPrec i e = showString (primPrint i e [])

javaLexer :: String -> [Token]
javaLexer = normalize . scan ctx_scan
  where normalize ((p,JTLBrack) : (_,JTRBrack) : xs) 
                         = (p,JTBrack) : normalize xs
        normalize ((p,JTThis) : (_,JTLParen) : xs)
                         = (p,JTThisL) : normalize xs
        normalize ((p,JTSuper) : (_,JTLParen) : xs)
                         = (p,JTSuperL) : normalize xs
        normalize (x:xs) = x : normalize xs
        normalize []     = []    

ctx_scan :: Scan Token
ctx_scan = load_scan (ctx_acts, stop_act) ctx_lx
   where
    stop_act p ""  = []
    stop_act p inp = [(p,JTError $ "unexpected end: (" ++ take 20 inp ++")")]


ctx_acts = [("jlChar",jlChar),("jlDouble",jlDouble),("jlFloat",jlFloat),("jlInt",jlInt),("jlLong",jlLong),("jlOperator",jlOperator),("jlQuote",jlQuote),("jlString",jlString),("jlcolon",jlcolon),("jlcomma",jlcomma),("jldot",jldot),("jllbrack",jllbrack),("jllcurly",jllcurly),("jllparen",jllparen),("jlquestion",jlquestion),("jlrbrack",jlrbrack),("jlrcurly",jlrcurly),("jlrparen",jlrparen),("jlsemi",jlsemi)]

ctx_lx :: [(Bool, [(Int,String,[Int],Maybe((Char,Char),[(Char,Bool)]),Maybe Int)], Int, ((Char,Char),[(Char,Int)]))]
ctx_lx = [lx__0_0,lx__1_0,lx__2_0,lx__3_0,lx__4_0,lx__5_0,lx__6_0,lx__7_0,lx__8_0,lx__9_0,lx__10_0,lx__11_0,lx__12_0,lx__13_0,lx__14_0,lx__15_0,lx__16_0,lx__17_0,lx__18_0,lx__19_0,lx__20_0,lx__21_0,lx__22_0,lx__23_0,lx__24_0,lx__25_0,lx__26_0,lx__27_0,lx__28_0,lx__29_0,lx__30_0,lx__31_0,lx__32_0,lx__33_0,lx__34_0,lx__35_0,lx__36_0,lx__37_0,lx__38_0]
lx__0_0 :: (Bool, [(Int,String,[Int],Maybe((Char,Char),[(Char,Bool)]),Maybe Int)], Int, ((Char,Char),[(Char,Int)]))
lx__0_0 = (False,[],-1,(('\t','~'),[('\t',38),('\n',38),('\r',38),(' ',38),('!',37),('"',24),('$',11),('%',37),('&',37),('\'',20),('(',27),(')',28),('*',37),('+',37),(',',29),('-',15),('.',18),('/',1),('0',12),('1',12),('2',12),('3',12),('4',12),('5',12),('6',12),('7',12),('8',12),('9',12),(':',33),(';',30),('<',37),('=',37),('>',37),('?',36),('A',11),('B',11),('C',11),('D',11),('E',11),('F',11),('G',11),('H',11),('I',11),('J',11),('K',11),('L',11),('M',11),('N',11),('O',11),('P',11),('Q',11),('R',11),('S',11),('T',11),('U',11),('V',11),('W',11),('X',11),('Y',11),('Z',11),('[',34),(']',35),('^',37),('_',11),('a',11),('b',11),('c',11),('d',11),('e',11),('f',11),('g',11),('h',11),('i',11),('j',11),('k',11),('l',11),('m',11),('n',11),('o',11),('p',11),('q',11),('r',11),('s',11),('t',11),('u',11),('v',11),('w',11),('x',11),('y',11),('z',11),('{',31),('|',37),('}',32),('~',37)]))
lx__1_0 :: (Bool, [(Int,String,[Int],Maybe((Char,Char),[(Char,Bool)]),Maybe Int)], Int, ((Char,Char),[(Char,Int)]))
lx__1_0 = (True,[(20,"jlOperator",[],Nothing,Nothing)],-1,(('!','~'),[('!',37),('%',37),('&',37),('*',6),('+',37),('-',37),('/',3),('<',37),('=',37),('>',37),('^',37),('|',37),('~',37)]))
lx__2_0 :: (Bool, [(Int,String,[Int],Maybe((Char,Char),[(Char,Bool)]),Maybe Int)], Int, ((Char,Char),[(Char,Int)]))
lx__2_0 = (False,[],2,(('\n','\n'),[('\n',4)]))
lx__3_0 :: (Bool, [(Int,String,[Int],Maybe((Char,Char),[(Char,Bool)]),Maybe Int)], Int, ((Char,Char),[(Char,Int)]))
lx__3_0 = (True,[(20,"jlOperator",[],Nothing,Nothing)],2,(('\n','~'),[('\n',4),('!',3),('%',3),('&',3),('*',3),('+',3),('-',3),('/',3),('<',3),('=',3),('>',3),('^',3),('|',3),('~',3)]))
lx__4_0 :: (Bool, [(Int,String,[Int],Maybe((Char,Char),[(Char,Bool)]),Maybe Int)], Int, ((Char,Char),[(Char,Int)]))
lx__4_0 = (True,[(0,"",[],Nothing,Nothing)],-1,(('0','0'),[]))
lx__5_0 :: (Bool, [(Int,String,[Int],Maybe((Char,Char),[(Char,Bool)]),Maybe Int)], Int, ((Char,Char),[(Char,Int)]))
lx__5_0 = (False,[],5,(('*','*'),[('*',7)]))
lx__6_0 :: (Bool, [(Int,String,[Int],Maybe((Char,Char),[(Char,Bool)]),Maybe Int)], Int, ((Char,Char),[(Char,Int)]))
lx__6_0 = (True,[(20,"jlOperator",[],Nothing,Nothing)],5,(('!','~'),[('!',6),('%',6),('&',6),('*',8),('+',6),('-',6),('/',6),('<',6),('=',6),('>',6),('^',6),('|',6),('~',6)]))
lx__7_0 :: (Bool, [(Int,String,[Int],Maybe((Char,Char),[(Char,Bool)]),Maybe Int)], Int, ((Char,Char),[(Char,Int)]))
lx__7_0 = (False,[],5,(('/','/'),[('/',10)]))
lx__8_0 :: (Bool, [(Int,String,[Int],Maybe((Char,Char),[(Char,Bool)]),Maybe Int)], Int, ((Char,Char),[(Char,Int)]))
lx__8_0 = (True,[(20,"jlOperator",[],Nothing,Nothing)],5,(('!','~'),[('!',6),('%',6),('&',6),('*',6),('+',6),('-',6),('/',9),('<',6),('=',6),('>',6),('^',6),('|',6),('~',6)]))
lx__9_0 :: (Bool, [(Int,String,[Int],Maybe((Char,Char),[(Char,Bool)]),Maybe Int)], Int, ((Char,Char),[(Char,Int)]))
lx__9_0 = (True,[(1,"",[],Nothing,Nothing)],-1,(('!','~'),[('!',37),('%',37),('&',37),('*',37),('+',37),('-',37),('/',37),('<',37),('=',37),('>',37),('^',37),('|',37),('~',37)]))
lx__10_0 :: (Bool, [(Int,String,[Int],Maybe((Char,Char),[(Char,Bool)]),Maybe Int)], Int, ((Char,Char),[(Char,Int)]))
lx__10_0 = (True,[(1,"",[],Nothing,Nothing)],-1,(('0','0'),[]))
lx__11_0 :: (Bool, [(Int,String,[Int],Maybe((Char,Char),[(Char,Bool)]),Maybe Int)], Int, ((Char,Char),[(Char,Int)]))
lx__11_0 = (True,[(2,"jlString",[],Nothing,Nothing)],-1,(('$','z'),[('$',11),('0',11),('1',11),('2',11),('3',11),('4',11),('5',11),('6',11),('7',11),('8',11),('9',11),('A',11),('B',11),('C',11),('D',11),('E',11),('F',11),('G',11),('H',11),('I',11),('J',11),('K',11),('L',11),('M',11),('N',11),('O',11),('P',11),('Q',11),('R',11),('S',11),('T',11),('U',11),('V',11),('W',11),('X',11),('Y',11),('Z',11),('_',11),('a',11),('b',11),('c',11),('d',11),('e',11),('f',11),('g',11),('h',11),('i',11),('j',11),('k',11),('l',11),('m',11),('n',11),('o',11),('p',11),('q',11),('r',11),('s',11),('t',11),('u',11),('v',11),('w',11),('x',11),('y',11),('z',11)]))
lx__12_0 :: (Bool, [(Int,String,[Int],Maybe((Char,Char),[(Char,Bool)]),Maybe Int)], Int, ((Char,Char),[(Char,Int)]))
lx__12_0 = (True,[(3,"jlInt",[],Nothing,Nothing)],-1,(('.','l'),[('.',17),('0',12),('1',12),('2',12),('3',12),('4',12),('5',12),('6',12),('7',12),('8',12),('9',12),('L',13),('l',13)]))
lx__13_0 :: (Bool, [(Int,String,[Int],Maybe((Char,Char),[(Char,Bool)]),Maybe Int)], Int, ((Char,Char),[(Char,Int)]))
lx__13_0 = (True,[(4,"jlLong",[],Nothing,Nothing)],-1,(('0','0'),[]))
lx__14_0 :: (Bool, [(Int,String,[Int],Maybe((Char,Char),[(Char,Bool)]),Maybe Int)], Int, ((Char,Char),[(Char,Int)]))
lx__14_0 = (False,[],-1,(('.','9'),[('.',17),('0',14),('1',14),('2',14),('3',14),('4',14),('5',14),('6',14),('7',14),('8',14),('9',14)]))
lx__15_0 :: (Bool, [(Int,String,[Int],Maybe((Char,Char),[(Char,Bool)]),Maybe Int)], Int, ((Char,Char),[(Char,Int)]))
lx__15_0 = (True,[(20,"jlOperator",[],Nothing,Nothing)],-1,(('!','~'),[('!',37),('%',37),('&',37),('*',37),('+',37),('-',37),('.',17),('/',37),('0',14),('1',14),('2',14),('3',14),('4',14),('5',14),('6',14),('7',14),('8',14),('9',14),('<',37),('=',37),('>',37),('^',37),('|',37),('~',37)]))
lx__16_0 :: (Bool, [(Int,String,[Int],Maybe((Char,Char),[(Char,Bool)]),Maybe Int)], Int, ((Char,Char),[(Char,Int)]))
lx__16_0 = (True,[(6,"jlDouble",[],Nothing,Nothing)],-1,(('0','f'),[('0',16),('1',16),('2',16),('3',16),('4',16),('5',16),('6',16),('7',16),('8',16),('9',16),('F',19),('f',19)]))
lx__17_0 :: (Bool, [(Int,String,[Int],Maybe((Char,Char),[(Char,Bool)]),Maybe Int)], Int, ((Char,Char),[(Char,Int)]))
lx__17_0 = (False,[],-1,(('0','9'),[('0',16),('1',16),('2',16),('3',16),('4',16),('5',16),('6',16),('7',16),('8',16),('9',16)]))
lx__18_0 :: (Bool, [(Int,String,[Int],Maybe((Char,Char),[(Char,Bool)]),Maybe Int)], Int, ((Char,Char),[(Char,Int)]))
lx__18_0 = (True,[(18,"jldot",[],Nothing,Nothing)],-1,(('0','9'),[('0',16),('1',16),('2',16),('3',16),('4',16),('5',16),('6',16),('7',16),('8',16),('9',16)]))
lx__19_0 :: (Bool, [(Int,String,[Int],Maybe((Char,Char),[(Char,Bool)]),Maybe Int)], Int, ((Char,Char),[(Char,Int)]))
lx__19_0 = (True,[(5,"jlFloat",[],Nothing,Nothing)],-1,(('0','0'),[]))
lx__20_0 :: (Bool, [(Int,String,[Int],Maybe((Char,Char),[(Char,Bool)]),Maybe Int)], Int, ((Char,Char),[(Char,Int)]))
lx__20_0 = (False,[],21,(('\\','\\'),[('\\',23)]))
lx__21_0 :: (Bool, [(Int,String,[Int],Maybe((Char,Char),[(Char,Bool)]),Maybe Int)], Int, ((Char,Char),[(Char,Int)]))
lx__21_0 = (False,[],21,(('\'','\\'),[('\'',22),('\\',23)]))
lx__22_0 :: (Bool, [(Int,String,[Int],Maybe((Char,Char),[(Char,Bool)]),Maybe Int)], Int, ((Char,Char),[(Char,Int)]))
lx__22_0 = (True,[(7,"jlChar",[],Nothing,Nothing)],21,(('\'','\\'),[('\'',22),('\\',23)]))
lx__23_0 :: (Bool, [(Int,String,[Int],Maybe((Char,Char),[(Char,Bool)]),Maybe Int)], Int, ((Char,Char),[(Char,Int)]))
lx__23_0 = (False,[],21,(('\n','\n'),[('\n',-1)]))
lx__24_0 :: (Bool, [(Int,String,[Int],Maybe((Char,Char),[(Char,Bool)]),Maybe Int)], Int, ((Char,Char),[(Char,Int)]))
lx__24_0 = (False,[],24,(('"','\\'),[('"',26),('\\',25)]))
lx__25_0 :: (Bool, [(Int,String,[Int],Maybe((Char,Char),[(Char,Bool)]),Maybe Int)], Int, ((Char,Char),[(Char,Int)]))
lx__25_0 = (False,[],24,(('\n','\n'),[('\n',-1)]))
lx__26_0 :: (Bool, [(Int,String,[Int],Maybe((Char,Char),[(Char,Bool)]),Maybe Int)], Int, ((Char,Char),[(Char,Int)]))
lx__26_0 = (True,[(8,"jlQuote",[],Nothing,Nothing)],-1,(('0','0'),[]))
lx__27_0 :: (Bool, [(Int,String,[Int],Maybe((Char,Char),[(Char,Bool)]),Maybe Int)], Int, ((Char,Char),[(Char,Int)]))
lx__27_0 = (True,[(9,"jllparen",[],Nothing,Nothing)],-1,(('0','0'),[]))
lx__28_0 :: (Bool, [(Int,String,[Int],Maybe((Char,Char),[(Char,Bool)]),Maybe Int)], Int, ((Char,Char),[(Char,Int)]))
lx__28_0 = (True,[(10,"jlrparen",[],Nothing,Nothing)],-1,(('0','0'),[]))
lx__29_0 :: (Bool, [(Int,String,[Int],Maybe((Char,Char),[(Char,Bool)]),Maybe Int)], Int, ((Char,Char),[(Char,Int)]))
lx__29_0 = (True,[(11,"jlcomma",[],Nothing,Nothing)],-1,(('0','0'),[]))
lx__30_0 :: (Bool, [(Int,String,[Int],Maybe((Char,Char),[(Char,Bool)]),Maybe Int)], Int, ((Char,Char),[(Char,Int)]))
lx__30_0 = (True,[(12,"jlsemi",[],Nothing,Nothing)],-1,(('0','0'),[]))
lx__31_0 :: (Bool, [(Int,String,[Int],Maybe((Char,Char),[(Char,Bool)]),Maybe Int)], Int, ((Char,Char),[(Char,Int)]))
lx__31_0 = (True,[(13,"jllcurly",[],Nothing,Nothing)],-1,(('0','0'),[]))
lx__32_0 :: (Bool, [(Int,String,[Int],Maybe((Char,Char),[(Char,Bool)]),Maybe Int)], Int, ((Char,Char),[(Char,Int)]))
lx__32_0 = (True,[(14,"jlrcurly",[],Nothing,Nothing)],-1,(('0','0'),[]))
lx__33_0 :: (Bool, [(Int,String,[Int],Maybe((Char,Char),[(Char,Bool)]),Maybe Int)], Int, ((Char,Char),[(Char,Int)]))
lx__33_0 = (True,[(15,"jlcolon",[],Nothing,Nothing)],-1,(('0','0'),[]))
lx__34_0 :: (Bool, [(Int,String,[Int],Maybe((Char,Char),[(Char,Bool)]),Maybe Int)], Int, ((Char,Char),[(Char,Int)]))
lx__34_0 = (True,[(16,"jllbrack",[],Nothing,Nothing)],-1,(('0','0'),[]))
lx__35_0 :: (Bool, [(Int,String,[Int],Maybe((Char,Char),[(Char,Bool)]),Maybe Int)], Int, ((Char,Char),[(Char,Int)]))
lx__35_0 = (True,[(17,"jlrbrack",[],Nothing,Nothing)],-1,(('0','0'),[]))
lx__36_0 :: (Bool, [(Int,String,[Int],Maybe((Char,Char),[(Char,Bool)]),Maybe Int)], Int, ((Char,Char),[(Char,Int)]))
lx__36_0 = (True,[(19,"jlquestion",[],Nothing,Nothing)],-1,(('0','0'),[]))
lx__37_0 :: (Bool, [(Int,String,[Int],Maybe((Char,Char),[(Char,Bool)]),Maybe Int)], Int, ((Char,Char),[(Char,Int)]))
lx__37_0 = (True,[(20,"jlOperator",[],Nothing,Nothing)],-1,(('!','~'),[('!',37),('%',37),('&',37),('*',37),('+',37),('-',37),('/',37),('<',37),('=',37),('>',37),('^',37),('|',37),('~',37)]))
lx__38_0 :: (Bool, [(Int,String,[Int],Maybe((Char,Char),[(Char,Bool)]),Maybe Int)], Int, ((Char,Char),[(Char,Int)]))
lx__38_0 = (True,[(21,"",[],Nothing,Nothing)],-1,(('\t',' '),[('\t',38),('\n',38),('\r',38),(' ',38)]))

