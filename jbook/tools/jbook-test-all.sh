#!/bin/bash

# Run all the tests over jbook-java.

JBOOK_TOOLS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

$JBOOK_TOOLS_DIR/jbook-test.sh $JBOOK_TOOLS_DIR/../../programs
