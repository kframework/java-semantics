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
 
syntax Exp ::= Exp "*" Exp [seqstrict, klabel('Mul)]
		| Exp "/" Exp [seqstrict, klabel('Div)]
		| Exp "%" Exp [seqstrict, klabel('Remain)]
		| "+" Exp [strict, klabel('Plus)]
		| "-" Exp [strict, klabel('Minus)]
		> Exp "+" Exp [seqstrict, klabel('Plus)]
 		| Exp "-" Exp [seqstrict, klabel('Minus)]
 		> Exp "=" Exp [klabel('Assign)]

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

syntax Exp ::= Exp "<<" Exp [seqstrict, klabel('LeftShift)]
              | Exp ">>" Exp [seqstrict, klabel('RightShift)]
              | Exp ">>>" Exp [seqstrict, klabel('URightShift)]

syntax Exp ::= Exp ">" Exp [seqstrict, klabel('Gt)]
syntax Exp ::= Exp "<" Exp [seqstrict, klabel('Lt)]
syntax Exp ::= Exp ">=" Exp [seqstrict, klabel('GtEq)]

syntax Exp ::= Exp "||" Exp [strict(1), klabel('LazyOr)]
             | Exp "&&" Exp [strict(1), klabel('LazyAnd)]
             | Exp "|" Exp [seqstrict, klabel('Or)]
             | Exp "^" Exp [seqstrict, klabel('ExcOr)]
             | Exp "&" Exp [seqstrict, klabel('And)]

syntax Exp ::= "~" Exp [strict, klabel('Complement)]
             | "!" Exp [strict, klabel('Not)]

syntax Exp ::= K "?" K ":" K [klabel('Cond)]
endmodule
