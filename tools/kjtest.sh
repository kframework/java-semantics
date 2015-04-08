#!/bin/bash

# if no arguments are provided - running the whole test suite.
# if several arguments are provided as directories - running
# tests inside that directories.

if (( "$#" >= 1 )) && [ "$1" == "--help" ]; then
    echo "Usage: `basename $0` [target files/dirs]"
    echo "Or:    `basename $0` <--run|--search|--t1|--t2|--t4|--t4> [target files/dirs]"
    echo "For more options use aux-kjtest.sh"
    exit 0
fi

if [[ $1 == --* ]];
  then
    OPTION=$1
    shift
  else
    OPTION="--t1"
fi

case "$OPTION" in
"--search")
    aux-kjtest.sh -mode search   -threads  6 -timeout 600 -encodeXML false -clean true ${@}
    ;;
"--symbolic")
    aux-kjtest.sh -mode symbolic -threads  6 -timeout 600 -encodeXML false -clean true ${@}
    ;;
"--jdk")
    aux-kjtest.sh -mode jdk      -threads 12 -timeout  10 -encodeXML false -clean true ${@}
    ;;
"--t1")
    aux-kjtest.sh -mode run      -threads  1 -timeout 240 -encodeXML false -clean true ${@}
    ;;
"--t2")
    aux-kjtest.sh -mode run      -threads  2 -timeout 120 -encodeXML false -clean true ${@}
    ;;
"--t4")
    aux-kjtest.sh -mode run      -threads  4 -timeout 120 -encodeXML false -clean true ${@}
    ;;
"--t8")
    aux-kjtest.sh -mode run      -threads  8 -timeout 120 -encodeXML false -clean true ${@}
    ;;
"--t12")
    aux-kjtest.sh -mode run      -threads 12 -timeout 120 -encodeXML false -clean true ${@}
    ;;
*)
    echo "Invalid OPTION: ${OPTION}"
    exit 1
    ;;
esac
