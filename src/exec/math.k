module JAVA-MATH

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

syntax Float ::= nextUpPos(Float) [function]
               | nextUp(Float)     [function]
syntax Float ::= nextDownPos(Float) [function]
               | nextDown(Float)     [function]

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

rule nextUp(Fl:Float) => --Float nextDownPos(Fl)
when signFloat(Fl)

rule nextUp(Fl:Float) => nextUpPos(Fl)
[owise]

rule nextUpPos(DoubleNaN) => DoubleNaN
rule nextUpPos(DoublePosInf) => DoublePosInf
rule nextUpPos(0.0) => DoubleMinVal
rule nextUpPos(Fl:Float) => incF0(Base2String(uvalueMInt(significandFloat(Fl)), 16),
                            exponentFloat(Fl)) [owise]

rule nextDown(Fl:Float) => --Float nextUpPos(Fl)
when signFloat(Fl)

rule nextDown(Fl:Float) => nextDownPos(Fl)
[owise]

rule nextDownPos(DoubleNaN) => DoubleNaN
rule nextDownPos(DoubleNegInf) => DoubleNegInf
rule nextDownPos(0.0) => --Float DoubleMinVal
rule nextDownPos(Fl:Float) => decF0(Base2String(uvalueMInt(significandFloat(Fl)), 16),
                           exponentFloat(Fl)) [owise]



/*@
1. compute the diffFromPos value for the target doubleVal and its two adjacent values.
    Say pos1 and pos2 representing the positions at which the target double value
     can be distinguished with its next lower / next higher double value.
2. return the larger one between pos1 and pos2.
*/
syntax Int ::= numOfDigitsPreserved(Float)  [function]
syntax Int ::= numOfDigitsPreserved2(Float, Int)  [function]

//The string arg in the middle is the string representation a float.
syntax Bool ::= inTheRange(Float, String, Float)  [function]
syntax Bool ::= inTheRange2(Float, Float, Float)  [function]

//check whether it is ok to use the format str "%." +String Int2String(N) +String "Rg"
//to print the float F so that the float F' (transformed back from the printed string)
//has the property:  nextDown(F) < F' < nextUp(F)
syntax Bool ::= ok2PrintFloat(Float, Int) [function]

syntax Bool ::= ok2PrintFloatStr(Float, String, Float)  [function]

rule inTheRange(F1:Float, F2:String, F3:Float) => inTheRange2(F1, String2Float(F2), F3)

rule inTheRange2(F1:Float, F2:Float, F3:Float) => true
when F1 <Float F2 andBool F2 <Float F3

rule inTheRange2(F1:Float, F2:Float, F3:Float) => false
[owise]

rule ok2PrintFloat(F:Float, N:Int) => ok2PrintFloatStr(nextDown(F), Float2String(F,
            "%." +String Int2String(N) +String "Rg"), nextUp(F))

//it is ok to print if it is in the interval (nextDown, nextUp) and it is not in scientific
//notation : no "e+" or "e-" symbol inside...
rule ok2PrintFloatStr(F1:Float, F2:String, F3:Float) =>
    inTheRange(F1, F2, F3) andBool findString(F2, "e+", 0) <Int 0 andBool findString(F2, "e-", 0)
    <Int 0

rule numOfDigitsPreserved(Fl:Float) => numOfDigitsPreserved2(Fl, 17)

rule numOfDigitsPreserved2(Fl:Float, N:Int) => numOfDigitsPreserved2(Fl, N -Int 1)
 when ok2PrintFloat(Fl, N) andBool N >=Int 1

rule numOfDigitsPreserved2(Fl:Float, N:Int) => N +Int 1
[owise]

//add 0 to the beginning of the hex string to make it 13 digits.
//the int arg is the number of zero to be added.
syntax String ::=     pad0(String)      [function]
                    | pad0(String, Int) [function]

rule pad0(S:String) => pad0(S, 13 -Int lengthString(S))

rule pad0(S:String, I:Int) => S
when I <=Int 0

rule pad0(S:String, I:Int) => pad0("0" +String S, I -Int 1)
when I >Int 0

syntax String ::= getFractionalPart(String)  [function]
rule getFractionalPart(S:String) =>
    substrString(S, findChar(S, ".", 0) +Int 1, lengthString(S))

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

endmodule