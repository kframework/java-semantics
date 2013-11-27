#!/bin/bash

# Requires at least 4 arguments:
# -threads num_of_threads
# -clean true/false
# the other arguments: test directories.
# If only four arguments are provided, test directory is assumed to be ../programs

if (( "$#" < 10 )); then
    echo "Usage: `basename $0` -mode <run/search> -threads <num_threads> -timeout <timeout in s> /
          -encodeXML <true/false> -clean <true/false> [target files/dirs]"
    exit
fi

TOOLS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ $# == 10 ]; then
    ${TOOLS_DIR}/aux-kjtest.sh ${@} ${TOOLS_DIR}/../programs/
    exit
fi

MODE=$2
THREADS=$4
TIMEOUT=$6
ENCODE_XML=$8
CLEAN=${10}
shift 10

START=$(date +%s)
PRETTY_ARGS=$(find ${@} -maxdepth 0)
echo "Running tests for"
echo "$PRETTY_ARGS"
echo

TEST_RUNNER_JAR=$(cross-path-native.sh ${TOOLS_DIR}/test-runner.jar)
GEN_CMD="$(cross-sh.sh ${TOOLS_DIR}/jdk-run.sh) --keep-temp"

case "$MODE" in
"run")
    RUN_CMD="$(cross-sh.sh ${TOOLS_DIR}/kjrun.sh) --cached"
    ;;
"search")
    RUN_CMD="$(cross-sh.sh ${TOOLS_DIR}/kjrun.sh) --search-cached"
    ;;
"jdk")
    RUN_CMD=$(cross-sh.sh ${TOOLS_DIR}/aux-echo.sh)
    ;;
*)
    echo "Invalid MODE: ${MODE}"
    exit 1
    ;;
esac

# Convert paths into OS-specific format
PATHS=("$@")
for ((i=0; i<${#PATHS[@]}; i++)); do
    PATHS[$i]=$(cross-path-native.sh ${PATHS[$i]})
done

# We don't use external script for deleting temp dir,
# since it have the same performance as standard delete from java.
java -jar ${TEST_RUNNER_JAR} \
  -gen \"${GEN_CMD}\" \
  -run \"${RUN_CMD}\" \
  -taskExt java \
  -testsuiteName java-semantics \
  -classnameStyle simple \
  -threads ${THREADS} \
  -timeout ${TIMEOUT} \
  -encodeXML ${ENCODE_XML} \
  -clean ${CLEAN} \
  ${PATHS[@]}

END=$(date +%s)
DIFF=$(( $END - $START ))
echo
echo "It took $DIFF seconds"
