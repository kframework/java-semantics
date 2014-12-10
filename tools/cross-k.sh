#!/bin/bash

#Converts a call to a K tool into a cross-platform version. Windows versions have extension .bat .
if [  $# == 0 ]; then
    echo "Usage: `basename $0` <path>"
    exit 1
fi

if [[ $(uname) == *Linux* ]] || [[ $(uname) == *Darwin* ]]
  then OUT=$1
  else OUT=$1.bat
fi

echo $OUT
