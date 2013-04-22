#!/bin/bash

# Run jbook-java over the given java program, without any pre/post processing.
# Can be run from any dir.

if [ $# -ne 1 ]; then
    echo "Usage: `basename $0` <javaFile>"
    exit 1
fi

JBOOK_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"/../jbook-impl
JBOOK_DIR=$(cygpath -w $JBOOK_DIR)
# Replace \ with /
JBOOK_DIR=$(echo $JBOOK_DIR | sed -e 's/\\/\//g')

JAVA_FILE=$1
# Convert JAVA_FILE to unix filename format
JAVA_FILE=$(cygpath -u $JAVA_FILE)
# Convert from relative to absolute path
JAVA_FILE=$(cd $(dirname $JAVA_FILE); pwd)/$(basename $JAVA_FILE)
# Convert to windows format
JAVA_FILE=$(cygpath -w $JAVA_FILE)
# Replace \ with /
JAVA_FILE=$(echo $JAVA_FILE | sed -e 's/\\/\//g')

WORK_DIR=$(pwd)
# Example call:
# AsmGofer.exe < files/java-nogui.in

echo :p $JBOOK_DIR/files/java.p > temp.txt
echo mainF \"$JAVA_FILE\" >> temp.txt
echo :q >> temp.txt

# Change dir to the dir of this script, because paths in java.p are relative
cd $JBOOK_DIR

./AsmGofer.exe < $WORK_DIR/temp.txt
rm $WORK_DIR/temp.txt
