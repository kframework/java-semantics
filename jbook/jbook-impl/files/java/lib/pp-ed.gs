-- --------------------------------------------------------------------------
-- pp-ed.gs: pretty printer instances for Editor ()
--
-- Ton Vullinghs,  April 97
-- --------------------------------------------------------------------------





instance PPSeq (Editor a) where
  a `ppseq` b = a `bind` \_ -> b

instance PrettyOut (Editor ()) where
  prettyOut      = void . write 
  cprettyOut cs  = void . writeCF cs

instance PrettyOut (Editor Tag) where
  prettyOut     = write
  cprettyOut cs = writeCF cs

