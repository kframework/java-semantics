type Word = (Int, WordType)          

type Offset   = Nat                
type Size     = Nat           
type RegNo = Nat               

type MSig = (MNm, [ JavaType ] )          

makeRegs(args) = { (l,v) | (l,v) <- (zip ( [0..length(args)-1] ) ( args ))  }  

type Ld = Ref         
type Class  = (Ld, Name)            
type Pc = Nat            

type Register t = Map ( RegNo ) (  t )               
type Opd t      = [ t ]                      

type ABSTRACT   = String
type Dimension  = Int                   

type CNm = ABSTRACT            
type FNm = ABSTRACT            
type MNm = ABSTRACT            

type Fun = ABSTRACT              
type Relation = ABSTRACT              

type PathName  = String                             
type ClassPath = {PathName}                          

data VTRefType                                  
      = VTNull
      | VTClass(Class)
      | VTArray([VerifyType])
      | VTAddr

data VerifyType                      
     = VTInt                  
     | VTLowLong                  
     | VTHighLong                  
     | VTFloat                  
     | VTLowDouble                  
     | VTHighDouble                  

     | VTReference(VTRefType)

     | VTNew(Class,Pc)
     | VTInit                     
     | VTUnusable                   

                   | VTReferenceSet({ VTRefType } )

                   | VTRetAddr(Pc)             

data WordType = WTInt                                   
              | WTLowLong                     
              | WTHighLong                     
              | WTFloat                     
              | WTLowDouble                     
              | WTHighDouble                
                 | WTReference                
                 | WTRetAddr(Pc)              
   | WTInternal String

data ArrayMoveType = AMTByte | AMTShort | AMTChar | AMTInt |
                     AMTLong |  AMTFloat  | AMTDouble | AMTObject  

data MoveType = MTInt  | MTLong |  MTFloat  | MTDouble                 

            | MTvoid
                 | MTAddr           

type Ref  = Int                       

typeTJVT :: JavaType -> [VerifyType]
typeTJVT(TJInt)       = [VTInt]
typeTJVT(TJFloat)     = [VTFloat]
typeTJVT(TJDouble)    = [VTLowDouble, VTHighDouble]
typeTJVT(TJLong)      = [VTLowLong,VTHighLong]
typeTJVT(TJByte)      = [VTInt]
typeTJVT(TJChar)      = [VTInt]
typeTJVT(TJShort)     = [VTInt]
typeTJVT(TJBoolean)   = [VTInt]
typeTJVT(TJRef(t))    = [VTReference(VTClass(convertJavaType(t)))]
typeTJVT(TJArray(t))  = [VTReference(VTArray(typeTJVT(t)))]
typeTJVT(TJVoid)      = []
typeTJVT(x)           = error ("typeTJVT: " ++ show' x)

typeWTVT(WTInt)        = VTInt
typeWTVT(WTLowLong)    = VTLowLong
typeWTVT(WTHighLong)   = VTHighLong
typeWTVT(WTFloat)      = VTFloat
typeWTVT(WTLowDouble)  = VTLowDouble
typeWTVT(WTHighDouble) = VTHighDouble
typeWTVT(WTReference)  = VTReference(VTAddr)
typeWTVT(WTRetAddr(pc))= VTRetAddr(pc)
typeWTVT(x)            = error ("typeWTVT: " ++ show' x)

