execJava = do  execJava__I
               execJava__C
               execJava__O
               execJava__E
               execJava__Array
               execJava__T

execJava__I = do
  execJavaExp__I
  execJavaStm__I

yieldUp(result) = do
  restbody   := substituteJavaOp( result , restbody , up(pos) )
  pos        := up(pos)

yield(result) =
   restbody := substituteJavaOp( result , restbody , pos )

yieldTermUp(result) = do
  restbody   := substitute( result , restbody , up(pos) )
  pos    := up(pos)

yieldTerm(result) = do
  restbody := substitute( result , restbody , pos )

execJavaExp__I = case context( restbody , pos )  of

   (Term(Lit( NoValue ),_)[] ,_) -> fail(nullPointerException)
   (Term(Lit( lit ),_)[] ,_) | isString(lit) -> createStringObject(stringVal(lit))

   ( Term(Lit( lit ),_)[]  ,_)      -> yield(Val( lapply(lit) ) )

   ( Term(LocAcc( loc ), t )[]  ,_)     -> yield(Val( locals#(loc) ) )

   ( Term(Una( op ),_)[ exp ]  ,_)      -> pos := down( pos ,0)

   (_, Term(Una( op ),_)[ Term(Val( val ), t )[]  ]  ) | pos== down( up(pos) ,0)     -> yieldUp(Val( uapply( op , t , val )  ) )

   (_, Term(Bin( "&&" ),_)[ Term(Val( TB(False) ), _ )[]  ,  exp ]  ) | pos==  down( up(pos) ,0)     -> yieldUp(Val(TB(False)) )
   (_, Term(Bin( "||" ),_)[ Term(Val( TB(True) ), _ )[]  ,  exp ]  ) | pos==   down( up(pos) ,0)     -> yieldUp(Val(TB(True)) )

   ( Term(Bin( op ),_)[ exp1 , exp2 ]  ,_)       -> pos := down( pos ,0)

   (_, Term(Bin( op ),_)[ Term(Val( val ), _ )[]  , exp ]  ) | pos== down( up(pos) ,0)                 -> pos := down( up(pos) ,1)
   (_, Term(Bin( op ),_)[ Term(Val( val1 ), t1 )[]  , Term(Val( val2 ), t2 )[]  ]  ) | pos== down( up(pos) ,1)      -> if not( ( op   `elem` divMod && isZero(val2)) )  then
                                                     yieldUp(bapply( op ,(  t1 ,  t2 ),  val1 ,  val2 ) ) else skip
   ( Term(LocAss( loc ),_)[ exp ]  ,_)     -> pos := down( pos ,0)

   (_, Term(LocAss( loc ),_)[ Term(Val( val ), _ )[]  ]  ) | pos== down( up(pos) ,0)     -> do locals := locals +<< {(loc,val)} ;  yieldUp(Val( val ) )

   ( Term(LocInc( loc ), t )[]  ,_)  -> do
          let v = locals#(loc)
          yield(Val( v ) )
          locals := locals +<< {(loc,intFun(v)(intVal(v)+1))}
   ( Term(LocDecr( loc ), t )[]  ,_)  -> do
          let v = locals#(loc)
          yield(Val( v ) )
          locals := locals +<< {(loc,intFun(v)(intVal(v)-1))}

   ( Term(IfExp,_)[ exp0 , exp1 , exp2 ]  ,_)    -> pos := down( pos ,0)

   (_, Term(IfExp,_)[ Term(Val( TB(val) ), _ )[]  , exp1 , exp2 ]  ) | pos== down( up(pos) ,0)     -> if val then pos := down( up(pos) ,1)
                                              else pos := down( up(pos) ,2)

   (_, Term(IfExp,_)[ Term(Val( TB(True) ), _ )[]  , Term(Val( val ), _ )[]  , exp ]  ) | pos== down( up(pos) ,1)      -> yieldUp(Val( val ) )
   (_, Term(IfExp,_)[ Term(Val( TB(False) ), _ )[]  , exp , Term(Val( val ), _ )[]  ]  ) | pos== down( up(pos) ,2)     -> yieldUp(Val( val ) )
   _ -> skip

execJavaStm__I = case context( restbody , pos )  of

   ( Term(LocDec _  x ,_)[ exp ]  ,_)              -> pos  := down( pos ,0)
   (_, Term(LocDec _  x ,_)[ Term(Val( val ), _ )[]  ]  ) | pos== down( up(pos) ,0)     -> do
         locals := locals +<< {(x,val)}
         yieldUp(Norm )

   ( Term(SSkip,_)[]  ,_)    -> yield(Norm )
   ( Term(ExpStm,_)[ exp ]  ,_)               -> pos  := down( pos ,0)

   (_, Term(ExpStm,_)[ Term(Val( val ), _ )[]  ]  ) | pos== down( up(pos) ,0)      -> yieldUp(Norm )

   ( Term(Break( lab ),_)[]  ,_)       -> yield(Abr(SBreak( lab )) )
   ( Term(Continue( lab ),_)[]  ,_)    -> yield(Abr(SContinue( lab )) )
   ( Term(LabStm( lab ),_)[ stm ]  ,_)                 -> pos  := down( pos ,0)

   (_, Term(LabStm( lab ),_)[ Term( Norm  ,_)[]  ]  ) | pos== down( up(pos) ,0)      -> yieldUp(Norm )

   (_, Term(LabStm( lab ),_)[ Term( Abr(SBreak( lab__b ))  ,_)[]  ]  ) | pos== down( up(pos) ,0)     -> if lab ==lab__b then
                                                   yieldUp(Norm )
                                                else yieldUp(Abr(SBreak( lab__b )) )

   (_, Term(LabStm( lab ),_)[ Term( Abr(SContinue( lab__c ))  ,_)[]  ]  ) | pos== down( up(pos) ,0)     -> if lab ==lab__c then
                               yieldTerm(subterm(  body(meth)   , pos ) )
                                                   else yieldUp(Abr(SContinue( lab__c )) )

   ( Term(Abr( abr ),_)[]  ,_)  -> if pos /= firstPos && propagatesAbr(subterm( restbody , up(pos) ) ) then
                                     yieldUp(Abr( abr ) ) else skip

   -- block rule 1 - empty block
   ( Term(Block,_)[]  ,_)             -> yield(Norm )

   -- block rule 2 - first stm is unprocessed. Strange: bs should be one single statement. Where are the other ones?
   ( Term(Block,_) bs   ,_)    -> pos  := down( pos ,0)

   -- block rule 3 - array of Norm, all statements processed
   -- ln bs == len bs?
   -- It looks like blocks in a case statement in ASM are processed in their order. So if several cases could match,
   -- the first that matches will be chosen. This makes ASM a bit too imperative.
   ( Term( Norm  ,_)[]  , Term(Block,_) bs   ) | pos==down(up(pos), ln bs )    -> yieldUp(Norm )

   -- block rule 4 - array of Norm, followed by array of block stmts. Process the first block stmt.
   ( Term( Norm  ,_)[]  , Term(Block,_) bs   ) | pos==down(up(pos), i )    -> pos := down( up(pos) , i+1 )

   ( Term(Val( _ ), _ )[]  , Term(Block,_) bs   ) | pos==down(up(pos), ln bs )  -> yieldUp(Norm )

   ( Term(Val( _ ), _ )[]  , Term(Block,_) bs   ) | pos==down(up(pos), i )  -> pos := down( up(pos) , i+1 )

   ( Term(IfStm,_)[ exp , stm1 , stm2 ]  ,_)    -> pos := down( pos ,0)

   (_, Term(IfStm,_)[ Term(Val( TB(val) ), _ )[]  , stm1 , stm2 ]  ) | pos== down( up(pos) ,0)     -> if val then pos := down( up(pos) ,1)
                                                 else pos := down( up(pos) ,2)

   (_, Term(IfStm,_)[ Term(Val( TB(True) ), _ )[]  , Term( Norm  ,_)[]  , stm ]  ) | pos== down( up(pos) ,1)     -> yieldUp(Norm )
   (_, Term(IfStm,_)[ Term(Val( TB(False) ), _ )[]  , stm , Term( Norm  ,_)[]  ]  ) | pos== down( up(pos) ,2)     -> yieldUp(Norm )

   ( Term(While,_)[ exp ,  stm ]  ,_)       -> pos  := down( pos ,0)
   (_, Term(While,_)[ Term(Val( TB(val) ), _ )[]  ,  stm ]  ) | pos== down( up(pos) ,0)     -> if val then pos := down( up(pos) ,1)
                                           else yieldUp(Norm )

   (_, Term(While,_)[ Term(Val( TB(True) ), _ )[]  ,  Term( Norm  ,_)[]  ]  ) | pos== down( up(pos) ,1)     ->
                        yieldTermUp(subterm(  body(meth)   , up(pos) ) )

   ( Term(For  l  _, t )[ exps1 , exp , exps2 , stm ]  ,_)  -> pos  := down( pos ,0)
   (_, Term(For _ _,_)[ Term(Val( _ ), _ )[]  , exp , exps2 , stm ]  ) | pos== down( up(pos) ,0)   -> yield(Norm )
   (_, Term(For _ _,_)[ Term( Norm  ,_)[]  , exp , exps2 , stm ]  ) | pos== down( up(pos) ,0)   -> pos := down( up(pos) ,1)
   (_, Term(For _ _,_)[ Term( Norm  ,_)[]  , Term(Val( TB(val) ), _ )[]  , exps2 , stm ]  ) | pos== down( up(pos) ,1)   -> if val then pos := down( up(pos) ,3)
                                               else yieldUp(Norm )

   (_, Term(For _ _,_)[ Term( Norm  ,_)[]  , Term(Val( TB(True) ), _ )[]  , exps2 , Term( Norm  ,_)[]  ]  ) | pos== down( up(pos) ,3)   ->
                                                   pos := down( up(pos) ,2)
   (_, Term(For _ _,_)[ Term( Norm  ,_)[]  , Term(Val( TB(True) ), _ )[]  , Term(Val( _ ), _ )[]  , Term( Norm  ,_)[]  ]  ) | pos== down( up(pos) ,2)   -> yield(Norm )
   (_, Term(For _ _,_)[ Term( Norm  ,_)[]  , Term(Val( TB(True) ), _ )[]  , Term( Norm  ,_)[]  , Term( Norm  ,_)[]  ]  ) | pos== down( up(pos) ,2)   -> do
               pos := down( up(pos) ,1)
               let Term(For  l   i , t )[ exps1 , exp , exps2 , stm ]  = subterm(  body(meth)   , up(pos) )
               restbody := substitute( Term(For  l   i , t )[ Term( Norm  ,TJVoid)[]  , exp , exps2 , stm ]  , restbody , up(pos) )

   ( Term(LocDec _  x ,_)[]  ,_)        -> yield(Norm )
   _ -> skip
 where i = last(pos)

execJava__C = do
  execJavaExp__C
  execJavaStm__C

execJavaExp__C = case context( restbody , pos )  of
    ( Term(ClassAcc( c  :/  f ), t )[]  ,_)    -> if initialized(c) then yield(Val( globals (c :/ f) ) )
                              else initialize(c)

    ( Term(ClassAss( c  :/  f ), t )[ exp ]  ,_)    -> pos := down( pos ,0)

    (_, Term(ClassAss( c  :/  f ), t )[ Term(Val( val ), _ )[]  ]  ) | pos== down( up(pos) ,0)     -> if initialized(c) then do
                                             globals(c :/ f) := val
                                             yieldUp(Val( val ) )
                                            else initialize(c)

    ( Term(ClassInv( c  :/  ms ), t )[ exps ]  ,_)    -> pos := down( pos ,0)

    (_, Term(ClassInv( c  :/  ms ), t )[ Term(Val( TArgList(vals) ), _ )[]  ]  ) | pos== down( up(pos) ,0)     -> if initialized(c) then
                                                 invokeMeth( up(pos) ,( c  :/   ms ),  vals )
                                                         else initialize(c)

    ( Term(ArgList,TJVoid)[]  ,_)             -> yield(Val(TArgList([])) )
    ( Term(ArgList,TJVoid) es   ,_)    -> pos := down( pos , 0 )
    ( Term(Val( _ ), _ )[]  , Term(ArgList,TJVoid) es   ) | pos==down(up(pos), ln es )    ->
                                        yieldUp(Val(TArgList( map getVal es )) )
    ( Term(Val( _ ), _ )[]  , Term(ArgList,TJVoid) es   ) | pos==down(up(pos), i )    -> pos := down( up(pos) , i+1 )

    _ -> skip
 where i = last(pos)

initialize(c) = do
  if classState(c) == ClassLinked then do
    classState(c) := InProgress
    forall f <- staticFields(c) do
      globals(f) := defaultVal(fieldType(f))
    invokeMeth( pos ,(  c  :/   ("<clinit>",[]) ),  [] )
   else skip
  if classState(c) == ClassLinked then do
    initWait(c)     := {}
    initThread(c)   := thread
   else skip
  if classState(c) == InProgress && initThread(c) /= thread then do
    exec(thread)      := Waiting
    cont(thread)      := (frames, (meth, restbody, pos, locals))
    initWait(c)       := initWait(c) `union` { thread }
    waitObj(thread) := 0
   else skip
  if classState(c) == ClassUnusable then
    fail(noClassDefFoundErr)
   else skip

execJavaStm__C = case context( restbody , pos )  of
    ( Term(StaticInit,_)[ stm ]  ,_)  -> let c = classNm(meth) in
      if c == objectClass || initialized(just( super(c) ) ) then pos := down( pos ,0)
      else initialize(just( super(c) ) )

    (_, Term(StaticInit,_)[ Term( Abr(SReturn([]))  ,_)[]  ]  ) | pos== down( up(pos) ,0)   -> yieldUp(Abr(SReturn([])) )
    ( Term(JavaReturn tries,_)[ exp ]  ,_)              -> pos  := down( pos ,0)
    (_, Term(JavaReturn tries,_)[ Term(Val( val ), _ )[]  ]  ) | pos== down( up(pos) ,0)     -> yieldUp(Abr(SReturn([ val ])) )

    ( Term(JavaReturn _,_)[]  ,_)                            -> yield(Abr(SReturn([])) )
    (_, Term(LabStm( lab ),_)[ Term( Abr(SReturn([]))  ,_)[]  ]  ) | pos== down( up(pos) ,0)      -> yieldUp(Abr(SReturn([])) )

    (_, Term(LabStm( lab ),_)[ Term( Abr(SReturn([ val ]))  ,_)[]  ]  ) | pos== down( up(pos) ,0)      -> yieldUp(Abr(SReturn([ val ])) )

    ( Term( Abr(SReturn([]))  ,_)[]  ,_)    -> if pos == firstPos && not( null(frames) )  then
                                 sreturn (Norm )  else skip
    ( Term( Abr(SReturn([ val ]))  ,_)[]  ,_)    -> if pos == firstPos && not( null(frames) )  then
                                     sreturn (Val( val ) ) else skip
    (_, Term(ExpStm,_)[ Term( Norm  ,_)[]  ]  ) | pos== down( up(pos) ,0)   -> yieldUp(Norm )
    _ -> skip

invokeMeth( nextPos ,( c  :/  m ), values )
  | Native `elem` javaModifiers(c:/m) =
    invokeNative(c:/m, values)
  | otherwise = do
     frames   := push(frames,(meth, restbody, nextPos, locals))
     meth     := c:/m
     restbody     := body(c:/m)
     pos      := firstPos
     locals   := mkSet(zip( argNames( c :/ m )  )( values ) )

sreturn (result) = do
  let (oldMeth, oldPgm, oldPos, oldLocals) = top(frames)
  meth     := oldMeth
  pos      := oldPos
  locals   := oldLocals
  frames   := pop(frames)
  if methNm(meth) == "<clinit>" && isNorm(Term( result ,TJVoid)[] ) then do
    restbody                    := oldPgm
    classState(classNm(meth))   := ClassInitialized
   else if  methNm(meth) == "<init>" && isNorm(Term( result ,TJVoid)[] ) then do
    restbody := substituteJavaOp( Val( locals#("this") )  , oldPgm ,  oldPos )
   else
    restbody := substituteJavaOp( result , oldPgm ,  oldPos )

execJava__O = do
  execJavaExp__O

execJavaExp__O = case context( restbody , pos )  of
    ( Term(This,_)[]  ,_)   -> yield(Val( locals#("this") ) )

    ( Term(NewClass( c ),_)[]  ,_)  -> if initialized(c) then
                    create ref do
                       heap(ref) := HeapObject(c, {(f, defaultVal(fieldType(f)))
                                                  | f <- instanceFields(c)})
                       waitSet(ref)   := {}
                       locks(ref)     := 0
                       if c `classCompatible` threadClass then do
                         exec(ref)    := NotStarted
                         sync(ref)    := []
                         interruptedFlag(ref) := False
                        else skip
                       yield(Val( TR(ref) ) )
                   else initialize(c)
    ( Term(FieldAcc( c  :/  f ), t )[ exp ]  ,_)     -> pos := down( pos ,0)

    (_, Term(FieldAcc( c  :/  f ), t )[ Term(Val( TR(ref) ), _ )[]  ]  ) | pos== down( up(pos) ,0)     ->
      if ref /= 0  then yieldUp(Val( getField(ref,c :/ f) ) )

        else skip
    ( Term(FieldAss( c  :/  f ), t )[ exp1 , exp2 ]  ,_)    -> pos := down( pos ,0)

    (_, Term(FieldAss( c  :/  f ), t )[ Term(Val( ref ), _ )[]  , exp ]  ) | pos== down( up(pos) ,0)     -> pos := down( up(pos) ,1)

    (_, Term(FieldAss( c  :/  f ), t )[ Term(Val( TR(ref) ), _ )[]  , Term(Val( val ), _ )[]  ]  ) | pos== down( up(pos) ,1)     ->
     if ref /= 0  then do
           setField(ref, c :/ f, val)
           yieldUp(Val( val ) )
          else skip
    ( Term(Instanceof( c ),_)[ exp ]  ,_)     -> pos := down( pos ,0)
    (_, Term(Instanceof( c ),_)[ Term(Val( TR(ref) ), _ )[]  ]  ) | pos== down( up(pos) ,0)     ->
        yieldUp(Val( TB(ref /= 0  &&
        typeOfRef(ref) `compatible` c) ) )

    ( Term(Classcast( c ),_)[ exp ]  ,_)       -> pos := down( pos ,0)
    (_, Term(Classcast( c ),_)[ Term(Val( TR(ref) ), _ )[]  ]  ) | pos== down( up(pos) ,0)     ->
     if ref == 0  || typeOfRef(ref) `compatible` c then
         yieldUp(Val( TR(ref) ) )
          else skip
    ( Term(InstanceInv( c  :/  ms )  k , t )[ exp , exps ]  ,_)    -> pos := down( pos ,0)

    (_, Term(InstanceInv( c  :/  ms )  k , t )[ Term(Val( ref ), _ )[]  , exps ]  ) | pos== down( up(pos) ,0)     -> pos := down( up(pos) ,1)
    (_, Term(InstanceInv( c  :/  ms )  k , t )[ Term(Val( TR(ref) ), _ )[]  , Term(Val( TArgList(vals) ), _ )[]  ]  ) | pos== down( up(pos) ,1)     ->
      if ref /= 0  then
           let c' = case  k   of
                     Virtual      -> lookup(classOf(ref), c:/  ms  )
                     Super        -> lookup(just( super(classNm(meth)) ) , c :/  ms  )
                     Special      -> c in
           invokeMeth( up(pos) ,( c'  :/  ms ), [TR(ref)] ++ vals )
          else skip
    _ -> skip

getField(ref, f) = case heap(ref) of
   HeapObject(c, fields) -> fields#(f)

   HeapArray(_,vals) -> TI(length(vals))

setField(ref, f, val) =
   heap(ref) := HeapObject(c, fields +<< {(f,val)})

   where HeapObject(c, fields) = heap(ref)

execJava__E = do
  execJavaExp__E
  execJavaStm__E

fail(exc) = do
  restbody := substitute( Term(ThrowExc,TJVoid)[ Term(InstanceInv ( exc :/("<init>",[])) Special,TJVoid)[Term(NewClass( exc ),TJRef( exc ))[],Term(ArgList,TJVoid)[] ]  ]  , restbody , pos )
failUp(exc) = do
  restbody := substitute( Term(ThrowExc,TJVoid)[ Term(InstanceInv ( exc :/("<init>",[])) Special,TJVoid)[Term(NewClass( exc ),TJRef( exc ))[],Term(ArgList,TJVoid)[] ]  ]  , restbody , up(pos) )
  pos      := up(pos)

execJavaStm__E = case context( restbody , pos )  of
    ( Term(ThrowExc,_)[ exp ]  ,_)                 -> pos := down( pos ,0)
    (_, Term(ThrowExc,_)[ Term(Val( TR(ref) ), _ )[]  ]  ) | pos== down( up(pos) ,0)   -> if ref == 0  then
                                       failUp(nullPointerException)
                                     else
                                        yieldUp(Abr(SExc( ref )) )
    ( Term(Try,_)( stm : ss )  ,_)    -> pos := down( pos ,0)

    (_, Term(Try,_)( Term( Norm  ,_)[]  : ss )  ) | pos== down( up(pos) ,0)     -> yieldUp(Norm )

    -- The very complicated try rule. Seems to be really one rule here.
    (_, Term(Try,_)( Term( Abr(SExc( ref ))  ,_)[]  : ss )  ) | pos== down( up(pos) ,0)   ->
      if (any(\ c__j  ->  classOf(ref) `classCompatible` c__j )( map catchClass ss ))
           then do

        let j = fstCatchIdx(ref,ss)
        let x__j = loc(ss!!(j))

        pos      :=  down(up(pos),j+1)
        locals   := locals +<< {(x__j, TR(ref))}
      else yieldUp(Abr(SExc( ref )) )

    (_, Term(Try,_)( Term(Abr( abr ),_)[]  : ss )  ) | pos== down( up(pos) ,0)   -> yieldUp(Abr( abr ) )
    ( Term( Norm  ,_)[]  , Term(Try,_)( Term( Abr(SExc( ref ))  ,_)[]  : ss )  ) | pos==down(up(pos), i )    ->
      yieldUp(Norm )
    ( Term(Abr( abr ),_)[]  , Term(Try,_)( Term( Abr(SExc( ref ))  ,_)[]  : ss )  ) | pos==down(up(pos), i )    ->
      yieldUp(Abr( abr ) )
    ( Term(Finally _,TJVoid)[ stm1 , stm2 ]  ,_)                  -> pos := down( pos ,0)

    (_, Term(Finally _,TJVoid)[ Term( Norm  ,_)[]  , stm ]  ) | pos== down( up(pos) ,0)       -> pos := down( up(pos) ,1)
    (_, Term(Finally _,TJVoid)[ Term(Abr( abr ),_)[]  , stm ]  ) | pos== down( up(pos) ,0)     -> pos := down( up(pos) ,1)
    (_, Term(Finally _,TJVoid)[ s , Term( Norm  ,_)[]  ]  ) | pos== down( up(pos) ,1)         -> yieldUp(res(s))
    (_, Term(Finally _,TJVoid)[ s , Term(Abr( abr ),_)[]  ]  ) | pos== down( up(pos) ,1)       -> yieldUp(Abr( abr ) )
    (_, Term(LabStm( lab ),_)[ Term( Abr(SExc( ref ))  ,_)[]  ]  ) | pos== down( up(pos) ,0)     -> yieldUp(Abr(SExc( ref )) )
    (_, Term(StaticInit,_)[ Term( Abr(SExc( ref ))  ,_)[]  ]  ) | pos== down( up(pos) ,0)     ->
       if classOf(ref) `classCompatible` errorException then
          yieldUp(Abr(SExc( ref )) )
        else
          failUp(exceptionInInitializerError)

    (_, Term(For _ _,_)[ Term(Abr( abr ),_)[]  , exp , exps2 , stm ]  ) | pos== down( up(pos) ,0)   -> yieldUp(Abr( abr ) )
    (_, Term(For _ _,_)[ Term( Norm  ,_)[]  , Term(Abr( abr ),_)[]  , exps2 , stm ]  ) | pos== down( up(pos) ,1)   -> yieldUp(Abr( abr ) )
    (_, Term(For _ _,_)[ Term( Norm  ,_)[]  , Term(Val( TB(True) ), _ )[]  , Term(Abr( abr ),_)[]  , Term( Norm  ,_)[]  ]  ) | pos== down( up(pos) ,2)   -> yieldUp(Abr( abr ) )
    (_, Term(For _ _,_)[ Term( Norm  ,_)[]  , Term(Val( TB(True) ), _ )[]  , exps2 , Term( Abr(SExc( ref ))  ,_)[]  ]  ) | pos== down( up(pos) ,3)   -> yieldUp(Abr(SExc( ref )) )
    (_, Term(For _ _,_)[ Term( Norm  ,_)[]  , Term(Val( TB(True) ), _ )[]  , exps2 , Term( Abr(SBreak( lab__b ))  ,_)[]  ]  ) | pos== down( up(pos) ,3)   -> yieldUp(Abr(SBreak( lab__b )) )
    (_, Term(For  l  _,_)[ Term( Norm  ,_)[]  , Term(Val( TB(True) ), _ )[]  , exps2 , Term( Abr(SContinue( lab__c ))  ,_)[]  ]  ) | pos== down( up(pos) ,3)   ->
       if lab__c == l then
         yield(Norm )
       else yieldUp(Abr(SContinue( lab__c )) )

    ( Term( Abr(SExc( ref ))  ,_)[]  ,_)  -> if pos == firstPos && not( null(frames) )  then do
                              sreturn (Abr(SExc( ref )) )
                              if methNm(meth) == "<clinit>" then
                                classState(classNm(meth)) := ClassUnusable
                               else skip
                            else skip
    _ -> skip
 where i = last(pos)

execJavaExp__E = case context( restbody , pos )  of
    (_, Term(Bin( op ),_)[ Term(Val( val1 ), _ )[]  , Term(Val( val2 ), _ )[]  ]  ) | pos== down( up(pos) ,1)     -> if  op   `elem` divMod && isZero(val2) then
                                                  failUp(arithmeticException)                                     else skip
    (_, Term(FieldAcc( c  :/  f ), t )[ Term(Val( TR(ref) ), _ )[]  ]  ) | pos== down( up(pos) ,0)     ->
     if ref == 0  then failUp(nullPointerException)

     else skip
    (_, Term(FieldAss( c  :/  f ), t )[ Term(Val( TR(ref) ), _ )[]  , Term(Val( val ), _ )[]  ]  ) | pos== down( up(pos) ,1)     ->
     if ref == 0  then failUp(nullPointerException)

      else skip
    (_, Term(InstanceInv( c  :/  ms )  k , t )[ Term(Val( TR(ref) ), _ )[]  , Term(Val( vals ), _ )[]  ]  ) | pos== down( up(pos) ,1)     ->
     if ref == 0  then failUp(nullPointerException)

                                                             else skip
    (_, Term(Classcast( c ),_)[ Term(Val( TR(ref) ), _ )[]  ]  ) | pos== down( up(pos) ,0)     -> if ref /= 0  && typeOfRef(ref) `notCompatible` c then
                                              failUp(classCastException)                               else skip
    _ -> skip

syncObj :: Thread -> Ref
syncObj = initAssocs "syncObj" []

waitObj :: Thread -> Ref
waitObj = initAssocs "waitObj" []

execJava__T = do
  execJavaStm__T

releaseLock(phrase) = do
  let ( p :( rest ))  = sync(thread)
  sync(thread)    := rest
  locks(p)        := locks(p) - 1
  yieldUp(phrase)

killThread = do
  waitSet(thread)   := {}
  exec(thread)      := Dead
  forall q <-: waitSet(thread) do
    exec(q) := Notified

execJavaStm__T = case context( restbody , pos )  of
    ( Term(SynBlock,_)[ exp , stm ]  ,_)  -> pos := down( pos ,0)
    (_, Term(SynBlock,_)[ Term(Val( TR(ref) ), _ )[]  , stm ]  ) | pos== down( up(pos) ,0)   ->
      if ref == 0  then failUp(nullPointerException)

      else do
          if ref `elem` sync(thread) then do
             sync(thread)   := [ref] ++ sync(thread)
             locks(ref)     := locks(ref) + 1
             pos            := down( up(pos) ,1)
           else do
            exec(thread)      := Synchronizing
            syncObj(thread)   := ref
            cont(thread)      := (frames,(meth, restbody, down( up(pos) ,1) , locals))
    (_, Term(SynBlock,_)[ Term(Val( TR(ref) ), _ )[]  , Term( Norm  ,_)[]  ]  ) | pos== down( up(pos) ,1)     -> releaseLock(Norm )
    (_, Term(SynBlock,_)[ Term(Val( ref ), _ )[]  , Term(Abr( abr ),_)[]  ]  ) | pos== down( up(pos) ,1)     -> releaseLock(Abr( abr ) )

    (_, Term(StaticInit,_)[ Term(Abr( abr ),_)[]  ]  ) | pos== down( up(pos) ,0)   -> notifyThreadsWaitingForInitialization
    ( Term(Abr( abr ),_)[]  ,_)  -> if pos == firstPos && null(frames) then killThread else skip
    _ -> skip

notifyThreadsWaitingForInitialization = do
  let c = classNm(meth)
  initWait(c)     := {}
  initThread(c)   := asmDefault
  forall q <-: initWait(c) do
    exec(q) := Active

execJavaThread = do
  choose q <- threadList , runnable(q) do
   if q == thread && exec(q) == Active then
     execJava
    else do
     if exec(thread) == Active then
       cont(thread) := (frames,(meth, restbody, pos, locals))
      else skip
     thread := q
     run(q)

runnable(q) =
  case exec(q) of
   Active          -> True
   Synchronizing   -> locks(syncObj(q)) == 0
   Notified        -> locks(waitObj(q)) == 0
   _ -> False

run(q) = do
  switchCont(q)
  if exec(q) == Synchronizing then
    synchronize(q)
   else skip
  if exec(q) == Notified then do
    wakeup(q)
   else skip

switchCont(q) = do
  let (frames', (meth', restbody', pos', locals')) = cont(q)
  exec(q)     := Active
  meth        := meth'
  restbody    := restbody'
  pos         := pos'
  locals      := locals'
  frames      := frames'

synchronize(q) = do
  sync(q)             := [syncObj(q)] ++ sync(q)
  locks(syncObj(q))   := 1

wakeup(q) = do
   locks(waitObj(q)) := occurrences(waitObj(q),sync(q))

invokeNative(meth, values)

  | meth == stringLength
    = yieldUp(Val( TI(length(stringVal(values!!(0)))) ) )
  | meth == stringValueOfI
    = yieldUp(Lit(TS(show(intVal(values!!(0))))))
  | meth == stringValueOfC
    = yieldUp(Lit(TS(showChar(charVal(values!!(0)))"")))
  | meth == printStreamPrintS
    = do stdout := stringVal(values!!(1))
         yieldUp(Norm )
  | meth == printStreamPrintlnS
    = do stdout := stringVal(values!!(1)) ++ newline
         yieldUp(Norm )
  | meth == printStreamPrintI
    = do stdout := show(intVal(values!!(1)))
         yieldUp(Norm )
  | meth == printStreamPrintlnI ||
    meth == printStreamClass :/ ("println",[TJLong])
    = do stdout := show(intVal(values!!(1))) ++ newline
         yieldUp(Norm )
  | meth == printStreamClass :/ ("println",[TJChar])
    = do stdout := show(charVal(values!!(1))) ++ newline
         yieldUp(Norm )
  | meth == printStreamClass :/ ("println",[TJBoolean])
    = do stdout := show(boolVal(values!!(1))) ++ newline
         yieldUp(Norm )
  | meth == printStreamClass :/ ("println",[TJFloat]) ||
    meth == printStreamClass :/ ("println",[TJDouble])
    = do stdout := show(floatVal(values!!(1))) ++ newline
         yieldUp(Norm )
  | meth == objectToString
    = yieldUp(Lit(TS(classOf(refVal(values!!(0))))))
  | meth == objectEquals
    = yieldUp(Val( TB(values!!(0)==values!!(1)) ) )
  | meth == objectClone
    = do let r = refVal(values!!(0))
         if classOf(r) `classCompatible` cloneableInterface then do
           create r' do
             heap(r')      := heap(r)
             waitSet(r')   := {}
             locks(r')     := 0
             yieldUp(Val( TR(r') ) )
          else
           failUp(cloneNotSupportedException)

  | meth == threadStart           = startThread(refVal(values!!(0)))
  | meth == threadInterrupt       = interrupt(refVal(values!!(0)))
  | meth == threadInterrupted     = interrupted
  | meth == threadIsInterrupted   = isInterrupted(refVal(values!!(0)))
  | meth == objectWait            = mWaitFor(refVal(values!!(0)))
  | meth == objectNotify          = notify(refVal(values!!(0)))
  | meth == objectNotifyAll       = notifyAll(refVal(values!!(0)))
  | otherwise = error ("unknown native method " ++ showJavaMRef(meth))

startThread(ref) = do
   if exec(ref) /= NotStarted then
     fail(illegalThreadStateException)
    else do
     let q      = getField(ref,threadClass :/ "target")
         meth   = lookup(classOf(getRef(q)),runnableClass:/threadRun):/threadRun
     exec(ref) := Active
     cont(ref) := ([],(meth,body(meth),firstPos,{("this",q)}))
     yieldUp(Norm )

interrupt(q) = do
 yieldUp(Norm )
 if exec(q) == Waiting && not( classInitialization(q) )  then do
   let (frames', (meth', restbody', pos', locals')) = cont(q)
   let fail   = substitute( Term(ThrowExc,TJVoid)[ Term(InstanceInv ( interruptedException :/("<init>",[])) Special,TJVoid)[Term(NewClass( interruptedException ),TJRef( interruptedException ))[],Term(ArgList,TJVoid)[] ]  ]  , restbody' , pos' )
   let ref    = waitObj(q)
   waitSet(ref)   := waitSet(ref) `difference` {q}
   exec(q)        := Notified
   cont(q)        := (frames', (meth', fail, pos', locals'))
   interruptedFlag(q) := False
  else do
   interruptedFlag(q) := True

classInitialization(q) =
  q `elem` ran(initThread) || q `elem` bigUnion(ran(initWait))

interrupted = do
  if interruptedFlag(thread) then do
    interruptedFlag(thread) := False
    yield(Val(TB(True)) )
   else
    yield(Val(TB(False)) )

isInterrupted(q) =
  if interruptedFlag(q) then
    yieldUp(Val(TB(True)) )
   else
    yieldUp(Val(TB(False)) )

mWaitFor(ref) = do
   if ref `notElem` sync(thread) then
     fail(illegalMonitorStateException)
    else do
     let ret = substituteJavaOp( Norm  , restbody , up(pos) )
     waitSet(ref)      := waitSet(ref) `union` { thread }
     locks(ref)        := 0
     exec(thread)      := Waiting
     waitObj(thread)   := ref
     cont(thread)      := (frames, (meth, ret, up(pos), locals))
     yieldUp(Norm )

notify(ref) = do
   if ref `notElem` sync(thread) then
     fail(illegalMonitorStateException)
    else do
     yieldUp(Norm )
     choose q <-: waitSet(ref) do
      waitSet(ref)   := waitSet(ref) `difference` {q}
      exec(q)        := Notified

notifyAll(ref) = do
   if ref `notElem` sync(thread) then
     fail(illegalMonitorStateException)
    else do
     waitSet(ref) := {}
     yieldUp(Norm )
     forall q <-: waitSet(ref) do
      exec(q) := Notified

execJava__Array = case context( restbody , pos )  of
    ( Term(ArrayAcc, t )[ exp1 , exp2 ]  ,_)     -> pos := down( pos ,0)
    (_, Term(ArrayAcc, t )[ Term(Val( ref ), _ )[]  , exp ]  ) | pos== down( up(pos) ,0)     -> pos := down( up(pos) ,1)
    (_, Term(ArrayAcc, t )[ Term(Val( TR(ref) ), _ )[]  , Term(Val( TI(i) ), _ )[]  ]  ) | pos== down( up(pos) ,1)     -> if ref == 0  then fail(nullPointerException)
                                                        else if  i < 0 || i >= arraySize(ref) then
                                                         fail(arrayIndexOutOfBoundsException)
                                                        else
                                                          yieldUp(Val( getElement(ref, i) ) )
    ( Term(ArrayAss, t )[ exp1 , exp2 , exp3 ]  ,_)       -> pos := down( pos ,0)

    (_, Term(ArrayAss, t )[ Term(Val( ref ), _ )[]  , exp2 , exp3 ]  ) | pos== down( up(pos) ,0)     -> pos := down( up(pos) ,1)

    (_, Term(ArrayAss, t )[ Term(Val( ref ), _ )[]  , Term(Val( i ), _ )[]  , exp3 ]  ) | pos== down( up(pos) ,1)     -> pos := down( up(pos) ,2)
    (_, Term(ArrayAss, t )[ Term(Val( TR(ref) ), _ )[]  , Term(Val( TI(i) ), _ )[]  , Term(Val( val ), _ )[]  ]  ) | pos== down( up(pos) ,2)     ->
       if ref == 0  then
         fail(nullPointerException)
       else if  i < 0 || i >= arraySize(ref) then
         fail(arrayIndexOutOfBoundsException)
       else if  isRef(val) && typeOfRef(getRef(val)) `notCompatible` c then do
           fail(arrayStoreException)
       else do
         setElement(ref,i,val)
         yieldUp(Val( val ) )
       where HeapArray(c,_) = heap(ref)
    ( Term(NewJavaArray, t ) dims   ,_)  -> pos := down( pos , 0 )
    ( Term(Val( _ ), _ )[]  , Term(NewJavaArray, t ) dims   ) | pos==down(up(pos), ln dims )  ->
        if (any( ((<0) . intVal . getVal) )( dims ))  then
          fail(negativeArraySizeException)
        else do

         rlet ref ::= createArray(t,length(dims),[ intVal(getVal(d)) | d <- dims])

         yieldUp(Val( ref ) )
    ( Term(Val( _ ), _ )[]  , Term(NewJavaArray, t ) dims   ) | pos==down(up(pos), i )  -> pos := down( up(pos) , i+1 )
    _ -> skip
 where i = last(pos)

createArray :: (JavaType, Nat, [Nat]) -> Rule JavaVal
createArray (TJArray(t),d,( i :( is )) ) = create ref do
   waitSet(ref) := {}
   locks(ref)   := 0
   if d == 1 then do
     heap(ref) := HeapArray(t,take ( i ) (  repeat(defaultVal(t)) ) )
     result(TR(ref))
    else do
     rlet elems ::= rforall x <- [1..i] do
       rlet r ::= createArray(t,d-1,is)
       result(r)
     heap(ref) := HeapArray(t,elems)
     result(TR(ref))

getElement(ref, i) = elems!!(i)
  where HeapArray(t,elems) = heap(ref)

setElement(ref, i, e) =
   heap(ref) := HeapArray(t, take ( i ) ( elems )  ++ [e] ++ drop ( i+1 ) ( elems ) )
  where HeapArray(t,elems) = heap(ref)

arraySize(ref) = length(elems)
  where HeapArray(t,elems) = heap(ref)

createStringObject :: String -> Rule()
createStringObject(str) = do
   case [ r  | (r,HeapString(s)) <- assocs(heap), s == str ] of
    [] -> create r do
            heap(r)    := HeapString(str)
            waitSet(r) := {}
            locks(r)   := 0
            yield(Val( TR(r) ) )
    [r] -> yield(Val( TR(r) ) )

threadList =
  let ls = expr2list(dom(exec))
  in  copy (5*length(ls)) thread ++ ls

synchronizing(q,ref) =
   exec(q) == Synchronizing && syncObj(q) == ref
waiting(q,ref) =
   exec(q) == Waiting && waitObj(q) == ref
notified(q,ref) =
   exec(q) == Notified && waitObj(q) == ref
