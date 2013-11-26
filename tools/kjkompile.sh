#!/bin/bash

# kompile java into one of five possible outputs:
# exec - regular kompilation, for execution
# strictness - kompilation for strictness checking
# threading - kompilation for threading checking
# latex - compile into latex
# pdf - compile into pdf

if [ $# -gt 1 ]; then
    echo "Your command:"
    echo `basename $0` $@
    echo "Usage: `basename $0`"
    echo "Or:    `basename $0` <exec|strictness|threading|latex|pdf>"
    exit
fi

TOOLS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
KOMPILE_CMD=$(cross-k.sh kompile)

if [ $# -eq 1 ];
  then OPTION=$1
  else OPTION=exec
fi

case "$OPTION" in
"exec")
    $KOMPILE_CMD -v java
    ;;
"strictness")
    $KOMPILE_CMD -v -transition "transition-strictness" java
    ;;
"threading")
    $KOMPILE_CMD -v -transition "transition-threading" java
    ;;
"latex")
    $KOMPILE_CMD -v --backend latex --doc-style "style=math" java
    ;;
"pdf")
    $KOMPILE_CMD -v --backend pdf --doc-style "style=math" java
    ;;
*)
    echo "Invalid option: $OPTION"
    echo "Usage: `basename $0` or `basename $0` <exec|strictness|threading|latex|pdf>"
    exit 1
    ;;
esac
