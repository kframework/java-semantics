
-- =====================================================================
-- AN ASM FOR JAVA
-- javaContextcheck
-- =====================================================================

type Checked a = StateM Error (String, ({Loc},[(Lab,Before)],
                                              [(Lab,Before)])) a

check :: (Bool, String) -> Checked ()
check(True, s) = okay ()
check(False, s) = sfail(s)

okay :: a -> Checked a
okay = result

sfail :: String -> Checked a
sfail(s) = do (str,_) <- update id
              mraise(str ++ s)

setErrorPrefix :: String -> Checked ()
setErrorPrefix(str) = void (update (\(_,vars) -> (str, vars)))

setLocalVariables :: Vars -> Checked ()
setLocalVariables(vars) = void 
   (update (\(str,(_,labsB,labsC)) -> (str, (vars, labsB,labsC))))

getLocalVariables :: Checked Vars
getLocalVariables = map (fst3.snd) (update id)

addLocalVariable :: Loc -> Checked ()
addLocalVariable(l) = do
  vars <- getLocalVariables
  setLocalVariables(vars `union` {l})

setBreakSet :: (Lab,Before) -> Checked ()
setBreakSet (l,before) = do
  update (\(str,(vars,labsB,labsC)) -> (str,(vars,(l,before):labsB,labsC)))
  done

setContinueSet :: (Lab,Before) -> Checked ()
setContinueSet (l,before) = do
  update (\(str,(vars,labsB,labsC)) -> (str,(vars,labsB,(l,before):labsC)))
  done

getBreakSets :: Lab -> Checked Before
getBreakSets (l) = do
  vars <- getLocalVariables
  bs <- map (snd3.snd) (update id)
  result (bigIntersect(vars,{ before | (l',before) <- bs, 
                                       l == l'}))
getContinueSets :: Lab -> Checked Before
getContinueSets (l) = do
  vars <- getLocalVariables
  bs <- map (thd3.snd) (update id)
  result (bigIntersect(vars,{ before | (l',before) <- bs, 
                                       l' == l}))

clearLabelSets :: Lab -> Checked ()
clearLabelSets (l) =
  void $ update (\(str,(vars,labsB,labsC))
         -> (str,(vars,filter ((/=l).fst) labsB,
                       filter ((/=l).fst) labsC)))
 

-- ---------------------------------------------------------------------
-- Checking programs
-- ---------------------------------------------------------------------

checkProgram :: Program -> Checked Program

checkProgram(ts) = do
  let cs = [ t | t <- ts, isClass(t)]
      is = [ t | t <- ts, isIface(t)]
  checkClasses(cs)
  checkIfaces(is)
  checkCompleteImplements(cs,is)
  binds [checkType(t) | t <- ts]

checkClasses :: [ClassDec] -> Checked ()
checkClasses(cs) = do
  once(cs, "Class '%' already defined", typeNm)
  completeClasses(cs)
  check(wellFoundedClasses(cs), "Class hierarchy is not in an order")
  
checkIfaces :: [IfaceDec] -> Checked ()
checkIfaces(is) = do
  once(is, "Interface '%' already defined",typeNm)
  completeIfaces(is)
  check(wellFoundedIfaces(is),  "Interfaces hierarchy is not in an order")
   
checkType(t)
 | isClass(t) = checkClass(t)
 | isIface(t) = checkIface(t)
 
-- Aux ----------------------------------------------------------------

-- Classes that are extended are defined
completeClasses(cs)=
  let cs' = [typeNm(c) | c <- cs]
  in  checkList([just(super(c)) | c <- cs, typeNm(c) /= objectClass],
                \x -> x `elem` cs',
                "Extended class '%' does not exist or is not accessible", id)

-- Class hierarchy is an order
wellFoundedClasses(cs) =
  isAcyclic[(typeNm(c),just(super(c))) | c <- cs, typeNm(c) /= objectClass]

-- Interfaces that are extended are defined
completeIfaces(is) =
  let is' = [typeNm i | i <- is]
  in  checkList ([ j | i <- is, j <- implements(i) ],
                 \j -> j `elem` is',
                 "Extended interface '%' does not exist or is not accessible", id)

-- interface hierarchy is an order
wellFoundedIfaces(is) =
  isAcyclic[(typeNm(i),j) | i <- is, j <- implements(i)]

--interfaces that are implemented are defined
checkCompleteImplements :: (Program,Program) -> Checked ()
checkCompleteImplements(cs,is) =
  let is' = [typeNm i | i <- is]
  in  seqs [ if i `elem` is' then done
              else sfail(printf("Interface '%' is not defined",([i])))
           | c <- cs, i <- implements(c) ]

isAcyclic :: Eq (a,a) => [(a,a)] -> Bool
isAcyclic(es) = all (\(a,b) -> a /= b) $
   transitive (id, \(a,_) (_,b) -> (a,b)) es

-- ---------------------------------------------------------------------
-- Checking type declarations
-- ---------------------------------------------------------------------

-- Classes --------------------------------------------------------------

type ClassDec = TypeDec
  
checkClass :: ClassDec -> Checked (ClassDec)
checkClass(c) = do
  setErrorPrefix (printf("class %:",([typeNm(c)])))
  fieldOncePerType(c)
  methodOncePerType(c)
  check(classModifiersOk(c),
        "Class has no abstract method or class is abstract")
  checkVisibleMethods(typeNm(c))
  implementsOncePerType(c)
  ms <- binds [checkClassMember(typeNm(c),m) | m <- members(c)]
  okay (ClassDec(javaModifiers(c), typeNm(c),super(c), implements(c), ms))

checkClassMember(c,m)
 | isField(m) = checkClassField(c,m)
 | isMethod(m) = checkClassMethod(c,m)

-- Classes-Aux - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

-- Class either has no abstract method or class
-- (and at least one method) is abstract
classModifiersOk(c) =
  (containsAbstractMethod(typeNm(c)) == (Abstract `elem` javaModifiers(c)))

--Ifaces---------------------------------------------------------------

type IfaceDec = TypeDec

checkIface :: IfaceDec -> Checked (IfaceDec)
checkIface(i) = do
  setErrorPrefix (printf("interface %:",([typeNm(i)])))
  fieldOncePerType(i)
  methodOncePerType(i)
  check(ifaceModifiersOk(i),
        printf("Interface '%' must be Abstract and not Static", ([typeNm(i)])))
  implementsOncePerType(i)
  checkVisibleMethods(typeNm(i))
  ms <- binds [checkIfaceMember(typeNm(i),m) | m <- members(i)]
  okay(IfaceDec(javaModifiers(i), typeNm(i),implements(i), ms))
  
checkIfaceMember(i,m)
 | isField(m) = checkIfaceField(i,m)
 | isMethod(m) = checkIfaceMethod(i,m)

-- Ifaces Aux- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  

-- Interfaces must be Abstract and not Static
ifaceModifiersOk(c) =
  Abstract `elem` javaModifiers(c) && Static `notElem` javaModifiers(c)

-- Aux------------------------------------------------------------------

-- Fields are unique
fieldOncePerType(t)  = once([fieldNm(f) | f <- fields(t)],
                            "Field '%' already defined",
                             show)

-- Methods are unique
methodOncePerType(t) = once([signature(m) | m <- methods(t)],
                            "Method '%' already defined",
                            show)

-- Implemented interfaces are unique
implementsOncePerType(t) = once(implements(t),
                                "Interface '%' already listed",
                                show)


-- ---------------------------------------------------------------------
-- Checking member declarations
-- ---------------------------------------------------------------------

--Method----------------------------------------------------------------
type MethDec = MemDec

checkClassMethod :: (JavaClass,MethDec) -> Checked (MethDec)
checkClassMethod(c,md) = do
  setErrorPrefix(printf("class % (method %):",([c,methNm(md)])))
  formalOncePerMethodHead(md)
  formalArgTypesOk(md)
  check(formalResTypeOk(md),
        printf("Formal type '%' does not exist", ([show(javaReturnType(md))])))
  check(classMethodModifierOk(md),
        "method cannot be abstact")
  check(overriddenMethodOk(c,md),
        "Overriding method does not preserve the type")
  check((Abstract `elem` javaModifiers(md) || 
         Native `elem` javaModifiers(md)) == emptyBody(body(md)),
        "method body must be empty or method cannot be final or abstract")
  if Abstract `notElem` javaModifiers(md) then do
    localOncePerBlock(argNames(md),body(md),
        "Local variable '%' already defined (probably as a formal parameter)")
    let vars = { x | (t,x) <- arguments(md) } `union` { x | (x,t) <-: this }
    b <- checkStm(((c :/ signature(md)),
                  [{(x,t) | (t,x) <- arguments(md)} +<< this],[],id), 
                  body(md))           
    abs <- checkDefiniteAssigned(vars,b)
    b' <- checkReturn(abs,b,javaModifiers(md),javaReturnType(md))
    okay(MethDec(javaModifiers(md), javaReturnType(md), methNm(md), 
                 arguments(md), b', throws(md),False))
   else
    okay md 
 where this = if Static `elem` javaModifiers(md) then 
                {} 
               else
                { ("this", TJRef(c)) }

emptyBody :: Stm -> Bool
emptyBody (Term(SSkip,_)_) = True
emptyBody _                = False

checkReturn :: ({Abruption},Stm, [Modifier], JavaType) -> Checked (Stm)
checkReturn (abs,body, ms, retType) =  do
  if Native `notElem` ms && AbNorm `elem` abs then
    if retType == TJVoid then do
       case body of
         Term(Block,_) ss 
           -> okay(Term (Block,TJVoid) 
                  (ss ++ [Term (JavaReturn "",TJVoid) []]))
         Term(StaticInit,_)[Term(Block,_)ss] 
           -> okay(Term (StaticInit,TJVoid)[Term(Block,TJVoid) 
                  (ss ++ [Term (JavaReturn "",TJVoid) []])])
         _ -> sfail "INTERNAL ERROR: Unexpected body"
      else
       sfail("Return required")
   else
    okay(body)
  
checkIfaceMethod :: (Iface,MethDec) -> Checked (MethDec)
checkIfaceMethod(i,md) = do
  setErrorPrefix(printf("interface % (method %):",([i,methNm(md)])))
  formalOncePerMethodHead(md)
  formalArgTypesOk(md)
  check(formalResTypeOk(md),
        printf("Formal type '%' does not exist", ([show(javaReturnType(md))])))
  check(ifaceMethodModifierOk(md),
        "Method must be abstract(but not static)")
  check(overriddenMethodOk(i,md),
        "Overriding method does not preserve the type")
  checkClassMethod(i,md)

-- Aux - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

-- Static methods are not abstract
classMethodModifierOk(md) = 
  (Static `elem` javaModifiers(md) || Final `elem` javaModifiers(md) ||
   Private `elem` javaModifiers(md))
    `implies` (Abstract `notElem` javaModifiers(md))

-- Iface methods must be non static and abstract
ifaceMethodModifierOk(md) = 
  methNm(md) == "<clinit>" ||
  ((Abstract `elem` javaModifiers(md)) && 
   (Static `notElem` javaModifiers(md)) &&
   (Public `elem` javaModifiers(md)))

checkVisibleMethods :: JavaClass -> Checked ()
checkVisibleMethods(c) =
  checkVisibleMethod(allVisibleMethods(c))

checkVisibleMethod :: [(MethRef,[Modifier])] -> Checked ()
checkVisibleMethod [] = done
checkVisibleMethod ((c:/msig,mods):ms) = do
   case filter f ms of
    []    -> done
    (m:_) -> checkBothVisible((c:/msig,mods),m)
   checkVisibleMethod(ms)
 where f (_:/msig',_) = msig == msig'

checkBothVisible :: ((MethRef,[Modifier]),(MethRef,[Modifier])) -> Checked ()
checkBothVisible ((c1:/msig,mods1),(c2:/_,mods2)) = do
  check(javaReturnType(c1:/msig)==javaReturnType(c2:/msig),
        printf("method '%' must have same return type as method '%'",
               [showJavaMRefArgs(c1:/msig),showJavaMRefArgs(c2:/msig)]))
  check((Public `elem` mods1) == (Public `elem` mods2),
        printf("method '%' and method '%' have different public modifier",
               [showJavaMRefArgs(c1:/msig),showJavaMRefArgs(c2:/msig)]))
  check((Static `elem` mods1) == (Static `elem` mods2),
        printf("method '%' and method '%' have different static modifier",
               [showJavaMRefArgs(c1:/msig),showJavaMRefArgs(c2:/msig)]))

overriddenMethodOk :: (JavaClass, MemDec) -> Bool
overriddenMethodOk (c,member) =
  case super(c) of
   Nothing -> True
   Just(s) -> let sig = signature(member) in
    and [ (javaReturnType(m) == javaReturnType(member)) &&
          Final `notElem` mods &&
          ((Static `elem` mods) == (Static `elem` javaModifiers(member))) &&
          Private `notElem` javaModifiers(member) &&
          (Public `elem` mods `implies` (Public `elem` javaModifiers(member))) &&
          (Protected `elem` mods `implies` 
               (Public `elem` javaModifiers(member) ||
                Protected `elem` javaModifiers(member)))
        | c' <- s : implements(c)
        , (m,mods) <- accessibleApplicableMethods (==) (c':/sig,c)
        , methNm(m) /= "<init>" ]


-- formal paramaters of each method are unique
formalOncePerMethodHead(md) = 
   once (argNames(md),
         "Formal parameter '%' already defined",
         show)

-- formal paramaters of each method must be types
formalArgTypesOk(md) = 
   checkList (argumentTypes(md), isValidType, 
              "Formal parameter type '%' does not exist",
              show)

-- return type of each method must be a type or void
formalResTypeOk(md) = 
   javaReturnType(md) == TJVoid || isValidType(javaReturnType(md))

--auxiliary
isValidType(t) = case t of
  TJRef(name)   -> name `inDom` pgm
  TJArray(t)    -> isValidType(t)
  TJVoid        -> False
  TJNull        -> False
  _             -> True

--auxiliary
isValidReferenceType(t) = case t of
  TJRef(name)   -> name `inDom` pgm
  TJArray(t)    -> isValidType(t)
  _             -> False

--Field- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
type FieldDec = MemDec

checkClassField :: (JavaClass,FieldDec) -> Checked (FieldDec)
checkClassField(c,fd) = do
  setErrorPrefix(printf("class % (field %):",([c,fieldNm(fd)])))
  check(classFieldModifierOk(fd), "Field cannot be abstract")
  check(fieldTypeOk(fd),
        printf("Field type '%' does not exist or is not accessible", ([show(fieldType(fd))])))
  okay fd

checkIfaceField :: (Iface,FieldDec) -> Checked (FieldDec)
checkIfaceField(i,fd) = do
  setErrorPrefix(printf("interface % (field %):",([i,fieldNm(fd)])))
  check(ifaceFieldModifierOk(fd), "Field must not be abstract")
  check(fieldTypeOk(fd),
        printf("Field type '%' does not exist or is not accessible", ([show(fieldType(fd))])))
  check(isJust(initialExp(fd)),
        printf("Field '%' must have initializer",[fieldNm(fd)]))
  okay fd
-- Aux - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

-- Class fields cannot be abstract
classFieldModifierOk(fd) =
  Abstract `notElem` javaModifiers(fd)

-- Iface fields are not abstract and must be static 
ifaceFieldModifierOk(fd) =
  Abstract `notElem` javaModifiers(fd)

-- Field types must exist
fieldTypeOk :: FieldInterface a => a -> Bool
fieldTypeOk(fd) =
  isValidType(fieldType(fd))

-- ---------------------------------------------------------------------
-- Checking statements
-- ---------------------------------------------------------------------
type Env = (MethRef,LocalEnv,[Lab],Lab -> Lab)
type LocalEnv = [Map Loc JavaType]

checkBlockLocs :: (Env,Stm) -> Checked Env
checkBlockLocs (env,Term(Block,_)ss) = checkLocs(env,ss)
checkBlockLocs (env,stm) = checkLocs(env,[stm])

checkLocs :: (Env,[Stm]) -> Checked Env
checkLocs (env@(ctx,locs,labs,labF),ss) = do
   let vars  = [ x | Term(LocDec t x,_)_ <- ss ]
   let nvars = nub vars
   if length vars /= length nvars then
     case vars \\ nvars of
       x:_ -> sfail(printf("Variable '%' already defined",[x]))
    else do
     let xts = {(x,t) | Term(LocDec t x,_)_  <- ss}
     seqs[check(isValidType(t),
                printf("Type '%' does not exist", 
                     ([show(t)]))) | (x,t) <-: xts] 
     result (ctx,xts : locs,labs,labF)

-- Statements
checkStm :: (Env,Stm) -> Checked Stm
checkStm (env@(ctx,locs,labs,labF),term) = case term of 
-- Javai  
  Term(SSkip,_)[]         -> okay(term)
  Term(LocDec t x,_)[]    -> okay(term)
  Term(LocDec t l,_)[i]   -> do
     i' <- checkExp(env,i)
     check(typeOfExp(i') `compatible` t,
           printf("Expression '%' not compatible to type '%'",
                  ([showPretty(i),show(t)])))
     okay(Term (LocDec t l,TJVoid) [cast(i',t)])
  Term(ExpStm,_)[e]       -> do
     e' <- checkExp(env,e)      -- can you have method calls
                                -- on the top level that don't return void? 
     okay(Term(ExpStm,TJVoid)[e'])
  Term(LabStm l,_)[Term(While,_)[e,s]] -> do
     e' <- checkExp(env,e)
     check(typeOfExp(e') == TJBoolean,
           printf("Expression '%' must be a boolean",[showPretty(e)]))
     s' <- checkStm((ctx,locs,l:labs,labF),s)
     okay(Term(LabStm l,TJVoid)[Term(While,TJVoid)[e',s']])
  Term(LabStm l,_)[Term(For _ i,_)[init,cond,upd,stm]] -> do
     env'@(_,locs',_,_) <- if i then checkBlockLocs(env,init)
                                else result env
     init' <- binds [ if i then checkStm(env',s)
                           else checkExp(env',s)
                    | s <- flattenBlock init ]
     cond' <- checkExp(env',cond)
     check(typeOfExp(cond') == TJBoolean,
           printf("Expression '%' must be a boolean",[showPretty(cond)]))
     upd'  <- binds [ checkExp(env',s) | s <- flattenBlock upd ]
     stm' <- checkStm((ctx,locs',l:labs,labF),stm)
     okay(Term (LabStm l,TJVoid)[Term(For l i,TJVoid)
                [buildBlock init',cond',buildBlock upd',stm']])
  Term(While,_)[e,s]      -> do 
     e' <- checkExp(env,e)
     check(typeOfExp(e') == TJBoolean,
           printf("Expression '%' must be a boolean",[showPretty(e)]))
     if containsUnlabeledJump(s) then do
       let l = genLab(labs)
       s' <- checkStm((ctx,locs,l:labs,labF),s)
       okay(Term (LabStm l,TJVoid)[Term(While,TJVoid)[e',s']])
      else do
       s' <- checkStm((ctx,locs,labs,labF),s)
       okay(Term(While,TJVoid)[e',s'])
  Term(For _ i,_)[init,cond,upd,stm] -> do
     env'@(_,locs',_,_) <- if i then checkBlockLocs(env,init)
                                else result env
     init' <- binds [ if i then checkStm(env',s)
                           else checkExp(env',s)
                    | s <- flattenBlock init ]
     cond' <- checkExp(env',cond)
     check(typeOfExp(cond') == TJBoolean,
           printf("Expression '%' must be a boolean",[showPretty(cond)]))
     upd'  <- binds [ checkExp(env',s) | s <- flattenBlock upd ]
     if containsUnlabeledJump(stm) then do
       let l = genLab(labs)
       stm' <- checkStm((ctx,locs',l:labs,labF),stm)
       okay(Term (LabStm l,TJVoid)
          [Term(For l i,TJVoid)[buildBlock init',cond',buildBlock upd',stm']])
      else do
       stm'  <- checkStm(env',stm)
       okay(Term(For "" i,TJVoid)[buildBlock init',cond',buildBlock upd',stm'])
  Term(IfStm,_)[e,s1,s2] -> do 
     e' <- checkExp(env,e)
     check(typeOfExp(e') == TJBoolean,
           printf("Expression '%' must be a boolean",[showPretty(e)]))
     s1' <- checkStm(env,s1)
     s2' <- checkStm(env,s2)
     okay(Term(IfStm,TJVoid)[e',s1',s2'])
  Term(Block,_)ss         -> do
     env' <- checkLocs(env,ss)
     ss' <- binds[checkStm(env',s) | s <- ss]
     okay(Term(Block,TJVoid)ss') 
{-
  Term(LabStm l,_)[s@(Term(LabStm _,_)_)] -> do
     let l'      = targetLabel(l,s)
     let labF' x = if x == l then l' else labF x
     checkStm((ctx,locs,labs,labF'),s)
-}
  Term(LabStm l,_)[s]     -> do 
--     s' <- checkStm((ctx,locs,if denotesLoop(s) then l:labs else labs,labF),s)
     s' <- checkStm((ctx,locs,labs,labF),s)
     okay(Term(LabStm l,TJVoid)[s'])
  Term(Continue l,t) []
     | l == ""          -> okay(Term(Continue (labs!!(0)),TJVoid)[])
     | otherwise        -> do
       let l' = labF(l)
       check(l' `elem` labs,
             printf("Continue label '%' must point to a loop statement", ([l])))
       okay(Term(Continue l',t)[])
  Term(Break l,t) []
     | l == ""          -> okay(Term(Break (labs!!(0)),TJVoid)[])
     | otherwise        -> okay(Term(Break (labF l),t)[])
--Javac
  Term(StaticInit,_) [s]  -> do
     s' <- checkStm(env,s)
     okay(Term(StaticInit,typeOfExp(s'))[s'])
  Term(JavaReturn tries,_) [e]  -> do
     e' <- checkExp(env,e)
     let rt  = javaReturnType(ctx)
     check(typeOfExp(e') `compatible` rt,
           "Expr '%' is not compatible to return type")
     okay(Term(JavaReturn tries,TJVoid) [cast(e',rt)])
  Term(JavaReturn tries,_) []   -> do
     let rt = javaReturnType(ctx)
     check(rt == TJVoid, "Return must return value")
     okay(term)
--Javao
--Javae
  Term(ThrowExc,_)[e]        -> do   
     e' <- checkExp(env,e)
     check(typeOfExp(e') `compatible` throwableType,
           "Type '%' is not compatible with java.lang.Throwable")
     okay(Term(ThrowExc, TJVoid)[e'])
  Term(Try,_)(ss)         -> do
     ss' <- binds[checkStm(env,s) | s <- ss]
     okay(Term(Try,TJVoid)(ss'))
  Term(Finally _,_)[try,fin]     -> do
     try' <- checkStm(env,try)
     fin' <- checkStm(env,fin)
     okay(Term(Finally (assignments(fin')),TJVoid)[try',fin'])
  Term(Catch(t',x),_)[s]  -> do
     check(isClassType(TJRef(t')),
           printf("Type '%' does not exist", ([show(t')])))
     check(t' `compatible` throwableClass,
           "Type '%' is not compatible with class Throwable")
     s' <- checkStm((ctx,{(x,TJRef(t'))} : locs,labs,labF),s)
     okay(Term(Catch(t',x),TJVoid)[s'])                                       
--Javat
  Term(SynBlock,_)[e,s]   -> do
     e' <- checkExp(env,e)
     check(isValidReferenceType(typeOfExp(e')),
           printf("Type '%' does not exist", ([show(typeOfExp(e'))])))
     s' <- checkStm(env,s)
     okay(Term(SynBlock,TJVoid)[e',s'])
  x -> sfail ("<ERROR>:checkStm: " ++ show' x)


-- aux - -

-- ---------------------------------------------------------------------
-- Type checkence of expressions
-- ---------------------------------------------------------------------
checkExp :: (Env,Exp) -> Checked Exp
checkExp(env@(ctx,locs,_,_),term) = case term of
  Term(Lit v,_) []        -> do
     okay (litExp(v))
  Term(Una op,_) [e]      -> do
     e'     <- checkExp(env,e)
     (t,t') <- checkUna(op,typeOfExp(e'))
     okay (Term(Una op,t)[cast(e',t')])
  Term(Bin op,_) [e0,e1]  -> do
     e0'       <- checkExp(env,e0)
     e1'       <- checkExp(env,e1)
     (t,tl,tr) <- checkBin(op,typeOfExp(e0'), typeOfExp(e1'))
     okay (Term(Bin op,t)[cast(e0',tl) , cast(e1',tr) ])
  
  Term(LocAcc loc,_)[]    -> do
     check(loc `definedInEnv` locs, 
           printf("Local '%' does not exist",([loc])))
     okay(locAcc(loc,locs##(loc)))
  Term(LocInc loc,_)[]    -> do
     check(loc `definedInEnv` locs, 
           printf("Local '%' does not exist",([loc])))
     okay(locInc(loc,locs##(loc)))
  Term(LocDecr loc,_)[]    -> do
     check(loc `definedInEnv` locs, 
           printf("Local '%' does not exist",([loc])))
     okay(locDecr(loc,locs##(loc)))
  Term(LocAss loc,_) [e]  -> do
     e'  <- checkExp(env, e)
     check(loc `definedInEnv` locs,
           printf("Local '%' does not exist",([loc])))
     check(typeOfExp(e') `compatible` locs##(loc),
           printf("Expression '%' not compatible to type '%'",
                  ([showPretty(e),show(locs##(loc))])))
     okay(locAss(loc,locs##(loc), cast(e',locs##(loc))))
  
  Term(IfExp,_)[e0,e1,e2] -> do
     e0'  <- checkExp(env,e0)
     e1'  <- checkExp(env,e1)
     e2'  <- checkExp(env,e2)
     check (typeOfExp(e0') == TJBoolean,
            "Type of '%' must be boolean") 
     t    <- checkThenElse(typeOfExp(e1'), typeOfExp(e2'))
     okay (Term(IfExp,t)[e0',cast(e1',t) , cast(e2',t)])

--Javac: Zugriff auf Felder und Methoden muss eindeutig sein, 
-- keine most specific methods,
-- Overloading jedoch bereits unterstuetzt.

  Term(ClassAcc(c :/ f),_)[]-> do
     check(isClassType(TJRef(c)),
           printf("Reference type '%' does not exist",([c])))
     check(visibleFieldsInCtx(c :/ f,classNm(ctx))==[c :/ f],
           printf("Field '%' is not accessible or is not unique",
                  ([showJavaFRef(c :/ f)])))
     case initialExp (c:/f) of
       Nothing -> okay(classAcc(c:/f))
       Just e  -> if isConstant e && Final `elem` javaModifiers(c:/f) then
                     checkExp(env,e)
                  else okay(classAcc(c:/f))
  Term(ClassAss(c :/ f),_)[e] -> do
     check(isClassType(TJRef(c)),
           printf("Reference type '%' does not exist",([c])))
     e' <- checkExp(env, e)
     check(visibleFieldsInCtx((c :/ f),classNm(ctx))==[c :/ f],
           printf("Field '%' is not accessible or is not unique",
                  ([showJavaFRef(c :/ f)])))
     check(typeOfExp(e') `compatible` fieldType(c :/ f),
           printf("Expression '%' not compatible to type '%'",
                  ([showPretty(e), show(fieldType(c :/ f))])))
     okay(classAss(c :/ f, cast(e',fieldType(c :/ f))))
  Term(ClassInv(c :/ m),_)[Term(ArgList,_)es] -> do
     check(isClassType(TJRef(c)),
           printf("Reference type '%' does not exist",([c])))
     es' <- binds [checkExp(env,e) | e <- es]
     check(map fst (accessibleApplicableMethods compatible (c :/ m,classNm(ctx)))==[c :/ m],
           printf("Method '%' is not accessible or is not unique",
                  ([showJavaMRefArgs(c :/ m)])))
     okay(classInv(c :/ m, [ cast(e',t) 
                          | (e',t) <- zip es' (argumentTypes(c :/ m))]))
--Javao
  Term(This,_)[]          -> do
     checkExp(env,locAcc("this", TJNoType))
  Term(NewClass c,_)[] -> do
     check(isInstantiableClass(c),
           printf("Class '%' does not exist or is not instantiable", ([c])))
     okay(Term(NewClass c,TJRef(c))[])
  Term(Instanceof t,_)[e] -> do
     check(isValidReferenceType(t),
           printf("Type '%' does not exist",([show(t)])))
     e' <- checkExp(env,e)
     okay(Term(Instanceof t,TJBoolean)[e'])  
  Term(Classcast t,_)[e]  -> do
     check(isValidReferenceType(t),
           printf("Type '%' does not exist",([show(t)])))
     e' <- checkExp(env,e)
     okay(classCast(t,e'))
  Term(Typecast t@(TJArray(_)),_)[e] -> do
     check(isValidReferenceType(t),
           printf("Type '%' does not exist",([show(t)])))
     e' <- checkExp(env,e)
     okay(classCast(t,e'))
  Term(Typecast t,_)[e]  -> do
     check(isValidType(t),
           printf("Type '%' does not exist",([show(t)])))
     e' <- checkExp(env,e)
     check(castable(typeOfExp(e'),t),
           printf("Cannot cast type '%' to type '%'", 
                  ([show(typeOfExp(e')), show(t)])))
     okay(cast(e',t))
  Term(FieldAcc(fr),_) [r]    -> okay(term)
  Term(FieldAss(fr),_) [r,e]   -> okay(term)
  Term(InstanceInv mr ck,_)_ -> okay(term)

--JavaArrays
  Term(ArrayAcc,_)[r,i]   -> do
     r' <- checkExp(env,r)
     check(isArray(typeOfExp(r')),
           printf("Exp '%' is not an array",[showPretty(r)]))
     i' <- checkExp(env,i)
     check(typeOfExp(i') `compatible` TJInt,
           printf("Invalid type '%' for array index",
                  ([show(typeOfExp(i'))])))
     okay(Term(ArrayAcc, arrayType(typeOfExp(r')))[r',cast(i',TJInt)])
  Term(ArrayAss, _)[r,i,e] -> do
     r' <- checkExp(env,r)
     check(isArray(typeOfExp(r')),
           printf("Exp '%' is not an array",[showPretty(r)]))
     i' <- checkExp(env,i)
     e' <- checkExp(env,e)
     check(typeOfExp(i') `compatible` TJInt,
           printf("Invalid type '%' for array index",
                  ([show(typeOfExp(i'))])))
     check(typeOfExp(e') `compatible` arrayType(typeOfExp(r')),
           printf("Expression '%' not compatible to type '%'",
                  ([showPretty(e),show(arrayType(typeOfExp(r')))])))
     okay(Term(ArrayAss, arrayType(typeOfExp(r')))
           [r',cast(i',TJInt),cast(e',arrayType(typeOfExp(r')))])
  Term(NewJavaArray,t)es    -> do
     check(isValidType(t),
           printf("Invalid type '%'",([show(t)])))
     es' <- binds [checkExp(env,e) | e <- es]
     check(and [ typeOfExp(e') `compatible` TJInt | e' <- es'],
           printf("Invalid types '%' for new array",
                  ([show(map typeOfExp es')])))
     okay(Term(NewJavaArray,t)[cast(e',TJInt) | e' <- es'])

-- AUXILIARY CONSTRUCTS (ELIMINATED AFTER CONTEXTCHECKING)

  Term(AccName n,_)[]     
     |  n `definedInEnv` locs ->
        checkExp(env,locAcc(n,TJNoType))
     |  n == "super" -> do
        check(super(classNm(ctx)) /= Nothing,
              "Class '%' has no super class")
        checkExp(env,classCast(TJRef(just(super(classNm(ctx)))),locAcc("this",TJNoType)))
     |  "this" `definedInEnv` locs ->
        checkExp(env,qualAcc(n, TJNoType, locAcc("this",TJNoType)))
     |  otherwise -> do
        fr <- checkAccessibleUniqueField((classNm(ctx) :/ n),classNm(ctx))
        if isClassField(fr) then
          checkExp(env,classAcc(fr))
         else
          sfail(printf("Cannot access static field '%'",
                       ([showJavaFRef(fr)])))
  Term(AssName(n),_)[e]
     |  n `elem` ["this","super"] -> do
        sfail("this and super can not be assigned")
     |  n `definedInEnv` locs ->
        checkExp(env,locAss(n,TJNoType,e))
     |  otherwise -> do
        fr <- checkAccessibleUniqueField((classNm(ctx) :/ n),classNm(ctx))
        if isClassField(fr) then
          checkExp(env,classAss(fr, e))
         else
          checkExp(env,qualAss(n, TJNoType, locAcc("this",TJNoType),e))
  Term(QualAcc(f),_)[e]
     | denotesTypeName(e)-> do
       check(isClassType(TJRef(typeName(e))),
             "Reference Type '%' does not exist")
       fr <- checkAccessibleUniqueField((typeName(e) :/ f),classNm(ctx))
       if isInstField(fr) then
         sfail(printf("Instance field '%' can not be called without target expression",[showJavaFRef(fr)]))
        else
         checkExp(env,classAcc(fr))
     | otherwise -> do
       e' <- checkExp(env,e)
       check(isClassArrType(typeOfExp(e')),
             printf("The target expression '%' must have a reference type",[showPretty(e)]))
       fr <- checkAccessibleUniqueField((refOf(typeOfExp(e')) :/ f),classNm(ctx))
       if isClassField(fr) then
         checkExp(env,classAcc(fr))
        else
         okay(fieldAcc(fr, e'))
  Term(QualAss(f),_)[e0,e1]
     | denotesTypeName(e0) -> do
       check(isClassType(TJRef(typeName(e0))),
             printf("Type '%' is  not a reference type",[showPretty(e0)]))
       fr <- checkAccessibleUniqueField((typeName(e0) :/ f),classNm(ctx))
       if isInstField(fr) then
         sfail(printf("Instance field '%' can not be called without target expression",[showJavaFRef(fr)]))
        else do
         e1' <- checkExp(env,e1)
         check(typeOfExp(e1') `compatible` fieldType(fr),
               printf("Expression '%' is not compatible to type '%'",
                      ([showPretty(e1), show(fieldType(fr))])))
         okay(classAss(fr, cast(e1',fieldType(fr))))
     | otherwise -> do
         e0' <- checkExp(env,e0)
         check(isClassArrType(typeOfExp(e0')),
               "The target expression '%' is  not a reference type")
         fr <- checkAccessibleUniqueField((refOf(typeOfExp(e0')):/f),classNm(ctx))
         if fr == "Array":/"length" then
            sfail("Cannot assign a value to array field 'length'")
          else done
         e1' <- checkExp(env,e1)  
         check(typeOfExp(e1') `compatible` fieldType(fr),
               printf("Expression '%' is not compatible to type '%'",
                      ([showPretty(e1), show(fieldType(fr))])))
         if isClassField(fr) then
           okay(classAss(fr, cast(e1',fieldType(fr))))
          else
           okay(fieldAss(fr, e0',cast(e1',fieldType(fr))))
  Term(Invoke(m),_)es   -> do
     es' <- binds [checkExp(env,e) | e <- es]
     mr <- checkApplicableAccessibleMostSpecific(
                 (classNm(ctx) :/ (m,map typeOfExp es')),classNm(ctx))
     if isClassMeth(ctx) then
       if isInstMeth(mr) then
         sfail(printf("Instance method '%' can not be called without target expression",[showJavaMRef(mr)]))
        else
         okay(classInv(mr, [cast(y) | y <- zip es' (argumentTypes(mr))]))
      else
       if isInstMeth(mr) then
         okay(instInv(mr, callKind(mr), 
                      locAcc("this",TJRef(classNm(ctx))),
                        [cast(y) | y <- zip es' (argumentTypes(mr))]))
       else
         okay(classInv(mr, [cast(y) | y <- zip es' (argumentTypes(mr))]))
  Term(QualInvoke(m),_)(e:es)
     | denotesTypeName(e) -> do
       es' <- binds [checkExp(env,e) | e <- es]
       mr <- checkApplicableAccessibleMostSpecific(
                (typeName(e) :/ (m,map typeOfExp es')), classNm(ctx))
       if isInstMeth(mr) then
         sfail(printf("Instance method '%' can not be called without target expression",[showJavaMRef(mr)]))
        else
         okay(classInv(mr, [cast(y) | y <- zip es' (argumentTypes(mr))]))
     | otherwise -> do
       e' <- checkExp(env,e)
       check(isClassArrType(typeOfExp(e')),
             printf("The target expression '%' must have a reference type",
                    ([showPretty(e)])))
       let c = refOf(typeOfExp(e'))
       es' <- binds [checkExp(env,e) | e <- es]
       if m == "<init>" then do
         mr <- checkApplicableAccessibleConstructor(instanceInit(c,map typeOfExp es'),
                                                              classNm(ctx))
         okay(instInv(mr, if denotesSuper(e) then Super else Special,
                          if denotesSuper(e) then Term (This,TJRef(classNm(ctx))) []
                          else e', [cast(y) | y <- zip es' (argumentTypes(mr))]))
        else do
         mr <- checkApplicableAccessibleMostSpecific(
                 (c :/ (m,map typeOfExp es')), classNm(ctx))
         if isInstMeth(mr) then
           okay(instInv(mr, if denotesSuper(e) then Super else callKind(mr),
              (if denotesSuper(e) then Term (This,TJRef(classNm(ctx))) [] else e'),
               [cast(y) | y <- zip es' (argumentTypes(mr))]))
          else
           okay(classInv(mr, [cast(y) | y <- zip es' (argumentTypes(mr))]))
  Term(IncOperator,_)[e] -> do
        e'  <- checkExp(env,e)
        case e' of
          Term(LocAcc l,t)[] -> do
            check(typeOfExp(e') `compatible` TJInt,
               printf("Invalid type '%' for expression '%'",
                   ([show(typeOfExp(e')),showPretty e])))
            result(Term(LocInc l,t)[])
          Term(ClassAcc(c :/ f),_)[] -> 
               sfail("Operator '++' supported only for local variables")
          Term(FieldAcc(fr),_) [r]   ->
               sfail("Operator '++' supported only for local variables")
          _ -> sfail(printf("Operator '++' can not be applied to '%'",
                            [showPretty(e)]))
  Term(DecOperator,_)[e] -> do
        e'  <- checkExp(env,e)
        case e' of
          Term(LocAcc l,t)[] -> do
            check(typeOfExp(e') `compatible` TJInt,
               printf("Invalid type '%' for expression '%'",
                   ([show(typeOfExp(e')),showPretty e])))
            result(Term(LocDecr l,t)[])
          Term(ClassAcc(c :/ f),_)[] -> 
               sfail("Operator '--' supported only for local variables")
          Term(FieldAcc(fr),_) [r]   ->
               sfail("Operator '--' supported only for local variables")
          _ -> sfail(printf("Operator '--' can not be applied to '%'",
                            [showPretty(e)]))
  x -> sfail ("<ERROR>:checkExp: " ++ show' x)


-- ---------------------------------------------------------------------
-- Checking applicability,  accesibility, uniqueness of members
-- ---------------------------------------------------------------------
checkAccessibleUniqueField :: (FieldRef,JavaClass) -> Checked FieldRef
checkAccessibleUniqueField(fr,ctxClass) =
  case visibleFieldsInCtx(fr,ctxClass) of
    []    -> sfail(printf("The field '%' is not visible",([showJavaFRef(fr)])))
    [fr'] -> okay(fr')
    _     -> sfail(printf("The field '%' is not unique",
                         ([showJavaFRef(fr)])))

checkApplicableAccessibleMostSpecific :: (MethRef,JavaClass) -> Checked MethRef
checkApplicableAccessibleMostSpecific(mr,ctxClass) =
  case accessibleApplicableMethods compatible (mr,ctxClass) of
    []  -> sfail(printf("The method '%' must be accessible and applicable",
                        ([showJavaMRefArgs(mr)])))
    mrs -> case mostSpecificMethod(map fst mrs) of 
            Nothing -> sfail(printf("method '%' is ambiguous",
                                    ([showJavaMRefArgs(mr)])))
            Just(mr')-> okay(mr')                                 

checkApplicableAccessibleConstructor :: (MethRef,JavaClass) -> Checked MethRef
checkApplicableAccessibleConstructor(mr,ctxClass) =
  case accessibleApplicableConstructors(mr,ctxClass) of
    []  ->  sfail(printf("The constructor '%' must be accessible and applicable",
                 ([showJavaMRefArgs(mr)])))
    mrs -> case mostSpecificMethod(map fst mrs) of 
             Nothing   -> sfail(printf("constructor '%' is ambiguous",
                                      ([showJavaMRefArgs(mr)])))
             Just(mr') -> okay(mr')                                 


-- ---------------------------------------------------------------------
-- Checking unary and binary operators
-- ---------------------------------------------------------------------

-- Staerk P. 13, Table 2.3 
checkBin :: (Bin, JavaType, JavaType) -> Checked (JavaType, JavaType, JavaType)
checkBin(op,t1,t2)
   | op `elem` ["+","-","/","*","%"] &&
     numeric(t1) && numeric(t2) 
      = let t = maxType([t1,t2,TJInt]) in
        okay(t,t,t)
   | op `elem` ["<",">","<=",">="] &&
     numeric(t1) && numeric(t2)
      = let t = maxType([t1,t2,TJInt]) in
        okay(TJBoolean,t,t)
   | op == "+" && ((string(t1) && (refType(t2) || t2==TJInt || t2==TJChar)) || 
                   (string(t2) && (refType(t1) || t1==TJInt || t1==TJChar)))
      = let t = TJRef(stringClass) in
        okay(t,t,t)
   | op `elem` ["==","!="] && t1 `compatible` t2
      = okay(TJBoolean,t2,t2)
   | op `elem` ["==","!="] && t2 `compatible` t1
      = okay(TJBoolean,t1,t1)
   | op `elem` ["&&","||"] && boolean(t2) && boolean(t1)
      = okay(TJBoolean,TJBoolean,TJBoolean)
   | otherwise
     = sfail(printf("invalid types for operator '%'", ([op])))

-- Staerk P. 13, Table 2.2 
checkUna :: (Una, JavaType) -> Checked (JavaType, JavaType)
checkUna(op,t)
   | op == "-" && numeric(t)
     = let t' = maxType([t,TJInt]) in
       okay(t',t')
   | op == "!" && boolean(t)
     = okay(t,t)
   | otherwise
     = case op of
         "b2s" -> okay(TJShort,t)
         "s2i" -> okay(TJInt,t)
         "i2l" -> okay(TJLong,t)
         "l2f" -> okay(TJFloat,t)
         "f2d" -> okay(TJDouble,t)
         "c2i" -> okay(TJInt,t)
         _ -> sfail(printf("invalid types for operator '%'", ([op])))


checkThenElse(t1,t2)
  | numeric(t1) && numeric(t2)  = okay(maxType[t1,t2,TJInt])
  | t1 `compatible` t2          = okay(t2)
  | t2 `compatible` t1          = okay(t1)
  | otherwise                   = sfail("Then and else expressions are not both numeric" ++
                                       "nor is one a subtype of the other")
  
    
-- ---------------------------------------------------------------------
-- Cast
-- ---------------------------------------------------------------------

cast(e,t)
  | typeOfExp(e) == t = e
  | isPrimType(typeOfExp(e)) && isPrimType(t) =
    case maplookup primCompatible (typeOfExp(e),t) of
          Just(f) -> f(e)
          Nothing -> case maplookup primCastable (typeOfExp(e),t) of
                      Just(f) -> f(e)
                      Nothing -> error ("cannot find conversion from " ++ 
                                        show' (typeOfExp(e)) ++
                                        " to " ++ show' t)
  | typeOfExp(e) `compatible` t = e
  | otherwise = case (typeOfExp(e),t) of
      (TJInt,TJRef("String")) -> 
         Term(ClassInv("String" :/ ("valueOf",[TJInt])),stringType)
            [Term(ArgList,TJVoid)[e]]
      (TJChar,TJRef("String")) -> 
         Term (ClassInv("String" :/ ("valueOf",[TJChar])),stringType)
            [Term(ArgList,TJVoid)[e]]
      (TJRef(c),TJRef("String")) ->
         Term (InstanceInv("Object" :/ ("toString",[])) Virtual,stringType)
            [e,Term(ArgList,TJVoid)[]]
      _ -> error ("cannot find conversion from " ++ show' (typeOfExp(e)) ++
                  " to " ++ show' t)

castable :: (JavaType, JavaType) -> Bool
castable (t,t') =
  t == t' ||
  isPrimType(t) && isPrimType(t') && 
     (isJust(maplookup primCompatible (t,t')) ||
      isJust(maplookup primCastable   (t,t'))) ||
  t `compatible` t'                

-- ---------------------------------------------------------------------
-- Aux 
-- ---------------------------------------------------------------------

-- locals in each body are unique
localOncePerBlock(xs,t,msg)  = case t of 
   Term(While,_)[e,s]     -> localOncePerBlock(xs,s,msg)
   Term(IfStm,_)[e0,s1,s2]-> seqs  [localOncePerBlock(xs,s,msg) | s <- [s1,s2]]
   Term(Block,_)ss        -> let ys = [y | Term(LocDec _ y,_)[] <- ss]
                             in do once(xs ++ys,msg,show)
                                   seqs [localOncePerBlock(ys++xs,s,msg) | s <- ss]
   Term(Try,_)(s:ss)      -> seqs  [localOncePerBlock(xs,s,msg) | s <- ss]
   Term(Catch(t,x),_)[s]  -> do
                           once(x:xs,msg,show)
                           localOncePerBlock(x:xs,s,msg)
   Term(StaticInit,_)[s]  -> localOncePerBlock(xs,s,msg)
   Term(Finally _,_)[s1,s2] -> do localOncePerBlock(xs,s1,msg)
                                  localOncePerBlock(xs,s2,msg)
   Term(LabStm _,_)[s]    -> localOncePerBlock(xs,s,msg)
   Term(SynBlock,_)[e,s]  -> localOncePerBlock(xs,s,msg)
   Term(For _ False,_)[init,cond,upd,stm] -> localOncePerBlock(xs,stm,msg)
   Term(For _ _,_)[init,cond,upd,stm] -> localOncePerBlock(xs,Term(Block,TJVoid)[init,stm],msg)
   Term(_)(_)           -> done

-- every local variable is assigned before it is used
type Vars       = { Loc }
type Before     = Vars
type After      = Vars
type AfterTrue  = Vars
type AfterFalse = Vars

checkDefiniteAssigned :: (Vars, Stm) -> Checked {Abruption}
checkDefiniteAssigned(vars,stm) = do
   setLocalVariables(vars)
   (after,abs) <- checkDefiniteAssignedStm(vars,stm)
   result(abs)

checkDefiniteAssignedStm :: (Before, Stm) -> Checked (After,{Abruption})
checkDefiniteAssignedStm (before, stm) = case stm of
-- Javai
   Term(LocDec _ l,_)[] -> do
                         addLocalVariable(l)
                         result(before,{AbNorm})
   Term(LocDec _ l,_)[i]-> do
                         addLocalVariable(l)
                         after <- checkDefiniteAssignedExp(before,i)
                         result (after `union` {l},{AbNorm})
   Term(SSkip,_)[]      -> result(before,{AbNorm})
   Term(ExpStm,_)[e]    -> do after <- checkDefiniteAssignedExp(before,e)
                              result (after,{AbNorm})
   Term(LabStm l,_)[s]  -> do
                         clearLabelSets(l)
                         (after,abs) <- checkDefiniteAssignedStm(before,s)
                         breakBefore <- getBreakSets(l)
                         let abs' = if AbBreak l `elem` abs then
                                       { AbNorm } `union`
                                       (abs `difference` { AbBreak l })
                                    else abs
                         result (after `intersect` breakBefore,abs')
   Term(Break l,_)[]    -> do
                         setBreakSet(l,before)
                         vars <- getLocalVariables
                         result (vars,{AbBreak l})
   Term(Continue l,_)[] -> do 
                         setContinueSet(l,before)
                         vars <- getLocalVariables
                         result(vars,{})
   Term(IfStm,_)[c,t,e] -> do
                         (true,false) <- checkDefiniteAssignedBoolExp(before,c)
                         (after1,abs1) <- checkDefiniteAssignedStm(true,t)
                         (after2,abs2) <- checkDefiniteAssignedStm(false,e)
                         result(after1 `intersect` after2,abs1 `union` abs2)
   Term(While,_)[c,stm] -> do
                         (true,false) <- checkDefiniteAssignedBoolExp(before,c)
                         (_,abs) <- checkDefiniteAssignedStm(true,stm)
                         let abs' = if constBool False (c) then { AbNorm }
                                    else if constBool True (c) then
                                      abs `difference` { AbNorm }
                                    else abs `union` { AbNorm }
                         result(false,abs')
   Term(Block,_)ss      -> do 
                          vars <- getLocalVariables
                          (after,abs) <- checkDefiniteAssignedBlock(before,ss)
                          setLocalVariables(vars)
                          result (after `intersect` vars,abs)
-- Javac
   Term(StaticInit,_)[s]  -> checkDefiniteAssignedStm(before,s)
   Term(JavaReturn _,_)[]   -> do vars <- getLocalVariables
                                  result (vars,{})
   Term(JavaReturn _,_)[e]  -> do
                           checkDefiniteAssignedExp(before,e)
                           vars <- getLocalVariables
                           result (vars,{})
-- Javao
-- Javae
   Term(ThrowExc,_)[e]  -> do checkDefiniteAssignedExp(before,e)
                              vars <- getLocalVariables
                              result (vars,{})
   Term(Try,_)(s:ss)    -> do 
        (at,absS) <- checkDefiniteAssignedStm(before,s)
        let catchers = zip [1..] [ (c,x,s) | Term (Catch(c,x),_)[s] <- ss ]
            cClasses = [ (i,c) | (i,(c,_,_)) <- catchers ]
            reachable(i,c) = and [ j>=i || not(c `compatible` c')
                                 | (j,c') <- cClasses ]
        vars <- getLocalVariables
        res <- binds [ do
                 addLocalVariable x
                 x <- checkDefiniteAssignedStm(before `union` {x},s)
                 setLocalVariables vars
                 result x
               | (i,(c,x,s)) <- catchers, reachable(i,c) ]
        result (bigIntersect({},mkSet(at:map fst res)),
                absS `union` bigUnion({ abs | (_,abs) <- res }))
   Term(Finally locs,_)[s,f] -> do 
        (at,absS) <- checkDefiniteAssignedStm(before,s)
        (af,absF) <- checkDefiniteAssignedStm(before,f)
        let af'  = af `union` (at `difference` locs)
            abs' = if AbNorm `elem` absF then
                     absS `union` (absF `difference` { AbNorm })
                   else absF
        seqs [ setBreakSet(l,af') | AbBreak l <-: abs' ]
        result(af',abs')

-- Javat
   Term(SynBlock,_)[e,s] -> do
        after <- checkDefiniteAssignedExp(before,e)
        checkDefiniteAssignedStm(after,s)
-- Additional
   Term(For l True,t1)[init,cond,upd,stm] -> do
        vars <- getLocalVariables
        (after,_) <- checkDefiniteAssignedBlock(before,flattenBlock init)
        (true,false) <- checkDefiniteAssignedBoolExp(after,cond)
        (after',abs) <- checkDefiniteAssignedStm(true,stm)
        continueBefore <- getContinueSets(l)
        checkDefiniteAssignedExp(after' `intersect` continueBefore,upd)
        let abs' = if constBool False (cond) then { AbNorm }
                   else if constBool True (cond) then
                          abs `difference` { AbNorm }
                        else abs `union` { AbNorm }
        setLocalVariables(vars)
        result (false `intersect` vars,abs')
   Term(For l False,_)[init,cond,upd,stm] -> do
        after <- checkDefiniteAssignedExpList(before,flattenBlock init)
        (true,false) <- checkDefiniteAssignedBoolExp(after,cond)
        (after',abs) <- checkDefiniteAssignedStm(true,stm)
        continueBefore <- getContinueSets(l)
        checkDefiniteAssignedExp(after' `intersect` continueBefore,upd)
        let abs' = if constBool False (cond) then { AbNorm }
                   else if constBool True (cond) then
                          abs `difference` { AbNorm }
                        else abs `union` { AbNorm }
        result (false,abs')
   s -> error ("checkDefiniteAssignedStm: " ++ show'(s))

checkDefiniteAssignedBlock :: (Before, [Stm]) -> Checked (After,{Abruption})
checkDefiniteAssignedBlock (before,[])   = result(before,{AbNorm})
checkDefiniteAssignedBlock (before,s:ss) = do 
   (after,abs) <- checkDefiniteAssignedStm(before,s)
   (af,absSS) <- checkDefiniteAssignedBlock(after,ss)
   let abs' = if AbNorm `elem` abs then
                (abs `difference` { AbNorm }) `union` absSS
              else abs
   result (af,abs')

checkDefiniteAssignedId :: (Before, Loc) -> Checked ()
checkDefiniteAssignedId(before, l) = do
  if l `elem` before then 
    done
   else 
    sfail (printf("local variable '%' may not have been initialized", [l]))

checkDeclaredId :: Loc -> Checked ()
checkDeclaredId l = do
  vars <- getLocalVariables
  if l `elem` vars then 
    done
   else 
    sfail (printf("undeclared local variable '%'", [l]))

checkDefiniteAssignedExp :: (Before, Exp) -> Checked After
checkDefiniteAssignedExp (before,exp) = case exp of
--Javai
    Term(LocAcc l,_)[]     -> do
      checkDeclaredId(l)
      checkDefiniteAssignedId(before, l)
      result(before)
    Term(LocInc l,_)[]     -> do
      checkDeclaredId(l)
      checkDefiniteAssignedId(before, l)
      result(before)
    Term(LocDecr l,_)[]     -> do
      checkDeclaredId(l)
      checkDefiniteAssignedId(before, l)
      result(before)
    Term(LocAss l,_)[e]    -> do
      checkDeclaredId(l)
      after <- checkDefiniteAssignedExp(before,e)
      result(after `union` {l})
    Term(op,t)es
     | t == TJBoolean &&
       (op==IfExp || op==Una("!") ||
        op==Bin("&&") || op==Bin("||")) -> do
       (true,false) <- checkDefiniteAssignedBoolExp(before,exp)
       result (true `intersect` false)
    Term(IfExp,_)[c,t,e]   -> do
      (true,false) <- checkDefiniteAssignedBoolExp(before,c)
      at <- checkDefiniteAssignedExp(true,t)
      af <- checkDefiniteAssignedExp(false,e)
      result(at `intersect` af)
--Javac
    Term(op)es -> checkDefiniteAssignedExpList(before,es)
    _ -> error "checkDefiniteAssignedExp"

checkDefiniteAssignedExpList :: (Before, [Exp]) -> Checked (After)
checkDefiniteAssignedExpList (before,[])   = result (before)
checkDefiniteAssignedExpList (before,e:es) = 
  do after <- checkDefiniteAssignedExp(before,e)
     checkDefiniteAssignedExpList(after,es)

checkDefiniteAssignedBoolExp :: (Before, Exp) -> Checked (AfterTrue, AfterFalse)
checkDefiniteAssignedBoolExp (before, exp) = case exp of
     Term(Lit(TB True),_)[] -> do
       vars <- getLocalVariables
       result(before, vars)
     Term(Lit(TB False),_)[] -> do
       vars <- getLocalVariables
       result(vars, before)
     Term(Una(op),_)[e]
       | op=="!"  -> do
         (true,false) <- checkDefiniteAssignedBoolExp(before,e)
         result (false,true)
     Term(Bin(op),_)[e1,e2]
       | op == "&&" -> do
         (te1,fe1) <- checkDefiniteAssignedBoolExp(before,e1)
         (te2,fe2) <- checkDefiniteAssignedBoolExp(te1,e2)
         result(te2, fe1 `intersect` fe2)
       | op == "||" -> do
         (te1,fe1) <- checkDefiniteAssignedBoolExp(before,e1)
         (te2,fe2) <- checkDefiniteAssignedBoolExp(fe1,e2)
         result(te1 `intersect` te2, fe2)
     Term(IfExp,_)[c,t,e]   -> do
         (tc,fc) <- checkDefiniteAssignedBoolExp(before,c)
         (tt,ft) <- checkDefiniteAssignedBoolExp(tc,t)
         (te,fe) <- checkDefiniteAssignedBoolExp(fc,e)
         result( tt `intersect` te, ft `intersect` fe)
     _ -> do 
         after <- checkDefiniteAssignedExp(before,exp)
         result (after,after)

-- AUX------------------------------------------------------------------

callKind(c :/ m)
    | Private `elem` javaModifiers(c:/m)
                 = Special
--   | isIface(c) = Interface
   | otherwise  = Virtual

-- AUX------------------------------------------------------------------

litExp v            = Term(Lit(v),litType(v))[]
locAcc(x, t)        = Term(LocAcc x,t) []
locInc(x, t)        = Term(LocInc x,t) []
locDecr(x, t)       = Term(LocDecr x,t) []
locAss(x,t,e)       = Term(LocAss x,t) [e]
classAcc f          = Term(ClassAcc f,fieldType(f)) []
classAss(f, e)      = Term(ClassAss f,fieldType(f)) [e]
classInv(m,es)      = Term(ClassInv m,javaReturnType(m)) [Term(ArgList,TJVoid)es]
classCast(t,e)      = Term(Classcast t,t) [e]
fieldAcc(f, e)      = Term(FieldAcc f,fieldType(f)) [e]
fieldAss(f, r, e)   = Term(FieldAss f,fieldType(f)) [r,e]
instInv(m,k, r,es)  = Term(InstanceInv m k,javaReturnType m) [r,Term(ArgList,TJVoid)es]
qualAcc(f, t,e)     = Term(QualAcc f,t) [e]
qualAss(f, t, r, e) = Term(QualAss f,t) [r,e]
qualInv m t es      = Term(QualInvoke m,t) es

-- AUX------------------------------------------------------------------
-- TODO!!!

isInstField, isClassField :: FieldRef -> Bool
isInstField(fr) = Static `notElem` javaModifiers(fr)
isClassField(fr) = not(isInstField(fr))


isInstMeth, isClassMeth :: MethRef -> Bool
isInstMeth(mr) = Static `notElem` javaModifiers(mr)
isClassMeth(mr) = Static `elem` javaModifiers(mr)


denotesTypeName :: Exp -> Bool
denotesTypeName(e) = case e of
  Term(AccName t,_)[] -> isClassType(TJRef(t))
  _                   -> False

denotesSuper :: Exp -> Bool
denotesSuper(e) = case e of
  Term(AccName t,_)[] -> t == "super"
  _                   -> False


typeName :: Exp -> Name
typeName(Term(AccName t,_)[]) = t

refOf(TJRef r)    = r
refOf(TJArray(_)) = "Array"

isClassType :: JavaType -> Bool
isClassType(t) = case t of
  TJRef(r) -> r `inDom` pgm
  _        -> False

isClassArrType :: JavaType -> Bool
isClassArrType(t) = case t of
  TJRef(r)   -> r `inDom` pgm
  TJArray(t) -> True
  _          -> False

isArray :: JavaType -> Bool
isArray(t) = case t of
  TJArray(t) -> True
  _          -> False

arrayType :: JavaType -> JavaType
arrayType(TJArray(t)) = t
arrayType(_) = error "arrayType"

  
isInstantiableClass :: JavaClass -> Bool
isInstantiableClass(c) =
  let td = pgm(c)
  in c `inDom` pgm && isClass(td) && Abstract `notElem` javaModifiers(td)
  

visibleFields :: FieldRef -> [FieldRef]
visibleFields(fr) = map fst (visibleFields'(fr))

visibleFieldsInCtx :: (FieldRef,JavaClass) -> [FieldRef]
visibleFieldsInCtx(fr,c) =
  [ fr' | (fr',mods) <- visibleFields'(fr)
        , accessible(c,(classNm(fr'),mods)) ]

visibleFields' :: FieldRef -> [(FieldRef,[Modifier])]
visibleFields'(fr) =
  case [ javaModifiers(f)
       | f <- fields(classNm(fr)), fieldNm(f) == fieldNm(fr) ] of
    mods : _ -> [(fr,mods)]
    _ -> case super(classNm(fr)) of
          Just(s) -> [ (fr',mods) 
                     | c' <- s:implements(classNm(fr))
                     , (fr',mods) <- visibleFields'(c':/fieldNm(fr))
                     , accessible(classNm(fr),(c',mods)) ]
          Nothing -> []

uniqueField :: [FieldRef] -> Maybe FieldRef
uniqueField([fr]) = Just(fr)
uniqueField (fr) = Nothing

accessibleApplicableMethods :: (MethSig -> MethSig -> Bool) -> 
             (MethRef,JavaClass) -> [(MethRef,[Modifier])]
accessibleApplicableMethods takeIt (mr,ctxClass) = 
   visibleMethodsInCtx takeIt (mr,ctxClass)

accessibleApplicableConstructors :: (MethRef,JavaClass) -> [(MethRef,[Modifier])]
accessibleApplicableConstructors(mr,ctxClass) = 
   [ (mr',mods)
   | (mr',mods) <- methodsInSameClass compatible (mr),
     accessible(ctxClass,(classNm(mr'),mods)) ]

methodsInSameClass :: (MethSig -> MethSig -> Bool) -> MethRef 
                          -> [(MethRef,[Modifier])]
methodsInSameClass takeIt (c :/ msig) =
   [ (mref(c,m), javaModifiers(m))
   | m <- methods(c), takeIt msig (signature(m)) ]


visibleMethodsInCtx :: (MethSig -> MethSig -> Bool)
                  -> (MethRef,JavaClass) -> [(MethRef,[Modifier])]
visibleMethodsInCtx takeIt (c:/msig,ctx) =
  [ x | x@(c':/_,mods) <- visibleMethods takeIt (c:/msig)
      , accessible(ctx,(c',mods)) ]

visibleMethods :: (MethSig -> MethSig -> Bool) 
                  -> MethRef -> [(MethRef,[Modifier])]
visibleMethods takeIt (c:/msig) =
   let mths = methodsInSameClass takeIt (c :/ msig)
       sigs = [ signature(m) | (m,mods) <- mths ] in
   case super(c) of
     Nothing -> mths
     Just(s) -> mths ++ 
                [ (c':/sig,mods)
                | i <- s : expr2list(implements(c)),
                  (c':/sig,mods) <- visibleMethods takeIt (i :/ msig),
                  sig `notElem` sigs, accessible(c,(c',mods)) ]


allVisibleMethods :: JavaClass -> [(MethRef,[Modifier])]
allVisibleMethods(c) = visibleMethods takeAll (c:/undefined)
 where takeAll _ _ = True

containsAbstractMethod :: JavaClass -> Bool
containsAbstractMethod(c) =
  let methods    = allVisibleMethods(c)
      implements = mapping [ (msig,True) 
                           | ((_:/msig),mods) <- methods, 
                             Abstract `notElem` mods ]
      abstract   = [ msig | (_:/msig,mods) <- methods,
                            Abstract `elem` mods,
                            isNothing(maplookup implements msig) ]
      isNothing Nothing = True
      isNothing _       = False
  in not(null(abstract))

mostSpecificMethod :: [MethRef] -> Maybe MethRef
mostSpecificMethod([mr])= Just(mr)
mostSpecificMethod(mrs) = 
   case nub [ mr | mr <- mrs, 
              and [ mr `compatible` mr' | mr' <- mrs ] ] of
     [mr] -> Just(mr)
     _    -> Nothing
  

binds2 :: Monad m => [m(a,b)] -> m ([a],[b])
binds2 xs = do ys <- binds xs; result (unzip ys)  


instance Compatible MethSig where
  (m1,sig1) `compatible` (m2,sig2) = 
         m1 == m2 && sig1 `compatible` sig2

instance Compatible MethRef where
  (c :/ m) `compatible` (d :/ n) = (c `compatible` d ||
                                    isClass(c) && isIface(d)) &&
                                   m `compatible` n

instance Compatible a => Compatible [a] where
  as `compatible` bs = length as == length bs &&
                       and [ a `compatible` b | (a,b) <- zip as bs ]


once :: Eq a => ([a],String,a -> String) -> Checked ()
once([],_,_)     = done
once([x],_,_)    = done
once(x:xs,msg,show) 
   | x `elem` xs = sfail (printf(msg,[show x]))
   | otherwise   = once(xs,msg,show)


checkList :: ([a], a -> Bool, String, a -> String) -> Checked ()
checkList ([],_, _, _) = done
checkList (x:xs,p,msg,show)
   | p(x)      = checkList(xs,p,msg,show)
   | otherwise = sfail(printf(msg,[show(x)]))


targetLabel :: (Lab,Stm) -> Lab
targetLabel (lab,Term(LabStm l,_)[s]) = targetLabel(l,s)
targetLabel (lab,_)                   = lab
