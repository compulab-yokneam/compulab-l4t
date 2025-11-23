#!/bin/bash -x

MY_FULL_NAME=$(readlink -e ${BASH_SOURCE[0]})
MY_FULL_FOLDER=$(dirname ${MY_FULL_NAME})
MFI_FOLDER=${MFI_FOLDER:-${MY_FULL_FOLDER}}

EDGE_AI="edge-ai"
MFI_CONF=${MFI_FOLDER}/${EDGE_AI}.conf

NVIDIA_DEVS=$(lsusb | awk '/NVIDIA Corp. APX/' | wc -l)

is_massflash_valid() {
	[[ -f ${MFI_CONF} ]] && return 0 || true
cat << eof

MFI Configureation ${MFI_CONF} is not found
Exiting ...

eof
    exit 2
}

is_massflash_available() {
    [[ ${NVIDIA_DEVS} -gt 0 ]] && return 0 || true
cat << eof
    Detected ${NVIDIA_DEVS} devices
    MassFlash is not available
    Make sure that an NVidia device is in recovery mode.
eof
    exit 1
}

deploy_massflash() {
    pushd ${L4T_ROOT}
    sudo ./tools/kernel_flash/l4t_initrd_flash.sh \
        --flash-only --massflash 5 --network usb0 --${massflash_arg:-"keep"}
    popd
}

is_massflash_valid
is_massflash_available

L4T_ROOT=${MFI_FOLDER} deploy_massflash
