#!/bin/bash

# Run a java program with krun, do not display output configuration.

if [ $# -ne 1 ]; then
    echo "Usage: `basename $0` <javaFile>"
    exit 1
fi

JAVA_FILE=$1
WORK_DIR="$(pwd)"
TOOLS_DIR="$( cd "$( dirname "$0" )" && pwd )"

KRUN_CMD="krun --parser=\"aux-kjparser.sh $WORK_DIR $JAVA_FILE\" \
  --compiled-def=\"$TOOLS_DIR/../semantics/java-compiled.maude\" \
  --main-module=JAVA --output-mode=none $TOOLS_DIR/aux-kjrun.sh"

echo "WORK_DIR="
echo $WORK_DIR
echo "KRUN_CMD="
echo $KRUN_CMD

eval $KRUN_CMD
