#!/bin/bash

# Executes the given tests with JDK only and writes output to test-results.xml
# if no arguments are provided - running the whole test suite.
# if several arguments are provided as directories - running
# tests inside that directories.

TOOLS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ $# == 0 ] || [ $1 != "-clean" ];
  then
    CLEAN=false
    STARTARG=1
  else
    CLEAN=true
    STARTARG=2
fi

if [ $# -lt $STARTARG ]; then
    $TOOLS_DIR/jdk-test.sh ${@} $TOOLS_DIR/../programs/
    exit
fi

START=$(date +%s)
PRETTYARGS=$(find ${@:STARTARG} -maxdepth 0)
echo "Running tests for"
echo "$PRETTYARGS"
echo

TEST_RUNNER_JAR=$(cross-path.sh ${TOOLS_DIR}/test-runner.jar)
GEN_CMD=$(cross-script.sh ${TOOLS_DIR}/aux-jdk-run.sh)
RUN_CMD=$(cross-script.sh ${TOOLS_DIR}/aux-echo.sh)

# We don't use external script for deleting temp dir,
# since it have the same performance as standard delete from java.
java -jar ${TEST_RUNNER_JAR} \
  -gen \"${GEN_CMD}\" \
  -run \"${RUN_CMD}\" \
  -taskExt java -threads 12 -timeout 120 -testsuiteName java-semantics \
  -clean ${CLEAN} ${@:STARTARG}

END=$(date +%s)
DIFF=$(( $END - $START ))
echo
echo "It took $DIFF seconds"

