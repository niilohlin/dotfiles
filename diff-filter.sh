#!/bin/sh

lint_output=$(exec swiftlint --strict --config ./.git/hooks/stricter-swiftlint.yml 2>&1)
ret_code=$?
PWDSTRING=$(pwd | sed -e 's/[\/&]/\\&/g')

if [ $ret_code != 0 ]; then
    lint_output=$(echo "$lint_output" | grep -v "^Done linting")
    lint_output=$(echo "$lint_output" | grep -v "^Loading configuration from")
    lint_output=$(echo "$lint_output" | grep -v "^Linting Swift files at paths")
    failed_files=$(echo "$lint_output" | grep -v "^Linting" | sed "s/$PWDSTRING//g")
    failed_files_without_warning=$(echo "$failed_files" | sed -E "s/:[[:digit:]]+: warning: .*//g")
    echo "$failed_files_without_warning"
    #STAGED=$(git --no-pager diff --cached --no-color)
    #pcregrep -o1 "^@@ -\d+,\d+ \+(\d+),\d+ @@"
    #declare -a ARRAY
    exit $ret_code
fi


