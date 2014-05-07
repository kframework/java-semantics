#!/bin/bash

# Run a java program with krun.

if (( "$#" < 1 )) || (( "$#" > 2 )); then
    echo "Your command:"
    echo `basename $0` $@
    echo "Usage: `basename $0` <javaFile>"
    echo "Or:    `basename $0` <--prep-ast|--prep-pretty|--prep-raw|--exec-pretty| \
      --split|--split-cached|--split-none| \
      --search|--search-cached|--search-pattern|--debug|--symbolic|--symbolic-cached> <javaFile>"
    echo "For more options use aux-kjrun.sh"
    exit 1
fi

if (( "$#" == 1 ));
  then
    OPTION=--split
    JAVA_FILE=$1
  else
    OPTION=$1
    JAVA_FILE=$2
fi

# OS-dependent choice of timeout
if [[ $(uname) == *Linux* ]]
  then DEFAULT_TIMEOUT=30
  else DEFAULT_TIMEOUT=120
fi

# OS-dependent choice of timeout
if [[ $(uname) == *Linux* ]]
  then SEARCH_TIMEOUT=120
  else SEARCH_TIMEOUT=240
fi

# OS-dependent choice of timeout
if [[ $(uname) == *Linux* ]]
  then SYMBOLIC_TIMEOUT=120
  else SYMBOLIC_TIMEOUT=240
fi

BASE_JAVA_FILE=`basename ${JAVA_FILE}`  #simple file/dir name
PKAST_FILE=`echo "$BASE_JAVA_FILE" | sed 's#/*$##'` # remove trailing slashes, important if JAVA_FILE is dir
PKAST_FILE=${PKAST_FILE}.pkast

case "$OPTION" in
"--prep-ast")
    aux-kjrun.sh --time true --timeout ${DEFAULT_TIMEOUT} --mode run-prep-ast --output raw --input java \
      --pattern 0 ${JAVA_FILE}
    ;;
"--prep-pretty")
    aux-kjrun.sh --time true --timeout ${DEFAULT_TIMEOUT} --mode run-prep-config --output pretty --input java \
      --pattern 0 ${JAVA_FILE}
    ;;
"--prep-raw")
    aux-kjrun.sh --time true --timeout ${DEFAULT_TIMEOUT} --mode run-prep-config --output raw --input java \
      --pattern 0 ${JAVA_FILE}
    ;;
"--exec-pretty")
    aux-kjrun.sh --time true --timeout ${DEFAULT_TIMEOUT} --mode run-exec --output pretty --input kast \
      --pattern 0 ${JAVA_FILE}
    ;;
"--split")
    echo "preprocess:"

    if [ ! -e ${PKAST_FILE} ];
      then aux-kjrun.sh --time true --timeout ${DEFAULT_TIMEOUT} --mode run-prep-ast --output raw --input java \
        --pattern 0 ${JAVA_FILE} > ${PKAST_FILE}
    fi

    echo
    echo "execute:"
    echo

    aux-kjrun.sh --time true --timeout ${DEFAULT_TIMEOUT} --mode run-exec --output pretty --input kast \
      --pattern 0 ${PKAST_FILE}
    ;;
"--split-cached")
    if [ ! -e ${PKAST_FILE} ];
      then aux-kjrun.sh --time false --timeout 0 --mode run-prep-ast --output raw --input kast-cache --pattern 0 \
        ${JAVA_FILE} > ${PKAST_FILE}
    fi

    aux-kjrun.sh --time false --timeout 0 --mode run-exec --output none --input kast --pattern 0 ${PKAST_FILE}
    ;;
"--none")
    if [ ! -e ${PKAST_FILE} ];
      then aux-kjrun.sh --time false --timeout 0 --mode run-prep-ast --output raw --input kast-cache --pattern 0 \
        ${JAVA_FILE} > ${PKAST_FILE}
    fi
    aux-kjrun.sh --time true --timeout ${DEFAULT_TIMEOUT} --mode run-exec --output none --input kast \
      --pattern 0 ${PKAST_FILE}

    rm -rf ${PKAST_FILE}
    ;;

"--search")
    echo "preprocess:"
    if [ ! -e ${PKAST_FILE} ];
      then aux-kjrun.sh --time true --timeout ${DEFAULT_TIMEOUT} --mode run-prep-ast --output raw --input java \
        --pattern 0 ${JAVA_FILE} > ${PKAST_FILE}
    fi

    echo
    echo "execute:"
    echo
    aux-kjrun.sh --time true --timeout ${SEARCH_TIMEOUT} --mode search --output pretty --input kast \
      --pattern 0 ${PKAST_FILE}
    ;;
"--search-cached")
    if [ ! -e ${PKAST_FILE} ];
      then aux-kjrun.sh --time false --timeout 0 --mode run-prep-ast --output raw --input kast-cache ${JAVA_FILE} \
        --pattern 0 > ${PKAST_FILE}
    fi
    aux-kjrun.sh --time false --timeout 0 --mode search-count --output raw --input kast --pattern 0 ${PKAST_FILE}
    ;;

"--search-pattern")
    echo "preprocess:"
    if [ ! -e ${PKAST_FILE} ];
      then aux-kjrun.sh --time true --timeout ${DEFAULT_TIMEOUT} --mode run-prep-ast --output raw --input java \
        --pattern 0 ${JAVA_FILE} > ${PKAST_FILE}
    fi

    echo
    echo "execute:"
    echo
    aux-kjrun.sh --time true --timeout ${SEARCH_TIMEOUT} --mode search-pattern --output pretty --input kast \
        --pattern "<T> <out> _ </out> ...</T>" \
        ${PKAST_FILE}
    ;;
#        --pattern "<T> <threads> <thread> <methodContext> \
#                          <env>... _ ...</env> ...</methodContext> ...</thread> </threads>  \
#                          <store>... _ ...</store> ...</T>" \

"--debug")
    echo "preprocess:"

    if [ ! -e ${PKAST_FILE} ];
      then aux-kjrun.sh --time true --timeout ${DEFAULT_TIMEOUT} --mode run-prep-ast --output raw --input java \
        --pattern 0 ${JAVA_FILE} > ${PKAST_FILE}
    fi

    echo
    echo "execute:"
    echo

    aux-kjrun.sh --time false --timeout 0 --mode debug --output pretty --input kast \
      --pattern 0 ${PKAST_FILE}
    ;;

"--symbolic")
    echo "preprocess:"

    if [ ! -e ${PKAST_FILE} ];
      then aux-kjrun.sh --time true --timeout ${DEFAULT_TIMEOUT} --mode run-prep-ast --output raw --input java \
        --pattern 0 ${JAVA_FILE} > ${PKAST_FILE}
    fi

    echo
    echo "execute:"
    echo

    aux-kjrun.sh --time true --timeout ${SYMBOLIC_TIMEOUT} --mode symbolic --output pretty --input kast \
      --pattern 0 ${PKAST_FILE}
    ;;

"--symbolic-cached")
    if [ ! -e ${PKAST_FILE} ];
      then aux-kjrun.sh --time false --timeout 0 --mode run-prep-ast --output raw --input kast-cache --pattern 0 \
        ${JAVA_FILE} > ${PKAST_FILE}
    fi
    aux-kjrun.sh --time false --timeout 0 --mode symbolic-count --output raw --input kast --pattern 0 ${PKAST_FILE}
    ;;

*)
    echo "Invalid option: $OPTION"
    echo "General help:"
    echo
    kjrun.sh
    exit 1
    ;;
esac
