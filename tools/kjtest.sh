# if no arguments are provided - running the whole test suite.
# if several arguments are provided as directories - running
# tests inside that directories.

TOOLS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ $# == 0 ]; then
    $TOOLS_DIR/kjtest.sh $TOOLS_DIR/../programs/
else
    START=$(date +%s)
    PRETTYARGS=$(find ${@} -maxdepth 0)
    echo "Running tests for"
    echo "$PRETTYARGS"
    echo

    java -cp $TOOLS_DIR/test-runner.jar ro.uaic.javasemantics.tools.Main \
      -gen $TOOLS_DIR/aux-jdk-run.sh -run $TOOLS_DIR/aux-kjrun.sh \
      -taskExt java -threads 22 -timeout 20 -testsuiteName java-semantics \
      -rm $TOOLS_DIR/aux-rm.sh ${@}

    END=$(date +%s)
    DIFF=$(( $END - $START ))
    echo "It took $DIFF seconds"
fi
