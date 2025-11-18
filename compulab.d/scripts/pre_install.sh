#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

update_soc_info() {
    local nvidia_source=/etc/apt/sources.list.d/nvidia-l4t-apt-source.list 
    sed -i 's/<SOC>/t234/g' ${nvidia_source}
}

prevent_bootloader_update() {
    local key_file="/opt/nvidia/l4t-packages/.nv-l4t-disable-boot-fw-update-in-preinstall"
    mkdir -p $(dirname ${key_file}) && touch ${key_file}
}

rootfs_update() {
    apt update
    apt upgrade -y
    apt install -y nvidia-jetpack
    apt autoremove -y
}

update_soc_info
prevent_bootloader_update
rootfs_update
