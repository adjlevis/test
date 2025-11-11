#!/bin/bash
set -euxo pipefail

WORKDIR=$(pwd)

echo "🚀 开始准备构建环境..."

docker run --rm --user root \
  -v "${WORKDIR}":/home/build/immortalwrt \
  -w /home/build/immortalwrt \
  immortalwrt/imagebuilder:armsr-armv7-openwrt-24.10 \
  bash -c "
    set -euxo pipefail
    echo '🚀 更新 feeds...'
    ./scripts/feeds update -a
    ./scripts/feeds install -a
    echo '🚀 开始编译固件...'
    bash ./build.sh
  "
