#!/bin/bash

# Run a java program with krun, do not display output configuration.
# Used by aux-kjtest.sh

if [ $# -ne 1 ]; then
    echo "Usage: `basename $0` <javaFile>"
    exit 1
fi

JAVA_FILE=$1
WORK_DIR="$(pwd)"
TOOLS_DIR="$( cd "$( dirname "$0" )" && pwd )"
BASE_JAVA_FILE=`basename $JAVA_FILE`
MAIN_CLASS=`echo "$BASE_JAVA_FILE" | cut -d'.' -f1`
KAST_FILE=$WORK_DIR/$BASE_JAVA_FILE.kast
SEMANTICS_DIR=$TOOLS_DIR/../semantics

PARSER_CMD="aux-kjparser.sh $WORK_DIR $JAVA_FILE"

KRUN_CMD="krun --parser=cat \
  --directory=\"$SEMANTICS_DIR\" \
  --main-module=JAVA
  -cMainClass=\"ListItem(\\\"$MAIN_CLASS\\\")\"
   -cModelCheck=\"false\"
  --output=none $KAST_FILE"

eval $PARSER_CMD >/dev/null
cd $SEMANTICS_DIR
eval $KRUN_CMD
