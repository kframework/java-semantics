require "../exec/java-exec.k"
require "tree_pattern.k"
require "int_set.k"
require "list_pattern.k"
require "int_list.k"

module JAVA-VERIFICATION
  imports JAVA-EXEC
  imports TREE-PATTERN
  imports LIST-PATTERN

syntax Id ::= "min" | ".min"
endmodule
