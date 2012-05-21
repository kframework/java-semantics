# Executes all the tests in the dir received as argument.
# Run the script from semantics directory.
# Tests should exist prior to invocation, they are nt created by jdk.

if [ $# -ne 1 ]; then
    echo "Usage: `basename $0` <dir-with-programs>"
    exit 1
fi

START=$(date +%s)

progdir=$1
last_dir_only=`basename $progdir`

echo
echo "Executing tests in $last_dir_only"
echo

perl ../tools/tester.pl -d $progdir/tests -f "--parser=\"java -cp ../parser/JavaParser.jar ro.uaic.info.fmse.parser.Main\" --no-color --output-mode=none" -n last_dir_only -timeout 25

END=$(date +%s)
DIFF=$(( $END - $START ))
echo "It took $DIFF seconds"
