#!/usr/bin/env bash

set -e

if id retro >/dev/null 2>&1; then
    usermod -aG sudo retro
    if [ -n "${RETRO_PASSWORD:-}" ]; then
        printf 'retro:%s\n' "$RETRO_PASSWORD" | chpasswd
    fi
fi

chmod 0755 /usr/bin/bwrap 2>/dev/null || true
chmod 0755 /usr/libexec/flatpak-bwrap 2>/dev/null || true
