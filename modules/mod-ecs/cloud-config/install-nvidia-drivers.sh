#!/bin/bash

function install_nvidia_drivers() {
    yum update -y
    curl http://us.download.nvidia.com/XFree86/Linux-x86_64/410.93/NVIDIA-Linux-x86_64-410.93.run -o NVIDIA-Linux-x86_64-410.93.run
    chmod +x NVIDIA-Linux-x86_64-410.93.run
    ./NVIDIA-Linux-x86_64-410.93.run -dkms --glvnd-egl-config-path /usr/lib/dkms/ --no-questions --silent
}

install_nvidia_drivers
