#!/bin/bash

# if no arguments are provided - running the whole test suite.
# if several arguments are provided as directories - running
# tests inside that directories.

TOOLS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

$TOOLS_DIR/java-fan-aux-test.sh -threads 22 -clean true ${@}
