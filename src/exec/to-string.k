require "../common/core-sorts.k"
require "../common/core-functions.k"
require "../common/aux-strings.k"

module TO-STRING
    imports CORE-SORTS
    imports CORE-FUNCTIONS
    imports AUX-STRINGS

/*@ Converts all possible Java values into String. Used mostly for printing and String + operator.
    Conversion for other value forms is defined in other modules.
*/
syntax K ::= toString ( K )   [strict]

rule toString(Str:String :: _) => Str
rule toString(I:Int :: char) => chrChar(I)
rule toString(I:Int :: T:Type) => Int2String(I)
    when T =/=K char
rule toString(Fl:Float :: _) => Float2String(Fl)
rule toString(true::_) => "true"
rule toString(false::_) => "false"
rule toString(null::_) => "null"

//@ toString(arrayOf T)

rule toString(arrayOf byte)  => "[B"
rule toString(arrayOf short) => "[S"
rule toString(arrayOf int)   => "[I"
rule toString(arrayOf long)  => "[J"
rule toString(arrayOf char)  => "[C"
rule toString(arrayOf bool)  => "[Z"

rule toString(arrayOf class Class:Id) => 'Plus("[L",, 'Plus(toString(class Class) ,,";"))

rule toString(arrayOf arrayOf T:Type) => 'Plus("[",, toString(arrayOf T))

rule [toString-ClassType-TopLevelWithPackage]:
    <k>
      toString(class ClassId:Id) => Id2String(ClassId)
      ...
    </k>
    <classType> class ClassId </classType>
    <enclosingClass> noClass </enclosingClass>
when
    retainHead(Id2String(ClassId), 1) =/=String "."

rule [toString-ClassType-TopLevelWithDefaultPackage]:
    <k>
      toString(class ClassId:Id) => trimHead(Id2String(ClassId), 1)
      ...
    </k>
    <classType> class ClassId </classType>
    <enclosingClass> noClass </enclosingClass>
when
    retainHead(Id2String(ClassId), 1) ==String "."

rule [toString-ClassType-Inner]:
    <k>
      toString(class ClassId:Id)
      => 'Plus(
            toString(class OuterClassId),,
            "$" +String Id2String(getSimpleName(class ClassId))
         )
      ...
    </k>
    <classType> class ClassId </classType>
    <enclosingClass> class OuterClassId:Id </enclosingClass>

//@ \texttt{toString for objectRef}

rule toString(objectRef(OId:Int, LowestClass:ClassType) :: T:Type)
    =>  'Invoke(
          'Method('MethodName(objectRef(OId, LowestClass) :: T,, String2Id("toString"))),,
          [.KList]
        )
        [anywhere]

//@ \subsection{Debug helper functions}

syntax K ::= debugPrint ( K )                [strict]
rule <k> debugPrint(Str:String::_) => . ...</k>
     <out>... . => ListItem(Str +String "\n") </out>

syntax K ::= debugString( K )             [function]
           | debugStringList( KListWrap ) [function]
           | Bool2String( Bool )          [function]

rule debugString(KI:KItem ~> KI2:KItem ~> K:K)
     => debugString(KI:KItem) +String " ~> " +String debugString(KI2:KItem ~> K:K)

rule debugString(X:Id) => Id2String(X)
rule debugString(I:Int) => Int2String(I)
rule debugString(B:Bool) => Bool2String(B)
rule debugString(Fl:Float) => Float2String(Fl)
rule debugString(Str:String) => Str
rule debugString(types(Ks:KList)) => "types(" +String debugStringList([Ks]) +String ")"
rule debugString([Ks:KList]) => "[" +String debugStringList([Ks]) +String "]"

rule debugString(KL:KLabel(Ks:KList)) => KLabel2String(KL) +String "(" +String debugStringList([Ks]) +String ")"
when
            (notBool isDebugStringLeaf(KL(Ks)) ==K true)
    andBool isString(KLabel2String(KL)) ==K true
    andBool Ks =/=KList .KList

rule debugString(KL:KLabel(.KList)) => KLabel2String(KL)
when
            (notBool isDebugStringLeaf(KL(.KList)) ==K true)
    andBool isString(KLabel2String(KL)) ==K true

rule debugString(KL:KLabel(Ks:KList)) => "???"
when
            (notBool isDebugStringLeaf(KL(Ks)) ==K true)
    andBool notBool isString(KLabel2String(KL)) ==K true

rule debugString(.K) => ""

rule debugStringList([K1:K,,Ks:KList]) => debugString(K1:K) +String ",, " +String debugStringList([Ks:KList])
when
    Ks =/=KList .KList

rule debugStringList([K1:K]) => debugString(K1)
rule debugStringList([.KList]) => ""

rule Bool2String(true) => "true"
rule Bool2String(false) => "false"

syntax K ::= isDebugStringLeaf ( K )
rule isDebugStringLeaf(_:Id) => true
rule isDebugStringLeaf(_:Int) => true
rule isDebugStringLeaf(_:Bool) => true
rule isDebugStringLeaf(_:Float) => true
rule isDebugStringLeaf(_:String) => true
rule isDebugStringLeaf(_:Types) => true
rule isDebugStringLeaf([_]) => true

endmodule
