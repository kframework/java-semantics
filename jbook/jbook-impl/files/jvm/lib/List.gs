data Ordering = LT | EQ | GT


compare :: Ord a => a -> a -> Ordering
compare x y | x > y     = GT
            | x < y     = LT
            | otherwise = EQ

sortBy          :: (a -> a -> Ordering) -> [a] -> [a]
sortBy cmp       = foldr (insertBy cmp) []

insertBy        :: (a -> a -> Ordering) -> a -> [a] -> [a]
insertBy cmp x []    = [x]
insertBy cmp x ys@(y:ys')
             = case cmp x y of
                GT -> y : insertBy cmp x ys'
                _  -> x : ys

groupBy                 :: (a -> a -> Bool) -> [a] -> [[a]]
groupBy eq []            = []
groupBy eq (x:xs)        = (x:ys) : groupBy eq zs
                           where (ys,zs) = span (eq x) xs

head' s [] = error s
head' s xs = head xs

seperate :: Eq a => a -> [a] -> [[a]]
seperate sym (x:xs) = let (as,bs) = break (==sym) xs
                      in  (x:as) : seperate sym bs
seperate sym []     = []



nubBy :: (a -> a -> Bool) -> [a] -> [a]
nubBy f []     = []
nubBy f (x:xs) = x : nubBy f (filter (not . f x) xs)
