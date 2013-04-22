switchVM__D = do                 
  switchVM__E
  case switch of
    InitClass(c) -> if classState(c) < Referenced then 
                      referenceClass(c) else skip   

    Result(res) -> do                               
      if mNm(meth) == "<cload>" then
         ldEnv(conv(reg#(0)),stringOf(conv(reg#(1)))) := conv(res!!(0))
        else skip 
    _ -> skip
trustfulVM__D = trustfulScheme__N(execVM__D, switchVM__D)  

trustfulVM__I = execVM__I(code( meth ) !!(pc))                  
switchVM__C = do                
  switchDiligent
  case switch of
    Call(meth, args) -> if not( isAbstract(meth) )  then do
                          pushFrame(meth, args)
                          switch := Noswitch  
                        else skip                                
    Result(res)   -> do if implicitCall(meth) then  
                          popFrame(0,[])
                         else                                  
                          popFrame(1,res)
                        switch := Noswitch 
    InitClass(c)   -> do if classState(c) == Linked then do
                           classState(c) := Initialized
                           forall f <-: staticFields(c) do
                             globals(c :/ f) := dflt(javaFieldType(c :/ f))

                           pushFrame(c:/ ("<clinit>",[]) ,[])

                           if c == object  ||  
                               initialized(just( super(c) ) ) then
                             switch        := Noswitch
                            else                                   
                             switch := InitClass(just( super(c) ) )  
                          else skip  
    _ -> skip
trustfulVM__C = trustfulScheme__C(execVM__C, switchVM__C)  

trustfulVM__O = trustfulScheme__C(execVM__O, switchVM__C)  

trustfulVM__E = trustfulScheme__C(execVM__E, switchVM__E)  

switchVM__E = do                
  switchVM__C
  case switch of
    Call(meth, args) -> if isAbstract(meth) then
                          raise("AbstractMethodError")  
                         else skip                                
    InitClass(c) -> if unusable(c) then 
                      raise("NoClassDefFoundError")  
                     else skip                                    
    Throw(r) -> if not( escapes(meth, pc, classOf (r)) )  then do
                      let exc = handler(meth, pc, classOf (r))
                      pc       := handle(exc)
                      opd      := [setReferenceType(conv(r))] 
                      switch   := Noswitch 
                else do                               
                 if mNm(meth) == "<clinit>" then
                    if not( (classOf(r) `runCompatibleClassClass` cerror ) )  then do
                      raise("ExceptionInInitializerError")
                      pc := -1 
                    else switch := ThrowInit(r)
                  else popFrame(0,[]) 
    ThrowInit(r) -> do let c = clName(meth)  

                       classState(c) := Unusable
                       popFrame(0,[])
                       if not( superInit(top(stack),c) )  then
                          switch := Throw(r)
                        else skip  
    _ -> skip
superInit((_,_,_,m),c) =
    mNm(m) == "<clinit>"  && just( super(clName(m)) )  == c
trustfulVM__N =                    
  trustfulScheme__N(execVM__N, switchVM__E)
