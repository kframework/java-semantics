type Display = ( ( Button,Button,Button,  -- load, where, step1
                   Button,Button,Button,  -- stepl, stepo, run,
                   Button,                -- break
                   Button,Button,Button   -- reset, main, quit
                 )  
               , ( Listbox [String]         -- opd
                 , Listbox [String]         -- heap
                 , Listbox [String]         -- registers
                 , Listbox [String]         -- methods
                 , Listbox [String]         -- instructions
                 , Listbox [String]         -- class info
                 )
               , ( Label                    -- pc
                 , Label                    -- frames
                 , Label                    -- switch
                 , Label                    -- phase
                 , Label                    -- steps
                 )
               , ( Label                    -- breakpoint
                 , Window                   -- top level window
                 )
               )

type GUIState = ( GVar [MRef]               -- displayed methods
                , GVar MRef                 -- displayed method
                )
               
-------------------------------------------------------------------------

data JVM a = JVM ((Display, GUIState) -> GUI (Error a))

instance Functor JVM where
   map f (JVM g) = JVM (\d -> map (map f) (g d))

instance Monad JVM where
   result = JVM . const . result . result
   JVM g `bind` f = JVM (\s -> let m = g s
                               in  do x <- m
                                      case x of
                                        Ok a -> let JVM g' = f a
                                                in  g' s
                                        Error s -> result (Error s))

instance Monad0 JVM where
  zero = JVM (const (result (Error "pattern matching failed")))

instance ErrorMonad JVM where
  mraise s = JVM (\d -> result (mraise s))

------------------------------------------------------------------------

catch_gui :: Window -> GUI (Error a) -> GUI () -> GUI ()
catch_gui w m upd = 
   do x <- m
      case x of
        Ok _    -> done
        Error s -> do set_ready w; myerror s; upd

myerror :: String -> GUI ()
myerror s = 
  do w  <- windowDefault [title "Error"
                         , winPosition (400,400)] []
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
  do w  <- windowDefault [title "Info"
                         , winPosition (400,400)] []
     l  <- label (conf_label ++ [bitmap "Bitmaps/info.bmp", width 30]) w
     m  <- label (conf_label ++ [ text s, width 66, height 5
                  , justify "left"]) w
     f  <- frame [borderWidth 2, relief "raised"] (l <|< flexible m)
     let close = command (closeWindow w)
     b <- button (conf_button ++ [text "Ok",  padx 5, pady 5, close]) w
     focus b
     pack (flexible f ^^ b)


gui :: GUI a -> JVM a
gui = JVM . const . map result

io :: IO a -> JVM a
io = JVM . const . map result . liftIO


jvm2gui :: JVM () -> JVM a -> JVM (GUI ())
jvm2gui (JVM upd) (JVM g) = 
    do s <- getGUIDisplayAndState
       let w = error "w"
       result $ catch_gui w (g s) (void (upd s))

err2jvm :: Error a -> JVM a
err2jvm x = JVM (const (result x))

jvmExec :: JVM a -> JVM a
jvmExec act = do
  w <- guiWindow
  gui $ set_working w
  res <- act
  gui $ set_ready w
  result res

--------------------------------------------------------------------------

getDisplay :: JVM Display
getDisplay = JVM (result . result . fst)

getGUIState :: JVM GUIState
getGUIState = JVM (result . result . snd)

getGUIDisplayAndState :: JVM (Display, GUIState)
getGUIDisplayAndState = JVM (result . result)


guiOpd :: JVM (Listbox [String])
guiOpd = do (_,(opd,_,_,_,_,_),_,_) <- getDisplay
            result opd

guiHeap :: JVM (Listbox [String])
guiHeap = do (_,(_,heap,_,_,_,_),_,_) <- getDisplay
             result heap

guiRegisters :: JVM (Listbox [String])
guiRegisters = do (_,(_,_,registers,_,_,_),_,_) <- getDisplay
                  result registers

guiMths :: JVM (Listbox [String])
guiMths = do (_,(_,_,_,mths,_,_),_,_) <- getDisplay
             result mths

guiInsn :: JVM (Listbox [String])
guiInsn = do (_,(_,_,_,_,insn,_),_,_) <- getDisplay
             result insn

guiClassInfo :: JVM (Listbox [String])
guiClassInfo = do (_,(_,_,_,_,_,ci),_,_) <- getDisplay
                  result ci

guiValues :: JVM (Label, Label, Label, Label, Label)
guiValues =  do (_,_,vs,_) <- getDisplay
                result vs

guiBreakpoint :: JVM Label
guiBreakpoint = do (_,_,_,bp) <- getDisplay
                   result (fst bp)

guiWindow :: JVM Window
guiWindow = do (_,_,_,bp) <- getDisplay
               result (snd bp)


guiListOfMethods :: JVM [MRef]
guiListOfMethods = do (ms,_) <- getGUIState
                      gui $ readGVar ms

guiGetActualMethod :: JVM MRef
guiGetActualMethod = do (_,vm) <- getGUIState
                        gui $ readGVar vm

guiSetActualMethod :: MRef -> JVM ()
guiSetActualMethod m = do (_,vm) <- getGUIState
                          gui $ writeGVar vm m


guiSetListOfMethods :: [MRef] -> JVM ()
guiSetListOfMethods mths = do (ms,_) <- getGUIState
                              gui $ writeGVar ms mths

pcOld    :: AsmVar (Nat)
pcOld    = initVal "pcOld" pc
methOld  :: AsmVar (MRef)
methOld  = initVal "methOld" meth

steps :: AsmVar (Int)
steps = initVal "steps" 0

     
