#!/bin/bash

# kompile java-full into one of five possible outputs:
# exec - regular kompilation, for execution
# strictness - kompilation for strictness checking
# threading - kompilation for threading checking
# latex - compile into latex
# pdf - compile into pdf

if [ $# -gt 1 ]; then
    echo "Your command:"
    echo `basename $0` $@
    echo "Usage: `basename $0`"
    echo "Or:    `basename $0` <--exec|--exec-v|--strictness|--threading|--symbolic|--latex|--exec-latex| \
      --methods-latex|--pdf|--help>"
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
    $KOMPILE_CMD -v --transition "transition-strictness" -d full full/java-full.k
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
    $KOMPILE_CMD -v --backend symbolic --symbolic-rules "symbolic-rule" -d full full/java-full.k
    ;;
"--latex")
    $KOMPILE_CMD -v --backend latex --doc-style "style=math" full/java-full.k
    ;;
"--exec-latex")
    $KOMPILE_CMD -v --backend latex --doc-style "style=math" exec/java-exec.k
    ;;
"--pdf")
    $KOMPILE_CMD -v --backend pdf --doc-style "style=math" full/java-full.k
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
    echo "Or:    `basename $0` <--exec|--exec-v|--strictness|--threading|--symbolic|--latex|--exec-latex| \
      --methods-latex|--pdf|--help>"
    ;;
*)
    echo "Invalid option: $OPTION"
    echo "Usage: `basename $0`"
    echo "Or:    `basename $0` <--exec|--exec-v|--strictness|--threading|--symbolic|--latex|--exec-latex| \
      --methods-latex|--pdf|--help>"
    exit 1
    ;;
esac
