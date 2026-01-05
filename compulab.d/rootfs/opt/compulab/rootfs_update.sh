#!/bin/bash 

INITD_FOLDER=/opt/compulab/init.d

init_main() {
    [[ -d ${INITD_FOLDER} ]] || return 0
    for script in ${INITD_FOLDER}/*; do
        echo ${script}
    done
}

init_main
