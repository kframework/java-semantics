infixr 3 `implies`
infixl 8 #, ##
infixl 4 +<<
infix 5 `subseteq`


configuration = mapping (getConfigs_from_str (openfile "config"))

f_s :: String
f_s = cfgGetKey configuration "Font]" "size" "12"

displayFont :: String
displayFont = 
  let f = cfgGetKey configuration "Font]" "font" "helvetica" in
  case f of
    "helvetica"      -> helvetica
    "helvetica_bold" -> helvetica_bold
    "courier"        -> courier
    "courier_bold"   -> courier_bold
    "terminal"       -> terminal
    "terminal_bold"  -> terminal_bold
    _                -> f

color_label   = cfgGetKey configuration "Color]" "label"   "lightgreen"
color_button  = cfgGetKey configuration "Color]" "button"  "lightblue"
color_info    = cfgGetKey configuration "Color]" "info"    "lightblue"
color_frame   = cfgGetKey configuration "Color]" "frame"   "lightblue"
color_window  = cfgGetKey configuration "Color]" "window"  "lightblue"
color_listbox = cfgGetKey configuration "Color]" "listbox" "lightblue"



type Nat = Int

data Combine a b = a :/ b

instance (Ord a, Ord b, Ord (a,b)) => Ord (Combine a b) where
  a1 :/ b1 <= a2 :/ b2 = (a1,b1) <= (a2,b2)
  a1 :/ b1 >= a2 :/ b2 = (a1,b1) >= (a2,b2)
  a1 :/ b1 <  a2 :/ b2 = (a1,b1) <  (a2,b2)
  a1 :/ b1 >  a2 :/ b2 = (a1,b1) >  (a2,b2)

instance (Ord a, Ord (a,(b, c))) => Ord (a,b,c) where
  (a1,b1,c1) <= (a2,b2,c2) = (a1,(b1,c1)) <= (a2,(b2,c2))
  (a1,b1,c1) >= (a2,b2,c2) = (a1,(b1,c1)) >= (a2,(b2,c2))
  (a1,b1,c1) < (a2,b2,c2)  = (a1,(b1,c1)) <  (a2,(b2,c2))
  (a1,b1,c1) > (a2,b2,c2)  = (a1,(b1,c1)) >  (a2,(b2,c2))


newline :: String
newline = "\n"

cnl :: Char
cnl = '\n'

class UndefValue a where
  undefValue :: a

subseteq :: Eq a => {a} -> {a} -> Bool
xs `subseteq` ys = all (\x -> x `elem` ys) xs


takeTop :: ([a],Int) -> [a]
takeTop(xs,n) = drop (length xs - n) xs

dropTop :: ([a],Int) -> [a]
dropTop(xs,n) = take (length xs -n) xs

-- (Finite) Maps
type Map a b = {(a,b)}
(#) :: (Eq a, UndefValue b) => Map a b -> a -> b
m # k = case [v | (k',v) <-: m, k == k'] of
          [x]  -> x
          _    -> undefValue

mlookup :: (Eq a, Ord b, UndefValue b) => Map a b -> a -> b
mlookup = (#)

(+<<) :: Ord (b,c) => {(b,c)} -> {(b,c)} -> {(b,c)}
m1 +<< m2 = m2 `union` { (d,r) | (d,r) <-: m1, d `notElem` mdomain(m2) }

definedInEnv :: Ord a => a -> [Map a b] -> Bool
definedInEnv l = any (elem l . mdomain)

(##) :: Ord a => [Map a b] -> a -> b
(loc:locs)##l = case [v | (k,v) <-: loc, k==l] of
                  [x] -> x
                  _   -> locs##(l)
[]##l = error ("cannot find: " ++ show'(l))

(#+) :: Ord (a,b) => [Map a b] -> (a,b) -> [Map a b]
(loc:locs)#+(l,v) = case [v | (k,v) <-: loc, k==l] of
                      [x] -> (loc +<< {(l,v)}) : locs
                      _   -> loc : (locs#+(l,v))
[]#+l = error ("cannot find: " ++ show'(l))


class Range a b where
  mrange :: a -> {b}

instance Ord b => Range (Map a b) b where
  mrange m = setmap snd m

instance Ord a => Range [a] a where
  mrange = Set

mdomain :: Ord a => Map a b -> {a}
mdomain kvs = setmap fst kvs


type Derived a = a

-- Maybe
just(Just a) = a 

isJust :: Maybe a -> Bool
isJust Nothing = False
isJust _       = True


fst4 (a,_,_,_) = a
snd4 (_,b,_,_) = b
thd4 (_,_,c,_) = c
fth4 (_,_,_,d) = d

-- 
a `implies` b = not a || b

tops :: ([a],[Int]) -> [[a]]
tops = snd . splits

splits(xs,ns) = 
  let (l,r)       = splitAt (length xs - sum ns) xs
      f [] _      = []
      f (n:ns) xs = take n xs : f ns (drop n xs)
  in  (l, f ns r)

split(xs,n) | n <= len  = splitAt (len-n) xs
   where len = length xs


data Tree(a) = Leaf | Node(a, [Tree a])

reverseTree :: Tree a -> [[a]]
reverseTree t = map reverse (reverseTree' t)
  where reverseTree' Leaf          = [ [] ]
        reverseTree' (Node(c, ts)) = map (c:) (concat (map reverseTree' ts))

reverseTrees :: [Tree a] -> [[a]]
reverseTrees = concat . map reverseTree

nodes :: Eq a => [Tree a] -> [a]
nodes ts = nub (concat(map nodes' ts))
  where nodes'(Leaf)       = []
        nodes'(Node(c,ts)) = c : concat(map nodes' ts)

hasPrefix :: Eq a => [a] -> [a] -> Bool
xs `hasPrefix` p = and (zipWith (==) xs p)

samePrefix :: Eq a => ([a], [a]) -> [a]
samePrefix (ps, xs) = take n xs
  where n = length (takeWhile (uncurry (==)) (zip ps xs))

longestSequences :: (Eq a, Ord [a]) => [[a]] -> [[a]]
longestSequences = longestSequences' . sort
 where longestSequences' []   = []
       longestSequences' [x]  = [x]
       longestSequences' (x:y:ys) 
            | y `hasPrefix` x = longestSequences' (y:ys)
            | otherwise       = x : longestSequences' (y:ys)
                            

maybe2list :: Maybe a -> [a]
maybe2list (Just(x)) = [x]
maybe2list Nothing   = []


showSpaceList :: Text a => [a] -> ShowS
showSpaceList []     = id
showSpaceList (x:xs) = shows x . showString " " . showSpaceList xs

showNewLineList :: Text a => [a] -> ShowS
showNewLineList []     = id
showNewLineList (x:xs) = shows x . showString "\n" . showNewLineList xs

type TypeName = String 
type Name = String


notEmptyDom :: AsmVar (a -> b) -> Bool
notEmptyDom = not . emptyDom

javaFileOpenDialogue :: GUI (Maybe FilePath)
javaFileOpenDialogue = 
  do x <- tk_getTcl ["tk_getOpenFile","-title","{Select Java Program}",
                     "-filetypes","{{{Java Files} {.java}} {{All Files} * }}"]
     case x of
       ""   -> result Nothing
       name -> result (Just name)

jasminFileOpenDialogue :: GUI (Maybe FilePath)
jasminFileOpenDialogue = 
  do x <- tk_getTcl ["tk_getOpenFile","-title","{Select Class}",
                     "-filetypes","{{{Jasmin Files} {.j}} {{All Files} * }}"]
     case x of
       ""   -> result Nothing
       name -> result (Just name)

jasminFileSaveDialogue :: String -> GUI (Maybe FilePath)
jasminFileSaveDialogue filename = 
  do x <- tk_getTcl ["tk_getSaveFile","-title","{Save Class}",
                     "-defaultextension",".j",
                     "-initialfile",filename,
                     "-filetypes","{{{Jasmin Files} {.j}} {{All Files} * }}"]
     case x of
       ""   -> result Nothing
       name -> result (Just name)


backcolor :: String  -- for pretty edit
backcolor = "white"

markcolorEditor :: String -- for pretty edit
markcolorEditor = "grey"

scrollBarColor :: String
scrollBarColor = "lightblue"

conf_label :: (HasForeground a, HasBackground a) => [Conf a]
conf_label = [background color_label, font displayFont]

conf_button :: (HasForeground a, HasBackground a) => [Conf a]
conf_button = [background color_button, font displayFont]

conf_info :: (HasForeground a, HasBackground a) => [Conf a]
conf_info = [background color_info, font displayFont]

conf_frame :: (HasBackground a, HasBorder a) => [Conf a]
conf_frame = [borderWidth 3, relief "raised", background color_frame]

conf_window :: HasBackground a => [Conf a]
conf_window = [background color_window]

conf_box :: (HasForeground a, HasBackground a) => [Conf a]
conf_box = [background color_listbox, font displayFont]


set_working :: Window -> GUI ()
set_working w = do
  cset w (cursor "watch")

set_ready :: Window -> GUI ()
set_ready w = cset w (cursor "")

guiExec :: Window -> GUI a -> GUI a
guiExec w act = do
  set_working w
  res <- act
  set_ready w
  result res


commandOnClose :: Window -> GUI () -> GUI ()
commandOnClose w act = do
   let x = tk_getPathName w
   id <- tk_addCallBack x (\_ -> do act; destroy w)
   tk_putTcl [ "wm protocol", x,"WM_DELETE_WINDOW"
                    , "{doEvent \"", show id , "\"}"
             ]
        
commandDestroy :: Window -> GUI () -> GUI ()
commandDestroy w act = do
   let x = tk_getPathName w
   id <- tk_addCallBack x (\_ -> act)
   tk_putTcl [ "wm protocol", x,"WM_DELETE_WINDOW"
                    , "{doEvent \"", show id , "\"}"
             ]
        




courier :: String
courier =        "-*-courier-medium-r-normal-*-" ++ f_s
              ++ "-*-*-*-m-*-iso8859-1"

courier_bold :: String
courier_bold = "-*-courier-bold-r-normal-*-" ++ f_s
              ++ "-*-*-*-m-*-iso8859-1"

courier_italic :: String
courier_italic = "-*-courier-medium-i-normal-*-" ++ f_s
              ++ "-*-*-*-m-*-iso8859-1"

helvetica :: String
helvetica =      "-*-helvetica-medium-r-normal-*-" ++ f_s
              ++ "-*-*-*-p-*-iso8859-1"

helvetica_bold :: String
helvetica_bold =      "-*-helvetica-bold-r-normal-*-" ++ f_s
              ++ "-*-*-*-p-*-iso8859-1"

terminal :: String
terminal =       "-*-terminal-medium-r-normal-*-" ++ f_s
              ++ "-*-*-*-c-*-iso8859-1"

terminal_bold :: String
terminal_bold =  "-*-terminal-bold-r-normal-*-" ++ f_s
              ++ "-*-*-*-c-*-iso8859-1"


cf_color_intensity :: Int
cf_color_intensity = 8


to_range l u x | x < l = l
               | x > u = u
               | True  = x

from_hex :: String -> Int
from_hex = foldl (\s x -> 16 * s + hex' x) 0
  where hex' x | '0' <= x && x <= '9' = ord x - ord '0'
        hex' x | 'a' <= x && x <= 'f' = ord x - ord 'a' + 10
        hex' x | 'A' <= x && x <= 'F' = ord x - ord 'A' + 10

cf_color r g b brightness color_intensitiy =
  let a = cf_color_intensity * color_intensitiy
      o = from_hex brightness
  in  rgb (to_range 0 255 (o + r*a))
          (to_range 0 255 (o + g*a))
          (to_range 0 255 (o + b*a))

cf_red, cf_blue, cf_green, cf_cyan, cf_yellow, cf_violett
  :: String -> Int -> String
cf_red     = cf_color ( 2) (-1) (-1)
cf_yellow  = cf_color ( 1) ( 1) (-2)
cf_green   = cf_color (-1) ( 2) (-1)
cf_cyan    = cf_color (-2) ( 1) ( 1)
cf_blue    = cf_color (-1) (-1) ( 2)
cf_violett = cf_color ( 1) (-2) ( 1)



cf_fg_bg_widget :: (HasBackground a, HasForeground a) => String -> [Conf a]
cf_fg_bg_widget bg = [ foreground "#000000", background bg ]

cf_fg_bg_ac_widget :: (HasForeground a, HasBackground a, HasCommand a)
                   => String -> String -> [Conf a]
cf_fg_bg_ac_widget bg ac = [ foreground "#000000", background bg
               , activeForeground "#000000", activeBackground ac ]

cf_bg_widget :: HasBackground a => String -> [Conf a]
cf_bg_widget bg = [ background bg ]

cf_bg_ac_widget :: (HasBackground a, HasCommand a)
                => String -> String -> [Conf a]
cf_bg_ac_widget bg ac = [ background bg, activeBackground ac ]

cf_lb, cf_l, cf_ro, cf_err, cf_war, cf_ok
       :: (HasBackground a, HasForeground a) => [Conf a]
cf_bt, cf_mn :: (HasBackground a, HasForeground a, HasCommand a) => [Conf a]
cf_sc  :: HasBackground a => [Conf a]

cf_lb  = cf_fg_bg_widget    (cf_green   "d9" 1)
cf_bt  = cf_fg_bg_ac_widget (cf_blue    "d9" 2) (cf_blue    "ec" 2)
cf_mn  = cf_fg_bg_ac_widget (cf_yellow  "d9" 2) (cf_yellow  "ec" 2)
cf_l   = cf_fg_bg_widget    (cf_red     "d9" 1)
cf_ro  = cf_fg_bg_widget    (cf_red     "d9" 1)
cf_err = cf_fg_bg_widget    (cf_red     "d9" 4)
cf_war = cf_fg_bg_widget    (cf_yellow  "d9" 4)
cf_ok  = cf_fg_bg_widget    (cf_green   "d9" 4)
cf_sc  = cf_bg_widget       (cf_violett "c4" 1)


resubstNewline :: String -> String
resubstNewline ('\n':xs) = '\\':'n':resubstNewline xs
resubstNewline (x:xs)    = x : resubstNewline xs
resubstNewline []        = []

substNewline :: String -> String
substNewline ('\\':'n':xs) = '\n' : substNewline xs
substNewline (x:xs)        = x : substNewline xs
substNewline []            = []

