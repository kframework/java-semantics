linkClass(c) = do                                   
   let classes = {just( super(c) ) } `union` implements(c)
   if c == object  || (all (\( c' ) ->  classState(c')>=Linked ) ( classes ))  then do
      classState(c) := Linked
      prepareClass(c)
    else if  not( cyclicInheritance(c) )  then
     choose c' <-: classes, classState(c')==Referenced do
      linkClass(c')
    else do
     stdout := "Cyclic Inheritance: " ++ cNm(c)
     halt   := True

