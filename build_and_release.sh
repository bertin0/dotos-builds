#! /bin/bash

source dotos-builds/utils.sh

for codename in "$@"
do
    build $codename
    if [ $? = 0 ]; then
        echo "Built successfully"
        release $codename
    fi
done
