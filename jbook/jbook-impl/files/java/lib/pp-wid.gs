-- --------------------------------------------------------------------------
-- pp-lib.gs: pretty printer combinators
--            generalization of [Hughes95]
--
-- Ton Vullinghs,  April 97
-- --------------------------------------------------------------------------

divide :: (a->Bool) -> [a] -> ([a], [a])
divide p = foldr (\x (a,b)->if p x then (x:a,b) else (a,x:b)) ([],[])

insertDwInfo :: [a] -> Dw () -> Dw a
insertDwInfo as dw = case insertDwInfo' dw as of
                        ([],dw) -> dw
                        (xs,_)  -> error ("insertDwInfo: " ++  show' xs)

insertDwInfo' :: Dw () -> [a] -> ([a],Dw a)
insertDwInfo' (DwLeaf _) (a:as)  = (as,DwLeaf a)
insertDwInfo' (DwPrefix n dw) as = let (as',dw') = insertDwInfo' dw as
                                   in (as',DwPrefix n dw')
insertDwInfo' (DwSplit dw1 dw2) as = let (as1,dw1') = insertDwInfo' dw1 as in
                                     let (as2,dw2') = insertDwInfo' dw2 as1 in
                                     (as2,DwSplit dw1' dw2')

dwToList :: Dw a -> [a]
dwToList dw = dwToList' dw []

dwToList' :: Dw a -> [a] -> [a]
dwToList' (DwLeaf a)        = (:)a
dwToList' (DwPrefix n dw)   = dwToList' dw
dwToList' (DwSplit dw1 dw2) = dwToList' dw1 . dwToList' dw2

dwSelect :: Dw a -> [Int] -> [a]
dwSelect dw ps = dwSelect' dw ps []

dwSelect' :: Dw a -> [Int] -> [a] -> [a]
dwSelect' dw []        = dwToList' dw
dwSelect' (DwLeaf a) [] = (:)a
dwSelect' (DwLeaf _) _  = id
dwSelect' (DwPrefix n dw) (p:ps) | n==p      = dwSelect' dw ps
                                 | otherwise = id
dwSelect' (DwSplit dw1 dw2) ps = dwSelect' dw1 ps . dwSelect' dw2 ps

markLayout :: PInfo -> Edit -> Doc (Editor Tag) -> Editor () 
markLayout st e d@(Nest dw _ _) = 
  do (a,b,(w,r),setClicks,_) <- liftEdit $ getValue st
     liftEdit $ tk_putTcl ["jSW",tk_getPathName e]
     as <- binds (nestbest 0 w r d)
     let ps   = insertDwInfo as dw
         ts d = dwSelect ps d
         clicks p (DwLeaf t) = 
                               setCmd t $
                                 changeMark st e (p,ts p)
{-
                               cset t (on (click 1) $ 
                                 changeMark st e (p,ts p))
-}
         clicks p (DwSplit dw1 dw2) = do clicks p dw1; clicks p dw2
         clicks p (DwPrefix n dw)   = clicks (p++[n]) dw
     liftEdit $ setValue st ([],b,(w,r),setClicks,ts)
     if setClicks then liftEdit $  clicks [] ps
      else done
 where
  setCmd (Tag n i) cmd = do
    e <- tk_addCallBack (n ++ ".@" ++ show i) (\_ -> cmd)
    tk_putTcl ["jSC",i,show e]


changeMark :: PInfo -> Edit -> ([Int],[Tag]) -> GUI ()
changeMark st e (d,new) =
  do (old,mcol,s,setClicks,f) <- getValue st
     c <- cget e background     -- restore color
     let (old',del) = divide p old
         p (p,t)    = d `isPrefix` p
     tk_putTcl ["jSW",tk_getPathName e]
     seqs [tk_putTcl ["jCTB",t,c]    | (_,ts) <- del, Tag _ t <- ts]
     seqs [tk_putTcl ["jCTB",t,mcol] | Tag _ t <- new]
{-
     seqs [cset t (background c)    | (_,ts) <- del, t <- ts]
     seqs [cset t (background mcol) | t <- new]
-}
     setValue st ((d,new):old',mcol,s,setClicks,f)
     if not (null new) then do
       let Tag n i = head new
       tk_toTcl e ["see",i ++ ".first"]
      else done


-- -------------------------------------------------------------
-- prettyEdit widget
-- -------------------------------------------------------------

type PInfo = Clipboard ([([Int],[Tag])],String, (Int,Int), Bool,
                                [Int] -> [Tag])  
                 -- pos, tags, color, size, setClicks, dw -> tags
data PrettyEdit0 a = PrettyEdit PInfo Edit a 
type PrettyEdit a  = WItem (PrettyEdit0 a)

prettyEditW :: PrettyEdit a -> Edit
prettyEditS :: PrettyEdit a -> PInfo

prettyEditW (WItem (PrettyEdit _ e _) _)  = e
prettyEditS (WItem (PrettyEdit st _ _) _) = st

prettyEdit :: (Pretty a Editor Tag, Widget (PrettyEdit a))
           => [Conf (PrettyEdit a)] -> Window -> GUI (PrettyEdit a)
prettyEdit cs w =
  do st <- clipboard [initValue ([],"grey", (60,60),True,const [])]
     e  <- edit [cursor "hand1", wrap False, font displayFont] w
     h  <- hscroll cf_sc e
     v  <- vscroll cf_sc e
     composeWidget (PrettyEdit st e undefined) 
                   (flexible (flexible (flexible e <|< v) ^-^ h) )
                   cs

instance Widget (PrettyEdit a) where
  cset w c = cset (prettyEditW w) (const (c w))

instance (HasInput TItem Clipboard0 (a,[Int],[Tag]) , Pretty a Editor Tag)
         => HasInput WItem PrettyEdit0 a where
  setValue w t = 
    let st = prettyEditS w
        e  = prettyEditW w
    in do tk_delBelowEvents (tk_getPathName e)  -- delete old tag bindings
          cset e (readOnly False) -- enable writing 
          setValue e ""           -- delete old text and tags
          fromEdit (markLayout st e (pretty t)) e
          cset e (readOnly True)  -- disable writing
          (y,_) <- getSize e      -- scroll window
          setYView e y


generateClickCommands :: PrettyEdit a -> Bool -> GUI ()
generateClickCommands e gen = do
   let st = prettyEditS e
   (a,b,c,_,f) <- getValue st
   setValue st (a,b,c,gen,f)


getMarkedParts :: PrettyEdit a -> GUI [[Int]]
getMarkedParts = map (\(a,_,_,_,_) -> map fst a) . getValue . prettyEditS 

getMarkedTags :: PrettyEdit a -> GUI [[Tag]]
getMarkedTags = map (\(a,_,_,_,_) -> map snd a) . getValue . prettyEditS 


setMarkedTags :: PrettyEdit a -> [Int] -> GUI ()
setMarkedTags e dw = do
   let st = prettyEditS e
   (_,_,_,_,f) <- getValue st
   changeMark st (prettyEditW e) (dw,f(dw))

markColor :: String -> Conf (PrettyEdit a)
markColor b w =
  Tk_FreeOption $
    do let st = prettyEditS w
       (a,_,c,s,f) <- getValue st
       setValue st (a,b,c,s,f)

prettySize :: (Int,Int) -> Conf (PrettyEdit a)
prettySize (x,y) w = 
  Tk_FreeOption $
    do let st = prettyEditS w
       (a,b,_,s,f) <- getValue st
       setValue st (a,b,(x,y),s,f)  



instance HasBackground (PrettyEdit a)
instance HasForeground (PrettyEdit a)
instance HasWidth      (PrettyEdit a)
instance HasBorder     (PrettyEdit a)
instance HasHeight     (PrettyEdit a)
instance HasPad        (PrettyEdit a)
instance HasScroll     (PrettyEdit a)

