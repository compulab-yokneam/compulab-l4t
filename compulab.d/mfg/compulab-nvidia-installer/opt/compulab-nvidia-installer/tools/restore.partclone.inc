[[ -z ${debug:-""} ]] || set -x
[[ $(id -u) -eq 0 ]] || exit -13

function apply_layout_func() {

    if [[ ! -f ${src}/disk.layout ]];then
        echo "Error: disk.layout is missing ..."
        return 2
    fi

    # Create layout { begin }
    cat ${src}/disk.layout | sfdisk ${device}
    echo "w" | fdisk ${device}
    sleep 1
    # Create layout { end }

    # Restore disk-id UUID if possible { begin }
    [[ ! -f ${src}/disk.id ]] && sfdisk --disk-id ${device} $(cat ${src}/disk.id)
    # Restore disk-id UUID if possible { end }

    return 0
}

function restore_partclone_func() {

    declare -A i_command=( ['xz']='xz -dc ' )

    # Get last partition number { begin }
    local part_dev=$(sfdisk --list ${device} | awk -v t=${device}  '{ if ( $1 ~ t ) { print $2" "$1 } }' | sort -n | tail -1 | awk '$0=$2')
    local last_part_num=$(cat  /sys/class/block/$(basename ${part_dev})/partition)
    # Get last partition number { end }

    for _wait in $(seq 1 3);do
        echo -n $_wait" "; sleep 1
    done

    for _device in ${device}*;do
        eval $(blkid ${_device} | awk -F":" '($0="dev="$1" "$2)';)
        local _dev=$(basename ${dev})
        [[ -f /sys/class/block/${_dev}/partition ]] || continue
        local num=$(cat /sys/class/block/${_dev}/partition)
        local image=$(ls ${src}/part${num}.* 2>/dev/null || true)
        if [[ -z ${image:-""} ]];then
            echo "No image file for part # ${num}; skip 'n' continue ..."
            continue
        fi
        # get part type and uuid from the image name { begin }
        local name=$(basename ${image}); name=(${name//./ })
        local type=${name[1]} uuid=${name[2]}
        # get part type and uuid from the image name { end }
        if [[ ${type} = swap ]];then
            # Create a swap partition { begin }
            mkswap ${_device} --uuid ${uuid}
            continue
            # Create a swap partition { end }
        fi
        [[ ${type} = dd ]] && pc_command="partclone.dd" || pc_command="partclone.restore -C "
        local _file_type=$(file ${image} | awk '$0=tolower($2)')
        local _command=${i_command[${_file_type}]:-"dd if="}
# cat << eof
        ${_command}${image} | ${pc_command} -d -s - -o ${_device} && rc=$? || rc=$?
# eof
        if [[ ${rc} -ne 0 ]];then
            echo "Error: deployment ( ${image} -> ${_device} )  error=${rc}"
            return ${rc}
        fi
	# Expand las part if yes
	[[ ${expand_last_part:-""} = 'yes' ]] || continue
        if [[ ${last_part_num} = ${num} ]];then
    	    parted -s ${device} resizepart ${last_part_num} 100%
            e2fsck -f ${_device} || true
            resize2fs ${_device} || true
        fi
    done
    return 0
}

# src=${src} device=${device} restore_partclone_func
