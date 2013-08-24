#!/bin/bash

# if no arguments are provided - running the whole test suite.
# if several arguments are provided as directories - running
# tests inside that directories.

aux-kjsearch-test.sh -threads 6 -clean false ${@}
