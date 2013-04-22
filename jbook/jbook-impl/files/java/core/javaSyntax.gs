-- Javai 

type Una = String               --- Unary Operators
type Bin = String               --- Binaray Operators

type Loc = String		-- Local Variables
type Lab = String		-- Label Names

-- Unanalyzed Java
type JavaClass  = String
type Iface      = String
type JavaField  = String
type JavaMeth   = String

-- Analyzed Java
type FieldRef   = Combine JavaClass JavaField
type MethRef    = Combine JavaClass MethSig
type MethSig    = (JavaMeth, [JavaType])

-- --------------------------------------------------------------------
-- TypeDec 
-- --------------------------------------------------------------------

-- Type Declarations
data TypeDec
  = IfaceDec([Modifier], Iface, [Iface], [MemDec])
  | ClassDec([Modifier], JavaClass, (Maybe JavaClass), [Iface], [MemDec])

class TypeInterface c where
  typeNm     :: c -> TypeName
  super      :: c -> Maybe(JavaClass)
  implements :: c -> [JavaClass]
  members    :: c -> [MemDec]
  isClass    :: c -> Bool
  isIface    :: c -> Bool

type Program = [TypeDec]

-- --------------------------------------------------------------------
-- MemberDec 
-- --------------------------------------------------------------------

-- Member Declarations
type Arg = (JavaType, Loc)

data MemDec
  = FieldDec([Modifier], JavaType, JavaField, Maybe(Exp))
  | MethDec ([Modifier], JavaType, JavaMeth, [Arg], Stm,{JavaClass},Bool)

isField(FieldDec(_)) = True
isField(_)           = False

isMethod(MethDec(_)) = True
isMethod(_)          = False

class MethodInterface c where
  methNm         :: c -> JavaMeth
  argumentTypes  :: c -> [JavaType]
  argNames       :: c -> [Loc]
  javaReturnType :: c -> JavaType
  signature      :: c -> MethSig
  body           :: c -> Stm
  throws         :: c -> {JavaClass}

class FieldInterface c where
  fieldNm    :: c -> JavaField
  fieldType  :: c -> JavaType
  initialExp :: c -> Maybe(Exp)

class MemberInterface c where
  memberDecl :: c -> MemDec
  classNm    :: c -> JavaClass

class ModifierInterface c where
  javaModifiers :: c -> [Modifier]

-- --------------------------------------------------------------------
-- Java Values
-- --------------------------------------------------------------------

data JavaVal = TB Bool | TI Int  | TR Ref | TF Float             --- Values
             | IB Int | IS Int | IL Int
             | FD Float | TC Char
             | TS String | NoValue
             | TArgList([JavaVal])

data JavaAbr = SBreak Lab      
             | SContinue Lab
             | SReturn ([JavaVal])
             | SExc Ref

litType(v) = case v of
  TB _  -> TJBoolean
  TI _  -> TJInt
  IB _  -> TJByte
  IS _  -> TJShort
  IL _  -> TJLong
  TC _  -> TJChar
  TF _  -> TJFloat
  FD _  -> TJDouble
  TR 0  -> TJNull
  TS _  -> TJRef(stringClass)
  _     -> error ("litType: " ++ show' v)

-- --------------------------------------------------------------------
-- Statements and Expressions
-- --------------------------------------------------------------------

type Exp = Term (JavaOp,JavaType)	-- Exp(ressions) and 
type Stm = Term (JavaOp,JavaType)	-- St(ate)m(ents) are implemented as terms 

typeOfExp :: Exp -> JavaType
typeOfExp(Term(InstanceInv (c:/(m,_)) Special,_)_) | m == "<init>" = TJRef(c)
typeOfExp(Term(op,t)_) = t

substituteJavaOp :: (JavaOp, Exp, Pos) -> Exp
substituteJavaOp (g, Term (Catch(x),ty) [t],is) 
  = Term (Catch(x),ty) [substituteJavaOp(g,t,is)]
substituteJavaOp (g, t,         []  ) = Term(g,typeOfExp(t))[]
substituteJavaOp (g, Term a ts, i:is) = 
  let (ls,rs) = splitAt i ts 
  in  Term a (ls ++ [substituteJavaOp(g, head(rs), is)] ++ tail rs)

data JavaOp

 --Javai
  --- expressions 

  --- operator		--- arguments
  = Lit JavaVal 
  | Una Una 		--- Exp
  | Bin Bin 		--- Exp Exp
  | LocDec JavaType Loc --- Exp      --- init value
  | LocAcc Loc
  | LocInc Loc
  | LocDecr Loc
  | LocAss Loc 		--- Exp
  | IfExp 		--- Exp Exp Exp
  --- statements
  | SSkip
  | ExpStm              --- Exp
  | LabStm Lab 		--- Stm
  | Break Lab
  | Continue Lab
  | IfStm 		--- Exp Stm Stm
  | While 		--- Exp Stm
  | Block 		--- [Stm]
  --- semantic values
  | Val JavaVal    
  | Abr JavaAbr
  | Norm          

--Javac
  --- expressions
  | StaticInit          ---  Stm
  | ArgList             --- [Exp]
  | ClassAcc FieldRef
  | ClassAss FieldRef 	--- Exp
  | ClassInv MethRef 	--- Exp
  --- statements
  | JavaReturn String	--- [Exp]  (depth)
  --- semantic values

--Javao 
  --- expressions
  | This
  | NewClass JavaClass  --- 
  | Instanceof JavaType     --- Exp  
  | Classcast JavaType      --- Exp
  | FieldAcc FieldRef 	--- Exp
  | FieldAss FieldRef 	--- Exp Exp
  | InstanceInv MethRef CallKind
  			--- Exp Exp

--Javae
  --- statements
  | ThrowExc            --- Exp 
  | Try 		--- Stm [Catch Type Loc Stm]
  | Finally {Loc}	--- Stm (Finally Stm)
  | Catch (JavaClass, Loc) 	--- Stm
  --- semantic values
--Javat
  | SynBlock            --- Exp Stm

--JavaArray
  | ArrayAcc               --- Exp Exp        --- Array Index
  | ArrayAss               --- Exp Exp Exp    --- Arrat Index Rhs
  | NewJavaArray           --- [Dims]

--Auxiliary
  | AccName(Name)      	--- 		--- Access
  | QualAcc(JavaField)	--- Exp		--- Qualified Access
  | AssName(Name)     	--- Exp		--- Assign
  | QualAss(JavaField) 	--- Exp Exp	--- Qualified Assign
  | Invoke(JavaMeth)   	--- [Exp]	--- Invoke
  | QualInvoke(JavaMeth)--- Exp:[Exp]	--- Qualified Invoke
  | Typecast JavaType 	--- Exp
  | IncOperator         --- Exp
  | DecOperator         --- Exp
  | For Lab Bool        --- ExpList Exp ExpList Stm --- init cond update body
                        --- Bool=True = init=local var def

data CallKind = Virtual | Special | Super

instance Eq JavaOp where
  (==) = genericEq

context :: (Stm, Pos) -> (Stm, Stm)
context(t,p) = contextterm(t,t,p)

contextterm :: (Stm,Stm, Pos) -> (Stm, Stm)
contextterm (tup,Term (Catch(_),_) [t],is)   = contextterm (tup,t,is)
contextterm (tup,t,[])                       = (t,tup)
contextterm (_,tup@(Term _ ts), i:is)        = contextterm (tup,ts!!i, is)

subterm :: (Stm,Pos) -> Stm
subterm (Term (Catch(_),_) [t],is) = subterm(t,is)
subterm (t,           [])          = t
subterm (Term a ts, i:is)          = subterm (ts!!i, is)

substitute :: (Stm, Stm, Pos) -> Stm
substitute (g, Term (Catch(x),ty) [t],is) = Term (Catch(x),ty) [substitute(g,t,is)]
substitute (g, t,         []  )           = g
substitute (g, Term a ts, i:is) = 
  let (ls,rs) = splitAt i ts 
  in  Term a (ls ++ [substitute(g, head(rs), is)] ++ tail rs)

-- --------------------------------------------------------------------
-- Classifiers on Terms (Syntax)

isUna(a) = case a of Una _ -> True; _ -> False
isBin(a) = case a of Bin _ -> True; _ -> False
isLocDec(a) = case a of LocDec _ _ -> True; _ -> False
isLocAss(a) = case a of LocAss _ -> True; _ -> False
isLocAcc(a) = case a of LocAcc _ -> True; _ -> False
isClassAss(a) = case a of ClassAss _ -> True; _ -> False
isClassAcc(a) = case a of ClassAss _ -> True; _ -> False
isClassInv(a) = case a of ClassInv _ -> True; _ -> False
isNew(a)      = case a of NewClass _ -> True; _ -> False
isFieldAss(a) = case a of FieldAss _ -> True; _-> False
isFieldAcc(a) = case a of FieldAcc _ -> True; _-> False
isInstanceInv(a) = case a of FieldAcc _ -> True; _-> False
isInstanceof(a) = case a of Instanceof _ -> True; _-> False
isClasscast(a) = case a of Classcast _ -> True; _-> False
isArrayAcc(a) = case a of ArrayAcc -> True; _ -> False
isArrayAss(a) = case a of ArrayAss -> True; _ -> False
isNewArray(a) = case a of NewJavaArray -> True; _ -> False

isConstant :: Exp -> Bool
isConstant(Term(Lit _,_)[]) = True
isConstant(_)               = False  

isExp(Term a _) = case fst a of 
--Javai
  Lit _         -> True
  Una _       	-> True
  Bin _       	-> True
  LocAcc _      -> True
  LocInc _      -> True
  LocDecr _     -> True
  LocAss _      -> True
  IfExp         -> True
--Javac
  ClassAcc _    -> True 
  ClassAss _  	-> True 
  ClassInv _	-> True
--Javao
  This          -> True
  NewClass _    -> True
  Instanceof _	-> True
  Classcast _   -> True
  FieldAcc _	-> True
  FieldAss _	-> True 
  InstanceInv _ _ -> True
--JavaArray
  ArrayAcc       -> True
  ArrayAss       -> True
  NewJavaArray   -> True
  Typecast _     -> True
  _              -> False

isStm (s@(Term a ss)) = case fst a of
--Javai
  SSkip         -> True
  LocDec _ _    -> True
  ExpStm      	-> True
  LabStm _	-> True
  Break _       -> True
  Continue _    -> True
  IfStm		-> True
  While	     	-> True
  Block	       	-> True
--Javac
  StaticInit    -> True
  JavaReturn _  -> True
--Javae
  ThrowExc  	-> True 
  Try   	-> True
  Catch _       -> isStm (ss!!0)
--Javat
  SynBlock      -> True
  For _ _       -> True
  _             -> isExp(s)

propagatesAbr(s@(Term a ss)) = case fst a of
  LabStm _   -> False
  Try        -> False
  Finally _  -> False
  StaticInit -> False
  SynBlock   -> False
  Abr _      -> False
  For _ _    -> False
  _          -> True

-- --------------------------------------------------------------------
-- Classifiers on Terms (Semantic Values)

isVal(Term a _) = case fst a of 
  Val _         ->  True
  _             ->  False

isString(TS _) = True
isString(_)    = False

isNorm(Term a ss) = case fst a of
  Norm         -> True
  Catch _      -> isNorm (ss!!0)
  _            -> False

isNotNorm = not . isNorm

isAbr(Term a _) = case fst a of 
  Abr _         ->  True
  _             ->  False

-- --------------------------------------------------------------------
-- Selectors/Inspectors on Terms (Semantic Values)

-- Javai
bool(Term(Val (TB b),_) _) = b

getVal(Term(Val v,_) _)       = v
getVal(Term(Abr(SReturn ([v])),_)_)= v

isTrue(Term(Val(TB b),_)_)  = b
isFalse(Term(Val(TB b),_)_) = not(b)

isZero(TI i)  = i == 0

-- Javao
getRef :: JavaVal -> Int
getRef(TR r) = r
getRef(_) = error "getRef"

isNull(Term(Val(TR r),_)_) = r == 0  
isNull(Term(Val(TS _),_)_) = False

isRef :: JavaVal -> Bool
isRef(TR _) = True
isRef(_)    = False

isRefType :: JavaType -> Bool
isRefType(TJArray(_)) = True
isRefType(TJRef(_))   = True
isRefType(_)          = False

-- Javae
loc(Term(Catch(t,x),_)_)= x
catchClass(Term(Catch(t,x),_)_) = t

exc(SExc r)	= r

-- all
res(Term (a,_) ss) = case a of
  Abr (SBreak _)      -> a
  Abr (SContinue _)   -> a
  Abr (SReturn _)     -> a
  Abr (SExc _)	-> a
  Norm          -> a
  _		-> error"No semantic value"

data Abruption = AbBreak Lab
--               | AbThrow JavaClass
               | AbNorm

-- --------------------------------------------------------------------
-- Predefine names
-- --------------------------------------------------------------------

objectClass  :: JavaClass
objectClass   = "Object"

cloneableInterface :: JavaClass
cloneableInterface = "Cloneable"

stringClass :: JavaClass
stringClass = "String"

printStreamClass :: JavaClass
printStreamClass = "PrintStream"

throwableClass :: JavaClass
throwableClass = "Throwable"

threadClass :: JavaClass
threadClass = "Thread"

runnableClass :: JavaClass
runnableClass = "Runnable"

classInit :: JavaClass -> MethRef
classInit(c) = c :/ ("<clinit>",[])

instanceInit :: (JavaClass,[JavaType]) -> MethRef
instanceInit(c,argTypes) = c :/ ("<init>",argTypes)

subStms :: Term a -> [Term a]
subStms(Term(_)xs) = xs

subTerms :: Term a -> [Term a]
subTerms(Term(_)xs) = xs

flattenBlock :: Stm -> [Stm]
flattenBlock (Term(Block,_)ss) = ss
flattenBlock e                 = [e]

buildBlock :: [Stm] -> Stm
buildBlock [e] = e
buildBlock es  = Term(Block,TJVoid)es

