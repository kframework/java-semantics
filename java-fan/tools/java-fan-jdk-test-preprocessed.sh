#!/bin/bash

#Run jdk only over java-fan preprocessed test suite.

TOOLS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

THREADS=22
CLEAN=true

START=$(date +%s)
PRETTYARGS=$(find ${@} -maxdepth 0)
echo "Running tests for"
echo "$PRETTYARGS"
echo

# We don't use external script for deleting temp dir,
# since it have the same performance as standart delete from java.
java -jar $TOOLS_DIR/../../tools/test-runner.jar \
  -gen $TOOLS_DIR/java-fan-jdk-run.sh -run $TOOLS_DIR/../../tools/aux-echo.sh \
  -taskExt java -threads $THREADS -timeout 30 -testsuiteName java-semantics \
  -classnameStyle simple \
  -clean $CLEAN $TOOLS_DIR/../../programs

END=$(date +%s)
DIFF=$(( $END - $START ))
echo
echo "It took $DIFF seconds"
