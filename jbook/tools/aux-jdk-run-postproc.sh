#!/bin/bash

# Compiles the given java program, run it and removes the remaining class file.
# After that, postprocesses te output to introduce two omnipresent bugs of jbook-java,
# So that the two outputs will be the same:
#   1. Removes all java.lang. envcounters,
#   2. true => True false => False

if [ $# -ne 1 ]; then
    echo "Usage: `basename $0` <javaFile or dir>"
    exit 1
fi

JBOOK_TOOLS_DIR="$( cd "$( dirname "$0" )" && pwd )"

#run jdk and save the output
$JBOOK_TOOLS_DIR/../../tools/aux-jdk-run.sh $1 > jdk-out.txt

# java.lang. => <nothing>
sed -i -e 's/java.lang.//g' jdk-out.txt

# true => True, false => False
sed -i -e 's/true/True/g' jdk-out.txt
sed -i -e 's/false/False/g' jdk-out.txt
cat jdk-out.txt
