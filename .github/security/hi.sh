#!/bin/bash

# Pre commit hook that prevents FORBIDDEN code from being commited.
# Add unwanted code to the FORBIDDEN array as necessary

FORBIDDEN=(
  "\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,6}\b" # emails
  "\#TODO\:"                                            # todos
)

for i in "${FORBIDDEN[@]}"; do
  git diff --cached --name-only |
    GREP_COLOR='4;5;37;41' xargs grep --color --with-filename -E -o "$i" &&
    echo 'COMMIT REJECTED Found' $i 'references. Please remove them before commiting' && exit 1
done

exit 0
