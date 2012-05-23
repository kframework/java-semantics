# Removes all the temporary files from the given dir, created by test execution.

if [ $# -ne 1 ]; then
    echo "Usage: `basename $0` <dir-with-programs>"
    exit 1
fi

progdir=$1

rm -f $progdir/tests/*.diff
rm -f $progdir/tests/*.stdout
rm -f $progdir/tests/*.stderr
rm -f $progdir/tests/*.xml
rm -f $progdir/tests/*.out
