#!/bin/bash

set -euo pipefail
IFS=$'\t\n'

set -x




BASEOPTS=" --ignore-config -J "

GEO=" --geo-bypass --geo-bypass-country=US "

PLAYLIST_NO=" --no-playlist "
PLAYLIST=" --yes-playlist "


LIST_SUBS=" --list-subs "

FORMATS=" -F "
