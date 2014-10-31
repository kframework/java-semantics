#!/bin/bash

#Converts a call to a K tool into a cross-platform version. Windows versions have extension .bat .
if [  $# == 0 ]; then
    echo "Usage: `basename $0` <path>"
    exit 1
fi

if [[ $(uname) == *Windows* ]]
  then OUT=$1.bat
  else OUT=$1
fi

echo $OUT
