#!/bin/bash

#Converts a path into linux path, if current environment is cygwin.
if [  $# == 0 ]; then
    echo "Usage: `basename $0` <path>"
    exit 1
fi

if [[ $(uname) == *Linux* ]] || [[ $(uname) == *Darwin* ]]
  then OUT=$1
  else OUT=$(cygpath -u $1)
fi

echo $OUT
