if [ $# -ne 1 ]; then
    echo "Usage: `basename $0` <dir-with-programs>"
    exit 1
fi

progdir=$1
last_dir_only=`basename $progdir`

echo
echo "Generating tests for $last_dir_only based on JDK"
echo

find $progdir -maxdepth 1 -type f \( -name "*java" \) |
  while read FILE; do
    echo "$FILE :"
    echo
    ./../tools/make-jdk-test.sh $FILE
    echo
  done

