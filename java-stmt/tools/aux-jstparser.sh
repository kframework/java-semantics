#!/bin/bash

# Parse a java program, and save the parsed result in a file.
# If the file with parse result already exists and it is newer
# than the java file, then nothing happens.

if [ $# -ne 2 ]; then
    echo "Usage: `basename $0` <OUT_DIR> <JAVA_FILE>"
    exit 1
fi

OUT_DIR=$1
JAVA_FILE=$2
BASE_JAVA_FILE=`basename $2`
KAST_FILE=$OUT_DIR/$BASE_JAVA_FILE.kast
TOOLS_DIR="$( cd "$( dirname "$0" )" && pwd )"

if [ ! -f $KAST_FILE ];
then
    # echo "$KAST_FILE not found"
    aux-jstprep.sh $JAVA_FILE > $KAST_FILE
else
    # case regular file
    if [ -f $JAVA_FILE ];
    then
      if test $JAVA_FILE -nt $KAST_FILE
      then
          # echo "$KAST_FILE is too old"
          aux-jstprep.sh $JAVA_FILE > $KAST_FILE
      fi
    else
      # case directory
      if [ -d $JAVA_FILE ];
      then
        LAST_MODIFIED_FILE=$(find $JAVA_FILE -type f -printf '%T@ %p\n' | sort -n | tail -1 | cut -f2- -d" ")
        # TEST_TIME=$(stat -c %Y $LAST_MODIFIED_FILE)
        # KAST_TIME=$(stat -c %Y $KAST_FILE)
        if [ $LAST_MODIFIED_FILE -nt $KAST_FILE ];
        then
          # echo "$KAST_FILE is too old"
          aux-jstprep.sh $JAVA_FILE > $KAST_FILE
        fi
        # echo $TEST_TIME
        # echo $KAST_TIME
      else
        echo "Error, unknown file type: $JAVA_FILE"
      fi
    fi
fi
