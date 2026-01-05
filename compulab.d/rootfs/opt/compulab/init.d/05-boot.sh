#!/bin/bash 

extlinux=/boot/extlinux/extlinux.conf
BR=$(awk '(/TNSPEC/)&&($0=$2)' /etc/nv_boot_control.conf)
BR=(${BR//-/ })
BR=${BR[2]}
FDT="/boot/dtbs/tegra234-p3768-0000+p3767-${BR}-nv-super-host.dtb"

main_reboot() {
cat << eof | tee /dev/kmsg
    Maintenace reboot ...
eof
for _c in s u b;do
    echo ${_c} > /proc/sysrq-trigger
done
return 0
}

bad_case() {
cat << eof | tee /dev/kmsg
    The device tree ${FDT} is not found.
    Exit w/out the ${extlinux} file update ...
eof
return 0
}

empty_case() {
cat << eof | tee /dev/kmsg
    The device tree ${FDT} is already in the ${extlinux} file
    Exit w/out the ${extlinux} file update ...
eof
return 0
}

good_case() {
cat << eof | tee /dev/kmsg
    The device tree ${FDT} is found.
    The ${extlinux} file has been updated.
    Reboot is required.
eof
return 0
}

chroot_exit() {
cat << eof
    The chroot environment detected.
    Bye ...
eof
return 0
}

fdt_main() {
    ischroot && { chroot_exit; return 0; }
    [[ -f ${FDT} ]] || { bad_case; return 0; }
    FDT_SHORT=$(basename ${FDT})
    grep -q ${FDT_SHORT} ${extlinux} && { empty_case; return 0; } || true
    sed -i "/FDT/d" ${extlinux}
    sed -i "/root=/i\      FDT ${FDT}" ${extlinux}
    good_case && main_reboot || true
}

prevent_fw_update() {
    local key_file="/opt/nvidia/l4t-packages/.nv-l4t-disable-boot-fw-update-in-preinstall"
    mkdir -p $(dirname ${key_file}) && touch ${key_file}
}

prevent_fw_update
fdt_main
