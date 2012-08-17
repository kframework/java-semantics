#!/bin/bash

# Parse a java program, and save the parsed result in a file.
# Output that file. If the file with parse result already exists and it is newer
# than the java file, just output that file.

if [ $# -ne 3 ]; then
    echo "Usage: `basename $0` <outDir> <javaFile> empty.txt"
    exit 1
fi

outDir=$1
javaFile=$2
baseJavaFile=`basename $2`
kastFile=$outDir/$baseJavaFile.kast
TOOLS_DIR="$( cd "$( dirname "$0" )" && pwd )"

if [ ! -f $kastFile ];
then
    # echo "$kastFile not found"
    aux-kjprep.sh $javaFile > $kastFile
else
    if [ -f $javaFile ];
    then
      if test $javaFile -nt $kastFile
      then
          # echo "$kastFile is too old"
          aux-kjprep.sh $javaFile > $kastFile
      fi
    else
      if [ -d $javaFile ];
      then
        LAST_MODIFIED_FILE=$(find $javaFile -type f -printf '%p\n' | sort -r -k1 | head -n1)
        # TEST_TIME=$(stat -c %Y $LAST_MODIFIED_FILE)
        # KAST_TIME=$(stat -c %Y $kastFile)
        if [ $LAST_MODIFIED_FILE -nt $kastFile ];
        then
          # echo "$kastFile is too old"
          aux-kjprep.sh $javaFile > $kastFile
        fi
        # echo $TEST_TIME
        # echo $KAST_TIME
      else
        echo "Error, unknown file type: $javaFile"
      fi
    fi
fi

cat $kastFile
