#!/bin/bash

# First preprocesses the input program using java-fan preprocessor.
# After that compiles the given java program, run it and removes the remaining class file.
# After that, postprocesses te output to introduce two omnipresent bugs of jbook-java,
# So that the two outputs will be the same:
#   1. Removes all java.lang. envcounters,
#   2. true => True false => False

if [ $# -ne 1 ]; then
    echo "Usage: `basename $0` <javaFile>"
    exit 1
fi
JAVA_FILE=$1
BASE_JAVA_FILE=`basename $JAVA_FILE`
JBOOK_TOOLS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
JAVA_FAN_TOOLS_DIR=$JBOOK_TOOLS_DIR/../../java-fan/tools
TOOLS_DIR=$JBOOK_TOOLS_DIR/../../tools


# preprocess the input file
mkdir -p .prep
$JAVA_FAN_TOOLS_DIR/java-fan-preprocess.sh $JAVA_FILE > .prep/$BASE_JAVA_FILE

#run jdk and save the output
$TOOLS_DIR/aux-jdk-run.sh .prep/$BASE_JAVA_FILE > jdk-out.txt

# java.lang. => <nothing>
sed -i -e 's/java.lang.//g' jdk-out.txt

# true => True, false => False
sed -i -e 's/true/True/g' jdk-out.txt
sed -i -e 's/false/False/g' jdk-out.txt
cat jdk-out.txt
