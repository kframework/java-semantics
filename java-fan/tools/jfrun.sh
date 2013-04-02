#!/bin/bash

#Run the given program with java-fan

if [  $# != 1 ]; then
    echo "Usage: `basename $0` <JAVA FILE or DIR>"
    exit 1
fi

JAVA_FILE=$1
BASE_JAVA_FILE=`basename $JAVA_FILE`
MAIN_CLASS=`echo "$BASE_JAVA_FILE" | cut -d'.' -f1`

mkdir -p temp
#find ~/java-semantics/class-lib -type f \( -name "*java" \) |
#  while read LIB_FILE; do
#    cp $LIB_FILE temp
#  done
cp ~/java-semantics/java-fan/class-lib/Object.java temp
cp ~/java-semantics/java-fan/class-lib/RuntimeException.java temp
cp -r $JAVA_FILE temp

java -cp ~/java-semantics/java-fan/classpath javarl.JavaRL -cls temp -op temp/out.txt $MAIN_CLASS >/dev/null

# cat temp/out.txt
# print out file from the second line
tail -n+2 temp/out.txt
rm -rf temp
