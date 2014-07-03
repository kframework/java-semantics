  This directory contains the infrastructure required to test java-fan project over
K-Java tests.
  General instructions:
1. Run "chmod +x tools/*"
2. All scripts should be run from this directory.

Tools:
1. To run a preprocessed program with java-fan:
    tools/java-fan-run.sh <program>
2. To preprocess and test a directory of programs:
    tools/java-fan-test.sh <program dir>
3. Test script with more options:
    java-fan-aux-test.sh
4. To see what preprocessings were made, read the comments in:
    tools/java-fan-preprocess.sh
