#! /bin/bash

source dotos-builds/utils.sh

for codename in "$@"
do
    build $codename
    release $codename
done
