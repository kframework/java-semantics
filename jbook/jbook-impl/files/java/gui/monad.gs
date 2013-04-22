type Display = ( ( Button, Button, Button,  -- load, where, step
                   Button, Button,          -- step call, run
                   Button,                  -- break
                   Button, Button, Button   -- reset, main, quit
                 )
               , ( Listbox [String]         -- heap
                 , Listbox [String]         -- methods
                 , Listbox [String]         -- class info
                 , Listbox [String]         -- frame stack
                 , PrettyEdit (JavaClass,MemDec)-- editor
                 , Window                   -- top level window
                 )
               , ( Label                    -- steps
                 , Label                    -- frames
                 , Label                    -- breakpoint
                 , Label                    -- thread
                 )
               )


type GUIState = ( GVar [MethRef], GVar MethRef )

data JavaGUI a = JAVA ((Display, GUIState) -> GUI (Error a))

instance Functor JavaGUI where
   map f (JAVA g) = JAVA (\d -> map (map f) (g d))

instance Monad JavaGUI where
   result = JAVA . const . result . result
   JAVA g `bind` f = JAVA (\s -> let m = g s
                                 in  do x <- m
                                        case x of
                                         Ok a -> let JAVA g' = f a
                                                 in  g' s
                                         Error s -> result (Error s))

instance Monad0 JavaGUI where
  zero = JAVA (const (result (Error "pattern matching failed")))
 

instance ErrorMonad JavaGUI where
  mraise s = JAVA (\d -> result (mraise s))

------------------------------------------------------------------------


catch_gui :: Window -> GUI (Error a) -> GUI () -> GUI ()
catch_gui w m upd = 
   do x <- m
      case x of
       Ok _    -> done
       Error s -> do set_ready w; myerror s; upd

myerror :: String -> GUI ()
myerror s =
  do w  <- windowDefault (conf_window ++ [title "Error"
                         , winPosition (400,400)]) []
     l  <- label (conf_label ++ [bitmap "Bitmaps/error.bmp", width 30]) w
     m  <- label (conf_label ++ [ text s, width 66, height 5
                  , justify "left"]) w
     f  <- frame [borderWidth 2, relief "raised"] (l <|< flexible m)
     let close = command (closeWindow w)
     b <- button (conf_button ++ [text "Ok",  padx 5, pady 5, close]) w
     focus b
     pack (flexible f ^^ b)

showInfo :: String -> GUI ()
showInfo s =
  do w  <- windowDefault (conf_window ++ [title "Info"
                         , winPosition (400,400)]) []
     l  <- label (conf_label ++ [bitmap "Bitmaps/info.bmp", width 30]) w
     m  <- label (conf_label ++ [ text s, width 66, height 5
                  , justify "left"]) w
     f  <- frame [borderWidth 2, relief "raised"] (l <|< flexible m)
     let close = command (closeWindow w)
     b <- button (conf_button ++ [text "Ok",  padx 5, pady 5, close]) w
     focus b
     pack (flexible f ^^ b)


gui :: GUI a -> JavaGUI a
gui = JAVA . const . map result

io :: IO a -> JavaGUI a
io = JAVA . const . map result . liftIO


java2gui :: JavaGUI () -> JavaGUI a -> JavaGUI (GUI ())
java2gui (JAVA upd) (JAVA g) =
    do s <- getGUIDisplayAndState
       w <- guiWindow
       result $ catch_gui w (g s) (void (upd s))

err2java :: Error a -> JavaGUI a
err2java x = JAVA (const (result x))

javaExec :: JavaGUI a -> JavaGUI a
javaExec act = do
  w <- guiWindow
  gui $ set_working w
  res <- act
  gui $ set_ready w
  result res


--------------------------------------------------------------------------

getDisplay :: JavaGUI Display
getDisplay = JAVA (result . result . fst)

getGUIState :: JavaGUI GUIState
getGUIState = JAVA (result . result . snd)

getGUIDisplayAndState :: JavaGUI (Display, GUIState)
getGUIDisplayAndState = JAVA (result . result)

guiListOfMethods :: JavaGUI [MethRef]
guiListOfMethods = do (ms,_) <- getGUIState
                      gui $ readGVar ms

guiSetListOfMethods :: [MethRef] -> JavaGUI ()
guiSetListOfMethods mths = do (ms,_) <- getGUIState
                              gui $ writeGVar ms mths

guiGetActualMethod :: JavaGUI MethRef
guiGetActualMethod = do (_,gm) <- getGUIState
                        gui $ readGVar gm

guiSetActualMethod :: MethRef -> JavaGUI ()
guiSetActualMethod mr = do (_,gm) <- getGUIState
                           gui $ writeGVar gm mr


getInputEditor :: JavaGUI Edit 
getInputEditor = do
  markEditor <- guiEditor
  result (prettyEditW markEditor)

guiMths :: JavaGUI (Listbox [String])
guiMths = do (_,(_,mths,_,_,_,_),_) <- getDisplay
             result mths

guiHeap :: JavaGUI (Listbox [String])
guiHeap = do (_,(heap,_,_,_,_,_),_) <- getDisplay
             result heap

guiEditor :: JavaGUI (PrettyEdit (JavaClass,MemDec))
guiEditor = do (_,(_,_,_,_,editor,_),_) <- getDisplay
               result editor

guiWindow :: JavaGUI Window
guiWindow = do (_,(_,_,_,_,_,w),_) <- getDisplay
               result w

guiClassInfo :: JavaGUI (Listbox [String])
guiClassInfo = 
    do (_,(_,_,fields,_,_,_),_) <- getDisplay
       result(fields)

guiFramestack :: JavaGUI (Listbox [String])
guiFramestack = 
    do (_,(_,_,_,stack,_,_),_) <- getDisplay
       result(stack)

guiBreakpoint :: JavaGUI Label
guiBreakpoint = do (_,_,(_,_,b,_)) <- getDisplay
                   result b

guiSteps :: JavaGUI Label
guiSteps = do (_,_,(b,_,_,_)) <- getDisplay
              result b

guiFrames :: JavaGUI Label
guiFrames = do (_,_,(_,b,_,_)) <- getDisplay
               result b

guiThread :: JavaGUI Label
guiThread = do (_,_,(_,_,_,t)) <- getDisplay
               result t

