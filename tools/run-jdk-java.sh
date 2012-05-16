# Compiles the given java program, run it and removes the remaining class file.

#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: `basename $0` <javaFile>"
    exit 1
fi

javaFile=$1

targetDir=`dirname $javaFile`
mainFile=`basename $javaFile`
mainClass=`echo "$mainFile" | cut -d'.' -f1`

javac $javaFile
java -cp $targetDir $mainClass
find $targetDir -type f -name "*.class" -exec rm -f {} \;
