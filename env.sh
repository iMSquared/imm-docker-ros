#!/usr/bin/env bash

# Best practices with shell scripting ...
set -ex

find_robot(){
    # FIXME(ycho): Hardcoded robot mac address...
    ROBOT_MAC_ADDR='34:13:e8:cf:96:df'
    WIFI_DEVICE="$(iw dev | awk '$1=="Interface"{print $2}')"
    ROBOT_IP="$(sudo arp-scan --interface=wlp0s20f3 --localnet | grep 34:13:e8:cf:96:df | awk '{print $1}')"
    echo ${ROBOT_IP}
}

set_network(){
    # FIXME(ycho): Pretty fragile
    MY_IP="$(hostname -I | awk '{print $1}')"
    export ROS_IP="${MY_IP}"
    export ROBOT_IP="$(find_robot)"
    if [ -z "${ROBOT_IP}" ]; then
        echo 'ROBOT NOT FOUND! Fallback to HOST IP'
        export ROBOT_IP="${MY_IP}"
    fi
    export ROS_MASTER_URI="http://${ROBOT_IP}:11311"
}

set_network

# Unset flags just in case.
set +ex
