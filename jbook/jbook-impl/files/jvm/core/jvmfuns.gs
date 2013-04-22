retSize :: RetType a => a -> Int
retSize(ts) = length(returnType(ts))             

w2f :: Word -> Float
w2f(w) = typeCast (valueOf(w)) :: Float          

mNm  :: CMeth a => a -> MNm
mNm = fst . mSig         

methods :: ClassFile -> MethTab
methods (CFile(_, _, _, _, _, _, _, ms)) = ms             

fields :: ClassFile -> FieldTab
fields (CFile(_, _, _, _, _, _, fs, _)) = fs             

cMNms :: ClassFile -> {MNm}
cMNms = setmap (fst . fst) . cMs            

cMs :: ClassFile -> MethTab
cMs (CFile(_, _, _, _, _, _, _, mtab)) = mtab          
