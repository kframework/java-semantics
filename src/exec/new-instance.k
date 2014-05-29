module NEW-INSTANCE
    imports CORE-SORTS
    imports CORE-FUNCTIONS
    imports CORE-EXEC   //for sl, restoreMethContext
    imports STATIC-INIT // for staticInit
    imports VAR-LOOKUP  //for typedLookup()

/*@ \section{Module NEW-INSTANCE}
  New instance creation and related language features.
*/

/*@ \subsection{New instance creation}*/

rule [QNewInstance-resolve-class]:
    Qual . new (Name:Id => getClassType(toPackage(typeOf(Qual)), Name)) (_)

/*@ Qualified new instance creation expression. Unqualified new expressions are rewritten into qualified ones by other
rules and also reach this point.*/
rule [QNewInstance]:
    <k>
      Qual:KResult . new Class:ClassType( Args:TypedVals )
      => staticInit(Class)
        ~> create(Class)
        ~> restoreMethContext(MethContext)
        ~> setEncloser(typedLookup(L), Class, Qual)
        ~> typedLookup(L) .getConsName(Class) (Args);
        ~> typedLookup(L)
      ...
    </k>
    <methodContext>
      MethContext
      =>  <env> .Map </env>
          <crntClass> .K </crntClass>
          <location> L </location>
    </methodContext>
    <store>... . => L |-> objectRef(L, Class) :: Class ...</store>
    <storeMetadata>... . => L |-> LocalLocMetadata ...</storeMetadata>
    (.Bag =>  <object>
                <objectId> L </objectId>
                <objectType> Class </objectType>
              </object>
    )
    <nextLoc> L:Int => L +Int 1 </nextLoc>

syntax K ::=  create ( ClassType )

rule [create]:
    <k>
      create(Class)
      => create(BaseClass) ~> setCrntClass(Class) ~> FieldDecs ~> addEnvLayer
      ...
    </k>
    <classType> Class </classType>
    <extends> BaseClass </extends>
    <instanceFields> FieldDecs </instanceFields>
        [structural]

rule [create-empty-discard]:
    create( noClass ) => .K
        [structural]

syntax K ::=  setCrntClass ( ClassType )

rule [setCrntClass]:
    <k> setCrntClass(Class) => . ...</k>
    <crntClass> _ => Class </crntClass>
        [structural]

syntax K ::=  "addEnvLayer"

rule [addEnvLayer]:
    <k> addEnvLayer => . ...</k>
    <env> Env => . </env>
    <crntClass> Class </crntClass>
    <location> OId </location>
    <object>
      <objectId> OId </objectId>
      (.Bag =>  <layer>
                  <layerClass> Class </layerClass>
                  <layerEnv> Env </layerEnv>
                  ...
                </layer>
      )
      ...
    </object>
        [structural]

/*@ Sets the enclosing object for a given object.
    Invoked by invokeConstr and QSuperConstrInv.
*/
syntax K ::=  setEncloser (
                K,          //Evaluates to source object
                ClassType,  //Class layer in the source object for which to set the enclosing object.
                K           //The enclosing object
              )
              [strict(1,3)]

rule [setEncloser-value]:
    <k>
      setEncloser(objectRef(OId, _)::_, Class, EncloserVal::_) => .
      ...
    </k>
    <objectId> OId </objectId>
    <layerClass> Class </layerClass>
    <layerEnclosingObject> _ => EncloserVal::EncloserClass </layerEnclosingObject>
    <classType> Class </classType>
    <enclosingClass> EncloserClass </enclosingClass>

rule [setEncloser-noValue]:
    setEncloser(_,_, noValue) => .

endmodule

module NEW-INSTANCE-REST
    imports CORE-SORTS
    imports CORE-FUNCTIONS
    imports CORE-EXEC   //for sl, restoreMethContext
    imports STATIC-INIT // for staticInit
    imports VAR-LOOKUP  //for typedLookup()
    imports NEW-INSTANCE

//@\subsection{Instance field declarations}

rule [FieldDec-instance]:
    <k> 'FieldDec([.KList],, T:Type,,['VarDec(X:Id)]) => . ...</k>
    <env> Env:Map => Env[L/X] </env>
    <store>... . => L |-> default(T) ...</store>
    <storeMetadata>... . => L |-> FieldLocMetadata ...</storeMetadata>
    <nextLoc> L:Int => L +Int 1 </nextLoc>

//@\subsection{Execution of QSuperConstrInv, AltConstrInv}

// 'QSuperConstrInv( Qual:K,, _:K,, [ Args:KList ] )
syntax KLabel ::=  "'QSuperConstrInv"

rule [QSuperConstrInv]:
    <k>
      'QSuperConstrInv(Qual:K,, _,, [ Args:KList ])
      => setEncloser('QThis(Class), BaseClass, Qual)
         ~> 'Invoke(
              'QSuperMethod(Class,, .K,, getConsName(BaseClass)),,
              [Args]
            );
      ...
    </k>
    <crntClass> Class:ClassType </crntClass>
    <classType> Class </classType>
    <extends> BaseClass:ClassType </extends>

// 'AltConstrInv( _:K,, [ Args:KList ] )
syntax KLabel ::= "'AltConstrInv"

rule [AltConstrInv]:
    <k>
      'AltConstrInv(_,, [ Args:KList ])
      => 'QThis(Class) .getConsName(Class) (toExps([Args]));
      ...
    </k>
    <crntClass> Class:ClassType </crntClass>

endmodule
