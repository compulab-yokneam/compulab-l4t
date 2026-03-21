#!/bin/bash 

prevent_fw_update() {
    local key_file="/opt/nvidia/l4t-packages/.nv-l4t-disable-boot-fw-update-in-preinstall"
    mkdir -p $(dirname ${key_file}) && touch ${key_file}
}

prevent_fw_update
