#!/bin/bash

set -euo pipefail

. ./tag

docker push ds1:6000/$TAG:$DATE
docker push ds1:6000/$TAG:latest
