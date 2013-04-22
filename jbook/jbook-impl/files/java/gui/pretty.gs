instance Text MemDec where
  showsPrec _ (MethDec(ms,rt,n,args,body,_,_))
               = showString n . showString "("
               . showSepBy (",") (map showTypedArg args)
               . showString ")"
  showsPrec _ x = error ("Text MemDec: " ++ show' x)

instance Text JavaVal where
  showsPrec _ (TB True)   = showString "true"
  showsPrec _ (TB False)  = showString "false"
  showsPrec _ (TI i)      = shows i
  showsPrec _ (IS i)      = shows i
  showsPrec _ (IL i)      = shows i
  showsPrec _ (IB i)      = shows i
  showsPrec _ (TC c)      = shows c
  showsPrec _ (TF f)      = shows f
  showsPrec _ (FD f)      = shows f
  showsPrec _ (TR 0)      = showString "null"
  showsPrec _ (TR r)      = showString "heap(" . shows r . showString ")"
  showsPrec _ (TS s)      = shows (resubstNewline s)
  showsPrec _ (TArgList vs) = showString "[" 
                            . showSepBy (",") (map shows vs)
                            . showString "]"
  showsPrec _ (NoValue)   = showString "null"
  showsPrec _ x           = error ("Text JavaVal: " ++ show' x)


showTypedArg :: Arg -> ShowS
showTypedArg (t,name) = shows t . showString " " . showString name


instance (Pretty String m a,
          Pretty JavaType m a) => Pretty Arg m a where
  pretty (t,a) = pretty t <> pretty " " <> pretty a

instance (PrettyPrint m, 
          Pretty String m a,
          Pretty Modifier m a,
          Pretty (JavaType,Loc) m a,
          Pretty Stm m a) => Pretty (JavaClass,MemDec) m a where
  pretty (c,MethDec(ms, rt, m, args, body, _,_))
           = (pp_sepby (map pretty ms ++ [pretty rt]) " "
             <> pretty " " <> pretty c <> pretty "."
             <> pretty m
             <> pp_parenthesized (pp_sepby (map pretty args) ", ")
                 <> dw 0 (pretty " {"))
             $$ dw 0 (pretty "  "  <> prettyBlock body)
             $$ dw 0 (pretty "}")
  pretty x = pretty ("error: " ++ show' x)


instance (PrettyPrint m, Pretty String m a,
          Text c) => Pretty c m a where
  pretty t = pretty (show t)

instance (PrettyPrint m, Pretty String m a,
          Pretty Int m a,
          Pretty JavaVal m a,
          Pretty JavaType m a) => Pretty Stm m a where
-- Java i
  pretty = prettyPrec 0
  prettyPrec _ (Term (Lit v,_) [])      = pretty v
  prettyPrec i (Term (Una u,_) [e])     = puna u <> dw 0 (pp_parenthesized (pretty e))
  prettyPrec i (Term (Bin b,_) [e1,e2]) = pp_prec(i,prec(b)) $
                                  dw 0 (prettyPrec (precl(b)) e1) <> pretty " "
                                  <> pbin b <> pretty " "
                                  <> dw 1 (prettyPrec (precr(b)) e2)
  prettyPrec _ (Term (LocDec t n,_) []) = pretty t <> pretty " "
                                  <> pretty n <> pretty ";"
  prettyPrec _ (Term (LocDec t n,_) [e])= pretty t <> pretty " "
                                  <> pretty n <> pretty " = " 
                                  <> dw 0 (pretty e) <> pretty ";"
  prettyPrec _ (Term (LocAcc(l),_) [])  = pretty l
  prettyPrec _ (Term (LocInc(l),_) [])  = pretty l <> pretty "++"
  prettyPrec _ (Term (LocDecr(l),_) []) = pretty l <> pretty "--"
  prettyPrec i (Term (LocAss(l),_) [e]) = pp_prec (i,prec("=")) $
                                  pretty l <> pretty " = " <>
                                  dw 0 (pretty e)
  prettyPrec i (Term (IfExp,_) [c,t,e])   = pp_prec(i,prec("?")) $
                                  dw 0 (prettyPrec (prec("?")) c) <>
                                  pretty " ? " <>
                                  dw 1 (prettyPrec (prec("?")) t) <>
                                  pretty " : " <>
                                  dw 2 (prettyPrec (prec("?")) e)

  prettyPrec _ (Term (SSkip,_) [])        = pretty ""
  prettyPrec _ (Term (ExpStm,_) [e])  = dw 0 (pretty e) <> pretty ";"
  prettyPrec _ (Term (LabStm l,_)[s])   = pretty l <> pretty ": " <> 
                                  dw 0 (pretty s)
  prettyPrec _ (Term (Break l,_) [])    = pkeyword "break" <> pretty " " <>
                                  pretty l <> pretty ";"
  prettyPrec _ (Term (Continue l,_) [])    = pkeyword "continue" <> pretty " " <>
                                  pretty l <> pretty ";"
  prettyPrec _ (Term (IfStm,_) [c,t,Term (SSkip,_) []]) = 
                                  (pkeyword "if" <> pretty " " <>
                                   dw 0 (pp_parenthesized (pretty c)) <>
                                   dw 1 (pretty " {")) 
                                  $$ dw 1 (pretty "  " <> prettyBlock t)
                                  $$ (dw 1 (pretty "} ")) <> pkeyword "else"
                                     <> dw 2 (pretty " ;")
  prettyPrec _ (Term (IfStm,_) [c,t@(Term _ []),Term (SSkip,_) []])
                                = pkeyword "if "
                                   <> dw 0 (pp_parenthesized(pretty c))
                                   <> pretty " " <> dw 1 (pretty t)
  prettyPrec _ (Term (IfStm,_) [c,t,Term (SSkip,_) []])
                                = (pkeyword "if " 
                                     <> dw 0 (pp_parenthesized(pretty c)))
                                  $$ pretty " " <> dw 1 (pretty t)
  prettyPrec _ (Term (IfStm,_) [c,t,e])   = (pkeyword "if" <> pretty " " <>
                                   dw 0 (pp_parenthesized (pretty c)) <>
                                   dw 1 (pretty " {")) 
                                  $$ dw 1 (pretty "  " <> prettyBlock t)
                                  $$ (dw 1 (pretty "} ") <> pkeyword "else" <>
                                       dw 2 (pretty " {"))
                                  $$ dw 2 (pretty "  " <> prettyBlock e)
                                  $$ dw 2 (pretty "}")
  prettyPrec _ (Term (While,_) [e,stm])   = (pkeyword "while" <> pretty " " <>
                                   pp_parenthesized (dw 0 (pretty e)) <>
                                   dw 1 (pretty " {"))
                                  $$ dw 1 (pretty "  " <> prettyBlock stm)
                                  $$ dw 1 (pretty "}")
  prettyPrec _ (Term (Block,_) [])        = pp_text ""
  prettyPrec _ (Term (Block,_) ss)        = (pp_text "{ " 
                                    <> pp_vertical (dwBlock 0 (map pretty ss)))
                                  $$ pp_text "}"
  prettyPrec _ (Term (Val v,_) [])      = psemantic (show v)
  prettyPrec _ (Term (Norm,_) [])         = psemantic "norm"
  prettyPrec _ (Term (Abr(SBreak l),_) [])    = psemantic "break" <> pretty " " <>
                                  pretty l <> pretty ";"
  prettyPrec _ (Term (Abr(SContinue l),_) [])    = psemantic "continue" <> pretty " " <>
                                  pretty l <> pretty ";"
                                  
-- Java c
  prettyPrec _ (Term (ClassAcc(fref),_) [])  =
                                  pretty (showJavaFRef(fref))
  prettyPrec _ (Term (ClassAss(fref),_) [e]) =
                                  pretty (showJavaFRef(fref)) <> 
                                  pretty " = " <>
                                  dw 0 (pretty e)
  prettyPrec _ (Term (ClassInv(mref),_) [args])
                                = pretty (classNm(mref)) <> pretty "." <>
                                    pretty (methNm(mref)) <> dw 0 (pretty args)
  prettyPrec _ (Term (ArgList,_) args) =  pp_parenthesized(
                                             pp_sepby (dwBlock 0 (map pretty args)) ",")
  prettyPrec _ (Term (StaticInit,_) [s])  = (pkeyword "static" <> 
                                   dw 0 (pretty " {"))
                                   $$ dw 0 (pretty "  " <> prettyBlock s)
                                   $$ dw 0 (pretty "}")
  prettyPrec _ (Term (JavaReturn _,_) [])   = pkeyword "return" <> pretty ";"
  prettyPrec _ (Term (JavaReturn _,_) [e])  = pkeyword "return " <> pretty " "
                                     <> dw 0 (pretty e) 
                                     <> pretty ";"
  prettyPrec _ (Term (Abr(SReturn []),_) [])
                                = psemantic "return;"
  prettyPrec _ (Term (Abr(SReturn [v]),_) [])
                                = psemantic "return" <> pretty " " <>
                                  pretty v <> pretty ";"

-- Java o
  prettyPrec _ (Term (This,_) [])       = pkeyword "this"
  prettyPrec _ (Term (Instanceof(t),_) [e])
                                = dw 0 (pretty e) <> pretty " " <>
                                  pkeyword "instanceof" <> pretty " " <>
                                  pp_parenthesized (pretty t)
  prettyPrec _ (Term (Classcast(t),_) [e])
                                = pp_parenthesized (pretty t)
                                   <> dw 0 (pp_parenthesized (pretty e))
  prettyPrec _ (Term (Typecast(t),_) [e])
                                = pp_parenthesized (pretty t)
                                   <> dw 0 (pp_parenthesized (pretty e))
  prettyPrec _ (Term (FieldAcc(fr),_)   [r])   =
                                  dw 0 (pretty r) <> pretty "." <>
                                  pretty (fieldNm(fr))
  prettyPrec _ (Term (FieldAss(fref),_) [r,e]) =
                                  dw 0 (pretty r) <> pretty "." <>
                                  pretty (fieldNm(fref)) <> 
                                  pretty " = " <>
                                  dw 1 (pretty e)
  prettyPrec _ (Term (InstanceInv mr Super,_) [_,args]) =
                                  dw 0 (pkeyword "super") <> pretty "." <>
                                  pretty (methNm(mr)) <> dw 1 (pretty args)
  prettyPrec _ (Term (InstanceInv mr Special,_) [Term(NewClass c,_)[],args]) =
                                  dw 0 (pkeyword "new " <> pretty c) <>
                                  dw 1 (pretty args)
  prettyPrec _ (Term (InstanceInv mr ck,_) [r,args]) =
                                  dw 0 (pretty r) <> pretty "." <>
                                  pretty (methNm(mr)) <> dw 1 (pretty args)

-- Java e
  prettyPrec _ (Term (ThrowExc,_) [e])   = pkeyword "throw" <> pretty " " <>
                                  dw 0 (pretty e <> pretty ";")
  prettyPrec _ (Term (Try,_) (stm : stms))= (pkeyword "try" <> pretty " {")
                                  $$ (pretty "  " <> dw 0 (prettyBlock stm))
                                  $$ prettyCatch 1 stms
  prettyPrec _ (Term (Finally _,_) [stm,fin])= 
                                  dw 0 (pretty stm)
                                  $$ dw 1 (pkeyword "finally" <> pretty " {")
                                  $$ dw 1 (pretty "  " <> prettyBlock fin)
                                  $$ dw 1 (pretty "}")
  prettyPrec _ (Term (Abr(SExc(r)),_) [])    = psemantic "exc" <> pp_parenthesized (
                                    pretty r)
-- Java t
  prettyPrec _ (Term (SynBlock,_) [e,s]) = (pkeyword "synchronized" <> pretty " " <>
                                        dw 0 (pp_parenthesized (pretty e))
                                        <> pretty " {")
                                       $$ (pretty "  " <> dw 1 (prettyBlock s))
                                       $$ pretty "}"
-- Java Array
  prettyPrec _ (Term (ArrayAcc,_)[r,i]) = dw 0 (pretty r) <>
                                  dw 1 (pretty "[" <> pretty i <>
                                        pretty "]")
  prettyPrec _ (Term (ArrayAss,_)[r,i,e])= dw 0 (pretty r) <>
                                   dw 1 (pretty "[" <> pretty i <>
                                         pretty "]") <> pretty " = " <>
                                   dw 2 (pretty e)
  prettyPrec _ (Term (NewJavaArray,t)dims)= pkeyword "new" <> pretty " " <>
                                  pretty (makeArrayType (arrTypeDepth(t)-
                                                         length(dims)) 
                                                        (arrBasicType(t))) <>
                                  pretty " " <>
                                  prettyDims 0 dims
-- Java aux
  prettyPrec _ (Term (AccName(id),_) [])  = pretty id
  prettyPrec _ (Term (QualAcc(id),_) [e]) = dw 0 (pretty e) <> pretty "." <>
                                     pretty id
  prettyPrec _ (Term (AssName(id),_) [exp]) = pretty id <> pretty " = " <>
                                        dw 0 (pretty exp)
  prettyPrec _ (Term (QualAss(id),_) [e,exp])= dw 0 (pretty e) <> pretty "." <>
                                        pretty id <> pretty " = " <>
                                        dw 1 (pretty exp)
  prettyPrec _ (Term (Invoke m,_) args) 
                                = pretty m <> pp_parenthesized (
                                    pp_sepby (dwBlock 0 (map pretty args)) ",")
  prettyPrec _ (Term (QualInvoke m,_) ((Term(NewClass c,_)[]):args))
                                = dw 0 (pkeyword "new " <> pretty c) <>
                                    pp_parenthesized (
                                    pp_sepby (dwBlock 1 (map pretty args)) ",")
  prettyPrec _ (Term (QualInvoke m,_) (r:args))
                                = dw 0 (pretty r) <> pretty "." 
                                   <> pretty m <> pp_parenthesized (
                                    pp_sepby (dwBlock 1 (map pretty args)) ",")
  prettyPrec _ (Term (IncOperator,_) [e]) = dw 0 (pretty e) <> pretty "++"
  prettyPrec _ (Term (DecOperator,_) [e]) = dw 0 (pretty e) <> pretty "--"
  prettyPrec _ (Term (For _ _,_)[init,cond,upd,stm])
                                = (pkeyword "for" <> pretty " " <>
                                   pp_parenthesized (
                                        dw 0 (prettyExpList init) <> pretty ";" <>
                                        dw 1 (pretty cond) <> pretty ";" <>
                                        dw 2 (prettyExpList upd)) <>
                                   dw 3 (pretty " {"))
                                  $$ dw 3 (pretty "  " <> prettyBlock stm)
                                  $$ dw 3 (pretty "}")
  prettyPrec _ x = pretty ("error: " ++ show' x)


instance (PrettyPrint m, Pretty String m a) => Pretty JavaVal m a where
  pretty v = pretty (show v)
  pretty x = pretty ("error: " ++ show' x)


prettyCatch :: (Pretty String m a,
              Pretty Stm m a) => Int -> [Stm] -> Doc (m a)
prettyCatch i []                       =  pretty "}"
prettyCatch i (Term (Catch (c,l),_) [s] : ss) 
                                   =  (dw (i-1) (pretty "} ")
                                       <> (pkeyword "catch "
                                       <> pp_parenthesized (
                                            pretty c <> pretty " "
                                            <> pretty l
                                       ) <> dw i (pretty "{")
                                      ) $$ dw i (pretty "  " 
                                               <> prettyBlock s))
                                        $$ prettyCatch (i+1) ss


prettyBlock :: Pretty Stm m a => Stm -> Doc (m a)
prettyBlock (Term (Block,_) stms) = pp_vertical (dwBlock 0 (map pretty stms))
prettyBlock t                 = pretty t

prettyExpList :: Pretty Stm m a => Stm -> Doc (m a)
prettyExpList (Term (Block,_) []) = pretty " "
prettyExpList (Term (Block,_) stms) = pp_sepby (dwBlock 0 (map prettyLoc stms)) ","
prettyExpList t = prettyLoc t

prettyLoc :: Pretty Stm m a => Stm -> Doc (m a)
prettyLoc (Term (LocDec t n,_) []) = pretty t <> pretty " "
                                  <> pretty n
prettyLoc (Term (LocDec t n,_) [e])= pretty t <> pretty " "
                                  <> pretty n <> pretty " = " 
                                  <> dw 0 (pretty e)
prettyLoc t = pretty t


dwBlock :: PrettyOut a => Int -> [Doc a] -> [Doc a]
dwBlock n bs = [ dw i b | (i,b) <- zip [n..] bs ]

instance (Pretty String m a,
          PrettyPrint m)  => Pretty JavaType m a where
  pretty(TJRef(c))   = pretty c
  pretty(TJArray(t)) = pretty t <> pretty "[]"
  pretty(t) = pkeyword (show(t))

instance (Pretty String m a,
          PrettyPrint m)  => Pretty Modifier m a where
  pretty(t) = pkeyword (show(t))



class PrettyPrint m where
   psymbol, pkeyword, pred, pvarname, pnumber, pquote :: Pretty String m b
       => String -> Doc (m b)
   psemantic :: Pretty String m b => String -> Doc (m b)

instance PrettyPrint a where
   pkeyword   = cpretty [foreground "darkgreen"]
   pred       = cpretty [font courier, foreground "red"]
   pnumber v  = cpretty [font courier] v
   pvarname v = cpretty [font courier] v
   psymbol    = pretty
   pquote op  = pretty "`" <> pvarname op <> pretty "`"
   psemantic  = cpretty [foreground "blue"]


showPretty :: Pretty a [] Char => a -> String
showPretty(e) = layout 80 100 (pretty(e))

prettyDims :: (Pretty String m a,
               Pretty Exp m a) => Int -> [Exp] -> Doc (m a)
prettyDims i ([d]) = dw i (pretty "[" <> pretty d <>
                           pretty "]")
prettyDims i (d:ds)= dw i (pretty "[" <> pretty d <>
                           pretty "]") <> prettyDims (i+1) ds

pbin :: Pretty String m a => Bin -> Doc (m a)
pbin op = pretty op

puna :: Pretty String m a => Una -> Doc (m a)
puna op = pretty op

arrBasicType :: JavaType -> JavaType
arrBasicType(TJArray(t)) = arrBasicType(t)
arrBasicType(t) = t

arrTypeDepth :: JavaType -> Int
arrTypeDepth(TJArray(t)) = 1 + arrTypeDepth(t)
arrTypeDepth(_)         = 0

makeArrayType :: Int -> JavaType -> JavaType
makeArrayType 0 t = t
makeArrayType i t = makeArrayType (i-1) (TJArray(t))



prec("*")  = 8
prec("/")  = 8
prec("%")  = 8
prec("-")  = 7
prec("+")  = 7
prec("<")  = 5
prec(">")  = 5
prec("<=") = 5
prec(">=") = 5
prec("==") = 4
prec("!=") = 4
prec("&&") = 3
prec("||") = 2
prec("?")  = 1
prec("=")  = 0
prec(_)    =  0


precr(op) 
   | op `elem` ["&&","||"] = prec(op)
   | otherwise             = 1 + prec(op)

precl(op)
   | op `elem` ["*","+","-"] = prec(op)
   | otherwise               = 1 + prec(op)

pp_prec :: PrettyOut m => (Int, Int) -> Doc m -> Doc m
pp_prec (i,j) p 
  | i <= j    = p
  | otherwise = pp_parenthesized p
