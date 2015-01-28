module SHARED-SYNTAX
/*previously defined elsewhere for ltl-support, now these syntax are also used for java,
although we don't incorporate ltl for now, let's keep this independent like this
*/
syntax Exp ::= Exp "<=" Exp [seqstrict, klabel('LtEq)]
		     | Exp "==" Exp [seqstrict, klabel('Eq)]
		     | Exp "!=" Exp [klabel('NotEq)]

endmodule
