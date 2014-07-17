module EXP-SYNTAX
    imports CORE-SORTS
    imports CORE-CLASSES

syntax Exp ::= Exp "+" Exp [seqstrict, klabel('Plus)]

endmodule
