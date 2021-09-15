#!/bin/bash

set -euo pipefail
set -x


#. ./tag

cd /mnt/auto/video
cd /mnt/auto/1

WORKDIR=$(dirname $(realpath $0))
cd $WORKDIR

uid=1000
APPUSER=pi

#TAG=ds1:6000/justinhop/mpv:latest
#TAG=a2444be96b3e
#TAG="ds1:6000/justinhop/mpv:2021-01-20-alpine"
TAG="ds1:6000/justinhop/mpv:latest-alpine"

#_VIDEO=""
#for _DEV in /dev/video* /dev/argon* /dev/rpivid* /dev/dri/card* /dev/dri/renderD128 ; do
#    _VIDEO="${_VIDEO} --device=${_DEV}:${_DEV}"
#done


{ sleep 5s; xdotool key f f ; } &
{ sleep 10s; sudo chown pi:pi /run/user/1000/mpv.socket ; } &

{ sleep 5s; docker exec mpv /bin/bash -c "youtube-dl --version" ; } &
#--user 0:0 
exec docker run -it --rm \
    --user 0:0  \
    -e HOME=/home/pi \
    --name=mpv \
    --net host \
    -e PATH \
    -e LD_LIBRARY_PATH \
    -e TZ \
    -e DISPLAY \
    -e DBUS_SESSION_BUS_ADDRESS \
    -e XDG_RUNTIME_DIR \
    -e XDG_CONFIG_HOME=/home/$APPUSER/.config \
    --privileged \
    --security-opt="seccomp=unconfined" \
    --security-opt="apparmor=unconfined" \
    -v /run/user/$uid:/run/user/$uid \
    -v /run/dbus:/run/dbus \
    -v /var/run/dbus:/var/run/dbus \
    -v /usr/share/fonts:/usr/share/fonts \
    -v "$WORKDIR/config:/home/${APPUSER}/.config" \
    -v "$WORKDIR/cache:/home/${APPUSER}/.cache" \
    -v "$WORKDIR/youtube-player:/home/$APPUSER/bin/youtube-player" \
    -v ~/tube:/home/$APPUSER/tube \
    -v /mnt/auto/1:/mnt/auto/1 \
    -v /mnt/auto/video:/mnt/auto/video \
    -v /tmp/:/tmp/ \
    --entrypoint /home/$APPUSER/bin/youtube-player \
    ${TAG} $*



foo='
    -v /dev/shm:/dev/shm \
    ${_VIDEO} ds1:6000/${TAG} $*


        '
