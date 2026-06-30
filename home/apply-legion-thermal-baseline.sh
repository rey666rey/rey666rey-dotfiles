#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_SRC="$SCRIPT_DIR/intel-undervolt.conf.codex"

if [[ $EUID -ne 0 ]]; then
  echo "Run as root: sudo $0"
  exit 1
fi

if [[ ! -f "$CONFIG_SRC" ]]; then
  echo "Missing config: $CONFIG_SRC"
  exit 1
fi

install -m 644 "$CONFIG_SRC" /etc/intel-undervolt.conf
systemctl disable --now auto-cpufreq || true
systemctl enable --now thermald
systemctl enable --now intel-undervolt
powerprofilesctl set balanced

echo "Applied thermal baseline."
echo
echo "Current profile:"
powerprofilesctl get
echo
echo "Platform profile:"
cat /sys/firmware/acpi/platform_profile
echo
echo "RAPL limits:"
for f in \
  /sys/class/powercap/intel-rapl:0/constraint_0_power_limit_uw \
  /sys/class/powercap/intel-rapl:0/constraint_1_power_limit_uw \
  /sys/class/powercap/intel-rapl-mmio:0/constraint_0_power_limit_uw \
  /sys/class/powercap/intel-rapl-mmio:0/constraint_1_power_limit_uw
do
  [[ -f "$f" ]] && printf "%s = %s\n" "$f" "$(cat "$f")"
done
