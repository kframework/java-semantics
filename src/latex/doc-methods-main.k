require "../common/java-doc.k"
require "mock-dependencies.k"
require "../exec/configuration-exec.k"
require "../exec/syntax-conversions.k"
require "../exec/method-invoke.k"

module DOC-METHODS-MAIN
    imports CONFIGURATION-EXEC
    imports SYNTAX-CONVERSIONS
    imports METHOD-INVOKE
    imports JAVA-SYNTAX

endmodule

module JAVA-SYNTAX
// No syntax needed, we are using an external parser.
endmodule
