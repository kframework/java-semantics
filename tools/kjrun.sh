#!/bin/bash

# Run a java program with krun.

if [ $# -ne 1 ]; then
    echo "Usage: `basename $0` <javaFile>"
    echo "for more options use aux-kjrun2.sh"
    exit 1
fi

JAVA_FILE=$1

# OS-dependent choice of default timeout
if [[ $(uname) == *Linux* ]]
  then DEFALUT_TIMEOUT=30
  else DEFALUT_TIMEOUT=120
fi

aux-kjrun2.sh --time true --timeout $DEFALUT_TIMEOUT --debug false --display-config true $JAVA_FILE
