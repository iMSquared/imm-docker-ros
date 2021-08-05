#!/usr/bin/env bash

set -ex

# TODO(ycho): Guard against cases where 
# the scripts fail to find the robot.
ROOT="$(git rev-parse --show-toplevel)"
source "${ROOT}/env.sh"

# Launch docker.
docker run -it --rm \
    --network host \
    --env DISPLAY \
    --env QT_X11_NO_MITSHM=1 \
    --env ROS_MASTER_URI="${ROS_MASTER_URI}" \
    --env ROS_IP="${ROS_IP}" \
    --mount type=bind,source=/tmp/.X11-unix,target=/tmp/.X11-unix \
    --device=/dev/dri:/dev/dri \
    --add-host="SXLS0-201214AB:${ROBOT_IP}" \
    --privileged \
    --gpus all \
    imm-ros:gpu
