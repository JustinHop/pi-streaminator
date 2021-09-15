#!/bin/bash

set -euo pipefail
set -x

. ./tag

uid=1000
APPUSER=mpv

_VIDEO=""
for _DEV in /dev/video* /dev/argon* /dev/rpivid* /dev/dri/card* /dev/dri/renderD128 ; do
    _VIDEO="${_VIDEO} --device=${_DEV}:${_DEV}"
done


exec docker run -it --rm --user 0:0 -e HOME=/home/mpv \
    --name=mpv \
    -e PATH \
    -e LD_LIBRARY_PATH \
    -e TZ \
    --net host \
    -e DISPLAY \
    -e DBUS_SESSION_BUS_ADDRESS \
    -e XDG_RUNTIME_DIR \
    --privileged \
    --security-opt="seccomp=unconfined" \
    --security-opt="apparmor=unconfined" \
    -v /run/user/$uid:/run/user/$uid \
    -v /run/dbus:/run/dbus \
    -v /var/run/dbus:/var/run/dbus \
    -v "$WORKDIR/config:/home/${APPUSER}/.config" \
    -v "$WORKDIR/cache:/home/${APPUSER}/.cache" \
    -v "$WORKDIR/local:/home/${APPUSER}/.local" \
    -v /usr/share/fonts:/usr/share/fonts \
    -v /usr/share/themes:/usr/share/themes \
    -v /usr/share/icons:/usr/share/icons \
    -v ~/Downloads:/home/$APPUSER/Downloads \
    -v ~/tube:/home/$APPUSER/tube \
    -v ~/bin/youtube-player:/home/$APPUSER/bin/youtube-player \
    -v /mnt/auto/video:/video \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    --entrypoint /bin/bash \
    ds1:6000/${TAG} $*



foo='
    --entrypoint /home/$APPUSER/bin/youtube-player \
    -v /dev/shm:/dev/shm \
    ${_VIDEO} ds1:6000/${TAG} $*


        '
