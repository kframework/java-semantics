require "labels-prep.k"
require "configuration-prep.k"
require "../common/java-doc.k"
require "../common/core-sorts.k"
require "../common/core-functions.k"
require "../common/core-classes.k"
require "../common/aux-strings.k"
require "../common/primitive-types.k"
require "../common/subtyping.k"
require "core-preprocessing.k"
require "process-type-names.k"
require "process-comp-units.k"
require "process-imports.k"
require "process-class-decs.k"
require "process-class-members.k"
require "elaboration-categories.k"
require "elaboration-core.k"
require "elaboration-top-blocks.k"
require "elaboration-statements.k"
require "elaboration-expressions.k"
require "elaboration-vars.k"
require "elaboration-method-invoke.k"
require "elaboration-new-instance.k"
require "elaboration-arrays.k"
require "elaboration-types.k"
require "literals.k"
require "process-local-classes.k"
require "process-anonymous-classes.k"
require "folding.k"

module JAVA-PREP
    imports LABELS-PREP
    imports CONFIGURATION-PREP
    imports CORE-SORTS
    imports AUX-STRINGS
    imports PROCESS-TYPE-NAMES
    imports PROCESS-COMP-UNITS
    imports PROCESS-IMPORTS
    imports PROCESS-CLASS-DECS
    imports PROCESS-CLASS-MEMBERS
    imports ELABORATION-TOP-BLOCKS
    imports ELABORATION-STATEMENTS
    imports ELABORATION-EXPRESSIONS
    imports ELABORATION-VARS
    imports ELABORATION-METHOD-INVOKE
    imports ELABORATION-NEW-INSTANCE
    imports ELABORATION-ARRAYS
    imports ELABORATION-TYPES
    imports PROCESS-LOCAL-CLASSES
    imports PROCESS-ANONYMOUS-CLASSES
    imports FOLDING
    imports PRIMITIVE-TYPES
    imports LITERALS
    imports SUBTYPING
    imports JAVA-SYNTAX

endmodule

module JAVA-SYNTAX
// No syntax needed, we are using an external parser.
endmodule
