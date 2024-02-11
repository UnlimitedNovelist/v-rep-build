#! /bin/bash

randstr=$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 8 | head -n 1)
project=v-rep
containerid=$project-build-$randstr
imageid=$project-build-$(id -u)

(set -xe; podman build -t $imageid .)

set -xe

#chmod a+x build_gca.sh
#chmod a+x startup.sh

podman run -it --rm \
    --name $containerid \
    -v "$(dirname $(readlink -f "$0")):/tmp/gca" \
    $imageid

#    --net=host -e DISPLAY=$DISPLAY \
#    --device=/dev/dri:/dev/dri \
#    -v "/tmp/.X11-unix:/tmp/.X11-unix" \
#    -v "$HOME/.Xauthority:/root/.Xauthority:rw" \