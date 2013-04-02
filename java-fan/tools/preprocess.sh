#!/bin/bash

echo "" > temp1.txt
cat $1 > temp2.txt

COUNTER=0
while ! cmp -s temp1.txt temp2.txt
do
  cp -T temp2.txt temp1.txt
  sed -i -r 's/System\.out\.print(ln)?\([[:space:]]*("[^"]*")[[:space:]]*\+[[:space:]]*(.*)/System.out.print\(\2\);System.out.print\1\(\3/' temp2.txt
  sed -i -r 's/System\.out\.print(ln)?\(\s*([^"^+^[:space:]]+)[[:space:]]*\+[[:space:]]*(.*)/System.out.print\(\2\);System.out.print\1\(\3/' temp2.txt
done
sed -i -r 's/System\.out\.println\(\)/System\.out\.println\(""\)/' temp2.txt
cat temp2.txt
rm -f temp1.txt
rm -f temp2.txt
