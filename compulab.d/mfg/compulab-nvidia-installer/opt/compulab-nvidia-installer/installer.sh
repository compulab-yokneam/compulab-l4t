#!/bin/bash -e

work_dir=$(readlink -e $(dirname ${BASH_SOURCE[0]}))
tools_dir=${work_dir}/tools
src_dir=${work_dir}/images.d/nvidia-swap-storage
layout_dir=${work_dir}/images.d/layouts.d

source ${work_dir}/installer.env

choose_device_func() {
	local select_string=$(get_install_devices)" Exit"
	PS3="Choose device > "
	local _device=""
	while [ -z ${_device:-""} ];do
		select j in ${select_string}; do
			case ${j} in
				"Exit")
				exit 0
				;;
				*)
				export device=${j}
				return 0
				;;
			esac
		done
	done
}

installer_probe_func() {
	if [ -z ${device:-""} ];then
		choose_device_func ; return $?

	fi
	if [ ! -b ${device:-""} ];then
		choose_device_func ; return $?
	fi
	local root_device=$(get_root_device)
	if [ ${device} = ${root_device} ];then
cat << eof
	WARNING: Target device is the current root device ${device} please choose another one ..."
eof
		choose_device_func ; return $?
	fi
}

installer_func() {
	local select_string=""
	for l in ${layout_dir}/* ;do 
		layout_id=$(basename ${l})
		layout_string=$(sed "s/ /__/g" ${l}/desk.layout)
		select_string+="${layout_id}--[${layout_string}]  "
	done
	select_string+="99--[Unsupported_Layout] Exit"
	PS3="Choose layout > "
	local LAYOUT=""
	while [ -z ${LAYOUT:-""} ];do
		select j in ${select_string}; do
			case ${j} in
				"Exit")
				exit 0
				;;
				*)
				LAYOUT=${j:0:2}
				break
				;;
			esac
		done
	done

	[[ -f  ${layout_dir}/${LAYOUT}/func.layout ]] || { echo "Bad case, exiting.." ; exit 22; }
	source ${layout_dir}/${LAYOUT}/func.layout

	inst_init
	src=${src_dir} device=${device} ${tools_dir}/restore.partclone.sh
	inst_fini

	[[ $? -eq 0 ]] && figlet "Done: OKAY" || figlet "Failed"
}

installer_probe_func
cat << eof
Starting install onto the ${device} ...
eof
installer_func
