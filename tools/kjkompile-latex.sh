#!/bin/bash

# kompile a latex file from java definition. To be run from semantics dir.

TOOLS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
KOMPILE_CMD=$(cross-k.sh kompile)

$KOMPILE_CMD -v --backend pdf --doc-style "style=math" java
