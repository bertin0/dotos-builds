#! /bin/bash

source dotos-builds/utils.sh

$EDITOR dotos-builds/changelog.md

for codename in "$@"
do
    release $codename
done

