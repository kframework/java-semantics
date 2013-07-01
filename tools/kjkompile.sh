#!/bin/bash

# kompile java definition for both plain testing and modelchecking. To be run from semantics dir.

TOOLS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

kompile -v -transition "strictness-transition" java
