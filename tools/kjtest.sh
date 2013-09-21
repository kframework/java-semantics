#!/bin/bash

# if no arguments are provided - running the whole test suite.
# if several arguments are provided as directories - running
# tests inside that directories.

aux-kjtest.sh -mode run -threads 12 -timeout 120 -encodeXML false -clean false ${@}
