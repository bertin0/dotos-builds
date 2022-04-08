#! /bin/bash

build () {
    CODENAME=$1
    . build/envsetup.sh
    lunch dot_$CODENAME-userdebug
    make -j20 bacon
}

release () {
    CODENAME=$1
    ZIPPATH=out/target/product/$CODENAME
    ZIPNAME=$(ls $ZIPPATH/dotOS-*.zip | tail -n1 | xargs -n1 basename)
    HASH=$(cut -f1 -d ' ' $ZIPPATH/$ZIPNAME.sha256sum)

    mv $ZIPPATH/$ZIPNAME dotos-builds/
    
    cd dotos-builds/

    REPOURL=https://github.com/bertin0/dotos-builds
    METADATA=$(unzip -p "$ZIPNAME" META-INF/com/android/metadata)

    DEVICE=$(echo "$METADATA" | grep pre-device | cut -f2 -d '=' | cut -f1 -d ',')
    SDK_LEVEL=$(echo "$METADATA" | grep post-sdk-level | cut -f2 -d '=')
    TIMESTAMP=$(echo "$METADATA" | grep post-timestamp | cut -f2 -d '=')

    DATE=$(echo $ZIPNAME | cut -f5 -d '-')
    SIZE=$(du -b $ZIPNAME | cut -f1 -d '	')
    TYPE=$(echo $ZIPNAME | cut -f4 -d '-')
    VERSION=$(echo $ZIPNAME | cut -f2 -d '-')

    RELEASENAME=${DEVICE}-${DATE}
    RELEASESTODAY=1
    while git show-ref --tags ${RELEASENAME} --quiet
    do
        RELEASESTODAY=$((RELEASESTODAY+1))
        RELEASENAME=${DEVICE}-${DATE}-${RELEASESTODAY}
    done

    URL="$REPOURL/releases/download/${RELEASENAME}/${ZIPNAME}"

    echo "Making release $RELEASENAME"

    jq --slurpfile devices devices.json "
        . += {codename: \"$DEVICE\"} | "'
        . += $devices[0]'".$DEVICE |
        .releases[0] += {
            type: \"$TYPE\",
            generatedAt: $TIMESTAMP,
            fileName: \"$ZIPNAME\",
            url: \"$URL\",
            requireCleanFlash: \"${CLEANFLASH:-false}\",
            hash: \"$HASH\",
            size: \"$SIZE\",
            version: \"$VERSION\"
        }" template.json > $DEVICE.json

    git add $DEVICE.json
    git commit -m $RELEASENAME
    git tag $RELEASENAME
    git push
    gh release create $RELEASENAME -F changelog.md $ZIPNAME
    
    cd ../
}
