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
    echo "Or:    `basename $0` <--exec|--exec-v|--strictness|--threading|--symbolic|--latex|--pdf|--help>"
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
    $KOMPILE_CMD exec/java-exec &> exec-out.txt \
        & $KOMPILE_CMD full/java-full &> full-out.txt \
        & $KOMPILE_CMD prep/java-prep
    wait

    echo
    echo
    echo "Execution semantics:"

    cat exec-out.txt
    rm -rf exec-out.txt

    echo
    echo
    echo "Full semantics:"

    cat full-out.txt
    rm -rf full-out.txt

    echo
    echo
    echo "Done"
    ;;
"--strictness")
    $KOMPILE_CMD -v -transition "transition-strictness" full/java-full
    ;;
"--threading")
    $KOMPILE_CMD -v -transition "transition-threading" full/java-full
    ;;
"--symbolic")
    $KOMPILE_CMD -v --backend symbolic --symbolic-rules "symbolic-rule" full/java-full
    ;;
"--latex")
    $KOMPILE_CMD -v --backend latex --doc-style "style=math" full/java-full
    ;;
"--pdf")
    $KOMPILE_CMD -v --backend pdf --doc-style "style=math" full/java-full
    ;;
"--help")
    echo "Usage: `basename $0`"
    echo "Or:    `basename $0` <--exec|--exec-v|--strictness|--threading|--symbolic|--latex|--pdf|--help>"
    ;;
*)
    echo "Invalid option: $OPTION"
    echo "Usage: `basename $0`"
    echo "Or:    `basename $0` <--exec|--exec-v|--strictness|--threading|--symbolic|--latex|--pdf|--help>"
    exit 1
    ;;
esac
