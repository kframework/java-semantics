#!/bin/bash

#java semantics preprocessor
# concatenates the parsing result of the given file with java lib classes

if [  $# == 0 ]; then
    echo "Usage: `basename $0` <javaFile>"
    exit 1
fi

javaFile=$1
TOOLS_DIR="$( cd "$( dirname "$0" )" && pwd )"

echo "'ListWrap("

if [ -f $javaFile ];
then
  kjparse.sh $javaFile
  echo ",,"
else
  find -P $javaFile -name "*.java" -type f |
  while read FILE; do
    kjparse.sh $FILE
    echo ",,"
  done
fi

find $TOOLS_DIR/../class-lib -type f \( -name "*java" \) |
  while read libFile; do
    kastFile=$libFile.kast
    if [ ! -f $kastFile ];
    then
        # echo "$kastFile not found"
        kjparse.sh $libFile > $kastFile
    else
        if test $libFile -nt $kastFile
        then
            # echo "$kastFile is too old"
            kjparse.sh $libFile > $kastFile
        fi
    fi

    # $kastFile
    cat $kastFile
    echo ",,"
  done

echo ".K"
echo ")"
