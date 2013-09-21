/*@ \section{Module AUX-STRINGS}
Auxiliary constructs related to Strings. Extension to string.k.*/

module AUX-STRINGS

//Retain the first Count chars in the string
syntax K ::= "retainHead" "(" String "," Int ")"                        [function]
rule retainHead(Str:String, Count:Int) => substrString(Str, 0, Count)

//Retain the last Count chars in the string
syntax K ::= "retainTail" "(" String "," Int ")"                        [function]
rule retainTail(Str:String, Count:Int) => substrString(Str, lengthString(Str) -Int Count, lengthString(Str))

//Trim the first Count chars in the string
syntax K ::= "trimHead" "(" String "," Int ")"                          [function]
rule trimHead(Str:String, Count:Int) => substrString(Str, Count, lengthString(Str))

//Trim the last Count chars in the string
syntax K ::= "trimTail" "(" String "," Int ")"                          [function]
rule trimTail(Str:String, Count:Int) => substrString(Str, 0, lengthString(Str) -Int Count)

syntax K ::= "lastChar" "(" String ")"                                  [function]
rule lastChar(Str:String) => retainTail(Str, 1)

endmodule
