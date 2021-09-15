#!/bin/bash

set -x

VIDEOS=${1:-999}
DATE=$(date +%s)
FILE=~/tube/$DATE-size_$VIDEOS-playlist.m3u

if [ ! -d ~/tube ] ; then
    mkdir ~/tube
fi

cd ~/src/youtube-subs2recentplaylist/

cat youtube.flat addon.flat > you.flat
cat odysee.flat odysee-addon.flat > od.flat

./sm2p-par.py --channels=3000 --videos=$VIDEOS -B bitchute.flat -f you.flat -O od.flat | sed -e "s/%/%%/g" | tee $FILE

cd ~/tube
sudo chown pi:pi .
cat ./latest.m3u > ./previous.m3u
sleep 2s
grep -F -f ./previous.m3u -v $FILE > ./latest.m3u
