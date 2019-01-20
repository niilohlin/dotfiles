#!/bin/sh

get_changed_files() {
    git diff --cached --name-only --diff-filter=dr | grep ".*\\.swift$"
}

get_lint_output() {
    read -r file
    if [ -z "$file" ]; then
        return 0
    fi
    result=$(exec swiftlint --path "$file" --strict --config ./.git/hooks/stricter-swiftlint.yml 2>&1)
    ret_code=$?
    echo "$result"
    return $ret_code
}

filter_lint_output() {
    lint_output=$(grep -v "^Done linting")
    lint_output=$(echo "$lint_output" | grep -v "^Loading configuration from")
    lint_output=$(echo "$lint_output" | grep -v "^Linting Swift files at paths")
    if [ -z "$lint_output" ]; then
        return 0
    else
        echo "$lint_output"
    fi
}

filter_nonfailed_files() {
    grep -v "^Linting" | cat
}

remove_current_directory() {
    PWDSTRING=$(pwd | sed -e 's/[\/&]/\\&/g')
    sed "s/$PWDSTRING//g"
}

# Maybe not needed
remove_warning_from_path() {
    sed -E "s/([[:digit:]]+):[[:digit:]]*:? (warning|error)(: .*)/\\1 \\2\\3/g"
}

get_added_changes() {
    xargs git --no-pager diff --cached --no-color --diff-filter=dr
}

## parsing patch

parse_diff_into_files_and_lines() {
    filename=""
    linenumber=""
    while read -r line; do
        match=$(echo "$line" | grep "diff --git")
        if [ ! -z "$match" ]; then
            filename=$(echo "$match" | sed -E "s/.* b\\/(.*.swift)/\\1/g" )

            linenumber=""
        else
            match=$(echo "$line" | pcregrep -o1 "^@@ -\\d+,\\d+ \\+(\\d+),\\d+ @@")
            if [ ! -z "$match" ]; then
                linenumber=$(echo "$match - 1" | bc)
            else
                if [ ! -z "$linenumber" ]; then
                    match=$(echo "$line" | grep "^-")
                    if [ -z "$match" ]; then
                        linenumber=$(echo "$linenumber + 1" | bc)
                    fi
                    match=$(echo "$line" | grep "^+")
                    if [ ! -z "$match" ]; then
                        echo "$filename:$linenumber $line"
                    fi
                fi

            fi
        fi
    done
}

if [ "$1" = "TEST" ]; then
    return 0
fi

lint_output=$(get_changed_files | get_lint_output)
ret_code=$?
PWDSTRING=$(pwd | sed -e 's/[\/&]/\\&/g')

if [ $ret_code != 0 ]; then
    lint_errors=$(echo "$lint_output" | filter_lint_output | filter_nonfailed_files | remove_current_directory | remove_warning_from_path)
    #echo "lint errors: $lint_errors"
    changes=$(get_changed_files | get_added_changes | parse_diff_into_files_and_lines)
    #echo "changes: $changes"

    found=""

    while read -r lint_error; do
        lint_error_file_and_column=$(echo "$lint_error" | cut -f 1 -d " " | sed "s/^\\///g")
        match=$(echo "$changes" | grep "$lint_error_file_and_column")
        if [ ! -z "$match" ]; then
            echo "$lint_error"
            found="found"
        fi
    done <<< "$lint_errors"
    if [ ! -z "$found" ]; then
        exit 1
    fi
    exit 0
fi


