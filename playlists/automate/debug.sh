#!/bin/bash

set -euo pipefail

. ./tag

docker run -it --rm \
  --volume=$WORKDIR/subs.py:/subs.py \
  --volume=$WORKDIR/chrome-settings:/home/chome/.config/chromium \
  --entrypoint=/bin/sh \
  ${TAG}:latest

