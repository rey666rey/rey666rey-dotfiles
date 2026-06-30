#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="$ROOT_DIR/nvidia-compat32"

mkdir -p "$TARGET_DIR"

if [[ ! -d /usr/lib32 ]]; then
  echo "/usr/lib32 was not found. Install lib32-nvidia-utils first." >&2
  exit 1
fi

for name in \
  libGLX_nvidia.so* \
  libnvidia-allocator.so* \
  libnvidia-glcore.so* \
  libnvidia-glsi.so* \
  libnvidia-glvkspirv.so* \
  libnvidia-gpucomp.so* \
  libnvidia-tls.so*
do
  find /usr/lib32 -maxdepth 1 \( -type f -o -type l \) -name "$name" -exec cp -a {} "$TARGET_DIR/" \;
done

if ! find "$TARGET_DIR" -mindepth 1 ! -name .gitkeep | grep -q .; then
  echo "No Nvidia 32-bit libraries were copied. Check that lib32-nvidia-utils is installed." >&2
  exit 1
fi

echo "Updated $TARGET_DIR"
