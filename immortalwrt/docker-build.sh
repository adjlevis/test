#!/bin/bash
set -euxo pipefail

WORKDIR=$(pwd)

echo "🚀 开始 Docker 构建..."

docker run --rm --user root \
  -v "${WORKDIR}":/home/build/immortalwrt \
  -w /home/build/immortalwrt \
  immortalwrt/imagebuilder:armsr-armv7-openwrt-24.10 \
  bash -c "
    set -euxo pipefail

    echo '🚀 调用 build.sh 构建固件...'
    bash ./build.sh

    echo '🔹 查找生成的 ext4-combined-efi 镜像...'
    SRC_IMG=\$(find bin/targets -type f -name '*ext4-combined-efi.img.gz' | head -n 1)

    if [ -z \"\$SRC_IMG\" ]; then
      echo '❌ 没找到 ext4-combined-efi 镜像'
      exit 1
    fi

    echo \"✅ 找到生成固件：\$SRC_IMG\"
  "
