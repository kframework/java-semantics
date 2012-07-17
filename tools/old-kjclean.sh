# Removes all the temporary files from the given dir or dirs, created by test execution.
# If no dirs are given, remove all temp files from all test dirs.

if [ $# == 0 ]; then
    ALLDIRS=$(find ../programs/ -maxdepth 1 -mindepth 1 -type d)
    ./../tools/kjclean.sh $ALLDIRS
else
    PRETTYARGS=$(find ${@} -maxdepth 0)
    echo "Cleaning dirs"
    echo "$PRETTYARGS"

    for ARG in "$@"; do
        rm -f $ARG/tests/*
    done
fi

