require "core-sorts.k"
require "core-classes.k"

module SHARED-SYNTAX
    imports CORE-SORTS
    imports CORE-CLASSES
   

//previously defined elsewhere for ltl-support, now these syntax are also used for java
syntax Exp ::= Exp "<=" Exp [seqstrict, klabel('LtEq)]
		|Exp "==" Exp [seqstrict, klabel('Eq)]
		|Exp "!=" Exp [klabel('NotEq)]

endmodule
