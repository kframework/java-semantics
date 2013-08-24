#!/bin/bash

# Explore state space of a java program using krun.

if [ $# -ne 1 ] && [ $# -ne 2 ]; then
    echo "Usage: `basename $0` <javaFile>"
    exit 1
fi

JAVA_FILE=$1
BASE_JAVA_FILE=`basename $JAVA_FILE`
MAIN_CLASS=`echo "$BASE_JAVA_FILE" | cut -d'.' -f1`
TOOLS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# The last argument is not used, we put it here just to overcome file presence checking of krun
# We cannot put $JAVA_FILE directly because krun expects only files,
# and $JAVA_FILE may also be a dir
time krun --parser=aux-kjprep.sh -cMainClass="ListItem(\"$MAIN_CLASS\")" -cModelCheck="true" --search-final $JAVA_FILE

