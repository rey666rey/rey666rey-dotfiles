FROM ghcr.io/games-on-whales/xfce:edge

ARG DEBIAN_FRONTEND=noninteractive

RUN dpkg --add-architecture i386 \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        steam-installer \
        libxkbcommon0 \
        libxkbcommon0:i386 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
