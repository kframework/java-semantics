require "labels-full.k"
require "configuration-full.k"
require "../common/java-doc.k"
require "../common/aux-strings.k"
require "../common/core-sorts.k"
require "../common/core-classes.k"
require "../common/core-functions.k"
require "../common/primitive-types.k"
require "../common/subtyping.k"

require "../prep/core-preprocessing.k"
require "../prep/process-type-names.k"
require "../prep/process-comp-units.k"
require "../prep/process-imports.k"
require "../prep/process-class-decs.k"
require "../prep/process-class-members.k"
require "../prep/elaboration-categories.k"
require "../prep/elaboration-core.k"
require "../prep/elaboration-top-blocks.k"
require "../prep/elaboration-statements.k"
require "../prep/elaboration-expressions.k"
require "../prep/elaboration-vars.k"
require "../prep/elaboration-method-invoke.k"
require "../prep/elaboration-new-instance.k"
require "../prep/elaboration-arrays.k"
require "../prep/elaboration-types.k"
require "../prep/literals.k"
require "../prep/process-local-classes.k"
require "../prep/process-anonymous-classes.k"
require "../prep/folding.k"

require "../exec/core-exec.k"
require "../exec/syntax-conversions.k"
require "../exec/to-string.k"
require "../exec/unfolding.k"
require "../exec/expressions.k"
require "../exec/expressions-classes.k"
require "../exec/statements.k"
require "../exec/arrays.k"
require "../exec/static-init.k"
require "../exec/new-instance.k"
require "../exec/var-lookup.k"
require "../exec/method-invoke.k"
require "../exec/api-core.k"
require "../exec/api-threads.k"

module JAVA-FULL
    imports LABELS-FULL
    imports CONFIGURATION-FULL
    imports AUX-STRINGS
    imports CORE-SORTS
    imports CORE-CLASSES
    imports CORE-FUNCTIONS
    imports PRIMITIVE-TYPES
    imports SUBTYPING

    imports CORE-PREPROCESSING
    imports PROCESS-TYPE-NAMES
    imports PROCESS-COMP-UNITS
    imports PROCESS-IMPORTS
    imports PROCESS-CLASS-DECS
    imports PROCESS-CLASS-MEMBERS
    imports ELABORATION-CATEGORIES
    imports ELABORATION-CORE
    imports ELABORATION-TOP-BLOCKS
    imports ELABORATION-STATEMENTS
    imports ELABORATION-EXPRESSIONS
    imports ELABORATION-VARS
    imports ELABORATION-METHOD-INVOKE
    imports ELABORATION-NEW-INSTANCE
    imports ELABORATION-ARRAYS
    imports ELABORATION-TYPES
    imports LITERALS
    imports PROCESS-LOCAL-CLASSES
    imports PROCESS-ANONYMOUS-CLASSES
    imports FOLDING

    imports CORE-EXEC
    imports SYNTAX-CONVERSIONS
    imports TO-STRING
    imports UNFOLDING
    imports EXPRESSIONS
    imports EXPRESSIONS-CLASSES
    imports STATEMENTS
    imports ARRAYS
    imports STATIC-INIT
    imports NEW-INSTANCE
    imports VAR-LOOKUP
    imports METHOD-INVOKE
    imports METHOD-INVOKE-REST
    imports API-CORE
    imports API-THREADS
    imports JAVA-SYNTAX

endmodule

module JAVA-SYNTAX
// No syntax needed, we are using an external parser.
endmodule
