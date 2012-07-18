#!/bin/bash

# Deletes a dir recursively

if [ $# -ne 1 ]; then
    echo "Usage: `basename $0` <dir to delete>"
    exit 1
fi

dirToDelete=$1
rm -r -f $dirToDelete
