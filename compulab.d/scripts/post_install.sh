#!/bin/bash -x

VERSION=${1}

update_boot_files() {
    mkdir /boot/compulab/backup -p
    cp /boot/initrd /boot/compulab/initrd-${VERSION}
    cp /boot/Image /boot/compulab/Image-${VERSION}
    cp /boot/initrd /boot/compulab/backup/initrd-${VERSION}
    cp /boot/Image /boot/compulab/backup/Image-${VERSION}
}

update_boot_config() {
    sed -i "s/\(^ .*LINUX \).*$/\1\/boot\/compulab\/Image-${VERSION}/g"   /boot/extlinux/extlinux.conf
    sed -i "s/\(^ .*INITRD \).*$/\1\/boot\/compulab\/initrd-${VERSION}/g" /boot/extlinux/extlinux.conf
    sed -i "s/\(^. *APPEND \${cbootargs}\).*/\1 net.ifnames=0/g"          /boot/extlinux/extlinux.conf
    # sed -i "/FDT/d" /boot/extlinux/extlinux.conf
    # sed -i "/initrd-${VERSION}/a\      FDT /boot/dtbs/tegra234-p3768-0000+p3767-0000-nv-super-device.dtb" /boot/extlinux/extlinux.conf
}

prevent_bootloader_update() {
    local key_file="/opt/nvidia/l4t-packages/.nv-l4t-disable-boot-fw-update-in-preinstall"
    mkdir -p $(dirname ${key_file}) && touch ${key_file}
}

nv-update-initrd
update_boot_files
update_boot_config
prevent_bootloader_update
