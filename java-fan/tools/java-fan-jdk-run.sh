#!/bin/bash

#Preprocesses the given program with java-fan preprocessor and runs it with JDK.

if [  $# != 1 ]; then
    echo "Usage: `basename $0` <JAVA FILE>"
    exit 1
fi

JAVA_FILE=$1
BASE_JAVA_FILE=`basename $JAVA_FILE`
MAIN_CLASS=`echo "$BASE_JAVA_FILE" | cut -d'.' -f1`
TOOLS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

mkdir -p .prep
$TOOLS_DIR/java-fan-preprocess.sh $JAVA_FILE > .prep/$BASE_JAVA_FILE

$TOOLS_DIR/../../tools/jdk-run.sh .prep/$BASE_JAVA_FILE
