module OPTIONAL-SYNTAX
//@ Labels used when a particular term is optional, in many places in Java grammar.
syntax None ::= ""   [onlyLabel, klabel('None)]

syntax OptionalId ::= Id [prefer, klabel('Some)] | None
syntax OptionalExp ::= Exp [prefer, klabel('Some)] | None
syntax OptionalWildcardBound ::= WildcardBound [prefer, klabel('Some)] | None
syntax OptionalTypeArgs ::= TypeArgs [prefer, klabel('Some)] | None
syntax OptionalTypeParams ::= TypeParams [prefer, klabel('Some)] | None
syntax OptionalTypeBound ::= TypeBound [prefer, klabel('Some)] | None
syntax OptionalThrows ::= Throws [prefer, klabel('Some)] | None
syntax OptionalDefaultVal ::= DefaultVal [prefer, klabel('Some)] | None
syntax OptionalExtendsInterfaces ::= ExtendsInterfaces [prefer, klabel('Some)] | None
syntax OptionalInterfaces ::= Interfaces [prefer, klabel('Some)] | None
syntax OptionalPackageDec ::= PackageDec [prefer, klabel('Some)] | None
syntax OptionalSuper ::= Super [prefer, klabel('Some)] | None
syntax OptionalConstrInv ::= ConstrInv [prefer, klabel('Some)] | None
syntax OptionalClassBody ::= ClassBody [prefer, klabel('Some)] | None
syntax OptionalEnumBodyDecs ::= EnumBodyDecs [prefer, klabel('Some)] | None
syntax OptionalEnumConstArgs ::= EnumConstArgs [prefer, klabel('Some)] | None

endmodule