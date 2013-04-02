#!/bin/bash

#Preprocesses all java files in the java-semantics/programs, using preprocess.sh, and stores them result in .programs.
#Invoked from java-fan.

time ~/java-semantics/java-fan/tools/preprocess-dir.sh ~/java-semantics/programs ~/java-semantics/java-fan/.programs
