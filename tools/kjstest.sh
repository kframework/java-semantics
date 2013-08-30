#!/bin/bash

# if no arguments are provided - running the whole test suite.
# if several arguments are provided as directories - running
# tests inside that directories.

aux-kjtest.sh -mode search -threads 6 -timeout 600 -encodeXML false -clean false ${@}
