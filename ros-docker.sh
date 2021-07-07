#!/usr/bin/env bash

set -x
set -e

docker run -it --rm \
    --network host \
    --env="DISPLAY" \
    --env="QT_X11_NO_MITSHM=1" \
    --mount type=bind,source=/tmp/.X11-unix,target=/tmp/.X11-unix \
    --device=/dev/dri:/dev/dri \
    --privileged \
    imm-ros
