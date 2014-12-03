#!/bin/bash

#Converts a script reference into one that could be called from java, on both Linux and cygwin.
if [  $# == 0 ]; then
    echo "Usage: `basename $0` <path>"
    exit 1
fi

if [[ $(uname) == *Linux* ]] || [[ $(uname) == *Darwin* ]]
  then OUT=$1
  else OUT="sh $1"
fi

echo $OUT
