#! /bin/bash

source dotos-builds/utils.sh

for codename in "$@"
do
    release $codename
done

