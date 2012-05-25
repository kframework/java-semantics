#Creates test suite for the argument dir, using jdk.
# Executes all the tests in the dir received as argument.
# Run the script from semantics directory.

if [ $# -ne 1 ]; then
    echo "Usage: `basename $0` <dir-with-programs>"
    exit 1
fi

progdir=$1
last_dir_only=`basename $progdir`

rm -f $progdir/tests/*.out

INFILES=$(find $progdir -maxdepth 1 -name '*.in')
OUTFILES=$(find $progdir -maxdepth 1 -name '*.out')
OUTCOUNT=$(find $progdir -maxdepth 1 -name '*.out' | wc -l)

for i in $INFILES; do cp $i $1/tests; done

if [ $OUTCOUNT == 0 ]; then
    # make test .out files based on JDK
    ./../tools/make-jdk-test-dir.sh $progdir
else
    # copy test out files from $progdir
    for i in $OUTFILES; do cp $i $1/tests; done
fi

echo
echo "Executing tests in $last_dir_only"
echo

perl ../tools/tester.pl -d $progdir/tests -f "--parser=\"java -cp ../parser/JavaParser.jar ro.uaic.info.fmse.parser.Main\" --no-color --output-mode=none" -n last_dir_only -timeout 25
