#!/bin/bash

# Run a java program with krun.

if [ $# -ne 1 ]; then
    echo "Usage: `basename $0` <javaFile>"
    exit 1
fi

javaFile=$1

krun --parser="aux-kjprep.sh" $javaFile

