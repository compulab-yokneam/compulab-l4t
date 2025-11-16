#!/bin/bash -x

VERSION=${1}

update_boot_files() {
	cp /boot/initrd /boot/initrd-${VERSION}
	cp /boot/Image /boot/Image-${VERSION}
}

update_boot_config() {
	sed -i "s/\(^ .*LINUX.*Image\).*$/\1-${VERSION}/g"          /boot/extlinux/extlinux.conf
	sed -i "s/\(^ .*INITRD.*initrd\).*$/\1-${VERSION}/g"i       /boot/extlinux/extlinux.conf
	sed -i 's/\(^. *APPEND ${cbootargs}\).*/\1 net.ifnames=0/g' /boot/extlinux/extlinux.conf

}

prevent_bootloader_update() {
	local key_file="/opt/nvidia/l4t-packages/.nv-l4t-disable-boot-fw-update-in-preinstall"
	mkdir -p $(dirname ${key_file}) && touch ${key_file}
}

nv-update-initrd
update_boot_files
update_boot_config
prevent_bootloader_update
