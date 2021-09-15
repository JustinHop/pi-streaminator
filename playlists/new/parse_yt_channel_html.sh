#!/bin/bash
#https://www.youtube.com/feeds/videos.xml?channel_id=UCzAxQ3vGD6Unk1GyxjJ9bmg

set -euo pipefail
IFS=$'\t\n'

backup html
xclip -o > html

cat html | grep -oP 'href="/channel/[^"]+"' | sed -e 's!href=!!' \
    -e 's!/channel/!channel_id=!' \
    -e 's!^!https://www.youtube.com/feeds/videos.xml?!' \
    | tr -d '"' | sort -u | tee youtubesubs.list

backup youtubesubs.list
cp youtubesubs.list ..
scp youtubesubs.list pi:src/youtube-subs2recentplaylist/
