-------------------------------------------------------------------------------
-- editor.gs
--
-- editor widget with primitive operations for writing
-------------------------------------------------------------------------------





type Editor a = Edit -> GUI a 
  in editor, liftEdit, liftEdit, toEdit, fromEdit, 
     mapEdit, bindGUI, resultGUI

editor :: [Conf Edit] -> Editor () -> IO ()
editor cs ed = start $ do    
  w <- window []
  x <- edit cs w
  y <- vscroll cf_sc x
  b1 <- button ([text "clear", command (setValue x "")] ++ cf_bt) w
  b2 <- button ([text "quit", command quit] ++ cf_bt) w
  pack (flexible (flexible x <|< y) ^-^ (b1 << b2))
  ed x

fromEdit :: Editor a -> Edit -> GUI a
fromEdit e x = e x

toEdit :: (Edit -> GUI a) -> Editor a
toEdit = id

liftEdit :: GUI a -> Editor a
liftEdit = toEdit . const

setText :: String -> Editor ()
setText s = toEdit (\e -> setValue e s)

writeCF :: [Conf Tag] -> String -> Editor Tag
writeCF cs s = toEdit (\e -> putEndTag' e s cs) 

putEndTag' :: Edit -> String -> [Conf Tag] -> GUI Tag
putEndTag' w s cs =
  do let n = tk_getPathName w
     t <- tk_newPathName
     tk_output (tk_toGUI s) $ \x -> do
       tk_putTcl ["jIT", "t"++ t]
       let v = Tag n ("t" ++ t) in do {csets v cs ; result v}


write :: String -> Editor Tag
write = writeCF []

writeln :: String -> Editor Tag
writeln x = write (x++"\n")

instance Functor Editor where
  map = mapEdit

mapEdit :: (a -> b) -> Editor a -> Editor b
mapEdit f ed = map f . ed 

instance Monad0 Editor
instance Monad  Editor where
  result = resultGUI
  bind   = bindGUI

resultGUI :: a -> Editor a
resultGUI x e = result x

bindGUI :: Editor a -> (a -> Editor b) -> Editor b
bindGUI e g = \x -> do y <- e x; g y x



