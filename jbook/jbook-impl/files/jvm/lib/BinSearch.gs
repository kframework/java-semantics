module BinSearch where


import Array
import List

type BinSort a   = Array Int a
type Mapping a b = Array Int (a,b)


binsortBy :: (a -> a -> Ordering) -> [a] -> BinSort a
binsortBy f xs = array (0,length xs) (zip [0..] (sortBy f xs))

binsort :: Ord a => [a] -> BinSort a
binsort xs = array (0, length xs) (zip [0..] (sort xs))


binlookupBy :: (a -> a -> Ordering) -> a -> BinSort a -> Maybe (Int,a)
binlookupBy compare search arr = binlookupBy' compare search (l,h-1) arr
  where (l,h) = bounds arr

binlookup :: Ord a => a -> BinSort a -> Maybe (Int,a)
binlookup search arr = binlookupBy' compare search (l,h-1) arr
  where (l,h) = bounds arr



mapping :: Ord a => [(a,b)] -> Mapping a b
mapping xs = binsortBy (\a b -> compare (fst a) (fst b)) xs

mappingBy :: (a -> a -> Ordering) -> [(a,b)] -> Mapping a b
mappingBy compare  xs = binsortBy (\a b -> compare (fst a) (fst b)) xs


maplookup :: Ord a => Mapping a b -> a -> Maybe b
maplookup mapping search = map (snd . snd) $
            binlookupBy (\a b -> compare (fst a) (fst b)) (search,undefined) mapping

maplookupBy :: (a -> a -> Ordering) -> Mapping a b -> a -> Maybe b
maplookupBy compare mapping search = map (snd . snd) $
            binlookupBy (\a b -> compare (fst a) (fst b)) (search, undefined) mapping


-- local definitions ------------------------------------------------------------

binlookupBy' :: (a -> a -> Ordering) -> a -> (Int,Int) -> BinSort a 
   -> Maybe (Int,a)
binlookupBy' compare search (low,high) arr 
   | high>=low = let middle = low + ((high - low + 1) `div` 2)
                     elem   = arr!middle
                 in if middle > high || middle < low
                    then error ("binlookupBy': index " ++ show middle)
                    else case compare search elem of
                      LT -> binlookupBy' compare search (low,middle-1) arr
                      EQ -> Just (middle, elem)
                      GT -> binlookupBy' compare search (middle+1,high) arr
   | otherwise = Nothing

