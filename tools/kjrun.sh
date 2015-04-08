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
  --ltlmc=<LTL Formula> LTL formula to model-check. If specified, --pattern option is reset.
  --config - Display the full configuration.
  -v | --verbose  Print produced commands for aux-kjrun and krun
  -c | --clean    Delete cache files after execution
  -t | --timeout=<timeout in s> - overwrites default timeout
EOF
}

function errorMsg() {
    echo "Your command:"
    echo `basename $0` ${ORIGINAL_ARGS}
    echo
    usage
    exit 1
}

function setSearchPattern() {
  if [[ ${PATTERN} == "" ]]; then
    PATTERN="<T> <threads> Threads:Bag </threads> <out> Out:List </out> _</T>"
  fi
}

#If true then we have to run preprocessing semantics first
PREP_FIRST=true

TIME=true

# OS-dependent choice of timeout
if [[ $(uname) == *Linux* ]] || [[ $(uname) == *Darwin* ]]
  then TIMEOUT_FACTOR=1
  else TIMEOUT_FACTOR=3
fi
TIMEOUT=$((30 * $TIMEOUT_FACTOR))
SEARCH_TIMEOUT_FACTOR=2

MODE=run-exec
PREP_OUTPUT=kast
OUTPUT=pretty
PREP_INPUT=java
INPUT=kast

# Pattern example: "<T> <out> OUT:List </out> _</T>"
PATTERN=""

LTLMC=""

# false = show only <out>, true = don't dissolve any cells at the end
CONFIG=false

#Remove all *.kast and *.pkast files
CLEAN=false

#If true then we display the built command in kjrun and aux-kjrun
VERBOSE=false

#If true then don't show any messages besides the actual output
SILENT=false

CMD_SUFFIX=""
COUNT_CMD_SUFFIX="| grep \"Solution\" | wc -l"
PREP_AST_CMD_SUFFIX="| sed 's/\s*\([[:graph:]].*[[:graph:]]\)\s*/\1/g'"
PREP_AST_CMD_SUFFIX="$PREP_AST_CMD_SUFFIX | tr -d '\n'"
PREP_AST_CMD_SUFFIX="$PREP_AST_CMD_SUFFIX | sed -r 's/.*<program>//g' | sed -r 's/<\/program>.*//g'"
PREP_AST_CMD_SUFFIX="$PREP_AST_CMD_SUFFIX | sed 's/KListWrap/ListWrap/g'"

while [[ ${1:0:1} == - ]]; do
  PARAM=`echo $1 | awk -F= '{print $1}'`
  ARG=$1
  CUT_AMOUNT=$((${#PARAM} + 1))
  VALUE=${ARG:${CUT_AMOUNT}}

  case ${PARAM} in
    "-h" | "--help")
      usage
      exit
      ;;
    "--prep-ast")
      PREP_FIRST=false
      MODE=run-prep-ast
      CMD_SUFFIX=${PREP_AST_CMD_SUFFIX}
      OUTPUT=$PREP_OUTPUT
      INPUT=java
      TIME=false
      TIMEOUT=0

      ;;
    "--prep-pretty")
      PREP_FIRST=false
      MODE=run-prep-config
      INPUT=java
      ;;
    "--prep-raw")
      PREP_FIRST=false
      MODE=run-prep-config
      OUTPUT=none
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
      SILENT=true
      ;;
    "--split-none")
      PREP_INPUT=kast-cache
      OUTPUT=none
      ;;
    "--search")
      TIMEOUT=$(($TIMEOUT * $SEARCH_TIMEOUT_FACTOR))
      MODE=search
      setSearchPattern
      ;;
    "--search-cached")
      TIME=false
      TIMEOUT=0
      PREP_INPUT=kast-cache
      MODE=search
      CMD_SUFFIX=${COUNT_CMD_SUFFIX}
      SILENT=true
      setSearchPattern
      ;;
    "--debug")
      TIME=false
      TIMEOUT=0
      MODE=debug
      ;;
    "--symbolic")
      TIMEOUT=$(($TIMEOUT * $SEARCH_TIMEOUT_FACTOR))
      MODE=symbolic
      setSearchPattern
      ;;
    "--symbolic-cached")
      TIME=false
      TIMEOUT=0
      PREP_INPUT=kast-cache
      MODE=symbolic
      CMD_SUFFIX=${COUNT_CMD_SUFFIX}
      SILENT=true
      setSearchPattern
      ;;

# Extra options
    "--pattern")
      PATTERN=${VALUE}
      ;;
    "--ltlmc")
      LTLMC=${VALUE}
      PATTERN=""
      ;;
    "--config")
      CONFIG=true
      ;;
    "-v" | "--verbose")
      VERBOSE=true
      ;;
    "-c" | "--clean")
      CLEAN=true
      ;;
    "-t" | "--timeout")
      TIMEOUT=${VALUE}
      SEARCH_TIMEOUT_FACTOR=1
      ;;
    *)
      echo "Invalid option: $PARAM"
      errorMsg
      ;;
  esac
  shift
done

JAVA_FILE=$(cross-path-unix.sh ${1})
if [[ ${JAVA_FILE} == "" ]]; then
  echo "Target file missing"
  errorMsg
fi

BASE_JAVA_FILE=`basename ${JAVA_FILE}`  #simple file/dir name
PKAST_FILE=`echo "$BASE_JAVA_FILE" | sed 's#/*$##'` # remove trailing slashes, important if JAVA_FILE is dir
PKAST_FILE=${PKAST_FILE}.pkast


#Actual execution
if [[ ${SILENT} == false ]]; then
  echo "preprocess:"
fi

if [[ ${PREP_FIRST} == true ]]; then
  if [ ! -e ${PKAST_FILE} ]; then
    CMD="aux-kjrun.sh --mode=run-prep-ast --output=${PREP_OUTPUT} \
      --cmd-suffix=\"${PREP_AST_CMD_SUFFIX}\" \
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

if [[ ${SILENT} == false ]]; then
  echo
  echo "execute:"
  echo
fi

OUTPUT="none"

CMD="aux-kjrun.sh --time=${TIME} --timeout=${TIMEOUT} --mode=${MODE} --output=${OUTPUT} --input=${INPUT} \
  --pattern=\"${PATTERN}\" --ltlmc=\"${LTLMC}\" --config=\"${CONFIG}\" \
  --verbose=${VERBOSE} --cmd-suffix=\"${CMD_SUFFIX}\" ${PKAST_FILE}"
if [[ ${VERBOSE} == true ]]; then
  echo "EXEC cmd:"
  echo ${CMD}
  echo
fi

# Actual command evaluation
#echo $CMD > auxInput.txt

eval ${CMD}

if [[ ${CLEAN} == true ]]; then
  rm -rf *.kast
  rm -rf *.pkast
fi
