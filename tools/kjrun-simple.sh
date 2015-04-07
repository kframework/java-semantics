#!/bin/bash
# Absolute path to this script, e.g. /home/user/bin/foo.sh
SCRIPT=$(readlink -f "$0")
# Absolute path this script is in, thus /home/user/bin
SCRIPTPATH=$(dirname "$SCRIPT")

CurDir=$(pwd)

Input=$(basename $1)
OUT="$CurDir/$Input.pkast"

TMP="$CurDir/tmp.txt"

krun $1 --directory "$SCRIPTPATH/../src/prep" --parser "kj-parse-aggreg.sh" --output kast > $OUT

sed 's/\s*\([[:graph:]].*[[:graph:]]\)\s*/\1/g' < $OUT | tr -d '\n' > $TMP

sed -r 's/.*<program>//g' < $TMP > $OUT
sed -r 's/<\/program>.*//g' < $OUT > $TMP

sed "s/\`'KListWrap/\`'ListWrap/g" < $TMP > $OUT

rm $TMP

ClsName=$(echo $Input | sed -r 's/\.java$//g')
krun $OUT --directory "$SCRIPTPATH/../src/exec" -cMainClass="ListItem(\"$ClsName\")" -cDissolveAllExceptOut="true" --parser "cat" --output none