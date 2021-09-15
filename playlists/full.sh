#!/bin/bash

set -euo pipefail
IFS=$'\n\t'


WORKDIR=$(dirname $(realpath $0))
cd $WORKDIR

$WORKDIR/automate/run.sh --bitchute | tee bitchute.flat
$WORKDIR/automate/run.sh --youtube | tee youtube.flat

VIDEOS=${1:-777}
DATE=$(date +%s)
FILE=~/tube/$DATE-size_$VIDEOS-playlist.m3u

if [ ! -d ~/tube ] ; then
    mkdir ~/tube
fi

./sm2p-par.py --channels=3000 --videos=$VIDEOS -B bitchute.flat -f youtube.flat | tr -d '%' | tee $FILE

cd ~/tube
cat ./latest.m3u > ./previous.m3u
sleep 2s
grep -F -f ./previous.m3u -v $FILE > ./latest.m3u

scp $FILE latest.m3u previous.m3u pi:tube
