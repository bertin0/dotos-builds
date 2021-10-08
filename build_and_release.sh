#! /bin/bash

source dotos-builds/utils.sh

$EDITOR dotos-builds/changelog.md

for codename in "$@"
do
    for tries in {1..3}; do
        build $codename
        if [ $? = 0 ]; then
            echo "Built successfully after $tries tries"
            release $codename
            break
        fi
        echo "Build failed... Trying again."
    done
done
