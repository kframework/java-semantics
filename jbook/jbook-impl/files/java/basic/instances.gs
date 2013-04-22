instance TypeInterface TypeDec where
  typeNm(IfaceDec(_, n, _, _))    = n
  typeNm(ClassDec(_, n, _, _, _)) = n
 
  super(IfaceDec(_))             = Just(objectClass)
  super(ClassDec(_, _, s, _, _)) = s

  implements(IfaceDec(_, _, is, _))    = is
  implements(ClassDec(_, _, _, is, _)) = is

  members(IfaceDec(_, _, _, ms))    = ms
  members(ClassDec(_, _, _, _, ms)) = ms

  isClass(ClassDec(_)) = True
  isClass(_)           = False
  isIface(IfaceDec(_)) = True
  isIface(_)           = False


instance MethodInterface MemDec where
  methNm(MethDec(_,_,n,_,_,_,_))     = n
  methNm(FieldDec(_))                = error "methNm of field"
  argumentTypes(m)                   = map fst (arguments(m))
  argNames(m)                        = 
     if methNm(m) == "<clinit>" || Static `elem` javaModifiers(m) then
        map snd (arguments(m))
     else
        "this" : map snd  (arguments(m))
  javaReturnType(MethDec(_,t,_,_,_,_,_)) = t
  signature(m)                       = (methNm(m), argumentTypes(m))
  body(MethDec(_,_,_,_,body,_,_))    = body
  body(FieldDec(_))                  = error "body of field"
  throws(MethDec(_,_,_,_,_,ts,_))    = ts
  throws(FieldDec(_))                = error "throws of field"


instance FieldInterface MemDec where
  fieldNm(FieldDec(_,_,n,_))   = n
  fieldNm(MethDec(_))          = error "fieldNm of meth"
  fieldType(FieldDec(_,t,_,_)) = t
  fieldType(MethDec(_))        = error "fieldType of meth"
  initialExp(FieldDec(_,_,_,i))= i
  initialExp(MethDec(_))       = error "initialExp of meth"


instance MemberInterface MemDec where
  memberDecl = id
  classNm(_) = error "classNm of MemDec"


instance ModifierInterface TypeDec where
  javaModifiers(IfaceDec(ms, _, _, _))    = ms
  javaModifiers(ClassDec(ms, _, _, _, _)) = ms

instance ModifierInterface MemDec where
  javaModifiers(FieldDec(ms, _, _, _))     = ms
  javaModifiers(MethDec(ms, _, _, _, _,_,_)) = ms


instance Ord JavaVal where
  x <  y = genericCmp x y == -1
  x >  y = genericCmp x y == 1
  x <= y = genericCmp x y <= 0
  x >= y = genericCmp x y >= 0

instance Ord Abruption where
  x <  y = genericCmp x y == -1
  x >  y = genericCmp x y == 1
  x <= y = genericCmp x y <= 0
  x >= y = genericCmp x y >= 0


instance UndefValue JavaVal where
  undefValue = error "undefValue :: JavaVal"

instance UndefValue JavaType where
  undefValue = error "undefValue :: JavaType"

instance UndefValue Bool where
  undefValue = error "undefValue :: Bool"


instance AsmTerm TypeDec
instance AsmTerm JavaVal
instance AsmTerm (Maybe(JavaClass))
instance AsmTerm Abruption
instance AsmTerm MethRef
instance AsmTerm FieldRef


arguments(MethDec(_,_,_,as,_,_,_))  = as
arguments(_)  = error "arguments"


extendInitMeth(MethDec(_,_,_,_,_,_,b)) = b
extendInitMeth(_) = error "extendInitMeth"

ln(xs) = length(xs)-1
