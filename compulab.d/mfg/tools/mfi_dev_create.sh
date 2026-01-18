#!/bin/bash -x

prepare_mfi() {
    local _board="000${1}"
    pushd ${L4T_ROOT}
    sudo BOARDID=3767 BOARDSKU=${_board} FAB=TS4 ./tools/kernel_flash/l4t_initrd_flash.sh --external-device nvme0n1p1 -c tools/kernel_flash/flash_l4t_t234_nvme.xml -p "-c bootloader/generic/cfg/flash_t234_qspi.xml" --no-flash --massflash 1 --showlogs --network usb0 edge-ai external
    mv mfi_edge-ai.tar.gz ${_board}_mfi_edge-ai.tar.gz
    popd
}

main_mfi() {
    for board in 0 1 3 4;do
        prepare_mfi ${board}
    done
}

main() {
    [[ -n ${L4T_ROOT:-""} ]] || return 1
    main_mfi
}
