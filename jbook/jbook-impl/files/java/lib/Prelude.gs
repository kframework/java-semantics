printf :: (String, [String]) -> String
printf (str, [])   = str
printf (str, arg:args) = 
    case break (=='%') str of
       (ls,_:rs) -> ls ++ arg ++ printf(rs,args)


transitive :: Eq (b,b) => (a -> (b,b), a -> a -> a) -> [a] -> [a]
transitive (extract,combine) set =
   let new  = nubBy (\a b -> extract a == extract b)
               [ combine ab bc
               | ab <- set,
                 bc <- set,
                 snd (extract ab) == fst (extract bc)
               ]
       new' = [ p | p <- new, extract p `notElem` map extract set ]
   in if null(new') then set
      else transitive(extract, combine) (set ++ new')


bigIntersect :: (Ord a, Eq a) => ({a},{{a}}) -> {a}
bigIntersect (max, Set([])) = max
bigIntersect (_,Set(xs)) = foldr1 intersect xs
 

push :: ([a],a) -> [a]
push (xs,x) = x : xs

top :: [a] -> a
top = head

pop :: [a] -> [a]
pop = tail

occurrences :: Eq a => (a,[a]) -> Int
occurrences (x,xs) = length(filter (==x) xs)
