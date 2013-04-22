check__D :: MRef -> Bool
check__D(c:/m) =              
  c == classLoader  && m `elem` { findLoadedClass , findSystemClass ,
                                  resolveClass , defineClassMethod  } || 

  c == classLoader  && m == getSystemClassLoader ||

  c:/m == cclass  :/ newInstance  ||
  check__N(c:/m)
