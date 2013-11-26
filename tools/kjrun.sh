#!/bin/bash

# Run a java program with krun.

if (( "$#" < 1 )) || (( "$#" > 2 )); then
    echo "Your command:"
    echo `basename $0` $@
    echo "Usage: `basename $0` <javaFile> or `basename $0` <exec|strictness|threading|latex|pdf>"
    echo "Or:    `basename $0` <pretty|raw|none> <javaFile>"
    echo "For more options use aux-kjrun2.sh"
    exit 1
fi

if (( "$#" == 1 ));
  then
    OPTION=pretty
    JAVA_FILE=$1
  else
    OPTION=$1
    JAVA_FILE=$2
fi

# OS-dependent choice of default timeout
if [[ $(uname) == *Linux* ]]
  then DEFAULT_TIMEOUT=30
  else DEFAULT_TIMEOUT=120
fi

case "$OPTION" in
"pretty")
    aux-kjrun2.sh --time true --timeout ${DEFAULT_TIMEOUT} --debug false --output ${OPTION} --kast-cache false ${JAVA_FILE}
    ;;
"raw")
    $KOMPILE_CMD -v -transition "transition-strictness" java
    ;;
"none")
    aux-kjrun2.sh --time false --timeout 0 --debug false --output ${OPTION} --kast-cache true ${JAVA_FILE}
    ;;
*)
    echo "Invalid option: $OPTION"
    echo "Usage: `basename $0` <javaFile> or `basename $0` <exec|strictness|threading|latex|pdf>"
    echo "Or: `basename $0` <pretty|raw|none> <javaFile>"
    echo "For more options use aux-kjrun2.sh"
    exit 1
    ;;
esac
