#!/bin/sh

export TOOLS_DIR=$WORKSPACE/tools
export PATH=/home/denis.bogdanas/k-framework-stable/bin:\
$TOOLS_DIR:\
$PATH

echo $PATH

# setting permissions for K tools
chmod +x /home/denis.bogdanas/k-framework-stable/bin/*
chmod +x /home/denis.bogdanas/k-framework-stable/lib/native/linux/*
chmod +x /home/denis.bogdanas/k-framework-stable/lib/maude/binaries/*

# setting permissions for K-Java tools
chmod +x $TOOLS_DIR/*.sh

echo "Using K Framework version:"
kompile --version

cd $WORKSPACE/src
kjkompile.sh --exec -v

export TOOLS_DIR=$WORKSPACE/tools
export PATH=/home/denis.bogdanas/k-framework-stable/bin:\
$TOOLS_DIR:\
$PATH

cd $WORKSPACE/src
rm -f ../class-lib/*.kast
rm -rf .test

aux-kjtest.sh -mode run -threads 1 -timeout 120 -encodeXML true -clean true ../tests/01_smoke_tests/helloWorld.java
