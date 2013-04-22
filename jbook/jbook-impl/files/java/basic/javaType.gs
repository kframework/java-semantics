-- --------------------------------------------------------------------
-- Java Types
-- --------------------------------------------------------------------

data JavaType = TJInt 
              | TJFloat
              | TJDouble
              | TJLong
              | TJByte
              | TJChar
              | TJShort
              | TJBoolean
              | TJRef(TypeName)
              | TJArray(JavaType)
              | TJNull	 
              | TJVoid
              | TJNoType

instance AsmTerm JavaType

instance Text JavaType where
  showsPrec _ TJInt         = showString "int"
  showsPrec _ TJFloat       = showString "float"
  showsPrec _ TJDouble      = showString "double"
  showsPrec _ TJShort       = showString "short"
  showsPrec _ TJByte        = showString "byte"
  showsPrec _ TJBoolean     = showString "boolean"
  showsPrec _ TJLong        = showString "long"
  showsPrec _ TJChar        = showString "char"
  showsPrec _ TJVoid        = showString "void"
  showsPrec _ (TJRef(c))    = showString c
  showsPrec _ (TJArray(t))  = shows t . showString "[]"
  showsPrec _ TJNull        = showString "null"   
  showsPrec _ TJNoType      = showString "not yet computed"
  showsPrec _ x             = error ("Text JavaType: " ++ show' x)


instance Ord JavaType where
  x <  y = genericCmp x y == -1
  x >  y = genericCmp x y == 1
  x <= y = genericCmp x y <= 0
  x >= y = genericCmp x y >= 0


showAddrType = error "showAddrType"

convertJavaType :: TypeName -> (Int,TypeName)
convertJavaType t = (1,t)