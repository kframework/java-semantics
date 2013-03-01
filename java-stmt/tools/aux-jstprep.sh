#!/bin/bash

#java semantics preprocessor
# concatenates the parsing result of the given file with java lib classes

if [  $# == 0 ]; then
    echo "Usage: `basename $0` <javaFile>"
    exit 1
fi

javaFile=$1
TOOLS_DIR="$( cd "$( dirname "$0" )" && pwd )"

java -jar $TOOLS_DIR/../../parser/JavaParser.jar $javaFile

