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

JAVA_FILE=$1

mainFile=`basename ${JAVA_FILE}`
MAIN_CLASS=`echo "$mainFile" | cut -d'.' -f1`

if [ -f ${JAVA_FILE} ];
then
  #if the file starts with a package declaration, add package to the main class name
  read -r IN < ${JAVA_FILE}
  PACKAGE_STR=${IN:0:7}
  if [ "$PACKAGE_STR" == "package" ];
    then MAIN_CLASS="${IN:8:${#IN}-9}.$MAIN_CLASS"
  fi
  JAVAC_ARG=${JAVA_FILE}
else
  JAVAC_ARG=$(find -P ${JAVA_FILE} -name "*.java" -type f)
fi

mkdir .jdk-run
javac -d .jdk-run ${JAVAC_ARG}
java -ea -Dline.separator=$'\n' -cp .jdk-run ${MAIN_CLASS}

if [ "${KEEP_TEMP}" == "false" ];
  then rm -rf .jdk-run
fi
