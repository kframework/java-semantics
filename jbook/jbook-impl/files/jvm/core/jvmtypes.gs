type Overflow  = (Opd(WordType), Int) -> Bool                 
type CheckArgs = (Instr,Nat, Pc, Register(VerifyType), Opd(VerifyType))
type TypeInstr = (Instr, Pc, Register(VerifyType), Opd(VerifyType))
type Succ      = (Pc, Register(VerifyType), Opd(VerifyType))
type Check     = MRef -> CheckArgs -> Bool
type CheckI    = CheckArgs -> Bool

data InitState = InitNew(Pc) | InInit | Complete                 

data ClassFile = CFile (           Class, 
                          Bool, 
                          { Modifier } , 

                          Maybe(Class),
                        SigInfo,

                          { Class } , 
                          FieldTab, 
                          MethTab)  

data Modifier                
        = Public
        | Private
        | Static
        | Native
        | Abstract
        | Protected
        | Final
        | Synchronized
        | Volatile
        | Transient

data Switch = Noswitch                                      
            | Call(MRef,Args)             
            | Result(Val)                   
            | InitClass(Class)                  
               | Throw(Ref) | ThrowInit(Ref)

type Prim = String

data PrimOp
    = PrimFun(Fun)
    | PrimLdc(Val)

type MRef = Combine Class MSig
type FRef = Combine Class FNm

type TypeSig = String
type FRefSig = (FNm, TypeSig)     --- (Fieldname, Fieldtype)
type MRefSig = (MNmSig, TypeSig)  --- (Methodname with signature, return type)
type MNmSig  = String
type CSig    = (String,(TypeSig,{Modifier}))

type SuperSigs  = [(MRef,(JavaType,{Modifier}))]
type SimpleSigs = Mapping String (TypeSig,{Modifier})

type SigInfo = (SimpleSigs,(SuperSigs,SuperSigs))

type ValType = [WordType]

data Instr = Prim(PrimOp)                                    
         | Iinc(RegNo, Word)
         | Swap
         | Nop
           | Load(MoveType, RegNo)              
           | Store(MoveType, RegNo)              
           | Dupx(Size, Size)                   
           | Pop(Size)                         
           | Goto(Offset)                       
           | Cond(Prim , Offset)          
           | Halt                               
           | MGetStatic(JavaType,FRef,FRefSig)                             
           | MPutStatic(JavaType,FRef,FRefSig)                
           | MInvokeStatic(JavaType,MRef,MRefSig)                   
           | Return(MoveType)               
           | New(Class)                                                
           | MGetField(JavaType,FRef,FRefSig)                   
           | MPutField(JavaType,FRef,FRefSig)                   
           | InstanceOf (JavaType)                               
           | Checkcast(JavaType)                                
           | MInvokeSpecial(JavaType,MRef,MRefSig)                   
           | MInvokeVirtual(JavaType,MRef,MRefSig)                   
           | LoadString(String)                                
           | NewArray(JavaType,Dimension)                         
           | ArrayLength                                  
           | AStore(ArrayMoveType)                   
           | ALoad(ArrayMoveType)                   

           | TableSwitch (Int,Int) Pc [Pc]
           | LookupSwitch Pc [(Int,Pc)]

           | Athrow                                          
           | Jsr(Offset)                     
           | Ret(RegNo)                 
    | LabInstr(LabName)
    | LabJsr(LabName)
    | LabCond(Relation,LabName)
    | LabGoto(LabName)

instance AsmTerm Modifier

showClassName :: Class -> ShowS
showClassName(_,cn) = showString cn

type Code = [ Instr ]            

type FieldTab   = Map ( FNm ) (  FDec )                  
type MethTab    = Map ( MSig ) (  MDec )                 

data FDec = FDec (  { Modifier } ,
                    JavaType)           

data MDec = MDec (  { Modifier } ,
                    JavaType,
                    Code,
                    [ Exc ] ,
                    (Nat,Nat))            

type JvmFrame  = (Pc,Map ( RegNo ) (  Word ) ,[ Word ] ,MRef)           

type Args   = [ Word ]                        
type Val    = [ Word ]                        

data Exc = Exc(   Pc,
                  Pc,
                  Pc,
                  Class)           

         | ExcL(LabName, LabName, LabName, Class)

data JVMHeap = JVMObject(Class, Map ( FRef ) (  Val ) )                      

             | Array(JavaType,[ Val ] )            

             | String(String)             

data JVMClassState = Linked   
                   | Initialized                   

               | Unusable
               | Referenced
                     | Loaded  | SupersLoaded                              

