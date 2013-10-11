#!/bin/bash

# Run a java program with krun, with arguments:
#   time: true = show execution time, false = don't show
#   timeout: timeout in seconds, or 0 if there is no timeout.
#   debug: true for debug mode (adding option --debug to krun), false otherwise.
#   display-config: true: display final configuration, false: display only sdtout output.
# Used by kjrun.sh

if [ $# -ne 9 ]; then
    echo "Usage: `basename $0` --time <true/false> --timeout <timeout in s> --debug <true/false> --display-config <true/false> <javaFile>"
    exit 1
fi

SHOW_TIME=$2
TIMEOUT=$4
DEBUG=$6
DISPLAY_CONFIG=$8
JAVA_FILE=$9
BASE_JAVA_FILE=`basename $JAVA_FILE`
MAIN_CLASS=`echo "$BASE_JAVA_FILE" | cut -d'.' -f1`
TOOLS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

KRUN_CMD="time"

if [ $SHOW_TIME == true ];
  then KRUN_CMD="time"
  else KRUN_CMD=""
fi

if [ $TIMEOUT -ne 0 ]; then
    KRUN_CMD="$KRUN_CMD timeout $TIMEOUT"
fi

KRUN_CMD="$KRUN_CMD krun \
                      --parser=aux-kjprep.sh \
                      --color extended \
                      -cMainClass=\"ListItem(\\\"$MAIN_CLASS\\\")\" \
                      -cModelCheck=\"false\""

if [ $DEBUG == true ]; then
    KRUN_CMD="$KRUN_CMD --debug"
fi

if [ $DISPLAY_CONFIG == false ]; then
    KRUN_CMD="$KRUN_CMD --output-mode=none"
fi

KRUN_CMD="$KRUN_CMD $JAVA_FILE"

# echo $KRUN_CMD
eval $KRUN_CMD
