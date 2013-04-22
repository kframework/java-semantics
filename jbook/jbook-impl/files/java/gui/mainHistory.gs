
main :: IO ()
main = do
  primAsmSetHistory True
  primAsmSetInteger (1 + maximum ({1} `union` dom(heap)))
  java_start done


java_start :: JavaGUI a -> IO ()
java_start act = start $ do
   backSteps <- newGVar 0
   liftIO moveToCurrentState
   gui <- create_gui updateGUI [ javaExec (guiLoadFile backSteps),
                                 guiShowCurrentPosition,
                                 guiStep backSteps,
                                 guiStepCall backSteps,
                                 guiRun backSteps,
                                 guiBreak backSteps,
                                 guiReset backSteps,
                                 guiChooseMain False backSteps,
                                 guiShowType,
                                 guiBack backSteps,
                                 gui quit ]
   g gui
 where JAVA g = do initGUI
                   updateGUI
                   updateGUIBreakpoint
                   act


control_frame :: Window -> GUI (Frame, [Button])
control_frame w = do 
  bs <- binds [ button (conf_button ++ [text t, anchor "w"]) w
              | t <- [ "Load", "Locate", "Step", "Step call",
                       "Run",  "Break",  "Reset", "Main?", "Show type",
                       "Back", "Quit" ]
              ]
  l <- label ([text "CONTROL"] ++ conf_label) w
  f <- frame conf_frame (l ^-^ vertical (map fillX bs))
  result (fillY f, bs)

valueBox :: [String] -> Window -> GUI (Frame, [Label])
valueBox ns w = do
  names <- binds [ label (conf_label ++
                         [ text n, relief "sunken", anchor "w"]) w
                 | n <- ns ]
  ls <- binds [ label (conf_info ++ [relief "sunken",
                       width 4, anchor "w"]) w
              | n <- ns ]
  dummy <- label [] w
  let [f1,f2,f3,f4] = map fillX names
      [l1,l2,l3,l4] = map fillX ls
  let left1 = f1 ^^ f2
      left2 = l1 ^^ l2
      left3 = flexible (flexible ((f3 ^^ f4) << (flexible (l3 ^*+^ l4))))
  f <- frame conf_frame $ (left1 << left2 << left3)
  result (fillX f, ls)


create_gui :: JavaGUI () -> [JavaGUI ()] -> GUI (Display, GUIState)
create_gui (JAVA upd) cmds = do
   w <- window (conf_window ++ [title "Java"])
   commandOnClose w quit
   (fheap, lheap)           <- listboxWithTitle "HEAP" w
   (fmethods, lmethods)     <- listboxWithTitle "METHODS" w
   (fclassInfo, lclassInfo) <- listboxWithTitle "CLASS-INFO" w
   (fstack, lstack)         <- listboxWithTitle "FRAME-STACK" w
   (fctrl, [ bLoad,  bWhere, bStep, bStepCall, bRun,
             bBreak, bReset, bMain, bShowType,bBack,bQuit]) <- control_frame w
   (fr, [ lFrames, lSteps, lBreak, lThread]) 
              <- valueBox ["frames:","steps:", "break:","thread:"] w
   (meditor,fmeditor)       <- markEditor w
   pack $
     flexible (fillX (fctrl <+< expand (fillY fmethods << flexible fmeditor)))
     ^^ fillX fr
     ^^ flexible (flexible fheap <*+< flexible fstack <*+< flexible fclassInfo)
   let display = ( (bLoad, bWhere, bStep, bStepCall, bRun,
                    bBreak, bReset, bMain, bQuit
                   )
                 , ( lheap, lmethods, lclassInfo, lstack, meditor, w )
                 , ( lSteps, lFrames, lBreak, lThread )
                 )
   listOfMethods <- newGVar []
   meth          <- newGVar undefined
   let guistate = ( listOfMethods, meth )
   let javaExecute (JAVA f) = catch_gui w (f (display, guistate))
                                          (void (upd (display, guistate)))
   let [ cLoad, cWhere, cStep, cStepCall,
         cRun, cBreak, cReset, cMain, cShowType, 
         cBack, cQuit ] = map javaExecute cmds
   cset bLoad     (command cLoad)
   cset bWhere    (command cWhere)
   cset bStep     (command cStep)
   cset bStepCall (command cStepCall)
   cset bRun      (command cRun)
   cset bBreak    (command cBreak)
   cset bReset    (command cReset)
   cset bMain     (command cMain)
   cset bQuit     (command cQuit)
   cset bShowType (command cShowType)
   cset bBack     (command cBack)
   cset w (on (key "space") cStep)
   result (display, guistate)


markEditor :: Window -> GUI (PrettyEdit (JavaClass,MemDec),Frame) 
markEditor w =
  do e <- prettyEdit ([height 15, background backcolor, 
                       markColor markcolorEditor])
                     w
     f <- frame [] e
     result (e,f)


listboxWithTitle :: String -> Window -> GUI (Frame, Listbox [String])
listboxWithTitle title w =
     do lb <- listbox ([height 6, width 16] ++ conf_box) w
        v  <- vscroll [takeFocus False,background scrollBarColor] lb
        l  <- label ([text title] ++ conf_label) w
        f  <- frame conf_frame (l ^-^ (flexible (flexible lb <|< v)))
        result (flexible f, lb)

 

initGUI :: JavaGUI ()
initGUI = do
  gmths <- guiMths
  updateGUIMethods
  act <- java2gui done $ displayMethod
  gui $ cset gmths (on (click 1) act)
  guiShowCurrentPosition

displayMethod :: JavaGUI ()
displayMethod = do
  gmths <- guiMths
  is <- gui $ getSelection gmths
  case is of
   [i] -> do gui $ tk_toTcl gmths ["activate", show i]
             lmths  <- guiListOfMethods
             editor <- guiEditor
             ieditor <- getInputEditor
             let (c :/ m) = lmths!!i
             guiSetActualMethod (c :/ m)
             if (c :/ m) == meth then do
               let MethDec(ms,rt,nm,args,_,throws,b) = methDec(members(c),m)
               gui $ setValue editor (c,MethDec(ms,rt,nm,args,restbody,throws,b))
               gui $ setMarkedTags editor (0:pos)
              else
              gui $ setValue editor (c,methDec(members(c),m))
   _ -> do ieditor <- getInputEditor
           clearPrettyWindow

clearPrettyWindow :: JavaGUI ()
clearPrettyWindow = do
  editor  <- guiEditor
  gui $ cset editor (readOnly False)
  gui $ setValue (prettyEditW editor) ""
  gui $ cset editor (readOnly True)

outputMethod :: MethRef -> JavaGUI ()
outputMethod(mref) = do
   ieditor <- getInputEditor
   gui $ cset ieditor (readOnly False)
   gui $ setValue ieditor (layout 80 100 
              (pretty (methDec(members(classNm(mref)),signature(mref)))))
   gui $ cset ieditor (readOnly True)


updateGUI :: JavaGUI ()
updateGUI = do
   updateGUIClassInfo
   updateGUIHeap
   updateGUIStack
   updateGUIFields
   guiShowCurrentPosition
   gui updateTask


updateGUIFields :: JavaGUI ()
updateGUIFields = do
   lsteps  <- guiSteps
   lframes <- guiFrames
   lthread <- guiThread
   gui $ cset lsteps  (text (show steps))
   gui $ cset lframes (text (show (length(frames))))
   gui $ cset lthread (text ("heap(" ++ show thread ++ ")"))

updateGUIBreakpoint :: JavaGUI ()
updateGUIBreakpoint = do
    lbp <- guiBreakpoint
    case breakpoint of
     Nothing       -> gui $ cset lbp (text "")
     Just (pos,mr) -> gui $ cset lbp (text (showJavaMRef(mr)
                             ++ ":" ++ map f (take 40 (showPretty(
                                        subterm(body(mr),pos))))))
 where f '\n' = ' '
       f x    = x
 
updateGUIMethods :: JavaGUI ()
updateGUIMethods = do
  gmths <- guiMths
  mths <- io $ strictEval all_methods
  gui $ setValue gmths (map printMth mths)
  guiSetListOfMethods (map mref mths)
 where printMth (c,m) = c ++ "." ++ show m

updateGUIClassInfo :: JavaGUI ()
updateGUIClassInfo = do
  gfields <- guiClassInfo
  gui $ setValue gfields (merge(assocs(globals), assocs(classState)))
 where merge([],[])           = []
       merge([],(c,state):cs) = (c ++ ": " ++ show(state)) : merge([],cs)
       merge(a@((d :/ f),v):as,[]) = [("  " ++ f ++ " = " ++ show v)]
       merge(a@((d :/ f),v):as,x@((c,state):cs))
                      | d>=c = (c ++ ": " ++ show (state))
                               : merge(a:as,cs)
                      | otherwise = ("  " ++ f ++ " = " ++ show v)
                                    : merge(as,x)

updateGUIHeap :: JavaGUI ()
updateGUIHeap = do
  gheap <- guiHeap
  gui $ setValue gheap (f (assocs(heap)))
 where f ((r,HeapArray(t,vs)):hs)
               = ( shows r . showString " = " . shows t . 
                     showString "[]") "" :
                 f2 0 vs hs
       f ((r,HeapString(s)):hs)
               = (shows r . showString " = " . showString "String = \"" .
                    showString s . showString "\"") "" :
                 f hs
       f ((r,HeapObject(c,fields)):hs)
               = (shows r . showString " = " . showString c) "" :
                 f3 (expr2list(fields)) hs
       f []    = []
       f2 i (v:vs) hs   = (showString  "  " . shows i .
                           showString ": " . shows v) "" :
                          f2 (i+1) vs hs
       f2 _ []     hs   = f hs
       f3 (f:fs) hs     = printField f : f3 fs hs
       f3 []     hs     = f hs
       printField(f,v)  = ( showString "  " . showsJavaFRef f
                          . showString " = " . shows v) ""

updateGUIStack :: JavaGUI ()
updateGUIStack = do
  gstack <- guiFramestack
  let f ((mr,term,pos,locals):fs) = showJavaMRef mr : f2 (expr2list(locals)) fs
      f []                        = []
      f2 ((l,v):ls) fs = (showString "  " . showString l .
                          showString " = " . shows v) "" :
                         f2 ls fs
      f2 [] fs         = f fs
  gui $ setValue gstack (f ((meth,restbody,pos,locals): frames))

guiLoadFile :: GVar Int -> JavaGUI ()
guiLoadFile backSteps = do
  x <- gui javaFileOpenDialogue
  case x of
   Nothing -> done
   Just(filename) -> do 
      cf  <- err2java (parse(filename))
      insertCFile cf backSteps
      updateGUI
      updateGUIMethods
      checkLoadedClasses
      updateGUI
      if mainClass == ""
       then guiChooseMain True backSteps
       else done
      displayMethod
      io $ clearHistory
      gui $ writeGVar backSteps 0

guiShowCurrentPosition :: JavaGUI ()
guiShowCurrentPosition = do
   lmths <- map (zip [0..]) guiListOfMethods
   gmths <- guiMths
   case filter ((==meth) . snd) lmths of
     [(i,_)] -> do gui $ setSelection gmths [i]
                   gui $ tk_toTcl gmths ["activate",show i]
                   gui $ tk_toTcl gmths ["see",show i]
                   gui $ focus gmths
                   displayMethod
     _       -> mraise ("cannot find main-method " ++ classNm(meth)
                       ++ "." ++ methNm(meth))

guiStep :: GVar Int -> JavaGUI ()
guiStep backSteps = do
   io $ fire1 execMachine
   gui $ writeGVar backSteps 0
   updateGUI

guiStepCall :: GVar Int -> JavaGUI ()
guiStepCall backSteps = do
  l     <- io $ strictEval (length(frames))
  pos'  <- io $ strictEval pos
  meth' <- io $ strictEval meth
  let lpos = length(pos')
      cond = (take lpos pos /= pos' &&
              length(frames) <= l &&
              meth == meth') ||
             (length(frames) < l)
  io $ fireUntil cond execMachine
  gui $ writeGVar backSteps 0
  updateGUI

runDelay :: AsmVar Int
runDelay = initVal "runDelay" 400

breakpoint :: AsmVar (Maybe ([Nat],MethRef))
breakpoint = initVal "breakpoint" Nothing

steps :: AsmVar Int
steps = initVal "steps" 0

posOld :: AsmVar [Int]
posOld = initVal "posOld" []

methOld :: AsmVar MethRef
methOld = initVal "methOld" ("" :/ ("",[]))

instance AsmTerm (Maybe([Nat],MethRef))


guiRun :: GVar Int -> JavaGUI ()
guiRun backSteps = do
   editor <- guiEditor
   gui $ generateClickCommands editor False
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
                             writeGVar backSteps 0
                             setValue t v))
   bc <- gui $ button (conf_button ++ [text "cancel"]) w
   bb <- gui $ button (conf_button ++ [text "clear" ]) w
   be <- gui $ button (conf_button ++ [text "finish"]) w
   bs <- gui $ button (conf_button ++ [text "stop"]) w
   updGUI <- java2gui done updateGUI
   let stop  = do cset t (active False)
                  cset bs (text "start")
                  cset bs (command start)
                  generateClickCommands editor True
                  updGUI
       start = do generateClickCommands editor False
                  cset bs (text "stop")
                  cset bs (command stop)
                  cset t (active True)
   clearbp <- java2gui done $ do
                io (fire1(breakpoint := Nothing))
                gui $ writeGVar backSteps 0
                updateGUIBreakpoint
   gui $ cset bb (command clearbp)
   gui $ cset bs (command stop)
   gui $ cset bc (command (do cset t (active False)
                              generateClickCommands editor True
                              updGUI
                              closeWindow w))
   gotoEnd <- java2gui done (guiGotoBreak backSteps w t stop [bc,bb,be,bs])
   gui $ cset be (command gotoEnd)
   gui $ commandDestroy w (invoke bc)
   gui $ pack (flexible (flexible s ^^ bc << bb << be << bs))
   act <- java2gui done (guiRun' backSteps w t stop)
   gui $ cset t (command act)



guiGotoBreak :: GVar Int -> Window -> Timer -> GUI () -> [Button] -> JavaGUI ()
guiGotoBreak backSteps w t stop bs = javaExec $
  do gui $ stop
     binds [  gui $ cset b (active False)  | b <- bs ]
     gui $ updateTask
     io $ fireUntil (Just (pos,meth) == breakpoint)
               execMachine
     gui $ writeGVar backSteps 0
     binds [  gui $ cset b (active True)  | b <- bs ]
     updateGUI
     gui $ closeWindow w

guiRun' :: GVar Int -> Window -> Timer -> GUI () -> JavaGUI ()
guiRun' backSteps w t stop = do
   do b <- io $ fire1_ (rule2io execMachine)
      gui $ writeGVar backSteps 0
      if b then do updateGUI
                   if (Just (pos,meth) == breakpoint)
                    then gui $ stop
                    else done
           else do gui $ cset t (active False)
                   editor <- guiEditor
                   gui $ generateClickCommands editor True
                   updateGUI
                   gui $ closeWindow w

guiBreak :: GVar Int -> JavaGUI ()
guiBreak backSteps = do
   editor <- guiEditor
   is    <- gui $ getMarkedParts editor
   case is of
     pos':_ -> case pos' of
                0:pos -> do mth <- guiGetActualMethod
                            io $ fire1(breakpoint := Just (pos,mth))
                            gui $ writeGVar backSteps 0
                            updateGUIBreakpoint
                _   -> mraise "no phrase selected"
     _   -> mraise "multiple terms are selected"

guiShowType :: JavaGUI ()
guiShowType = do
   editor <- guiEditor
   is    <- gui $ getMarkedParts editor
   case is of
     pos':_ -> case pos' of
                0:pos -> do mth <- guiGetActualMethod
                            let e = if mth == meth then
                                      subterm(restbody,pos)
                                     else subterm(body(mth),pos)
                            gui $ showInfo ("Type of selected phrase is '" ++
                                            showPretty (typeOfExp e) ++
                                            "'" ++ f e)
                               where f (Term(InstanceInv mr _,_)_) = 
                                         ", call: " ++ 
                                         showJavaMRefArgs mr
                                     f (Term(ClassInv mr,_)_) =
                                         ", call: " ++ 
                                         showJavaMRefArgs mr
                                     f _ = ""
                _   -> mraise ("no phrase selected")
     _   -> mraise "multiple terms are selected"


execMachine :: Rule ()
execMachine = do
   execJavaThread
   recordSteps

recordSteps = do
   if pos /= posOld || meth /= methOld 
     then do steps   := steps + 1
             posOld  := pos
             methOld := meth
     else done


checkLoadedClasses :: JavaGUI ()
checkLoadedClasses = do
   done
   let program = [ td | (_, td) <- assocs(pgm) ]
   let StateM f = checkProgram(program)
   case f ("",({},[],[])) of
     Error(s)  -> mraise s
     Ok(_,p)   -> do io $ fire1 (do
                      forall td <- p do
                        pgm(typeNm(td)) := td)

guiReset :: GVar Int -> JavaGUI ()
guiReset backSteps = do
   io $ fire1 (do
       pgm(objectClass) := objectCode(pgm(objectClass),Term (Block,TJVoid) [Term (JavaReturn "",TJVoid) []])
       mainClass := ""
    )                            
   io $ fire1 (do
       steps   := 0
       methOld := ("" :/ ("",[]))
       posOld  := []
       meth    := entrypoint
       restbody:= body(entrypoint)
       pos     := firstPos
       breakpoint := Nothing
       locals  := {}
       frames  := []
       forall c <-: dom(classState) do
         forall f <- staticFields(c) do
           globals(f) := asmDefault
         if c `elem` predefinedClasses then do
           if c == objectClass || c == stringClass then
             classState(c) := ClassInitialized
            else
             classState(c) := ClassLinked
          else do
           classState(c) := asmDefault
           pgm(c) := asmDefault        
       forall r <-: dom(heap), r /= systemThread do
         heap(r) := asmDefault
         waitSet(r) := asmDefault
         cont(r) := asmDefault
         exec(r) := asmDefault
         interruptedFlag(r) := asmDefault
         sync(r) := asmDefault
         locks(r):= asmDefault
       forall t <-: dom(waitObj) do
         waitObj(t) := asmDefault
       forall t <-: dom(syncObj) do
         syncObj(t) := asmDefault
       waitSet(systemThread) := {}
       exec(systemThread) := Active
       sync(systemThread) := []
       thread             := systemThread
     )
   io (primAsmSetInteger (1 + maximum ({1} `union` dom(heap))))
   updateGUI
   updateGUIMethods
   updateGUIBreakpoint
   io  $ clearHistory
   gui $ writeGVar backSteps 0

guiChooseMain :: Bool -> GVar Int -> JavaGUI ()
guiChooseMain silent backSteps = do
    mths  <- guiListOfMethods
    vmref <- gui $ newGVar ("" :/ ("",[]))
    let f = filter (\mref -> snd (signature(mref)) == [TJArray(TJRef(stringClass))] &&
                             Static `elem` javaModifiers(mref)
                   )
    case f mths of
      []  -> mraise "cannot find any suitable main-method"
      [m] -> do if silent
                  then done
                  else gui $
                    showInfo ("using method '" ++ methNm m ++
                              "' of class " ++ classNm m)
                gui $ writeGVar vmref m
                setClass vmref
      ms  -> do w <- gui $ window (conf_window ++ [title "choose main method"])
                b <- gui $ button (conf_button ++ [text "Cancel",
                                   command (closeWindow w)]) w
                act <- java2gui done (setClass vmref)
                l <- gui $ listbox (conf_box ++ [initValue (map print ms)]) w
                s <- gui $ vscroll [takeFocus False,
                                    background scrollBarColor] l
                gui $ cset l (on (click 1)
                      (do [i] <- getSelection l
                          closeWindow w
                          writeGVar vmref (ms!!i)
                          act))
                gui $ pack ((l << fillY s) ^^ b)
  where print mref = classNm(mref) ++ "." ++ methNm(mref)
        setClass :: Var MethRef -> JavaGUI ()
        setClass vmref = do
              mref <- gui $ readGVar vmref
              io $ fire1(do mainClass := classNm(mref)
                            let o = objectCode (pgm(objectClass),startMain(mref))
                            pgm(objectClass) := o
                            if meth == entrypoint && pos == firstPos then
                              restbody := startMain(mref)
                             else done)
              gui $ writeGVar backSteps 0
              updateGUI
 

insertCFile :: [TypeDec] -> GVar Int -> JavaGUI ()
insertCFile cf backSteps = do
   io $ fire1 (do
   forall typeDec <- cf do
     pgm(typeNm(typeDec))        := typeDec
     classState(typeNm(typeDec)) := ClassLinked)
   gui $ writeGVar backSteps 0

mainClass :: Dynamic JavaClass
mainClass = initVal "mainClass" ""

all_methods :: [(JavaClass, MemDec)]
all_methods = [ (c,m) | c <-: dom(pgm), m <- methods(c) ]



moveToCurrentState :: IO Bool
moveToCurrentState = do
 steps <- primAsmSteps
 primAsmShowHistory steps

guiBack :: GVar Int -> JavaGUI ()
guiBack backSteps = do
 back  <- gui $ readGVar backSteps
 steps <- io primAsmSteps
 if steps - back > 0 then do
   b <- io $ primAsmShowHistory (steps-back-1)
   if b then do
     gui $ writeGVar backSteps (back+1)
     updateGUIMethods
     updateGUIBreakpoint
     updateGUI
    else gui $ showInfo "End of history"
  else 
    gui $ showInfo "End of history"


clearHistory :: IO ()
clearHistory = do
  primAsmSetHistory False  
  primAsmSetHistory True