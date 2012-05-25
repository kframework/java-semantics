# if no arguments are provided - running the whole test suite.
# if several arguments are provided as directories - running
# tests inside that directories.

if [ $# == 0 ]; then
    ALLDIRS=$(find ../programs/ -maxdepth 1 -mindepth 1 -type d)
    ./../tools/test-suite.sh $ALLDIRS
else
    START=$(date +%s)
    PRETTYARGS=$(find ${@} -maxdepth 0)
    echo "Running tests for"
    echo "$PRETTYARGS"

    for ARG in "$@"; do
        ./../tools/aux-test-dir.sh $ARG
        CATARG="$CATARG $ARG/tests/krun-results.xml"
    done

    cat $CATARG > test-all-results.xml

    END=$(date +%s)
    DIFF=$(( $END - $START ))
    echo "It took $DIFF seconds"
fi
