# Run a java program with krun.

#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: `basename $0` <javaFile>"
    exit 1
fi

javaFile=$1

TOOLS_DIR="$( cd "$( dirname "$0" )" && pwd )"

krun --parser="java -cp $TOOLS_DIR/../parser/JavaParser.jar ro.uaic.info.fmse.parser.Main" \
  --compiled-def="$TOOLS_DIR/../semantics/java-compiled.maude" \
  --main-module=JAVA --output-mode=none $javaFile
