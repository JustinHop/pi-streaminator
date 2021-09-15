#!/bin/bash

set -euo pipefail

WORKDIR=$(dirname $(realpath $0))
cd $WORKDIR

. ./tag

docker run -it --rm \
  --volume=$WORKDIR/subs.py:/subs.py \
  --volume=$WORKDIR/chrome-settings:/home/chome/.config/chromium \
  --entrypoint=/usr/bin/python3 \
  ${TAG}:latest /subs.py $*

