#!/bin/bash

#
# Author: Marcin 'y0rune' Woźniak
# Last Edit: 2021-11-17
#
# shellcheck disable=SC2207,SC2143
#

set -u
set -e

# Get all script files
FILES=( $(find . -type f -name '*.sh') )

# Function check if script has a wrapper function
function check_script_has_wrapper_function() {
    for FILE in "${FILES[@]}"
    do
        # Checking if the file has the '{' at the beginning
        if grep -iqE '^{' "$FILE"
        then
            echo "File $FILE do not have a wrapper function"

            # Creating a function name
            # For example
            # __init_script_name
            FUNCTION_NAME="__init_$(echo "$FILE" \
                | awk -F/ '{print $2}'\
                | sed 's/-/_/g')"

            # Apply changes on the files
            sed -i -e 's/^{/function '"$FUNCTION_NAME"'() {/g' "$FILE"

            # Remove backup file of sed
            rm "$FILE-e"

            # Added function at the end of function
            echo -e "\n $FUNCTION_NAME" >> "$FILE"
        fi
    done
}

function check_script_has_function_word(){
    for FILE in "${FILES[@]}"
    do
        # Checking if the file has the '{' at the beggining
        if grep -iqE '^[a-zA-Z_-]+.\(\)' "$FILE"
        then
            echo "File $FILE does not have a function at the beggining"

            # Getting a function name without `function` word in the beginning
            FUNCTION_NAME=($(grep --color=no -iEo '^[a-zA-Z_-]+.\(\)' "$FILE"))

            for NAME in "${FUNCTION_NAME[@]}"
            do
                # Adding the function word at the beginning
                sed -i -e 's/'"$NAME"'/function '"$NAME"'/g' "$FILE"

                # Remove backup file of sed
                rm "$FILE-e"
            done
        fi
    done
}

function check_script_has_not_shebang(){
    for FILE in "${FILES[@]}"
    do
        # Checking if the file has the '{' at the beggining
        if ! grep -iEq '^\#\!/bin/bash' "$FILE"
        then
            echo "File $FILE does not have a shebang"

            # Added in the first line shebang
            sed -i -e '1s/^/\#\!\/bin\/bash\n/' "$FILE"

            # Remove backup file of sed
            rm "$FILE-e"
        fi
    done
}

function main(){
    check_script_has_wrapper_function
    check_script_has_function_word
    check_script_has_not_shebang
}

main
