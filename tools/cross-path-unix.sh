#!/bin/bash

#Converts a path into linux path, if current environment is cygwin.
if [  $# == 0 ]; then
    echo "Usage: `basename $0` <path>"
    exit 1
fi

if [[ $(uname) == *Windows* ]]
  then OUT=$(cygpath -u $1)
  else OUT=$1
fi

echo $OUT
