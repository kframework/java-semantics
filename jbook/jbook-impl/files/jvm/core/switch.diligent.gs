switchDiligent =
   case switch of
     InitClass(c) -> if classState(c) == Referenced then
                       linkClass(c) else skip  
     _            -> skip 
