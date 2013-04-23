#!/bin/bash

# Run the tests in the target directory (or file).
# Tests are preprocessed with java-fan preprocessor.

if [ $# -ne 1 ]; then
    echo "Usage: `basename $0` <testDir or testFile>"
    exit 1
fi

JBOOK_TOOLS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
JBOOK_TOOLS_DIR=$(cygpath -w $JBOOK_TOOLS_DIR)
TOOLS_DIR=$JBOOK_TOOLS_DIR/../../tools
TOOLS_DIR=$(cygpath -w $TOOLS_DIR)
JAVA_FILE=$1

java -jar $TOOLS_DIR/test-runner.jar -gen $JBOOK_TOOLS_DIR/aux-jdk-prep-run-postproc.bat -run $JBOOK_TOOLS_DIR/jbook-prep-run.bat -taskExt java -threads 2 -timeout 30 -killProcessTreeOnTimeout true -testsuiteName java-semantics -classnameStyle simple -clean true $JAVA_FILE
