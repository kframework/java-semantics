#!/bin/bash

#java semantics preprocessor
# concatenates the parsing result of the given file with java lib classes

if [  $# == 0 ]; then
    echo "Usage: `basename $0` <javaFile>"
    exit 1
fi

JAVA_FILE=$1
TOOLS_DIR="$( cd "$( dirname "$0" )" && pwd )"

echo "\`'ListWrap\`("

if [ -f ${JAVA_FILE} ];
then
  kjparse.sh ${JAVA_FILE}
  echo ","
else
  find -P ${JAVA_FILE} -name "*.java" -type f |
  while read FILE; do
    kjparse.sh ${FILE}
    echo ","
  done
fi

find ${TOOLS_DIR}/../class-lib -type f \( -name "*java" \) |
  while read LIB_FILE; do
    KAST_FILE=${LIB_FILE}.kast
    if [ ! -f ${KAST_FILE} ];
    then
        # echo "$KAST_FILE not found"
        kjparse.sh ${LIB_FILE} > ${KAST_FILE}
    else
        if test ${LIB_FILE} -nt ${KAST_FILE}
        then
            # echo "$KAST_FILE is too old"
            kjparse.sh ${LIB_FILE} > ${KAST_FILE}
        fi
    fi

    # $KAST_FILE
    cat ${KAST_FILE}
    echo ","
  done

echo ".::K"
echo ")"
