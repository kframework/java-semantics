#!/bin/bash

# Run a java program with krun.

ORIGINAL_ARGS=$@

function usage()
{
cat <<-EOF
Usage: `basename $0` [OPTION] <javaFile>
For more options use aux-kjrun.sh

  OPTION

  --prep-ast
  --prep-pretty
  --prep-raw
  --exec-pretty
  --split
  --split-cached
  --split-none
  --search
  --search-cached
  --debug
  --symbolic
  --symbolic-cached

  ADDITIONAL OPTIONS:

  --pattern=<PATTERN>  Search pattern. May be used in combination with any option
  -v | --verbose  Print produced commands for aux-kjrun and krun
  -c | --clean    Delete cache files after execution
EOF
}

function errorMsg() {
    echo "Your command:"
    echo `basename $0` ${ORIGINAL_ARGS}
    echo
    usage
    exit 1
}

#If true then we have to run preprocessing semantics first
PREP_FIRST=true

TIME=true

# OS-dependent choice of timeout
if [[ $(uname) == *Linux* ]]
  then TIMEOUT_FACTOR=3
  else TIMEOUT_FACTOR=1
fi
TIMEOUT=$((30 * $TIMEOUT_FACTOR))
SEARCH_TIMEOUT_FACTOR=2

MODE=run-exec
PREP_OUTPUT=raw
OUTPUT=pretty
PREP_INPUT=java
INPUT=kast

# Pattern example: "<T> <out> OUT:List </out> _</T>"
PATTERN=0

#Remove all *.kast and *.pkast files
CLEAN=false

#If true then we display the built command in kjrun and aux-kjrun
VERBOSE=false

while [[ ${1:0:1} == - ]]; do
  PARAM=`echo $1 | awk -F= '{print $1}'`
  VALUE=`echo $1 | awk -F= '{print $2}'`
  case ${PARAM} in
    "-h" | "--help")
      usage
      exit
      ;;
    "--prep-ast")
      PREP_FIRST=false
      MODE=run-prep-ast
      OUTPUT=raw
      INPUT=java
      ;;
    "--prep-pretty")
      PREP_FIRST=false
      MODE=run-prep-config
      INPUT=java
      ;;
    "--prep-raw")
      PREP_FIRST=false
      MODE=run-prep-config
      OUTPUT=raw
      INPUT=java
      ;;
    "--exec-pretty")
      PREP_FIRST=false
      MODE=run-exec
      ;;
    "--split") #everything default
      ;;
    "--split-cached")
      TIME=false
      TIMEOUT=0
      PREP_INPUT=kast-cache
      OUTPUT=none
      ;;
    "--split-none")
      PREP_INPUT=kast-cache
      OUTPUT=none
      ;;
    "--search")
      TIMEOUT=$(($TIMEOUT * $SEARCH_TIMEOUT_FACTOR))
      MODE=search
      ;;
    "--search-cached")
      TIME=false
      TIMEOUT=0
      PREP_INPUT=kast-cache
      MODE=search-count
      OUTPUT=raw
      ;;
    "--debug")
      TIME=false
      TIMEOUT=0
      MODE=debug
      ;;
    "--symbolic")
      TIMEOUT=$(($TIMEOUT * $SEARCH_TIMEOUT_FACTOR))
      MODE=symbolic
      ;;
    "--symbolic-cached")
      TIME=false
      TIMEOUT=0
      PREP_INPUT=kast-cache
      MODE=symbolic-count
      OUTPUT=raw
      ;;

# Extra options
    "--pattern")
      PATTERN=\"${VALUE}\"
      ;;
    "-v" | "--verbose")
      VERBOSE=true
      ;;
    "-c" | "--clean")
      CLEAN=true
      ;;
    *)
      echo "Invalid option: $PARAM"
      errorMsg
      ;;
  esac
  shift
done

JAVA_FILE=${1}
if [[ ${JAVA_FILE} == "" ]]; then
  echo "Target file missing"
  errorMsg
fi

BASE_JAVA_FILE=`basename ${JAVA_FILE}`  #simple file/dir name
PKAST_FILE=`echo "$BASE_JAVA_FILE" | sed 's#/*$##'` # remove trailing slashes, important if JAVA_FILE is dir
PKAST_FILE=${PKAST_FILE}.pkast


#Actual execution
if [[ ${OUTPUT} == pretty ]]; then
  echo "preprocess:"
fi

if [[ ${PREP_FIRST} == true ]]; then
  if [ ! -e ${PKAST_FILE} ]; then
    CMD="aux-kjrun.sh --time=${TIME} --timeout=${TIMEOUT} --mode=run-prep-ast --output=${PREP_OUTPUT} \
      --input=${PREP_INPUT} --verbose=${VERBOSE} ${JAVA_FILE} > ${PKAST_FILE}"
    if [[ ${VERBOSE} == true ]]; then
      echo "PREP cmd:"
      echo ${CMD}
      echo
    fi
    eval ${CMD}
  fi
else
  PKAST_FILE=${JAVA_FILE}
fi

if [[ ${OUTPUT} == pretty ]]; then
  echo
  echo "execute:"
  echo
fi

CMD="aux-kjrun.sh --time=${TIME} --timeout=${TIMEOUT} --mode=${MODE} --output=${OUTPUT} --input=${INPUT} \
  --pattern=${PATTERN} --verbose=${VERBOSE} ${PKAST_FILE}"
if [[ ${VERBOSE} == true ]]; then
  echo "EXEC cmd:"
  echo ${CMD}
  echo
fi

# Actual command evaluation
eval ${CMD}

if [[ ${CLEAN} == true ]]; then
  rm -rf *.kast
  rm -rf *.pkast
fi
