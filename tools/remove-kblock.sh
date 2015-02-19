#!/bin/sh

#removes \begin{kblock}, \end{kblock} from the given file
if [  $# == 0 ]; then
    echo "Usage: `basename $0` <file>"
    exit 1
fi

# http://www.cyberciti.biz/faq/howto-delete-word-using-sed-under-unix-linux-bsd-appleosx/
# http://stackoverflow.com/questions/2369314/why-does-sed-require-3-backslashes-for-a-regular-backslash
# http://stackoverflow.com/questions/1251999/sed-how-can-i-replace-a-newline-n

sed -e ':a;N;$!ba; s/\\begin{kblock}\[text\]\s*\n*\s*//g; s/\\end{kblock}\n//g' $1
