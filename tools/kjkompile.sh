#!/bin/bash

# kompile java-prep into one of 3 possible outputs:
# exec - regular kompilation, for execution
# latex - compile into latex
# pdf - compile into pdf

# kompile java-exec into one of five possible outputs:
# exec - regular kompilation, for execution
# strictness - kompilation for strictness checking
# threading - kompilation for threading checking
# latex - compile into latex
# pdf - compile into pdf

ORIGINAL_ARGS=$@

function usage()
{
cat <<-EOF
Usage: `basename $0` [OPTION] <javaFile>
For more options use aux-kjrun.sh

  OPTION

  --exec, the default option
  --exec-only
  --strictness
  --threading
  --threading-sync
  --symbolic
  --prep-latex
  --prep-pdf
  --exec-latex
  --methods-latex
  --methods-pdf
  --new-latex
  --new-pdf
  --modules-latex
  --help

  ADDITIONAL OPTIONS:
  -v | --verbose  Passes -v to kompile
EOF
}

function errorMsg() {
    echo "Your command:"
    echo `basename $0` ${ORIGINAL_ARGS}
    echo
    usage
    exit 1
}

OPTION=--exec
EXTRA_OPTS=""

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
    "--exec"|"--exec-only" \
      |"--strictness"|"--threading"|"--threading-sync"|"--symbolic"|"--prep-latex"|"--prep-pdf" \
      |"--exec-latex"|"--methods-latex"|"--methods-pdf"|"--new-latex"|"--new-pdf"|"--modules-latex")
      OPTION=${PARAM}
      ;;
    "-v" | "--verbose")
      EXTRA_OPTS="$EXTRA_OPTS -v"
      ;;
    "--debug")
      EXTRA_OPTS="$EXTRA_OPTS --debug"
      ;;
    *)
      echo "Invalid option: $PARAM"
      errorMsg
      ;;
  esac
  shift
done

TOOLS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
KOMPILE_CMD=$(cross-k.sh kompile)

KOMPILE_CMD="$KOMPILE_CMD $EXTRA_OPTS"

case "$OPTION" in
"--exec")
    echo
    echo
    echo "Preprocessing semantics:"
    # "&> file" redirects both stdin and stderr to the given file
    $KOMPILE_CMD -d exec exec/java-exec.k &> exec-out.txt \
        & $KOMPILE_CMD -d prep prep/java-prep.k
    wait

    echo
    echo
    echo "Execution semantics:"

    cat exec-out.txt
    rm -rf exec-out.txt

    echo
    echo
    echo "Done"
    ;;
"--exec-only")
    echo
    echo
    echo "Execution semantics:"
    $KOMPILE_CMD -d exec exec/java-exec.k
    ;;
"--strictness")
    echo
    echo
    echo "Preprocessing semantics:"
    # "&> file" redirects both stdin and stderr to the given file
    $KOMPILE_CMD --transition "transition-strictness" -d exec exec/java-exec.k &> exec-out.txt \
        & $KOMPILE_CMD -d prep prep/java-prep.k
    wait

    echo
    echo
    echo "Execution semantics:"

    cat exec-out.txt
    rm -rf exec-out.txt

    echo
    echo
    echo "Done"
    ;;
"--threading")
    echo
    echo
    echo "Preprocessing semantics:"
    # "&> file" redirects both stdin and stderr to the given file
    $KOMPILE_CMD --transition "transition-threading" -d exec exec/java-exec.k &> exec-out.txt \
        & $KOMPILE_CMD -d prep prep/java-prep.k
    wait

    echo
    echo
    echo "Execution semantics:"

    cat exec-out.txt
    rm -rf exec-out.txt

    echo
    echo
    echo "Done"
    ;;
"--threading-sync")
    echo
    echo
    echo "Preprocessing semantics:"
    # "&> file" redirects both stdin and stderr to the given file
    $KOMPILE_CMD --transition "transition-sync" -d exec exec/java-exec.k &> exec-out.txt \
        & $KOMPILE_CMD -d prep prep/java-prep.k
    wait

    echo
    echo
    echo "Execution semantics:"

    cat exec-out.txt
    rm -rf exec-out.txt

    echo
    echo
    echo "Done"
    ;;
"--symbolic")
    echo
    echo
    echo "Preprocessing semantics:"
    # "&> file" redirects both stdin and stderr to the given file
    $KOMPILE_CMD --backend symbolic --symbolic-rules "symbolic-rule" -d exec exec/java-exec.k &> exec-out.txt \
        & $KOMPILE_CMD -d prep prep/java-prep.k
    wait

    echo
    echo
    echo "Execution semantics:"

    cat exec-out.txt
    rm -rf exec-out.txt

    echo
    echo
    echo "Done"
    ;;
"--prep-latex")
    $KOMPILE_CMD -d prep --backend latex --doc-style "style=math,modulesAsSections" prep/java-prep.k
    remove-kblock.sh prep/java-prep.tex > java-prep.tex
    rm prep/java-prep.tex
    mv prep/k.sty .
    ;;
"--exec-latex")
    $KOMPILE_CMD -d exec --backend latex --doc-style "style=math,modulesAsSections" exec/java-exec.k
    remove-kblock.sh exec/java-exec.tex > java-exec.tex
    rm exec/java-exec.tex
    mv exec/k.sty .
    ;;
"--methods-latex")
    kjkompile.sh $EXTRA_OPTS --exec-latex
    extract-module.sh -m METHOD-INVOKE -o method-invoke.tex java-exec.tex
    mv exec/java-exec.tex .
    mv exec/k.sty .
    ;;
"--new-latex")
    kjkompile.sh $EXTRA_OPTS --exec-latex
    extract-module.sh -m NEW-INSTANCE -o new-instance.tex java-exec.tex
    mv exec/java-exec.tex .
    mv exec/k.sty .
    ;;
"--modules-latex")
    echo "Preprocessing semantics:"
    # "&> file" redirects both stdin and stderr to the given file
    kjkompile.sh $EXTRA_OPTS --exec-latex &> exec-out.txt \
        & kjkompile.sh $EXTRA_OPTS --prep-latex
    wait

    echo
    echo
    echo "Execution semantics:"

    cat exec-out.txt
    rm -rf exec-out.txt

    echo
    echo
    extract-all-modules.sh java-prep.tex
    extract-all-modules.sh java-exec.tex
    echo "Done"
    ;;

esac
