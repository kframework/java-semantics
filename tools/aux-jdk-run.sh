# Compiles the given java program, run it and removes the remaining class file.


#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: `basename $0` <javaFile>"
    exit 1
fi

javaFile=$1

mainFile=`basename $javaFile`
mainClass=`echo "$mainFile" | cut -d'.' -f1`

javac -d . $javaFile
java -ea -cp . $mainClass
