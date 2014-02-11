#!/bin/bash

# Run a java program with krun, with arguments:
#   time: true = show execution time, false = don't show
#   timeout: timeout in seconds, or 0 if there is no timeout.
#   debug: true for debug mode (adding option --debug to krun), false otherwise.
#   OUTPUT: same as --output option of krun.
# Used by kjrun.sh

if (( "$#" != 11 )); then
    echo "Your command:"
    echo `basename $0` $@
    echo "Usage: `basename $0` --time <true|false> --timeout <timeout in s> \
      --mode <run|search|search-count|symbolic|symbolic-count|debug> --output <none|raw|pretty> \
      --kast-cache <true|false> \
      <javaFile>"
    exit 1
fi

# echo "Your command:"
# echo `basename $0` $@

SHOW_TIME=$2
TIMEOUT=$4
MODE=$6
OUTPUT=$8
KAST_CACHE=${10}
JAVA_FILE=${11}

BASE_JAVA_FILE=`basename ${JAVA_FILE}`

MAIN_CLASS=`echo "$BASE_JAVA_FILE" | cut -d'.' -f1`
TOOLS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
WORK_DIR="$(pwd)"
SEMANTICS_DIR=$(cross-path-native.sh ${TOOLS_DIR}/../semantics)

KRUN_CMD="time"

# Option time
if [ ${SHOW_TIME} == true ];
  then KRUN_CMD="time"
  else KRUN_CMD=""
fi

# Option timeout
if [ ${TIMEOUT} -ne 0 ]; then
    KRUN_CMD="$KRUN_CMD timeout $TIMEOUT"
fi

# OS-dependent selection of krun.
KRUN_CMD="$KRUN_CMD $(cross-k.sh krun)"

KRUN_CMD="$KRUN_CMD \
                      --debug-info \
                      --color extended \
                      --directory=\"$SEMANTICS_DIR\" \
                      --main-module=JAVA \
                      -cMainClass=\"ListItem(\\\"$MAIN_CLASS\\\")\""

case "$MODE" in
"run")
    KRUN_CMD="$KRUN_CMD -cModelCheck=\"false\""
    ;;
"search"|"search-count")
    KRUN_CMD="$KRUN_CMD --search-final -cModelCheck=\"true\""
    ;;
"symbolic"|"symbolic-count")
    IN_FILE=${JAVA_FILE%.java}.cIN.in
    IN_VALUE=$(<${IN_FILE})
    KRUN_CMD="$KRUN_CMD --search -cModelCheck=\"true\" -cPC=true -cIN=\"$IN_VALUE\""
    ;;
"debug")
    KRUN_CMD="$KRUN_CMD --debug -cModelCheck=\"false\""
    ;;
*)
    echo "Invalid MODE: ${MODE}"
    exit 1
    ;;
esac

KRUN_CMD="$KRUN_CMD --output=$OUTPUT"

if [ ${KAST_CACHE} == false ];
  then
    # OS-dependent selection of the parser.
    KRUN_CMD="$KRUN_CMD --parser=\"$(cross-sh.sh kj-parse-aggreg.sh)\""

    KRUN_CMD="$KRUN_CMD $JAVA_FILE"
  else
    KAST_FILE=${WORK_DIR}/${BASE_JAVA_FILE}.kast
    PARSER_CMD="kj-parse-cache.sh $WORK_DIR $(cross-path-unix.sh ${JAVA_FILE})"

    KRUN_CMD="$KRUN_CMD --parser=cat"
    KRUN_CMD="$KRUN_CMD $KAST_FILE"

    # echo "PARSER_CMD"
    # echo ${PARSER_CMD}
    eval ${PARSER_CMD}
fi

if [ ${MODE} == "search-count" ] || [ ${MODE} == "symbolic-count" ];
  then KRUN_CMD="$KRUN_CMD  | grep \"Solution\" | wc -l"
fi

# echo KRUN_CMD
# echo ${KRUN_CMD}
eval ${KRUN_CMD}
