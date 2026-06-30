# Rainy Morning Plymouth Theme

Soft gray `Plymouth` theme focused on the LUKS unlock prompt:

- blurry rainy background
- small lock icon
- thick title typography
- light, gentle password panel

## Files

- `background.png`: full-screen rainy morning backdrop
- `box.png`: soft dialog panel
- `entry.png`: password field base
- `bullet.png`: password bullets
- `lock.png`: lock icon
- `title.png`: heavy title text
- `rainy-morning.script`: password prompt layout and message handling
- `rainy-morning.plymouth`: theme descriptor

## Install

Copy the directory to your Plymouth themes path:

```bash
sudo mkdir -p /usr/share/plymouth/themes/rainy-morning
sudo cp -r ./* /usr/share/plymouth/themes/rainy-morning/
```

Set it as the default theme:

```bash
sudo plymouth-set-default-theme -R rainy-morning
```

On Debian or Ubuntu systems, if `plymouth-set-default-theme` is not present:

```bash
sudo update-alternatives --install /usr/share/plymouth/themes/default.plymouth default.plymouth /usr/share/plymouth/themes/rainy-morning/rainy-morning.plymouth 200
sudo update-alternatives --config default.plymouth
sudo update-initramfs -u
```

## Test

If `plymouth-x11` is installed, test the prompt like this:

```bash
sudo plymouthd --no-daemon --debug
sudo plymouth show-splash
sudo plymouth --ask-for-password
```
