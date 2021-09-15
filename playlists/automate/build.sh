#!/bin/bash

set -euo pipefail

. ./tag

docker build -t ${TAG}:${DATE} -t ${TAG}:latest .
