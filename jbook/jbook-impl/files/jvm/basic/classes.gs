infix 4 `hasSuffix`

class ArgTypes a where
  argTypes :: a -> [VerifyType]

class RetType a where
  returnType :: a -> [VerifyType]

class Types a where
  types :: a -> [VerifyType]

class Dflt t where
  dflt:: t -> Val

class CMeth a where
  mSig :: a -> MSig

class ClassName a where
  cNm :: a -> CNm

class ClassLoader a where
  cLd :: a -> Ld


class Compatibles c where
  compatibles :: c -> {c}


class HasSuffix a b where
  hasSuffix  :: a -> b -> Bool

class Concat a b where
  (+++) :: [a] -> [b] -> [a]

instance Concat a a where
  (+++) = (++)

instance Concat [a] a where
  as +++ bs = as ++ map (\x -> [x]) bs

instance Ord a => Concat {a} a where
  as +++ bs = as ++ map (\x -> {x}) bs
