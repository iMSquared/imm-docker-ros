#!/usr/bin/env bash

set -ex

DOCKER_BUILDKIT=1 docker build --progress=plain --ssh default -t imm-ros .
