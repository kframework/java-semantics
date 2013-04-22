main :: IO ()
main = do
  primAsmSetInteger (1 + maximum ({1} `union` dom(heap)))
  java_start done

java_start :: JavaGUI a -> IO ()
java_start act = start $ do
   gui <- create_gui updateGUI [ guiLoadFile,
                                 guiCompile,
                                 guiReset,
                                 gui quit ]
   g gui
 where JAVA g = do initGUI
                   updateGUI
                   act


control_frame :: Window -> GUI (Frame, [Button])
control_frame w = do 
  bs <- binds [ button (conf_button ++ [text t, anchor "w"]) w
              | t <- [ "Load", "Compile", "Reset", "Quit" ]
              ]
  l <- label ([text "CONTROL"] ++ conf_label) w
  f <- frame conf_frame (l ^-^ vertical (map fillX bs))
  result (fillY f, bs)

valueBox :: [String] -> Window -> GUI (Frame, [Label])
valueBox ns w = do
  names <- binds [ label (conf_label ++
                         [ text n, relief "sunken", anchor "w"]) w
                 | n <- ns ]
  ls <- binds [ label [relief "sunken", width 4, anchor "w"] w
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
   w <- window (conf_window ++ [title "Compiler"])
   commandOnClose w quit
   (fmethods, lmethods)     <- listboxWithTitle "METHODS" w
   (fclassInfo, lclassInfo) <- listboxWithTitle "CLASSES" w
   (fctrl, [ bLoad,  bRun, bReset, bQuit ]) <- control_frame w
   (meditor,fmeditor)       <- markEditor w
   pack $
     flexible (fillX (fctrl <+< expand (fillY fmethods << flexible fmeditor)))
     ^^ flexible fclassInfo
   let display = ( (bLoad, undefined, undefined, undefined, bRun,
                    undefined, undefined, undefined, bQuit
                   )
                 , ( undefined, lmethods, lclassInfo, undefined, meditor,w )
                 , undefined
                 )
   listOfMethods <- newGVar []
   meth          <- newGVar undefined
   let guistate = ( listOfMethods, meth )
   let javaExecute (JAVA f) = catch_gui w (f (display, guistate))
                                          (void (upd (display, guistate)))
   let [ cLoad, cCompile, cReset, cQuit ] = map javaExecute cmds
   cset bLoad     (command cLoad)
   cset bRun      (command cCompile)
   cset bReset    (command cReset)
   cset bQuit     (command cQuit)
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
        v  <- vscroll [takeFocus False, background scrollBarColor] lb
        l  <- label ([text title] ++ conf_label) w
        f  <- frame conf_frame (l ^-^ (flexible (flexible lb <|< v)))
        result (flexible f, lb)

 

initGUI :: JavaGUI ()
initGUI = do
  gmths <- guiMths
  updateGUIMethods
  act <- java2gui done $ displayMethod
  gui $ cset gmths (on (click 1) act)
  checkLoadedClasses
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
   guiShowCurrentPosition
   gui updateTask


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
  gui $ setValue gfields (expr2list(dom(classState)))

guiCompile :: JavaGUI ()
guiCompile = do
  gcinfo <- guiClassInfo
  is <- gui $ getSelection gcinfo
  case is of
   [i] -> do classes <- gui $ getValue gcinfo
             let cn = classes!!i
             pn <- gui $ jasminFileSaveDialogue (cn ++ ".j")
             case pn of
              Just n -> gui $ writeFile n (jshow(compileClass(cn))"")
              Nothing -> done
   _   -> mraise "Please select a class"

selectClass :: String -> JavaGUI ()
selectClass(n) = do
  gcinfo <- guiClassInfo
  mths <- gui $ getValue gcinfo
  case filter (\(m,i) -> m==n) (zip mths [0..]) of
    (_,i):_ -> do gui $ setSelection gcinfo [i]
                  gui $ tk_toTcl gcinfo ["see",show i]
    _ -> done
  done


guiLoadFile :: JavaGUI ()
guiLoadFile = javaExec $ do
  x <- gui javaFileOpenDialogue
  case x of
   Nothing -> done
   Just(filename) -> do 
      cf  <- err2java (parse(filename))
      insertCFile (cf)
      updateGUI
      updateGUIMethods
      checkLoadedClasses
      updateGUI
      displayMethod
      if cf /= [] then selectClass(typeNm(head(cf))) else done

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
     _       -> mraise ("cannot find method " ++ classNm(meth)
                       ++ "." ++ methNm(meth))


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

guiReset :: JavaGUI ()
guiReset = do
   io $ fire1 (do
       pgm(objectClass) := objectCode(pgm(objectClass),Term (Block,TJVoid) [Term (JavaReturn "",TJVoid) []])
       mainClass := ""
    )                            
   io $ fire1 (do
       meth    := entrypoint
       restbody:= body(entrypoint)
       pos     := firstPos
       locals  := {}
       frames  := []
       forall c <-: dom(classState) do
         if c `elem` predefinedClasses then do
           if c == objectClass then
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
   updateGUI
   updateGUIMethods


insertCFile :: [TypeDec] -> JavaGUI ()
insertCFile (cf) =
   io $fire1 $ do
   forall typeDec <- cf do
     pgm(typeNm(typeDec))        := typeDec
     classState(typeNm(typeDec)) := ClassLinked

mainClass :: Dynamic JavaClass
mainClass = initVal "mainClass" ""

all_methods :: [(JavaClass, MemDec)]
all_methods = [ (c,m) | c <-: dom(pgm), m <- methods(c) ]

