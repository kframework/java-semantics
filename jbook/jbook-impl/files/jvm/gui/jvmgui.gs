dynamicMode :: Bool
dynamicMode = initVal "dynamicMode" False

showClass' :: Class -> ShowS
showClass'(c) = if language == 5 then showClass(c)
                else showString (snd c)

showMRef :: MRef -> ShowS
showMRef(mr) = showMRef'(mr)
 where showMRef'(c:/(mn,sig)) = showClass' c . showString "." . showString mn
                               . showString "(" . foldl (.) id (map shows sig)
                               . showString ")"

loadGUI :: (ClassPath,Class) -> Rule (Maybe ClassFile)
loadGUI (path,c) = do
   p <- locateClassfile(classPath,cNm(c))
   case p of
    Nothing -> result Nothing
    Just(p) -> load(c,p++cNm(c)++".j")


listboxWithTitle :: String -> Window -> GUI (Frame, Listbox [String])
listboxWithTitle title w = 
     do lb <- listbox ([height 6, width 16] ++ conf_box) w
        v  <- vscroll [takeFocus False,background scrollBarColor] lb
        l  <- label ([text title] ++ conf_label) w
        f  <- frame conf_frame (l ^-^ (flexible (flexible lb <|< v)))
        result (flexible f, lb)


control_frame :: Window -> GUI (Frame, [Button])
control_frame w = do 
    bs <- binds [ button (conf_button ++ 
                          [text t, anchor "w"]) w
                | t <- [ "Load", "Locate", "Step one", "Step pc", "Step call"
                       , "Run", "Break", "Reset", "Main?", "Quit" ]
                ]
    l  <- label ([text "CONTROL"] ++ conf_label) w
    f  <- frame conf_frame (l ^-^ vertical (map fillX bs))
    result (fillY f,bs)

valueBox :: [String] -> Window -> GUI (Frame, [Label])
valueBox ns w = do
    names <- binds [ label (conf_label ++ 
                     [text n, relief "sunken", anchor "w"]) w 
                   | n <- ns ]
    ls    <- binds [ label (conf_info ++
                     [relief "sunken", width 4, anchor "w"]) w 
                   | n <- ns ]
    let [f1,f2,f3,f4,f5,f6] = map fillX names
        [l1,l2,l3,l4,l5,l6] = map fillX ls
    cset l2 (width 30)
    cset l4 (width 30)
    binds [ cset l (anchor "e") | l <- [ l1,l3,l6] ]
    let left1 = f1 ^^ f3 ^^ f6
        left2 = l1 ^^ l3 ^^ l6
        left3 = f2 ^^ f4 ^^ f5
        right = l2 ^^ l4 ^^ l5
    f <- frame conf_frame $ left1 << left2 << left3 << expand (fillX right)
    result (fillX f, ls)

create_gui :: JVM () -> [JVM ()] -> GUI (Display, GUIState)
create_gui (JVM upd) cmds = do
    w <- window (conf_window ++ [title "Java Virtual Machine"])
    commandOnClose w quit
    (fopd,lopd)   <- listboxWithTitle "STACK" w
    (fheap,lheap) <- listboxWithTitle "HEAP" w
    (fregister,lregister) <- listboxWithTitle "VARIABLES" w
    (fmths,lmths) <- listboxWithTitle "METHODS" w
    (fins,lins)   <- listboxWithTitle "INSTRUCTIONS" w
    (fcli,lcli)   <- listboxWithTitle "CLASS-INFO" w
    (fr,[lpc, lswitch, lframe, lphase, lbreak, lsteps]) 
                  <- valueBox [ "pc:", "switch:", "stacks:"
                              ,  "phase:", "break:","steps:"] w
    (fctrl,[ bLoad, bWhere, bStep1, bStepl, bStepo, bRun
           , bBreak, bReset, bMain, bQuit])
                  <- control_frame w
    pack $
      flexible (fctrl <+< flexible ((fheap <*+< fopd) ^*+^ (fcli <*+< fregister)))
      ^^ fillX fr
      ^^ flexible (fins <*+< fmths)
    let display = ( ( bLoad, bWhere, bStep1, bStepl, bStepo
                    , bRun, bBreak, bReset, bMain, bQuit
                    )
                  , (lopd, lheap, lregister, lmths, lins, lcli)
                  , (lpc, lframe, lswitch, lphase, lsteps)
                  , (lbreak,w)
                  )
    listOfMethods <- newGVar []
    meth          <- newGVar undefined
    let guistate = ( listOfMethods, meth )
    let jvmExecute (JVM f) = catch_gui w (f (display, guistate)) 
                                       (void (upd (display, guistate)))
    let [ cLoad, cWhere, cStep1, cStepl, cStepo, 
          cRun, cBreak, cReset, cMain, cQuit ] = map jvmExecute cmds
    cset bLoad    (command cLoad)
    cset bWhere   (command cWhere)
    cset bStep1   (command cStep1)
    cset bStepl   (command cStepl)
    cset bStepo   (command cStepo)
    cset bRun     (command cRun)
    cset bBreak   (command cBreak)
    cset bReset   (command cReset)
    cset bMain    (command cMain)
    cset bQuit    (command cQuit)
    cset w (on (key "space") cStep1)
    result (display, guistate)

insertCFile :: ClassFile -> JVM ()
insertCFile (cf) = do
     let cn   = cNm(cf)
         c    = (sysLd, cn)
     io $ fire1 (do
      if dynamicMode then
        create r do
          cEnv (c)       := cf
          cReferences(c) := ctxReferences c cf
          heap(r)   := JVMObject(cclass, {})
          cOf(r)    := (sysLd, cn)
          ldEnv(c)  := r
          classState(c) := Loaded
       else do
          cEnv (c)       := cf
          cReferences(c) := ctxReferences c cf
          classState(c) := Loaded)
     io $ fire1 (
       forall f <-: staticFields(c) do
         globals(c :/ f) := asmDefault)
     updateGUI True

loadClassfile(c) = do
  c `notInDom` cEnv =>> do
     cf <- io $ rule2io' (loadGUI(classPath,c))
     if cf == Nothing then
       mraise ("cannot locate class (or invalid class) " ++ cNm(c))
      else if cNm(just(cf)) /= cNm(c) then
       mraise ("expected name " ++ cNm(c) ++ " but got " ++
               cNm(just(cf)))
      else insertCFile (just(cf))

loadReferences' :: JVM ()
loadReferences' = do
  done
  case [ c | (c,s) <- assocs classState, s == Loaded ] of
    c : _ -> do
         let cs = references(c)
         seqs [ loadClassfile c | c <-: cs ]
         io $ fire1 (
           if classState(c) < SupersLoaded then do
              classState(c) := SupersLoaded
            else done)
         loadReferences'
    _ -> changeClassFiles

changeClassFiles :: JVM ()
changeClassFiles = do
   done
   case [ c | (c,s) <- assocs classState, s == SupersLoaded ] of
     c : _ -> do io $ fire1 (changeClassFile(c))
                 changeClassFiles
     _ -> done
           

changeClassFile :: Class -> Rule ()
changeClassFile(c) = do
  chooseIfNone c' <-: {just(super(c))} `union` implements(c), 
         classState(c') < Referenced do
    changeClassFile(c')
   ifnone do
    cEnv(c) := insertSupSigs(c,cEnv(c))
    Rule (fire1 skip)
    if not(isDiligent) then do
        case constraintViolation(c) of
          (b,s) -> if not(isTrustful) && b then do
                     stdout := violationMsg(cNm(c)) ++ newline ++ s
                     classState(c) := Unusable
                    else do
                     classState(c) := Linked
      else
       classState(c) := Referenced


guiLoadFile :: JVM ()
guiLoadFile = do 
   x <- gui jasminFileOpenDialogue
   case x of
     Nothing   -> done
     Just name -> do cf <- err2jvm (parse' (sysLd,name,openfile name))
                     p <- result (getFilepath name)
                     if p `notElem` classPath then
                       io $ fire1 (do classPath := classPath `union` {p})
                      else done
                     let c = (sysLd,cNm(cf))
                     insertCFile (cf)
                     if language < 5 then do
                       loadReferences'
                      else done
                     updateGUI(True)
                     if cNm(mainClass) == ""
                       then guiChooseMain True
                       else done

guiShowCurrentPosition :: JVM ()
guiShowCurrentPosition = do
   lmths <- map (zip [0..]) guiListOfMethods
   gmths <- guiMths
   case filter ((==gui_meth) . snd) lmths of
     [(i,_)] -> do gui $ setSelection gmths [i]
                   gui $ tk_toTcl gmths ["activate",show i]
                   gui $ tk_toTcl gmths ["see",show i]
                   gui $ focus gmths
                   displayInstructions gmths
     _       -> mraise ("cannot find method " ++ cNm gui_meth 
                       ++ "." ++ mNm gui_meth)

guiStep1 :: JVM ()
guiStep1 = do
   io $ fire1 executeMachine
   updateGUIInfoFields


guiStepl :: JVM ()
guiStepl = do
   pc'   <- io $ strictEval gui_pc
   meth' <- io $ strictEval gui_meth
   let cond = gui_pc/=pc' || gui_meth/=meth'
   io $ fireUntil cond executeMachine
   updateGUIInfoFields

guiStepo :: JVM ()
guiStepo = do
   pc'   <- io $ strictEval gui_pc
   lf    <- map length $ io (strictEval stack)
   meth' <- io $ strictEval gui_meth
   let cond = (gui_pc/=pc' && length stack <= lf
               && gui_meth == meth')
              || length stack < lf
   io $ fireUntil cond executeMachine
   updateGUIInfoFields

runDelay :: AsmVar Int
runDelay = initVal "runDelay" 400

breakpoint :: AsmVar (Maybe (Nat,MRef))
breakpoint = initVal "breakpoint" Nothing

instance AsmTerm (Maybe (Nat, MRef))

guiRun :: JVM ()
guiRun = do
   t <- gui $ timer [initValue runDelay]
   w <- gui $ window (conf_window ++ [title "Run"])
   s <- gui $ hscale [ scaleRange (0,3000)
                     , tickInterval 1000
                     , text "delay in ms"
                     , height 200
                     , initValue runDelay
                     ] w
   gui $ cset s (command (do v <- getValue s
                             liftIO $ fire1(runDelay := v)
                             setValue t v))
   bc <- gui $ button (conf_button ++ [text "cancel"]) w
   bb <- gui $ button (conf_button ++ [text "clear"]) w
   be <- gui $ button (conf_button ++ [text "finish"]) w
   bs <- gui $ button (conf_button ++ [text "stop"]) w
   let stop  = do cset t (active False)
                  cset bs (text "start")
                  cset bs (command start)
       start = do cset bs (text "stop")
                  cset bs (command stop)
                  cset t (active True)
   clearbp <- jvm2gui done $ do
                io (fire1(breakpoint := Nothing))
                updateGUIBreakpoint
   gui $ cset bb (command clearbp)
   gui $ cset bs (command stop)
   gui $ cset bc (command (do cset t (active False)
                              closeWindow w))
   gotoEnd <- jvm2gui done (guiGotoBreak w t stop [bc,bb,be,bs])
   gui $ cset be (command gotoEnd)
   gui $ commandDestroy w (invoke bc)
   gui $ pack (flexible (flexible s ^^ bc << bb << be << bs))
   act <- jvm2gui done (guiRun' w t stop)
   gui $ cset t (command act)

guiGotoBreak :: Window -> Timer -> GUI () -> [Button] -> JVM ()
guiGotoBreak w t stop bs = jvmExec $
  do gui $ stop
     binds [  gui $ cset b (active False)  | b <- bs ]
     gui $ updateTask
     io $ fireUntil (Just (f(gui_pc,gui_meth)) == map f breakpoint) 
               executeMachine
     binds [  gui $ cset b (active True)  | b <- bs ]
     updateGUIInfoFields
     gui $ closeWindow w
 where f (pc, ((_, cn) :/ x)) = (pc,((sysLd,cn) :/ x))

guiRun' :: Window -> Timer -> GUI () -> JVM ()
guiRun' w t stop = do
   do b <- io $ fire1_ (rule2io executeMachine)
      if b then do updateGUIInfoFields
                   if (Just (gui_pc,gui_meth) == breakpoint)
                    then gui $ stop
                    else done
           else do gui $ cset t (active False)
                   gui $ closeWindow w

guiBreak :: JVM ()
guiBreak = do
   ginsn <- guiInsn
   is    <- gui $ getSelection ginsn
   case is of
    [i] -> do mth <- guiGetActualMethod
              io $ fire1(breakpoint := Just (i,mth))
              updateGUIBreakpoint
    _   -> mraise "no instruction selected"

guiReset :: JVM ()
guiReset = do
   io $ fire1(do steps        := 0
                 pc           := 0
                 opd          := []
                 reg          := {}
                 meth         := (object :/ ("<entrypoint>",[]))
                 mainClass    := (sysLd,"")
                 classPath    := {"predefined.jvm/"}
                 stack        := []
                 switch       := Noswitch
                 breakpoint   := Nothing
                 verifyMeths  := []
                 halt         := False
                 cEnv(object) := snd (javaLangObject([]))
                 forall r <-: dom(initState) do
                   initState(r) := asmDefault
                 forall c <-: dom(ldEnv) do
                   if basicPredefinedClass(c) then done
                     else ldEnv(c) := asmDefault
                 forall r <-: dom(heap) do
                   if r /= sysLd then do
                      if dynamicMode && r `inDom` cOf &&
                         basicPredefinedClass(cOf(r)) then done
                       else do
                        heap(r) := asmDefault
                        cOf(r)  := asmDefault
                    else done
                 forall x <-: dom(changed) do
                   changed(x) := asmDefault
                 forall x <-: dom(visited) do
                   visited(x) := asmDefault
                 forall s <-: dom(enterJsr) do
                   enterJsr(s) := asmDefault
                 forall s <-: dom(leaveJsr) do
                   leaveJsr(s) := asmDefault
                 forall c <-: dom(cEnv) do
                   if basicPredefinedClass(c) then
                      if basicInitializedClass(c) then do
                        classState(c) := Initialized
                        forall f <-: staticFields(c) do
                         globals(c:/f) := dflt(javaFieldType(c:/f))
                      else do
                        classState(c) := Loaded
                        forall f <-: staticFields(c) do
                          globals(c :/ f) := asmDefault
                    else do 
                      cEnv(c)        := asmDefault
                      cReferences(c) := asmDefault
                      classState(c)  := asmDefault
                      forall f <-: staticFields(c) do
                       globals(c :/ f) := asmDefault
            )
   io (primAsmSetInteger (1 + maximum ({1} `union` dom(heap))))
   updateGUI True
   updateGUIBreakpoint

guiChooseMain :: Bool -> JVM ()
guiChooseMain silent = do 
    mths  <- guiListOfMethods
    guiChooseMainOfList silent mths

guiChooseMainOfList :: Bool -> [MRef] -> JVM ()
guiChooseMainOfList silent mths = do
    vmref <- gui $ newGVar ((sysLd,"") :/ ("",[]))
    let f = filter (\(_:/ms) -> 
              snd (ms) == [TJArray(tjString)])
    case f mths of
      []  -> mraise "cannot find any suitable main-method"
      [m] -> do if silent
                  then done
                  else gui $ 
                    showInfo ("using method '" ++ mNm m ++ 
                              "' of class " ++ cNm m)
                gui $ writeGVar vmref m
                setClass vmref
      ms  -> do w <- gui $ window (conf_window ++ [title "choose main method"])
                b <- gui $ button (conf_button ++ [text "Cancel", 
                                   command (closeWindow w)]) w
                act <- jvm2gui done (setClass vmref)
                l <- gui $ listbox [initValue (map print ms)] w
                s <- gui $ vscroll [takeFocus False,
                                    background scrollBarColor] l
                gui $ cset l (on (click 1) 
                      (do [i] <- getSelection l
                          closeWindow w
                          writeGVar vmref (ms!!i)
                          act))
                gui $ pack ((l << fillY s) ^^ b)
  where print mref = cNm(mref) ++ "." ++ mNm(mref)
        setClass :: Var MRef -> JVM ()
        setClass vmref = do
              (c:/m) <- gui $ readGVar vmref
              io $ fire1(do mainClass := c
                            let (cn',o) = javaLangObject (startMain (c:/m))
                            cEnv(sysLd,cn') := o)
              guiShowCurrentPosition
  
create_select_machine :: JVM () -> JVM () -> JVM ()
    -> (Display, GUIState) -> GUI ()
create_select_machine (JVM upd) (JVM changeToDynamicMode) 
                                (JVM resetDynamicMode)
    (d,s) = do
  w <- window (conf_window ++ [title "Exec Machine"])
  execI <- radiobutton (conf_button ++ [text "JVM I", anchor "w", command (lact 0)]) w
  execC <- radiobutton (conf_button ++ [text "JVM C", anchor "w", command (lact 1)]) w
  execO <- radiobutton (conf_button ++ [text "JVM O", anchor "w", command (lact 2)]) w
  execE <- radiobutton (conf_button ++ [text "JVM E", anchor "w", command (lact 3)]) w
  execN <- radiobutton (conf_button ++ [text "JVM N", anchor "w", command (lact 4)]) w
  execD <- radiobutton (conf_button ++ [text "JVM D", anchor "w", command lact5]) w
  radio [initValue language] [execI, execC, execO, execE, execN, execD]
  pack (execI ^*-^ execC ^*-^ execO ^*-^ execE ^*-^ execN ^*-^ execD)
 where lact i   = do liftIO (fire1 (do language    := i
                                       halt        := False))
                     void (resetDynamicMode (d,s))
                     void (upd (d,s))
       lact5 = do liftIO (fire1 (do language := 5
                                    halt     := False))
                  void (changeToDynamicMode (d,s))
                  void (upd (d,s))

changeToDynamicMode :: JVM ()
changeToDynamicMode = do
  done
  if dynamicMode then done
   else do
    guiReset
    io $ fire1 (do
       dynamicMode := True
       initializeDynamicLoading(map f loadedClasses))
    io (primAsmSetInteger (1 + maximum ({1} `union` dom(heap))))
    updateGUI True
 where f (ld,(cn,_)) = (ld,cn)

resetDynamicMode :: JVM ()
resetDynamicMode = do
  done
  if dynamicMode then do
    io $ fire1 (dynamicMode := False)
    guiReset
    updateGUI True
   else
    done
    

jvm_start :: JVM a -> IO ()
jvm_start act = start $ do
       (d,s) <- create_gui (updateGUI(False)) [ jvmExec guiLoadFile , guiShowCurrentPosition
                  , guiStep1, guiStepl, guiStepo, guiRun
                  , guiBreak, guiReset 
                  , guiChooseMain False, gui quit ]
       g (d,s)
       create_select_machine (updateGUI(True)) 
                             changeToDynamicMode 
                             resetDynamicMode
                             (d,s)
    where JVM g = do initGUI
                     updateGUI(False)
                     updateGUIBreakpoint
                     act

initGUI :: JVM ()
initGUI = do
   gmths <- guiMths
   act   <- jvm2gui done $ displayInstructions gmths
   gui $ cset gmths (on (click 1) act)
   done

displayInstructions :: Listbox [String] -> JVM ()
displayInstructions gmths = do
    is <- gui $ getSelection gmths
    case is of
     [i] -> do gui $ tk_toTcl gmths ["activate",show i]
               ginsn <- guiInsn
               lmths <- guiListOfMethods
               let mref = lmths!!i
               guiSetActualMethod mref
               gui $ setValue ginsn 
                       (map (showWithNumber "" ": ")
                         (zip [0..] $ [ showInstr(i) "" | i <- code(mref)]))
               if mref==gui_meth && gui_pc >= 0
                 then do gui $ setSelection ginsn [gui_pc]
                         gui $ tk_toTcl ginsn ["see",show gui_pc]
                 else gui $ setSelection ginsn []
     _   -> done

all_methods :: [MRef]
all_methods = [ ((ld,cn) :/ m) 
              | ((ld,cn),cf) <- assocs (cEnv :: AsmVar ((Ld, CNm) -> ClassFile))
              , (m,_) <-: cMs(cf)
              ]


updateGUIMethods :: Bool -> JVM ()
updateGUIMethods(force) = do
    gmths <- guiMths
    mths <- io $ strictEval all_methods
    lmths <- guiListOfMethods
    if force || lmths /= mths
      then do guiSetListOfMethods mths
              gui $ setValue gmths (map printMth mths)
      else done
 where printMth mref = showMRef mref ""



updateGUIHeap :: JVM ()
updateGUIHeap = do
   gheap <- guiHeap
   let f ((r,String(s)) : hs)          
              = (printRef(r) . showString "String = " .
                 shows s) "" :
                f hs
       f ((r,Array(ts,vs)) : hs)       
              = (printRef(r) . shows (TJArray ts)) "" :
                f2 0 vs hs
       f ((r,JVMObject(c,fields)) : hs) 
              = (printRef(r) . printName(r,c)) "" :
                printFields(expr2list(fields),hs)
       f []   = []
       f2 i (v:vs) hs   = (showString  "  " . shows i .
                           showString ": " . shows v) "" :
                          f2 (i+1) vs hs
       f2 _ []     hs   = f hs
       printFields((f,v):fields,hs)
                          = (showString "  " . showFRef(f) .
                             showString " = " . shows v) "" :
                            printFields(fields,hs)
       printFields([],hs) = f hs
       printName(r,c) | c==cclass && r `inDom` cOf
                        = showClass' (c) . showString " of " .
                          showClass' (cOf(r))
                      | otherwise
                        = showClass' (c)
       printRef(r) = shows r . showString " =  "
   gui $ setValue gheap (f (assocs(heap)))

updateGUIOpd :: JVM ()
updateGUIOpd = do
    gopd <- guiOpd
    if null(verifyMeths)
     then gui $ setValue gopd (f ((pc,{},opd,meth):reverse stack))
     else if emptyDom(changed)
          then  gui $ setValue gopd []
          else  gui $ setValue gopd (g (opdV(gui_pc)))
  where f ((_,_,opd,meth):fs) 
              = (showString (cNm(meth)) . showString "." . 
                 showString (mNm(meth))) "" :
                f2 0 (reverse opd) fs
        f []  = []
        f2 i (o:os) fs = showWithNumber "  " ": " (i,showWord' o) :
                         f2 (i+1) os fs
        f2 _ []     fs = f fs
        g ts = map (showWithNumber "  " ": ") (zip [0..] 
                      [ shows t "" | t <- reverse ts])

updateGUIRegister :: JVM ()
updateGUIRegister = do
    gregister <- guiRegisters
    if null(verifyMeths)
     then gui $ setValue gregister (f ((pc,reg,[],meth):reverse stack))
     else if emptyDom(changed)
          then gui $ setValue gregister []
          else gui $ setValue gregister (h (expr2list(regV(gui_pc))))
  where f ((_,reg,_,meth):fs) 
                 = (showString(cNm meth) . showString  "." .
                    showString (mNm meth)) "" :
                   g (expr2list(reg)) fs
        f []     = []
        g ((i,v):rs) fs = showWithNumber "  " " = " (i,showWord' v) : 
                          g rs fs
        g [] fs         = f fs
        h ts = map (showWithNumber "  " " = ")
               [ (i, shows t "") | (i,t) <- ts ]
  

updateGUIClassInfo :: JVM ()
updateGUIClassInfo = do
   gcli <- guiClassInfo
   let f ((c,state):cs) []
            = (showClass' c . showString ": " . shows state) "" :
              f cs []
       f ((c,state):cs) fields
            = (showClass' c . showString ": " . shows state) "" :
              f2 c cs fields
       f [] _ = []
       showVal [v] = showWord v
       showVal v   = shows (map showWord' v)
       f2 c cs fields@((c' :/ fn,val):fs)
            | c == c'   = (showString "  " . showString fn .
                           showString " = " . showVal val) "" :
                          f2 c cs fs
            | otherwise = f cs fields
       f2 c cs []       = f cs []
   gui $ setValue gcli (f (assocs(classState)) (assocs(globals)))

updateGUIInfoFields :: JVM ()
updateGUIInfoFields = do
    updateGUIOpd
    updateGUIHeap
    updateGUIRegister
    updateGUIClassInfo
    (lpc, lframes, lswitch, lphase, lsteps) <- guiValues
    gui $ cset lpc     (text (show (max 0 gui_pc) ++ " "))
    gui $ cset lframes (text (show (length stack + 1) ++ " "))
    gui $ cset lswitch (text (" " ++ showSwitch switch "" ++ " "))
    gui $ cset lphase (text (
       case (verifyMeths, emptyDom(changed)) of
         ([],_)   -> " executing"
         (_,True) -> " preparing verification"
         _        -> " bytecode verification"
       ))
    gui $ cset lsteps  (text (show steps ++ " "))
    if newClassLoaded 
     then do updateGUIMethods(True)
             io $ fire1(newClassLoaded := False)
     else done
    guiShowCurrentPosition
    gui $ updateTask

updateGUIBreakpoint :: JVM ()
updateGUIBreakpoint = do
    lbp <- guiBreakpoint
    case breakpoint of
     Nothing      -> gui $ cset lbp (text "")
     Just (pc,mr) -> gui $ cset lbp (text (cNm mr ++ "." ++ mNm mr 
                             ++ ":" ++ show pc ++ " = "
                             ++ showInstr (code(mr)!!pc) ""))


showWithNumber :: String -> String -> (Int,String) -> String
showWithNumber str1 str2 (i,e) = str1 ++ show i ++ str2 ++ e

updateGUI :: Bool -> JVM ()
updateGUI(force) = do updateGUIMethods(force)
                      updateGUIInfoFields

main :: IO ()
main = do
    primAsmSetInteger (1 + maximum ({1} `union` dom(heap)))
    jvm_start done

guiRule :: IO () -> IO ()
guiRule act = start $ do
                liftIO act
                putStrLn "finished"
                quit

executeMachine :: Rule ()
executeMachine = do
   execMachine
   recordChangeOfPc

recordChangeOfPc = do
   if pc/=pcOld || meth /= methOld 
    then do steps   := steps + 1
            pcOld   := pc
            methOld := meth
    else done


