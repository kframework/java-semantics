-----------------------------------------------------------------------------
-- Standard Library: Array operations
--
-- Suitable for use with Hugs 1.4.
-----------------------------------------------------------------------------

{-
module  Array ( 
    module Ix,  -- export all of Ix 
    Array, array, listArray, (!), bounds, indices, elems, aassocs, 
    accumArray, (//), accum, ixmap ) where
-}

import Ix
import List( (\\) )

infixl 9  !, //

--data Array a b -- Arrays are implemented as a primitive type

array          :: Ix a => (a,a) -> [(a,b)] -> Array a b
listArray      :: Ix a => (a,a) -> [b] -> Array a b
(!)	       :: Ix a => Array a b -> a -> b
bounds         :: Ix a => Array a b -> (a,a)
indices        :: Ix a => Array a b -> [a]
elems          :: Ix a => Array a b -> [b]
aassocs	       :: Ix a => Array a b -> [(a,b)]
(//)           :: Ix a => Array a b -> [(a,b)] -> Array a b
accum          :: Ix a => (b -> c -> b) -> Array a b -> [(a,c)] -> Array a b
accumArray     :: Ix a => (b -> c -> b) -> b -> (a,a) -> [(a,c)] -> Array a b
ixmap	       :: (Ix a, Ix b) => (a,a) -> (a -> b) -> Array b c -> Array a c

primitive primArray' "primArray" 
    :: (a -> Int) -> (a,a) -> [(a,b)] -> Array a b
primArray :: [(a,b)] -> (a,a) -> (a -> Int) -> Array a b
primArray assocs bounds range = primArray' range bounds assocs

primitive primUpdate' "primUpdate"
    :: (a -> Int) -> Array a b -> [(a,b)] -> Array a b
primUpdate :: [(a,b)] -> Array a b -> (a -> Int) -> Array a b
primUpdate assocs arr range = primUpdate' range arr assocs
primitive primAccum' "primAccum"
    :: (a -> Int) -> (b -> c -> b) -> Array a b -> [(a,c)] -> Array a b
primAccum :: [(a,c)] -> Array a b -> (b -> c -> b) -> (a -> Int) -> Array a b
primAccum assocs arr f range = primAccum' range f arr assocs
primitive primAccumArray' "primAccumArray"
    :: (a -> Int) -> (b -> c -> b) -> b -> (a,a) -> [(a,c)] -> Array a b
primAccumArray :: [(a,c)] -> (a,a) -> b -> (b -> c -> b) -> (a -> Int) -> Array a b
primAccumArray assocs bounds g f range = primAccumArray' range f g bounds assocs
primitive primSubscript' "primSubscript"
    :: (a -> Int) -> Array a b -> a -> b
primSubscript :: Ix a => ((a,a) -> a -> Int) -> Array a b -> a -> b
primSubscript f arr = primSubscript' (f (bounds arr)) arr

primitive primBounds "primBounds" :: Array a b -> (a,a)
primitive primElems  "primElems"  :: Array a b -> [b]
primitive primAmap   "primAmap"   :: (b -> c) -> Array a b -> Array a c

array bounds assocs = primArray assocs bounds (index bounds)
listArray b vs      = array b (zip (range b) vs)
(!)                 = primSubscript index
bounds              = primBounds
indices	            = range . bounds
elems               = primElems
aassocs a           = zip (indices a) (elems a)
accumArray f z b as = primAccumArray as b z f (index b)
a // as             = primUpdate as a (index (bounds a))
accum f a as        = primAccum as a f (index (bounds a))
amap                = primAmap
ixmap b f a         = array b [ (i, a ! f i) | i <- range b ]

instance (Ix a) => Functor (Array a) where
    map = primAmap

instance (Ix a, Eq [(a,b)], Eq b) => Eq (Array a b) where
    a == a'   =   aassocs a == aassocs a'

instance (Ix a, Ord [(a,b)], Ord b) => Ord (Array a b) where
    a <= a'   =   aassocs a <= aassocs a'

{-
instance  (Ix a, Text a, Text b) => Text (Array a b)  where
    showsPrec p a = showParen (p > 9) (
		    showString "array " .
		    shows (bounds a) . showChar ' ' .
		    shows (aassocs a)                  )
-}

--instance  (Ix a, Read a, Read b) => Read (Array a b)  where
--    readsPrec p = readParen (p > 9)
--	     (\r -> [(array b as, u) | ("array",s) <- lex r,
--				       (b,t)       <- reads s,
--				       (as,u)      <- reads t   ])

-----------------------------------------------------------------------------
