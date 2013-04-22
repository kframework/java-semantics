data Error a = Ok a 
             | Error String

instance Functor Error where
  map f (Error s) = Error s
  map f (Ok a)    = Ok (f a)

instance Monad Error where
  result = Ok
  Error s `bind` f = Error s
  Ok a `bind` f    = f a


class ErrorMonad m where
  mraise :: String -> m a

instance ErrorMonad Error where
  mraise = Error


data StateM m s a = StateM (s -> m (s, a))

instance Monad m => Functor (StateM m s) where
  map f (StateM g) = StateM (\s -> do (s',a') <- g s
                                      result (s', f a'))

instance Monad m => Monad (StateM m s) where
  result a = StateM (\s -> result (s,a))
  StateM g `bind` f = StateM (\s -> do (s',a) <- g s
                                       let StateM f' = f a
                                       f' s')

instance ErrorMonad m => ErrorMonad (StateM m s) where
  mraise msg = StateM (\_ -> mraise msg)

instance ErrorMonad m => Monad0 m where
  zero = mraise "pattern matching failed"
                                        


data SRW s a = SRW (s -> (s,a))

instance Functor (SRW s) where
  map f (SRW g) = SRW (\s -> let (s',a') = g s
                             in  (s', f a'))

instance Monad (SRW s) where
  result a = SRW (\s -> (s,a))
  SRW g `bind` f = SRW (\s -> let (s',a')  = g s
                                  SRW f' = f a'
                              in  f' s')
                                      

class StateMonad m s where
  update :: (s -> s) -> m s s

instance StateMonad SRW s where
  update f = SRW (\s -> (f s, s))

instance Monad m => StateMonad (StateM m) s where
  update f = StateM (\s -> result (f s,s))
