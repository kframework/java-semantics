#!/bin/bash

# Postprocess the result of jbook-raw-run a java file.
# Input is received as an argument file.
# Output is printed to the standart output.

if [ $# -ne 1 ]; then
    echo "Usage: `basename $0` <rawOutFile>"
    echo "You entered:"
    echo $0
    for i in $*; do
      echo $i
    done
    exit 1
fi

THIS_COMMAND=$(cygpath -u ${BASH_SOURCE[0]})
TOOLS_DIR="$( cd "$( dirname "$THIS_COMMAND" )" && pwd )"
RAW_OUT_FILE=$1

# Index of the first line to keep in the jbook-raw-run result
FIRST_TO_PRINT=71

# Index of the first byte of the first line to keep in the output,
# after $FIRST_TO_PRINT filter have been applied.
FIRST_BYTE_TO_PRINT=3

# The number of lines to remove at the end of jbook-raw-run result
SKIP_TAIL=7

# The number of lines to remove if the run was unsuccessful. Keeps the number of steps performed.
SKIP_TAIL_ALT=5

tail -n+$FIRST_TO_PRINT $RAW_OUT_FILE > temp2.out
tail -c+$FIRST_BYTE_TO_PRINT temp2.out > temp3.out
head -n-$SKIP_TAIL temp3.out > temp4.out
head -n-$SKIP_TAIL temp3.out > temp4.out

# Just to convert spaces into linux format
sed -i -e 's/x/x/g' temp4.out

if [ -s temp4.out ]
  then cat temp4.out
  else head -n-$SKIP_TAIL_ALT temp3.out
fi
