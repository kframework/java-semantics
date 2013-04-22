-- is used as a suppressed paramater during type check and execution!

typeDec :: JavaClass -> TypeDec
typeDec(n) = pgm(n)


{-
abruptions :: Stm -> { Abruption }
abruptions(e) = case e of
   Term(LabStm l,_)[s]      -> let abs = abruptions(s) in
                               if AbBreak l `elem` abs then
                                 { AbNorm } `union`
                                   (abs `difference` { AbBreak l })
                                else abs
   Term(Break l,_)[]        -> { AbBreak l }
   Term(Continue _,_)[]     -> { }
   Term(IfStm,_)[c,t,e]     -> abruptions(t) `union` abruptions(e)
   Term(While,_)[c,e]       -> if constBool False (c) then { AbNorm }
                               else if constBool True (c) then
                                  abruptions(e) `difference` { AbNorm }
                               else
                                  abruptions(e) `union` { AbNorm }
   Term(Block,_)[]          -> { AbNorm }
   Term(Block,_)(s:ss)      -> let abs = abruptions(s) in
                               if AbNorm `elem` abs then
                                 (abs `difference` { AbNorm }) `union`
                                 abruptions(Term(Block,TJVoid)ss)
                                else abs
   Term(StaticInit,_)[s]     -> abruptions(s)
   Term(JavaReturn,_)_       -> { }
   Term(ThrowExc,_)_  -> { }
   Term(Finally,_)[s,f]      -> let abs = abruptions(f) in
                                if AbNorm `elem` abs then
                                   abruptions(s) `union` 
                                     (abs `difference` { AbNorm })
                                else abs
   Term(Try,_)(s:ss) ->
       let abs      = abruptions(s)
           catchers = zip [1..] [ (c,s) | Term (Catch(c,_),_)[s] <- ss ]
           cClasses = [ (i,c) | (i,(c,_)) <- catchers ]
           cabs     = bigUnion({ abruptions(s) 
                               | (i,(c,s)) <- catchers, reachable(i,c)}) 
           reachable(i,c) = and [ j>=i || not(c `compatible` c')
                                | (j,c') <- cClasses ]
       in abs `union` cabs
   Term(SynBlock,_)[s]    -> abruptions(s)
   Term(_)_               -> { AbNorm }
-}


constBool :: Bool -> Exp -> Bool
constBool b (Term(Lit(TB(b')),_)[]) = b == b'
constBool b (Term(Una("!"),_)[e])   = constBool (not b) e
constBool b (Term(IfExp,_)[c,t,e])  = if constBool True c then 
                                          constBool b t
                                       else if constBool False c then
                                          constBool b e
                                       else False
constBool True (Term(Bin("&&"),_)[e1,e2]) = constBool True e1 &&
                                            constBool True e2
constBool False (Term(Bin("&&"),_)[e1,e2]) = constBool False e1 ||
                                             constBool True e1 &&
                                             constBool False e2
constBool True (Term(Bin("||"),_)[e1,e2]) = constBool True e1 ||
                                            constBool False e1 &&
                                            constBool True e2
constBool False (Term(Bin("||"),_)[e1,e2]) = constBool False e1 &&
                                             constBool False e2
constBool b (_) = False


class Accessible a where
  accessible :: (JavaClass,a) -> Bool

instance Accessible (JavaClass,[Modifier]) where
  accessible(c,(c',mods)) =
      Private `elem` mods && c == c' ||
      Private `notElem` mods ||
      Public `elem` mods ||
      Protected `elem` mods && c `compatible` c'

