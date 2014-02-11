#!/bin/bash

# Run a java program with krun.

if (( "$#" < 1 )) || (( "$#" > 2 )); then
    echo "Your command:"
    echo `basename $0` $@
    echo "Usage: `basename $0` <javaFile>"
    echo "Or:    `basename $0` <--pretty|--raw|--none|--search|--cached|--search-cached|--debug|--symbolic|--symbolic-cached> <javaFile>"
    echo "For more options use aux-kjrun.sh"
    exit 1
fi

if (( "$#" == 1 ));
  then
    OPTION=--pretty
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

case "$OPTION" in
"--pretty")
    aux-kjrun.sh --time true --timeout ${DEFAULT_TIMEOUT} --mode run --output pretty --kast-cache false ${JAVA_FILE}
    ;;
"--raw")
    aux-kjrun.sh --time true --timeout ${DEFAULT_TIMEOUT} --mode run --output raw --kast-cache false ${JAVA_FILE}
    ;;
"--none")
    aux-kjrun.sh --time true --timeout ${DEFAULT_TIMEOUT} --mode run --output none --kast-cache false ${JAVA_FILE}
    ;;
"--search")
    aux-kjrun.sh --time true --timeout ${SEARCH_TIMEOUT} --mode search --output pretty --kast-cache false ${JAVA_FILE}
    ;;
"--cached")
    aux-kjrun.sh --time false --timeout 0 --mode run --output none --kast-cache true ${JAVA_FILE}
    ;;
"--search-cached")
    aux-kjrun.sh --time false --timeout 0 --mode search-count --output raw --kast-cache true ${JAVA_FILE}
    ;;
"--debug")
    aux-kjrun.sh --time false --timeout 0 --mode debug --output pretty --kast-cache false ${JAVA_FILE}
    ;;
"--symbolic")
    aux-kjrun.sh --time true --timeout ${SYMBOLIC_TIMEOUT} --mode symbolic \
      --output pretty --kast-cache false ${JAVA_FILE}
    ;;
"--symbolic-cached")
    aux-kjrun.sh --time false --timeout 0 --mode symbolic-count --output raw --kast-cache true ${JAVA_FILE}
    ;;
*)
    echo "Invalid option: $OPTION"
    echo "Usage: `basename $0` <javaFile>"
    echo "Or:    `basename $0` <--pretty|--raw|--none|--search|--cached|--search-cached|--debug|--symbolic|--symbolic-cached> <javaFile>"
    echo "For more options use aux-kjrun.sh"
    exit 1
    ;;
esac
