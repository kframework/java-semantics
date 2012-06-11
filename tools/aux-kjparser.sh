# Parse a java program, and savethe parsed result in a file.
# Output that file. If the file with parse result already exists and is newer
# than java file, just output that file.

#!/bin/bash

if [ $# -ne 2 ]; then
    echo "Usage: `basename $0` <outDir> <javaFile>"
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
    java -cp $TOOLS_DIR/../parser/JavaParser.jar ro.uaic.info.fmse.parser.Main $javaFile > $kastFile
else
    if test $javaFile -nt $kastFile
    then
        # echo "$kastFile is too old"
        java -cp $TOOLS_DIR/../parser/JavaParser.jar ro.uaic.info.fmse.parser.Main $javaFile > $kastFile
    fi
fi

cat $kastFile
