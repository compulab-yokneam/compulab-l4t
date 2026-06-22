#!/bin/bash -x

deploy_bootloader_rootfs() {
    local qspi_cfg="bootloader/generic/cfg/flash_t234_qspi.xml"
    [[ -f bootloader/t186ref/cfg/flash_t234_qspi.xml && ! -f ${qspi_cfg} ]] && qspi_cfg="bootloader/t186ref/cfg/flash_t234_qspi.xml"

    ./tools/kernel_flash/l4t_initrd_flash.sh \
    --external-device nvme0n1p1 \
    -c tools/kernel_flash/flash_l4t_t234_nvme.xml \
    -p "-c ${qspi_cfg}" \
    --keep --showlogs --network usb0 edge-ai external
}

deploy_bootloader_rootfs
