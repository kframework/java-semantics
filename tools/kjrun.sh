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

TIME=true

# OS-dependent choice of timeout
if [[ $(uname) == *Linux* ]] || [[ $(uname) == *Darwin* ]]
  then TIMEOUT_FACTOR=1
  else TIMEOUT_FACTOR=3
fi
TIMEOUT=$((120 * $TIMEOUT_FACTOR))
SEARCH_TIMEOUT_FACTOR=2

INPUT=java

# Pattern example: "<T> <out> OUT:List </out> _</T>"
PATTERN=""

LTLMC=""

# false = show only <out>, true = don't dissolve any cells at the end
CONFIG=false

#Remove all *.kast and *.pkast files
CLEAN=false

#If true then we display the built command in kjrun and aux-kjrun
VERBOSE=false

CMD_SUFFIX=""

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
MAIN_CLASS=`echo "$BASE_JAVA_FILE" | cut -d'.' -f1` #simple file minus extension
TOOLS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
WORK_DIR="$(pwd)"

SEMANTICS_DIR=$(cross-path-native.sh ${TOOLS_DIR}/../src/common)

# OS-dependent selection of krun.
if !(( $TIME == false )); then
 KRUN_CMD="time"
fi

KRUN_CMD="$KRUN_CMD timeout $TIMEOUT"

KRUN_CMD="$KRUN_CMD $(cross-k.sh krun)"

KRUN_CMD="$KRUN_CMD --directory \"$SEMANTICS_DIR\""

if (( $OUTPUT == "none" )); then
KRUN_CMD="$KRUN_CMD --output none"	
fi

KRUN_CMD="$KRUN_CMD --symbolic-execution -w none"

KRUN_CMD="$KRUN_CMD --parser \"$(cross-sh.sh kj-parse-aggreg.sh)\""

KRUN_CMD="$KRUN_CMD -cMainClass=\"ListItem(\\\"$MAIN_CLASS\\\")\""

KRUN_CMD="$KRUN_CMD -cDissolveAllExceptOut=\"true\""

KRUN_CMD="$KRUN_CMD $JAVA_FILE"

# Actual command evaluation
eval ${KRUN_CMD}

if [[ ${CLEAN} == true ]]; then
  rm -rf *.kast
  rm -rf *.pkast
fi
