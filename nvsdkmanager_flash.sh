#!/bin/bash -x

deploy_bootloader_rootfs() {
    ./tools/kernel_flash/l4t_initrd_flash.sh \
    --external-device nvme0n1p1 \
    -c tools/kernel_flash/flash_l4t_t234_nvme.xml \
    -p "-c bootloader/generic/cfg/flash_t234_qspi.xml" \
    --keep --showlogs --network usb0 edge-ai-rev1v2 external
}

deploy_bootloader_rootfs
