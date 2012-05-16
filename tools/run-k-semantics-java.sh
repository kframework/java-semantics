# Run a java program with krun.

#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: `basename $0` <javaFile>"
    exit 1
fi

javaFile=$1

krun --parser="java -cp ../parser/JavaParser.jar ro.uaic.info.fmse.parser.Main" $javaFile

