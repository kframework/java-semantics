#!/bin/bash

# if no arguments are provided - running the whole test suite.
# if several arguments are provided as directories - running
# tests inside that directories.

~/java-semantics/java-fan/tools/aux-jftest.sh -threads 22 -clean false ${@}
