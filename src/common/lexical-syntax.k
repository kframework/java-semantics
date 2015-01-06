module LEXICAL-SYNTAX
//@ \subsection{Comments.sdf}
//no need to define because K provides fixed layout

//@ \subsection{Id.sdf} todo
//syntax Id ::= ID [klabel('Id)]
//syntax ID ::= Token{[A-Za-z\_\$][A-Za-z0-9\_\$]*}
syntax ID ::= //KeyWord [reject] only terminals can be rejected todo
              "true"  [reject]
            | "false" [reject]
            | "null"  [reject]

//@ \subsection{KeyWord.sdf(not needed?)}
/*
syntax Keyword ::= "abstract"
                 | "assert"
                 | "boolean"
                 | "break"
                 | "byte"          
                 | "case"          
                 | "catch"         
                 | "char"          
                 | "class"         
                 | "const"         
                 | "continue"      
                 | "default"       
                 | "do"            
                 | "double"        
                 | "else"          
                 | "enum"          
                 | "extends"       
                 | "final"         
                 | "finally"       
                 | "float"         
                 | "for"           
                 | "goto"          
                 | "if"            
                 | "implements"    
                 | "import"        
                 | "instanceof"    
                 | "int"           
                 | "interface"     
                 | "long"          
                 | "native"        
                 | "new"           
                 | "package"       
                 | "private"       
                 | "protected"     
                 | "public"        
                 | "return"        
                 | "short"         
                 | "static"        
                 | "strictfp"      
                 | "super"         
                 | "switch"        
                 | "synchronized"  
                 | "this"          
                 | "throw"         
                 | "throws"        
                 | "transient"     
                 | "try"           
                 | "void"          
                 | "volatile"      
                 | "while"
*/

//@ \subsection{LineTerminators.sdf}

//@ \subsection{Modifiers.sdf}
syntax Public ::= "public"  [klabel('Public)]
syntax Private ::= "private"  [klabel('Private)]
syntax Protected ::= "protected" [klabel('Protected)]
syntax Abstract ::= "abstract"  [klabel('Abstract)]
syntax Final ::= "final" [klabel('Final)]
syntax Static ::= "static" [klabel('Static)]
syntax Native ::= "native" [klabel('Native)]
syntax Transient ::= "transient" [klabel('Transient)]
syntax Volatile ::= "volatile" [klabel('Volatile)]
syntax StrictFP ::= "strictfp" [klabel('StrictFP)]
syntax Modifier ::= Public
                  | Private
                  | Protected
                  | Abstract
                  | Final
                  | Static
                  | Native
                  | Transient
                  | Volatile
                  | StrictFP

//@ \subsection{UnicodeEscape.sdf}
syntax UnicodeEscape ::= Token {"\\" [u]+ [0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]} [klabel('UnicodeEscape)]

//@ \subsection{WhiteSpace.sdf}
//no need to define because K provides fixed layout
endmodule