-- --------------------------------------------------------------------------
-- pp-lib.gs: pretty printer combinators
--            generalization of [Hughes95]
--
-- Ton Vullinghs,  April 97
-- --------------------------------------------------------------------------




infixr $$
infixr <>

data Dw a = DwLeaf a
          | DwPrefix Int (Dw a)
          | DwSplit  (Dw a) (Dw a)

data Doc m = Nest (Dw ()) Int [Alt m]
data Alt m = PText Int [m] | Above Int [m]  (Doc m)

-- Basic ---------------------------------------------------------------------

class PPSeq a where
  ppseq :: a -> a -> a

instance PPSeq String where
  ppseq = (++)

instance PPSeq (IO ()) where
  ppseq = sequence



class PPSeq m => PrettyOut m where
  prettyOut  :: String -> m          -- how to print a single string?

  cprettyOut :: [Conf Tag] -> String -> m
  cprettyOut xs ys = prettyOut ys

  ($$) :: Doc m -> Doc m  -> Doc m
  (Nest dw n as) $$ d@(Nest dw2 _ _)
   = Nest (DwSplit dw dw2) n (map f as)
     where
        f (PText m s)    = Above m s (nest (-n) d)
        f (Above m s d') = Above m s (d' $$ nest (-n) d)

  indnt :: Int -> [m] -> [m] -> [m]
  indnt 0 s c = s ++ seqhead (prettyOut "\n") c
  indnt n s c = seqhead (prettyOut (copy n ' ')) (indnt 0 s c)
{-
  indnt n s c | n >= 8 = seqhead (prettyOut "\t") (indnt (n-8) s c)
  indnt n s c | n >= 1 = seqhead (prettyOut " ") (indnt (n-1) s c)
  indnt 0 s c          = s ++ seqhead (prettyOut "\n") c
-}
  indnt i s c = error ("indnt " ++ show i)



instance PrettyOut String where
  prettyOut = id

instance PrettyOut (IO ()) where
  prettyOut x  = putStr x



type IODoc   = Doc (IO ())
type TextDoc = Doc String



-- PP Library ----------------------------------------------------------------

(<>) :: PrettyOut a => Doc a -> Doc a -> Doc a
(Nest dw1 n as) <> (Nest dw2 m bs)
   = Nest (DwSplit dw1 dw2) n (concat (map f as))
     where
        f (PText k s)    = map g bs
                          where
                             g (PText l t)   = PText (k+l) (s ++ t)
                             g (Above l t d) = Above (k+l) (s ++ t) (nest k d)
        f (Above k s d) = [Above k s (d <> (Nest dw2 m bs))]

sep :: PrettyOut  a => [Doc a] -> Doc a
sep [d] = d
sep ds  = fitunion (foldr1 (<>) ds) (foldr1 ($$) ds)

layout  :: PrettyOut m => Int -> Int -> Doc m -> m  
layout w r = foldr1 ppseq . nestbest 0 w r

pp_text	:: PrettyOut  a   => String -> Doc a
pp_text e = Nest (DwLeaf ()) 0 [PText (length e) [prettyOut e ]]

pp_textL :: PrettyOut  a   => Int -> String -> Doc a
pp_textL d e = Nest (DwLeaf ()) 0 [PText d [prettyOut e ]]


pp_ctext :: PrettyOut a => [Conf Tag] -> String -> Doc a
pp_ctext cs e = Nest (DwLeaf ()) 0 [PText (length e) [cprettyOut cs e]]


nest :: PrettyOut a => Int -> Doc a -> Doc a
nest n (Nest dw m as) = Nest dw (m+n) as

dw :: PrettyOut a => Int -> Doc a -> Doc a
dw n (Nest ds i as) = Nest (DwPrefix n ds) i as

dws :: PrettyOut a => [Int] -> Doc a -> Doc a
dws ns (Nest ds i as) = Nest (f ns ds) i as
  where f []     ds = ds
        f (n:ns) ds = DwPrefix n (f ns ds)

-- Implementation ------------------------------------------------------------

fitunion  :: PrettyOut a => Doc a -> Doc a -> Doc a
nice      :: PrettyOut a => Int -> Int -> Alt a -> Bool
pchoose   :: PrettyOut a => Int -> Int -> Alt a -> Alt a -> Alt a
nestbest  :: PrettyOut a => Int -> Int -> Int -> Doc a -> [a]

fitunion (Nest dw1 n (PText m s : _)) (Nest dw2 _ as) = 
  Nest dw1 n (PText m s:as)
fitunion _ d  = d

nice w r (PText n s)   = n <= min r w
nice w r (Above n s d) = n <= min r w

pchoose w r d d' = if nice w r d then d else d'

nestbest n w r (Nest dw m as) = 
   case foldr1 (pchoose (w-m) r) as of
      PText _ s   -> indnt (n+m) s []
      Above _ s d -> indnt (n+m) s (nestbest (n+m) (w-m) r d)

seqhead :: PPSeq a => a -> [a] -> [a]  -- fuse `dummy' actions
seqhead a []     = []
seqhead a (x:xs) = (a `ppseq` x: xs)



-- Writing Pretty Printers ---------------------------------------------------

class PrettyOut (m b) => Pretty a m b where
  prettyPrec :: Int -> a -> Doc (m b)
  pretty     :: a -> Doc (m b)
  cpretty    :: [Conf Tag] -> a -> Doc (m b)
  cpretty  _ = pretty


instance Pretty String a b where
  pretty x     = pp_text x
  cpretty cs x = pp_ctext cs x

instance Pretty Int a b where
  pretty = pp_text . show

instance Pretty Bool a b where
  pretty = pp_text  . show 

-- Further Combinators -------------------------------------------------------

pp_pack :: PrettyOut a => String -> Doc a -> String -> Doc a
pp_pack left item right = sep [pp_text left <> item, pp_text right]

pp_parenthesized :: PrettyOut a => Doc a -> Doc a
pp_parenthesized xs = pp_pack "(" xs ")"

pp_bracketed :: PrettyOut a => Doc a -> Doc a 
pp_bracketed xs = pp_pack "[" xs "]"

pp_horizontal :: PrettyOut a => [Doc a] -> Doc a 
pp_horizontal = foldr (<>) (pp_text "") 

pp_vertical :: PrettyOut a => [Doc a] -> Doc a
pp_vertical [] = pp_text ""
pp_vertical cs = foldr1 ($$) cs

pp_sepby :: PrettyOut a => [Doc a] -> String -> Doc a
xs `pp_sepby` p
  = case xs of 
      []   -> pp_text ""
      y:ys -> sep ( y : map (\x -> pp_text p <> x) ys)

pp_commaList :: PrettyOut a => [Doc a] -> Doc a
pp_commaList ps = ps `pp_sepby` ", "

pp_spList :: PrettyOut a => [Doc a] -> Doc a
pp_spList ps = ps `pp_sepby` " "

pp_tupled :: PrettyOut a => [Doc a] -> Doc a
pp_tupled = pp_parenthesized . pp_commaList 



