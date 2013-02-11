#!/bin/bash

# Run a java program with krun.

if [ $# -ne 1 ] && [ $# -ne 2 ]; then
    echo "Usage: `basename $0` <javaFile>"
    echo "or"
    echo "Usage: `basename $0` <javaFile> --debug"
    exit 1
fi

JAVA_FILE=$1
BASE_JAVA_FILE=`basename $JAVA_FILE`
MAIN_CLASS=`echo "$BASE_JAVA_FILE" | cut -d'.' -f1`
TOOLS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# The last argument is not used, we put it here just to overcome file presence checking of krun
# We cannot put $JAVA_FILE directly because krun expects only files,
# and $JAVA_FILE may also be a dir
if [ $# == 1 ];
then
    time krun --parser=aux-kjprep.sh -cMainClass="ListItem(\"$MAIN_CLASS\")" $JAVA_FILE
else
    krun --parser=aux-kjprep.sh -cMainClass="ListItem(\"$MAIN_CLASS\")" --debug $JAVA_FILE
fi

