#!/bin/bash 

extlinux=/boot/extlinux/extlinux.conf
BR=$(awk '(/TNSPEC/)&&($0=$2)' /etc/nv_boot_control.conf)
BR=(${BR//-/ })
BR=${BR[2]}
FDT="/boot/dtbs/tegra234-p3768-0000+p3767-${BR}-nv-super-host.dtb"

function bad_case() {
cat << eof | tee /dev/kmsg
	The device tree ${FDT} is not found.
	Exit w/out the ${extlinux} file update ...
eof
exit 0
}

function empty_case() {
cat << eof | tee /dev/kmsg
	The device tree ${FDT} is already in the ${extlinux} file
	Exit w/out the ${extlinux} file update ...
eof
exit 0
}

function good_case() {
cat << eof | tee /dev/kmsg
	The device tree ${FDT} is found.
	The ${extlinux} file has been updated.
	Reboot is required.
eof
exit 0
}

function fdt_main() {
	[[ -f ${FDT} ]] || bad_case
	FDT_SHORT=$(basename ${FDT})
	grep -q ${FDT_SHORT} ${extlinux} && empty_case || true
	sed -i "/FDT/d" ${extlinux}
	sed -i "/root=/i\      FDT ${FDT}" ${extlinux}
	good_case
}

fdt_main
