instance SizeOf FRef where
  size(c :/ f) = size(t)
    where CFile(_, _, _, _, _, _, fields, _) = cEnv(c)
          FDec(_, t)                      = fields # f

--------------------------------------------------------------------------

instance Types Class where
  types (c) = [conv(VTClass(c))]

instance Types Word where
  types(w) = [typeOfWord(w)]

instance Types [Word] where
  types = map typeOfWord

mTypeClass :: Class -> [VerifyType]
mTypeClass(c) = types(c)