#!/bin/bash

#Parse the given java file

if [  $# == 0 ]; then
    echo "Usage: `basename $0` <javaFile>"
    exit 1
fi

JAVA_FILE=$(cross-path-native.sh $1)
TOOLS_DIR="$( cd "$( dirname "$0" )" && pwd )"

#PARSER_JAR=$(cross-path-native.sh ${TOOLS_DIR}/../parser/JavaParser.jar)
PARSER_JAR=$(cross-path-native.sh ${TOOLS_DIR}/../parser/javafrontparser.jar)
java -jar ${PARSER_JAR} ${JAVA_FILE}
