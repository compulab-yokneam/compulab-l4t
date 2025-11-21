#!/bin/bash -x

export COMPULAB_VERSION=${1}
export NVIDIA_VERSION=${2:-$COMPULAB_VERSION}
export SYS_SERVICE_LIST=${3:-"empty-service-name,"}

_update_boot_files() {
    mkdir /boot/compulab/backup -p
    cp /boot/initrd /boot/compulab/initrd-${COMPULAB_VERSION}
    cp /boot/Image /boot/compulab/Image-${COMPULAB_VERSION}
    cp /boot/initrd /boot/compulab/backup/initrd-${COMPULAB_VERSION}
    cp /boot/Image /boot/compulab/backup/Image-${COMPULAB_VERSION}
}

_update_boot_config_kernel() {
    sed -i "s/\(^ .*LINUX \).*$/\1\/boot\/compulab\/Image-${COMPULAB_VERSION}/g"   /boot/extlinux/extlinux.conf
    sed -i "s/\(^ .*INITRD \).*$/\1\/boot\/compulab\/initrd-${COMPULAB_VERSION}/g" /boot/extlinux/extlinux.conf
}

update_boot_files() {
    _update_boot_files
    _update_boot_config_kernel
}

update_boot_config_bootargs() {
    sed -i "s/\(^. *APPEND \${cbootargs}\).*/\1 net.ifnames=0/g"          /boot/extlinux/extlinux.conf
}

update_system_services() {
    local sys_service_list="${SYS_SERVICE_LIST//,/ }"
    for _service in ${sys_service_list};do
        [[ -f /lib/systemd/system/${_service}.service ]] && systemctl enable ${_service} || true
    done
}

nv-update-initrd
[[ "${COMPULAB_VERSION}" = "${NVIDIA_VERSION}" ]] || update_boot_files
update_boot_config_bootargs
update_system_services
