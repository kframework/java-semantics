# Creates an out file for a given program file, in the right place
# Run the script from semantics directory.

#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: `basename $0` <prog>"
    exit 1
fi

prog=$1

outdir=`dirname $prog`
outdir="$outdir/tests"
newfilename=`basename $prog`

in_file="$outdir/$newfilename.in"

# krun_command="krun --parser=\"java -cp ../parser/JavaParser.jar ro.uaic.info.fmse.parser.Main\" --output-mode=none --no-color $prog "
krun_command="../tools/jdk-run.sh $prog "
if [ -f $in_file ]
then
  krun_command="$krun_command < $in_file > out.tmp"
else
  krun_command="$krun_command > out.tmp"
fi

mkdir -p $outdir
eval $krun_command
newfile="$outdir/$newfilename.out"
# echo $newfile
# echo $out
mv out.tmp $newfile
cat $newfile

