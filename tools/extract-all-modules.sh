#!/bin/sh

IN_FILE=$1

# Get all line numbers with a \begin{module}
BEGIN_MOD_LINE_NUMS=$( \
    grep -n \begin{module} ${IN_FILE} | \
    sed -n 's/^\([0-9]*\)[:].*/\1/p' \
  )

# Get all line numbers with an \end{module}
END_MOD_LINE_NUMS=$( \
    grep -n \end{module} ${IN_FILE} | \
    sed -n 's/^\([0-9]*\)[:].*/\1/p' \
  )

MOD_NAMES_RAW=$(grep -o -E \begin{module}{[a-zA-Z\-]+ ${IN_FILE})

# Convert line num strings into arrays
BEGIN_NUM_ARRAY=(${BEGIN_MOD_LINE_NUMS})
END_NUM_ARRAY=(${END_MOD_LINE_NUMS})
MOD_NAMES_ARRAY_RAW=(${MOD_NAMES_RAW})

mkdir -p .modules

# echo "Modules:"
for (( i = 0 ; i < ${#BEGIN_NUM_ARRAY[@]} ; i++ )) do
  #extract module name
  MOD_NAME_RAW=${MOD_NAMES_ARRAY_RAW[$i]}
  MOD_NAME=${MOD_NAME_RAW:14}

  # convert to lowercase
  MOD_NAME=${MOD_NAME,,}

  # debug data for each module
  # echo ${BEGIN_NUM_ARRAY[$i]} - ${END_NUM_ARRAY[$i]}, ${MOD_NAME}

  #extract module content to file in directory ".modules".
  cat ${IN_FILE} | awk NR==${BEGIN_NUM_ARRAY[$i]},NR==${END_NUM_ARRAY[$i]} >.modules/${MOD_NAME}.tex
done
