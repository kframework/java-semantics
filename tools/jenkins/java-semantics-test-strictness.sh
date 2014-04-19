#!/bin/sh

rm -rf $WORKSPACE/*
cp -rf $WORKSPACE/../java-semantics/* $WORKSPACE
export TOOLS_DIR=$WORKSPACE/tools
export PATH=/home/denis.bogdanas/k-framework-stable/bin:\
$TOOLS_DIR:\
$PATH

cat /home/denis.bogdanas/k-framework-stable/bin/krun
chmod +x $TOOLS_DIR/*.sh
cd $WORKSPACE/src

kjkompile.sh --strictness

export K_OPTS="-Xss8m -Xmx8192m"

aux-kjtest.sh -mode search -threads 6 -timeout 600 -encodeXML true -clean true ../model-check/71_strictness
