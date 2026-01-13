#!/bin/bash 

extlinux=/boot/extlinux/extlinux.conf
export SOM_EEPROM_I2C_ADDR=50
export SOM_EEPROM_I2C_BUS=0
export SOM_EEPROM_DEV=/sys/bus/i2c/devices/${SOM_EEPROM_I2C_BUS}-00${SOM_EEPROM_I2C_ADDR}/eeprom
BR=$(dd if=${SOM_EEPROM_DEV} skip=$((0x1E)) bs=1 count=4 2>/dev/null)
FDT="/boot/dtbs/tegra234-p3768-0000+p3767-${BR}-nv-super-host.dtb"

main_reboot() {
cat << eof | tee /dev/kmsg
    Maintenace reboot ...
eof
ischroot && { chroot_exit; return 0; }
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
