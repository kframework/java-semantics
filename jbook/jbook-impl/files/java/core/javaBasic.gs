up :: Pos -> Pos        

data Term a = Term a [Term a]

instance Functor Term where
  map f (Term a ts) = Term (f a) (map (map f) ts)

foldTerm :: (a -> [b] -> b) -> Term a -> b
foldTerm f (Term a rs) = f a (map (foldTerm f) rs)

type Pos = [Int]

firstPos :: Pos
firstPos  = []

--lastPos :: Pos
--lastPos  = []

up [] = []
up ds = init(ds)

down      :: (Pos,Nat) -> Pos
down(ds,d) = ds++[d]

