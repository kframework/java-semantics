module TO-STRING
    imports CORE-SORTS
    imports CORE-FUNCTIONS
    imports AUX-STRINGS
    imports SYNTAX-CONVERSIONS


//add 0 to the beginning of the hex string to make it 13 digits.
//the int arg is the number of zero to be added.
syntax String ::=     pad0(String)      [function]
                    | pad0(String, Int) [function]

rule pad0(S:String) => pad0(S, 13 -Int lengthString(S))

rule pad0(S:String, I:Int) => S
when I <=Int 0

rule pad0(S:String, I:Int) => pad0("0" +String S, I -Int 1)
when I >Int 0

syntax Int ::= uvalueMInt(MInt)     [function, hook(#MINT:uvalue), smtlib(bv2int)]

// the min val of double in java
syntax Float ::= "DoubleMinVal" | "DoubleMaxVal"
syntax Float ::= "DoubleNegInf" | "DoublePosInf"
syntax Float ::= "DoubleNaN"

rule DoubleMinVal => minValueFloat(53, 11)
rule DoubleMaxVal => maxValueFloat(53, 11)
rule DoubleNegInf => minusInfinity(53, 11)
rule DoublePosInf => plusInfinity(53, 11)
rule DoubleNaN => fpNaN(53, 11)

syntax Float ::= nextUp(Float) [function]
syntax Float ::= nextDown(Float) [function]

//FFFFFFFFFFFFF is eq to 4503599627370495
//auxiliary functions for computing ajacent double values.
syntax Float ::= incF0(String, Int) [function]
                   //three args are prefix, significand, and power resp.
               | incF1(String, Int, Int) [function]

               | decF0(String, Int) [function]
               //three args are prefix, significand, and power resp.
               | decF1(String, Int, Int) [function]

//there are 14 chars in the hex str, first 1 is either 0 or 1, the remaining 13 are significands.
rule incF0(Fl:String, E:Int) => incF1(substrString(Fl, 0, 1), String2Base(substrString(Fl, 1,
lengthString(Fl)), 16), E)


rule incF1(Prefix:String, Significand:Int, Power:Int) =>
String2Float("0x" +String Prefix +String ".0" +String "p" +String Int2String(Power +Int 1))
when Significand ==Int 4503599627370495

rule incF1(Prefix:String, Significand:Int, Power:Int) =>
String2Float("0x" +String Prefix +String "." +String pad0(Base2String(Significand +Int 1, 16)) +String
 "p" +String Int2String(Power))
when notBool (Significand ==Int 4503599627370495)


//=============auxiliary functions for computing next smaller double
rule decF0(Fl:String, E:Int) => decF1(substrString(Fl, 0, 1), String2Base(substrString(Fl, 1,
lengthString(Fl)), 16), E)


rule decF1(Prefix:String, Significand:Int, Power:Int) =>
String2Float("0x" +String Prefix +String ".FFFFFFFFFFFFF" +String "p" +String Int2String(Power -Int
 1)) when Significand ==Int 0

rule decF1(Prefix:String, Significand:Int, Power:Int) =>
String2Float("0x" +String Prefix +String "." +String pad0(Base2String(Significand -Int 1, 16))
+String "p" +String Int2String(Power))
when notBool (Significand ==Int 0)


//build the hex string of a float, given its significand's string and exponent.
//syntax String ::= buildFloatHexStr(String, Int) [function]

rule nextUp(DoubleNaN) => DoubleNaN
rule nextUp(DoublePosInf) => DoublePosInf
rule nextUp(0.0) => DoubleMinVal
rule nextUp(Fl:Float) => incF0(Base2String(uvalueMInt(significandFloat(Fl)), 16),
                            exponentFloat(Fl)) [owise]

rule nextDown(DoubleNaN) => DoubleNaN
rule nextDown(DoubleNegInf) => DoubleNegInf
rule nextDown(0.0) => --Float DoubleMinVal
rule nextDown(Fl:Float) => decF0(Base2String(uvalueMInt(significandFloat(Fl)), 16),
                                                       exponentFloat(Fl)) [owise]

/*@auxiliary function for printing Java's double value in default mode.
//the number of digits preserved after decimal point depend solely on whether
// that amount of significands can distinguish the target value with its adjacent
//double values.
//This function returns the pos at which two strings are distinguishable
//the two input string are assumed to have equal length.
*/
syntax Int ::= diffFromPos(String, String) [function]

rule diffFromPos(S1:String, S2:String) => 0
    when S1 ==String "" orBool S2 ==String ""

rule diffFromPos(S1:String, S2:String) => 1
    when substrString(S1, 0, 1) =/=String substrString(S2, 0, 1)

rule diffFromPos(S1:String, S2:String) =>
    1 +Int diffFromPos(substrString(S1, 1, lengthString(S1)),
                    substrString(S2, 1, lengthString(S2)))
    when substrString(S1, 0, 1) ==String substrString(S2, 0, 1)

rule diffFromPos(S1:String, S2:String) => -1 [owise] //error state


/*@
1. compute the diffFromPos value for the target doubleVal and its two adjacent values.
    Say pos1 and pos2 representing the positions at which the target double value
     can be distinguished with its next lower / next higher double value.
2. return the larger one between pos1 and pos2.
*/
syntax Int ::= numOfDigitsPreserved(Float)  [function]
            | numOfDigitsPreserved1(Float, Float, Float) [function]
            //the string representation of the format "%.17Rf"
            | numOfDigitsPreserved2(String, String, String) [function]
            //the substr after decimal points: all of them should have 17 chars
            | numOfDigitsPreserved3(String, String, String) [function]

syntax String ::= getFractionalPart(String)  [function]
rule getFractionalPart(S:String) =>
    substrString(S, findChar(S, ".", 0) +Int 1, lengthString(S))

rule numOfDigitsPreserved(Fl:Float) =>
  numOfDigitsPreserved1(nextDown(Fl), Fl, nextUp(Fl))

rule numOfDigitsPreserved1(F0:Float, F1:Float, F2:Float)
     => numOfDigitsPreserved2(Float2String(F0, "%.18Rf"),
                              Float2String(F1, "%.18Rf"),
                              Float2String(F2, "%.18Rf"))

rule numOfDigitsPreserved2(F0:String, F1:String, F2:String)
    => numOfDigitsPreserved3(getFractionalPart(F0),
                         getFractionalPart(F1),
                         getFractionalPart(F2))

rule numOfDigitsPreserved3(F0:String, F1:String, F2:String)
    => maxInt(diffFromPos(F0, F1), diffFromPos(F1, F2))


//Implement the rounding mode of 'N' (round to nearest) manually in order to pass the tests.
//round(s,i) where s is the target float number in string format and int i is the number of
//fractional digits after the decimal point;
syntax String ::= round0(String, Int) [function]
                //use this helper method so that only compute the pos of decimal point one time
                //the arg in the middle is the pos of "."
                | round1(String, Int, Int) [function]

 //The method incI analyzes a float string in this format: A.BX, where X is the last digit
 //and the length of B is the number of preserved fractional digits (denoted by n)
 //The four args are A, B, X, n
                | incI(Int, Int, Int, Int)  [function]
                //helper function to avoid the repetition of computation
                | incNoOverflow(String, String, Int)  [function]



rule round0(S:String, N:Int) => round1(S, findChar(S, ".", 0), N)



rule round1(S:String, Pos:Int, N:Int) => incI(String2Int(substrString(S, 0, Pos)),
                            String2Int(substrString(S, Pos +Int 1, Pos +Int 1 +Int N)),
                            String2Int(substrString(S, Pos +Int 1 +Int N, Pos +Int 2 +Int N)),
                             N)


rule incI(A:Int, B:Int, X:Int, N:Int) =>
incNoOverflow(Int2String(A), Int2String(B), N)
when X <Int 5

//inc by one unit, no overflow in fractional part
rule incI(A:Int, B:Int, X:Int, N:Int) =>
incNoOverflow(Int2String(A), Int2String(B +Int 1), N)
when X >=Int 5 andBool (B +Int 1 <Int 10 ^Int N)

//inc by one unit, has overflow in fractional part
rule incI(A:Int, B:Int, X:Int, N:Int) =>
incNoOverflow(Int2String(A +Int 1), "0", 1)
when X >=Int 5 andBool (B +Int 1 >=Int 10 ^Int N)



rule incI(A:Int, B:Int, X:Int, N:Int) => "Error State!"
[owise] //error state



rule incNoOverflow(A:String, B:String, N:Int) =>
  A +String "." +String pad0(B, N -Int lengthString(B))

/*@ Converts all possible Java values into String. Used mostly for printing and String + operator.
    Conversion for other value forms is defined in other modules.
*/

syntax Exp ::= toString ( K )   [strict]

rule toString(Str:String :: _) => Str
rule toString(I:Int :: char) => chrChar(I)
rule toString(I:Int :: T:Type) => Int2String(I)
    when T =/=K char

rule toString(Fl:Float :: _) =>
//round0("100.99634", 2)
//round1("100.99634", 3, 2)
//"" +String incI(100,99,6,2)

round0(Float2String(Fl, "%.18Rf"), numOfDigitsPreserved(Fl))



/*
                                Float2String(Fl, "%." +String
                                Int2String(numOfDigitsPreserved(Fl)) +String "Rg")


                             +String ";;\n nextDown: " +String Float2String(nextDown(Fl), "%.28Rf")
                             +String ";;\tTarget: " +String Float2String(Fl, "%.28Rf")
                             +String ";;\tnextUp: " +String Float2String(nextUp(Fl), "%.28Rf")

                             +String ";;\tNumOfDigitsPreserved:\t" +String Int2String(numOfDigitsPreserved(Fl))
                             +String ";;\tTarget in round mode (16RNf): " +String
                             Float2String(Fl, "%.16RNf")
      +String ";;\tTarget in round 16 RNg: " +String Float2String(Fl, "%.16RNg")

                      +String ";;\tTarget in round 18 RNf: " +String Float2String(Fl, "%.18RNf")
                      +String ";;\tTarget in round 18 RNg: " +String Float2String(Fl, "%.18RNg")



//Float2String(incF0("10000000000000",0), "%Ra")


Float2String(String2Float("0x" +String "1" +String "." +String Int2String(0 +Int 1)
+String "p" +String Int2String(0)), "%Ra")

 //Int2String(String2Base("0000000000000", 16)) +String ";;"
//+String Int2String(exponentFloat(Fl)) +String ";;len: " +String Int2String(lengthString
//("10000000000000"))

//Float2String(incF1("1", 0, 0), "%Ra")
//Base2String(uvalueMInt(significandFloat(Fl)), 16) +String
 //  ", expo:" +String Int2String(exponentFloat(Fl)) +String "; " +String Float2String(String2Float
 //  ("0x1.0p0"))

 //Float2String(nextUp(Fl), "%Ra")

//Base2String(uvalueMInt(significandFloat(Fl)), 16)
//Float2String(String2Float("0x1.3ae147ae147adp+0"), "%.18Rf") //nextDown
//+String ";\t" +String Float2String(String2Float("0x1.3ae147ae147aep+0"), "%.18Rf") //target float
//+String ";\t" +String Float2String(String2Float("0x1.3ae147ae147afp+0"), "%.18Rf") //nextUp
*/

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
