#!/usr/bin/env bash

export NODE_OPTIONS=--max-old-space-size=4096

VERSION=`node -pe 'JSON.parse(process.argv[1]).version' "$(cat package.json)"`

_prepare()
{
    hugo --cleanDestinationDir
    cp public/en/index.html public/en.html
    rm public.zip
    # Compress using gzip compression
    for f in $(find public/ -type f); do { gzip -k $f & }; done
    wait
    cd public ; zip -9 -q -r ../public.zip * ; cd -
}

_scp() {
    fileName=$1
    subDomain=$2
    rsync -avP ${fileName}.zip web1.cogocollect.com:${fileName}.zip
    rsync -avP ${fileName}.zip web2.cogocollect.com:${fileName}.zip
    ssh web1.cogocollect.com ./deploy.sh ${fileName} ${subDomain}.cogocollect.nl
    ssh web2.cogocollect.com ./deploy.sh ${fileName} ${subDomain}.cogocollect.nl
}

_prepare
_scp public www
