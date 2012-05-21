if [ $# -ne 1 ]; then
    echo "Usage: `basename $0` <dir-with-programs>"
    exit 1
fi

START=$(date +%s)

progdir=$1
last_dir_only=`basename $progdir`

echo
echo "Generating tests for $last_dir_only based on java-semantics"
echo

find $progdir -maxdepth 1 -type f \( -name "*java" \) |
  while read FILE; do
    echo "$FILE :"
    echo
    ./../tools/make-non-jdk-test.sh $FILE
    echo
  done

END=$(date +%s)
DIFF=$(( $END - $START ))
echo "It took $DIFF seconds"
