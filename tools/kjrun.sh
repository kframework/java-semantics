#!/bin/bash

# Run a java program with krun.

if [ $# -ne 1 ]; then
    echo "Usage: `basename $0` <javaFile>"
    exit 1
fi

javaFile=$1
TOOLS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# The last argument is not used, we put it here just to overcome file presence checking of krun
# We cannot put $javaFile directly because krun expects only files,
# and $javaFile may also be a dir
krun --parser="aux-kjprep.sh $javaFile" $TOOLS_DIR/kjrun.sh
