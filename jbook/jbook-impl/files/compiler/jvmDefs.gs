w2f :: Word -> Float
w2f(w) = typeCast (valueOf(w)) :: Float

mNm  :: CMeth a => a -> MNm
mNm = fst . mSig

javaMachine = False