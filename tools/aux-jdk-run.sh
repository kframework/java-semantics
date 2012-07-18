#!/bin/bash

# Compiles the given java program, run it and removes the remaining class file.

if [ $# -ne 1 ]; then
    echo "Usage: `basename $0` <javaFile>"
    exit 1
fi

javaFile=$1

mainFile=`basename $javaFile`
mainClass=`echo "$mainFile" | cut -d'.' -f1`

#if the file starts with a package declaration, add package to the main class name
read -r IN < $javaFile
PACKAGE_STR=${IN:0:7}
if [ "$PACKAGE_STR" == "package" ];
  then mainClass="${IN:8:${#IN}-9}.$mainClass"
fi

javac -d . $javaFile
java -ea -cp . $mainClass
