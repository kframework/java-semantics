#!/bin/bash

# Run jbook-java on the target file using asm-wrapper.java
# Also good for running individual programs.

if [ $# -ne 1 ]; then
    echo "Usage: `basename $0` <javaFile>"
    echo "You entered:"
    echo $0
    for i in $*; do
      echo $i
    done
    exit 1
fi

THIS_COMMAND=$(cygpath -u ${BASH_SOURCE[0]})
TOOLS_DIR="$( cd "$( dirname "$THIS_COMMAND" )" && pwd )"
JAVA_FILE=$1

# Index of the first line to keep in the jbook-raw-run result
FIRST_TO_PRINT=71

# Index of the first byte of the first line to keep in the output,
# after $FIRST_TO_PRINT filter have been applied.
FIRST_BYTE_TO_PRINT=3

# The number of lines to remove at the end of jbook-raw-run result
SKIP_TAIL=7

# The number of lines to remove if the run was unsuccessful. Keeps the number of steps performed.
SKIP_TAIL_ALT=5

$TOOLS_DIR/jbook-raw-run.sh $JAVA_FILE > temp1.out
tail -n+$FIRST_TO_PRINT temp1.out > temp2.out
tail -c+$FIRST_BYTE_TO_PRINT temp2.out > temp3.out
head -n-$SKIP_TAIL temp3.out > temp4.out
head -n-$SKIP_TAIL temp3.out > temp4.out

if [ -s temp4.out ]
  then cat temp4.out
  else head -n-$SKIP_TAIL_ALT temp3.out
fi
rm temp*.out
