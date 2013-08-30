#!/bin/bash

# Requires at least 4 arguments:
# -threads num_of_threads
# -clean true/false
# the other arguments: test directories.
# If only four arguments are provided, test directory is assumed to be ../programs

TOOLS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ $# -le 9 ]; then
    echo "Usage: `basename $0` -mode <run/search> -threads <num_threads> -timeout <timeout in s> -encodeXML <true/false> -clean <true/false> [target files/dirs]"
    exit
fi

if [ $# == 10 ]; then
    $TOOLS_DIR/aux-kjtest.sh ${@} $TOOLS_DIR/../programs/
    exit
fi

MODE=$2
THREADS=$4
TIMEOUT=$6
ENCODE_XML=$8
CLEAN=$10
shift 10

START=$(date +%s)
PRETTYARGS=$(find ${@} -maxdepth 0)
echo "Running tests for"
echo "$PRETTYARGS"
echo

if [ $MODE == "run" ];
  then RUN_CMD="$TOOLS_DIR/aux-kjrun.sh"
  else RUN_CMD="$TOOLS_DIR/aux-kjsearch.sh"
fi

# We don't use external script for deleting temp dir,
# since it have the same performance as standart delete from java.
java -jar $TOOLS_DIR/test-runner.jar \
  -gen $TOOLS_DIR/aux-jdk-run.sh \
  -run $RUN_CMD \
  -taskExt java \
  -testsuiteName java-semantics \
  -classnameStyle simple \
  -threads $THREADS \
  -timeout $TIMEOUT \
  -encodeXML $ENCODE_XML \
  -clean $CLEAN \
  ${@}

END=$(date +%s)
DIFF=$(( $END - $START ))
echo
echo "It took $DIFF seconds"
