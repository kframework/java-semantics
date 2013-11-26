#!/bin/bash

# kompile java definition for regular execution. To be run from semantics dir.

TOOLS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
KOMPILE_CMD=$(cross-k.sh kompile)

$KOMPILE_CMD -v java
