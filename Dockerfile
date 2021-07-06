#!/usr/bin/env bash

set -x
set -e

docker run --network host -it --rm \
    --env="DISPLAY" \
    --env="QT_X11_NO_MITSHM=1" \
    --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
    --privileged \
    imm-ros \
    /bin/bash