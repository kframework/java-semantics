#!/bin/bash

# Compiles the given java program, run it and removes the remaining class file.

if [ $# -ne 1 ]; then
    echo "Usage: `basename $0` <javaFile or dir>"
    exit 1
fi

aux-jdk-run.sh $1
find -type f -name "*.class" -exec rm -f {} \;
