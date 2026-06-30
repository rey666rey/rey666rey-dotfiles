#!/usr/bin/env bash
set -e

# Expose only the host's 32-bit Nvidia userspace libraries to the
# Ubuntu-based app container. Do not mount the full host /usr/lib32,
# because unrelated Arch libs can break Steam's own 32-bit runtime.
if [ -d /opt/nvidia-compat32 ]; then
    cat >/etc/ld.so.conf.d/zz-nvidia-compat32.conf <<'EOF'
/opt/nvidia-compat32
EOF
    mkdir -p /usr/share/vulkan/icd.d
    cat >/usr/share/vulkan/icd.d/nvidia_icd.i686.json <<'EOF'
{
    "file_format_version" : "1.0.1",
    "ICD": {
        "library_path": "libGLX_nvidia.so.0",
        "api_version" : "1.4.329"
    }
}
EOF
    ldconfig || true
fi
