#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="${HOME}/.dotfiles-restore-backup/$(date +%Y%m%d-%H%M%S)"

if (($# == 0)); then
  RESTORE_HOME=1
else
  RESTORE_HOME=0
fi
RESTORE_SYSTEM=0
INSTALL_PACKAGES=0
REBUILD_BOOT=0

usage() {
  cat <<'USAGE'
Usage: ./install.sh [options]

Options:
  --home          Restore files under $HOME. This is the default.
  --system        Restore GRUB, Plymouth and mkinitcpio files using sudo.
  --packages      Install saved package lists when pacman/paru/flatpak exist.
  --rebuild-boot  After --system, run mkinitcpio and grub-mkconfig when present.
  --all           Restore home + system + packages and rebuild boot files.
  --help          Show this help.

Notes:
  Existing files are backed up to ~/.dotfiles-restore-backup/<timestamp>/.
  Review system/etc/default/grub after a reinstall: disk UUIDs can change.
USAGE
}

for arg in "$@"; do
  case "$arg" in
    --home)
      RESTORE_HOME=1
      ;;
    --system)
      RESTORE_SYSTEM=1
      ;;
    --packages)
      INSTALL_PACKAGES=1
      ;;
    --rebuild-boot)
      REBUILD_BOOT=1
      ;;
    --all)
      RESTORE_HOME=1
      RESTORE_SYSTEM=1
      INSTALL_PACKAGES=1
      REBUILD_BOOT=1
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $arg" >&2
      usage
      exit 2
      ;;
  esac
done

backup_user_path() {
  local target="$1"
  local rel="${target#"$HOME"/}"

  if [[ -e "$target" || -L "$target" ]]; then
    mkdir -p "$BACKUP_DIR/home/$(dirname "$rel")"
    cp -a "$target" "$BACKUP_DIR/home/$rel"
  fi
}

restore_user_entry() {
  local src="$1"
  local dst="$2"

  backup_user_path "$dst"
  mkdir -p "$(dirname "$dst")"
  rm -rf "$dst"
  cp -a "$src" "$dst"
}

restore_children() {
  local src_dir="$1"
  local dst_dir="$2"

  [[ -d "$src_dir" ]] || return 0
  mkdir -p "$dst_dir"
  while IFS= read -r -d '' src; do
    restore_user_entry "$src" "$dst_dir/$(basename "$src")"
  done < <(find "$src_dir" -mindepth 1 -maxdepth 1 -print0)
}

backup_system_path() {
  local target="$1"
  local rel="${target#/}"

  if sudo test -e "$target"; then
    sudo mkdir -p "$BACKUP_DIR/system/$(dirname "$rel")"
    sudo cp -a "$target" "$BACKUP_DIR/system/$rel"
  fi
}

restore_system_path() {
  local rel="$1"
  local src="$ROOT_DIR/system/$rel"
  local dst="/$rel"

  [[ -e "$src" || -L "$src" ]] || return 0
  backup_system_path "$dst"
  sudo mkdir -p "$(dirname "$dst")"
  sudo cp -a "$src" "$dst"
}

restore_system() {
  [[ -d "$ROOT_DIR/system" ]] || return 0

  echo "Restoring system files with sudo..."
  sudo -v
  restore_system_path "etc/default/grub"
  restore_system_path "etc/plymouth/plymouthd.conf"
  restore_system_path "etc/mkinitcpio.conf"
  restore_system_path "etc/auto-cpufreq.conf"
  restore_system_path "etc/intel-undervolt.conf"

  if [[ -d "$ROOT_DIR/system/etc/modprobe.d" ]]; then
    while IFS= read -r -d '' conf; do
      restore_system_path "etc/modprobe.d/$(basename "$conf")"
    done < <(find "$ROOT_DIR/system/etc/modprobe.d" -mindepth 1 -maxdepth 1 -type f -print0)
  fi

  if [[ -d "$ROOT_DIR/system/etc/systemd/system" ]]; then
    while IFS= read -r -d '' unit; do
      restore_system_path "etc/systemd/system/$(basename "$unit")"
    done < <(find "$ROOT_DIR/system/etc/systemd/system" -mindepth 1 -maxdepth 1 -type f -print0)
    sudo systemctl daemon-reload || true
  fi

  if [[ -d "$ROOT_DIR/system/usr/share/plymouth/themes" ]]; then
    while IFS= read -r -d '' theme; do
      restore_system_path "usr/share/plymouth/themes/$(basename "$theme")"
    done < <(find "$ROOT_DIR/system/usr/share/plymouth/themes" -mindepth 1 -maxdepth 1 -print0)
  fi

  if command -v plymouth-set-default-theme >/dev/null 2>&1; then
    sudo plymouth-set-default-theme PlymouthTheme-Cat || true
  fi

  if (( REBUILD_BOOT )); then
    if command -v mkinitcpio >/dev/null 2>&1; then
      sudo mkinitcpio -P
    fi

    if command -v grub-mkconfig >/dev/null 2>&1 && sudo test -d /boot/grub; then
      sudo grub-mkconfig -o /boot/grub/grub.cfg
    fi
  fi
}

install_packages() {
  [[ -d "$ROOT_DIR/packages" ]] || return 0

  echo "Installing package lists..."
  if command -v pacman >/dev/null 2>&1 && [[ -s "$ROOT_DIR/packages/native-explicit.txt" ]]; then
    xargs -r sudo pacman -S --needed -- < "$ROOT_DIR/packages/native-explicit.txt"
  fi

  if command -v paru >/dev/null 2>&1 && [[ -s "$ROOT_DIR/packages/aur-foreign.txt" ]]; then
    xargs -r paru -S --needed -- < "$ROOT_DIR/packages/aur-foreign.txt"
  elif command -v yay >/dev/null 2>&1 && [[ -s "$ROOT_DIR/packages/aur-foreign.txt" ]]; then
    xargs -r yay -S --needed -- < "$ROOT_DIR/packages/aur-foreign.txt"
  fi

  if command -v flatpak >/dev/null 2>&1 && [[ -s "$ROOT_DIR/packages/flatpak-apps.txt" ]]; then
    xargs -r flatpak install -y flathub < "$ROOT_DIR/packages/flatpak-apps.txt"
  fi
}

restore_home() {
  [[ -d "$ROOT_DIR/home" ]] || return 0

  echo "Restoring home files..."
  while IFS= read -r -d '' src; do
    case "$(basename "$src")" in
      .config|.local|Pictures|bin)
        ;;
      *)
        restore_user_entry "$src" "$HOME/$(basename "$src")"
        ;;
    esac
  done < <(find "$ROOT_DIR/home" -mindepth 1 -maxdepth 1 -print0)

  restore_children "$ROOT_DIR/home/.config" "$HOME/.config"
  restore_children "$ROOT_DIR/home/.local/bin" "$HOME/.local/bin"
  restore_children "$ROOT_DIR/home/.local/share" "$HOME/.local/share"
  restore_children "$ROOT_DIR/home/bin" "$HOME/bin"
  restore_children "$ROOT_DIR/home/Pictures" "$HOME/Pictures"
}

restore_home_if_enabled() {
  if (( RESTORE_HOME )); then
    restore_home
  fi
}

restore_home_if_enabled

if (( RESTORE_SYSTEM )); then
  restore_system
fi

if (( INSTALL_PACKAGES )); then
  install_packages
fi

echo "Done."
echo "Backups, if any, are in: $BACKUP_DIR"
