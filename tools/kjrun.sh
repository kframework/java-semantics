#!/bin/bash

# Run a java program with krun.

if [ $# -ne 1 ]; then
    echo "Usage: `basename $0` <javaFile>"
    echo "for more options use aux-kjrun2.sh"
    exit 1
fi

JAVA_FILE=$1

aux-kjrun2.sh --time true --timeout 30 --debug false --display-config true $JAVA_FILE
