#!/bin/bash

#Converts a cygwin path into windows path, if current environment is cygwin.
if [  $# == 0 ]; then
    echo "Usage: `basename $0` <path>"
    exit 1
fi

if [[ $(uname) == *Linux* ]]
  then OUT=$1
  else OUT=$(cygpath -w $1)
fi

echo $OUT
