#!/bin/sh

# A POSIX variable
OPTIND=1         # Reset in case getopts has been used previously in the shell.

# Initialize our own variables:
MODULE=0
OUT_FILE=0

while getopts "h?m:o:" opt; do
    case "$opt" in
    h|\?)
        echo "Usage: `basename $0` -m MODULE -o OUTPUT-FILE"
        exit 0
        ;;
    m)  MODULE=$OPTARG
        ;;
    o)  OUT_FILE=$OPTARG
        ;;
    esac
done

shift $((OPTIND-1))

[ "$1" = "--" ] && shift

IN_FILE=$1
AUX_FILE=cut.tex

shift

# echo "MODULE=$MODULE, OUT_FILE='$OUT_FILE', IN_FILE='$IN_FILE', Leftovers: $@"
# End of command args parsing


# Save to BEGIN_DOC_LINE_NUM the line number of \begin{document} in the original doc-methods-main.tex
BEGIN_DOC_LINE_NUM=$(grep -n -m 1 \begin{document} ${IN_FILE} | sed -n 's/^\([0-9]*\)[:].*/\1/p')

# save into final.tex the beginning of the document up to \begin{document} inclusively
head -n ${BEGIN_DOC_LINE_NUM} ${IN_FILE} > ${OUT_FILE}

# Append one more line
echo "" >> ${OUT_FILE}

# Save to START_LINE_NUM just the line number where moduleName{METHOD-INVOKE} is located:
START_LINE_NUM=$( \
    grep -n \begin{module}{${MODULE}} ${IN_FILE} | \
    sed -n 's/^\([0-9]*\)[:].*/\1/p' \
  )

# Delete the beginnign ofthe file up to the line with moduleName{METHOD-INVOKE} inclusively
sed "1,${START_LINE_NUM}d" ${IN_FILE} > ${AUX_FILE}

# Save to END_LINE_NUM just the line number where the first end{module} is located in the new cut.tex:
END_LINE_NUM=$(grep -n -m 1 \end{module} ${AUX_FILE} | sed -n 's/^\([0-9]*\)[:].*/\1/p')

# Make END_LINE_NUM to point to the line prior to end{module}
END_LINE_NUM=`expr ${END_LINE_NUM} - 1`

# Retain the beginning of new cut.tex up to the line prior to first end{module}. Append to final.tex
head -n ${END_LINE_NUM} ${AUX_FILE} >> ${OUT_FILE}

# Append \end{document} to the end of the file
echo "" >> ${OUT_FILE}
echo "\end{document}" >> ${OUT_FILE}

rm -f ${AUX_FILE}
