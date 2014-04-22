require "labels-exec.k"
require "configuration-exec.k"
require "../core-sorts.k"
require "../extended-KResult.k"
require "../aux-strings.k"
require "../unfolding.k"
require "../primitive-types.k"
require "../literals.k"
require "../subtyping.k"
require "../expressions.k"
require "../statements.k"
require "../arrays.k"
require "../static-init.k"
require "../classes.k"
require "../var-lookup.k"
require "../method-invoke.k"
require "../to-string.k"
require "../api-core.k"
require "../api-threads.k"

module JAVA-EXEC
    imports LABELS-EXEC
    imports CONFIGURATION-EXEC
    imports CORE-SORTS
    imports EXTENDED-K-RESULT
    imports AUX-STRINGS
    imports UNFOLDING
    imports PRIMITIVE-TYPES
    imports LITERALS
    imports SUBTYPING
    imports EXPRESSIONS
    imports STATEMENTS
    imports ARRAYS
    imports STATIC-INIT
    imports CLASSES
    imports VAR-LOOKUP
    imports METHOD-INVOKE
    imports TO-STRING
    imports API-CORE
    imports API-THREADS
    imports JAVA-SYNTAX

endmodule

module JAVA-SYNTAX
// No syntax needed, we are using an external parser.
endmodule
