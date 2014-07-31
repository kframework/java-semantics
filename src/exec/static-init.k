//@ \section{Module STATIC-INIT}

module STATIC-INIT
    imports CORE-SORTS
    imports CORE-CLASSES          //for objectClass
    imports CORE-EXEC             //for restoreMethContext

/*@ Triggers static initialization of a class.

Detailed initialization procedure is described in JLS \$12.4.2. Here we implement an approximation of that algorithm,
that does not use the traditional Java synchronization mechanism, but instead relies on term rewriting
capabilities to implement locks. This algorithm is required to avoid multithreaded issues during static initialization.
This may happen when two threads access an uninitialized class at the same time.

Initialization status of a class may have 3 states: StaticUninitialized, StaticInitializing(TId), StaticInitialized.
//Here TId is the id of the thread that initiated the initializing process.
//Now when we reach staticInit(Class), depending on the initialization status of class we should do the following:
1. status = StaticUninitialized => perform the initialization
2. status = StaticInitializing(TId), TId = this thread => this is a recursive initialization request, discard the term.
3. status = StaticInitializing(TId), IID = another thread => we should wait until the initialization is completed
  by another thread. Do not match this case.
4. status = StaticInitialized => the class have been already initialized. Discard the term.
*/
syntax KItem ::=  staticInit (
                ClassType // Class - the ClassType to be initialized,
                          // or noClass if this term should be discarded.
              )

rule [staticInit]:
    <k>
      staticInit(Class:ClassType)
      => [
        StaticFields,, //Static fields have to be allocated before base class is statically initialized,
                       // because during base class initialization those fields might be accessed.
        staticInit(BaseClass),,
        'Try(
            StaticInit,,

            //catch clause of 'Try
            [
              'Catch(
                'Param( [.KList],, classObject,, String2Id("e") ),,
                throw new class String2Id("java.lang.ExceptionInInitializerError") (
                  ((classObject) String2Id("e"))
                );
              )
            ],,

            //finally clause of 'Try
            [
              restoreMethContext(MethContext),,
              staticInitDone(Class)
            ]
        )
      ]
      ...
    </k>

    <methodContext>
      MethContext:Bag
      =>  <env> .Map </env>
          <crntClass> Class </crntClass>
          <location> noValue </location>
    </methodContext>

    <tid> TId:Int </tid>
    <classType> Class </classType>
    <extends> BaseClass:ClassType </extends>
    <staticFields> StaticFields:KListWrap </staticFields>
    <staticInit> StaticInit:KListWrap </staticInit>
    <staticInitStatus> StaticUninitialized => StaticInitializing(TId) </staticInitStatus>

rule [staticInit-already-initialized-discard]:
    <k>
      staticInit(Class:ClassType) => .
      ...
    </k>
    <classType> Class </classType>
    <staticInitStatus> StaticInitialized </staticInitStatus>

rule [staticInit-recursive-initializing-discard]:
    <k>
      staticInit(Class:ClassType) => .
      ...
    </k>
    <tid> TId:Int </tid>
    <classType> Class </classType>
    <staticInitStatus> StaticInitializing(TId) </staticInitStatus>

rule [staticInit-empty]:
    staticInit(noClass) => .K

/*@ Triggers the last step of static initialization:
static init status transitions from StaticInitializing to StaticInitialized.
*/
syntax KItem ::=  staticInitDone (
                ClassType // The class whose initialization just finished
              )

rule [staticInitDone]:
    <k>
      staticInitDone(Class:ClassType) => .
      ...
    </k>
    <tid> TId:Int </tid>
    <classType> Class </classType>
    <staticInitStatus> StaticInitializing(TId) => StaticInitialized </staticInitStatus>

rule [FieldDec-static]:
    <k> 'FieldDec(['Static(_)],, T:Type,,['VarDec(X:Id)]) => . ...</k>
    <crntClass> Class:ClassType </crntClass>
    <classType> Class </classType>
    <staticEnv> Env:Map => Env[L/X] </staticEnv>
    <store>... . => L |-> default(T) ...</store>
    <storeMetadata>... . => L |-> FieldLocMetadata ...</storeMetadata>
    <nextLoc> L:Int => L +Int 1 </nextLoc>

endmodule
