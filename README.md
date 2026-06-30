# rey666rey dotfiles

Personal system configuration backup for restoring the desktop after a reinstall.

## What is included

- Shell dotfiles: `.zshrc`, `.bashrc`, `.profile`, `.p10k.zsh`, `.gitconfig`
- Desktop config: Hyprland, Hypridle, Hyprlock, Waybar, Rofi, SwayNC, Wlogout
- Terminal/UI config: Kitty, Ghostty, GTK, Qt, Matugen, Cava, Fastfetch, btop, htop
- User scripts: `~/.config/bin`, selected `~/.local/bin`, selected `~/bin`
- Wallpapers: `~/Pictures/Wallpapers`
- Wolf Docker setup: compose file, active config, helper scripts and selected XFCE settings
- Extra services/config: user systemd units, Legion thermal configs, modprobe configs, omniroute compose file
- Boot theming/config: GRUB, Plymouth, mkinitcpio
- Package lists: native pacman packages, AUR packages, Flatpak apps

Private keys, browser profiles, app sessions, caches, cloud/VPN secrets, tokens, Wolf runtime data and personal document folders are intentionally not included.

## Restore

Home files only:

```bash
./install.sh
```

Full restore:

```bash
./install.sh --all
```

System files only:

```bash
./install.sh --system --rebuild-boot
```

Package lists only:

```bash
./install.sh --packages
```

The script backs up overwritten files into `~/.dotfiles-restore-backup/<timestamp>/`.

## Important after a clean reinstall

Check `system/etc/default/grub` before restoring it. The saved file contains disk-specific boot parameters such as `cryptdevice=UUID=...` and `resume=/dev/mapper/...`; these can change after repartitioning or reinstalling.

Some services are restored as unit files but not force-enabled. After `./install.sh --system`, enable only what is still relevant on the new install, for example `legiond.service`, `legiond-cpuset.timer`, and the user services under `~/.config/systemd/user/`.
