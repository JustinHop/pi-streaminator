#!/bin/bash

set -euo pipefail

. ./tag

# docker build -t ${TAG}:${DATE} -t ${TAG}:latest 
docker tag ${TAG}:latest ds1:6000/${TAG}:latest
docker tag ${TAG}:${DATE} ds1:6000/${TAG}:latest
docker push ds1:6000/${TAG}:latest
docker push ds1:6000/${TAG}:${DATE}
