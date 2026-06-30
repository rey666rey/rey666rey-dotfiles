#!/usr/bin/env bash

set -e

mkdir -p /usr/share/vulkan/icd.d

if [ -f /etc/vulkan/icd.d/nvidia_icd.json ] && [ ! -f /usr/share/vulkan/icd.d/nvidia_icd.json ]; then
    ln -sf /etc/vulkan/icd.d/nvidia_icd.json /usr/share/vulkan/icd.d/nvidia_icd.json
fi

if [ -f /etc/vulkan/icd.d/nvidia_icd.i686.json ] && [ ! -f /usr/share/vulkan/icd.d/nvidia_icd.i686.json ]; then
    ln -sf /etc/vulkan/icd.d/nvidia_icd.i686.json /usr/share/vulkan/icd.d/nvidia_icd.i686.json
fi
