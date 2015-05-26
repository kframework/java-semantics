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