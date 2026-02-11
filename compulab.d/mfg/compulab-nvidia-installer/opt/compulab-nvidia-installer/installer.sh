#!/bin/bash -e

work_dir=$(readlink -e $(dirname ${BASH_SOURCE[0]}))
tools_dir=${work_dir}/tools
src_dir=${work_dir}/data/images.d/01
rootfs_dir=${work_dir}/data/rootfs.d

source ${work_dir}/installer.env
source ${work_dir}/installer.inc
source ${work_dir}/installer.lay
source ${tools_dir}/restore.partclone.inc

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
    local layout=""

    for _layout in $(for __layout in ${!layout_array[@]};do echo ${__layout}; done | sort -u);do
        layout_id=${_layout}
        layout_string=$(sed "s/ /__/g" <<< ${layout_array[${_layout}]})
        select_string+="${layout_id}--[${layout_string}]  "
    done
    select_string+=" Exit"
    PS3="Choose layout > "
    while [ -z ${layout:-""} ];do
        select j in ${select_string}; do
            case ${j} in
                "Exit")
                exit 0
                ;;
                *)
                layout=${j}
                break
                ;;
            esac
        done
    done

    # Get the layout func from the select string
    layout=(${layout/--/ })
    layout=${layout[0]}

    ${layout}
    inst_init
    src=${src_dir} device=${device} apply_layout_func
    src=${src_dir} device=${device} restore_partclone_func
    inst_fini

    [[ $? -eq 0 ]] && figlet "Done: OKAY" || figlet "Failed"
}

installer_probe_func
cat << eof
Starting install onto the ${device} ...
eof
installer_func
