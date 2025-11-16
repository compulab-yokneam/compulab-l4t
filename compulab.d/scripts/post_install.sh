#!/bin/bash -x

VERSION=${1}

update_boot_files() {
	cp /boot/initrd /boot/initrd-${VERSION}
	cp /boot/Image /boot/Image-${VERSION}
}

update_boot_config() {
	sed -i "s/\(^ .*LINUX.*Image\).*$/\1-${VERSION}/g"    /boot/extlinux/extlinux.conf
	sed -i "s/\(^ .*INITRD.*initrd\).*$/\1-${VERSION}/g"  /boot/extlinux/extlinux.conf
}

nv-update-initrd
update_boot_files
update_boot_config
