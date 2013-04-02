#!/bin/bash

# Requires at least 4 arguments:
# -threads num_of_threads
# -clean true/false
# the other arguments: test directories.
# If only four arguments are provided, test directory is assumed to be ../programs

TOOLS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ $# -le 3 ]; then
    echo "`basename $0` -threads <num_threads> -clean <true/false> [target files/dirs]"
    exit
fi

if [ $# == 4 ]; then
    $TOOLS_DIR/aux-jftest.sh ${@} $TOOLS_DIR/../.programs/
    exit
fi

THREADS=$2
CLEAN=$4
shift 4

START=$(date +%s)
PRETTYARGS=$(find ${@} -maxdepth 0)
echo "Running tests for"
echo "$PRETTYARGS"
echo

# We don't use external script for deleting temp dir,
# since it have the same performance as standart delete from java.
java -jar $TOOLS_DIR/../../tools/test-runner.jar \
  -gen $TOOLS_DIR/../../tools/aux-jdk-run.sh -run $TOOLS_DIR/jfrun.sh \
  -taskExt java -threads $THREADS -timeout 30 -testsuiteName java-semantics \
  -classnameStyle simple \
  -clean $CLEAN ${@}

END=$(date +%s)
DIFF=$(( $END - $START ))
echo
echo "It took $DIFF seconds"
