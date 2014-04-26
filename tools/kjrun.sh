#!/bin/bash

# Run a java program with krun.

if (( "$#" < 1 )) || (( "$#" > 2 )); then
    echo "Your command:"
    echo `basename $0` $@
    echo "Usage: `basename $0` <javaFile>"
    echo "Or:    `basename $0` <--full-pretty|--prep-ast|--prep-pretty|--prep-raw|--exec-pretty| \
      --split|--split-cached|--full-kast|--raw|--none| \
      --search|--cached|--search-cached|--debug|--symbolic|--symbolic-cached> <javaFile>"
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
  then SEARCH_TIMEOUT=60
  else SEARCH_TIMEOUT=120
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
"--full-pretty")
    aux-kjrun.sh --time true --timeout ${DEFAULT_TIMEOUT} --mode run-full --output pretty --input java \
      ${JAVA_FILE}
    ;;
"--prep-ast")
    aux-kjrun.sh --time true --timeout ${DEFAULT_TIMEOUT} --mode run-prep-ast --output raw --input java \
      ${JAVA_FILE}
    ;;
"--prep-pretty")
    aux-kjrun.sh --time true --timeout ${DEFAULT_TIMEOUT} --mode run-prep-config --output pretty --input java \
      ${JAVA_FILE}
    ;;
"--prep-raw")
    aux-kjrun.sh --time true --timeout ${DEFAULT_TIMEOUT} --mode run-prep-config --output raw --input java \
      ${JAVA_FILE}
    ;;
"--exec-pretty")
    aux-kjrun.sh --time true --timeout ${DEFAULT_TIMEOUT} --mode run-exec --output pretty --input kast \
      ${JAVA_FILE}
    ;;
"--split")
    echo "preprocess:"

    aux-kjrun.sh --time true --timeout ${DEFAULT_TIMEOUT} --mode run-prep-ast --output raw --input java \
      ${JAVA_FILE} > ${PKAST_FILE}

    echo
    echo "execute:"
    echo

    aux-kjrun.sh --time true --timeout ${DEFAULT_TIMEOUT} --mode run-exec --output pretty --input kast \
      ${PKAST_FILE}

    rm -f ${PKAST_FILE}
    ;;
"--split-cached")
    echo "preprocess:"

    if [ ! -e ${PKAST_FILE} ];
      then aux-kjrun.sh --time true --timeout ${DEFAULT_TIMEOUT} --mode run-prep-ast --output raw --input java \
        ${JAVA_FILE} > ${PKAST_FILE}
    fi

    echo
    echo "execute:"
    echo

    aux-kjrun.sh --time true --timeout ${DEFAULT_TIMEOUT} --mode run-exec --output pretty --input kast \
      ${PKAST_FILE}
    ;;
"--full-kast")
    aux-kjrun.sh --time true --timeout ${DEFAULT_TIMEOUT} --mode run-full --output pretty --input kast \
      ${JAVA_FILE}
    ;;
"--raw")
    aux-kjrun.sh --time true --timeout ${DEFAULT_TIMEOUT} --mode run-full --output raw --input java ${JAVA_FILE}
    ;;
"--none")
    aux-kjrun.sh --time true --timeout ${DEFAULT_TIMEOUT} --mode run-full --output none --input java ${JAVA_FILE}
    ;;
"--search")
    aux-kjrun.sh --time true --timeout ${SEARCH_TIMEOUT} --mode search --output pretty --input java ${JAVA_FILE}
    ;;
"--cached")
    if [ ! -e ${PKAST_FILE} ];
      then aux-kjrun.sh --time false --timeout 0 --mode run-prep-ast --output raw --input kast-cache ${JAVA_FILE} \
        > ${PKAST_FILE}
    fi

    aux-kjrun.sh --time false --timeout 0 --mode run-exec --output none --input kast ${PKAST_FILE}
    ;;
"--search-cached")
    aux-kjrun.sh --time false --timeout 0 --mode search-count --output raw --input kast-cache ${JAVA_FILE}
    ;;
"--debug")
    aux-kjrun.sh --time false --timeout 0 --mode debug --output pretty --input java ${JAVA_FILE}
    ;;
"--symbolic")
    aux-kjrun.sh --time true --timeout ${SYMBOLIC_TIMEOUT} --mode symbolic \
      --output pretty --input java ${JAVA_FILE}
    ;;
"--symbolic-cached")
    aux-kjrun.sh --time false --timeout 0 --mode symbolic-count --output raw --input kast-cache ${JAVA_FILE}
    ;;
*)
    echo "Invalid option: $OPTION"
    echo "Usage: `basename $0` <javaFile>"
    echo "Or:    `basename $0` <--full-pretty|--prep-ast|--prep-pretty|--prep-raw|--exec-pretty| \
      --split|--split-cached|--full-kast|--raw|--none| \
      --search|--cached|--search-cached|--debug|--symbolic|--symbolic-cached> <javaFile>"
    echo "For more options use aux-kjrun.sh"
    exit 1
    ;;
esac
