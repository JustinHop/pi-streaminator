#!/bin/bash

set -euo pipefail
IFS=$"\t\n"

set -x
cat youtubesubs.list | shuf -n 5 | xargs youtube-dl \
    --ignore-config \
    --format="bestvideo[ext=mp4][width<=1920]+bestaudio/bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best" \
    --dateafter=$(date -d "2 days ago" +%Y%m%d ) \
    --dump-json --verbose | tee youtubesubs.$(date +%s).output

#    --add-metadata \
#    --sub-format="srt/ass/best" \
#    --sub-lang="en,th" \

