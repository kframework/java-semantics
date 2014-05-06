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

if [ $# -gt 1 ]; then
    echo "Your command:"
    echo `basename $0` $@
    echo "Usage: `basename $0`"
    echo "Or:    `basename $0` <--exec|--exec-v|--strictness|--threading|--symbolic| \
      --prep-latex|--prep-pdf|--exec-latex|--exec-pdf|--methods-latex|--methods-pdf|--help>"
    exit
fi

TOOLS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
KOMPILE_CMD=$(cross-k.sh kompile)

if [ $# -eq 1 ];
  then OPTION=$1
  else OPTION=--exec
fi

if [ $OPTION == "--exec-v" ];
  then KOMPILE_CMD="$KOMPILE_CMD -v"
fi

case "$OPTION" in
"--exec" | "--exec-v")
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
    ;;
"--methods-pdf")
    $KOMPILE_CMD -v --backend pdf --doc-style "style=math" latex/doc-methods-main.k
    ;;
"--help")
    echo "Usage: `basename $0`"
    echo "Or:    `basename $0` <--exec|--exec-v|--strictness|--threading|--symbolic| \
      --prep-latex|--prep-pdf|--exec-latex|--exec-pdf|--methods-latex|--methods-pdf|--help>"
    ;;
*)
    echo "Invalid option: $OPTION"
    echo "Usage: `basename $0`"
    echo "Or:    `basename $0` <--exec|--exec-v|--strictness|--threading|--symbolic| \
      --prep-latex|--prep-pdf|--exec-latex|--exec-pdf|--methods-latex|--methods-pdf|--help>"
    exit 1
    ;;
esac
