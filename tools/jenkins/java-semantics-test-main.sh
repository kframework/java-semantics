#!/bin/sh

export TOOLS_DIR=$WORKSPACE/tools
export PATH=/home/denis.bogdanas/k-framework-stable/bin:\
$TOOLS_DIR:\
$PATH

echo "Using K Framework version:"
krun --version
echo "krun command:"
cat /home/denis.bogdanas/k-framework-stable/bin/krun

rm -rf $WORKSPACE/*
cp -rf $WORKSPACE/../java-semantics/* $WORKSPACE

cd $WORKSPACE/src
aux-kjtest.sh -mode run -threads 12 -timeout 120 -encodeXML true -clean true ../tests
