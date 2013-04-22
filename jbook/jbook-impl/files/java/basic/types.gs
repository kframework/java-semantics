type Ref = Int			     		             -- References

-- --------------------------------------------------------------------
-- Modifier
-- --------------------------------------------------------------------
data Modifier = Abstract
              | Static
              | Public
              | Protected
              | Private
              | Final
              | Native
-- not yet supported
              | Transient
              | Synchronized

instance AsmTerm Modifier

instance Text Modifier where
  showsPrec _ Abstract      = showString "abstract"
  showsPrec _ Public        = showString "public"
  showsPrec _ Protected     = showString "protected"
  showsPrec _ Private       = showString "private"
  showsPrec _ Final         = showString "final"
  showsPrec _ Native        = showString "native"
  showsPrec _ Static        = showString "static"
  showsPrec _ Transient     = showString "transient"
  showsPrec _ Synchronized  = showString "synchronized"
  showsPrec _ x = error ("Text Modifier: " ++ show' x)


javaMachine = True