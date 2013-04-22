data Long   = Long(Int)
data Double = Double(Float)

class Conv fromType toType where
  conv :: fromType -> toType

class SizeOf a where
  size :: a -> Int

class Argsize a where
  argSizes :: a -> [Int] 
  argSize  :: a -> Int
  argSize   = sum . argSizes


instance Conv a a where
  conv = id

type LabName = (String,[Nat])

valueOf :: (a,b) -> a
valueOf(v,_) = v


