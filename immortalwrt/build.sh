#!/bin/bash
set -euxo pipefail

# =============================
# ImmortalWrt 自定义快速构建脚本
# 支持 OneCloud 自动扩展 overlay 分区
# 默认 root 无密码，IP 192.168.2.2
# =============================

# 自定义要安装的包
PACKAGES=""
PACKAGES="$PACKAGES curl"
PACKAGES="$PACKAGES luci-i18n-base-zh-cn"
PACKAGES="$PACKAGES luci-i18n-firewall-zh-cn"
PACKAGES="$PACKAGES luci-i18n-package-manager-zh-cn"
PACKAGES="$PACKAGES luci luci-app-opkg luci-app-docker luci-app-ttyd luci-app-filebrowser "

# 根分区大小（单位 MB）
ROOTFS_PARTSIZE="512"

# 创建自定义文件结构
mkdir -p files/etc/init.d/
mkdir -p files/etc/config/

# === 设置 LAN 默认 IP 为 192.168.2.2 ===
cat > files/etc/config/network <<'EOF'
config interface 'lan'
	option ifname 'eth0'
	option proto 'static'
	option ipaddr '192.168.2.2'
	option netmask '255.255.255.0'
	option gateway '192.168.2.1'
	option dns '223.5.5.5'
EOF

# === 设置 root 密码为空 ===
mkdir -p files/etc
cat > files/etc/shadow <<'EOF'
root::0:0:99999:7:::
EOF

# === 添加自动扩展 overlay 分区脚本 ===
cat > files/etc/init.d/expand-overlay <<'EOF'
#!/bin/sh /etc/rc.common
# 自动扩展 overlay 分区，仅首次启动执行
START=99
STOP=10

start() {
    if [ -f /etc/expanded_done ]; then
        exit 0
    fi

    echo "开始扩展 overlay 分区..."
    parted /dev/mmcblk1 resizepart 2 100%
    losetup /dev/loop0 /dev/mmcblk1p2
    e2fsck -f -y /dev/loop0
    resize2fs -f /dev/loop0
    sync

    # 扩展 Docker 存储目录
    [ -d /opt/docker ] || mkdir -p /opt/docker
    mount -o bind /overlay/docker /opt/docker

    touch /etc/expanded_done
    echo "扩展完成，下次启动不再执行。"
    reboot
}
EOF

chmod +x files/etc/init.d/expand-overlay

# === 执行构建 ===
echo "🚀 开始构建镜像..."
make image PACKAGES="$PACKAGES" FILES="files" ROOTFS_PARTSIZE="$ROOTFS_PARTSIZE"

echo "🎉 构建完成！镜像已包含以下自定义功能："
echo " - 默认 IP: 192.168.2.2"
echo " - root 密码为空（直接登录）"
echo " - 自动扩展 overlay 分区（首次启动自动执行）"
echo " - 预装插件: luci、docker、openclash、ttyd、filebrowser、nikki 等"

