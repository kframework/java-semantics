require "core-sorts.k"
require "core-classes.k"
require "shared-syntax.k"

module EXP-SYNTAX
    imports CORE-SORTS
    imports CORE-CLASSES
    imports SHARED-SYNTAX

syntax PrefixPostfixExp ::= "++" Exp [klabel('PreIncr)] 
		| "--" Exp [klabel('PreDecr)]
		| Exp "++" [klabel('PostIncr)]
		| Exp "--" [klabel('PostDecr)]

 //use sort K instead of Exp for the sake of Lookup, others might be changed when needed
syntax Exp ::= K "*" K [seqstrict, klabel('Mul)]
		| K "/" K [seqstrict, klabel('Div)]
		| K "%" K [seqstrict, klabel('Remain)]
		| "+" Exp [strict, klabel('Plus)]
		| "-" Exp [strict, klabel('Minus)]
		> K "+" K [seqstrict, klabel('Plus)]
 		| K "-" K [seqstrict, klabel('Minus)]
 		> K "=" K [klabel('Assign)]

syntax CompoundAssignExp ::=  Exp "*=" Exp [klabel('AssignMul)]
                            | Exp "/=" Exp [klabel('AssignDiv)]
                            | Exp "%=" Exp [klabel('AssignRemain)]
                            | Exp "+=" Exp [klabel('AssignPlus)]
                            | Exp "-=" Exp [klabel('AssignMinus)]
                            | Exp "<<=" Exp [klabel('AssignLeftShift)]
                            | Exp ">>=" Exp [klabel('AssignRightShift)]
                            | Exp ">>>=" Exp [klabel('AssignURightShift)]
                            | Exp "&=" Exp [klabel('AssignAnd)]
                            | Exp "^=" Exp [klabel('AssignExcOr)]
                            | Exp "|=" Exp [klabel('AssignOr)]

syntax Exp ::= K "<<" K [seqstrict, klabel('LeftShift)]
              | K ">>" K [seqstrict, klabel('RightShift)]
              | K ">>>" K [seqstrict, klabel('URightShift)]

syntax Exp ::= Exp ">" Exp [seqstrict, klabel('Gt)]
syntax Exp ::= Exp "<" Exp [seqstrict, klabel('Lt)]
syntax Exp ::= Exp ">=" Exp [seqstrict, klabel('GtEq)]

syntax Exp ::= Exp "||" Exp [strict(1), klabel('LazyOr)]
             | Exp "&&" Exp [strict(1), klabel('LazyAnd)]
             | K "|" K [seqstrict, klabel('Or)]
             | K "^" K [seqstrict, klabel('ExcOr)]
             | K "&" K [seqstrict, klabel('And)]

syntax Exp ::= "~" Exp [strict, klabel('Complement)]
             | "!" Exp [strict, klabel('Not)]

syntax Exp ::= K "?" K ":" K [klabel('Cond)]
endmodule
