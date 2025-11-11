#!/bin/bash
set -euxo pipefail

WORKDIR=$(pwd)

docker run --rm --user root \
  -v "${WORKDIR}":/home/build/immortalwrt \
  -w /home/build/immortalwrt \
  immortalwrt/imagebuilder:armsr-armv7-openwrt-24.10 \
  bash ./build.sh
