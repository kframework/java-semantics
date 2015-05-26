require "math.k"

module TO-STRING
    imports CORE-SORTS
    imports CORE-FUNCTIONS
    imports AUX-STRINGS
    imports SYNTAX-CONVERSIONS
    imports JAVA-MATH



/*@
The algorithm for printing a Java's double value is based on the description of Javadoc of Double.
http://docs.oracle.com/javase/7/docs/api/java/lang/Double.html#toString(double)
 1. Given a Java's double value, compute its nextDown and nextUp (two adjacent double values)
 2. Print them using format Float2String(Fl, "%.18Rf")
    18 digits should be enough, cause In java, there are at most 17 digits after decimal point
    being printed.
 3. Get the position after which the target double can be distinguished from its neighbors.
 4. There are two candidate string representation. Suppose the position computed by last step
    is N, then the two candidate string are:
     Candidate1: Float2String(TargetFl, "%." +String Int2String(N) +String "Rg")
     Candidate2: Float2String(TargetFl, "%." +String Int2String(N +Int 1) +String "Rg")

    In most cases, Candidate1 is the right one, but occasionaly, e.g. the number 7 % 1.2, the
    Candidate 1 will become the same as its left-neighbor's string representation, i.e. "1"

 5. Additional check is performed to decide which candidate to use: the Candidate 1 will be
    parsed back to float and comared with its left and right neighbors. If they are
    distinguishable, then Candidate 1 will be returned as the string representation of the
    target double value, otherwise, Candidate 2 will be returned.
*/
syntax String ::= javaDouble2String(Float)  [function]
//the three args: nextDown, target double, nextUp
                | chooseFromCandidateDoubleStr0(Float, Float, Float) [function]

//First three args are the same as the above function, the last one is the number at which pos the
//target double is distinguishable from its adjacent double values
                | chooseFromCandidateDoubleStr1(Float, Float, Float, Int) [function]

                //the 4 args are: nextDown, nextUp, candidate1, candidate2
                //At first, the candidate1 is transformed back to float and compare with its
                //neighbors, if ok then return it, owise return the candidate2
                | chooseFromCandidateDoubleStr2(Float, Float, String, String) [function]


//check whether the string (representing a float) is diff from both of the two floats.
syntax Bool ::= isDiffFl(Float, String, Float) [function]
               | isDiff(Float, Float, Float) [function]
rule isDiffFl(F0:Float, F1:String, F2:Float) => isDiff(F0, String2Float(F1), F2)
rule isDiff(F0:Float, F1:Float, F2:Float) => F1 =/=Float F0 andBool F1 =/=Float F2

rule javaDouble2String(Fl:Float) => chooseFromCandidateDoubleStr0(nextDown(Fl), Fl, nextUp(Fl))

rule chooseFromCandidateDoubleStr0(F0:Float, F1:Float, F2:Float) =>
    chooseFromCandidateDoubleStr1(F0, F1, F2, numOfDigitsPreserved1(F0, F1, F2))

rule chooseFromCandidateDoubleStr1(Lower:Float, Cur:Float, Higher:Float, N:Int) =>
    chooseFromCandidateDoubleStr2(Lower, Higher,
                            Float2String(Cur, "%." +String Int2String(N) +String "Rg"),
                            Float2String(Cur, "%." +String Int2String(N +Int 1) +String "Rg"))


rule chooseFromCandidateDoubleStr2(Lower:Float, Higher:Float, Cand1:String, Cand2:String) => Cand1
when isDiffFl(Lower, Cand1, Higher)

rule chooseFromCandidateDoubleStr2(Lower:Float, Higher:Float, Cand1:String, Cand2:String) => Cand2
[owise]

/*@ Converts all possible Java values into String. Used mostly for printing and String + operator.
    Conversion for other value forms is defined in other modules.
*/

syntax Exp ::= toString ( K )   [strict]

rule toString(Str:String :: _) => Str
rule toString(I:Int :: char) => chrChar(I)
rule toString(I:Int :: T:Type) => Int2String(I)
    when T =/=K char

rule toString(Fl:Float :: _) => javaDouble2String(Fl)

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

rule toString(arrayOf class Class:Id) => "[L" + (toString(class Class) + ";")

rule toString(arrayOf arrayOf T:Type) => "[" + toString(arrayOf T)

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
      =>    toString(class OuterClassId) +
           ("$" +String Id2String(getSimpleName(class ClassId)))
      ...
    </k>
    <classType> class ClassId </classType>
    <enclosingClass> class OuterClassId:Id </enclosingClass>

//@ \texttt{toString for objectRef}

rule toString(objectRef(OId:Int, LowestClass:ClassType) :: T:Type)
    =>  objectRef(OId, LowestClass) :: T .((String2Id("toString")):>MethodName) (.TypedVals)

//@ \subsection{Debug helper functions}

syntax KItem ::= debugPrint ( K )                [strict]
rule <k> debugPrint(Str:String::_) => .K ...</k>
     <out>... .List => ListItem(Str +String "\n") </out>

syntax KItem ::= debugString( K )             [function]
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

syntax KItem ::= isDebugStringLeaf ( K )
rule isDebugStringLeaf(_:Id) => true
rule isDebugStringLeaf(_:Int) => true
rule isDebugStringLeaf(_:Bool) => true
rule isDebugStringLeaf(_:Float) => true
rule isDebugStringLeaf(_:String) => true
rule isDebugStringLeaf(_:Types) => true
rule isDebugStringLeaf([_]) => true

endmodule
