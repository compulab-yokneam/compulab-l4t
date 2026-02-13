#!/bin/bash

declare -A array;
array['/tmp/nvidia-installer-root.tar.bz2']="tar -C compulab.d/mfg/compulab-nvidia-installer/ -cvjf /tmp/nvidia-installer-full.tar.bz2 --exclude=opt/compulab-nvidia-installer/data/images.d ."
array['/tmp/nvidia-installer-opt.tar.bz2']="tar -C compulab.d/mfg/compulab-nvidia-installer/opt/  -cvjf /tmp/nvidia-installer-opt.tar.bz2 --exclude=compulab-nvidia-installer/data/images.d ."


for _tar_cmd in ${!array[@]};do
	${array[${_tar_cmd}]}
done
