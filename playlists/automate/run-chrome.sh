#!/bin/bash

WORKDIR=$(dirname $(realpath $0))
cd $WORKDIR

SNAP_USER_DATA=$WORKDIR/local

chromium-browser --user-data-dir=$WORKDIR/chrome-settings
