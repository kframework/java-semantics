#!/bin/bash

# Compiles the given java program, run it and removes the remaining class file.

if (( "$#" < 1 )) || (( "$#" > 2 )); then
    echo "Your command:"
    echo `basename $0` $@
    echo "Usage: `basename $0` <javaFile or dir>"
    echo "Or:    `basename $0` <--keep-temp> <javaFile or dir>"
    exit 1
fi

if [[ $1 == --keep-temp ]];
  then
    KEEP_TEMP=true
    shift
  else
    KEEP_TEMP=false
fi

javaFile=$1

mainFile=`basename $javaFile`
mainClass=`echo "$mainFile" | cut -d'.' -f1`

if [ -f $javaFile ];
then
  #if the file starts with a package declaration, add package to the main class name
  read -r IN < $javaFile
  PACKAGE_STR=${IN:0:7}
  if [ "$PACKAGE_STR" == "package" ];
    then mainClass="${IN:8:${#IN}-9}.$mainClass"
  fi
  JAVAC_ARG=$javaFile
else
  JAVAC_ARG=$(find -P $javaFile -name "*.java" -type f)
fi

mkdir .jdk-run
javac -d .jdk-run $JAVAC_ARG
java -ea -cp .jdk-run $mainClass

if [ "${KEEP_TEMP}" == "false" ];
  then rm -rf .jdk-run
fi
