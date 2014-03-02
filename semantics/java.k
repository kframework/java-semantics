require "java-doc.k"
require "labels.k"
require "configuration.k"
require "core.k"
require "extended-KResult.k"
require "aux-strings.k"
require "process-type-names.k"
require "process-comp-units.k"
require "process-imports.k"
require "process-class-decs.k"
require "process-class-members.k"
require "elaboration-top-blocks.k"
require "elaboration-statements.k"
require "elaboration-expressions.k"
require "elaboration-types.k"
require "process-local-classes.k"
require "primitive-types.k"
require "literals.k"
require "subtyping.k"
require "expressions.k"
require "statements.k"
require "arrays.k"
require "static-init.k"
require "classes.k"
require "var-lookup.k"
require "method-invoke.k"
require "api-core.k"
require "api-threads.k"

module JAVA
    imports LABELS
    imports CONFIGURATION
    imports CORE
    imports EXTENDED-K-RESULT
    imports AUX-STRINGS
    imports PROCESS-TYPE-NAMES
    imports PROCESS-COMP-UNITS
    imports PROCESS-IMPORTS
    imports PROCESS-CLASS-DECS
    imports PROCESS-CLASS-MEMBERS
    imports ELABORATION-TOP-BLOCKS
    imports ELABORATION-STATEMENTS
    imports ELABORATION-EXPRESSIONS
    imports ELABORATION-TYPES
    imports PROCESS-LOCAL-CLASSES
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
    imports API-CORE
    imports API-THREADS
    imports JAVA-SYNTAX

endmodule

module JAVA-SYNTAX
// No syntax needed, we are using an external parser.
endmodule
