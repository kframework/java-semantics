OUT="$1.pkast"

TMP="tmp1.txt"

krun $1 --directory "../src/prep" --parser "kj-parse-aggreg.sh" --output kast > $OUT

sed 's/\s*\([[:graph:]].*[[:graph:]]\)\s*/\1/g' < $OUT | tr -d '\n' > $TMP

sed -r 's/.*<program>//g' < $TMP > $OUT
sed -r 's/<\/program>.*//g' < $OUT > $TMP

sed "s/\`'KListWrap/\`'ListWrap/g" < $TMP > $OUT

ClsName=$(echo $1 | sed -r 's/\.java$//g')
krun $OUT --directory "../src/exec" -cMainClass="ListItem(\"$ClsName\")" -cDissolveAllExceptOut="true" --parser "cat" --output none
