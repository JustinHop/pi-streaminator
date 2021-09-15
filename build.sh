#!/bin/bash

set -euo pipefail

set -x

. ./tag
export DOCKER_BUILDKIT=1
docker build \
    -t $TAG \
    -t ds1:6000/$TAG:latest-alpine \
    -t ds1:6000/$TAG:${DATE}-alpine \
    -t ds2:6000/$TAG:latest-alpine \
    -t ds2:6000/$TAG:${DATE}-alpine \
    .
docker push  ds1:6000/$TAG:latest-alpine
docker push  ds1:6000/$TAG:${DATE}-alpine
docker push  ds2:6000/$TAG:latest-alpine
docker push  ds2:6000/$TAG:${DATE}-alpine
