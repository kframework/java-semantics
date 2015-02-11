#!/bin/bash

# Run a java program with krun, with arguments:
#   time: true = show execution time, false = don't show
#   timeout: timeout in seconds, or 0 if there is no timeout.
#   debug: true for debug mode (adding option --debug to krun), false otherwise.
#   OUTPUT: same as --output option of krun.
# Used by kjrun.sh

ORIGINAL_ARGS=$@

function usage()
{
cat <<-EOF
Usage: `basename $0` [OPTIONS] <javaFile>

  OPTIONS

  --time=<true|false>
  --timeout=<timeout in s>
  --mode=< run-prep-config
         | run-prep-ast
         | run-exec
         | search
         | symbolic
         | debug
         >
  --output=<none|raw|pretty>
  --input=<java|kast|kast-cache>
  --pattern=<pattern>
  --ltlmc=<LTL formula>
  --config=<true|false>  - Display full config or not
  -v
  --verbose=<true|false>            If true print produced commands for krun
  --cmd-suffix=<suffix to the krun command>
EOF
}

function errorMsg() {
    echo "Your command:"
    echo `basename $0` ${ORIGINAL_ARGS}
    echo
    usage
    exit 1
}

# Default var values

SHOW_TIME=true #param time
TIMEOUT=0
MODE=run-exec
OUTPUT=pretty
INPUT=kast
PATTERN=""
LTLMC=""
CONFIG=false

# Arguments parsing

while [[ ${1:0:1} == - ]]; do
  PARAM=`echo $1 | awk -F= '{print $1}'`
  ARG=$1
  CUT_AMOUNT=$((${#PARAM} + 1))
  VALUE=${ARG:${CUT_AMOUNT}}

  case ${PARAM} in
    "-h" | "--help")
      usage
      exit
      ;;
    "--time")
      SHOW_TIME=${VALUE}
      ;;
    "--timeout")
      TIMEOUT=${VALUE}
      ;;
    "--mode")
      MODE=${VALUE}
      ;;
    "--output")
      OUTPUT=${VALUE}
      ;;
    "--input")
      INPUT=${VALUE}
      ;;
    "--pattern")
      PATTERN=${VALUE}
      ;;
    "--ltlmc")
      LTLMC=${VALUE}
      ;;
    "--config")
      CONFIG=${VALUE}
      ;;
    "-v")
      VERBOSE=true
      ;;
    "--verbose")
      VERBOSE=${VALUE}
      ;;
    "--cmd-suffix")
      CMD_SUFFIX=${VALUE}
      ;;
    *)
      echo "Invalid option: $PARAM"
      errorMsg
      ;;
  esac
  shift
done

# Building the krun command

JAVA_FILE=${1}
if [[ ${JAVA_FILE} == "" ]]; then
  echo "Target file missing"
  errorMsg
fi

BASE_JAVA_FILE=`basename ${JAVA_FILE}`  #simple file/dir name
MAIN_CLASS=`echo "$BASE_JAVA_FILE" | cut -d'.' -f1` #simple file minus extension
TOOLS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
WORK_DIR="$(pwd)"


case "$MODE" in
"run-prep-config" | "run-prep-ast")
    SEMANTICS_DIR=$(cross-path-native.sh ${TOOLS_DIR}/../src/prep)
    MAIN_MODULE=JAVA-PREP
    ;;
"run-exec" | "search" | "symbolic" | "debug")
    SEMANTICS_DIR=$(cross-path-native.sh ${TOOLS_DIR}/../src/exec)
    MAIN_MODULE=JAVA-EXEC
    ;;

*)
    echo "Invalid MODE: ${MODE}"
    exit 1
    ;;
esac

KRUN_CMD="time"

# Option time
if [ ${SHOW_TIME} == true ];
  then KRUN_CMD="time"
  else KRUN_CMD=""
fi

# Option timeout
if [ ${TIMEOUT} -ne 0 ]; then
if [[ $(uname) != *Darwin* ]]
  then KRUN_CMD="$KRUN_CMD timeout $TIMEOUT"
fi
fi

# OS-dependent selection of krun.
KRUN_CMD="$KRUN_CMD $(cross-k.sh krun)"

KRUN_CMD="$KRUN_CMD \
                      --debug-info \
                      --color extended \
                      --directory=\"$SEMANTICS_DIR\" \
                      --main-module=\"$MAIN_MODULE\" \
                      -cMainClass=\"ListItem(\\\"$MAIN_CLASS\\\")\""

case "$MODE" in
"run-prep-config" | "run-prep-ast")
    KRUN_CMD="$KRUN_CMD -cCOMMAND=\"'procTypeNames(.KList)\" \
                        -cSTARTPHASE=\"'ProcTypeNamesPhase(.KList)\" \
                        -cENDPHASE=\"'FoldingPhase(.KList)\""
    ;;
"run-exec")
    ;;
"search")
    KRUN_CMD="$KRUN_CMD --search-final"
    ;;
"symbolic")
    IN_FILE=${JAVA_FILE%.java}.cIN.in
    IN_VALUE=$(<${IN_FILE})
    KRUN_CMD="$KRUN_CMD --search -cPC=true -cIN=\"$IN_VALUE\""
    ;;
"debug")
    KRUN_CMD="$KRUN_CMD --debug"
    ;;
*)
    echo "Invalid MODE: ${MODE}"
    exit 1
    ;;
esac

if [[ ${PATTERN} != "" || ${LTLMC} != "" || ${CONFIG} == "true" ]];
  then KRUN_CMD="$KRUN_CMD -cDissolveAllExceptOut=\"false\""
  else KRUN_CMD="$KRUN_CMD -cDissolveAllExceptOut=\"true\""
fi

KRUN_CMD="$KRUN_CMD --output=$OUTPUT"

if [[ ${PATTERN} != "" ]]; then
  KRUN_CMD="$KRUN_CMD --pattern \"$PATTERN\""
fi

if [[ ${LTLMC} != "" ]]; then
  KRUN_CMD="$KRUN_CMD --ltlmc \"$LTLMC\""
fi

case "$INPUT" in
"java")
    # OS-dependent selection of the parser.
    KRUN_CMD="$KRUN_CMD --parser=\"$(cross-sh.sh kj-parse-aggreg.sh)\""

    KRUN_CMD="$KRUN_CMD $JAVA_FILE"
    ;;
"kast")
    # OS-dependent selection of the parser.
    KRUN_CMD="$KRUN_CMD --parser=\"cat\""

    KRUN_CMD="$KRUN_CMD $JAVA_FILE"
    ;;
"kast-cache")
    KAST_FILE=${WORK_DIR}/${BASE_JAVA_FILE}.kast
    PARSER_CMD="kj-parse-cache.sh $WORK_DIR $(cross-path-unix.sh ${JAVA_FILE})"

    KRUN_CMD="$KRUN_CMD --parser=cat"
    KRUN_CMD="$KRUN_CMD $KAST_FILE"

    if [[ ${VERBOSE} == true ]]; then
      echo "PARSER cmd:"
      echo ${PARSER_CMD}
      echo
    fi

    eval ${PARSER_CMD}
    ;;
*)
    echo "Invalid INPUT: ${INPUT}"
    exit 1
    ;;
esac

if [[ ${CMD_SUFFIX} != "" ]]; then
  KRUN_CMD="$KRUN_CMD  $CMD_SUFFIX"
fi

if [[ ${VERBOSE} == true ]]; then

  echo ${KRUN_CMD} >> krunCMD.txt

fi

# Actual command evaluation
eval ${KRUN_CMD}
