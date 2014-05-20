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
VERBOSE=false

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
    "--exec"|"--strictness"|"--threading"|"--threading-sync"|"--symbolic"|"--prep-latex"|"--prep-pdf" \
      |"--exec-latex"|"--methods-latex"|"--methods-pdf"|"--new-latex"|"--new-pdf")
      OPTION=${PARAM}
      ;;
    "-v" | "--verbose")
      VERBOSE=true
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

if [ ${VERBOSE} == true ];
  then KOMPILE_CMD="$KOMPILE_CMD -v"
fi

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
    $KOMPILE_CMD -v --backend latex --doc-style "style=math" exec/java-exec.k
    ;;
"--prep-pdf")
    $KOMPILE_CMD -v --backend pdf --doc-style "style=math" exec/java-exec.k
    ;;
"--exec-latex")
    $KOMPILE_CMD -v --backend latex --doc-style "style=math" exec/java-exec.k
    ;;
"--exec-pdf")
    $KOMPILE_CMD -v --backend pdf --doc-style "style=math" exec/java-exec.k
    ;;
"--methods-latex")
    $KOMPILE_CMD -v --backend latex --doc-style "style=math" latex/doc-methods-main.k
    extract-module.sh -m METHOD-INVOKE -o method-invoke.tex doc-methods-main.tex
    ;;
"--methods-pdf")
    kjkompile.sh --methods-latex
    mkdir -p .latex
    pdflatex -synctex=-1 -max-print-line=120 -interaction=nonstopmode -shell-escape \
      --aux-directory=.latex method-invoke.tex
    ;;
"--new-latex")
    $KOMPILE_CMD -v --backend latex --doc-style "style=math" exec/java-exec.k
    extract-module.sh -m NEW-INSTANCE -o new-instance.tex java-exec.tex
    ;;
"--new-pdf")
    kjkompile.sh --new-latex
    mkdir -p .latex
    pdflatex -synctex=-1 -max-print-line=120 -interaction=nonstopmode -shell-escape \
      --aux-directory=.latex new-instance.tex
    ;;
esac
