#!/bin/bash

#Preprocesses all java files in the SRC_DIR, using preprocess.sh, and stores them result in OUT_DIR

if [  $# != 2 ]; then
    echo "Usage: `basename $0` <SRC_DIR> <OUT_DIR>"
    exit 1
fi

SRC_DIR=$1
OUT_DIR=$2
SRC_LEN=${#SRC_DIR}

find $SRC_DIR -name '*.java' -type f | while IFS=$'\n' read -r FILE
do
  REL_FILE=${FILE:$SRC_LEN}
  #echo $REL_FILE

  mkdir -p "$(dirname $OUT_DIR/$REL_FILE)"
  ~/java-semantics/java-fan/tools/preprocess.sh $FILE > $OUT_DIR/$REL_FILE
done
