#!/bin/bash

# Run a java program with krun, do not display output configuration.

if [ $# -ne 1 ]; then
    echo "Usage: `basename $0` <javaFile>"
    exit 1
fi

javaFile=$1
workDir="$(pwd)"
TOOLS_DIR="$( cd "$( dirname "$0" )" && pwd )"

krun --parser="aux-kjparser.sh $workDir" \
  --compiled-def="$TOOLS_DIR/../semantics/java-compiled.maude" \
  --main-module=JAVA --output-mode=none $javaFile
