#!/bin/bash

#   Preprocesses the given file to be compatible with java-fan and prints the output to the console.
#   Transformations performed:
# System.out.print[ln]("foo bar" + etc); => System.out.print("foo bar");system.out.print[ln](etc);
# System.out.print[ln](var + etc); => System.out.print(var);system.out.print[ln](etc);
# System.out.print[ln]((anything_no_spaces) + etc); => System.out.print(anything_no_spaces);system.out.print[ln](etc);
# System.out.println() => System.out.println("")
# <two or more spaces> => one space
#   For the third transformation the spaces around + are required.
# The first three transformations are done recursively.

#Restrictions on the input programs:
#1. Any statement of the form System.out.print[ln](...); should be on one line.
#2. Expressions within System.out.print[ln](...) that we do not wish to desugar by the first two rules, but by the third rule,
# should be:
#   - wrapped into ()
#   - should not contain spaces
#   - should be followed by a space
#   - example: System.out.println("foo(a+b) = " + (foo(a+b)) + ...);

if [  $# != 1 ]; then
    echo "Usage: `basename $0` <JAVA FILE>"
    exit 1
fi

echo "" > temp1.txt
cat $1 > temp2.txt

COUNTER=0
while ! cmp -s temp1.txt temp2.txt
do
  cp -T temp2.txt temp1.txt
  sed -i -r 's/System\.out\.print(ln)?\([[:space:]]*("[^"]*")[[:space:]]*\+[[:space:]]*(.*)/System.out.print\(\2\);System.out.print\1\(\3/' temp2.txt
  sed -i -r 's/System\.out\.print(ln)?\([[:space:]]*([^"^+^[:space:]^\(^\)]+)[[:space:]]*\+[[:space:]]*(.*)/System.out.print\(\2\);System.out.print\1\(\3/' temp2.txt
  sed -i -r 's/System\.out\.print(ln)?\([[:space:]]*\(([^[:space:]]+)\)[[:space:]]+\+[[:space:]]*(.*)/System.out.print\(\2\);System.out.print\1\(\3/' temp2.txt
done
sed -i -r 's/System\.out\.println\(\)/System\.out\.println\(""\)/' temp2.txt
sed -i -r 's/([[:space:]])[[:space:]]+/ /g' temp2.txt
cat temp2.txt
rm -f temp1.txt
rm -f temp2.txt
