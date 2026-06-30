# Wolf Docker Setup

This is the portable part of `~/wolf`.

Included:

- `docker-compose.yml`
- active Wolf config: `user-config/cfg/config.toml`
- host/init scripts
- custom XFCE Steam Dockerfile
- selected XFCE settings
- empty runtime mount directories

Intentionally excluded:

- `user-config/cfg/key.pem` and `cert.pem`
- crash dumps and logs
- Steam/runtime home data
- Pulse cookies, browser/profile data, `.gnupg`, `.pki`
- Mesa/Nvidia/Flatpak caches
- copied Nvidia 32-bit driver libraries

After restoring on a fresh system, rebuild the local image and regenerate Nvidia compatibility libraries:

```bash
cd ~/wolf
./update-nvidia-compat32.sh
docker build -t wolf-xfce-steam-native:local ./xfce-steam-native
docker compose up -d
```

If you need the `retro` user password inside the XFCE container, pass it via `RETRO_PASSWORD` instead of storing it in git.
