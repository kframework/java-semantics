require "labels-exec.k"
require "configuration-exec.k"
require "../common/java-doc.k"
require "../common/core-sorts.k"
require "../common/aux-strings.k"
require "../common/primitive-types.k"
require "../common/subtyping.k"
require "unfolding.k"
require "expressions.k"
require "expressions-classes.k"
require "statements.k"
require "arrays.k"
require "static-init.k"
require "new-instance.k"
require "var-lookup.k"
require "method-invoke.k"
require "api-core.k"
require "api-threads.k"

module JAVA-EXEC
    imports LABELS-EXEC
    imports CONFIGURATION-EXEC
    imports CORE-SORTS
    imports AUX-STRINGS
    imports UNFOLDING
    imports PRIMITIVE-TYPES
    imports SUBTYPING
    imports EXPRESSIONS
    imports EXPRESSIONS-CLASSES
    imports STATEMENTS
    imports ARRAYS
    imports STATIC-INIT
    imports NEW-INSTANCE
    imports VAR-LOOKUP
    imports METHOD-INVOKE
    imports API-CORE
    imports API-THREADS
    imports JAVA-SYNTAX

endmodule

module JAVA-SYNTAX
// No syntax needed, we are using an external parser.
endmodule
